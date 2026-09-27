# Docker

The Kumbuka repository includes a [Docker Compose stack](https://github.com/kumbuka-me/kumbuka/blob/main/deploy/compose.yaml) under `deploy/compose.yaml`. It starts Kumbuka together with PostgreSQL and the supporting `html2pdf` and Mailbridge services.

From a checkout of the server repository:

```sh
git clone https://github.com/kumbuka-me/kumbuka.git
cd kumbuka
docker compose -f deploy/compose.yaml up -d
```

Kumbuka is then available at `http://localhost:8080`.

The reference stack publishes:

- Kumbuka on `127.0.0.1:8080`;
- the HTML-to-PDF service on `127.0.0.1:8081`;
- Mailbridge on `127.0.0.1:8082`;
- PostgreSQL on `127.0.0.1:5432`.

The Compose configuration sets `KUMBUKA__DATABASE_URL`, `KUMBUKA__PUBLIC_URL`, and `KUMBUKA__PDF_URL`. Adjust the deployment before exposing it outside a development machine, especially credentials, the public URL, and any Mailbridge configuration.

## Persistent data

PostgreSQL data is stored in the `kumbuka-postgres` volume. Pages, uploaded images, and attachments are stored through PostgreSQL and do not require a separate Kumbuka data volume.

See [Runtime configuration](../configuration/runtime.md) for the complete environment-variable and flag reference.
