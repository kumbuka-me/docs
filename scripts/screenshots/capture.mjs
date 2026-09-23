import { mkdir } from "node:fs/promises";
import { chromium } from "playwright";

const baseURL = process.env.SCREENSHOT_BASE_URL;
const archive = process.env.SCREENSHOT_ARCHIVE;
const output = process.env.SCREENSHOT_OUTPUT;
const editorSlug = process.env.SCREENSHOT_EDITOR_SLUG;
const browserChannel = (process.env.SCREENSHOT_BROWSER_CHANNEL || "").trim();
const visitPaths = (process.env.SCREENSHOT_VISITS || "")
  .split(",")
  .map((value) => value.trim())
  .filter(Boolean);

if (!baseURL || !archive || !output || !editorSlug) {
  throw new Error("Missing screenshot environment configuration.");
}

for (const path of visitPaths) {
  if (!path.startsWith("/")) {
    throw new Error(`Screenshot visit path must be absolute: ${path}`);
  }
}

await mkdir(output, { recursive: true });

const launchOptions = { headless: true };
if (browserChannel) launchOptions.channel = browserChannel;

const browser = await chromium.launch(launchOptions);

try {
  const context = await browser.newContext({
    viewport: { width: 1440, height: 960 },
    deviceScaleFactor: 1,
    colorScheme: "light",
    reducedMotion: "reduce",
    serviceWorkers: "block",
  });
  const page = await context.newPage();

  page.setDefaultTimeout(15_000);

  async function screenshot(filename) {
    await page.evaluate(() => document.fonts.ready);
    await page.screenshot({
      path: `${output}/${filename}`,
      animations: "disabled",
    });
  }

  async function capture(path, filename, readySelector = "") {
    await page.goto(new URL(path, baseURL).toString(), {
      waitUntil: "networkidle",
    });
    if (readySelector) {
      await page.locator(readySelector).first().waitFor({ state: "visible" });
    }
    await screenshot(filename);
  }

  async function openEditor(slug) {
    await page.goto(`${baseURL}/edit/${slug}`, {
      waitUntil: "networkidle",
    });
    await page.locator("[data-editor-workspace]").waitFor({ state: "visible" });
  }

  async function selectEditorMode(mode) {
    await page.locator(`button[data-editor-mode="${mode}"]`).click();
    await page
      .locator(`[data-editor-workspace][data-editor-mode="${mode}"]`)
      .waitFor({ state: "visible" });
  }

  async function captureMarkdownPreview() {
    await openEditor(editorSlug);
    await selectEditorMode("write");
    await page.locator("[data-editor-preview-toggle]").click();
    await page
      .locator('[data-editor-workspace][data-editor-mode="split"]')
      .waitFor({ state: "visible" });
    await page.locator("[data-editor-preview-status]").waitFor({
      state: "hidden",
    });
    await page.locator("[data-editor-preview-content] > *").first().waitFor();
    await screenshot("editor.png");
  }

  async function captureVisualEditor(slug, filename) {
    await openEditor(slug);
    await selectEditorMode("visual");
    await page
      .locator("[data-visual-editor-pane] .tiptap")
      .waitFor({ state: "visible" });
    await screenshot(filename);
  }

  async function captureVisualTable() {
    await openEditor("content/lifecycle");
    await selectEditorMode("visual");

    const table = page.locator("[data-visual-editor-pane] table").first();
    await table.waitFor({ state: "visible" });
    await table.locator("th, td").first().click();
    await page
      .locator("[data-table-context-toolbar]")
      .waitFor({ state: "visible" });
    await screenshot("editor-visual-table.png");
  }

  async function postFixture(path, form) {
    const response = await context.request.post(
      new URL(path, baseURL).toString(),
      {
        form,
        maxRedirects: 0,
      },
    );
    if (response.status() !== 303) {
      throw new Error(
        `Fixture request ${path} returned ${response.status()}: ${await response.text()}`,
      );
    }

    const location = response.headers().location;
    if (!location)
      throw new Error(`Fixture request ${path} returned no location.`);

    return location;
  }

  await page.goto(`${baseURL}/setup`, { waitUntil: "networkidle" });
  await page.locator('input[name="username"]').fill("admin");
  await page.locator('input[name="display_name"]').fill("Administrator");
  await page.locator('input[name="password"]').fill("kumbuka-screenshot-admin");
  await page
    .locator('input[name="password_confirm"]')
    .fill("kumbuka-screenshot-admin");
  await Promise.all([
    page.waitForURL(/\/admin\/configuration$/),
    page.getByRole("button", { name: "Create administrator" }).click(),
  ]);

  await page.goto(`${baseURL}/admin/import`, { waitUntil: "networkidle" });
  await page
    .locator('input[type="file"][name="files"]:not([webkitdirectory])')
    .setInputFiles(archive);
  await Promise.all([
    page.waitForURL(/\/admin\/import\?result=\d+$/),
    page.getByRole("button", { name: "Import pages" }).click(),
  ]);

  for (const path of visitPaths) {
    await page.goto(new URL(path, baseURL).toString(), {
      waitUntil: "networkidle",
    });
  }

  await capture("/", "dashboard.png");

  await captureMarkdownPreview();
  await captureVisualEditor(editorSlug, "editor-visual.png");
  await captureVisualTable();

  await capture(
    "/graph",
    "knowledge-graph.png",
    "[data-graph-svg] .graph-node",
  );
  await capture("/admin/plugins", "admin-plugins.png", ".plugin-table");
  await capture(
    "/admin/editor-toolbar",
    "admin-editor-toolbar.png",
    ".admin-table",
  );
  await capture(
    "/admin/plugin-settings/me.kumbuka.tables",
    "admin-plugin-settings.png",
    ".plugin-settings-panel",
  );

  const discussionSlug = "collaboration/discussions-notifications";
  const discussionTarget = await postFixture(
    `/page-comments/${discussionSlug}`,
    {
      kind: "suggestion",
      anchor: "Every discussion comment has a permalink.",
      body: "Make the sentence a little more explicit.",
      replacement: "Every discussion comment has a stable permalink.",
    },
  );
  await capture(
    discussionTarget,
    "inline-suggestion.png",
    "[data-inline-comment-panel]:not([hidden]) .page-comment-suggestion",
  );

  const reviewSlug = "collaboration/review-approvals";
  await postFixture(`/pages/approval/request/${reviewSlug}`, {
    reviewers: "@admin",
    reviewer_group_id: "",
    note: "Please verify the workflow wording and examples.",
  });
  await page.goto(new URL(`/pages/${reviewSlug}`, baseURL).toString(), {
    waitUntil: "networkidle",
  });
  const reviewPath = await page
    .locator('a[href^="/reviews/"]')
    .first()
    .getAttribute("href");
  if (!reviewPath)
    throw new Error("Review fixture did not expose its review URL.");

  const reviewID = reviewPath.match(/^\/reviews\/(\d+)\//)?.[1];
  if (!reviewID) throw new Error(`Unexpected review URL: ${reviewPath}`);

  const reviewTarget = await postFixture(
    `/reviews/${reviewID}/comments/${reviewSlug}`,
    {
      side: "new",
      start_line: "1",
      end_line: "1",
      kind: "suggestion",
      body: "Use a more explicit heading for the workflow.",
      replacement: "# Review and approval workflow",
    },
  );
  await capture(reviewTarget, "review-suggestion.png", ".review-suggestion");

  await capture("/admin/health", "documentation-health.png", ".health-grid");
} finally {
  await browser.close();
}
