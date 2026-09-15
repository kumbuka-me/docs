# Trusted proxy authentication

Trusted-proxy mode accepts identity information from configured HTTP headers. Kumbuka checks the configured username headers in order and uses the first non-empty value. Email and display name are resolved the same way.

Built-in deployment defaults include common headers such as `X-Forwarded-User`, `X-Auth-Request-User`, and `Remote-User` for usernames.

## Security boundary

Only use this mode when Kumbuka is reachable exclusively through a proxy that removes untrusted client-supplied identity headers and writes its own authenticated headers. If clients can connect directly to Kumbuka or inject those headers, the authentication boundary is broken.

Unknown trusted-proxy identities are subject to Kumbuka's user-registration setting.

Persistent trusted-proxy header lists are managed in **Administration → Configuration**. With the trusted-proxy runtime authentication override active, deployment-level username, email, and display-name header lists become read-only in the UI. Group headers and the administrator group remain database-managed.

## External administrator group

Configure one or more **Group headers** and an exact **Administrator group** value in **Administration → Configuration**. Kumbuka reads the first non-empty configured group header, splits comma-separated values, and grants effective administrator access when one value matches. This elevation is separate from the manually assigned Kumbuka role: an administrator can still promote or demote the account independently.

Unlike OIDC, trusted-proxy authentication is asserted on every request rather than stored in a Kumbuka login session. Group changes therefore take effect on the next request. The user page records the last assertion and warns when a manually assigned Kumbuka administrator is no longer in the configured external administrator group.

The **Sign out** action revokes local and OIDC browser sessions, but it cannot prevent a trusted proxy from authenticating the user again on the next request. Disable the Kumbuka account when access must be blocked. A disabled account is also denied local login, OIDC login, and personal API-token access.

Automatically created trusted-proxy accounts do not receive a local password. An administrator may explicitly grant one for `/auth/local`; see [Local authentication](local.md#accounts-and-local-credentials).
