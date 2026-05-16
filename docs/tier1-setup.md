# Tier 1 Setup Guide (Fully Offline)

Tier 1 requires you to run a local AI model. This guide helps you set it up.

## Recommended: Ollama (Easiest)

### 1. Install Ollama

**Linux / macOS:**
```bash
curl -fsSL https://ollama.com/install.sh | sh
```

**Windows:**
Download from https://ollama.com/download

### 2. Start Ollama and Pull a Model

```bash
ollama serve
```

In another terminal:
```bash
# Good balance of quality and speed
ollama pull llama3.1:8b

# Stronger model (needs more RAM)
# ollama pull llama3.1:70b
```

### 3. Verify Local Model is Running

```bash
ollama list
```

You should see the model you downloaded.

### 4. Run Tier 1 Readiness Check

```bash
bash scripts/tier1-check.sh
```

If it says "Tier 1 Ready", you can proceed with offline recovery.

## Alternative Local Setups

- **LM Studio**
- **llama.cpp server**
- **GPT4All**
- **AnythingLLM** (local mode)

As long as the model is accessible locally, Tier 1 is possible.

## Important Notes

- Tier 1 works best with 16GB+ RAM.
- You must remain offline during the entire recovery session.
- After recovery, run `sweep-reminder.sh` as usual.