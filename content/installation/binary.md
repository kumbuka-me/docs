# Binary

Kumbuka can run directly as a compiled binary when PostgreSQL is reachable. Release archives are available for Linux and macOS on AMD64 and ARM64.

After extracting the archive, start Kumbuka with a database URL:

```sh
./kumbuka \
  --database-url 'postgres://kumbuka:secret@localhost:5432/kumbuka?sslmode=disable'
```

The same setting can be supplied with `KUMBUKA__DATABASE_URL`. Run `./kumbuka --help` for the complete server flag reference, or see [Runtime configuration](../configuration/runtime.md).

Static-site builds, mirrors, and plugin-project commands are provided by the separate `kumbuka-cli` binary.

## PDF support

PDF export uses a separate HTML-to-PDF service. Configure its endpoint and optional request headers under **Administration → Configuration**. A deployment can override the endpoint with `KUMBUKA__PDF_URL`.

If request headers contain credentials, mark them sensitive and configure `KUMBUKA__ENCRYPTION_KEY`.
