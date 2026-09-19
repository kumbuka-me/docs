# Configuration

Kumbuka has two kinds of configuration:

- **Deployment settings** are supplied as command-line flags or `KUMBUKA__` environment variables. They cover values such as the listen address, database URL, public URL, authentication overrides, deployment secrets, logging, and optional service endpoints.
- **Application settings** are changed under **Administration → Configuration**. They cover authentication mode, registration, discussions, crawler settings, external header links, language and presentation defaults, PDF rendering, trusted-proxy headers, and non-secret OIDC settings.

When a deployment override controls a setting, the administration UI marks that field **Managed by deployment** and makes it read-only.

See [Runtime configuration](runtime.md) for the complete flag and environment-variable reference.

## Search-engine crawling

Under **Administration → Configuration**, choose one of:

- **Disallow crawling** — serve `robots.txt` with `Disallow: /`;
- **Allow crawling** — allow crawling and expose `sitemap.xml`;
- **Disabled** — do not expose `robots.txt` or `sitemap.xml`.

New installations default to disallowing crawling. The sitemap contains the home page plus verified and deprecated pages; draft and archived pages are omitted.

## External header links

External links appear beside global search for authenticated users. Each link has a label and HTTP(S) URL, plus optional icon, description, hover effect, and hover text.

Built-in Lucide icons use the `-lucide` suffix. Enabled plugins can contribute additional icons; the first-party Simple Icons plugin uses the `-simple` suffix.

## Branding

The application logo is managed under **Administration → Branding**. See [Branding](../administration/branding.md).

## PDF service

Configure the HTML-to-PDF endpoint and optional request headers under **Administration → Configuration**. Headers such as bearer tokens or API keys can be marked sensitive; configure `KUMBUKA__ENCRYPTION_KEY` so sensitive values can be encrypted at rest.

Use the PDF service test to verify the current endpoint and headers before saving them. A deployment can override only the PDF endpoint with `KUMBUKA__PDF_URL`.
