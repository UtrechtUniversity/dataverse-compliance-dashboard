#!/usr/bin/env sh
set -eu

# Minimal helper for running the Dataverse metadata crawler manually.
# The exact CLI flags may differ depending on how the crawler is installed, 
# so treat this script as a documented starting point rather than a fixed guaranteed command.

REPO_ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
TOKEN_FILE="$REPO_ROOT/TOKEN.txt"
RAW_DIR="$REPO_ROOT/data/raw"

BASE_URL="${BASE_URL:-https://dataverse.nl}"
ROOT_DATAVERSE="${ROOT_DATAVERSE:-UU}"
DATASET_VERSION="${DATASET_VERSION:-latest}"
CRAWLER_DIR="${CRAWLER_DIR:-$(dirname "$REPO_ROOT")/dataverse-metadata-crawler}"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
RAW_JSON="$RAW_DIR/dataverse-uu-${TIMESTAMP}.json"

mkdir -p "$RAW_DIR"

if [ ! -f "$TOKEN_FILE" ]; then
  echo "Missing $TOKEN_FILE"
  echo "Create TOKEN.txt in the repository root and paste your Dataverse API token into it."
  exit 1
fi

API_TOKEN=$(tr -d '\r\n' < "$TOKEN_FILE")

if [ -z "$API_TOKEN" ]; then
  echo "TOKEN.txt exists but is empty."
  exit 1
fi

echo "Raw output directory: $RAW_DIR"
echo "Base URL: $BASE_URL"
echo "Target Dataverse: $ROOT_DATAVERSE"
echo "Planned raw JSON file: $RAW_JSON"
echo

WORK_DIR=$(mktemp -d "${TMPDIR:-/tmp}/dataverse-crawler.XXXXXX")
cleanup() {
  rm -rf "$WORK_DIR"
}
trap cleanup EXIT HUP INT TERM

find_dvmeta_bin() {
  if [ -x "$CRAWLER_DIR/.venv/Scripts/dvmeta.exe" ]; then
    printf '%s\n' "$CRAWLER_DIR/.venv/Scripts/dvmeta.exe"
  elif [ -x "$CRAWLER_DIR/.venv/bin/dvmeta" ]; then
    printf '%s\n' "$CRAWLER_DIR/.venv/bin/dvmeta"
  elif command -v dvmeta >/dev/null 2>&1; then
    command -v dvmeta
  fi
}

DVMETA_BIN=$(find_dvmeta_bin || true)

run_crawler() {
  # Using "run-all" rather than "crawl-metadata" on its own: upstream's
  # crawl-metadata command asserts state.crawler is set before it checks
  # whether it needs to auto-run search, so calling it standalone always
  # fails with AssertionError. run-all runs search first in the same
  # process, avoiding that bug, and still writes the same ds_metadata_*.json.
  BASE_URL="$BASE_URL" API_TOKEN="$API_TOKEN" "$DVMETA_BIN" \
    -c "$ROOT_DATAVERSE" -v "$DATASET_VERSION" -a "$API_TOKEN" run-all
}

if [ -n "$DVMETA_BIN" ]; then
  echo "Running dvmeta: $DVMETA_BIN"
  echo

  (
    cd "$WORK_DIR"
    run_crawler
  )

  CRAWLER_JSON=$(find "$WORK_DIR/exported_files/json_files" -name 'ds_metadata_*.json' -type f | sort | tail -n 1)
  if [ -z "$CRAWLER_JSON" ]; then
    echo "Crawler completed but no ds_metadata JSON file was found."
    exit 1
  fi

  cp "$CRAWLER_JSON" "$RAW_JSON"
  echo "Wrote $RAW_JSON"
else
  echo "Could not find a dvmeta executable."
  echo
  echo "Next steps:"
  echo "1. Clone https://github.com/scholarsportal/dataverse-metadata-crawler"
  echo "   (expected by default at: $CRAWLER_DIR)"
  echo "2. Run 'uv sync' inside that clone to create its .venv."
  echo "3. Re-run this helper, or set CRAWLER_DIR to point at a different clone."
  echo
  echo "Example command shape:"
  echo "CRAWLER_DIR=/path/to/dataverse-metadata-crawler sh scripts/run_crawler.sh"
fi
