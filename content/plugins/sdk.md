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
- `Text`, `Markdown`, and `Failure` for render results;
- `Pages`, `Settings`, `Storage`, `Attachments`, `Icon`, and `Log` for host capabilities;
- public wire and page/storage/attachment types used by plugin code.

The host still sanitizes resulting HTML and enforces manifest permissions. SDK helpers do not bypass runtime policy.

## Markdown helpers

`github.com/kumbuka-me/sdk/markdown` contains small reusable Markdown parsing helpers for plugins:

- `Fence` recognizes opening backtick or tilde fences;
- `Closes` checks whether a line closes a known fence;
- `AppendFence` copies a complete fenced block without interpreting its body.

Plugin-specific syntax belongs in the plugin itself rather than this helper package.

## Package validation

`github.com/kumbuka-me/sdk/pluginpackage` exposes the public manifest and package-validation contract used by tooling and the Kumbuka host. `ParseManifest` strictly validates one manifest and `Read` validates a complete `.kumbukaplugin` archive.

See [Package format](package-format.md) for the archive layout and limits.
