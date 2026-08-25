# Composio wiring

Composio is the connector layer between the bots and the outside world (Notion, OneDrive, Attio, Todoist, Gmail, Outlook, Google Calendar, Fireflies, GitHub, Telegram).

## Setup on the droplet

Bootstrap.sh pastes `COMPOSIO_API_KEY` into `/opt/aga-fleet/.env`. Hermes loads it and passes it to each bot's Composio client.

## Per-bot toolkit

Each bot's `config.yaml` declares which connectors it needs and at what permission level (`read_only`, `read_write`, `draft_only`, `read_write_via_zeus`).

- `read_only` — bot can read, cannot write
- `read_write` — bot can read and write (subject to buckets)
- `draft_only` — bot can create drafts but not send/publish
- `read_write_via_zeus` — bot proposes writes to Zeus; Zeus executes on Bucket 2/3 resolution

## Composio auth flow

First run of each bot triggers OAuth for the tools it declares. Zeus handles the OAuth callback via a temporary droplet-local URL. Bob approves each connector once per bot per service.

## Rate limits (as of 2026-08-25)

- Free tier: 20K tool calls/month (or 100K depending on source - verify)
- Pro: $29/mo, higher limits
- Serious Business: $229/mo, no fleet-scale limits

At 9 bots × modest cadence, Pro is likely sufficient. Monitor via Composio dashboard.

## Fallback

If Composio quota exhausts or a connector breaks, each bot has a documented fallback path to Bob's Mac via `pc` (comet-bridge). Zeus can execute a `pc bash` or `pc files read` command as a last-resort human-in-the-loop.
