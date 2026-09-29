# Documentation screenshots

The screenshot runner uses a real Kumbuka instance so generated images match the normal application renderer.

From the documentation repository, with sibling `../kumbuka` and `../plugins` checkouts:

```sh
make screenshots
```

The target builds the current Kumbuka checkout and the current first-party plugin packages before starting an isolated PostgreSQL instance. It imports the documentation, captures the application screenshots, installs the locally built plugin packages, imports their preview fixtures, and captures the rendered plugin previews.

Use different checkout locations when needed:

```sh
make screenshots \
  SCREENSHOT_KUMBUKA_DIR=/path/to/kumbuka \
  SCREENSHOT_PLUGINS_DIR=/path/to/plugins
```

Application screenshots are written to `assets/screenshots/`. Extension previews are written to `assets/plugins/<plugin>/preview.png`. Captures use `SCREENSHOT_DEVICE_SCALE_FACTOR=2` by default for sharp HiDPI output.
