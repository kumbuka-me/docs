# Plugin package format

A `.kumbukaplugin` file is a bounded ZIP archive validated before Kumbuka exposes any of its contents.

## Files

A package can contain:

```text
README.md
plugin.yaml
plugin.wasm        # only when executable modules require WASM
assets/
  ...
```

`README.md` and `plugin.yaml` are required. `plugin.wasm` is required when the manifest contains an executable `renderer-extension`, `macro`, `code-highlighter`, `widget`, or `exporter`. Declarative-only packages do not need WASM.

The packaged README is sanitized and displayed on the plugin detail page in **Administration → Plugins**.

Only files under `assets/` can be added beyond those package-root files. Unsafe paths, duplicate entries, symlinks, special files, and unsupported root entries are rejected. The runtime keeps validated packages in memory and does not extract archives into the host filesystem.

## Limits

| Item             |   Limit |
| ---------------- | ------: |
| Archive          |  16 MiB |
| Expanded package |  32 MiB |
| WASM module      |  16 MiB |
| One asset        |   8 MiB |
| Manifest         |  64 KiB |
| README           | 256 KiB |
| Entries          |     256 |

The manifest is strictly decoded and must contain exactly one YAML document.

## Building packages

`kumbuka-plugin build` validates the project, compiles required Go/WASI code, and writes a deterministic package to `dist/<plugin-name>.kumbukaplugin`.

For executable Go plugins, the build uses the Go version declared by the containing module and targets `GOOS=wasip1`, `GOARCH=wasm`.

See [Manifest and modules](manifest.md) for the manifest schema and [Getting started](getting-started.md) for the normal development workflow.
