# Tier Handling Guidelines

This document captures the design decisions for the Three-Tier security model in btcrecover-skill.

## Core Principles

- Tier 2 is the recommended default for most users.
- Always present the full tier comparison table before asking the user to choose.
- Keep Tier 1 support lightweight (verification only).
- Do not expand the skill into AI infrastructure automation (Ollama installation, network control, etc.).

## Tier 1 Approach

- Use `scripts/tier1-check.sh` for readiness verification.
- Provide documentation in `docs/tier1-setup.md`.
- Never auto-install models or kill network access from within the skill.

## Files

- `scripts/tier1-check.sh` — Lightweight offline + local model checker
- `docs/tier1-setup.md` — User-facing Ollama setup instructions