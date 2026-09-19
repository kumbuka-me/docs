# Trusted proxy authentication

Trusted-proxy mode accepts identity information from configured HTTP headers. Kumbuka checks the configured username headers in order and uses the first non-empty value. Email and display name are resolved the same way.

Common username headers such as `X-Forwarded-User`, `X-Auth-Request-User`, and `Remote-User` are included in the default configuration.

## Security boundary

Use trusted-proxy authentication only when Kumbuka is reachable exclusively through a proxy that removes client-supplied identity headers and writes authenticated values itself. Direct client access to Kumbuka must not be able to bypass that proxy.

Unknown identities are subject to Kumbuka's user-registration setting.

Header lists are normally managed under **Administration → Configuration**. When trusted-proxy authentication is configured through deployment overrides, the deployment-managed username, email, and display-name header lists are read-only in the UI.

## External administrator group

Configure one or more **Group headers** and an exact **Administrator group** value under **Administration → Configuration**. Kumbuka reads the first non-empty group header, splits comma-separated values, and grants administrator access when one value matches.

This does not change the user's assigned Kumbuka role. Because trusted-proxy identity is evaluated on every request, group changes take effect on the next request.

**Sign out** can revoke local and OIDC browser sessions, but the trusted proxy can authenticate the user again on the next request. Disable the Kumbuka account when access must be blocked completely.

Automatically created trusted-proxy users do not receive a local password. An administrator can add one for `/auth/local`; see [Local authentication](local.md#accounts-and-local-credentials).
