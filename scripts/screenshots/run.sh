#!/bin/sh
set -eu

usage() {
  cat <<'USAGE'
Usage: scripts/screenshots/run.sh --binary FILE --content DIR --plugins DIR --output DIR --plugin-output DIR --editor-slug SLUG [--visits PATHS]

PATHS is a comma-separated list of application paths to visit before the dashboard capture.
DIR passed to --plugins must be a checkout of kumbuka-me/plugins. Canonical preview Markdown
from that checkout is imported into the temporary Kumbuka instance only for screenshot capture.
USAGE
}

repository=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
compose_file="$repository/scripts/screenshots/compose.yaml"
binary=""
content_dir=""
plugins_dir=""
output=""
plugin_output=""
editor_slug=""
visits=""

while [ "$#" -gt 0 ]; do
  case "$1" in
  --binary)
    [ "$#" -ge 2 ] || {
      usage >&2
      exit 2
    }
    binary=$2
    shift 2
    ;;
  --content)
    [ "$#" -ge 2 ] || {
      usage >&2
      exit 2
    }
    content_dir=$2
    shift 2
    ;;
  --plugins)
    [ "$#" -ge 2 ] || {
      usage >&2
      exit 2
    }
    plugins_dir=$2
    shift 2
    ;;
  --output)
    [ "$#" -ge 2 ] || {
      usage >&2
      exit 2
    }
    output=$2
    shift 2
    ;;
  --plugin-output)
    [ "$#" -ge 2 ] || {
      usage >&2
      exit 2
    }
    plugin_output=$2
    shift 2
    ;;
  --editor-slug)
    [ "$#" -ge 2 ] || {
      usage >&2
      exit 2
    }
    editor_slug=$2
    shift 2
    ;;
  --visits)
    [ "$#" -ge 2 ] || {
      usage >&2
      exit 2
    }
    visits=$2
    shift 2
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    echo "Unknown argument: $1" >&2
    usage >&2
    exit 2
    ;;
  esac
done

[ -n "$binary" ] || {
  echo "--binary is required" >&2
  exit 2
}
[ -n "$content_dir" ] || {
  echo "--content is required" >&2
  exit 2
}
[ -n "$plugins_dir" ] || {
  echo "--plugins is required" >&2
  exit 2
}
[ -n "$output" ] || {
  echo "--output is required" >&2
  exit 2
}
[ -n "$plugin_output" ] || {
  echo "--plugin-output is required" >&2
  exit 2
}
[ -n "$editor_slug" ] || {
  echo "--editor-slug is required" >&2
  exit 2
}

case "$binary" in
/*) ;;
*) binary="$PWD/$binary" ;;
esac

case "$content_dir" in
/*) ;;
*) content_dir="$PWD/$content_dir" ;;
esac

case "$plugins_dir" in
/*) ;;
*) plugins_dir="$PWD/$plugins_dir" ;;
esac

case "$output" in
/*) ;;
*) output="$PWD/$output" ;;
esac

case "$plugin_output" in
/*) ;;
*) plugin_output="$PWD/$plugin_output" ;;
esac

[ -x "$binary" ] || {
  echo "Kumbuka binary not found or not executable: $binary" >&2
  exit 1
}
[ -d "$content_dir" ] || {
  echo "Screenshot content directory not found: $content_dir" >&2
  exit 1
}
[ -d "$plugins_dir" ] || {
  echo "Kumbuka plugins checkout not found: $plugins_dir" >&2
  echo "Set SCREENSHOT_PLUGINS_DIR to a kumbuka-me/plugins checkout." >&2
  exit 1
}
[ -x "$repository/node_modules/.bin/playwright" ] || {
  echo "Playwright is not installed. Run npm ci in the docs repository." >&2
  exit 1
}

work_dir=$(mktemp -d "${TMPDIR:-/tmp}/kumbuka-screenshots.XXXXXX")
archive="$work_dir/content.zip"
plugin_archive="$work_dir/plugin-previews.zip"
plugin_dist="$work_dir/plugin-packages"
plugin_list="$work_dir/plugins.txt"
plugin_source="$work_dir/plugin-previews"
server_log="$work_dir/kumbuka.log"
server_pid=""
compose_project="kumbuka-screenshots-$$"

screenshot_port=${SCREENSHOT_PORT:-18080}
database_port=${SCREENSHOT_DB_PORT:-55432}
base_url="http://127.0.0.1:$screenshot_port"

cleanup() {
  status=$?
  trap - EXIT INT TERM

  if [ -n "$server_pid" ]; then
    kill "$server_pid" 2>/dev/null || true
    wait "$server_pid" 2>/dev/null || true
  fi

  SCREENSHOT_DB_PORT="$database_port" \
    docker compose \
    -f "$compose_file" \
    -p "$compose_project" \
    down \
    --remove-orphans >/dev/null 2>&1 || true

  if [ "$status" -ne 0 ] && [ -s "$server_log" ]; then
    echo "Kumbuka screenshot server log:" >&2
    tail -n 200 "$server_log" >&2
  fi

  rm -rf "$work_dir"
  exit "$status"
}
trap cleanup EXIT INT TERM

mkdir -p "$output" "$plugin_output"
rm -f "$output"/*.png
find "$plugin_output" -mindepth 2 -maxdepth 2 -type f -name 'preview.png' -delete 2>/dev/null || true

if [ "${SCREENSHOT_SKIP_BROWSER_INSTALL:-0}" != "1" ]; then
  "$repository/node_modules/.bin/playwright" install chromium
fi

SCREENSHOT_DB_PORT="$database_port" \
  docker compose \
  -f "$compose_file" \
  -p "$compose_project" \
  up \
  -d \
  --wait

(
  cd "$content_dir"
  find . -type f -name '*.md' -print |
    LC_ALL=C sort |
    zip -q "$archive" -@
)

mkdir -p "$plugin_source/__screenshots/plugins"
: >"$plugin_list"
for manifest in "$plugins_dir"/*/plugin.yaml; do
  [ -f "$manifest" ] || continue

  plugin=$(basename "$(dirname "$manifest")")
  [ -f "$content_dir/extensions/$plugin.md" ] || continue

  preview="$plugins_dir/$plugin/preview.md"
  [ -f "$preview" ] || continue
  if [ -f "$plugins_dir/$plugin/preview.static.md" ]; then
    preview="$plugins_dir/$plugin/preview.static.md"
  fi

  cp "$preview" "$plugin_source/__screenshots/plugins/$plugin.md"
  printf '%s\n' "$plugin" >>"$plugin_list"

  if [ "$plugin" = "subpages" ]; then
    mkdir -p "$plugin_source/__screenshots/plugins/subpages"
    cat >"$plugin_source/__screenshots/plugins/subpages/getting-started.md" <<'PAGE'
# Getting started

Prepare the service and confirm access before making changes.
PAGE
    cat >"$plugin_source/__screenshots/plugins/subpages/operations.md" <<'PAGE'
# Operations

Day-two procedures for running the service safely.
PAGE
    cat >"$plugin_source/__screenshots/plugins/subpages/troubleshooting.md" <<'PAGE'
# Troubleshooting

Common symptoms, checks, and recovery steps.
PAGE
  fi
done

if [ ! -s "$plugin_list" ]; then
  echo "No plugin preview sources matched documentation pages under $content_dir/extensions." >&2
  exit 1
fi

printf '%s\n' "Building first-party plugin packages from $plugins_dir..."
make -C "$plugins_dir" build DIST="$plugin_dist"

while IFS= read -r plugin; do
  [ -n "$plugin" ] || continue
  version=$(sed -n 's/^version:[[:space:]]*//p' "$plugins_dir/$plugin/plugin.yaml" | head -n 1 | tr -d '"' | tr -d "'")
  package="$plugin_dist/$plugin-$version.kumbukaplugin"
  if [ ! -s "$package" ]; then
    echo "Plugin build did not produce $package" >&2
    exit 1
  fi
done <"$plugin_list"

(
  cd "$plugin_source"
  find . -type f -name '*.md' -print |
    LC_ALL=C sort |
    zip -q "$plugin_archive" -@
)

KUMBUKA__PLUGIN_UPDATE_CHECK_INTERVAL=0 \
  "$binary" \
  --listen-address="127.0.0.1:$screenshot_port" \
  --public-url="$base_url" \
  --database-url="postgres://kumbuka:kumbuka@127.0.0.1:$database_port/kumbuka?sslmode=disable" \
  --log-format=text >"$server_log" 2>&1 &
server_pid=$!

attempt=0
until curl --fail --silent "$base_url/healthz" >/dev/null; do
  attempt=$((attempt + 1))
  if [ "$attempt" -ge 60 ]; then
    echo "Kumbuka did not become healthy at $base_url" >&2
    exit 1
  fi
  sleep 0.25
done

SCREENSHOT_BASE_URL="$base_url" \
  SCREENSHOT_ARCHIVE="$archive" \
  SCREENSHOT_PLUGIN_ARCHIVE="$plugin_archive" \
  SCREENSHOT_PLUGIN_LIST="$plugin_list" \
  SCREENSHOT_PLUGIN_PACKAGES="$plugin_dist" \
  SCREENSHOT_PLUGINS_DIR="$plugins_dir" \
  SCREENSHOT_OUTPUT="$output" \
  SCREENSHOT_PLUGIN_OUTPUT="$plugin_output" \
  SCREENSHOT_EDITOR_SLUG="$editor_slug" \
  SCREENSHOT_VISITS="$visits" \
  SCREENSHOT_BROWSER_CHANNEL="${SCREENSHOT_BROWSER_CHANNEL:-}" \
  SCREENSHOT_DEVICE_SCALE_FACTOR="${SCREENSHOT_DEVICE_SCALE_FACTOR:-2}" \
  node "$repository/scripts/screenshots/capture.mjs"

printf '%s\n' "Application screenshots written to $output"
printf '%s\n' "Plugin previews written to $plugin_output"
