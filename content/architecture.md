# Architecture

Kumbuka is a layered Go monolith. It runs as one process with one PostgreSQL database, while package dependencies point inward so HTTP and persistence details stay out of application behavior.

The normal request path is:

```text
HTTP -> routes/middleware -> handler -> service -> repository contract -> store -> PostgreSQL
                                      |                                |
                                      +------------> domain <------------+
```

## Main layers

- `cmd/kumbuka` is the minimal server process entry point. `kumbuka` starts the server directly; there is no server subcommand.
- `internal/serve` owns runtime configuration and is the server composition root. It loads assets, opens PostgreSQL, constructs services/authentication/views, and builds the router.
- `internal/routes` registers routes and applies authentication/role policies to already-constructed dependencies.
- `internal/handler`, `internal/middleware`, and `internal/auth` are inbound HTTP adapters.
- `internal/service` owns application use cases and mutation policy.
- reusable runtime packages under `pkg/` contain domain records, PostgreSQL storage, Markdown rendering, navigation, plugin/runtime support, revisions, icons, logging, and themes. These packages are intentionally consumable by the standalone CLI.
- server-only HTTP, authentication, routing, and application composition remain under `internal/`.
- `web` contains the server browser assets.
- the separate `github.com/kumbuka-me/cli` repository owns its CLI command tree plus `internal/site`, `internal/mirror`, and `internal/pluginproject`.

## Boundaries

Handlers do not import the concrete store. Services and authenticators declare the persistence capabilities they consume. `internal/serve` is the place where concrete store implementations satisfy those contracts for the running server. SQL and `pgx` stay in `pkg/store`.

The static builder and mirror exporter are intentionally outside the server repository's composition path. `kumbuka-cli build` reads files, renders them, and writes static output without opening PostgreSQL; `kumbuka-cli mirror` opens PostgreSQL only to write its deterministic snapshot. Both reuse the public runtime packages under `github.com/kumbuka-me/kumbuka/pkg/...`.
