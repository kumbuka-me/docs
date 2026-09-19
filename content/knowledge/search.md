# Search

Kumbuka supports full-text search together with field filters.

Supported filters are:

```text
tag:name
group:name
title:text
namespace:path
author:name
status:draft|verified|deprecated|archived
owner:group
property:key=value
```

Quoted filter values can contain spaces:

```text
group:"Platform Engineering" status:verified postgres
```

Filters can be combined with each other and with free-text terms. Saved searches let users name a query and optionally pin it into the sidebar.

## Static-site search

Generated static sites provide browser-side title and body search. The server-only field filters listed above are not available there.
