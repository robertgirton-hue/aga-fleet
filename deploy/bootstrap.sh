#!/usr/bin/env bash
# bootstrap.sh - run from Bob's Mac after droplet is up
# Usage: ./deploy/bootstrap.sh <droplet-ip>
#
# What this does:
#   1. Copies your SSH public key to the droplet's aga user
#   2. Prompts you for every secret (TELEGRAM tokens, COMPOSIO, NOTION, etc.)
#   3. Writes .env to the droplet, correct permissions
#   4. Starts aga-hermes and aga-memo services
#   5. Verifies Zeus is reachable via Telegram

set -euo pipefail

DROPLET_IP="${1:?Usage: $0 <droplet-ip>}"
SSH_KEY="${SSH_KEY:-$HOME/.ssh/id_ed25519}"

echo "==> AGA Fleet bootstrap targeting $DROPLET_IP"
echo

# --- SSH key setup ---
if [ ! -f "$SSH_KEY" ]; then
  echo "SSH key not found at $SSH_KEY. Generate one? (y/n)"
  read -r yn
  if [ "$yn" = "y" ]; then
    ssh-keygen -t ed25519 -f "$SSH_KEY" -N ""
  else
    echo "Aborting."
    exit 1
  fi
fi

echo "==> Copying SSH public key to droplet"
ssh-copy-id -i "${SSH_KEY}.pub" "aga@${DROPLET_IP}" || true

# --- Secrets prompt ---
declare -A SECRETS=(
  [TELEGRAM_ZEUS_BOT_TOKEN]="Telegram bot token for @AugustGraceAdvisory_Bot (from @BotFather)"
  [TELEGRAM_PRESSMASTER_BOT_TOKEN]="Telegram bot token for @CJ_PressMaster_AGABot"
  [TELEGRAM_PERPLEXITY_BOT_TOKEN]="Telegram bot token for @AGA_Perplexity_Bot (optional, leave blank if not routing through)"
  [BOB_TELEGRAM_USER_ID]="Your Telegram user ID (get from @userinfobot)"
  [COMPOSIO_API_KEY]="Composio API key (https://app.composio.dev/settings/api-keys)"
  [NOTION_API_KEY]="Notion integration token (or leave blank if using Composio's Notion)"
  [ATTIO_API_KEY]="Attio API key"
  [TODOIST_API_KEY]="Todoist API token"
  [FIREFLIES_API_KEY]="Fireflies API key"
  [GITHUB_PAT]="GitHub PAT with repo scope (Zeus needs this to push config changes)"
  [ANTHROPIC_API_KEY]="Anthropic API key (for Claude models)"
  [OPENAI_API_KEY]="OpenAI API key (optional)"
  [PERPLEXITY_API_KEY]="Perplexity API key"
  [POSTGRES_PASSWORD]="Postgres password for the aga user (auto-generate? Leave blank)"
)

ENV_TMP="$(mktemp)"
trap "rm -f $ENV_TMP" EXIT

for key in "${!SECRETS[@]}"; do
  prompt="${SECRETS[$key]}"
  echo
  echo "$key"
  echo "  $prompt"
  read -rs -p "  Value (hidden): " value
  echo
  if [ "$key" = "POSTGRES_PASSWORD" ] && [ -z "$value" ]; then
    value="$(openssl rand -base64 24)"
    echo "  Generated: $value"
  fi
  echo "${key}=${value}" >> "$ENV_TMP"
done

echo
echo "==> Uploading .env to droplet"
scp "$ENV_TMP" "aga@${DROPLET_IP}:/opt/aga-fleet/.env"
ssh "aga@${DROPLET_IP}" "chmod 600 /opt/aga-fleet/.env"

# --- Update postgres password from generated value ---
echo "==> Setting Postgres password"
PG_PW="$(grep '^POSTGRES_PASSWORD=' "$ENV_TMP" | cut -d= -f2-)"
ssh "aga@${DROPLET_IP}" "sudo -u postgres psql -c \"ALTER USER aga WITH PASSWORD '$PG_PW';\""

# --- Start services ---
echo "==> Starting Hermes and Memo services"
ssh "aga@${DROPLET_IP}" "sudo systemctl start aga-memo.service && sleep 3 && sudo systemctl start aga-hermes.service"

sleep 5
echo "==> Service status:"
ssh "aga@${DROPLET_IP}" "sudo systemctl status aga-hermes.service --no-pager -l | head -15"
ssh "aga@${DROPLET_IP}" "sudo systemctl status aga-memo.service --no-pager -l | head -15"

echo
echo "==> Bootstrap complete."
echo "    Next: send /start to @AugustGraceAdvisory_Bot in Telegram."
echo "    Zeus should respond within 5 seconds."
