# Git-friendly mirror

`kumbuka-cli mirror` exports the current knowledge base as a directory tree that can be committed to Git or copied into a backup system.

```sh
kumbuka-cli mirror \
  --database-url 'postgres://kumbuka:secret@postgres:5432/kumbuka?sslmode=disable' \
  --output kumbuka-mirror
```

The mirror is one-way: editing the generated files does not change Kumbuka. Each run stages a complete snapshot before replacing the selected output directory, so a failed export leaves the previous snapshot in place. The CLI rejects destructive destinations such as a filesystem root, the current working directory, or one of its ancestors, including paths that resolve there through symlinks.

```text
kumbuka-mirror/
├── manifest.json
├── pages/
│   └── platform/runbook.md
├── metadata/
│   └── platform/runbook.json
├── media/
│   └── 42/diagram.png
└── attachments/
    └── 17/checklist.pdf
```

`pages/` contains the original Markdown. `metadata/` contains page metadata such as title, lifecycle state, groups, tags, ownership, review settings, properties, authorship, and timestamps. Images and attachments are exported under stable identifiers, and `manifest.json` describes the snapshot contents.

Unchanged content produces stable output, which keeps Git diffs useful. Treat a mirror as sensitive: it contains all non-deleted pages and uploaded files, including content hidden by page-access rules.
