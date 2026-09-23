# Plugin development

Kumbuka extensions are implemented as versioned plugins. The public plugin contract lives in `kumbuka-me/sdk`, while first-party implementations and releases live in `kumbuka-me/plugins`.

Use declarative manifest modules where possible. Executable server-side behavior runs as WASI, browser modules render inside isolated frames, and Kumbuka remains responsible for authorization, capability enforcement, sanitization, and lifecycle management.

- [Getting started](getting-started.md) — create, test, build, and install a plugin.
- [SDK](sdk.md) — public Go packages and helpers.
- [Manifest and modules](manifest.md) — package metadata and contribution types.
- [Capabilities](capabilities.md) — host operations available to executable plugins.
- [Browser modules](browser-modules.md) — isolated client-side rendering.
- [Package format](package-format.md) — `.kumbukaplugin` archive structure and limits.
- [Wire protocol](wire-protocol.md) — low-level WASI ABI for implementations that do not use the Go SDK.

Browse [Extensions](../../extensions/index.md) for first-party plugin usage documentation. Installation and lifecycle administration are documented under [Administration → Plugins](../../administration/plugins.md).
