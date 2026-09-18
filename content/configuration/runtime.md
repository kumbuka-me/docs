# Runtime configuration

The Kumbuka server uses command-line flags and matching `KUMBUKA__` environment variables. The database URL is required when starting `kumbuka`. Static-site and mirror commands belong to the separate `kumbuka-cli` binary.

| Flag                             | Environment                             | Purpose                                                                                                                                                  |
| -------------------------------- | --------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `--listen-address`               | `KUMBUKA__LISTEN_ADDRESS`               | HTTP listen address; defaults to `127.0.0.1:8080`.                                                                                                       |
| `--database-url`                 | `KUMBUKA__DATABASE_URL`                 | PostgreSQL connection URL.                                                                                                                               |
| `--public-url`                   | `KUMBUKA__PUBLIC_URL`                   | Externally visible base URL; defaults to `http://localhost:8080`.                                                                                        |
| `--pdf-url`                      | `KUMBUKA__PDF_URL`                      | Optional runtime override for the configured HTML-to-PDF render endpoint.                                                                                |
| `--plugin-update-check-interval` | `KUMBUKA__PLUGIN_UPDATE_CHECK_INTERVAL` | Checks the first-party plugin catalog on this schedule; defaults to `15m`. Set to `0` to disable scheduled checks while keeping manual checks available. |
| `--local-login`                  | `KUMBUKA__LOCAL_LOGIN`                  | Exposes local recovery login alongside another configured authentication mode.                                                                           |
| `--theme-directory`              | `KUMBUKA__THEME_DIRECTORY`              | Optional directory of TOML theme files that override or extend embedded themes.                                                                          |
| `--auth-mode`                    | `KUMBUKA__AUTH_MODE`                    | Emergency authentication override.                                                                                                                       |
| `--oidc-issuer`                  | `KUMBUKA__OIDC_ISSUER`                  | OIDC issuer used with the runtime override.                                                                                                              |
| `--oidc-client-id`               | `KUMBUKA__OIDC_CLIENT_ID`               | OIDC client ID used with the runtime override.                                                                                                           |
| `--oidc-client-secret`           | `KUMBUKA__OIDC_CLIENT_SECRET`           | OIDC client secret used when OIDC is enabled.                                                                                                            |
| `--oidc-session-secret`          | `KUMBUKA__OIDC_SESSION_SECRET`          | Signs OIDC login state/session cookies; when set it must be at least 32 characters.                                                                      |
| `--encryption-key`               | `KUMBUKA__ENCRYPTION_KEY`               | Base64-encoded 32-byte key used to encrypt sensitive persisted application settings.                                                                     |
| `--log-format`                   | `KUMBUKA__LOG_FORMAT`                   | `json` or `text`.                                                                                                                                        |
| `--debug`                        | `KUMBUKA__DEBUG`                        | Enables verbose diagnostics.                                                                                                                             |
| `--debug-render-timings`         | `KUMBUKA__DEBUG_RENDER_TIMINGS`         | Logs detailed page-handler, Markdown-stage, and WASM-boundary timings for rendered pages.                                                                |
| `--access-log`                   | `KUMBUKA__ACCESS_LOG`                   | Enables HTTP access logging.                                                                                                                             |

Trusted-proxy username, email, and display-name header lists also have deployment flags and environment-variable forms. Their built-in defaults cover common reverse-proxy headers.

Plugin update checks run in the background after Kumbuka has initialized. The updater performs an immediate first check and then refreshes the catalog every `--plugin-update-check-interval`; it never installs a plugin automatically. Administrators can use **Check for updates** on **Administration -> Plugins** to refresh immediately without waiting for the next scheduled check. Set the interval to `0` to disable scheduled checks while retaining that manual refresh action and manual package management.

Successful discovery is compared with the currently loaded plugin versions. Newly discovered compatible releases generate a deduplicated inbox notification for every currently enabled administrator. The same plugin ID and target version are announced only once even after a restart; a newer target version can generate another notification. Failed catalog checks are logged and exposed in plugin administration but do not generate inbox notifications.

Plugin catalog requests and plugin update downloads use Go's standard HTTP proxy handling. Set `HTTPS_PROXY` for the HTTPS catalog and GitHub release downloads, `HTTP_PROXY` for plain HTTP requests, and `NO_PROXY` for hosts that should bypass the proxy. Lowercase forms are also recognized. These are process environment variables, separate from Kumbuka's `KUMBUKA__` configuration namespace. Plugin packages are streamed into bounded memory during verification, so update checks and downloads do not require a writable temporary directory.

Executable plugins that use Kumbuka's generic outbound HTTP capability use the same conventional `HTTP_PROXY`, `HTTPS_PROXY`, and `NO_PROXY` environment. `SSL_CERT_FILE` and `SSL_CERT_DIR` can extend certificate trust for plugin HTTP destinations and HTTPS proxies. Provider URL, token, and per-source TLS choices remain plugin-owned settings rather than Kumbuka runtime flags.

`--debug-render-timings` / `KUMBUKA__DEBUG_RENDER_TIMINGS=true` is intended for short-lived performance diagnosis. It emits one page-handler summary, one Markdown summary per page render, and one record per WASM call. Handler stages cover page lookups, shared view-data loading, Markdown rendering, and template execution; WASM records include guest gate wait, JSON encode/decode, guest allocation/execution, memory copies, and request/response byte counts. It never logs page or plugin payload contents. Disable it again after profiling because the additional timing and log output add overhead. Stage timings are cumulative; nested handler stages such as `view_data` and its individual lookups, plus nested Markdown rendering and annotation passes, can therefore make the sum of individual stages larger than the wall-clock `duration_ms`. Compare `page_handler_timing.duration_ms` with the access log `request_complete` duration to identify time spent before the handler in routing, authentication, or middleware.

The `--auth-mode` value is a recovery override, not the normal place to configure browser authentication. When it is set, the administration UI shows the effective authentication mode as **Managed by deployment** and does not allow the persisted mode to be changed. Remove the runtime setting and restart Kumbuka to manage the mode in the UI again.

Runtime authentication settings override only their corresponding fields. With the OIDC runtime override, `--oidc-issuer` / `KUMBUKA__OIDC_ISSUER` and `--oidc-client-id` / `KUMBUKA__OIDC_CLIENT_ID` are also read-only and marked **Managed by deployment**; OIDC group settings remain database-managed. With the trusted-proxy runtime override, the runtime username, email, and display-name header lists are read-only while group-header and administrator-group settings remain database-managed.

The PDF service is also normally configured in **Administration → Configuration**. `--pdf-url` / `KUMBUKA__PDF_URL` overrides that persisted endpoint for deployments that want to manage the integration entirely outside Kumbuka. Persisted PDF request headers still apply when the endpoint is overridden. Sensitive header values require `KUMBUKA__ENCRYPTION_KEY`; see the generation instructions below. See [Authentication](../authentication/index.md) for authentication setup.

## Generate deployment secrets

Run these commands once when setting up a new deployment. Each command generates a separate random value:

```sh
# Encrypts sensitive settings stored in PostgreSQL.
export KUMBUKA__ENCRYPTION_KEY="$(openssl rand -base64 32)"

# Signs OIDC session cookies; needed when using OIDC.
export KUMBUKA__OIDC_SESSION_SECRET="$(openssl rand -base64 32)"
```

These exports configure Kumbuka when it is started from the same shell. Save the values in your deployment's secret store so they are available after a restart; do not regenerate them in a startup script.

| Secret                         | Required format                     | Generated by the command                                 |
| ------------------------------ | ----------------------------------- | -------------------------------------------------------- |
| `KUMBUKA__ENCRYPTION_KEY`      | Base64 encoding of exactly 32 bytes | A 44-character Base64 string, including the trailing `=` |
| `KUMBUKA__OIDC_SESSION_SECRET` | At least 32 characters              | A 44-character random string                             |

Use the complete generated value. A 32-character string is too short for the encryption key: it must **decode to 32 bytes**.

For Kubernetes, run `openssl rand -base64 32` separately for each secret and paste each output into the corresponding `stringData` field:

```yaml
# In Secret kumbuka-config:
stringData:
  KUMBUKA__ENCRYPTION_KEY: "<paste the first generated value here>"

# In the separate Secret kumbuka-oidc:
stringData:
  KUMBUKA__OIDC_SESSION_SECRET: "<paste the second generated value here>"
```

The placeholders above must be replaced. Under `stringData`, paste the output exactly as generated; Kubernetes handles its own Secret encoding. Preserve any other fields already in these Secrets. For Flux deployments, update the Secret in your configured secret-management source.

Keep each secret consistent across all replicas and restarts:

- Changing or losing the encryption key makes existing encrypted settings unreadable. Restore the original key when recovering an existing deployment.
- Changing the OIDC session secret signs out users and invalidates pending logins.

`KUMBUKA__OIDC_CLIENT_SECRET` comes from your identity provider's Kumbuka client configuration. Copy that value from the provider; the commands above generate Kumbuka's own secrets.
