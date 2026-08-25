#!/usr/bin/env bash
# Health check for the AGA Fleet droplet
# Usage: ./scripts/status.sh <droplet-ip>

set -euo pipefail
DROPLET_IP="${1:?Usage: $0 <droplet-ip>}"

echo "=== Service status ==="
ssh aga@$DROPLET_IP "sudo systemctl status aga-hermes.service --no-pager -l | head -10"
echo
ssh aga@$DROPLET_IP "sudo systemctl status aga-memo.service --no-pager -l | head -10"
echo
echo "=== Pending actions queue ==="
ssh aga@$DROPLET_IP "sudo -u postgres psql -d aga_fleet -c \"SELECT bot_name, bucket, action_type, status, created_at FROM pending_actions ORDER BY created_at DESC LIMIT 20;\""
echo
echo "=== Recent run log ==="
ssh aga@$DROPLET_IP "sudo -u postgres psql -d aga_fleet -c \"SELECT bot_name, run_type, LEFT(summary, 80) AS summary, created_at FROM run_log ORDER BY created_at DESC LIMIT 20;\""
echo
echo "=== Memo vault size ==="
ssh aga@$DROPLET_IP "du -sh /opt/aga-fleet/memo-vault/* 2>/dev/null || echo 'vault empty'"
echo
echo "=== Disk / memory ==="
ssh aga@$DROPLET_IP "df -h / && echo && free -h"
