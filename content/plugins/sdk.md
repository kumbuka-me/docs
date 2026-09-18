# Plugin SDK

The public Go module is:

```text
github.com/kumbuka-me/sdk
```

Most executable plugins need only the root package. It provides module registration, render request/result types, helper constructors, and typed capability clients.

## Root SDK

The root package exposes helpers such as:

- `RegisterModule` for a declared executable module;
- `RegisterMacro` for typed macro parse/render handlers;
- `RegisterWidget` for typed widget render handlers;
- `RegisterWidgetWithCommands` when a widget also needs host-mediated state-changing commands;
- `RegisterExporter` for typed page export handlers;
- `Text`, `Markdown`, and `Failure` for render results;
- `Pages`, `Drafts`, `Settings`, `Resources`, `Storage`, `Attachments`, `HTTP`, `Icon`, and `Log` for host capabilities;
- public wire and page/storage/attachment types used by plugin code.

The host still sanitizes resulting HTML and enforces manifest permissions. SDK helpers do not bypass runtime policy.

`RegisterWidgetWithCommands` keeps mutation routing in Kumbuka. A rendered widget returns an action with `kind: command`; when selected, the host invokes the registered command handler with the validated surface, optional current page, action ID, and current plugin features. The command may return only a safe local redirect.

`RegisterExporter` receives an `ExportContext` containing public current-page metadata, stored Markdown source, and current features. It returns an `ExportFile`; Kumbuka validates the filename, media type, and bounded payload before serving it.

## Settings and resources

`Settings()` reads and writes the plugin's own simple settings namespace. A manifest can additionally declare administrator-managed typed singleton settings. Those fields are read through the same client with keys in `<module>.<field>` form. Kumbuka returns the manifest default until an administrator saves an explicit value, decrypts declared secret values for the owning plugin, and rejects guest writes to manifest-declared settings.

Use `Resources()` for repeatable `admin-resource` records such as repository connections, endpoints, or reusable named values. Resource schemas use host-rendered typed fields, and secret values are decrypted only for the owning plugin. Both typed settings and resources require `settings:read` when executable plugin code reads them.

## Outbound HTTP

`HTTP().Do` lets a plugin define a bounded HTTP(S) request while Kumbuka performs the network I/O. The plugin owns provider-specific URLs, headers, authentication, response parsing, and protocol behavior; the host owns generic limits, destination validation, redirects, TLS policy, proxy handling, and request deadlines.

The base client requires `network:http`. Requests that explicitly permit exact private addresses additionally require `network:private`, and disabling origin certificate verification additionally requires `network:insecure-tls`. See [Capabilities](capabilities.md#outbound-http) for the host security model.

## Markdown helpers

`github.com/kumbuka-me/sdk/markdown` contains small reusable Markdown parsing helpers for plugins:

- `Fence` recognizes opening backtick or tilde fences;
- `Closes` checks whether a line closes a known fence;
- `AppendFence` copies a complete fenced block without interpreting its body.

Plugin-specific syntax belongs in the plugin itself rather than this helper package.

## Package validation

`github.com/kumbuka-me/sdk/pluginpackage` exposes the public manifest and package-validation contract used by tooling and the Kumbuka host. `ParseManifest` strictly validates one manifest and `Read` validates a complete `.kumbukaplugin` archive.

See [Package format](package-format.md) for the archive layout and limits.
