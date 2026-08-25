# Nomenclature (fleet mirror of the Notion Nomenclature Standard)

Canonical source: [AGA Nomenclature Standard](https://app.notion.com/p/3b16a2e785d181e380a4e4074c9c3d5a) in Notion. This file is a working mirror the bots load into their system context. When the Notion page changes, this file updates via the weekly promote.

## Pillar labels (canonical, ratified 2026-08-23)

Bots use these exact strings when writing to any DB, filename, or communication:

- `A - Deal Advisory`
- `B1 - Growth Execution`
- `B2 - Growth Lab`
- `C - Effective Team`
- `D - AI & Digital`
- `E - Investing`
- `F - Board Role`

Legacy values (`A - M&A`, `B - Growth`, `D - AI & Digitization`, `E - Invest`, `Pillar A - Deals`, no-space `A-Deals`) are dead. Do not emit them.

## Deal / project naming

- **Codenamed deals**: `Project X - Company` (e.g., `Project Pike - Fishman Corporation`).
- **Company-only deals**: drop legal suffix (`, Inc.`, `LLC`) unless needed to disambiguate.
- **Casing**: title case, not all-caps (`Project Pike`, not `Project PIKE`).
- **One dash character only**: plain hyphen with spaces (` - `). No em dashes (`—`), no en dashes (`–`).

## Sponsor naming

- Title = common firm name, **no legal suffix**. `American Securities`, not `American Securities LLC`. `Apollo`, not `Apollo Global Management`.
- One record per firm. Duplicate `36a6a2e7...` enrichment records are subordinate to graded records.

## Cross-DB canonical names (partial — expand as needed)

- Heraeus deal: `Project Capture - Clevios (Heraeus Epurio)`
- Wooster: `Project Wooster - RBB Systems`
- Pike: `Project Pike - Fishman Corporation`

## House style

- **No em dashes.** Anywhere. Ever. Use ` - `.
- **No exclamation points** in bot-generated messages to Bob.
- **No emojis** unless Bob explicitly asks or the format requires them (e.g., 🔴🟡🟢 status flags in Sloane-style daily ops pages).
- **Concise.** Bob reads on his phone between calls. If a message is longer than 6 lines, it needs a TL;DR at the top.
