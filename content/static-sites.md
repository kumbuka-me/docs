# Static sites

`kumbuka-cli build` turns a directory of Markdown files into a read-only documentation site. No Kumbuka server or PostgreSQL database is required to serve the generated files.

## Build

```sh
kumbuka-cli build
```

By default, the CLI looks for `kumbuka-site.toml`. Use `--config` to select another file.

Without a configuration file, the defaults are:

- site name: `Documentation`;
- source directory: `docs`;
- output directory: `site`;
- sidebar navigation with comfortable density;
- 280-pixel sidebar width.

## Configuration

Example `site.toml`:

```toml
site_name = "My Documentation"
site_url = "https://docs.example.com/"

source_dir = "content"
output_dir = "site"

theme = "Light"
language = "en"
navigation_style = "sidebar"
navigation_density = "comfortable"
sidebar_width = 280
robots = "allow"

logo = "assets/logo.svg"
favicon = "assets/favicon.svg"
favicon_ico = "assets/favicon.ico"
assets_dir = "assets"

[[external_links]]
label = "Repository"
url = "https://github.com/example/project"
icon = "github-simple"
description = "v2.4.1"
hover_effect = "lift"
hover_text = "{{label}} | {{description}}"
```

`site_url` sets the public URL prefix used in generated links. Set it correctly when the site is hosted below a path, such as a GitHub Pages project site.

`navigation_style` accepts `sidebar`, `topbar`, or `tree`. `navigation_density` accepts `comfortable` or `compact`. `sidebar_width` must be between 220 and 420 pixels.

`robots` accepts:

- `allow` — allow crawling and generate a sitemap when `site_url` is an absolute HTTP(S) URL;
- `disallow` — generate `robots.txt` with `Disallow: /`;
- `none` — do not generate `robots.txt`.

Each `external_links` entry requires a label and absolute HTTP(S) URL. Icons and descriptions are optional. Enabled static-site plugins can contribute additional icon sets.

## Project plugins

Static builds use `.kumbukaplugins` to pin optional rendering and presentation plugins. Manage the file with the CLI:

```sh
kumbuka-cli plugins list
kumbuka-cli plugins sync
kumbuka-cli plugins add \
  --id com.example.chart \
  --repository example/kumbuka-chart \
  --plugin-version 2.3.0
kumbuka-cli plugins remove --id com.example.chart
```

Use `--plugins FILE` to select a different plugin dependency file for one build.

## Filesystem routes

The source directory must contain a root `index.md`, which becomes the site home page. Markdown paths map to clean URLs:

```text
docs/index.md                   -> /
docs/getting-started.md         -> /getting-started/
docs/installation/index.md      -> /installation/
docs/installation/docker.md     -> /installation/docker/
```

When `site_url` contains a path prefix, the prefix is added to generated URLs.

## Links and assets

Normal relative Markdown links are rewritten to generated routes:

```markdown
[Docker](installation/docker.md)
```

A link to a missing Markdown source file fails the build. Kumbuka wiki links are also resolved during the build, and unresolved or ambiguous targets fail validation.

Non-Markdown files under the source directory are copied to the generated site. Relative image and asset links are rewritten to remain valid after page URLs become directory-style routes.

The Subpages plugin supports `{{subpages}}` in static builds when it is declared in `.kumbukaplugins`.

## Logos, favicons, and extra assets

Static-site branding is configured in the site configuration and is independent of branding configured in the Kumbuka server.

```toml
logo = "assets/logo.svg"
favicon = "assets/favicon.svg"
favicon_ico = "assets/favicon.ico"
assets_dir = "assets"
```

These paths are resolved relative to the configuration file. Relative paths may use `../`, and absolute paths are also supported.

Supported image formats are SVG, PNG, JPEG, WebP, GIF, and ICO. `favicon_ico` must reference an ICO file. If `logo`, `favicon`, or `favicon_ico` is omitted, that branding element is omitted from the generated site.

Do not edit the output directory manually; each build recreates it.

## Generated output

A static build includes the generated pages, a `404.html` page, search data, selected theme and plugin assets, source assets, and `.nojekyll`. It can also include `robots.txt` and `sitemap.xml` according to the site configuration.

Static sites do not include the editor, authentication, account settings, administration UI, drafts, notifications, API tokens, or write APIs. The generated directory can be hosted by GitHub Pages, Cloudflare Pages, S3-compatible storage, or any normal web server.

## GitHub Pages

A typical Pages workflow installs `kumbuka-cli`, runs `kumbuka-cli build`, and publishes the configured output directory. No PostgreSQL service is needed for the build.
