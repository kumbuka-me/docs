# Page access

Kumbuka can restrict a page path and all pages below it to selected collaboration groups.

Administrators manage rules under **Administration → Page access**. A rule grants one group either **View** or **View and edit** access to a path. Multiple rules on the same path form an allow-list. Edit access also includes view access.

Rules inherit down the page tree. If a descendant has its own rules, that nearest rule set replaces the inherited one. Paths without a matching rule follow the normal role permissions. Administrators always retain access.

Page-access rules apply to page views and edits, navigation, dashboard collections, search, the knowledge graph, page reports, includes, revisions, comments, and exports. Restricted pages are omitted from the public sitemap.

Uploaded media and attachments use Kumbuka's normal authenticated media access rather than separate per-file access rules. Do not treat a raw media URL as a secret.
