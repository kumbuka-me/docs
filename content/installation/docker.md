# Docker

The included Compose file starts Kumbuka, PostgreSQL 18, and the optional `html2pdf` renderer.

```sh
docker compose -f deploy/compose.yaml up -d
```

The development stack publishes Kumbuka on `127.0.0.1:8080`, the HTML-to-PDF service on `127.0.0.1:8081`, and PostgreSQL on `127.0.0.1:5432`. The Kumbuka service receives a PostgreSQL URL through `KUMBUKA__DATABASE_URL` and uses `KUMBUKA__PUBLIC_URL=http://localhost:8080`.

## Container image

The production image is multi-stage. A Node build stage compiles the TypeScript frontend, a Go build stage embeds the generated web assets into the Kumbuka binary, and the final distroless image contains only the application and its writable runtime directories. PDF rendering stays in the separate `html2pdf` container. Node.js and npm are build dependencies only and are not present in the Kumbuka runtime image.

## Persistent data

PostgreSQL owns the persistent Kumbuka data. The Compose deployment uses the `kumbuka-postgres` volume. Kumbuka itself does not require an application data volume for pages or uploads because those are stored in PostgreSQL.

See [Runtime configuration](../configuration/runtime.md) for environment variables.
