# Markdown

Kumbuka supports standard Markdown plus Kumbuka-specific features and optional plugin syntax. Wiki links are built in; features such as callouts, tabs, details, tables, task lists, autolinks, syntax highlighting, footnotes, definition lists, and typographic substitutions are provided by plugins.

## Images

Use normal Markdown image syntax. Kumbuka also supports an optional width directly after the image:

```markdown
![Diagram](images/diagram.png){width=640}
![Diagram](images/diagram.png){width=50%}
```

See [Image sizing](media.md#image-sizing) for supported values and export behavior.

## Wiki links

```markdown
[[Postgres Restore]]
[[Postgres Restore|the runbook]]
[[operations/postgres/restore]]
[[operations/postgres/restore#Verify the restore]]
[[operations/postgres/restore#Verify the restore|verification steps]]
```

Append `#Heading` to link to a heading on the target page. Wiki-link syntax inside fenced code blocks remains literal.

## Callouts

```markdown
!!! warning
`$(VAR_NAME)` does not work with **envFrom**!
```

Supported presentation kinds include `info`, `success`, `warning`, and `danger`.

## Tabs

````markdown
=== "Linux"

    ```bash
    apt install postgresql
    ```

=== "macOS"

    ```bash
    brew install postgresql
    ```
````

## Collapsible details

```markdown
??? "Closed by default"

    Markdown content.
```

Use `???+` to render the details block initially open.

## Page functions

The **Subpages** plugin can insert links to the current page's children:

```markdown
{{subpages}}
```

Set a custom heading or hide it entirely:

```markdown
{{subpages title="Related pages"}}
{{subpages title=""}}
```

Static builds support the same syntax when the project includes the Subpages plugin.

## Reusable content

The Variables, Snippets, and Includes plugins provide reusable content:

```text
{{var:name}}
{{snippet:name}}
{{include:path/to/page}}
```

These macros remain literal inside fenced code blocks. Includes may be nested only within the supported recursion limit.

See [Templates and snippets](../knowledge/snippets-templates.md) for authoring details and [Tables](tables.md) for Kumbuka's table directive syntax.
