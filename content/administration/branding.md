# Branding

Administrators can customize the instance-wide application logo under **Administration → Branding**. The logo is used in the application header and on public surfaces such as login, setup, and shared pages.

## Custom logo

Upload a replacement under **Application logo**. Supported formats are PNG, JPEG, GIF, WebP, and passive SVG, with a maximum size of 2 MiB. Transparent backgrounds generally work best across themes.

SVG files must not contain active content such as scripts, event handlers, embedded executable content, or external resource references.

## Restore the default

Select **Use default favicon** to return to Kumbuka's built-in logo.

## Static sites

Static-site branding is configured separately. Set `logo`, `favicon`, and `favicon_ico` in `site.toml`; see [Static sites](../static-sites.md#logos-favicons-and-extra-assets).
