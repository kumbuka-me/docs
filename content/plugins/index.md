# Plugins

Kumbuka plugins are versioned `.kumbukaplugin` packages that can add Markdown syntax, rendering, editor actions, administration features, widgets, icons, integrations, and other optional behavior.

## Install and update plugins

1. Download the plugin's `.kumbukaplugin` file.
2. Open **Administration → Plugins**.
3. Upload the package and select **Install and enable**.

First-party plugins can also be updated directly from the administration page when a compatible release is available in the Kumbuka plugin catalog.

See [Plugin administration](../administration/plugins.md) for updates, dependencies, enable/disable behavior, and uninstalling plugins.

## Example: External Files

The **External Files** plugin embeds source files or selected line ranges from configured repositories and can attach notes to individual lines.

![Annotated README rendered by the External Files plugin.](/assets/screenshots/plugins/external-files-annotated-readme.png)

See [External Files](external-files.md) for configuration and usage.

## Develop plugins

Plugins can be declarative or executable. Use declarative manifest modules where possible; executable server-side behavior uses WASM, while browser modules provide isolated client-side rendering.

- [Getting started](getting-started.md) — create, test, build, and install a plugin.
- [SDK](sdk.md) — public Go packages and helpers.
- [Manifest and modules](manifest.md) — package metadata and contribution types.
- [Capabilities](capabilities.md) — host operations available to executable plugins.
- [Browser modules](browser-modules.md) — isolated client-side rendering.
- [Package format](package-format.md) — `.kumbukaplugin` archive structure and limits.
- [Wire protocol](wire-protocol.md) — low-level WASI ABI for implementations that do not use the Go SDK.
