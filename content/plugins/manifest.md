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

### `settings`

Adds host-rendered boolean controls to the plugin detail page. `requires` can reference other modules in the same package; missing dependencies and cycles are rejected.

### `content-style`

Adds a packaged stylesheet for rendered page typography. Kumbuka filters selectors, properties, and values before applying it.

### `render-policy`

Requests a named host rendering behavior from the public allowlist. API v1 includes `coding-ligatures` and `typographer`.

### `browser-module`

Adds isolated browser-side rendering from packaged JavaScript and optional CSS. It requires the `browser:render` permission. See [Browser modules](browser-modules.md).

### `admin-resource`

Declares a bounded host-rendered record schema owned by the plugin. Kumbuka owns forms, validation, authorization, CSRF protection, and namespaced persistence.

### `content-substitution`

Binds an `admin-resource` to inline `{{prefix:name}}` substitutions. Values are restored immediately before Markdown parsing so inserted content is not recursively reinterpreted as new substitutions.

### `editor-completion`

Exposes an `admin-resource` through a bounded editor-completion trigger and replacement template.

### `editor-insert`

Adds a static insertion action to the editor without loading plugin code into Kumbuka's editor DOM.

## Usage selectors

Executable modules can declare `usage` rules so Kumbuka can avoid invoking a plugin for pages that cannot use it:

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
