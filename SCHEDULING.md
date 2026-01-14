Scheduling notes (Windows 11)

Two easy ways to run the bash script once per day on Windows:

1) Git Bash (recommended if you have Git for Windows)
- Place `download_reddit_memes.sh` in the repository root and convert path to MSYS style if needed (the script handles common Windows paths).
- Task Scheduler example (create a daily task):
  - Program/script: "C:\Program Files\Git\bin\bash.exe"
  - Add arguments: -lc "/c/Users/<you>/path/to/repo/download_reddit_memes.sh"

2) WSL (recommended if you use WSL)
- Put the script in your WSL home or make sure the Windows path is accessible via WSL.
- Example schtasks command (run as Administrator):
  schtasks /Create /SC DAILY /TN "DownloadRedditMemes" /TR "wsl -u <yourlinuxuser> bash -lc '/home/<yourlinuxuser>/download_reddit_memes.sh'" /ST 09:00

Testing
- Run the script once manually to confirm: 
  - In Git Bash: `./download_reddit_memes.sh`
  - In WSL: `bash ./download_reddit_memes.sh`

Dependencies
- The script requires `curl` and `jq`:
  - WSL (Ubuntu): `sudo apt install curl jq`
  - Git Bash: install `jq` via chocolatey or manually, curl usually available

Notes
- The script intentionally only downloads direct image links (jpg/png/gif) and excludes NSFW posts.
- If you want GIF/video support or gallery handling, I can extend the script.
