# Documentation screenshots

The documentation repository owns the complete screenshot scenario. Kumbuka provides only the server source that is built and started for the capture.

The runner creates an isolated PostgreSQL instance, builds the selected Kumbuka checkout, completes first-run setup, imports the canonical Markdown from `content/`, visits the configured pages, and captures representative application features with Playwright. It also creates deterministic discussion and review fixtures so those screenshots contain useful inline feedback instead of empty states.

From the documentation repository:

```sh
make screenshots
```

By default the server checkout is expected at `../kumbuka`. Override it when necessary:

```sh
make screenshots KUMBUKA_SERVER_DIR=/path/to/kumbuka
```

The runner writes these generated images under `assets/screenshots/`:

- `dashboard.png`
- `editor.png`
- `knowledge-graph.png`
- `admin-plugins.png`
- `inline-suggestion.png`
- `review-suggestion.png`
- `documentation-health.png`

Plugin previews are maintained in the plugins repository and synchronized into `assets/plugins/` with their generated documentation. This runner only replaces application screenshots directly under `assets/screenshots/`.

Use `SCREENSHOT_VISITS` to control which imported pages are visited before capturing the dashboard and `SCREENSHOT_EDITOR_SLUG` to choose the page opened in the editor screenshot.
