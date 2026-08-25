# Morning Playbook - AGA Fleet Stand-Up

Bob, this is your executable checklist for spinning up the fleet. Run top-to-bottom. Each step is either a single command or a URL to click. Timing estimates in brackets.

Total time to a running Zeus you can Telegram: **~45 minutes** if all credentials are ready. Add ~15 min if you need to fetch tokens.

---

## Step 1 - Install missing CLIs on your Mac [10 min]

Open Terminal.

```bash
# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add brew to PATH (Apple Silicon)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# CLIs
brew install doctl gh uv node
```

Verify:
```bash
doctl version && gh --version && uv --version && node --version
```

---

## Step 2 - SSH key [1 min]

```bash
ls ~/.ssh/id_ed25519 2>/dev/null || ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
cat ~/.ssh/id_ed25519.pub
```

Copy that public key output. You'll paste it into DO in the next step.

---

## Step 3 - Digital Ocean auth and SSH key upload [3 min]

```bash
doctl auth init
# Paste your DO API token from https://cloud.digitalocean.com/account/api/tokens
# (create one with Read + Write scope if you don't have one)

doctl compute ssh-key create aga-fleet-mac --public-key "$(cat ~/.ssh/id_ed25519.pub)"
```

---

## Step 4 - GitHub repo [3 min]

From the workspace:
```bash
cd /home/user/workspace/aga-fleet
gh auth login  # follow prompts, browser auth
gh repo create aga-fleet --private --source=. --remote=origin --push
```

Note the URL that comes back. You'll paste it into cloud-init in Step 5.

---

## Step 5 - Edit cloud-init with your GitHub username [1 min]

```bash
# Replace BOB_GH_USERNAME with your actual GitHub username
sed -i.bak "s|BOB_GH_USERNAME|<your-github-username>|g" /home/user/workspace/aga-fleet/deploy/cloud-init.yaml
```

---

## Step 6 - Create the droplet [3 min]

```bash
doctl compute droplet create aga-fleet-prod \
  --region nyc3 \
  --image ubuntu-24-04-x64 \
  --size s-2vcpu-4gb \
  --ssh-keys $(doctl compute ssh-key list --format ID --no-header | head -1) \
  --user-data-file /home/user/workspace/aga-fleet/deploy/cloud-init.yaml \
  --wait
```

Cost: **$24/mo** (2 vCPU / 4 GB RAM). Downsize to $12 (1 vCPU / 2 GB) after a week if the fleet is idle enough.

Grab the IP:
```bash
DROPLET_IP=$(doctl compute droplet list aga-fleet-prod --format PublicIPv4 --no-header)
echo "Droplet IP: $DROPLET_IP"
```

**Wait ~90 seconds** for cloud-init to finish. Verify:
```bash
ssh aga@$DROPLET_IP "tail -5 /var/log/cloud-init-output.log"
# Should show "AGA Fleet droplet provisioned."
```

---

## Step 7 - Fetch credentials [15 min if you need to gather them]

You'll need these ready for Step 8. Fetch each one from its source:

| Secret | Where to get it |
|---|---|
| `TELEGRAM_ZEUS_BOT_TOKEN` | Message [@BotFather](https://t.me/BotFather), `/mybots` → @AugustGraceAdvisory_Bot → API Token |
| `TELEGRAM_PRESSMASTER_BOT_TOKEN` | Same, for @CJ_PressMaster_... |
| `BOB_TELEGRAM_USER_ID` | Message [@userinfobot](https://t.me/userinfobot), copy the numeric ID |
| `COMPOSIO_API_KEY` | https://app.composio.dev/settings/api-keys |
| `NOTION_API_KEY` | https://www.notion.so/profile/integrations - if you don't have one, skip and Composio handles Notion |
| `ATTIO_API_KEY` | https://app.attio.com/settings/api-keys |
| `TODOIST_API_KEY` | https://app.todoist.com/app/settings/integrations/developer |
| `FIREFLIES_API_KEY` | https://app.fireflies.ai/integrations/custom/api |
| `GITHUB_PAT` | https://github.com/settings/tokens - Fine-grained, repo access to aga-fleet |
| `ANTHROPIC_API_KEY` | https://console.anthropic.com/settings/keys |
| `PERPLEXITY_API_KEY` | https://www.perplexity.ai/settings/api |

---

## Step 8 - Bootstrap [5 min]

```bash
cd /home/user/workspace/aga-fleet
bash deploy/bootstrap.sh $DROPLET_IP
```

Follow the prompts. Paste each secret when asked. Values are hidden as you type. The script will:
- Push .env to the droplet
- Set Postgres password
- Start Hermes and Memo services
- Print service status

---

## Step 9 - First Zeus interaction [1 min]

Open Telegram. Message **@AugustGraceAdvisory_Bot** with:

```
/start
```

Zeus should reply within 5 seconds:

> Zeus online. Fleet: 8 specialists ready, none dispatched yet. Bob, want a morning brief or a specific specialist?

If it doesn't reply within 30 seconds:

```bash
ssh aga@$DROPLET_IP "sudo journalctl -u aga-hermes.service -n 50 --no-pager"
```

Send me (Perplexity Computer) whatever that shows.

---

## Step 10 - Verify each specialist [5 min]

Message Zeus:

```
/roster
```

Zeus responds with:
```
✓ zeus (chief of staff, active)
✓ rbb-coo (project wooster - rbb systems)
✓ pike-coo (project pike - fishman corporation)
✓ co-orchestrator (curiously optimistic)
✓ cie-architect (commercial intelligence engine)
✓ capture-coo (project capture - clevios)
✓ network-intel (relationships / attio)
✓ hawken-family (family ops)
✓ dac-chair (uoa dac chairmanship)
```

Try a direct routing:
```
Ask pike-coo: what's the fernanda financial delivery status?
```

Zeus routes, pike-coo reads its Notion static SoT + Memo vault, replies through Zeus with the current gate.

---

## Step 11 - Wire Sloane's next 6:45am run to the new fleet [defer to Day 2]

The existing Sloane bot on Grok Bot keeps running at 6:45am ET. Do not turn it off yet. Let it run in parallel for one week. Compare its daily ops page to what Zeus produces at 6:30am. Cut over when they match.

---

## Rollback

If anything goes sideways:

```bash
doctl compute droplet delete aga-fleet-prod --force
```

Costs stop immediately. No lingering state on your Mac. The GitHub repo persists, so you can redeploy any time.

---

## What happens after

- **Every morning 6:30am ET:** Zeus texts you the fleet morning brief on @AugustGraceAdvisory_Bot
- **Every Friday 4pm ET:** Zeus runs the weekly promote loop, texts you a batch of Notion updates to confirm
- **All day:** specialists act in Bucket 1 silently, Bucket 2 with notification, Bucket 3 gated on you
- **Memo pilot:** unchanged, still on the Grok Bot computer until 2026-09-23 review. After review, if it holds, we route the droplet's fluid brain through Memo instead of the local vault

---

## What I need from you when you're up

Answer in your first message to me:

1. Confirm you want Zeus (I picked it; Apollo conflicts with the sponsor record)
2. Confirm @AugustGraceAdvisory_Bot as Zeus's Telegram surface
3. Full username of @CJ_PressMaster_... (truncated in your screenshot)
4. Any bucket-3 items I should hard-code before you touch the droplet (contacts, deals, rules I missed)

Everything else, I built or documented. Kick me if I got it wrong.
