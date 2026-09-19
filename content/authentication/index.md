# Authentication

Kumbuka supports three browser authentication modes:

- `local` — Kumbuka-managed usernames and passwords;
- `trusted-proxy` — identity supplied by a trusted reverse proxy;
- `oidc` — login through an OpenID Connect provider.

A `none` mode is available for local development and recovery scenarios. API and media routes can additionally accept [personal access tokens](../api/tokens.md) where supported.

Kumbuka has three roles:

- `admin` can administer Kumbuka and perform destructive page operations;
- `editor` can create and edit content;
- `viewer` can use authenticated read features.

OIDC and trusted-proxy authentication can grant effective administrator access from a configured external group without changing the user's assigned Kumbuka role. Disabling a Kumbuka account blocks all browser authentication modes and personal access tokens.

New-user registration is controlled by an application setting. Unknown OIDC identities can be queued for administrator approval when registration is closed.

Read the mode-specific pages:

- [Local authentication](local.md)
- [Trusted proxy](trusted-proxy.md)
- [OIDC](oidc.md)

Generated static sites have no authentication; see [Static sites](../static-sites.md).
