# Plugins

Kumbuka plugins are versioned `.kumbukaplugin` packages that add rendering, editor, administration, or presentation features without exposing Kumbuka internals to plugin code.

## Choose the smallest module that works

Plugins do not need Go code merely to be plugins. Prefer a declarative module such as `markdown-syntax`, `editor-insert`, `content-style`, `icon-resource`, `page-action`, or another host-owned contribution when it expresses the feature. Use executable WASM only for behavior that cannot be represented declaratively, and use a `browser-module` only for isolated client-side execution.

This is also a security boundary: declarative packages have no guest code to execute, while executable packages receive only the capabilities declared by their manifest and granted by the host.

## Install and update plugins

1. Download the plugin's `.kumbukaplugin` file.
2. Open **Administration → Plugins**.
3. Upload the package and select **Install and enable**.

First-party releases are also published through `https://kumbuka.me/plugins/catalog.json`. Kumbuka uses that catalog to offer compatible updates directly from the administration page while retaining manual package upload for custom and third-party plugins.

See [Plugin administration](../administration/plugins.md) for updates, manual upgrades, enable/disable behavior, dependencies, and uninstalling plugins.

## Example: External Files

The **External Files** plugin can embed source files or focused line ranges from configured repositories and attach explanatory notes to individual lines.

![Annotated README rendered by the External Files plugin.](/assets/screenshots/plugins/external-files-annotated-readme.png)

See [External Files](external-files.md) for configuration, security, and appearance defaults.

## Develop plugins

- [Getting started](getting-started.md) — create, test, build, and install a plugin.
- [SDK](sdk.md) — public Go packages and helpers.
- [Manifest and modules](manifest.md) — package metadata and contribution types.
- [Capabilities](capabilities.md) — permission-checked host operations available to WASM plugins.
- [Browser modules](browser-modules.md) — isolated client-side rendering.
- [Package format](package-format.md) — `.kumbukaplugin` archive structure and limits.
- [Wire protocol](wire-protocol.md) — low-level WASI ABI for non-SDK implementations.
