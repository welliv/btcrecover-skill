---
name: btcrecover-skill
description: AI-guided Bitcoin wallet recovery using btcrecover. Helps users recover lost wallet passwords, seed phrases, and discover wallet backups through guided, step-by-step assistance. Works offline-first with local models (Ollama) or cloud APIs. Supports password recovery, BIP39/SLIP39 seed recovery, and file archaeology. Three-tier security model. Post-recovery safety protocol with fund sweeping and session destruction.
---

# btcrecover-skill

The AI layer that makes Bitcoin wallet recovery accessible to everyone.

Built on btcrecover by Stephen Rothery (3rdIteration). Free and open source. Always.

## Progressive Disclosure

```
L1 — Advertise (~80 tokens in system prompt)
     name + description only
     Agent knows the skill exists and when to use it

L2 — Load (< 5,000 tokens, loaded when triggered)
     This main SKILL.md orchestrator
     Loaded when user describes a recovery situation

L3 — Sub-skills (loaded per recovery type)
     skills/password/SKILL.md   → password/passphrase recovery
     skills/seed/SKILL.md       → mnemonic recovery
     skills/forensics/SKILL.md  → file archaeology

L4 — References and scripts (loaded on demand)
     references/ files loaded only when the sub-skill needs them
     scripts/ executed only when the user approves each command
```

## Orchestration Flow

```
User describes situation (plain English)
          │
          ▼
    Step 0A: First-run consent gate (ACCEPT)
    Step 0B: btcrecover integrity check (verify-btcrecover.sh)
          │
          ▼
    Step 1: Connectivity gate (connectivity-check.sh)
          │
     ┌────┴────┐
  OFFLINE    ONLINE
     │           │
  Green       Tier warning
  light       + acknowledgment
     │           │
     └────┬───────┘
          │
    Step 2: Model router reads benchmarks.json
    Calculates EV: (task_score × evidence_quality) - cost_penalty - risk_penalty
    Recommends optimal model
          │
          ▼
    Step 3: Natural language triage interview
    Classifies: PASSWORD | SEED | FORENSIC | HYBRID
          │
          ▼
    Step 4: Routes to appropriate sub-skill
    Sub-skill builds btcrecover command
    Shows command to user in plain English
    User approves → runs (never auto-executes)
          │
    ┌─────┴──────┐
  Found      Not found
    │              │
    ▼         Expand search
  Step 7:     or escalate
  sweep-
  reminder
  .sh (6 steps)
    │
    ▼
  nuke-session.sh
  (secure destroy everything)
```

## Step 0A: First-Run Consent Gate

On first run only, display DISCLAIMER.md and require the user to type `ACCEPT` to proceed. This is a one-time gate per agent installation.

```
Before we begin, I need you to read and accept the terms in DISCLAIMER.md.
This skill provides guidance for Bitcoin wallet recovery. It does not
guarantee recovery. You assume all risk. See DISCLAIMER.md for full terms.

Type ACCEPT to continue:
```

Log the acceptance with timestamp to `~/.btcrecover-skill/consent.log`.

## Step 0B: btcrecover Integrity Check

Before any recovery work, verify btcrecover installation authenticity:

```bash
bash scripts/verify-btcrecover.sh
```

This checks:
- Git remote URL against official repo (3rdIteration/btcrecover)
- Known malicious fork patterns (TCRetriever, demining, etc.)
- SHA256 checksums of core files

If verification fails, halt the session and warn the user.

## Step 1: Connectivity Gate

```bash
bash scripts/connectivity-check.sh
```

Three-layer detection:
1. ICMP ping to 8.8.8.8
2. DNS resolution via nslookup
3. TCP port 53 check

Also checks for active network interfaces and cloud sync processes (Dropbox, iCloud, OneDrive, Nextcloud).

**Exit codes:**
- 0 = OFFLINE (safe, Tier 1 — proceed)
- 1 = ONLINE (requires tier acknowledgment)

If ONLINE, display the tier selection:
```
You are currently online. Please select a security tier:

TIER 1 — FULLY OFFLINE (recommended)
  Disconnect from internet, use local AI model
  Nobody sees your keys. Maximum security.

TIER 2 — LOCAL AGENT + CLOUD API
  Local btcrecover + cloud AI reasoning
  Keys stay local. Only text prompts go to cloud.
  Type "I UNDERSTAND" to proceed.

TIER 3 — FULLY ONLINE
  Use with clear understanding of risks.
  Type "I UNDERSTAND AND ACCEPT" to proceed.
```

## Step 2: Model Recommendation

Read `references/benchmarks.json` and calculate EV for each available model:

```
EV = (task_score × evidence_multiplier) - cost_penalty - risk_penalty

Where:
  task_score          = model's benchmark score for this recovery type (0-100)
  evidence_multiplier = HIGH: ×1.0 | MEDIUM: ×0.85 | LOW: ×0.70
  cost_penalty        = (estimated_cost_usd / wallet_value_usd) × 20, capped at 20
  risk_penalty        = 0 (Tier 1) | 5 (Tier 2) | 15 (Tier 3)
```

Recommend the top-scoring model in plain English with alternatives explained.

## Step 3: Natural Language Triage Interview

Ask the user about their situation. Classify into one of:

| Type | Description | Sub-skill |
|------|-------------|-----------|
| PASSWORD | Forgotten wallet encryption password | password/ |
| SEED | Missing or wrong BIP39/SLIP39 words | seed/ |
| PASSPHRASE | Forgotten BIP39 25th word | password/ (passphrase mode) |
| FORENSIC | Unknown wallet file location | forensics/ |
| HYBRID | Multiple issues combined | All sub-skills in sequence |

Also classify evidence quality:
- **HIGH**: Strong candidates, small space (<1 billion)
- **MEDIUM**: Partial memory, medium space (1B-1T)
- **LOW**: Very vague, large space (>1T)

## Step 4: Sub-Skill Routing

Load the appropriate sub-skill and follow its phases. For each btcrecover command:

1. Show the command in plain English
2. Explain what it does and why
3. Wait for explicit user approval
4. Run the command
5. Parse output and report progress in human terms

## Step 5: Long Session Management

For recovery jobs expected to take more than 30 minutes:

```bash
bash scripts/session-manager.sh start
```

This wraps btcrecover in a managed `screen` or `tmux` session with automatic checkpointing via `--savefile`.

Progress parsing reads btcrecover's native output and translates to: "X% complete, estimated Y hours remaining."

## Step 6: Progress Briefings

At each milestone (25%, 50%, 75%, completion), provide a plain-English progress briefing:
- What has been tried
- What is currently running
- Estimated time remaining
- Whether the search space is being reduced as expected

## Step 7: Post-Recovery Protocol

When btcrecover finds the credential:

**Stage 1 — Intercept (before congratulations)**
"We found it. Before anything else, I need to walk you through something important."

**Stage 2-7: Run sweep-reminder.sh**
```bash
bash scripts/sweep-reminder.sh
```

Six mandatory steps with Enter gates between each:
1. The reframe: "Accessible is not the same as safe."
2. New wallet setup on clean device
3. Address display with 8-character verification
4. Test transaction gate (defeats clipboard hijackers)
5. Full sweep (sweep, not import)
6. On-chain verification

**Stage 8: Session destruction**
```bash
bash scripts/nuke-session.sh
```

Destroys all session data, tokenlists, extract files, clipboard, shell history, and terminal scrollback.

## Security Model

### Three Tiers

**TIER 1 — FULLY OFFLINE (maximum security)**
- Local AI model + internet disconnected + btcrecover local
- Nobody sees keys outside your machine
- Recommended for any wallet above $1,000

**TIER 2 — LOCAL AGENT + CLOUD API (safe cloud reasoning)**
- Hermes on your machine calls a cloud AI API
- Wallet file and btcrecover run locally
- Only text prompts go to the cloud
- Consent gate: "I UNDERSTAND"

**TIER 3 — FULLY ONLINE (use with clear understanding)**
- Skill runs on Claude.ai, Grok, VPS, or uncontrolled environment
- Consent gate: "I UNDERSTAND AND ACCEPT"
- Sweep urgency: IMMEDIATE — treat all keys as compromised

### Key Principle
Mode 2 is not Mode 3. In Mode 2, the cloud AI is a reasoning engine generating command-line instructions. You run those instructions locally. In Mode 3, the inference environment is not under your control.

## What the Skill Never Does

- Never executes anything without explicit user approval
- Never holds, moves, or transmits funds
- Never shares seed phrases or private keys with anyone
- Never stores sensitive information in plain text
- Never contacts the user (the skill is a file, not a service)
- Never guarantees successful recovery

## Agent Compatibility

Works with any agent supporting the agentskills.io SKILL.md standard:
- Hermes Agent (Nous Research) — primary agent, see `agents/hermes.md`
- Claude Code (Anthropic) — see `agents/claude-code.md`
- Cline (VS Code) — see `agents/cline.md`
- Cursor — see `agents/cursor.md`
- Any LLM or chat interface — see `agents/generic.md`

## Model Compatibility

Works with local models (Ollama) and cloud APIs:
- Local: Ollama with hermes3:8b, qwen3:14b, deepseek-r1:14b/32b
- Cloud: Claude, GPT, Gemini, DeepSeek via OpenRouter

## License

GPL-2.0 — free forever.

## Attribution

Built on btcrecover by Stephen Rothery (3rdIteration).
Inspired by @cprkrn's May 2026 recovery story.
Skill structure informed by Andrej Karpathy's LLM coding observations.

---
*Free. Open source. Always.*