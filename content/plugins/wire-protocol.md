# Plugin wire protocol

The Go SDK owns this protocol for normal plugin authors. This page documents the low-level API v1 contract for other WASI Preview 1 implementations and runtime integration work.

## Guest exports

A WASI Preview 1 reactor exposes:

| Export                | Parameters                      | Result                    |
| --------------------- | ------------------------------- | ------------------------- |
| `_initialize`         | none                            | none                      |
| `kumbuka_api_version` | none                            | `i32`, currently `1`      |
| `kumbuka_alloc`       | `i32` byte length               | `i32` guest-memory offset |
| `kumbuka_transform`   | `i32` offset, `i32` byte length | packed `i64` response     |
| `memory`              | —                               | linear memory             |

Kumbuka calls `_initialize` before checking the API version. For each request it asks the guest to allocate a buffer, writes a JSON request, and invokes `kumbuka_transform`.

The returned `i64` packs the response byte length into the high 32 bits and the guest-memory offset into the low 32 bits. Kumbuka validates both before decoding JSON. The response buffer must remain valid until the next invocation. Calls to one reactor are serialized.

## Render requests

A render request contains:

- `api_version` — protocol version;
- `module` — manifest module ID;
- `stage` — operation/stage;
- `source` — Markdown, code, or intermediate HTML input;
- `language` — fenced-code language when applicable;
- `invocation` — serialized macro parse state when applicable;
- `features` — request-scoped presentation flags;
- `widget` — the host surface plus optional current-page metadata for widget invocations.
- `widget_command` — validated widget surface, optional page, and action ID for a host-mediated command;
- `export` — authorized page metadata and stored Markdown source for an exporter invocation.

A result can contain an error, macro match/invocation data, ordered output parts, widget actions, a widget-command result, or an exported file depending on the stage. A part is literal intermediate text or Markdown that Kumbuka renders recursively. Only preprocessing stages may return recursive Markdown fragments; the WASM call finishes before nested rendering occurs.

All resulting HTML passes through Kumbuka's central sanitizer. There is no trusted-HTML result type.

## Macros

For a `macro` module, Kumbuka first invokes stage `parse` for candidate source. A matched response returns `matched` plus JSON `invocation` data. Kumbuka later calls stage `macro` with that invocation data. Macro rendering returns ordinary text fragments; it cannot return recursive Markdown fragments.

## Widgets

For a `widget` module, Kumbuka invokes stage `widget`. The request contains the selected public widget surface and, for page-scoped surfaces, authorized current-page metadata.

Widget output uses ordinary text parts and is sanitized before it reaches the host template. Recursive Markdown fragments are rejected. A result can additionally request bounded host-rendered actions. API v1 supports `link` and `dialog` actions with a stable action ID, visible label, local application URL, and optional host icon. It also supports `command`, which has no plugin URL and may carry bounded confirmation text.

For a command, Kumbuka owns the POST route and invokes the same module with stage `widget-command` plus `widget_command` context. A command response contains only an optional local redirect. Page-scoped commands are reauthorized by the host before the guest runs.

## Exporters

For an `exporter` module, Kumbuka invokes stage `export` with an `export` context containing the authorized current page and stored Markdown source. The result contains exactly one `file` with a base filename, media type, and bytes. Render parts and widget actions are rejected for this stage, and Kumbuka validates the file again before sending it as a download.

## Administrator actions

For an `admin-action` module, Kumbuka invokes stage `admin-action`. The SDK callback receives no arbitrary HTTP request or browser payload; a successful action returns an empty result and a failed action returns the normal result error. Kumbuka owns the administrator route, authentication, authorization, CSRF handling, and surrounding UI.

## Host capability import

Guests can import:

```text
kumbuka_v1.call(i32, i32, i32, i32) -> i32
```

The arguments are request offset, request length, response offset, and response capacity. Both buffers belong to guest memory. The result is the number of response bytes or zero for an invalid buffer. Kumbuka never re-enters a guest allocator during a host call.

Requests are JSON objects with `method` and method-specific `params`. Responses contain either `value` or `error`. Unknown methods and unknown top-level fields are rejected. See [Capabilities](capabilities.md) for the public operations and permission model.

## Go build target

A Go reactor can be built with:

```sh
GOOS=wasip1 GOARCH=wasm go build -buildmode=c-shared -o plugin.wasm .
```

The `kumbuka-plugin` CLI handles this automatically for normal SDK projects.
