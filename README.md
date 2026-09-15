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

```bash
make build
```

The generated site is written to `site/`. Build, serve, and open it locally with:

```bash
make serve
```

The local site uses a persistent random port for the current checkout.

## Links

- [Documentation](https://kumbuka.me/)
- [License](./LICENSE)
