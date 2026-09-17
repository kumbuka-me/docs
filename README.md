# Kumbuka Documentation

## Features

- Markdown-first documentation stored in `content/`.
- Static-site generation with the Kumbuka CLI.
- Theme-aware navigation, table of contents, and browser-side search.
- Build-time validation for documentation links and static routes.
- Automatic deployment to GitHub Pages from `main`.

## Requirements

- GNU Make
- `curl`
- Python 3 for local preview
- Node.js/npm for formatting

The pinned Kumbuka CLI and development helpers are downloaded automatically.

## Build locally

```sh
make build
```

Run the same formatting and artifact checks used by CI with:

```sh
make check
```

The generated site is written to `site/`. Build, serve, and open it locally with:

```sh
make serve
```

The local site uses a persistent random port for the current checkout.

## Screenshots

Documentation screenshots are generated from the same Markdown under `content/`; there is no second fixture copy. Keep the Kumbuka server repository next to this checkout and run:

```sh
make screenshots
```

By default this expects the server at `../kumbuka`. Override `KUMBUKA_SERVER_DIR` when it lives elsewhere. Screenshot generation additionally requires Go, Docker, `zip`, and Playwright's Chromium browser. The manual **Documentation Screenshots** workflow checks out the server automatically and commits changed PNGs under `assets/screenshots/`.

# License

Licensed under the [Apache License, Version 2.0](LICENSE).
