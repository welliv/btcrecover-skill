---
name: btcrecover-skill
description: AI-guided Bitcoin wallet recovery using btcrecover. Recovers lost passwords, seed phrases and wallet backups. Works offline with local models or cloud APIs. Three-tier security with post-recovery fund sweeping and session destruction.
---

# btcrecover-skill

The AI layer that makes Bitcoin wallet recovery accessible to everyone.

Built on btcrecover by Stephen Rothery (3rdIteration). Free and open source. Always.

## Flow

```
User describes situation
  → Step 0: Consent (ACCEPT)
  → Step 0: Verify btcrecover
  → Step 1: Check connectivity
  → Step 2: Recommend model
  → Step 3: Classify problem (password/seed/forensics/hybrid)
  → Step 4: Route to subskill, build command, user approves
  → Step 5: Manage long sessions
  → Step 6: Report progress
  → Step 7: Sweep funds → Destroy session
```

## Step 0: First Run

Show DISCLAIMER.md. User types `ACCEPT`. Log to `consent.log`. One time only.

## Step 0: Verify btcrecover

```bash
bash scripts/verify-btcrecover.sh
```

Checks remote URL against official repo. Checks for known malicious forks. Halts on failure.

## Step 1: Connectivity

```bash
bash scripts/connectivity-check.sh
```

Checks: ICMP ping, DNS resolution, TCP port 53. Also detects active interfaces and cloud sync processes.

Exit 0 = offline (safe). Exit 1 = online (requires tier choice).

When online:

```
TIER 1 — Fully offline (recommended)
  Disconnect internet. Use local AI. Maximum security.

TIER 2 — Local agent + cloud API
  Keys stay local. Only text prompts go to cloud.
  Type "I UNDERSTAND" to proceed.

TIER 3 — Fully online
  Last resort. Type "I UNDERSTAND AND ACCEPT" to proceed.
```

## Step 2: Model Recommendation

Read `references/benchmarks.json`. Calculate expected value:

```
EV = (task_score × evidence_multiplier) - cost_penalty - risk_penalty
```

Recommend the top model in plain English.

## Step 3: Classify Problem

| Type | What it is | Route |
|------|------------|-------|
| Password | Forgotten wallet password | password/ |
| Seed | Wrong BIP39/SLIP39 words | seed/ |
| Passphrase | Forgotten BIP39 25th word | password/ |
| Forensics | Wallet file location unknown | forensics/ |
| Hybrid | Multiple issues | All in sequence |

Rate evidence: high, medium or low.

## Step 4: Route to Subskill

Load the right subskill. For each command:

1. Show it in plain English
2. Explain what it does
3. Wait for approval
4. Run it
5. Report results

## Step 5: Long Sessions

Jobs over 30 minutes:

```bash
bash scripts/session-manager.sh start
```

Wraps btcrecover in screen/tmux with automatic checkpointing. Reports progress in plain English.

## Step 6: Progress Briefings

At 25%, 50%, 75% and completion, report:
- What has been tried
- What is running
- Time remaining
- Search space reduction

## Step 7: Post Recovery

When btcrecover finds the credential:

**Intercept** — "We found it. Before anything else, walk through this with me."

**Run sweep script:**
```bash
bash scripts/sweep-reminder.sh
```

Six steps with Enter gates:
1. Reframe: accessible is not safe
2. Create new wallet on clean device
3. Verify receive address (8 characters)
4. Test transaction (defeats clipboard hijackers)
5. Full sweep (not import)
6. On-chain verification

**Destroy session:**
```bash
bash scripts/nuke-session.sh
```

Deletes tokenlists, extracts, clipboard, shell history, scrollback.

## Security

### Three Tiers

**Tier 1 — Fully offline**
Local AI, no internet, btcrecover local. No one sees your keys. Recommended for wallets over $1,000.

**Tier 2 — Local agent + cloud API**
Hermes on your machine calls a cloud API. Wallet file stays local. Text prompts only. Consent: "I UNDERSTAND".

**Tier 3 — Fully online**
Use with caution. Consent: "I UNDERSTAND AND ACCEPT". Sweep immediately.

### Key Distinction
Tier 2 is not Tier 3. In Tier 2, the cloud API receives text prompts, never your wallet file or keys. You run the commands locally. In Tier 3, the platform itself controls the environment.

## What This Skill Never Does

- Execute anything without approval
- Hold, move or transmit funds
- Share seed phrases or private keys
- Store sensitive data in plain text
- Contact you (it is a file, not a service)
- Guarantee success

## Compatibility

**Agents:** Hermes, Claude Code, Cline, Cursor, any agent supporting the SKILL.md standard.

**Models:** Local via Ollama (hermes3:8b, qwen3:14b, deepseek-r1:14b/32b). Cloud via Claude, GPT, Gemini, DeepSeek, OpenRouter.

## License

GPL-2.0. Free forever.

## Attribution

Built on btcrecover by Stephen Rothery (3rdIteration).
Inspired by @cprkrn's May 2026 recovery story.
Skill structure informed by Andrej Karpathy's work on LLM agent behaviour ([tweet](https://x.com/karpathy/status/2015883857489522876), [repo](https://github.com/multica-ai/andrej-karpathy-skills)).

---
*Free. Open source. Always.*