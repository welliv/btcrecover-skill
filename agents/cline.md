# Cline (VS Code) Setup Guide — btcrecover skill

Cline is an AI coding agent that runs inside VS Code. It supports the
SKILL.md format and can use both local models (via Ollama) and cloud APIs.

---

## Installation

### Option 1 — Verified installer

```bash
curl -fsSL https://raw.githubusercontent.com/welliv/btcrecover-skill/main/install.sh | bash
# Select option 3: .vscode/skills/ (Cline)
```

### Option 2 — Manual

```bash
git clone https://github.com/welliv/btcrecover-skill
mkdir -p .vscode/skills/
cp -r btcrecover-skill .vscode/skills/
chmod +x .vscode/skills/btcrecover-skill/scripts/*.sh
```

Skills directories in Cline:

| Scope | Path | Use case |
|---|---|---|
| Project-level | `.vscode/skills/` | Per-project, shared via git |
| Global | `~/.vscode/skills/` | Available in all VS Code projects |

---

## Model configuration for recovery

For **Tier 1 offline recovery** (recommended), point Cline at a local
Ollama model:

1. Install Ollama: `curl -fsSL https://ollama.com/install.sh | sh`
2. Pull a model: `ollama pull qwen3:14b`
3. In VS Code: Cline settings → API Provider → OpenAI Compatible
4. Base URL: `http://127.0.0.1:11434/v1`
5. API Key: (leave blank)
6. Model: `qwen3:14b`

For **Tier 2 cloud reasoning**, use your preferred cloud API:
- Anthropic: set ANTHROPIC_API_KEY in Cline settings
- OpenAI: set OPENAI_API_KEY in Cline settings
- OpenRouter: set OPENROUTER_API_KEY for access to 200+ models

---

## Triggering the skill

In VS Code with Cline open:
- Type `/skills btcrecover` to explicitly invoke
- Or describe your situation: "I need to recover my Bitcoin wallet password"

---

## Important note for Windows VS Code users

Cline's terminal uses PowerShell by default. The recovery skill's scripts
are bash. Change the integrated terminal to bash:

```json
// .vscode/settings.json
{
  "terminal.integrated.defaultProfile.windows": "Git Bash"
}
```

Or use VS Code with WSL2 (recommended for this skill on Windows):
- Install WSL2: `wsl --install`
- Open VS Code in WSL: `code .` from inside a WSL terminal
