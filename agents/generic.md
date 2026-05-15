# Generic / Universal Setup Guide — btcrecover skill

Use this guide if your agent is not listed in the other files in this
directory, or if you want to use the skill with any LLM chat interface
without a dedicated agent.

---

## The universal method — paste SKILL.md as your first message

This works with any LLM that accepts a system prompt or a long first
message. No installation required.

```
1. Open your LLM chat interface (any model, any platform)

2. Copy the entire contents of SKILL.md from:
   https://github.com/welliv/btcrecover-skill/blob/main/SKILL.md

3. Paste it as your first message (or as the system prompt if supported)

4. Then describe your recovery situation in your next message
```

The model will follow the skill's instructions and guide you through
recovery. You will run all generated commands yourself in a separate
terminal.

**Security note:** When using this method with a cloud LLM (Claude.ai,
ChatGPT, Gemini, etc.), you are in Tier 3 (fully online). Do not paste
your seed phrase, private keys, or wallet file into the chat. Use
btcrecover's extract scripts to share only a safe hash.

---

## For agents that support SKILL.md files

If your agent has a skills or memory directory where it reads SKILL.md
files, drop the entire `btcrecover-skill/` folder there.

Common locations:

| Agent | Skills directory |
|---|---|
| Open WebUI | Settings → Documents → upload SKILL.md |
| LM Studio | Custom system prompt → paste SKILL.md |
| Jan.ai | Thread instructions → paste SKILL.md contents |
| Anything LLM | Workspace → add document → SKILL.md |
| Continue (VS Code) | `.continue/skills/` |
| Goose | `~/.goose/skills/` |
| Roo | `.roo/skills/` |

For agents not listed: check the agent's documentation for "custom
instructions", "system prompt", or "skills directory". Any of these
can receive the SKILL.md contents.

---

## For direct Ollama usage (no agent)

If you are running Ollama directly without an agent wrapper:

```bash
# Pull a model
ollama pull qwen3:14b

# Start a session with the skill content as system prompt
SKILL_CONTENT=$(cat /path/to/btcrecover-skill/SKILL.md)

ollama run qwen3:14b \
  --system "$SKILL_CONTENT" \
  "I need to recover my Bitcoin wallet. [describe your situation]"
```

Or use Ollama's API directly:

```bash
curl http://localhost:11434/api/chat -d '{
  "model": "qwen3:14b",
  "messages": [
    {
      "role": "system",
      "content": "'"$(cat /path/to/btcrecover-skill/SKILL.md | sed "s/'/'\''/"g)"'"
    },
    {
      "role": "user",
      "content": "I need help recovering my Electrum wallet password."
    }
  ]
}'
```

---

## For API-only usage (no chat interface)

If you are using an AI API directly (curl, Python, etc.) and want to
use the skill programmatically:

```python
import anthropic

with open("SKILL.md", "r") as f:
    skill_content = f.read()

client = anthropic.Anthropic()

message = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=4096,
    system=skill_content,
    messages=[
        {
            "role": "user",
            "content": "I have an Electrum wallet from 2019. I remember the password "
                      "started with my cat's name 'Whiskers' but I may have added "
                      "numbers. Can you help me recover it?"
        }
    ]
)
print(message.content[0].text)
```

---

## Minimum requirements for any setup

Regardless of which agent or method you use, the skill requires:

1. **The LLM can read the full SKILL.md** (~5,000 tokens) in context
2. **The LLM supports a context window of at least 16,000 tokens**
   (for longer recovery sessions with sub-skills loaded)
3. **You have a terminal** where you can run the btcrecover commands
   the skill generates
4. **btcrecover is installed** on your machine:
   `git clone https://github.com/3rdIteration/btcrecover`

If your model has a very small context window (<8K tokens), load only
the relevant sub-skill instead of the full SKILL.md:
- Password recovery: paste `skills/password/SKILL.md`
- Seed recovery: paste `skills/seed/SKILL.md`
- File archaeology: paste `skills/forensics/SKILL.md`

---

## Trigger phrases (use these to activate the skill)

When the skill content is loaded, any of these will trigger it:

```
"Help me recover my Bitcoin wallet"
"I forgot my wallet password"
"I lost my seed words"
"I have an old wallet.dat file"
"Use the btcrecover skill"
"I need to recover access to my crypto"
```
