# Plugin capabilities

WASM plugins do not receive Kumbuka Go pointers, database clients, filesystem handles, raw sockets, or process access. Host operations are exposed through a small versioned capability API and are checked against both the plugin manifest and the active runtime/render policy. Plugins can own credentials in manifest-declared secret settings; Kumbuka encrypts those values at rest and returns them only to the owning plugin.

The Go SDK provides typed clients, so plugins normally do not call the low-level transport directly.

## Operations

| Operation               | Manifest permission | Purpose                                                     |
| ----------------------- | ------------------- | ----------------------------------------------------------- |
| `pages.get`             | `pages:read`        | Read authorized public page metadata.                       |
| `pages.search`          | `pages:read`        | Search the authorized page catalog with a bounded limit.    |
| `pages.navigation`      | `pages:read`        | Read the prepared navigation tree for the render target.    |
| `pages.links`           | `pages:read`        | Read authorized backlinks and outgoing wiki-link metadata.  |
| `pages.revisions`       | `pages:read`        | Read bounded revision metadata without stored page bodies.  |
| `pages.recent`          | `pages:read`        | Read the newest authorized pages.                           |
| `pages.popular`         | `pages:read`        | Read the most-viewed authorized pages.                      |
| `pages.recent-viewed`   | `activity:read`     | Read pages recently viewed by the current viewer.           |
| `pages.favorites`       | `activity:read`     | Read pages favorited by the current viewer.                 |
| `pages.recent-edits`    | `activity:read`     | Read pages recently edited by the current viewer.           |
| `drafts.list`           | `drafts:read`       | Read bounded private draft metadata for the current viewer. |
| `pages.content`         | `pages:content`     | Read authorized Markdown source.                            |
| `attachments.read`      | `attachments:read`  | Read a bounded authorized attachment byte range.            |
| `plugin.settings.read`  | `settings:read`     | Read this plugin's simple settings namespace.               |
| `plugin.settings.write` | `settings:write`    | Write this plugin's simple settings namespace.              |
| `plugin.resources.get`  | `settings:read`     | Read one manifest-declared structured setting record.       |
| `plugin.resources.list` | `settings:read`     | List one manifest-declared structured setting collection.   |
| `plugin.storage.read`   | `storage:read`      | Read this plugin's opaque data namespace.                   |
| `plugin.storage.write`  | `storage:write`     | Write this plugin's opaque data namespace.                  |
| `http.do`               | `network:http`      | Perform one bounded host-mediated HTTP(S) request.          |
| `icons.render`          | none                | Render an icon from the active host icon catalog.           |
| `log`                   | none                | Write a bounded plugin log message.                         |

A permission must be declared by the package and granted by Kumbuka's runtime policy. An undeclared call is denied even if another plugin is allowed to use that capability. Missing grants prevent the plugin from loading in that scope.

`icons.render` and `log` are explicitly public host operations and therefore need no manifest permission. Unknown methods are rejected rather than treated as unprivileged calls.

## Request scope

Page operations use the current viewer's authorized catalog rather than unrestricted persistence. Link, revision, recent-page, popularity, and search results therefore stay inside the same page-access boundary as the surrounding render.

Viewer-specific activity operations (`pages.recent-viewed`, `pages.favorites`, `pages.recent-edits`, and `drafts.list`) are available only when the current request supplies that viewer context. Public-share rendering is restricted to the shared page. Static builds can provide prepared navigation without exposing database-backed catalog, activity, draft, or persistent-storage capabilities.

Attachment reads are available only when the current render scope explicitly supplies an authorized range reader. Missing context capabilities return an error.

## Plugin-owned storage

Settings and data are separate namespaces owned by the executing plugin. Keys are 1–256 bytes and values are at most 64 KiB. PostgreSQL-backed storage enforces up to 1,024 keys and 16 MiB per plugin across both namespaces. Reads distinguish an absent value from an empty value.

Plugin data survives renderer/runtime restarts and disabling a plugin does not delete it. Structured `admin-resource` records are stored in the owning plugin's namespace. Fields declared as `secret` are encrypted with `KUMBUKA__ENCRYPTION_KEY`, masked in administration, and decrypted when the owning plugin reads the record through `Resources()`.

## Outbound HTTP

`HTTP().Do` lets an executable plugin define an HTTP(S) request while Kumbuka performs the network I/O. Core understands generic HTTP method, URL, headers, body, TLS policy, and destination policy; provider-specific endpoints, authentication headers, response formats, and setting names stay in the plugin.

The base operation requires `network:http`. A request that supplies exact RFC1918 or IPv6 ULA destination exceptions additionally requires `network:private`. Setting `InsecureSkipVerify` additionally requires `network:insecure-tls`. These permissions must be present both in the package manifest and Kumbuka's runtime policy.

The host applies bounded request and response bodies, bounded headers, an HTTP(S)-only URL policy, no redirects, timeouts, DNS validation with numeric-address pinning, and SSRF filtering. Private destinations are denied unless the plugin supplies an exact permitted private address and has `network:private`; loopback, link-local, shared-address space, metadata, documentation, and other special-use destinations remain blocked. The generic client honors Kumbuka's process `HTTP_PROXY`, `HTTPS_PROXY`, `NO_PROXY`, `SSL_CERT_FILE`, and `SSL_CERT_DIR` environment settings.

The server enables outbound plugin HTTP only for authenticated invocation contexts. Public-share rendering cannot use it. Static builds do not grant network permissions.

## Limits

Host calls during plugin initialization are denied. One invocation can make at most 512 host calls and those calls share the invocation deadline. Plugin identity is never supplied by guest input; Kumbuka derives it from the executing plugin instance.

See [Wire protocol](wire-protocol.md) for the low-level `kumbuka_v1.call` ABI.
