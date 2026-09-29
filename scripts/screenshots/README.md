# Documentation screenshots

Run the complete screenshot flow from the documentation repository:

```sh
make screenshots
```

The Makefile downloads the pinned Kumbuka release through the shared dev-tools installer. The screenshot runner fetches that release's `plugins.lock` and uses the same plugin download and checksum verification logic as Kumbuka core.

An isolated PostgreSQL instance and real Kumbuka server render the current documentation and released plugin preview fixtures. Application screenshots are written to `assets/screenshots/`; plugin previews are written to `assets/plugins/<plugin>/preview.png`.

Captures use a 2× device scale factor by default for sharp HiDPI output.
