# OIDC

OIDC mode uses authorization-code login with provider discovery, S256 PKCE, and an ID-token nonce check. Kumbuka binds an account to the verified `(issuer, subject)` pair; usernames, email addresses, and display names are profile attributes rather than account ownership keys.

## Required deployment secrets

Set:

```text
KUMBUKA__OIDC_CLIENT_SECRET
KUMBUKA__OIDC_SESSION_SECRET
```

Copy `KUMBUKA__OIDC_CLIENT_SECRET` from the Kumbuka client configuration in your identity provider.

Generate a separate session secret once during initial setup:

```sh
openssl rand -base64 32
```

Save the complete output as `KUMBUKA__OIDC_SESSION_SECRET` in your deployment's secret store. This command produces 44 characters, satisfying the minimum of 32 characters. For Kubernetes, paste it directly into the `stringData.KUMBUKA__OIDC_SESSION_SECRET` field of Secret `kumbuka-oidc`.

Use a different value from `KUMBUKA__ENCRYPTION_KEY`, even though the same command works for both. See [Generate deployment secrets](../configuration/runtime.md#generate-deployment-secrets) for shell and Kubernetes examples. The client secret and OIDC session secret are not stored in PostgreSQL.

OIDC browser sessions remain valid across Kumbuka restarts and version updates until they expire, provided `KUMBUKA__OIDC_SESSION_SECRET` and the PostgreSQL database are preserved. Sessions last 12 hours. Explicit session revocation and account disabling still invalidate existing sessions. Changing the session secret invalidates all OIDC sessions and pending logins; keep the same secret on every replica. Login attempts expire after 10 minutes and can complete after a restart with the same configuration. Upgrading from a version without PKCE requires restarting any pending login, but does not invalidate established sessions.

Normally the issuer, client ID, optional group claim, administrator group, and group mappings are managed as non-secret application settings. While `KUMBUKA__AUTH_MODE=oidc` is active, the runtime issuer and client ID are deployment-managed and read-only in the administration UI; group claim, administrator group, and group mappings remain database-managed.

## External administrator group

Set **Group claim** to the top-level ID-token claim that contains memberships, then set **Administrator group** to the exact value that should grant Kumbuka administrator access. The claim may be one string or an array of strings. Matching is exact after surrounding whitespace is removed.

Kumbuka evaluates the administrator group during a successful OIDC login and stores the observed result. Membership grants effective administrator access for that OIDC session, but it does not overwrite the account's manually assigned Kumbuka role. A manually assigned administrator therefore remains an administrator after leaving the external group. The user administration page warns when Kumbuka last observed that mismatch so an administrator can deliberately keep or remove the manual role.

Removing a user from the identity-provider group affects new logins. Use **Sign out** in **Administration → Users** to invalidate that user's existing local and OIDC browser sessions immediately.

The identity provider must include the configured claim in the ID token. For Keycloak, add a group-membership or role mapper to the Kumbuka client/client scope and emit its value under the same claim name configured in Kumbuka. No Kumbuka collaboration-group mapping is required solely for administrator elevation.

## Group synchronization

Kumbuka can read a configurable top-level group claim as either a string or string array. Administrators explicitly map external group values to Kumbuka groups. An optional authoritative mode removes mapped Kumbuka memberships when those external values disappear from the current claim.

## Unknown identities

When automatic user creation is disabled, a verified unknown identity is recorded for administrator review. An administrator can approve it as a new user, link it to an existing Kumbuka user, reject it, or reopen a rejected request.

The callback verifies issuer and subject before establishing the Kumbuka session.

Automatically created OIDC accounts do not receive a local password. An administrator may explicitly grant one for `/auth/local`; see [Local authentication](local.md#accounts-and-local-credentials).

## Disabled accounts and sessions

Disabling an account in **Administration → Users** revokes its local and OIDC browser sessions and blocks local login, OIDC login, trusted-proxy authentication, and personal API tokens. Re-enabling it does not restore old sessions; the user must authenticate again.

## Provider and restart requirements

Register the exact callback URL `<KUMBUKA__PUBLIC_URL>/auth/callback` with the provider. The client must support authorization-code login with S256 PKCE and return `preferred_username` in the ID token. Kumbuka requires provider discovery to succeed at startup when OIDC is active, so an unavailable provider can prevent startup even when existing session cookies are valid. Preserve the issuer URL, database, client configuration, and deployment secrets when restarting. Kumbuka sessions do not require an in-memory provider token or a refresh token.
