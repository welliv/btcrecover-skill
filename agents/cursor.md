# Cursor Setup Guide — btcrecover skill

Cursor is an AI-powered code editor that supports the SKILL.md format.

---

## Installation

### Option 1 — Verified installer

```bash
curl -fsSL https://raw.githubusercontent.com/[yourusername]/btcrecover-skill/main/install.sh | bash
# Select option 3: ~/.cursor/skills/ (Cursor)
```

### Option 2 — Manual

```bash
git clone https://github.com/[yourusername]/btcrecover-skill

# Global (all projects)
mkdir -p ~/.cursor/skills/
cp -r btcrecover-skill ~/.cursor/skills/

# Or project-level
mkdir -p .cursor/skills/
cp -r btcrecover-skill .cursor/skills/

chmod +x ~/.cursor/skills/btcrecover-skill/scripts/*.sh
```

---

## Model configuration

For **Tier 1 offline recovery** (recommended), configure Cursor to use
a local Ollama model:

1. Cursor Settings (Cmd+, / Ctrl+,) → Models
2. Add custom model provider
3. Base URL: `http://127.0.0.1:11434/v1`
4. API Key: (leave blank or use `ollama`)
5. Model name: `qwen3:14b` or `hermes3:8b`

Cursor supports all major cloud providers natively (Claude, GPT-4,
Gemini). For Tier 2 recovery, use your preferred cloud model with
the skill generating commands that run in Cursor's integrated terminal.

---

## Triggering the skill

In Cursor's Composer or Chat:
- Type `@btcrecover-skill` to reference the skill directly
- Or describe your situation naturally

Cursor's AI panel will load the skill when it detects a recovery-related
request.

---

## Notes for Cursor users

- Cursor's terminal runs on your local machine — btcrecover commands
  execute locally regardless of which cloud model you use for reasoning
- The skill's connectivity check works normally in Cursor's integrated
  terminal
- For very long recovery sessions, use `session-manager.sh` to run
  btcrecover in a background session outside of Cursor
