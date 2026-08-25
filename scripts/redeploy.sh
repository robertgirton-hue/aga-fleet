#!/usr/bin/env bash
# Redeploy the fleet from scratch. Destroys droplet, recreates, bootstraps.
# The GitHub repo and Memo vault backups persist.
# Usage: ./scripts/redeploy.sh

set -euo pipefail

echo "==> Destroying current droplet"
doctl compute droplet delete aga-fleet-prod --force || true

echo "==> Waiting 30s for release"
sleep 30

echo "==> Recreating droplet from cloud-init"
doctl compute droplet create aga-fleet-prod \
  --region nyc3 \
  --image ubuntu-24-04-x64 \
  --size s-2vcpu-4gb \
  --ssh-keys $(doctl compute ssh-key list --format ID --no-header | head -1) \
  --user-data-file "$(dirname "$0")/../deploy/cloud-init.yaml" \
  --wait

DROPLET_IP=$(doctl compute droplet list aga-fleet-prod --format PublicIPv4 --no-header)
echo "==> New droplet IP: $DROPLET_IP"

echo "==> Waiting 90s for cloud-init"
sleep 90

echo "==> Running bootstrap"
bash "$(dirname "$0")/../deploy/bootstrap.sh" "$DROPLET_IP"

echo "==> Redeploy complete."
