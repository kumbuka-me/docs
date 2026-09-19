# Plugin manifest and modules

Every plugin contains a `plugin.yaml` manifest. Kumbuka strictly decodes one YAML document: unknown fields, unsupported module types, invalid permissions, and incompatible API versions are rejected.

## Manifest

A minimal executable plugin manifest looks like:

```yaml
api_version: 1
provider: Example
id: com.example.greeting
name: Greeting
version: 1.0.0
default_enabled: true
modules:
  - type: macro
    id: greeting
    name: greeting
permissions: []
```

Top-level fields are:

| Field             | Purpose                                                            |
| ----------------- | ------------------------------------------------------------------ |
| `api_version`     | Plugin API version. API v1 currently uses `1`.                     |
| `provider`        | Optional author/provider label. It is metadata, not a trust grant. |
| `id`              | Globally unique plugin identifier.                                 |
| `name`            | Human-readable plugin name.                                        |
| `version`         | Plugin version in `MAJOR.MINOR.PATCH` form.                        |
| `description`     | Optional plugin description.                                       |
| `default_enabled` | Whether the plugin starts enabled by default.                      |
| `requires`        | Plugin IDs that must be enabled first.                             |
| `modules`         | One or more contributions supplied by the package.                 |
| `permissions`     | Host capabilities the package may request.                         |

A manifest can declare up to 32 modules. Plugin and module identifiers are lowercase identifiers using letters, digits, `.`, `_`, and `-` within the public format limits.

## Module types

### `markdown-syntax`

Enables a standard host-provided Markdown grammar. Supported syntax identifiers are `tables`, `strikethrough`, `task-list`, `definition-list`, `footnote`, and `linkify`.

### `renderer-extension`

Runs executable WASM during `preprocess`, `content-preprocess`, or `postprocess`. `content-preprocess` modules can declare a bounded `priority`.

### `macro`

Declares a named macro parsed and rendered by the WASM guest. The optional `capability` field can require one host operation in the active render scope.

### `code-highlighter`

Provides the exclusive fenced-code highlighter. The guest receives the source and language with stage `highlight`. An optional packaged CSS asset is filtered and scoped by Kumbuka.

### `widget`

Runs executable WASM to render a bounded widget on a host-owned surface. Supported surfaces are `home`, `page.details`, `page.after-content`, `page.aside`, and `sidebar`. `width` can be omitted or set to `normal` or `wide`; `order` controls deterministic placement within the surface.

Widget HTML is sanitized by Kumbuka. A widget can also return bounded host-rendered `link` or `dialog` actions with local application URLs, or a `command` action handled through Kumbuka's host-owned POST endpoint. Command actions do not expose arbitrary plugin routes. They may include optional confirmation text and are executed only after the host revalidates the current page context. Widgets cannot return recursive Markdown fragments.

### `page-action`

Adds a declarative action to the current page without requiring WASM. `name`, optional `description` and `icon`, `order`, `kind`, and a bounded local `url` describe the host-rendered control. `kind` can be `link` or `dialog` and defaults to `link`. URL templates may use `${slug}` and `${id}`; Kumbuka expands both with path-safe current-page values.

Use `page-action` for navigation or host dialogs. Fundamental page operations such as edit, move, and delete remain core application actions rather than plugin contributions.

### `exporter`

Runs executable WASM to produce one bounded downloadable file for the current authorized page. The exporter receives public page metadata plus the stored Markdown source and returns a base filename, media type, and file bytes. Kumbuka owns the POST route, page authorization, response headers, and filename/media-type validation.

### `settings`

Declares administrator-managed plugin settings. A settings module has two forms:

- without `fields`, it is a boolean feature toggle; `requires` can reference other modules in the same package;
- with `fields`, it is a typed singleton settings group rendered on the plugin's page under **Administration → Plugin settings**.

Typed settings use the same generic configuration field schema as `admin-resource`: `text`, `textarea`, `url`, `secret`, `boolean`, and `select`. Typed settings groups can contain up to 16 fields and cannot use `key: true` or `requires`.

For example:

```yaml
modules:
  - type: settings
    id: appearance
    name: Appearance
    description: Default presentation for embeds.
    fields:
      - id: reference_position
        name: Reference position
        type: select
        required: true
        default: right
        options:
          - right
          - left
      - id: highlight_referenced_lines
        name: Highlight referenced lines
        type: boolean
        default: "true"
```

An executable plugin with `settings:read` reads a typed setting through `Settings().Get("<module>.<field>")`. When the administrator has not saved an explicit value, the host returns the manifest default. Manifest-declared settings are administrator managed; guest `settings:write` calls cannot overwrite them.

### `content-style`

Adds a packaged stylesheet for rendered page typography. Kumbuka filters selectors, properties, and values before applying it.

### `render-policy`

Declares a bounded semantic rendering-policy marker. Active policies become request-scoped feature flags named `render-policy.<policy>` that other modules can observe; core does not attach feature-specific behavior to individual policy names.

### `browser-module`

Adds isolated browser-side rendering from packaged JavaScript and optional CSS. It requires the `browser:render` permission. See [Browser modules](browser-modules.md).

### `admin-resource`

Declares a bounded host-rendered record schema owned by the plugin. Kumbuka owns forms, generic type validation, authorization, CSRF protection, namespaced persistence, and encryption of `secret` fields. Plugins that declare `settings`, `admin-resource`, or `admin-action` modules appear under **Administration → Plugin settings** rather than placing their configuration in the Plugins lifecycle page.

Each resource has exactly one `text` field marked `key: true`. Other fields use the same configuration field schema as typed `settings`. `required` and `max_bytes` apply generically. `boolean` fields may use `default: "true"` or `"false"`; `select` fields declare an `options` list and may choose one option as `default`. `url` defaults must be absolute HTTP(S) URLs. Secret fields cannot have defaults and are masked in the browser after saving. A configuration group or resource may contain at most 16 fields; a `select` may contain at most 32 unique options.

For example:

```yaml
modules:
  - type: admin-resource
    id: sources
    name: Sources
    fields:
      - id: name
        name: Name
        type: text
        required: true
        key: true
      - id: endpoint
        name: API endpoint
        type: url
        required: true
      - id: token
        name: Access token
        type: secret
      - id: enabled
        name: Enabled
        type: boolean
        default: "true"
      - id: provider
        name: Provider
        type: select
        options: [github, gitlab]
        default: github
```

Executable plugins with `settings:read` can read their own structured records through the SDK `Resources()` client. Secret fields are decrypted only for the owning plugin.

### `admin-action`

Declares one explicit administrator-triggered executable operation. Kumbuka renders the action under **Administration → Plugin settings** and owns authentication, authorization, CSRF handling, and the POST route. The action is disabled while the plugin is disabled; plugins do not receive an arbitrary administration HTTP route.

`name` is required. `description` and `icon` are optional; icons use the normal identifier syntax. The module ID identifies the action dispatched to the guest.

```yaml
modules:
  - type: admin-action
    id: refresh-cache
    name: Refresh cache
    description: Mark all cached files stale.
    icon: refresh-cw-lucide
```

Executable plugins register the matching module ID with `sdk.RegisterAdminAction`. The callback returns an error when the operation fails; successful callbacks return no content because Kumbuka owns the administration UI.

### `content-substitution`

Binds an `admin-resource` to inline `{{prefix:name}}` substitutions. Values are restored immediately before Markdown parsing so inserted content is not recursively reinterpreted as new substitutions.

### `editor-completion`

Exposes an `admin-resource` through a bounded editor-completion trigger and replacement template.

### `editor-insert`

Adds a static insertion action to the editor without loading plugin code into Kumbuka's editor DOM.

### `icon-resource`

Adds a declarative icon set from a packaged JSON asset. Kumbuka validates the resource and emits the SVG wrapper itself; plugin-provided SVG markup is not trusted directly. Icon names join the shared icon catalog and disappear when the owning plugin is disabled or removed.

## Usage selectors

Executable source-aware modules can declare `usage` rules so Kumbuka can avoid invoking a plugin for pages that cannot use it:

```yaml
modules:
  - type: renderer-extension
    id: diagrams
    stage: postprocess
    usage:
      - fence: mermaid
```

Each rule contains exactly one selector:

- `contains` — literal Markdown text;
- `macro` — a standalone macro name;
- `substitution` — an inline substitution prefix;
- `fence` — a fenced-code language, or `*` for any fenced block.

Selectors are performance hints and must not create false negatives. Modules without selectors remain active for all candidate renders. Macro modules can infer their selector from the declared macro name.

Permissions required by executable modules are described in [Capabilities](capabilities.md).
