# Reddit Programmer Humor Meme Downloader

A tiny MVP that downloads the top 5 non-NSFW images from r/ProgrammerHumor (top of day) into your Windows downloads folder.

## What this repo contains ✅
- `scripts/download_reddit_memes.sh` — the single bash script that downloads the top images (MVP)
- `SCHEDULING.md` — short instructions for running the script daily on Windows (WSL or Git Bash)
- `README.md`, `LICENSE`, and `.gitignore` — minimal project metadata

## Quick start
1. Install dependencies (WSL/Ubuntu):
   `sudo apt update && sudo apt install -y curl jq`

2. Make the script executable and run it:
   `chmod +x scripts/download_reddit_memes.sh`
   `./scripts/download_reddit_memes.sh`

3. Optional: override defaults per-run:
   `TOP_N=5 DEST_WIN_PATH='./downloads' ./scripts/download_reddit_memes.sh`

Default: the script saves into `./downloads` (relative to the repo root) unless you set `DEST_WIN_PATH`.

See `SCHEDULING.md` for Task Scheduler examples to run this daily.

## License
MIT — see `LICENSE`.
