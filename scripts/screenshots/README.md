# Documentation screenshots

The documentation repository owns the complete screenshot scenario. Kumbuka provides only the server source that is built and started for the capture.

The runner creates an isolated PostgreSQL instance, builds the selected Kumbuka checkout, completes first-run setup, imports the canonical Markdown from `content/`, visits the configured pages, and captures the dashboard and editor with Playwright.

From the documentation repository:

```sh
make screenshots
```

By default the server checkout is expected at `../kumbuka`. Override it when necessary:

```sh
make screenshots KUMBUKA_SERVER_DIR=/path/to/kumbuka
```

The runner writes `dashboard.png` and `editor.png` under `assets/screenshots/`. Use `SCREENSHOT_VISITS` to control which imported pages are visited before capturing the dashboard and `SCREENSHOT_EDITOR_SLUG` to choose the page opened in the editor screenshot.
