# Architecture

Kumbuka is a layered Go monolith. It runs as one process with one PostgreSQL database, while package dependencies point inward so HTTP and persistence details stay out of application behavior.

The normal request path is:

```text
HTTP -> routes/middleware -> handler -> service -> repository contract -> store -> PostgreSQL
                              |          |                                |
                              |          +------------> domain <----------+
                              |
                              +-> webview -> narrow read-only contracts
```

## Main layers

- `cmd/kumbuka` is the minimal server process entry point. `kumbuka` starts the server directly; there is no server subcommand.
- `internal/app` owns server startup orchestration and is the composition root. It loads assets, opens PostgreSQL, constructs services/authentication/views, and builds the router.
- `internal/routes` registers routes and applies authentication/role policies to already-constructed dependencies.
- `internal/handler`, `internal/middleware`, and `internal/auth` are inbound HTTP adapters. Handlers parse transport input, coordinate use cases, translate expected failures into HTTP responses, and choose redirects or rendered views.
- `internal/webview` owns server-side HTML presentation: shared template data, view-only models, theme/plugin presentation metadata, common authenticated/public view-data loading, and template rendering. It consumes narrow read-only capabilities and does not own application mutation policy.
- `internal/service` owns application use cases and mutation policy.
- reusable runtime packages under `pkg/` contain domain records, PostgreSQL storage, Markdown rendering, navigation, plugin/runtime support, revisions, icons, logging, and themes. These packages are intentionally consumable by the standalone CLI.
- server-only HTTP, authentication, routing, and application composition remain under `internal/`.
- `web` contains the server browser assets.
- the separate `github.com/kumbuka-me/cli` repository owns its CLI command tree plus `internal/site`, `internal/mirror`, and `internal/pluginproject`.

## Boundaries

Handlers do not import the concrete store. They coordinate service contracts and `internal/webview`; presentation code does not live in the handler package. `internal/webview` must not depend back on `internal/handler`, and services must not depend on HTTP or presentation packages. The webview loader may consume narrow read-only capabilities that application services satisfy.

Services and authenticators declare the persistence capabilities they consume. `internal/app` is the composition root where concrete services, view dependencies, authentication, and store implementations are wired for the running server. SQL and `pgx` stay in `pkg/store`.

The static builder and mirror exporter are intentionally outside the server repository's composition path. `kumbuka-cli build` reads files, renders them, and writes static output without opening PostgreSQL; `kumbuka-cli mirror` opens PostgreSQL only to write its deterministic snapshot. Both reuse the public runtime packages under `github.com/kumbuka-me/kumbuka/pkg/...`.

## Core and plugin responsibilities

Kumbuka core owns the platform: page/domain state, persistence, authentication and authorization, revisions, drafts, search, routing, sanitization, the render pipeline, plugin lifecycle, capability enforcement, and generic extension surfaces. Optional product behavior and presentation belong to plugins.

That split deliberately allows core data to outlive a plugin UI. For example, revisions and favorite/activity data remain core domain capabilities while Revision History, Favorites, Recently Viewed, and similar presentation are plugin contributions. Fundamental application operations such as editing, moving, deleting, authentication, and the structural page tree remain core rather than becoming plugins.

Generic core code must not depend on concrete first-party plugin IDs. When a feature needs special handling, the preferred fix is a reusable module contract or capability that can serve unrelated plugins as well. For example, integration plugins own provider URLs, credentials, response formats, and protocol behavior; Kumbuka supplies generic typed settings/resources and a bounded host-mediated HTTP capability rather than provider-specific services.

Plugin authors should use the least powerful extension surface that can implement a feature: prefer declarative modules, use WASM only when server-side behavior is required, and add a browser module only when isolated browser-side execution is necessary. This keeps simple plugins executable-code-free and reduces permission and runtime surface.
