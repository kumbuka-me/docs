# Import and export

## Imports

Open **Administration → Import** and choose the source format. An import request may contain up to 100 MiB of uncompressed file content, including files inside ZIP archives.

**Markdown** accepts `.md`, `.markdown`, and ZIP archives containing those files. Each document needs a level-one heading (`# Title`), which becomes the page title; the file path becomes the page path.

**Wiki.js** accepts JSON or ZIP. JSON pages provide `path`, `title`, and `content` fields.

**Confluence** accepts HTML/HTM or ZIP and converts supported HTML to Markdown.

Imported pages are created as `verified`. Replacing an existing page keeps its existing metadata, including icon, language, tags, lifecycle state, ownership and review settings, groups, replacement target, and properties.

## Exports

A single page can be exported as Markdown. When it references uploaded images, Kumbuka creates a ZIP containing the Markdown and referenced images with portable relative paths.

Administrators can also export selected pages or all pages as an archive.

PDF export requires a configured HTML-to-PDF service. See [Configuration](../configuration/index.md).

Static-site generation is a separate publishing workflow; see [Static sites](../static-sites.md).

## Customized print and PDF output

When a page uses variables, open **Share and export → Customize variables** to replace their values for one print or PDF operation. The changes affect only that preview, print, or PDF and do not modify the page, revisions, shared variable values, or Markdown exports.

Use **Reset to saved values** to discard the temporary values. See [Templates and snippets](../knowledge/snippets-templates.md#temporary-values-for-print-and-pdf) for limits and detailed behavior.
