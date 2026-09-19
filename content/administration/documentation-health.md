# Documentation health

Kumbuka computes documentation-quality findings for administrators. The health view groups pages into actionable categories:

- broken wiki links;
- orphan pages;
- untagged pages;
- pages without an icon;
- stale pages;
- pages whose configured review is due;
- lifecycle `draft` pages;
- deprecated pages.

![Documentation health overview with actionable page groups](../assets/screenshots/documentation-health.png)

The stale-page view uses an age cutoff supplied by the handler; the administration page checks for pages not updated within the previous six calendar months.

These checks use the PostgreSQL-backed page inventory and link graph. They are a server feature, not part of the read-only filesystem static build.
