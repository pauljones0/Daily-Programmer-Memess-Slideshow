#!/usr/bin/env bash
set -euo pipefail

# Minimal Reddit top-image downloader (MVP)
# - Downloads top N non-NSFW images from r/ProgrammerHumor (top of day)
# - Intended to run on Windows using WSL or Git Bash
# - Configure with env vars: TOP_N, DEST_WIN_PATH, SUBREDDIT

TOP_N=${TOP_N:-5}
SUBREDDIT=${SUBREDDIT:-ProgrammerHumor}
# Default to a repo-relative downloads folder to avoid embedding user-specific paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
DEST_WIN_PATH=${DEST_WIN_PATH:-"$SCRIPT_DIR/../downloads"}
USER_AGENT=${USER_AGENT:-"meme-downloader:1.0 (by /u/anon)"}
TMP_JSON=$(mktemp)
count=0

err() { echo "ERROR: $*" >&2; exit 1; }
check_cmd() { command -v "$1" >/dev/null 2>&1 || err "Required command '$1' not found. Please install it."; }

# Check dependencies
check_cmd curl
check_cmd jq

convert_path() {
  local p="$1"
  # WSL: use wslpath
  if command -v wslpath >/dev/null 2>&1 && [[ "$p" =~ ^[A-Za-z]:\\ ]]; then
    wslpath -a "$p"
    return
  fi
  # Git Bash / MSYS: convert C:\ -> /c/
  if [[ "$p" =~ ^([A-Za-z]):\\ ]]; then
    local drive=$(echo "${BASH_REMATCH[1]}" | tr '[:upper:]' '[:lower:]')
    local tail=$(echo "$p" | sed -E 's#^[A-Za-z]:\\##; s#\\#/#g')
    echo "/$drive/$tail"
    return
  fi
  # assume posix path
  echo "$p"
}

DEST_DIR=$(convert_path "$DEST_WIN_PATH")
mkdir -p "$DEST_DIR"

echo "Downloading top $TOP_N non-NSFW images from r/$SUBREDDIT to: $DEST_DIR"

# fetch more than TOP_N to allow filtering out non-images / nsfw
LIMIT=$((TOP_N * 3))
URL="https://www.reddit.com/r/$SUBREDDIT/top/.json?sort=top&t=day&limit=$LIMIT"

curl -s -A "$USER_AGENT" "$URL" -o "$TMP_JSON"

# Stream over candidates, filter non-NSFW and image urls
jq -r '
  .data.children[] | .data
  | select(.over_18 == false)
  | {id: .id, url: (.url_overridden_by_dest // .url)}
  | select(.url != null)
  | "\(.id)\t\(.url)"
' "$TMP_JSON" | while IFS=$'\t' read -r id url; do
  # stop if we've already downloaded TOP_N
  if [ "$count" -ge "$TOP_N" ]; then break; fi

  # unescape common HTML entities
  url=$(echo "$url" | sed 's/&amp;/\&/g')

  # Only handle static images or direct reddit-hosted images for MVP
  if [[ "$url" =~ \.(jpg|jpeg|png|gif)(\?.*)?$ ]] || [[ "$url" == *"i.redd.it"* ]]; then
    filename=$(basename "${url%%\?*}")
    dest_file="$DEST_DIR/${id}_$filename"

    if [ -f "$dest_file" ]; then
      echo "Skipping existing: $dest_file"
      continue
    fi

    echo "Downloading: $url -> $dest_file"
    if curl -sL -o "$dest_file" "$url"; then
      count=$((count+1))
    else
      echo "Failed to download: $url" >&2
      rm -f "$dest_file" || true
    fi
  else
    echo "Skipping (not an image or unsupported host): $url"
  fi

done

rm -f "$TMP_JSON"

echo "Done. Downloaded $count images to: $DEST_DIR"

# Quick usage notes
# - To change defaults for a single run:
#   TOP_N=5 DEST_WIN_PATH='C:\Users\z00557ab\Downloads\desktop' ./download_reddit_memes.sh
# - On Windows Task Scheduler examples are provided in SCHEDULING.md

exit 0
