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

## SDK source selection

`kumbuka-plugin init` accepts either `--sdk-version` or `--sdk-path`. When the CLI is built from an SDK checkout and neither option is supplied, it can use that checkout automatically.

## Release a first-party plugin

First-party plugins in `kumbuka-me/plugins` are versioned independently. Use a patch bump for compatible fixes, a minor bump for backwards-compatible features, and a major bump for breaking plugin behavior.

Bump one plugin manifest with:

```sh
make version-plugin PLUGIN=simple-icons BUMP=patch
```

`make version` provides the same flow interactively. Run the repository tests and lint checks, then commit and push the version change before creating the release tag.

With a clean working tree, create the tag for the version stored in `plugin.yaml`:

```sh
make tag-plugin PLUGIN=simple-icons
git push origin simple-icons/v1.0.1
```

The plugins release workflow verifies that the tag matches the manifest version, runs tests and linting, builds the `.kumbukaplugin` package and checksum, and creates the matching GitHub Release. `make tag-plugin` creates the local tag only; it does not push it.

### Releasing a new SDK dependency

A Go SDK version must exist as a Git tag before another repository can resolve it. When a plugin needs a new SDK version, release the SDK first:

```sh
cd ../sdk
git tag v0.2.0
git push origin v0.2.0
```

Pushing an SDK `vMAJOR.MINOR.PATCH` tag runs the SDK test, lint, and build workflow and creates a GitHub Release when those checks pass. The Git tag itself is what makes `github.com/kumbuka-me/sdk@v0.2.0` available to the Go module resolver; the GitHub Release is not required for module resolution.

After the SDK tag is available, update the plugins repository and refresh its module files:

```sh
cd ../plugins
go get github.com/kumbuka-me/sdk@v0.2.0
go mod tidy
```

Only then bump and release the affected plugin version.

## Next steps

- Define package metadata and contributions in [Manifest and modules](manifest.md).
- Use typed host operations described in [Capabilities](capabilities.md).
- Use [Browser modules](browser-modules.md) for isolated client-side rendering.
- Read the [Wire protocol](wire-protocol.md) only when implementing the guest ABI directly instead of using the Go SDK.
