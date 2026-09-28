# Trusted proxy authentication

Trusted-proxy mode accepts identity information from configured HTTP headers. Kumbuka checks the configured username headers in order and uses the first non-empty value. Email and display name are resolved the same way.

Common username headers such as `X-Forwarded-User`, `X-Auth-Request-User`, and `Remote-User` are included in the default configuration.

## Security boundary

Use trusted-proxy authentication only when Kumbuka is reachable exclusively through a proxy that removes client-supplied identity headers and writes authenticated values itself. Direct client access to Kumbuka must not be able to bypass that proxy.

Unknown identities are subject to Kumbuka's user-registration setting.

Header lists are normally managed under **Administration → Configuration**. When trusted-proxy authentication is configured through deployment overrides, the deployment-managed username, email, and display-name header lists are read-only in the UI.

## OpenShift OAuth Proxy

For OpenShift OAuth Proxy, use `X-Forwarded-User` as the identity header and `X-Forwarded-Email` as mutable email metadata. Configure them as follows:

```text
Username headers: X-Forwarded-User
Email headers: X-Forwarded-Email
```

Kumbuka does not require an immutable user-ID header or a groups header for this integration. Do not use email to identify or link an account: the exact `X-Forwarded-User` value is the trusted-proxy identity key. As with every trusted-proxy deployment, the proxy must remove client-supplied identity headers before setting its authenticated values, and Kumbuka must not be directly reachable around that proxy.

## Profile synchronization and relinking

Email and display name update from the configured trusted headers on each request by default. An administrator can override either field under **Administration → Users**; only the overridden field stops syncing. Restoring a field to provider-managed immediately applies the latest value observed from the proxy.

The proxy username is not an ordinary profile field because it is the account's external identity key. Use the administrator-only **Relink identity** action to change it. Relinking rejects a username already bound to another account, removes the old binding, and records the change in the audit log.

## External administrator group

Configure one or more **Group headers** and an exact **Administrator group** value under **Administration → Configuration**. Kumbuka reads the first non-empty group header, splits comma-separated values, and grants administrator access when one value matches.

This does not change the user's assigned Kumbuka role. Because trusted-proxy identity is evaluated on every request, group changes take effect on the next request.

**Sign out** can revoke local and OIDC browser sessions, but the trusted proxy can authenticate the user again on the next request. Disable the Kumbuka account when access must be blocked completely.

Automatically created trusted-proxy users do not receive a local password. An administrator can add one for `/auth/local`; see [Local authentication](local.md#accounts-and-local-credentials).
