# Administration

## Editor toolbar

Open **Administration → Editor toolbar** to customize plugin contributions globally. Each row shows the contribution and plugin, its current semantic group, visibility, and numeric order. Only groups allowed by the plugin are offered. Numeric ordering controls provide an accessible alternative to drag and drop, and **Reset** restores the plugin's manifest defaults.

![Editor toolbar administration with plugin contributions and ordering controls](../assets/screenshots/admin-editor-toolbar.png)

Overrides use stable plugin and contribution IDs, so they survive plugin upgrades. Disabled, removed, or renamed contributions are ignored without breaking the editor; an override is retained so it can apply again if the same stable contribution returns.

The administration area is available only to `admin` users. It covers application configuration, branding, plugins, users, groups, page inventory, navigation icons, reusable content, tags, tokens, imports/exports, media cleanup, documentation health, audit history, and the recycle bin.

{{subpages}}
