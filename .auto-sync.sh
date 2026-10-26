#!/usr/bin/env bash
# Git auto pull & push

REPO="/home/linqin/plankton1205.github.io"
BRANCH="main"
LOG="$HOME/.auto-sync.log"

notify() {
  echo "[$(date '+%F %T')] $1" >> "$LOG"
  notify-send "Git 同步" "$1" 2>/dev/null
}

cd "$REPO" || { notify "cannot find the local git repository: $REPO"; exit 1; }

# 1. commit all local change
if [[ -n "$(git status --porcelain)" ]]; then
  git add .
  git commit -m "auto update" >> "$LOG" 2>&1 || { notify "commit failed, check log for detail: $LOG"; exit 1; }
fi

# 2. pull all remote change
if ! git pull --rebase origin "$BRANCH" >> "$LOG" 2>&1; then
  conflicts=$(git diff --name-only --diff-filter=U | paste -sd ',' -)
  git rebase --abort >/dev/null 2>&1
  if [[ -n "$conflicts" ]]; then
    notify "conflict files: $conflicts"
  else
    notify "pull failed, check log for detail: $LOG"
  fi
  exit 1
fi

# 3. push all local change
if ! git push origin "$BRANCH" >> "$LOG" 2>&1; then
  notify "push failed, check log for detail: $LOG"
  exit 1
fi

echo "[$(date '+%F %T')] auto sync completed." >> "$LOG"
