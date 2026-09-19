# Media and attachments

Kumbuka supports uploaded images and downloadable attachments. Uploaded files use authenticated Kumbuka URLs.

## Images

Image uploads support JPEG, PNG, GIF, and WebP. The maximum image size is 10 MiB. An image that is still referenced by content cannot be deleted until those references are removed.

### Image sizing

Append a width directive directly to a Markdown image, without a space:

```markdown
![Architecture](/media/42/architecture.png){width=640}
![Architecture](/media/42/architecture.png){width=640px}
![Architecture](/media/42/architecture.png){width=50%}
```

A bare number means pixels. Pixel widths accept whole numbers from 1 to 10000; percentages accept whole numbers from 1 to 100. Percentages are relative to the content width.

Only the displayed width changes; the original upload is unchanged and the height follows the image's aspect ratio.

Titles, linked images, and reference-style images also support the width directive:

```markdown
![Architecture](/media/42/architecture.png "System overview"){width=640}
[![Architecture](/media/42/architecture.png){width=50%}](/media/42/architecture.png)
![Architecture][diagram]{width=50%}

[diagram]: /media/42/architecture.png "System overview"
```

The width is preserved in previews, saved pages, static sites, PDF output, and Markdown exports. This is a Kumbuka extension rather than standard Markdown syntax, so other Markdown renderers may display the directive as text.

## Attachments

Attachments are non-image documentation files. Supported types include PDF, plain text, Markdown, JSON, YAML, CSV, log files, TOML, and ZIP. The maximum attachment size is 25 MiB.

## Export behavior

Markdown export includes referenced images. Pages that need media are packaged as ZIP archives with portable relative image paths.

PDF export includes stored images in the generated document and requires the configured HTML-to-PDF service.
