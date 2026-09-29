#!/usr/bin/env python3
"""Prepare deterministic screenshot fixtures from released Kumbuka plugins."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import time
import urllib.error
import urllib.parse
import urllib.request
import zipfile


USER_AGENT = "kumbuka-docs/screenshots"
DOWNLOAD_ATTEMPTS = 5
DOWNLOAD_DELAY = 2


def raw_github_file(repository: str, path: str, ref: str) -> bytes:
    repository_path = "/".join(
        urllib.parse.quote(part, safe="") for part in repository.split("/")
    )
    ref_path = urllib.parse.quote(ref, safe="/")
    file_path = urllib.parse.quote(path, safe="/")
    url = f"https://raw.githubusercontent.com/{repository_path}/{ref_path}/{file_path}"
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})

    for attempt in range(1, DOWNLOAD_ATTEMPTS + 1):
        try:
            with urllib.request.urlopen(request, timeout=30) as response:
                return response.read()
        except urllib.error.HTTPError as error:
            if error.code == 404:
                raise RuntimeError(
                    f"GitHub file not found: {repository}@{ref}:{path}"
                ) from error
            if attempt == DOWNLOAD_ATTEMPTS:
                raise RuntimeError(
                    f"GitHub returned HTTP {error.code} for {repository}@{ref}:{path}"
                ) from error
        except urllib.error.URLError as error:
            if attempt == DOWNLOAD_ATTEMPTS:
                raise RuntimeError(
                    f"Could not fetch {repository}@{ref}:{path}: {error.reason}"
                ) from error

        time.sleep(DOWNLOAD_DELAY)

    raise RuntimeError(f"Could not fetch {repository}@{ref}:{path}")


def parse_plugin_lock(source: str) -> list[tuple[str, str]]:
    plugins: list[tuple[str, str]] = []
    seen: set[str] = set()
    for raw in source.splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        name, separator, version = line.partition("=")
        name = name.strip()
        version = version.strip()
        if not separator or not name or not version:
            raise RuntimeError(f"Invalid plugins.lock entry: {raw!r}")
        if name in seen:
            raise RuntimeError(f"Duplicate plugin in plugins.lock: {name}")
        seen.add(name)
        plugins.append((name, version))
    if not plugins:
        raise RuntimeError("Kumbuka plugins.lock did not contain any plugins")
    return plugins


def write_plugin_lock(version: str, output: Path) -> None:
    if output.is_file():
        parse_plugin_lock(output.read_text(encoding="utf-8"))
        return

    lock = raw_github_file(
        "kumbuka-me/kumbuka",
        "plugins.lock",
        f"refs/tags/{version}",
    )
    parse_plugin_lock(lock.decode("utf-8"))
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_bytes(lock)


def write_markdown_archive(source_dir: Path, output: Path) -> None:
    files = sorted(path for path in source_dir.rglob("*.md") if path.is_file())
    if not files:
        raise RuntimeError(f"No Markdown files found under {source_dir}")

    output.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(output, "w", compression=zipfile.ZIP_DEFLATED) as archive:
        for path in files:
            archive.write(path, path.relative_to(source_dir).as_posix())


def preview_support_pages(plugin_name: str) -> list[dict[str, str]]:
    if plugin_name == "includes":
        return [
            {
                "slug": "operations/shared-warning",
                "title": "Shared warning",
                "markdown": "# Shared warning\n\n## Warning\n\n!!! warning\nBack up the database before changing production.\n",
            }
        ]
    if plugin_name == "subpages":
        return [
            {
                "slug": "__screenshots/plugins/subpages/getting-started",
                "title": "Getting started",
                "markdown": "# Getting started\n\nPrepare the service and confirm access before making changes.\n",
            },
            {
                "slug": "__screenshots/plugins/subpages/operations",
                "title": "Operations",
                "markdown": "# Operations\n\nDay-two procedures for running the service safely.\n",
            },
            {
                "slug": "__screenshots/plugins/subpages/troubleshooting",
                "title": "Troubleshooting",
                "markdown": "# Troubleshooting\n\nCommon symptoms, checks, and recovery steps.\n",
            },
        ]
    return []


def cached_preview(cache_dir: Path, name: str, version: str) -> str:
    filename = cache_dir / name / version / "preview.md"
    if filename.is_file():
        preview = filename.read_text(encoding="utf-8")
        if preview.strip():
            return preview
        filename.unlink()

    tag = f"{name}/v{version}"
    print(f"Downloading preview fixture {name} v{version}")
    preview = raw_github_file(
        "kumbuka-me/plugins",
        f"{name}/preview.md",
        f"refs/tags/{tag}",
    ).decode("utf-8")
    if not preview.strip():
        raise RuntimeError(f"Empty preview fixture for {name} at {tag}")

    filename.parent.mkdir(parents=True, exist_ok=True)
    filename.write_text(preview, encoding="utf-8")
    return preview


def preview_title(name: str) -> str:
    return name.replace("-", " ").title() + " preview"


def write_plugin_metadata(
    lock_file: Path,
    preview_cache: Path,
    content_dir: Path,
    metadata_file: Path,
) -> None:
    plugins = parse_plugin_lock(lock_file.read_text(encoding="utf-8"))
    selected: list[dict[str, object]] = []

    for name, version in plugins:
        extension_page = content_dir / "extensions" / f"{name}.md"
        if not extension_page.is_file():
            continue

        selected.append(
            {
                "id": f"me.kumbuka.{name}",
                "name": name,
                "version": version,
                "title": preview_title(name),
                "markdown": cached_preview(preview_cache, name, version),
                "support_pages": preview_support_pages(name),
            }
        )

    if not selected:
        raise RuntimeError("No released plugin previews matched content/extensions")

    metadata_file.parent.mkdir(parents=True, exist_ok=True)
    metadata_file.write_text(
        json.dumps(selected, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )


def command_lock(args: argparse.Namespace) -> None:
    write_plugin_lock(args.kumbuka_version, args.output)


def command_content(args: argparse.Namespace) -> None:
    write_markdown_archive(args.source, args.output)


def command_plugins(args: argparse.Namespace) -> None:
    write_plugin_metadata(
        args.plugin_lock,
        args.preview_cache,
        args.content,
        args.metadata,
    )


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(description=__doc__)
    subcommands = result.add_subparsers(dest="command", required=True)

    lock = subcommands.add_parser(
        "lock",
        help="Fetch and cache plugins.lock from the selected Kumbuka release",
    )
    lock.add_argument("--kumbuka-version", required=True)
    lock.add_argument("--output", required=True, type=Path)
    lock.set_defaults(handler=command_lock)

    content = subcommands.add_parser(
        "content", help="Create a portable Markdown archive from the documentation"
    )
    content.add_argument("--source", required=True, type=Path)
    content.add_argument("--output", required=True, type=Path)
    content.set_defaults(handler=command_content)

    plugins = subcommands.add_parser(
        "plugins", help="Create plugin preview pages from released preview fixtures"
    )
    plugins.add_argument("--plugin-lock", required=True, type=Path)
    plugins.add_argument("--preview-cache", required=True, type=Path)
    plugins.add_argument("--content", required=True, type=Path)
    plugins.add_argument("--metadata", required=True, type=Path)
    plugins.set_defaults(handler=command_plugins)

    return result


def main() -> None:
    args = parser().parse_args()
    try:
        args.handler(args)
    except RuntimeError as error:
        raise SystemExit(f"prepare screenshots: {error}") from error


if __name__ == "__main__":
    main()
