#!/usr/bin/env python3
"""Prepare deterministic screenshot fixtures from released Kumbuka plugins."""

from __future__ import annotations

import argparse
import base64
import hashlib
import json
import os
from pathlib import Path
import sys
import tomllib
import urllib.error
import urllib.parse
import urllib.request
import zipfile


USER_AGENT = "kumbuka-docs/screenshots"


def github_file(repository: str, path: str, ref: str) -> bytes:
    query = urllib.parse.urlencode({"ref": ref})
    quoted = urllib.parse.quote(path, safe="/")
    url = f"https://api.github.com/repos/{repository}/contents/{quoted}?{query}"
    headers = {
        "Accept": "application/vnd.github+json",
        "User-Agent": USER_AGENT,
    }
    token = os.environ.get("GITHUB_TOKEN", "").strip()
    if token:
        headers["Authorization"] = f"Bearer {token}"

    request = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            payload = json.load(response)
    except urllib.error.HTTPError as error:
        raise RuntimeError(
            f"GitHub returned HTTP {error.code} for {repository}@{ref}:{path}"
        ) from error
    except urllib.error.URLError as error:
        raise RuntimeError(
            f"Could not fetch {repository}@{ref}:{path}: {error.reason}"
        ) from error

    if payload.get("encoding") != "base64" or not payload.get("content"):
        raise RuntimeError(f"Unexpected GitHub response for {repository}@{ref}:{path}")

    return base64.b64decode(payload["content"])


def parse_plugin_lock(source: str) -> list[tuple[str, str]]:
    plugins: list[tuple[str, str]] = []
    for raw in source.splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        name, separator, version = line.partition("=")
        if not separator or not name or not version:
            raise RuntimeError(f"Invalid plugins.lock entry: {raw!r}")
        plugins.append((name.strip(), version.strip()))
    if not plugins:
        raise RuntimeError("Kumbuka plugins.lock did not contain any plugins")
    return plugins


def write_manifest(version: str, output: Path) -> None:
    source = github_file("kumbuka-me/kumbuka", "plugins.lock", version).decode("utf-8")
    plugins = parse_plugin_lock(source)

    lines = ["format = 1", ""]
    for name, plugin_version in plugins:
        lines.extend(
            [
                "[[plugin]]",
                f'id = "me.kumbuka.{name}"',
                'repository = "kumbuka-me/plugins"',
                f'tag_prefix = "{name}/v"',
                f'asset = "{name}"',
                f'version = "{plugin_version}"',
                "",
            ]
        )

    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text("\n".join(lines), encoding="utf-8")


def user_cache_dir() -> Path:
    if sys.platform == "darwin":
        return Path.home() / "Library" / "Caches"
    if sys.platform.startswith("linux"):
        configured = os.environ.get("XDG_CACHE_HOME", "").strip()
        return Path(configured) if configured else Path.home() / ".cache"
    raise RuntimeError(f"Unsupported screenshot platform: {sys.platform}")


def package_cache_path(plugin: dict[str, object]) -> Path:
    repository = str(plugin["repository"])
    tag_prefix = str(plugin["tag_prefix"])
    asset = str(plugin["asset"])
    plugin_id = str(plugin["id"])
    version = str(plugin["version"])
    digest = hashlib.sha256(
        f"{repository}\n{tag_prefix}\n{asset}".encode("utf-8")
    ).hexdigest()
    return (
        user_cache_dir()
        / "kumbuka"
        / "plugins"
        / digest
        / plugin_id
        / version
        / "plugin.kumbukaplugin"
    )


def read_manifest(filename: Path) -> list[dict[str, object]]:
    with filename.open("rb") as source:
        data = tomllib.load(source)
    if data.get("format") != 1:
        raise RuntimeError(f"Unsupported plugin manifest format in {filename}")
    plugins = data.get("plugin")
    if not isinstance(plugins, list):
        raise RuntimeError(f"Plugin manifest contains no plugins: {filename}")
    return plugins


def write_markdown_archive(source_dir: Path, output: Path) -> None:
    files = sorted(path for path in source_dir.rglob("*.md") if path.is_file())
    if not files:
        raise RuntimeError(f"No Markdown files found under {source_dir}")

    output.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(output, "w", compression=zipfile.ZIP_DEFLATED) as archive:
        for path in files:
            archive.write(path, path.relative_to(source_dir).as_posix())


def preview_support_files(archive: zipfile.ZipFile, plugin_name: str) -> None:
    if plugin_name == "includes":
        archive.writestr(
            "operations/shared-warning.md",
            """# Shared warning\n\n## Warning\n\n!!! warning\nBack up the database before changing production.\n""",
        )
    elif plugin_name == "subpages":
        children = {
            "getting-started.md": "# Getting started\n\nPrepare the service and confirm access before making changes.\n",
            "operations.md": "# Operations\n\nDay-two procedures for running the service safely.\n",
            "troubleshooting.md": "# Troubleshooting\n\nCommon symptoms, checks, and recovery steps.\n",
        }
        for filename, content in children.items():
            archive.writestr(
                f"__screenshots/plugins/subpages/{filename}",
                content,
            )


def write_plugin_archive(
    manifest_file: Path,
    content_dir: Path,
    archive_file: Path,
    metadata_file: Path,
) -> None:
    plugins = read_manifest(manifest_file)
    selected: list[dict[str, str]] = []

    archive_file.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(archive_file, "w", compression=zipfile.ZIP_DEFLATED) as archive:
        for plugin in plugins:
            name = str(plugin["asset"])
            extension_page = content_dir / "extensions" / f"{name}.md"
            if not extension_page.is_file():
                continue

            repository = str(plugin["repository"])
            tag = f"{plugin['tag_prefix']}{plugin['version']}"
            preview_path = f"{name}/preview.md"
            preview = github_file(repository, preview_path, tag).decode("utf-8")
            if not preview.strip():
                raise RuntimeError(f"Empty preview fixture for {name} at {tag}")

            package = package_cache_path(plugin)
            if not package.is_file():
                raise RuntimeError(
                    f"Plugin package was not synced for {plugin['id']} {plugin['version']}: {package}"
                )

            archive.writestr(f"__screenshots/plugins/{name}.md", preview)
            preview_support_files(archive, name)
            selected.append(
                {
                    "id": str(plugin["id"]),
                    "name": name,
                    "version": str(plugin["version"]),
                    "package": str(package),
                }
            )

    if not selected:
        raise RuntimeError("No released plugin previews matched content/extensions")

    metadata_file.parent.mkdir(parents=True, exist_ok=True)
    metadata_file.write_text(
        json.dumps(selected, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )


def command_manifest(args: argparse.Namespace) -> None:
    write_manifest(args.kumbuka_version, args.output)


def command_content(args: argparse.Namespace) -> None:
    write_markdown_archive(args.source, args.output)


def command_plugins(args: argparse.Namespace) -> None:
    write_plugin_archive(args.manifest, args.content, args.archive, args.metadata)


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(description=__doc__)
    subcommands = result.add_subparsers(dest="command", required=True)

    manifest = subcommands.add_parser(
        "manifest", help="Create the plugin dependency manifest for one Kumbuka release"
    )
    manifest.add_argument("--kumbuka-version", required=True)
    manifest.add_argument("--output", required=True, type=Path)
    manifest.set_defaults(handler=command_manifest)

    content = subcommands.add_parser(
        "content", help="Create a portable Markdown archive from the documentation"
    )
    content.add_argument("--source", required=True, type=Path)
    content.add_argument("--output", required=True, type=Path)
    content.set_defaults(handler=command_content)

    plugins = subcommands.add_parser(
        "plugins", help="Create plugin preview fixtures and metadata from synced releases"
    )
    plugins.add_argument("--manifest", required=True, type=Path)
    plugins.add_argument("--content", required=True, type=Path)
    plugins.add_argument("--archive", required=True, type=Path)
    plugins.add_argument("--metadata", required=True, type=Path)
    plugins.set_defaults(handler=command_plugins)

    return result


def main() -> None:
    args = parser().parse_args()
    try:
        args.handler(args)
    except (OSError, RuntimeError, tomllib.TOMLDecodeError, ValueError) as error:
        raise SystemExit(f"prepare screenshots: {error}") from error


if __name__ == "__main__":
    main()
