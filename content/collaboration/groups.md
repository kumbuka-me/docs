# Groups and roles

Every Kumbuka user has one role: `admin`, `editor`, or `viewer`.

- `admin` manages the application and can perform destructive page operations.
- `editor` can create and edit content.
- `viewer` can use authenticated read features.

Administrators can also create named collaboration groups and manage membership. Pages can be assigned to groups, and editors can assign only groups available to their account. A separate owner group can be used for documentation ownership and review workflows.

For path-based access rules, see [Page access](../administration/page-access.md). OIDC can synchronize explicitly mapped external groups into Kumbuka groups; see [OIDC](../authentication/oidc.md).
