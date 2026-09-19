# Development

This page is for contributors working on the Kumbuka server repository.

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

Go code is formatted with `gofmt`. PostgreSQL queries and migrations live under `pkg/store`. See [Architecture](architecture.md) for the package boundaries used by the server.

Run the normal test suite with `make test` and the race-enabled suite with `make test-race`.

PostgreSQL integration tests require a disposable database. Set `KUMBUKA_TEST_DATABASE_URL` and run the relevant store tests, for example:

```sh
KUMBUKA_TEST_DATABASE_URL='postgres://...' go test -race ./pkg/store
```

Without that environment variable, database integration tests are skipped.

## Development tools

The Makefile downloads pinned shared development helpers and project-specific tools as needed. Use the Make targets rather than invoking downloaded helper binaries directly.

## Documentation

User-facing documentation is maintained in the separate [kumbuka-me/docs](https://github.com/kumbuka-me/docs) repository.
