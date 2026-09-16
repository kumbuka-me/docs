# Binary

Kumbuka can run as a normal Go binary when PostgreSQL is reachable.

Release archives are available for Linux and macOS on both AMD64 and ARM64.

A development build can be started with:

```sh
make run
```

A release-style local binary can be built with:

```sh
make build
./kumbuka --database-url 'postgres://kumbuka:kumbuka@localhost:5432/kumbuka?sslmode=disable'
```

Run `./kumbuka --help` to see the server runtime flags. Static-site builds, mirrors, and project plugin management are provided by the separate `kumbuka-cli` binary.

## Frontend assets

The Go binary embeds `web/dist`. Run `make web` before compiling manually so TypeScript and CSS are emitted. Normal `make build`, `make run`, and the Docker build already do this.

## PDF support

The Kumbuka binary does not contain a PDF renderer. Configure a compatible HTML-to-PDF `POST` endpoint in **Administration → Configuration**. A deployment can override the persisted endpoint with `KUMBUKA__PDF_URL`. If the service requires a bearer token, API key, or other request header, add it there; mark credentials sensitive and configure `KUMBUKA__ENCRYPTION_KEY` so Kumbuka encrypts them at rest.
