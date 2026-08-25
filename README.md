# aga-fleet

The August Grace Advisory bot fleet — nine specialist bots plus one Chief of Staff, running on a Digital Ocean droplet, orchestrated by Hermes, glued together by Composio, with Memo as fluid brain and Notion as static source of truth.

## Architecture

```
                        ┌─────────────────────────────┐
                        │        Bob (Telegram)       │
                        └──────────────┬──────────────┘
                                       │
                                       ▼
                        ┌─────────────────────────────┐
                        │   Zeus - Chief of Staff     │
                        │   (routes, aggregates,      │
                        │    pushes config changes)   │
                        └──────────────┬──────────────┘
                                       │
      ┌────────────────┬───────────────┼───────────────┬────────────────┐
      ▼                ▼               ▼               ▼                ▼
  ┌────────┐      ┌────────┐     ┌────────┐     ┌────────┐     ┌────────┐
  │RBB COO │      │Pike COO│     │  CO    │     │  CIE   │     │Capture │
  │        │      │        │     │Orch    │     │Architect│     │ COO   │
  └────────┘      └────────┘     └────────┘     └────────┘     └────────┘
  ┌────────┐      ┌────────┐     ┌────────┐
  │Network │      │Hawken  │     │  DAC   │
  │Intel   │      │Family  │     │ Chair  │
  └────────┘      └────────┘     └────────┘

                          │
                          ▼
              ┌───────────────────────┐
              │   Memo (fluid brain)  │
              │  local vault + SQLite │
              │      + light graph    │
              └───────────┬───────────┘
                          │  weekly promote
                          ▼
              ┌───────────────────────┐
              │  Notion + OneDrive    │
              │   (static SoT)        │
              └───────────────────────┘
```

## The nine bots

1. **Zeus** — Chief of Staff. Bob's primary interface. Routes, aggregates, applies config changes.
2. **RBB COO** — Wooster/RBB Systems deal execution
3. **Pike COO** — Fishman/Pike deal execution
4. **CO Orchestrator** — Curiously Optimistic newsletter publishing
5. **CIE Architect** — Commercial Intelligence Engine builds
6. **Capture COO** — Clevios/Heraeus strategic evaluation
7. **Network Intel** — Penny's function: relationships, warm intros, Attio hygiene
8. **Hawken Family** — Ava/Aggie/Theo school ops, family calendar
9. **DAC Chair** — University of Akron Dean's Advisory Council

## Decision autonomy

See `policies/decision-autonomy.md`. Three-bucket model based on **material × reversible**. Bots act in buckets 1 and 2. Bucket 3 drafts and waits for Bob via Zeus.

## Memory model

- **Fluid brain**: Memo (`jagoff/memo`), running on the droplet at `/opt/aga-fleet/memo-vault/`. Bots read/write in seconds. Local markdown + SQLite + light graph + MCP.
- **Static SoT**: Notion + OneDrive `_CONTEXT.md`. Humans edit. Bots read canonical, promote to canonical only via the weekly loop.
- **Weekly promote**: Friday. Zeus proposes deltas, Bob confirms, changes land in Notion.

## Nomenclature

All bot names, deal titles, and pillar refs follow `policies/nomenclature.md` (mirror of the Notion Nomenclature Standard). No em dashes anywhere. Plain hyphen with spaces.

## Deploy

```
./deploy/bootstrap.sh          # from Bob's Mac, provisions droplet
./deploy/deploy-fleet.sh       # deploys bots to droplet
./scripts/status.sh            # health check
```

See `MORNING-PLAYBOOK.md` for the exact sequence Bob runs.
