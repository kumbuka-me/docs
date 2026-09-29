#!/bin/sh
set -eu

usage() {
  cat <<'USAGE'
Usage: scripts/screenshots/run.sh --repository DIR --binary FILE --kumbuka-version VERSION --content DIR --output DIR --plugin-output DIR --plugin-cache DIR --editor-slug SLUG [--visits PATHS]

PATHS is a comma-separated list of application paths to visit before the dashboard capture.
USAGE
}

repository=""
binary=""
kumbuka_version=""
content_dir=""
output=""
plugin_output=""
plugin_cache=""
editor_slug=""
visits=""

while [ "$#" -gt 0 ]; do
  case "$1" in
  --repository)
    [ "$#" -ge 2 ] || { usage >&2; exit 2; }
    repository=$2
    shift 2
    ;;
  --binary)
    [ "$#" -ge 2 ] || { usage >&2; exit 2; }
    binary=$2
    shift 2
    ;;
  --kumbuka-version)
    [ "$#" -ge 2 ] || { usage >&2; exit 2; }
    kumbuka_version=$2
    shift 2
    ;;
  --content)
    [ "$#" -ge 2 ] || { usage >&2; exit 2; }
    content_dir=$2
    shift 2
    ;;
  --output)
    [ "$#" -ge 2 ] || { usage >&2; exit 2; }
    output=$2
    shift 2
    ;;
  --plugin-output)
    [ "$#" -ge 2 ] || { usage >&2; exit 2; }
    plugin_output=$2
    shift 2
    ;;
  --plugin-cache)
    [ "$#" -ge 2 ] || { usage >&2; exit 2; }
    plugin_cache=$2
    shift 2
    ;;
  --editor-slug)
    [ "$#" -ge 2 ] || { usage >&2; exit 2; }
    editor_slug=$2
    shift 2
    ;;
  --visits)
    [ "$#" -ge 2 ] || { usage >&2; exit 2; }
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

[ -n "$repository" ] || { echo "--repository is required" >&2; exit 2; }
[ -n "$binary" ] || { echo "--binary is required" >&2; exit 2; }
[ -n "$kumbuka_version" ] || { echo "--kumbuka-version is required" >&2; exit 2; }
[ -n "$content_dir" ] || { echo "--content is required" >&2; exit 2; }
[ -n "$output" ] || { echo "--output is required" >&2; exit 2; }
[ -n "$plugin_output" ] || { echo "--plugin-output is required" >&2; exit 2; }
[ -n "$plugin_cache" ] || { echo "--plugin-cache is required" >&2; exit 2; }
[ -n "$editor_slug" ] || { echo "--editor-slug is required" >&2; exit 2; }

[ -d "$repository" ] || { echo "Repository directory not found: $repository" >&2; exit 1; }
[ -x "$binary" ] || { echo "Kumbuka binary not found or not executable: $binary" >&2; exit 1; }
[ -d "$content_dir" ] || { echo "Screenshot content directory not found: $content_dir" >&2; exit 1; }
[ -x "$repository/node_modules/.bin/playwright" ] || {
  echo "Playwright is not installed. Run npm ci in the docs repository." >&2
  exit 1
}

compose_file="$repository/scripts/screenshots/compose.yaml"
prepare_script="$repository/scripts/screenshots/prepare.py"
capture_script="$repository/scripts/screenshots/capture.mjs"
plugin_download="$repository/scripts/screenshots/download-plugins.sh"

[ -f "$compose_file" ] || { echo "Screenshot compose file not found: $compose_file" >&2; exit 1; }
[ -x "$prepare_script" ] || { echo "Screenshot prepare script not found: $prepare_script" >&2; exit 1; }
[ -f "$capture_script" ] || { echo "Screenshot capture script not found: $capture_script" >&2; exit 1; }
[ -x "$plugin_download" ] || { echo "Plugin download script not found: $plugin_download" >&2; exit 1; }

work_dir=$(mktemp -d "${TMPDIR:-/tmp}/kumbuka-screenshots.XXXXXX")
archive="$work_dir/content.zip"
plugin_archive="$work_dir/plugin-previews.zip"
plugin_lock="$work_dir/plugins.lock"
plugin_packages="$plugin_cache"
plugin_metadata="$work_dir/plugins.json"
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

mkdir -p "$output" "$plugin_output" "$plugin_packages"
rm -f "$output"/*.png
find "$plugin_output" -mindepth 2 -maxdepth 2 -type f -name 'preview.png' -delete 2>/dev/null || true

if [ "${SCREENSHOT_SKIP_BROWSER_INSTALL:-0}" != "1" ]; then
  "$repository/node_modules/.bin/playwright" install chromium
fi

python3 "$prepare_script" content \
  --source "$content_dir" \
  --output "$archive"

python3 "$prepare_script" lock \
  --kumbuka-version "$kumbuka_version" \
  --output "$plugin_lock"

printf '%s\n' "Syncing first-party plugins pinned by Kumbuka $kumbuka_version..."
"$plugin_download" \
  --plugin-lock "$plugin_lock" \
  --destination "$plugin_packages" \
  --plugin-repository kumbuka-me/plugins

python3 "$prepare_script" plugins \
  --plugin-lock "$plugin_lock" \
  --packages "$plugin_packages" \
  --content "$content_dir" \
  --archive "$plugin_archive" \
  --metadata "$plugin_metadata"

SCREENSHOT_DB_PORT="$database_port" \
  docker compose \
  -f "$compose_file" \
  -p "$compose_project" \
  up \
  -d \
  --wait

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
  SCREENSHOT_PLUGIN_METADATA="$plugin_metadata" \
  SCREENSHOT_OUTPUT="$output" \
  SCREENSHOT_PLUGIN_OUTPUT="$plugin_output" \
  SCREENSHOT_EDITOR_SLUG="$editor_slug" \
  SCREENSHOT_VISITS="$visits" \
  SCREENSHOT_BROWSER_CHANNEL="${SCREENSHOT_BROWSER_CHANNEL:-}" \
  SCREENSHOT_DEVICE_SCALE_FACTOR="${SCREENSHOT_DEVICE_SCALE_FACTOR:-2}" \
  node "$capture_script"

printf '%s\n' "Application screenshots written to $output"
printf '%s\n' "Plugin previews written to $plugin_output"
