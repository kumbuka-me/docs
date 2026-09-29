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

Regenerate the application screenshots and plugin previews:

```sh
make screenshots
```

The pinned Kumbuka release is downloaded automatically. Its matching first-party plugins are already bundled in the release binary. Plugin preview fixtures are cached under `bin/screenshot-fixtures/`, so unchanged versions are reused on later runs.

Generated images are written to `assets/screenshots/` and `assets/plugins/<plugin>/preview.png`.

## Plugin catalog

The first-party plugin catalog is stored in `content/plugins/catalog.json` and is published as `/plugins/catalog.json`.

## License

Licensed under the [Apache License, Version 2.0](LICENSE).
