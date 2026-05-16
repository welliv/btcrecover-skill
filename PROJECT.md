# btcrecover-skill

The AI layer that makes Bitcoin wallet recovery accessible to everyone.

Built on btcrecover by 3rdIteration. Free and open source. Always.

---

## Summary

This skill provides safe, guided recovery for lost Bitcoin wallets using btcrecover. It supports two security tiers, handles password, seed, and hybrid scenarios, and includes post-recovery sweeping and session cleanup.

It is designed for both technical and non-technical users. The skill never executes commands itself. It only generates guidance and commands for the user to run.

---

## Security Model — Two Tiers Only

**Tier 1 — Fully Offline**  
Everything runs locally with a local model. No data leaves the machine. Recommended for high-value wallets.

**Tier 2 — Local Agent + Cloud Reasoning (recommended)**  
The skill runs on your machine. The cloud API receives only text prompts. Wallet files, seeds, and btcrecover execution stay local. Requires explicit consent.

---

## Core Flow

1. Consent and tier selection
2. Quick classification of the recovery type
3. Model recommendation based on benchmarks
4. Pre-flight checks
5. Command generation and preview
6. User executes the command
7. Post-recovery sweeping and session destruction

For complex cases the skill can load sub-skills (password, seed, forensics) and delegate work.

---

## What the Skill Actually Covers

- Password recovery with typo patterns and tokenlists
- Seed recovery (missing words, wrong words, scrambled seeds)
- Hybrid recovery (known seed + partial passphrase)
- Basic forensics and file archaeology
- Two-tier security enforcement
- Wargame scoring and battle testing
- Post-recovery safety protocol

Forensics and advanced wallet formats have partial coverage. They are handled in dedicated sub-skills.

---

## Current Status

Independently verified across 35 recovery scenarios covering 11 blockchains and 9 wallet types. See docs/verified-recoveries.md.

Core password, seed, and hybrid flows are reliable. Forensics is functional but less mature.

The skill follows simplified British English, avoids redundancy, and prefers decisive one-pass action.

---

## Key Files

- `SKILL.md` — Main orchestrator
- `SECURITY.md` — Security principles
- `references/hybrid-recovery.md` — Exact command templates
- `references/safety-rules.md` — Safety rules loaded every session
- `scripts/verify-btcrecover.sh` — Installation integrity check
- `scripts/connectivity-check.sh` — Two-tier connectivity gate
- `scripts/nuke-session.sh` — Post-recovery cleanup

---

Free. Open source. Always.
