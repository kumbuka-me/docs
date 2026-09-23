# Development

This page is for contributors working on the Kumbuka server repository. Related components live in sibling repositories rather than subdirectories of the server checkout.

- [Architecture](architecture.md) documents server package boundaries and dependency direction.
- [Plugin development](plugins/index.md) covers the SDK, manifests, capabilities, package format, and WASI contract.

## Repositories

- `kumbuka-me/kumbuka` owns the server, web application, PostgreSQL adapter, plugin host/runtime, and reusable `pkg/` packages.
- `kumbuka-me/sdk` owns the plugin package schema, WASI guest API, capability clients, and `kumbuka-plugin` tooling.
- `kumbuka-me/cli` owns static sites, Git-friendly mirrors, and `.kumbukaplugins` project tooling.
- `kumbuka-me/plugins` owns first-party plugin source, packages, previews, and the release catalog.
- `kumbuka-me/docs` owns user, administrator, contributor, and cross-repository documentation plus application screenshots.

Each repository has its own module, CI, release history, and dependency updates. Use a local Go workspace when testing compatible unreleased Go changes across sibling checkouts instead of committing `replace` directives to shared modules.

## Common commands

```sh
make download
make run
make test
make test-race
make lint
make fmt
make build
```

`make run` builds the application, starts the local dependencies, and opens Kumbuka in the browser. `web/dist` is generated and is not committed.

## Local services and ports

Local development uses separate ports for Kumbuka, PostgreSQL, and the PDF service. Port assignments are saved per checkout so the same project keeps using the same local addresses.

Useful targets include:

```sh
make dev-build
make postgres
make html-pdf
make serve
make open
make ports
make ports-reset
```

You can set fixed ports when needed:

```sh
make ports \
  KUMBUKA_ASSIGNED_PORT=8080 \
  DB_ASSIGNED_PORT=5433 \
  PDF_ASSIGNED_PORT=8081
```

Stop the local services before resetting saved ports.

## Frontend

Authored browser code lives under `web/src/ts`, with TypeScript tests under `test/ts`. CSS lives under `web/src/css`. The build emits browser assets into `web/dist`.

Node.js, npm, and TypeScript are build-time dependencies; they are not needed by the running Kumbuka server.

## Backend

Go code is formatted with `gofmt`. PostgreSQL queries, migrations, and `pgx` usage live under `internal/postgres`. See [Architecture](architecture.md) for the package boundaries used by the server.

`internal/app` is intentionally small: `run.go` is the process composition root. HTTP construction and route registration live under `internal/http/server`, application use cases under `internal/application`, and plugin/Markdown runtime construction under `internal/pluginruntime`.

Run the normal test suite with `make test` and the race-enabled suite with `make test-race`.

PostgreSQL integration tests require a disposable database. Set `KUMBUKA_TEST_DATABASE_URL` and run the relevant PostgreSQL adapter tests, for example:

```sh
KUMBUKA_TEST_DATABASE_URL='postgres://...' go test -race ./internal/postgres
```

Each integration test creates and removes its own schema. Use a development or test database whose account can create schemas. Without that environment variable, database integration tests are skipped.

Build browser assets before running backend commands directly: the Go server embeds `web/dist`. Do not rebuild those assets concurrently with a Go build or test, because the frontend build replaces that directory.

## Review conventions

Document every non-test function with at least one line explaining its purpose. Document each production struct and field, including local response structs, with meaning, units, ownership, or invariants that help a reader. Preserve comments in generators when generated declarations need documentation.

Group function bodies by validation, preparation, execution, and result handling where those phases apply. Extract complicated conditions into helpers named for the rule they enforce. Keep straightforward checks inline and avoid helpers that merely hide an expression.

Keep dependency direction visible during review: HTTP may depend on application and presentation packages, application use cases should depend on narrow capabilities rather than concrete adapters, PostgreSQL owns SQL/`pgx`, and webview remains passive. Prefer behavioral regression tests for important contracts such as authorization and bounded database access rather than tests that enforce source-tree shape.

For cross-repository work, publish shared contracts before their consumers. An SDK change is released first; the server, CLI, and affected plugins then adopt that released SDK version as needed. Server and CLI releases are independent, and first-party plugins are versioned and released independently from one another. Update the documentation repository after the behavior and package versions it describes are available. Use focused commits and run each repository's formatting, tests, vet/lint, and build targets before release.

## Development tools

The Makefile downloads pinned shared development helpers and project-specific tools as needed. Use the Make targets rather than invoking downloaded helper binaries directly.

## Documentation

User-facing documentation is maintained in the separate [kumbuka-me/docs](https://github.com/kumbuka-me/docs) repository.
