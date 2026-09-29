# Documentation screenshots

Run the complete screenshot flow from the documentation repository:

```sh
make screenshots
```

The Makefile downloads the pinned Kumbuka release through the shared dev-tools installer. That release already contains the matching first-party plugin packages used by Kumbuka itself.

The screenshot runner caches the release's `plugins.lock` and each matching plugin `preview.md` fixture under `bin/screenshot-fixtures/`. Existing versions are reused, so only fixtures for newly pinned plugin versions are downloaded.

An isolated PostgreSQL instance and real Kumbuka server render the current documentation and plugin previews. Preview pages are imported with optional plugins disabled, then the bundled plugins are enabled and those preview pages are rebuilt before capture.

Application screenshots are written to `assets/screenshots/`; plugin previews are written to `assets/plugins/<plugin>/preview.png`.

Captures use a 2× device scale factor by default for sharp HiDPI output.
