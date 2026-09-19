# API

Kumbuka exposes a JSON API under `/api`. Requests can use an authenticated browser session or, where supported, a personal access token. Individual endpoints enforce the same role and page-access rules as the application.

Important endpoints include:

| Method           | Path                           | Purpose                                     |
| ---------------- | ------------------------------ | ------------------------------------------- |
| `GET`            | `/api/pages`                   | List recent pages.                          |
| `POST`           | `/api/pages`                   | Create a page (`admin`/`editor`).           |
| `GET`            | `/api/pages/{slug...}`         | Read a page; append `/raw` for Markdown.    |
| `PUT`            | `/api/pages/{slug...}`         | Update a page (`admin`/`editor`).           |
| `DELETE`         | `/api/pages/{slug...}`         | Move a page to the bin (`admin`).           |
| `POST`           | `/api/preview`                 | Render unsaved Markdown (`admin`/`editor`). |
| `GET/PUT/DELETE` | `/api/drafts/{key}`            | Private server drafts (`admin`/`editor`).   |
| `GET`            | `/api/search?q=...`            | Search page summaries.                      |
| `GET`            | `/api/graph`                   | Knowledge graph.                            |
| `GET`            | `/api/tags`                    | Known tags.                                 |
| `GET`            | `/api/groups`                  | Groups assignable by the current user.      |
| `GET`            | `/api/recent`                  | Recently updated pages.                     |
| `GET`            | `/api/images`                  | Image metadata (`admin`/`editor`).          |
| `POST`           | `/api/images`                  | Upload image (`admin`/`editor`).            |
| `GET`            | `/api/attachments`             | Attachment metadata (`admin`/`editor`).     |
| `POST`           | `/api/attachments`             | Upload attachment (`admin`/`editor`).       |
| `GET`            | `/api/notifications`           | Current user notification inbox.            |
| `POST`           | `/api/notifications/{id}/read` | Mark one notification read.                 |
| `POST`           | `/api/notifications/all/read`  | Mark the complete notification inbox read.  |

Errors are returned as JSON problem responses.

See [Personal access tokens](tokens.md) for bearer authentication. Static sites do not expose the Kumbuka API.
