# External Files

The **External Files** plugin embeds whole text files or selected line ranges from GitHub and GitLab repositories, including self-hosted instances. Retrieved content is displayed as text and is never executed or interpreted as Markdown.

The plugin is disabled by default. Configure it under **Administration → Plugin settings → External Files**.

## Configure a source

1. Configure `KUMBUKA__ENCRYPTION_KEY` before storing repository credentials.
2. Install and enable **External Files**.
3. Open **Administration → Plugin settings → External Files**.
4. Add a source with a unique name, provider, API endpoint, repository, and explicit branch, tag, or commit.
5. Choose the cache TTL. The default is **1 hour**.
6. For a private repository, use a dedicated read-only token restricted to that repository.
7. For an internal provider, configure the exact private addresses its hostname may resolve to.

Common API endpoints are:

- GitHub.com: `https://api.github.com`
- GitHub Enterprise: `https://git.example.com/api/v3`
- GitLab.com: `https://gitlab.com/api/v4`
- self-hosted GitLab: `https://git.example.com/api/v4`

GitHub repositories use `owner/repository`. GitLab repositories may contain nested group paths. Use a commit SHA when embedded content and annotations must remain pinned to an exact revision.

**Skip TLS certificate verification** is off by default. Prefer a trusted CA configured with `SSL_CERT_FILE` or `SSL_CERT_DIR`.

## Embed a file

Place the macro on its own line outside a code fence.

Whole file:

```markdown
{{external-file source="engineering" path="src/main.go"}}
```

Single line:

```markdown
{{external-file source="engineering" path="src/main.go" lines="12"}}
```

Line range with annotations:

```markdown
{{external-file source="engineering" path="src/main.go" lines="10-25" note="12:Initialize the client." note="19:Handle errors before continuing."}}
```

Repeat `note` to annotate multiple lines or add multiple notes to the same line. Annotation line numbers refer to the original file and must fall inside the displayed range.

Annotations are displayed beside the source rather than inserted into the copied text.

## Screenshots

Rendered external file with an annotation:

![Annotated README rendered by the External Files plugin.](/assets/screenshots/plugins/external-files-annotated-readme.png)

Annotation detail:

![Close-up of the External Files annotation list under the rendered source block.](/assets/screenshots/plugins/external-files-annotation-detail.png)

## Presentation

The **Appearance** settings define defaults for External Files embeds:

- **Reference position** — `Right` or `Left`;
- **Reference color** — `Accent`, `Blue`, `Green`, `Yellow`, `Orange`, `Red`, `Purple`, or `Gray`;
- **Highlight referenced lines**;
- **Show line numbers**;
- **Show provider**;
- **Show branch, tag, or commit**.

A single embed can override those defaults:

```markdown
{{external-file source="engineering" path="src/main.go" lines="10-25" note="12:Initialize the client." reference-position="left" reference-color="yellow" highlight-references="false" line-numbers="true" show-provider="true" show-branch="false"}}
```

Boolean overrides accept `true` or `false`.

## Cache behavior

The default cache TTL is **1 hour**. Available values are `5m`, `15m`, `30m`, `1h`, `2h`, `6h`, `12h`, and `24h`.

Files are refreshed when they are next requested after the TTL expires. If a refresh fails and a previously valid copy is available, the plugin continues to show that copy.

Use **Refresh cache** under **Administration → Plugin settings → External Files** to make cached files refresh on their next use. Editing a source also invalidates its cached content. The cache starts empty after a Kumbuka restart or plugin reload.

## Security and networking

Repository tokens are never written into page Markdown or rendered output. Provider endpoints must use HTTPS, and public-share rendering cannot fetch external files.

Private destinations require explicit administrator-configured address exceptions. Loopback, link-local, metadata, and other special-use destinations remain blocked. Binary or unsafe control content is rejected, and Git LFS objects are not expanded.

A configured source grants the plugin access to that repository at the selected revision; it is not a per-reader repository ACL. Use a dedicated repository or token scope when only part of a repository should be exposed through Kumbuka.

## Proxy and CA settings

External Files honors the Kumbuka process environment:

- `HTTPS_PROXY` / `https_proxy`
- `HTTP_PROXY` / `http_proxy`
- `NO_PROXY` / `no_proxy`
- `SSL_CERT_FILE`
- `SSL_CERT_DIR`

A source's **Skip TLS certificate verification** setting applies to the origin connection and does not disable TLS verification for an HTTPS proxy.
