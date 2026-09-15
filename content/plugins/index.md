# Plugins

Kumbuka plugins are versioned `.kumbukaplugin` packages that add rendering, editor, administration, or presentation features without exposing Kumbuka internals to plugin code.

## Install a plugin

1. Download the plugin's `.kumbukaplugin` file.
2. Open **Administration → Plugins**.
3. Upload the package and select **Install and enable**.

See [Plugin administration](../administration/plugins.md) for upgrades, enable/disable behavior, dependencies, and uninstalling plugins.

## Develop plugins

- [Getting started](getting-started.md) — create, test, build, and install a plugin.
- [SDK](sdk.md) — public Go packages and helpers.
- [Manifest and modules](manifest.md) — package metadata and contribution types.
- [Capabilities](capabilities.md) — permission-checked host operations available to WASM plugins.
- [Browser modules](browser-modules.md) — isolated client-side rendering.
- [Package format](package-format.md) — `.kumbukaplugin` archive structure and limits.
- [Wire protocol](wire-protocol.md) — low-level WASI ABI for non-SDK implementations.
