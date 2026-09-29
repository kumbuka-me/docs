import { mkdir, readFile } from "node:fs/promises";
import { join } from "node:path";
import { chromium } from "playwright";

const baseURL = process.env.SCREENSHOT_BASE_URL;
const archive = process.env.SCREENSHOT_ARCHIVE;
const pluginArchive = process.env.SCREENSHOT_PLUGIN_ARCHIVE;
const pluginMetadata = process.env.SCREENSHOT_PLUGIN_METADATA;
const output = process.env.SCREENSHOT_OUTPUT;
const pluginOutput = process.env.SCREENSHOT_PLUGIN_OUTPUT;
const editorSlug = process.env.SCREENSHOT_EDITOR_SLUG;
const browserChannel = (process.env.SCREENSHOT_BROWSER_CHANNEL || "").trim();
const deviceScaleFactor = Number(
  process.env.SCREENSHOT_DEVICE_SCALE_FACTOR || "2",
);
const visitPaths = (process.env.SCREENSHOT_VISITS || "")
  .split(",")
  .map((value) => value.trim())
  .filter(Boolean);

if (
  !baseURL ||
  !archive ||
  !pluginArchive ||
  !pluginMetadata ||
  !output ||
  !pluginOutput ||
  !editorSlug
) {
  throw new Error("Missing screenshot environment configuration.");
}
if (!Number.isFinite(deviceScaleFactor) || deviceScaleFactor <= 0) {
  throw new Error(
    `SCREENSHOT_DEVICE_SCALE_FACTOR must be positive, got ${JSON.stringify(process.env.SCREENSHOT_DEVICE_SCALE_FACTOR)}.`,
  );
}

for (const path of visitPaths) {
  if (!path.startsWith("/")) {
    throw new Error(`Screenshot visit path must be absolute: ${path}`);
  }
}

await mkdir(output, { recursive: true });
await mkdir(pluginOutput, { recursive: true });

const launchOptions = { headless: true };
if (browserChannel) launchOptions.channel = browserChannel;

async function pluginFixtures() {
  let fixtures;
  try {
    fixtures = JSON.parse(await readFile(pluginMetadata, "utf8"));
  } catch (error) {
    const reason = error instanceof Error ? error.message : String(error);
    throw new Error(`Could not read plugin screenshot metadata: ${reason}`);
  }

  if (!Array.isArray(fixtures) || fixtures.length === 0) {
    throw new Error("Plugin screenshot metadata contains no plugins.");
  }

  for (const plugin of fixtures) {
    if (
      !plugin ||
      typeof plugin.id !== "string" ||
      typeof plugin.name !== "string" ||
      typeof plugin.version !== "string"
    ) {
      throw new Error("Plugin screenshot metadata is invalid.");
    }
  }

  return fixtures;
}

function responseSummary(content) {
  return content
    .replace(/<script[\s\S]*?<\/script>/gi, " ")
    .replace(/<style[\s\S]*?<\/style>/gi, " ")
    .replace(/<[^>]+>/g, " ")
    .replace(/&nbsp;/g, " ")
    .replace(/&amp;/g, "&")
    .replace(/\s+/g, " ")
    .trim()
    .slice(0, 240);
}

async function settle(page) {
  await page.evaluate(() => document.fonts.ready);
  await page.waitForFunction(() =>
    [...document.images].every((image) => image.complete),
  );

  const frames = page.locator("iframe.kumbuka-plugin-frame");
  if ((await frames.count()) > 0) {
    await page.waitForFunction(
      () =>
        [...document.querySelectorAll("iframe.kumbuka-plugin-frame")].every(
          (frame) => frame.dataset.pluginReady === "true",
        ),
      undefined,
      { timeout: 15_000 },
    );
  }

  await page.waitForTimeout(100);
}

const browser = await chromium.launch(launchOptions);

try {
  const context = await browser.newContext({
    viewport: { width: 1440, height: 960 },
    deviceScaleFactor,
    colorScheme: "light",
    reducedMotion: "reduce",
    serviceWorkers: "block",
  });
  const page = await context.newPage();

  page.setDefaultTimeout(15_000);

  async function screenshot(filename) {
    await settle(page);
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

  async function importArchive(filename) {
    const importURL = new URL("/admin/import", baseURL).toString();
    const importTimeout = 180_000;
    const response = await context.request.post(importURL, {
      multipart: {
        format: "markdown",
        files: {
          name: "documentation.zip",
          mimeType: "application/zip",
          buffer: await readFile(filename),
        },
      },
      maxRedirects: 0,
      timeout: importTimeout,
    });

    if (response.status() !== 303) {
      const details = responseSummary(await response.text());
      throw new Error(
        `Could not import ${filename}: HTTP ${response.status()}${details ? `: ${details}` : ""}`,
      );
    }

    const location = response.headers().location;
    if (!location) {
      throw new Error(`Could not import ${filename}: response did not include a redirect.`);
    }

    const resultURL = new URL(location, baseURL);
    if (
      resultURL.pathname !== "/admin/import" ||
      !/^\d+$/.test(resultURL.searchParams.get("result") || "")
    ) {
      throw new Error(`Could not import ${filename}: unexpected redirect ${location}.`);
    }
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

  async function installedPluginStates() {
    await page.goto(`${baseURL}/admin/plugins`, { waitUntil: "networkidle" });
    const states = await page
      .locator(".plugin-row[data-plugin-detail-open]")
      .evaluateAll((rows) =>
        rows.map((row) => {
          const control = row.querySelector("[data-plugin-state-control]");
          return [
            row.dataset.pluginDetailOpen,
            {
              version:
                row
                  .querySelector("[data-plugin-installed-version]")
                  ?.textContent?.trim() || "",
              enabled:
                control
                  ?.querySelector(".plugin-state")
                  ?.classList.contains("enabled") === true,
              required: control?.textContent?.includes("Required") === true,
            },
          ];
        }),
      );
    return new Map(states);
  }

  async function disablePlugin(plugin) {
    const path = `/admin/plugins/${encodeURIComponent(plugin.id)}/disable?defer_render=1`;
    const response = await context.request.post(
      new URL(path, baseURL).toString(),
      { maxRedirects: 0 },
    );
    if (response.status() === 303) return { ok: true, message: "" };
    return {
      ok: false,
      message: `HTTP ${response.status()}: ${responseSummary(await response.text())}`,
    };
  }

  async function enablePlugin(plugin) {
    const path = `/admin/plugins/${encodeURIComponent(plugin.id)}/enable?defer_render=1`;
    const response = await context.request.post(
      new URL(path, baseURL).toString(),
      { maxRedirects: 0 },
    );
    if (response.status() === 303) return { ok: true, message: "" };
    return {
      ok: false,
      message: `HTTP ${response.status()}: ${responseSummary(await response.text())}`,
    };
  }

  async function rebuildPluginPreview(plugin) {
    const slug = `__screenshots/plugins/${plugin.name}`;
    const response = await context.request.post(
      new URL(`/admin/pages/render/${slug}`, baseURL).toString(),
      { maxRedirects: 0 },
    );
    if (response.status() !== 303) {
      throw new Error(
        `Could not rebuild ${slug}: HTTP ${response.status()}: ${responseSummary(await response.text())}`,
      );
    }
  }

  async function applyWithDependencyRetries(items, action, description) {
    let pending = [...items];
    const failures = new Map();

    while (pending.length > 0) {
      const next = [];
      let progressed = false;

      for (const item of pending) {
        const result = await action(item);
        if (result.ok) {
          progressed = true;
          failures.delete(item.plugin.id);
        } else {
          failures.set(item.plugin.id, result.message);
          next.push(item);
        }
      }

      if (!progressed) {
        const details = next
          .map(
            ({ plugin }) =>
              `${plugin.id}: ${failures.get(plugin.id) || "unknown failure"}`,
          )
          .join("\n");
        throw new Error(`Could not ${description}:\n${details}`);
      }
      pending = next;
    }
  }

  async function disablePreviewPlugins(fixtures) {
    const states = await installedPluginStates();
    const missing = fixtures.filter((plugin) => !states.has(plugin.id));
    if (missing.length > 0) {
      throw new Error(
        `Pinned Kumbuka release does not bundle expected plugins:\n${missing
          .map((plugin) => `${plugin.id} ${plugin.version}`)
          .join("\n")}`,
      );
    }

    const mismatched = fixtures.filter(
      (plugin) => states.get(plugin.id)?.version !== plugin.version,
    );
    if (mismatched.length > 0) {
      throw new Error(
        `Bundled plugin versions do not match the pinned Kumbuka release:\n${mismatched
          .map(
            (plugin) =>
              `${plugin.id}: expected ${plugin.version}, found ${states.get(plugin.id)?.version || "unknown"}`,
          )
          .join("\n")}`,
      );
    }

    const enabled = fixtures
      .filter((plugin) => {
        const state = states.get(plugin.id);
        return state?.enabled && !state.required;
      })
      .map((plugin) => ({ plugin }));

    await applyWithDependencyRetries(
      enabled.reverse(),
      async ({ plugin }) => disablePlugin(plugin),
      "disable preview plugins before importing fixtures",
    );
  }

  async function enablePreviewPlugins(fixtures) {
    await applyWithDependencyRetries(
      fixtures.map((plugin) => ({ plugin })),
      async ({ plugin }) => enablePlugin(plugin),
      "enable preview plugins",
    );

    for (const plugin of fixtures) {
      await rebuildPluginPreview(plugin);
    }
  }

  async function capturePluginPreview(plugin) {
    const path = `/pages/__screenshots/plugins/${plugin.name}`;
    const response = await page.goto(new URL(path, baseURL).toString(), {
      waitUntil: "networkidle",
    });
    if (!response || !response.ok()) {
      throw new Error(
        `Plugin preview page ${path} returned HTTP ${response?.status() ?? "unknown"}.`,
      );
    }

    await page.addStyleTag({
      content: `
        .prose {
          box-sizing: border-box !important;
          width: 820px !important;
          max-width: none !important;
          margin: 0 !important;
          padding: 32px 36px !important;
        }
      `,
    });
    await settle(page);

    const preview = page.locator(".page-reading .prose, article.page .prose").first();
    await preview.waitFor({ state: "visible" });
    const directory = join(pluginOutput, plugin.name);
    await mkdir(directory, { recursive: true });
    await preview.screenshot({
      path: join(directory, "preview.png"),
      animations: "disabled",
    });
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

  await importArchive(archive);

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

  const fixtures = await pluginFixtures();
  await disablePreviewPlugins(fixtures);
  await importArchive(pluginArchive);
  await enablePreviewPlugins(fixtures);
  for (const plugin of fixtures) {
    await capturePluginPreview(plugin);
  }
} finally {
  await browser.close();
}
