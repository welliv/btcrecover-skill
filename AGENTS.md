# AGENTS

This file enables BTCRecover-skill compatibility with AI coding agents. It is consumed automatically by Claude Code, GitHub Copilot, Cline, and other agents that support AGENTS.md.

## Purpose

The primary skill definition is in [SKILL.md](SKILL.md). This file tells agents to look there.

## Agent Setup

**Claude Code**: Run `claude` from the btcrecover checkout directory. SKILL.md is auto-picked.

**Cline** (VS Code): Place the btcrecover-skill directory in your workspace. Cline reads SKILL.md from the project root.

**GitHub Copilot**: Open the btcrecover-skill directory in VS Code. Copilot Chat uses SKILL.md for context.

**Manual / Other agents**: Paste the contents of SKILL.md as the first message or system prompt.

## Related

- [SKILL.md](SKILL.md) — Main skill definition
- [PROJECT.md](PROJECT.md) — Project overview and manifest
