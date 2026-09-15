# Plugin capabilities

WASM plugins do not receive Kumbuka Go pointers, database clients, filesystem handles, credentials, or general network/process access. Host operations are exposed through a small versioned capability API and are checked against both the plugin manifest and the active runtime/render policy.

The Go SDK provides typed clients, so plugins normally do not call the low-level transport directly.

## Operations

| Operation               | Manifest permission | Purpose                                                  |
| ----------------------- | ------------------- | -------------------------------------------------------- |
| `pages.get`             | `pages:read`        | Read authorized public page metadata.                    |
| `pages.content`         | `pages:content`     | Read authorized Markdown source.                         |
| `pages.search`          | `pages:read`        | Search the authorized page catalog with a bounded limit. |
| `pages.navigation`      | `pages:read`        | Read the prepared navigation tree for the render target. |
| `attachments.read`      | `attachments:read`  | Read a bounded authorized attachment byte range.         |
| `plugin.settings.read`  | `settings:read`     | Read this plugin's settings namespace.                   |
| `plugin.settings.write` | `settings:write`    | Write this plugin's settings namespace.                  |
| `plugin.storage.read`   | `storage:read`      | Read this plugin's data namespace.                       |
| `plugin.storage.write`  | `storage:write`     | Write this plugin's data namespace.                      |
| `icons.render`          | none                | Render a host-provided icon.                             |
| `log`                   | none                | Write a bounded plugin log message.                      |

A permission must be declared by the package and granted by Kumbuka's runtime policy. An undeclared call is denied even if another plugin is allowed to use that capability. Missing grants prevent the plugin from loading in that scope.

## Request scope

Page operations use the current viewer's authorized catalog rather than unrestricted persistence. Public-share rendering is restricted to the shared page. Static builds can provide prepared navigation without exposing catalog search or persistent storage.

Attachment reads are available only when the current render scope explicitly supplies an authorized range reader. Missing context capabilities return an error.

## Plugin-owned storage

Settings and data are separate namespaces owned by the executing plugin. Keys are 1–256 bytes and values are at most 64 KiB. PostgreSQL-backed storage enforces up to 1,024 keys and 16 MiB per plugin across both namespaces. Reads distinguish an absent value from an empty value.

Plugin data survives renderer/runtime restarts and disabling a plugin does not delete it.

## Limits

Host calls during plugin initialization are denied. One invocation can make at most 512 host calls and those calls share the invocation deadline. Plugin identity is never supplied by guest input; Kumbuka derives it from the executing plugin instance.

See [Wire protocol](wire-protocol.md) for the low-level `kumbuka_v1.call` ABI.
