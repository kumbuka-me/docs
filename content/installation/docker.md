# Docker

The included Compose file starts Kumbuka, PostgreSQL 18, and the optional `html2pdf` service used for PDF export.

```sh
docker compose -f deploy/compose.yaml up -d
```

The development stack publishes:

- Kumbuka on `127.0.0.1:8080`;
- the HTML-to-PDF service on `127.0.0.1:8081`;
- PostgreSQL on `127.0.0.1:5432`.

Kumbuka is configured with `KUMBUKA__DATABASE_URL` and `KUMBUKA__PUBLIC_URL=http://localhost:8080`.

## Persistent data

The Compose deployment stores Kumbuka data in PostgreSQL using the `kumbuka-postgres` volume. Pages, uploaded images, and attachments do not require a separate Kumbuka data volume.

See [Runtime configuration](../configuration/runtime.md) for environment variables.
