# Import and export

## Imports

Open **Administration → Import** and choose the source format. An import request may contain up to 100 MiB of uncompressed file content, including files inside ZIP archives.

**Markdown** accepts `.md`, `.markdown`, and ZIP archives containing those files. Each document needs a level-one heading (`# Title`), which becomes the page title; the file path becomes the page path.

**Wiki.js** accepts JSON or ZIP. JSON pages provide `path`, `title`, and `content` fields.

**Confluence** accepts HTML/HTM or ZIP and converts supported HTML to Markdown.

Pages imported from Markdown, Wiki.js, or Confluence are created as `verified`. Replacing an existing page keeps its existing metadata, including icon, language, tags, lifecycle state, ownership and review settings, groups, replacement target, and properties.

### Restore a Kumbuka archive

Choose **Kumbuka archive** and upload exactly one ZIP created by **Administration → Exports**. A single ZIP whose root manifest identifies Kumbuka is also detected automatically when another source format is selected.

The archive restores page Markdown and portable metadata, referenced images, and attachments. Groups are matched by name, ignoring case, and missing groups are created. Imported metadata replaces the metadata of an existing page at the same path. This differs from the Markdown, Wiki.js, and Confluence import behavior described above.

The archive must fit both the 100 MiB uploaded-file limit and the 100 MiB total expanded-content limit. The expanded limit includes the manifest, page metadata, Markdown, images, and attachments. Kumbuka validates the archive inventory and paths before restoring content. Restoration writes resources, groups, and pages in sequence; an operational failure can leave earlier writes in place.

## Exports

A single page can be exported as Markdown. When it references uploaded images, Kumbuka creates a ZIP containing the Markdown and referenced images with portable relative paths.

**Administration → Exports** creates a portable Kumbuka ZIP for selected pages or all pages. It contains a versioned `manifest.json`, Markdown under `pages/`, metadata under `metadata/`, and referenced images and attachments under `media/` and `attachments/`. Resource links are rewritten to portable relative paths.

Portable exports preserve page settings such as tags, groups, language, lifecycle state, ownership, review interval, and properties. They do not include account credentials, API tokens, revision history, or instance configuration. Use a database backup when you need to preserve the complete instance.

PDF export requires a configured HTML-to-PDF service. See [Configuration](../configuration/index.md).

Static-site generation is a separate publishing workflow; see [Static sites](../static-sites.md).

## Customized print and PDF output

When a page uses variables, open **Share and export → Customize variables** to replace their values for one print or PDF operation. The changes affect only that preview, print, or PDF and do not modify the page, revisions, shared variable values, or Markdown exports.

Use **Reset to saved values** to discard the temporary values. See [Templates and snippets](../knowledge/snippets-templates.md#temporary-values-for-print-and-pdf) for limits and detailed behavior.
