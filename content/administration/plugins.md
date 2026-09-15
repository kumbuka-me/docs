# Plugins

Open **Administration → Plugins** to manage Kumbuka's bundled and installed plugins. Only administrators can view these pages or change plugin lifecycle state.

The list shows each plugin's name, version, provider, source, and status. Select a plugin to view its packaged documentation, plugin-owned settings, lifecycle controls, requested permissions, dependencies, modules, and technical metadata. Provider names are supplied by package authors; they are not verification badges.

## Install and upgrade

Upload one `.kumbukaplugin` package, up to 16 MiB, and select **Install and enable**. Kumbuka validates the package format, API compatibility, dependencies, and permission policy before publishing its contributions. A package requesting capabilities that the current runtime policy does not grant cannot be installed.

To upgrade, open the plugin and upload a package with the same plugin ID. Kumbuka validates the replacement before switching versions. Enabled plugins stay enabled, disabled plugins stay disabled, and a failed upgrade preserves the current version. Upgrading a bundled plugin creates an installed override through the same package loader and runtime.

## Enable, disable, and uninstall

**Disable plugin** removes its contributions from new renders. Active renders finish using their existing version. Browser module catalogs are embedded when a page is rendered, so already-open pages keep their current browser modules until the user reloads the page.

Dependencies must remain enabled while a dependent plugin is active. System plugins marked required by deployment policy cannot be disabled or removed. Packages cannot declare themselves required.

Installed plugins can be uninstalled from their detail modal. Plugin settings and namespaced data are retained for reinstall. Removing an installed override leaves any bundled copy disabled. Bundled plugins themselves can be disabled; their embedded package remains part of Kumbuka.

Plugin-owned rendering features and settings live in the plugin detail modal. **Administration → Rendering** contains only Kumbuka's built-in rendering behavior.

For package creation and extension APIs, see [Plugin development](../plugins/index.md).
