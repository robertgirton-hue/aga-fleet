#!/usr/bin/env bash
# Nightly backup of the Memo vault from droplet to Bob's OneDrive
# Runs on the droplet via cron; commit-pushes the vault snapshot to a private aga-memo-backup repo
# Usage (from droplet cron): /opt/aga-fleet/scripts/backup-memo.sh

set -euo pipefail

VAULT=/opt/aga-fleet/memo-vault
BACKUP_REPO=/opt/aga-fleet/memo-backup

cd "$BACKUP_REPO"
rsync -a --delete "$VAULT/" "$BACKUP_REPO/vault/"
git add -A
if git diff --staged --quiet; then
  echo "no changes"
else
  git commit -m "vault snapshot $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  git push origin main
fi
