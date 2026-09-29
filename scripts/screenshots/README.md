# Documentation screenshots

Run the complete screenshot flow from the documentation repository:

```sh
make screenshots
```

The Makefile downloads the pinned Kumbuka and Kumbuka CLI release binaries. The runner starts an isolated PostgreSQL instance, imports `content/`, syncs the plugin versions bundled with the selected Kumbuka release, and captures the application and plugin previews with Playwright.

Application screenshots are written to `assets/screenshots/`. Plugin previews are written to `assets/plugins/<plugin>/preview.png`.

Captures use a 2× device scale factor by default for sharp HiDPI output.
