# Getting started

The quickest way to run the full Kumbuka server is Docker Compose. It starts Kumbuka, PostgreSQL, and the separate `html2pdf` service used for PDF export.

## Start the stack

```sh
docker compose -f deploy/compose.yaml up -d
```

Open `http://localhost:8080`.

A fresh database redirects to `/setup`. Create the first local administrator there. Registration begins closed; after setup, configure the long-term authentication mode in **Administration → Configuration**.

## Create your first page

Accounts with the `admin` or `editor` role can create pages. A page has a path, title, Markdown body, optional icon and language, tags, collaboration groups, lifecycle state, ownership/review metadata, and structured properties.

The page path becomes the navigation hierarchy. For example:

```text
operations
operations/postgres
operations/postgres/restore
```

Kumbuka derives the sidebar tree from those paths.

## Next steps

Read [Content](content/index.md) for authoring and [Authentication](authentication/index.md) before exposing Kumbuka beyond a development machine. For a public documentation site that does not need a database or login, use [static site mode](static-sites.md).
