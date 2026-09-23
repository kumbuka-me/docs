# Runtime configuration

The Kumbuka server accepts command-line flags and matching `KUMBUKA__` environment variables. A database URL is required when starting the server. Static-site builds, mirrors, and plugin-project commands use the separate `kumbuka-cli` binary.

| Flag                             | Environment                             | Purpose                                                                                          |
| -------------------------------- | --------------------------------------- | ------------------------------------------------------------------------------------------------ |
| `--listen-address`               | `KUMBUKA__LISTEN_ADDRESS`               | HTTP listen address; defaults to `127.0.0.1:8080`.                                               |
| `--database-url`                 | `KUMBUKA__DATABASE_URL`                 | PostgreSQL connection URL.                                                                       |
| `--public-url`                   | `KUMBUKA__PUBLIC_URL`                   | Externally visible base URL; defaults to `http://localhost:8080`.                                |
| `--pdf-url`                      | `KUMBUKA__PDF_URL`                      | Optional deployment override for the HTML-to-PDF endpoint.                                       |
| `--plugin-update-check-interval` | `KUMBUKA__PLUGIN_UPDATE_CHECK_INTERVAL` | First-party plugin update-check interval; defaults to `15m`, or `0` to disable scheduled checks. |
| `--allow-user-registration`      | `KUMBUKA__ALLOW_USER_REGISTRATION`      | Override whether unknown OIDC or trusted-proxy identities may create accounts.                   |
| `--read-only`                    | `KUMBUKA__READ_ONLY`                    | Block state-changing application requests while preserving reads and authentication.             |
| `--local-login`                  | `KUMBUKA__LOCAL_LOGIN`                  | Expose local recovery login alongside another authentication mode.                               |
| `--theme-directory`              | `KUMBUKA__THEME_DIRECTORY`              | Optional directory containing additional TOML themes.                                            |
| `--auth-mode`                    | `KUMBUKA__AUTH_MODE`                    | Deployment override for browser authentication mode.                                             |
| `--trusted-username-headers`     | `KUMBUKA__TRUSTED_USERNAME_HEADERS`     | Trusted-proxy username header list used with the authentication override.                        |
| `--trusted-email-headers`        | `KUMBUKA__TRUSTED_EMAIL_HEADERS`        | Trusted-proxy email header list used with the authentication override.                           |
| `--trusted-display-name-headers` | `KUMBUKA__TRUSTED_DISPLAY_NAME_HEADERS` | Trusted-proxy display-name header list used with the authentication override.                    |
| `--trusted-group-headers`        | `KUMBUKA__TRUSTED_GROUP_HEADERS`        | Trusted-proxy group header list used with the authentication override.                           |
| `--trusted-admin-group`          | `KUMBUKA__TRUSTED_ADMIN_GROUP`          | Trusted-proxy group value that grants administrator access.                                      |
| `--oidc-issuer`                  | `KUMBUKA__OIDC_ISSUER`                  | OIDC issuer used with a deployment-managed OIDC configuration.                                   |
| `--oidc-client-id`               | `KUMBUKA__OIDC_CLIENT_ID`               | OIDC client ID used with a deployment-managed OIDC configuration.                                |
| `--oidc-group-claim`             | `KUMBUKA__OIDC_GROUP_CLAIM`             | OIDC group-membership claim used with the authentication override; defaults to `groups`.         |
| `--oidc-admin-group`             | `KUMBUKA__OIDC_ADMIN_GROUP`             | OIDC group value that grants administrator access.                                               |
| `--oidc-client-secret`           | `KUMBUKA__OIDC_CLIENT_SECRET`           | OIDC client secret.                                                                              |
| `--oidc-session-secret`          | `KUMBUKA__OIDC_SESSION_SECRET`          | Secret used for OIDC browser sessions; must be at least 32 characters when set.                  |
| `--encryption-key`               | `KUMBUKA__ENCRYPTION_KEY`               | Base64-encoded 32-byte key used to encrypt sensitive application settings.                       |
| `--log-format`                   | `KUMBUKA__LOG_FORMAT`                   | `json` or `text`.                                                                                |
| `--debug`                        | `KUMBUKA__DEBUG`                        | Enable verbose diagnostics.                                                                      |
| `--debug-render-timings`         | `KUMBUKA__DEBUG_RENDER_TIMINGS`         | Log detailed page-render timing information for temporary performance diagnosis.                 |
| `--access-log`                   | `KUMBUKA__ACCESS_LOG`                   | Enable HTTP access logging.                                                                      |

## Deployment overrides

`KUMBUKA__AUTH_MODE` is intended for deployment-managed or recovery configuration. When it is set, the effective authentication mode is read-only under **Administration → Configuration**.

With an OIDC override, the runtime issuer, client ID, group claim, and administrator group are also read-only. OIDC group synchronization and mapping settings remain configurable in the application. With a trusted-proxy override, the runtime username, email, display-name, and group header lists and administrator group are read-only.

`KUMBUKA__ALLOW_USER_REGISTRATION` overrides the stored registration setting without changing it. This is a strict Boolean deployment value, so set it explicitly to `true` or `false`.

`KUMBUKA__READ_ONLY=true` blocks requests that change application state while leaving reads and authentication available. Use it for maintenance or replicas that must not accept writes; it does not make PostgreSQL itself read-only.

`KUMBUKA__PDF_URL` similarly overrides the configured PDF endpoint while leaving the application's request-header configuration in use.

Plugin update checks use the configured interval but never install updates automatically. Administrators can always use **Check for updates** under **Administration → Plugins** unless access to the catalog itself is unavailable. See [Plugins](../administration/plugins.md).

`KUMBUKA__DEBUG_RENDER_TIMINGS=true` is intended for short-term troubleshooting. Disable it after profiling to avoid unnecessary diagnostic output.

## Proxy and certificate environment

Plugin catalog downloads and plugin HTTP integrations use the standard process environment variables `HTTP_PROXY`, `HTTPS_PROXY`, and `NO_PROXY`, including lowercase forms. `SSL_CERT_FILE` and `SSL_CERT_DIR` can extend certificate trust for outbound HTTPS connections.

## Generate deployment secrets

Generate the encryption key and OIDC session secret separately:

```sh
export KUMBUKA__ENCRYPTION_KEY="$(openssl rand -base64 32)"
export KUMBUKA__OIDC_SESSION_SECRET="$(openssl rand -base64 32)"
```

Save both values in your deployment's secret store and reuse them across restarts and replicas. Do not generate new values automatically at startup.

| Secret                         | Required format                     |
| ------------------------------ | ----------------------------------- |
| `KUMBUKA__ENCRYPTION_KEY`      | Base64 encoding of exactly 32 bytes |
| `KUMBUKA__OIDC_SESSION_SECRET` | At least 32 characters              |

The `openssl rand -base64 32` command produces a 44-character Base64 string. For the encryption key, use the complete value so it decodes to exactly 32 bytes.

For Kubernetes, place each generated value in `stringData`:

```yaml
# Secret containing the application encryption key
stringData:
  KUMBUKA__ENCRYPTION_KEY: "<generated value>"

# Secret containing the OIDC session secret
stringData:
  KUMBUKA__OIDC_SESSION_SECRET: "<different generated value>"
```

Changing or losing `KUMBUKA__ENCRYPTION_KEY` makes existing encrypted settings unreadable. Changing `KUMBUKA__OIDC_SESSION_SECRET` signs out OIDC users and invalidates pending logins.

`KUMBUKA__OIDC_CLIENT_SECRET` comes from the Kumbuka client configuration in your identity provider.
