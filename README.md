# Kumbuka Documentation

This repository contains the documentation published at [kumbuka.me](https://kumbuka.me/).

## Build

Build the static documentation site:

```sh
make build
```

The generated site is written to `site/`.

## Preview locally

Build and preview the documentation with the Kumbuka CLI:

```sh
make serve
```

The site opens automatically in your browser. The CLI watches Markdown, site configuration, assets, and plugin dependencies; when an input changes, it rebuilds the site and reloads the browser. A failed rebuild leaves the last successful site available. Stop the preview with `Ctrl+C`.

`make serve` uses the pinned `kumbuka-cli` release (v0.14.0 or newer) and a checkout-specific local port. It does not require Python, a Kumbuka server, or PostgreSQL. To run the preview command directly, use:

```sh
kumbuka-cli serve --config site.toml --listen-address 127.0.0.1:8000
```

For additional options, including serving an already-built site without watching for changes, see [Static sites](content/static-sites.md#preview-locally).

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
