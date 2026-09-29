# Kumbuka Documentation

This repository contains the documentation published at [kumbuka.me](https://kumbuka.me/).

## Build

Build the static documentation site:

```sh
make build
```

The generated site is written to `site/`.

## Preview locally

Build the documentation and serve it locally:

```sh
make serve
```

The site opens automatically in your browser.

## Screenshots

Regenerate the documentation screenshots and plugin previews:

```sh
make screenshots
```

By default the screenshot runner uses sibling checkouts at `../kumbuka` and `../plugins`. It builds the current Kumbuka source, starts a temporary instance, imports the documentation, and captures the required screenshots. Plugin previews are generated with the current plugin source as well.

If the repositories live elsewhere:

```sh
make screenshots \
  SCREENSHOT_KUMBUKA_DIR=/path/to/kumbuka \
  SCREENSHOT_PLUGINS_DIR=/path/to/plugins
```

Generated screenshots are written to `assets/screenshots/` and `assets/plugins/<plugin>/preview.png`.

## Plugin catalog

The first-party plugin catalog is stored in `content/plugins/catalog.json` and is published as `/plugins/catalog.json`.

## License

Licensed under the [Apache License, Version 2.0](LICENSE).
