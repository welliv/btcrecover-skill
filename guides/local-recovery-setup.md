# Local Recovery Setup

How to set up Ollama and Hermes for fully private wallet recovery.

## Install Ollama

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

Set context length (critical for Hermes):
```bash
sudo systemctl edit ollama.service
# Add: Environment="OLLAMA_CONTEXT_LENGTH=65536"
sudo systemctl daemon-reload && sudo systemctl restart ollama
```

Pull a model:
```bash
ollama pull hermes3:8b         # 6GB VRAM, good all round
ollama pull qwen3:14b          # 10GB VRAM, best for forensics
ollama pull deepseek-r1:32b   # 20GB VRAM, best for passwords
```

## Install Hermes

```bash
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
source ~/.bashrc
```

## Configure Hermes

```bash
hermes model
# → Custom endpoint
# → URL: http://127.0.0.1:11434/v1
# → Key: (blank)
# → Model: hermes3:8b (or whichever you pulled)
```

## Load the Skill

```bash
cp -r btcrecover-skill ~/.hermes/skills/
chmod +x ~/.hermes/skills/btcrecover-skill/scripts/*.sh
```

## Test Your Setup

Disconnect from internet. Run Hermes. Describe your situation in plain English.

```bash
hermes --tui
> I think I lost my Electrum wallet password.
```

The skill checks connectivity (offline is fine), loads safety rules, classifies your problem and guides you through recovery.

## For Cloud Model Power (Tier 2)

Install Hermes locally. Point it at a cloud API. The wallet file never leaves your machine.

```bash
hermes model
# → Anthropic
# → Paste API key
# → Select claude-sonnet-4-6 or claude-opus-4-6
```

This is safe. The cloud API receives text prompts, not your wallet file or keys.

## Troubleshooting

| Problem | Fix |
|---|---|
| Cannot connect to Ollama | `ollama serve` to start. Check port 11434. |
| Model not found | `ollama list` to see installed models. |
| Slow | Try a smaller model: `ollama pull phi3:mini`. Close other apps. |
| Text truncated | Set OLLAMA_CONTEXT_LENGTH=65536. |
