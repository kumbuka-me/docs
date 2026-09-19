# OIDC

OIDC mode uses authorization-code login with provider discovery, S256 PKCE, and an ID-token nonce check. Kumbuka identifies an account by the verified issuer and subject; username, email, and display name are profile attributes.

## Required deployment secrets

Set:

```text
KUMBUKA__OIDC_CLIENT_SECRET
KUMBUKA__OIDC_SESSION_SECRET
```

Copy `KUMBUKA__OIDC_CLIENT_SECRET` from the Kumbuka client in your identity provider.

Generate the session secret once during initial setup:

```sh
openssl rand -base64 32
```

Store the complete output as `KUMBUKA__OIDC_SESSION_SECRET`. Use a different value from `KUMBUKA__ENCRYPTION_KEY`. See [Generate deployment secrets](../configuration/runtime.md#generate-deployment-secrets).

OIDC sessions last 12 hours. Keep the same session secret on every replica and across restarts; changing it signs out users and invalidates pending logins.

The issuer, client ID, group claim, administrator group, and group mappings can normally be managed under **Administration → Configuration**. When `KUMBUKA__AUTH_MODE=oidc` is configured by the deployment, the issuer and client ID are also deployment-managed and read-only in the UI.

## External administrator group

Set **Group claim** to the top-level ID-token claim containing group memberships, then set **Administrator group** to the exact value that grants administrator access. The claim may be a string or an array of strings.

Membership grants administrator access for the OIDC session but does not change the user's assigned Kumbuka role. A manually assigned administrator therefore remains an administrator even after leaving the external group.

Removing a user from the identity-provider group affects new logins. Use **Sign out** under **Administration → Users** to invalidate that user's existing browser sessions immediately.

For Keycloak, configure a group-membership or role mapper so the required value is included in the ID token under the same claim name configured in Kumbuka.

## Group synchronization

Kumbuka can map values from a top-level OIDC group claim to Kumbuka collaboration groups. In authoritative mode, mapped memberships are removed when their external values disappear from the current claim.

## Unknown identities

When automatic user creation is disabled, an unknown verified identity is queued for administrator review. An administrator can approve it as a new user, link it to an existing user, reject it, or reopen a rejected request.

Automatically created OIDC users do not receive a local password. An administrator can add one for `/auth/local`; see [Local authentication](local.md#accounts-and-local-credentials).

## Disabled accounts and sessions

Disabling an account under **Administration → Users** revokes its local and OIDC browser sessions and blocks local login, OIDC login, trusted-proxy authentication, and personal access tokens. Re-enabling the account requires the user to authenticate again.

## Provider configuration

Register the exact callback URL `<KUMBUKA__PUBLIC_URL>/auth/callback` with the provider. The client must support authorization-code login with S256 PKCE and return `preferred_username` in the ID token.

Provider discovery must succeed when Kumbuka starts with OIDC enabled. Preserve the issuer URL, client configuration, database, and deployment secrets across restarts.
