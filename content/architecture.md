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
- `pkg/store` contains PostgreSQL persistence and migrations.
- other packages under `pkg/` provide reusable runtime features such as Markdown rendering, navigation, plugins, revisions, icons, logging, and themes.
- `web` contains the browser assets used by the server.

The standalone CLI reuses public packages from the server repository but has its own command and project-specific code in `github.com/kumbuka-me/cli`.

## Dependency boundaries

Handlers can call services and web views but do not access the concrete store directly. `internal/webview` does not depend on handlers, and services do not depend on HTTP or presentation packages. SQL and `pgx` code stay in `pkg/store`.

## Core and plugins

Core provides pages, persistence, authentication and authorization, revisions, drafts, search, routing, sanitization, plugin lifecycle, and generic extension APIs.

Plugins add optional rendering, editor, administration, and presentation features. Executable plugins access host functionality only through the capabilities declared by their package and allowed by the current runtime context. See [Plugin development](plugins/index.md) for the extension model.
