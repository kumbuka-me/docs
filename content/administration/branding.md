# Branding

Administrators can customize Kumbuka's instance-wide application logo under **Administration → Branding**.

Kumbuka uses the embedded `favicon.svg` as the default logo. The same logo is shown in the authenticated application header and on public application surfaces such as login, setup, and shared pages.

## Custom logo

Upload a replacement from **Administration → Branding → Application logo**. Supported formats are PNG, JPEG, GIF, WebP, and passive SVG. The maximum file size is 2 MiB. Transparent backgrounds generally work best across Kumbuka themes.

SVG uploads must be passive image documents. Kumbuka rejects active content such as scripts, embedded executable content, event-handler attributes, and external resource references before storing the file.

The custom logo is stored in PostgreSQL and applies to the complete Kumbuka instance. It is not a per-user preference and does not require a deployment-level file or environment variable.

## Restore the default

Select **Use default favicon** to remove the custom logo and return immediately to the embedded `favicon.svg`.

## Static sites

Server branding and static-site branding are independent. `kumbuka-cli build` does not read the logo stored in PostgreSQL. Configure `logo`, `favicon`, and `favicon_ico` in `site.toml` when a generated static site needs branding. See [Static sites](../static-sites.md#logos-favicons-and-extra-assets).
