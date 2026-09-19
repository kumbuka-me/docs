# Dynamic page reports

The **Page Report** plugin renders a live collection of pages using Kumbuka's normal search language. Matching pages update automatically as their metadata changes.

Use a standalone `{{pages ...}}` function:

```text
{{pages query="tag:service status:verified"}}
```

The required `query` option accepts the same filters as normal search. Optional settings control columns, layout, sorting, and result count:

```text
{{pages query="owner:\"Platform\"" columns="title,property:version,status,updated" view=table sort=title limit=50}}
```

Supported columns are `title`, `path`, `status`, `owner`, `updated`, `author`, `tags`, `views`, and `property:<key>`. Supported views are `table`, `list`, and `cards`. Sorting can use `relevance`, `updated`, `title`, or `path`; `limit` may be between 1 and 100.

Page reports are available only in the Kumbuka server. Static sites do not evaluate the `{{pages ...}}` function.
