# Dashboard

The server home page is a personalized documentation dashboard assembled from enabled plugin widgets.

Kumbuka ships bundled widgets for:

- **Continue Working** — private drafts and pages recently edited by the current user;
- **Recent Changes** — recently updated pages visible to the current user;
- **Favorites** — favorite pages on Home and pinned favorites in the sidebar;
- **Popular Pages** — the most viewed visible pages;
- **Recently Viewed** — recent pages on Home and in the sidebar.

Users can show or hide individual enabled widgets under **Settings → Plugin widgets**. Disabling or uninstalling the owning plugin removes its widgets for everyone.

Opening a page records a view for the authenticated user and supplies the activity used by Recently Viewed and Popular Pages. The static filesystem site has no accounts, plugin widgets, or server-side view tracking, so it does not generate a personalized dashboard.
