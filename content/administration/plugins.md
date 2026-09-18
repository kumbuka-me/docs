# Plugins

Open **Administration → Plugins** to manage Kumbuka's bundled and installed plugins. Only administrators can view these pages or change plugin lifecycle state.

The list shows each plugin's name, version, provider, source, status, and whether a newer compatible first-party release is available. Select a plugin to view its packaged documentation, plugin-owned settings, lifecycle controls, requested permissions, dependencies, modules, technical metadata, and update controls. Provider names are supplied by package authors; they are not verification badges.

## Install and update

Upload one `.kumbukaplugin` package, up to 16 MiB, and select **Install and enable**. Kumbuka validates the package format, API compatibility, dependencies, and permission policy before publishing its contributions. A package requesting capabilities that the current runtime policy does not grant cannot be installed.

Kumbuka checks the first-party update catalog at `https://kumbuka.me/plugins/catalog.json` in the background. The first check starts after the application has initialized, and successful or failed checks do not block startup or normal wiki use. The default interval is 15 minutes. Deployments can change it with `--plugin-update-check-interval` / `KUMBUKA__PLUGIN_UPDATE_CHECK_INTERVAL`; setting it to `0` disables scheduled checks but keeps the administrator **Check for updates** action available.

The Plugins page shows the last catalog check state and includes **Check for updates** for an immediate refresh. A manual check bypasses the configured interval, but it only refreshes discovery metadata; it never installs a plugin automatically.

When a successful check discovers a newer compatible release, Kumbuka creates a deduplicated notification for every currently enabled administrator. One catalog refresh may aggregate several newly discovered plugin releases into one notification. The same plugin version is announced only once across restarts, and a later release can generate a new notification. Catalog failures are logged and shown in plugin administration, but they do not create inbox notifications.

When the catalog contains a newer release for the plugin's current API version, the plugin detail view offers an **Update** action. Kumbuka streams the release into a bounded in-memory buffer, enforces the same 16 MiB package limit, verifies the catalog SHA-256 checksum and package identity, and then passes the package through the normal plugin upgrade path.

Catalog requests and plugin package downloads honor Go's standard proxy environment variables: `HTTP_PROXY`, `HTTPS_PROXY`, and `NO_PROXY` (including their lowercase forms). For the HTTPS catalog and GitHub release downloads, configure `HTTPS_PROXY`; use `NO_PROXY` for destinations that should bypass the proxy.

Update downloads do not require a writable temporary directory or plugin volume. Successful installed and upgraded package bytes are stored in PostgreSQL through the plugin installation store, so an update survives container replacement or restart. Bundled packages remain part of the Kumbuka image; an installed newer version is persisted as an override and is selected again during startup.

If a catalog refresh fails, Kumbuka keeps the last successful catalog in memory when one exists. Plugin administration remains usable, **Check for updates** can retry immediately, and manual package upgrades stay available. To upgrade manually, open the plugin and upload a package with the same plugin ID. Enabled plugins stay enabled, disabled plugins stay disabled, and a failed update or upgrade preserves the current version.

## Enable, disable, and uninstall

**Disable plugin** removes its contributions from new renders. Active renders finish using their existing version. Browser module catalogs are embedded when a page is rendered, so already-open pages keep their current browser modules until the user reloads the page.

Dependencies must remain enabled while a dependent plugin is active. System plugins marked required by deployment policy cannot be disabled or removed. Packages cannot declare themselves required.

Installed plugins can be uninstalled from their detail modal. Plugin settings and namespaced data are retained for reinstall. Removing an installed override leaves any bundled copy disabled. Bundled plugins themselves can be disabled; their embedded package remains part of Kumbuka.

Plugin-owned rendering features and settings live in the plugin detail modal. Kumbuka's built-in application presentation defaults remain under **Administration → Configuration**.

Plugin documentation can include packaged screenshots. For example, the External Files plugin README and the documentation site both show a rendered annotated file so administrators can understand the result before enabling the plugin.

For package creation and extension APIs, see [Plugin development](../plugins/index.md).
