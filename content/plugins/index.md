# Plugins

Kumbuka plugins are versioned `.kumbukaplugin` packages that can add Markdown syntax, rendering, editor actions, administration features, widgets, icons, integrations, and other optional behavior.

## Install and update plugins

1. Download the plugin's `.kumbukaplugin` file.
2. Open **Administration → Plugins**.
3. Upload the package and select **Install and enable**.

First-party plugins can also be updated directly from the administration page when a compatible release is available in the Kumbuka plugin catalog.

See [Plugin administration](../administration/plugins.md) for updates, dependencies, enable/disable behavior, and uninstalling plugins.

## Browse plugins

Explore the [Plugin catalog](catalog.md) for descriptions, previews, permissions, and usage documentation for every first-party plugin.

## Develop plugins

Plugins can be declarative or executable. Use declarative manifest modules where possible; executable server-side behavior uses WASM, while browser modules provide isolated client-side rendering. The public schema, guest ABI, capability clients, and `kumbuka-plugin` tool live in [`kumbuka-me/sdk`](https://github.com/kumbuka-me/sdk); first-party plugin implementations and releases live in [`kumbuka-me/plugins`](https://github.com/kumbuka-me/plugins).

- [Getting started](getting-started.md) — create, test, build, and install a plugin.
- [SDK](sdk.md) — public Go packages and helpers.
- [Manifest and modules](manifest.md) — package metadata and contribution types.
- [Capabilities](capabilities.md) — host operations available to executable plugins.
- [Browser modules](browser-modules.md) — isolated client-side rendering.
- [Package format](package-format.md) — `.kumbukaplugin` archive structure and limits.
- [Wire protocol](wire-protocol.md) — low-level WASI ABI for implementations that do not use the Go SDK.
