# Plugin development

The Kumbuka SDK contains the public Go API and the `kumbuka-plugin` development CLI. Go plugins compile to WASI Preview 1 and are packaged as `.kumbukaplugin` archives.

## Create a plugin

Create a project with the development CLI:

```sh
kumbuka-plugin init my-plugin
cd my-plugin
```

The generated project contains a manifest, Go module, sample plugin code, tests, and the README displayed in Kumbuka's plugin administration UI. Plugins that need only declarative modules can later remove the Go/WASM implementation entirely; Kumbuka packages declarative-only plugins without `plugin.wasm`.

A Go plugin normally imports the root SDK:

```go
import sdk "github.com/kumbuka-me/sdk"
```

Executable contributions are registered from `init`. The SDK owns the WASM ABI, request/response transport, and typed host-capability clients.

## Test and build

Validate the package and run its Go tests:

```sh
kumbuka-plugin test
```

Build the installable package:

```sh
kumbuka-plugin build
```

The output is written to:

```text
dist/<plugin-name>.kumbukaplugin
```

Install that file from **Administration → Plugins**.

Executable builds use the nearest containing `go.mod`, which lets multiple plugins share one parent module. The CLI selects the compiler from that module's `go` directive and builds with `GOOS=wasip1`, `GOARCH=wasm`, and workspace mode disabled. Declarative-only plugins need no Go module.

## SDK source selection

`kumbuka-plugin init` accepts either `--sdk-version` or `--sdk-path`. When the CLI is built from an SDK checkout and neither option is supplied, it can use that checkout automatically.

Quote local checkout paths when they contain spaces:

```sh
kumbuka-plugin init my-plugin --sdk-path "/path/to/SDK checkout"
```

The generated `go.mod` preserves that path as a quoted local replacement. Remove the local replacement and select a released SDK version before publishing a project intended for other developers.

## Release a first-party plugin

First-party plugins in `kumbuka-me/plugins` are versioned independently. Use a patch bump for compatible fixes, a minor bump for backwards-compatible features, and a major bump for breaking plugin behavior.

The normal repository workflow is interactive:

```sh
make release
```

Select the plugin and bump type. The release helper validates the repository, updates the plugin version, runs the repository checks, commits the version change, creates the plugin tag, pushes the branch, and pushes the release tag. The tag-triggered GitHub workflow builds only the tagged plugin package and checksum and creates its GitHub Release.

For a manual release, use the lower-level targets:

```sh
make version-plugin PLUGIN=simple-icons BUMP=patch
make test
make lint
make build-plugin PLUGIN=simple-icons

git add simple-icons/plugin.yaml
git commit -m "chore: bump simple-icons version"
git push origin main

make tag-plugin PLUGIN=simple-icons
# Push the exact tag printed by tag-plugin, for example:
git push origin refs/tags/simple-icons/v1.1.1
```

`make tag-plugin` creates a local tag only; it does not push it. `make check-releases` verifies the latest published plugin tags against GitHub Releases. `make release-missing` is recovery tooling for a tag that already exists remotely but is missing its release; it is not part of the normal release path.

### Releasing a new SDK dependency

A Go SDK version must exist as a Git tag before another repository can resolve it. When a plugin needs an unreleased SDK change, release the SDK first. For example, with the intended release version in a shell variable:

```sh
cd ../sdk
SDK_VERSION=v0.15.0
git tag "$SDK_VERSION"
git push origin "$SDK_VERSION"
```

Pushing an SDK `vMAJOR.MINOR.PATCH` tag runs the SDK checks and creates a GitHub Release. The Git tag is what makes `github.com/kumbuka-me/sdk@$SDK_VERSION` available to the Go module resolver.

After that tag is available, update the plugins repository and refresh its module files:

```sh
cd ../plugins
go get "github.com/kumbuka-me/sdk@$SDK_VERSION"
go mod tidy
```

Only then bump and release the affected plugin version. The server and CLI adopt SDK releases independently through their own module dependencies.

## Next steps

- Define package metadata and contributions in [Manifest and modules](manifest.md).
- Use typed host operations described in [Capabilities](capabilities.md).
- Use [Browser modules](browser-modules.md) for isolated client-side rendering.
- Read the [Wire protocol](wire-protocol.md) only when implementing the guest ABI directly instead of using the Go SDK.
