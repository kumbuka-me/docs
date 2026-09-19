# Templates and snippets

Kumbuka supports page templates for creating new pages and reusable content for values or shared sections.

## Page templates

Administrators can create named page templates that prefill the path prefix, icon, tags, lifecycle state, owner group, review interval, properties, and Markdown body.

Templates can also prompt authors for values. Define a field with a name, label, optional default, and optional required flag, then use it in the template body:

```text
{{field:service}}
```

The new-page editor asks for the value and replaces the placeholder when the page is saved. Template fields are creation-time inputs, not persistent page macros.

## Knowledge snippets

The **Variables** and **Snippets** plugins provide reusable values managed under **Administration → Plugin settings**:

```text
{{var:name}}
{{snippet:name}}
```

The **Includes** plugin can insert another page or one of its heading sections:

```text
{{include:platform/shared-warning}}
{{include:operations/postgres#Restore from backup}}
```

Includes can be nested within the supported recursion limit. Variable and snippet values are inserted as content and are not recursively evaluated as new macros.

## Inspect variables on a page

When a page uses variables, a **Variables (N)** action shows the distinct variables used by the rendered page, including variables from included content.

The panel shows each variable's name, saved value, description, and occurrence count. **Highlight in page** marks text that came from a variable so readers can inspect it in context. Some variables used only in links, image attributes, or complex Markdown can be listed without being highlightable.

Highlighting is read-only and does not appear in print or PDF output.

## Temporary values for print and PDF

Open **Share and export → Customize variables** to replace variable values for one preview, print, or PDF operation. Every occurrence of the same variable uses the same temporary value, and an empty field replaces it with an empty string.

**Reset to saved values** clears the temporary changes. Closing and reopening the dialog also starts with the saved values again. Temporary values do not modify shared variables, page Markdown, revisions, or Markdown exports.

The print/PDF preview shows the rendered content but is not a pixel-identical pagination preview; the browser or PDF service determines final page breaks.

A request can override at most 128 variables, with a maximum of 8 KiB per value and 64 KiB total for names and values. Only variables used by the page can be overridden.
