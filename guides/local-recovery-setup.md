# Local Recovery Setup — Ollama and Hermes

## Complete Setup Guide for Maximum Privacy

This guide walks you through setting up a fully local, private Bitcoin wallet recovery environment using Ollama and Hermes Agent.

## Part 1: Install Hermes Agent

### Option A: Docker (Recommended for beginners)
```bash
docker run -it --name hermes \
  -v ~/.hermes:/root/.hermes \
  -p 8080:8080 \
  nousresearch/hermes-agent:latest
```

### Option B: Manual Installation
```bash
# Clone the repository
git clone https://github.com/NousResearch/hermes-agent.git
cd hermes-agent

# Install dependencies
pip install -e .

# Start Hermes Agent
hermes agent
```

## Part 2: Install Ollama (Local LLM Provider)

### Linux/macOS
```bash
curl -fsSL https://ollama.com/install.sh | sh
```

### Windows
Use the Ollama Windows installer from https://ollama.com/download

### Start Ollama Service
```bash
ollama serve &
```

### Download a Recommended Model
```bash
# For recovery tasks, we recommend:
ollama pull llama3:8b
# Or for better accuracy (requires more RAM/VRAM):
ollama pull llama3:70b
```

## Part 3: Configure Hermes Agent to Use Ollama

Hermes Agent automatically detects Ollama running on localhost:11434.

To verify:
```bash
hermes model list
```
You should see your Ollama models listed.

## Part 4: Load the btcrecover-skill

```bash
# From within Hermes Agent:
skill load https://github.com/3rdIteration/btcrecover-skill/raw/main/SKILL.md
```

Or if you cloned the repository locally:
```bash
skill load /path/to/btcrecover-skill/SKILL.md
```

## Part 5: Verify Your Setup

1. Describe your recovery situation in plain English
2. Hermes will load the skill and guide you through:
   - Reading safety rules (mandatory)
   - Checking connectivity (3-layer)
   - Determining recovery type
   - Loading appropriate sub-skill
   - Guided recovery with approvals

## Part 6: Advanced Configuration

### Custom Model Parameters
Create `~/hermes/config.yaml`:
```yaml
models:
  ollama:
    llama3:8b:
      num_ctx: 4096
      temperature: 0.1
      top_p: 0.9
```

### Offline Verification
To ensure no data leaves your machine:
```bash
# Monitor network traffic during recovery
sudo tcpdump -i any not port 22 and not port 11434
```
You should see only local traffic (to Ollama on 11434) and SSH (if remote).

## Part 7: Recovery Workflow Example

### Scenario: Forgot Electrum Wallet Password
1. User says: "I think I lost my Electrum wallet password. I remember it was based on my pet's name and my birth year 1990."
2. Hermes loads btcrecover-skill
3. Skill reads safety-rules.md (you see this every session)
4. Runs connectivity-check.sh (reports LOCAL_ONLY if Ollama is local)
5. Determines this is a password recovery task
6. Loads skills/password/SKILL.md
7. Guides you through:
   - Gathering known fragments (pet name + 1990)
   - Creating a tokenlist with common variations
   - Running btcrecover with your approval for each command
   - Validating the recovered password
   - Initiating sweep-reminder.sh
   - Offering to run nuke-session.sh

## Part 8: Maintenance

### Update Hermes Agent
```bash
git pull && pip install -e .
```

### Update Ollama Models
```bash
ollama pull llama3:8b  # Gets latest version
```

### Update btcrecover-skill
```bash
# If you cloned the repository:
git pull origin main
```

### Backup Your Configuration
```bash
cp -r ~/.hermes ~/hermes-backup-$(date +%Y%m%d)
```

## Part 9: Troubleshooting

### "Cannot connect to Ollama"
- Ensure Ollama is running: `ollama serve`
- Check firewall: `sudo ufw allow 11434`
- Verify Hermes config points to localhost:11434

### Slow Performance
- Use a smaller model: `ollama pull phi3:mini`
- Increase Ollama num_ctx in config.yaml
- Close other applications to free RAM

### Model Not Found
- Run `ollama list` to see installed models
- Pull the model: `ollama pull <model-name>`

## Part 10: Security Verification

### Network Isolation Test
1. Disconnect from internet
2. Start recovery session
3. All steps should work except connectivity-check.sh (will report OFFLINE)
4. Recovery can proceed with local model

### Data Leak Test
1. Use Wireshark or tcpdump to monitor traffic
2. Confirm only local ports (11434 for Ollama, 22 for SSH if needed) are used
3. No HTTP/HTTPS traffic to external domains during recovery

## Conclusion

You now have a fully private, local Bitcoin wallet recovery environment. Your data never leaves your machine, and you maintain complete control over the recovery process.

Remember: Always sweep recovered funds to a new wallet immediately after recovery.

---
*Stay safe and recover responsibly.*