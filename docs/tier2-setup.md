# Tier 2 Setup Guide

Tier 2 is the recommended default for most users.

## What Tier 2 Means

- Cloud AI is used only for reasoning and suggestions.
- Your seed phrase, wallet file, addresses, and passphrases **never leave your machine**.
- You run all `btcrecover` commands locally.

## Requirements

You need an API key from a supported provider:

- OpenRouter (recommended)
- Anthropic (Claude)
- OpenAI (GPT-4o)
- Groq
- Together AI

## How to Configure

1. Get an API key from your chosen provider.
2. Configure it in Hermes Agent (usually via environment variable or config file).
3. When the skill asks for tier consent, type:

```
TIER2 I UNDERSTAND
```

## Security Notes

- Only text prompts are sent to the cloud.
- Never paste seed phrases or wallet files into the chat.
- The actual recovery commands always run on your machine.

Tier 2 is suitable for smaller recoveries. For larger amounts, Tier 1 or air-gapped setups are strongly recommended.