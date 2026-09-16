# Git-friendly mirror

Kumbuka can export the current PostgreSQL-backed knowledge base into a deterministic directory tree that is suitable for committing to Git or copying into a normal backup system.

```sh
kumbuka-cli mirror \
  --database-url 'postgres://kumbuka:secret@postgres:5432/kumbuka?sslmode=disable' \
  --output kumbuka-mirror
```

The database remains the only source of truth. The mirror is intentionally **one-way**: Kumbuka never reads changes back from the generated directory and it does not invoke Git.

Each run replaces the selected output directory with a complete snapshot:

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

`pages/` contains the original Markdown source without front-matter changes. `metadata/` contains portable JSON sidecars with the page identity, title, lifecycle data, groups, tags, ownership/review settings, properties, authorship and timestamps. Uploaded images and attachments are copied byte-for-byte under their stable Kumbuka identifiers. `manifest.json` records the mirror format version and the stable object inventory.

The output intentionally contains no generation timestamp, so running the command twice against unchanged content does not create a meaningless Git diff. Treat the mirror as potentially sensitive: it contains all non-deleted pages and uploaded files regardless of page access rules.
