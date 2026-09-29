# Documentation screenshots

The documentation repository owns the complete screenshot scenario. Kumbuka provides the real server used for capture, while `kumbuka-me/plugins` provides the canonical first-party plugin preview Markdown and release versions.

The runner starts an isolated PostgreSQL instance and a real Kumbuka server, completes first-run setup, imports the canonical Markdown from `content/`, visits the configured pages, and captures representative application features with Playwright. It also creates deterministic discussion and review fixtures so those screenshots contain useful inline feedback instead of empty states.

After the application screenshots are complete, the same Kumbuka instance installs or upgrades the documented first-party plugin releases, enables them, imports temporary preview pages built from each plugin's `preview.md` (or `preview.static.md` when present), waits for browser modules to settle, and captures only the rendered page content. The temporary preview pages never enter the documentation repository.

From the documentation repository, with `kumbuka-me/plugins` checked out as the sibling `../plugins` directory:

```sh
make screenshots
```

If the plugins checkout lives elsewhere:

```sh
make screenshots SCREENSHOT_PLUGINS_DIR=/path/to/plugins
```

To capture with a different released Kumbuka version, override the pinned version:

```sh
make screenshots KUMBUKA_VERSION=v0.36.2
```

The runner writes application images under `assets/screenshots/`:

- `dashboard.png`
- `editor.png`
- `editor-visual.png`
- `editor-visual-table.png`
- `knowledge-graph.png`
- `admin-plugins.png`
- `admin-editor-toolbar.png`
- `admin-plugin-settings.png`
- `inline-suggestion.png`
- `review-suggestion.png`
- `documentation-health.png`

Extension previews are written to `assets/plugins/<plugin>/preview.png`. These PNGs are captured from the normal Kumbuka page renderer instead of from the static-site renderer, so browser modules and plugin presentation match normal page view. Screenshots use `SCREENSHOT_DEVICE_SCALE_FACTOR=2` by default for sharp HiDPI output; override it only when a different capture density is intentionally required.

Use `SCREENSHOT_VISITS` to control which imported pages are visited before capturing the dashboard and `SCREENSHOT_EDITOR_SLUG` to choose the page used for the Markdown-preview and primary visual-editor screenshots. The visual table screenshot uses the imported `content/lifecycle` page so it always has a real Markdown table to select.
