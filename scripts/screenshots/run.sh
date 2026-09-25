#!/bin/sh
set -eu

usage() {
  cat <<'USAGE'
Usage: scripts/screenshots/run.sh --binary FILE --content DIR --output DIR --editor-slug SLUG [--visits PATHS]

PATHS is a comma-separated list of application paths to visit before the dashboard capture.
USAGE
}

repository=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
compose_file="$repository/scripts/screenshots/compose.yaml"
binary=""
content_dir=""
output=""
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
  --output)
    [ "$#" -ge 2 ] || {
      usage >&2
      exit 2
    }
    output=$2
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
[ -n "$output" ] || {
  echo "--output is required" >&2
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

case "$output" in
/*) ;;
*) output="$PWD/$output" ;;
esac

[ -x "$binary" ] || {
  echo "Kumbuka binary not found or not executable: $binary" >&2
  exit 1
}
[ -d "$content_dir" ] || {
  echo "Screenshot content directory not found: $content_dir" >&2
  exit 1
}
[ -x "$repository/node_modules/.bin/playwright" ] || {
  echo "Playwright is not installed. Run npm ci in the docs repository." >&2
  exit 1
}

work_dir=$(mktemp -d "${TMPDIR:-/tmp}/kumbuka-screenshots.XXXXXX")
archive="$work_dir/content.zip"
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
    sed -n '1,200p' "$server_log" >&2
  fi

  rm -rf "$work_dir"
  exit "$status"
}
trap cleanup EXIT INT TERM

mkdir -p "$output"
rm -f "$output"/*.png

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
  SCREENSHOT_OUTPUT="$output" \
  SCREENSHOT_EDITOR_SLUG="$editor_slug" \
  SCREENSHOT_VISITS="$visits" \
  SCREENSHOT_BROWSER_CHANNEL="${SCREENSHOT_BROWSER_CHANNEL:-}" \
  node "$repository/scripts/screenshots/capture.mjs"

printf '%s\n' "Screenshots written to $output"
