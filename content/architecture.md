# Architecture

This page is a contributor reference for the Kumbuka server codebase. It is not required for installing or administering Kumbuka.

Kumbuka runs as a single Go server backed by PostgreSQL. A separate `kumbuka-cli` binary provides static-site builds, Git-friendly mirrors, and plugin-project tooling.

A normal server request follows this path:

```text
HTTP → routes/middleware → handler → service → store → PostgreSQL
                         ↘ webview
```

## Main packages

- `cmd/kumbuka` starts the server.
- `internal/app` creates the server dependencies and router.
- `internal/routes` registers HTTP routes and their authentication requirements.
- `internal/handler` parses requests and coordinates application operations.
- `internal/webview` prepares and renders server-side HTML views.
- `internal/service` contains application use cases and mutation rules.
- `internal/auth` and `internal/middleware` provide authentication and HTTP middleware.
- `internal/store` contains PostgreSQL persistence and migrations.
- other packages under `pkg/` provide reusable runtime features such as Markdown rendering, navigation, plugins, revisions, icons, logging, and themes.
- `web` contains the browser assets used by the server.

The standalone CLI reuses public packages from the server repository but has its own command and project-specific code in `github.com/kumbuka-me/cli`.

## Dependency boundaries

Handlers can call services and web views but do not access the concrete store directly. `internal/webview` does not depend on handlers, and services do not depend on HTTP or presentation packages. SQL and `pgx` code stay in `internal/store`.

Services declare the small repository interfaces they need, while handlers declare the service interfaces they consume. `internal/app` supplies concrete implementations. Shared page models and typed application errors belong in `pkg/domain`; handlers translate those errors into HTTP responses. A failed audit or notification after a successful mutation is logged without reporting the mutation itself as failed.

`internal/portable` validates portable archive structure and metadata before restoration begins. The import handler coordinates uploaded resources and group mapping; the page service applies page mutations. Validation happens before writes, but restoration is not a single transaction across resources, groups, and pages.

## Core and plugins

Core provides pages, persistence, authentication and authorization, revisions, drafts, search, routing, sanitization, plugin lifecycle, and generic extension APIs.

Plugins add optional rendering, editor, administration, and presentation features. Executable plugins access host functionality only through the capabilities declared by their package and allowed by the current runtime context. See [Plugin development](plugins/index.md) for the extension model.

The SDK owns the versioned package schema, guest ABI, and typed capability clients. The host owns authorization, execution limits, sanitization, and plugin lifecycle. Provider-specific protocols and rendering syntax stay in plugins: for example, External Files constructs GitHub and GitLab requests while core enforces the generic outbound HTTP policy.

Validated SDK packages are cached by archive digest. Their accessors return independent copies, including nested configuration option lists. Keep that ownership contract when adding fields so callers cannot change another render's cached package.
