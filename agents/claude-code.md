# Claude Code Setup Guide — btcrecover skill

This guide explains how to install and use the btcrecover skill with
Claude Code, Anthropic's official terminal coding agent.

---

## Installation

### Option 1 — Verified installer (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/[yourusername]/btcrecover-skill/main/install.sh | bash
```

The installer auto-detects Claude Code's skills directory (`~/.claude/skills/`)
and installs there by default.

### Option 2 — npx (via skills.sh)

```bash
npx skills add [yourusername]/btcrecover-skill
```

### Option 3 — Manual

```bash
git clone https://github.com/[yourusername]/btcrecover-skill
cp -r btcrecover-skill ~/.claude/skills/
chmod +x ~/.claude/skills/btcrecover-skill/scripts/*.sh
```

Skills directories in Claude Code:

| Scope | Path | Use case |
|---|---|---|
| Global (all projects) | `~/.claude/skills/` | Recommended for this skill |
| Project-level | `.claude/skills/` | Shared with team via git |

---

## Triggering the skill

Start Claude Code and describe your situation in natural language:

```
claude
> I had some Bitcoin from 2016 in an Electrum wallet. I forgot the
  password but I remember it had my dog's name in it.
```

Or explicitly:
```
> Use the btcrecover skill to help me recover my wallet.
```

---

## Security notes for Claude Code

Claude Code runs on your machine. When using it with this skill:

**For Tier 1 (fully offline) recovery:**
- Disconnect from the internet before starting
- Claude Code will use its local context — no API call is made for
  each message in offline mode
- The connectivity gate in the skill will confirm you are offline

**For Tier 2 (Claude API + local btcrecover):**
- Claude Code's normal mode: calls the Anthropic API for reasoning
- Your wallet file, seed phrase, and keys are processed locally by
  btcrecover — they are never sent to the API
- The skill generates commands; you run them in Claude Code's terminal

**Model selection in Claude Code:**
```bash
# Use the best model for forensics recovery
claude --model claude-opus-4-6

# Use the faster model for password recovery
claude --model claude-sonnet-4-6
```

---

## Useful Claude Code flags for recovery sessions

```bash
# Start with a specific model
claude --model claude-opus-4-6

# Allow the skill's scripts to run (required for connectivity check and sweep)
claude --allow-execute

# For long recovery sessions — disable timeout
claude --no-timeout

# Start Claude Code in a specific directory (e.g. where btcrecover is installed)
claude --dir ~/btcrecover
```

---

## Troubleshooting

**Skill not triggering automatically:**
```
> Use the btcrecover skill to help me recover my wallet.
```
Explicit invocation always works.

**Scripts not executable:**
```bash
chmod +x ~/.claude/skills/btcrecover-skill/scripts/*.sh
```

**Skill not found:**
```bash
ls ~/.claude/skills/
# Should show btcrecover-skill/ directory
# If not: re-run the installer
```

**Using a local model instead of the Anthropic API:**
Claude Code always uses the Anthropic API. For fully local offline
recovery, use Hermes Agent with Ollama instead — see `agents/hermes.md`.
