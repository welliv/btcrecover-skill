# btcrecover-skill Design

Technical blueprint for contributors.

## Architecture

The skill uses four-stage progressive disclosure:

**L1** — Name and description in system prompt (~80 tokens). Agent knows the skill exists.

**L2** — Main orchestrator (SKILL.md). Loaded when user describes a recovery situation.

**L3** — Subskills loaded per recovery type (password, seed, forensics).

**L4** — References and scripts loaded on demand.

## Flow

User describes situation → Consent gate → Verify btcrecover → Check connectivity → Model recommendation → Problem classification → Subskill routing → btcrecover command generation → User approval → Run → Report → Post-recovery safety → Session destruction.

## Security

Three tiers of isolation. Advisor-not-actor architecture: the skill generates commands, the user runs them. Consent gates at every decision point.

## Extending

Add new wallet types to `references/wallet-types.md`. Add new models to `references/benchmarks.json`. Submit community benchmarks via GitHub Discussions.