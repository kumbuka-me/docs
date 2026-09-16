# Links, backlinks, and graph

Kumbuka records wiki-link relationships between pages. When the bundled **Wiki Links** plugin is enabled, page details show incoming and outgoing wiki-link relationships. The bundled **Related Pages** plugin separately shows pages related through shared tags. Documentation health reports broken wiki links.

The knowledge graph exposes active pages as nodes and wiki-link relationships as edges. The graph UI can focus on a selected page, while the JSON API exposes graph data for authenticated clients.

Historical page aliases help links continue to resolve after page moves. Documentation health separately reports broken wiki-link targets and orphan pages.

Filesystem static mode resolves Kumbuka wiki links at build time and rewrites ordinary relative Markdown links such as `../content/editor.md` to their generated static URLs. Missing `.md` link targets fail the static build instead of silently generating a broken link.
