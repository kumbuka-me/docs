# Local authentication

Local authentication uses Kumbuka-managed usernames and passwords. Local credentials can also be added to users who normally sign in through OIDC or a trusted proxy.

## Accounts and local credentials

Accounts created automatically through OIDC or trusted-proxy login do not receive a local password. An administrator can add one under **Administration → Users**. The user can then sign in through `/auth/local` when local login is enabled and can change their own password under **Account → Settings**.

Administrators can also disable an individual local credential while an external authentication mode is active. This blocks local sign-in for that account without disabling its OIDC, trusted-proxy, or personal-token access.

Passwords must contain at least 12 Unicode characters and be no more than 72 UTF-8 bytes. Replacing a local password invalidates the account's previous local sessions. Local browser sessions expire after 12 hours.

The first administrator is created through `/setup` on a fresh database.

## Enable local authentication on an existing installation

To switch an existing installation to local authentication:

1. Open **Administration → Users** and edit an enabled administrator.
2. Use **Set local password** to create a password for that account.
3. Open **Administration → Configuration → Authentication**.
4. Select **Local account** and save.

Kumbuka requires at least one enabled administrator with an enabled local credential before local mode can be selected.

If `KUMBUKA__AUTH_MODE` is set by the deployment, the authentication mode is read-only in the administration UI. Create the administrator's local password first, then change the deployment override to `local` and restart Kumbuka.

For an OIDC or trusted-proxy installation that only needs a recovery login, keep the external mode active and set `KUMBUKA__LOCAL_LOGIN=true` instead.

## Recovery login

`KUMBUKA__LOCAL_LOGIN=true` exposes `/auth/local` alongside another authentication mode. Administrators can set or replace their recovery password from the user administration page.

If all application login paths are unavailable, an operator with PostgreSQL access can re-enable the local credential for an administrator:

```sql
UPDATE local_credentials
SET enabled = true, updated_at = now()
WHERE user_id = (SELECT id FROM users WHERE username = 'admin');
```

The `/auth/local` endpoint must also be enabled through local mode or `KUMBUKA__LOCAL_LOGIN=true`.

If the endpoint is not available, temporarily switch the stored authentication mode to `local` at the same time:

```sql
BEGIN;
UPDATE local_credentials
SET enabled = true, updated_at = now()
WHERE user_id = (SELECT id FROM users WHERE username = 'admin');
UPDATE application_settings
SET auth_mode = 'local', updated_at = now()
WHERE singleton = true;
COMMIT;
```

After signing in, restore the intended authentication mode. A deployment-level `KUMBUKA__AUTH_MODE` override takes precedence over the stored setting.

If the Kumbuka account itself is disabled, re-enable both the account and its local credential:

```sql
BEGIN;
UPDATE users
SET enabled = true
WHERE username = 'admin';
UPDATE local_credentials
SET enabled = true, updated_at = now()
WHERE user_id = (SELECT id FROM users WHERE username = 'admin');
COMMIT;
```
