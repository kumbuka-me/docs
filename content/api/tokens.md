# Personal access tokens

Users can create personal access tokens with a name and optional expiration. Administrators can also manage tokens across accounts.

The token secret is shown only when it is created, so copy it immediately and store it securely. Kumbuka keeps the information needed to validate the token along with metadata such as creation time, creator, optional expiration, and last use.

Send the token as a bearer credential:

```http
Authorization: Bearer <token>
```

Tokens work only on API and media routes that allow bearer authentication. The token uses the permissions of its Kumbuka user, including role and page-access restrictions.
