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
    → Offline verification (ping + nslookup must fail)
    → If online: Tier selection + split-workflow rules
  → Step 2: Recommend model
  → Step 3: Classify problem (password/seed/passphrase/forensics/hybrid)
    → Check "not practical" gates — bail if hopeless
  → Step 3b: Pre-Flight Validation (if seed or hybrid)
  → Step 4: Pick the right tool (btcrecover.py or seedrecover.py)
  → Step 4: Route to subskill, build command, user approves
  → Step 5: Manage long sessions
  → Step 6: Report progress
  → Step 7: Sweep funds → Destroy session → Donate → Upstream
```

## Step 0: First Run

Show DISCLAIMER.md. User types `ACCEPT`. Log to `consent.log`. Once only.

## Step 0: Setup and Verify btcrecover

Check for the marker file `~/.btcrecover-skill/.btcrecover-verified`.

**If marker exists (returning user):** run verify only:
```bash
bash scripts/verify-btcrecover.sh
```
- Exit 0: verified — proceed to Step 1.
- Exit 1: suspicious fork detected — show warning, refuse to continue until user reinstalls from the official source.
- Exit 2: btcrecover missing (deleted or moved) — offer to re-run setup.

**If marker does not exist (first run):** tell the user warmly:
> "Before we start, I need to set up btcrecover — the open-source tool that does the actual recovery work. One-time setup, takes about a minute."

Then run:
```bash
bash scripts/setup-btcrecover.sh
```
- Exit 0: ready — proceed to Step 1.
- Exit 1: failed or declined — explain what is needed and wait.
- Exit 2: prerequisites missing (Python/git) — show the install instructions from the script output and pause until the user confirms they are installed.

If btcrecover is missing at any later step, do not show a raw error. Say: "It looks like btcrecover is missing — let me set that up." Then run `setup-btcrecover.sh` and resume.

## Step 1: Connectivity — HARD GATE

🚫 **You MUST NOT proceed past this step without exit 0 from `connectivity-check.sh --enforce`.**

Exit 0 means either:
- User is verified **offline** (Tier 1 — safe to proceed)
- User has typed explicit **consent** to proceed online (Tier 2 or 3)

Without exit 0, you MUST NOT ask for or accept any sensitive data:
seed phrases, private keys, wallet files, passphrases, or addresses.

### Step 1a — Initial connectivity check

```bash
bash scripts/connectivity-check.sh
```

Checks ICMP ping, DNS resolution and TCP port 53. Also detects active interfaces and cloud sync processes.

**Exit codes:**
- `2` = OFFLINE — run `--enforce` to confirm (will auto-pass). Then proceed to Step 2.
- `0` = FULLY ONLINE — run `--enforce` for interactive tier consent.
- `1` = PARTIAL (some layers blocked) — treat as online, run `--enforce`.

### Step 1b — Enforce gate (do not skip)

```bash
bash scripts/connectivity-check.sh --enforce
```

This is the **hard gate**. The script is interactive — it shows the tier menu
and blocks until the user types one of:

| Input | Tier | Meaning |
|-------|------|---------|
| `DISCONNECTED` | Tier 1 | Confirms offline. Script re-checks connectivity. |
| `TIER2 I UNDERSTAND` | Tier 2 | Cloud reasoning only. Keys stay local. |
| `TIER3 I UNDERSTAND AND ACCEPT` | Tier 3 | Full online. Treat keys as compromised post-recovery. |

**Exit 0** — proceed to Step 2.
**Any other exit** — the script failed or user aborted. Show the output and wait.

The script logs consent to `~/.btcrecover-skill/consent.log` with timestamp.

### Security notes for the agent

- **Tier 1 (offline):** Full seed, wallet file, keys — safe to process. Proceed normally.
- **Tier 2 (cloud reasoning):** Seed words and wallet files stay on local machine.
  The agent may reason about password patterns, tokenlists, and error messages
  via the cloud API. btcrecover runs locally.
  - Seed recovery: use placeholder words, let user substitute locally.
  - Password recovery: build tokenlist online (word fragments only — safe).
  - Use `--data-extract` instead of transmitting wallet files.
- **Tier 3 (fully online):** Last resort. Platform controls environment.
  Prefer `--data-extract` for wallet hashes. Sweep IMMEDIATELY on success.

### After the gate passes

1. Note the active tier in the session context for later steps (sweep urgency depends on it).
2. Add sweep urgency notes: Tier 1 → standard. Tier 2 → standard. Tier 3 → IMMEDIATE.
3. Proceed to Step 2.

## Step 2: Model Recommendation

Read `references/benchmarks.json`. Calculate expected value:

```
EV = (task_score × evidence_multiplier) - cost_penalty - risk_penalty
```

Recommend the best model. No jargon.

## Step 3: Classify Problem

| Type | What it is | Route |
|------|------------|-------|
| Password | Forgotten wallet password | password/ |
| Seed | Wrong BIP39/SLIP39 words | seed/ |
| Passphrase | Forgotten BIP39 25th word | password/ |
| Forensics | Wallet file location unknown | forensics/ |
| Hybrid | Multiple issues | All in sequence |

Rate evidence: high, medium or low.

### When Recovery Is Not Practical

Be honest with the user. Recovery is unlikely or impossible when:

- **Seed-only, no address, no xpub, no wallet file, no AddressDB** → btcrecover has nothing to verify against. Recovery is blind. Tell the user this.
- **Password recovery with "no idea"** — no fragments, no length, no theme, no context → infeasible for any non-trivial password.
- **4+ missing seed words** on a 12-word seed → 17 trillion possibilities. GPU rental needed, and even then it's days or weeks.
- **3+ unknown words + no address** → effectively impossible. Even with address, it's a large GPU job.
- **Brainwallet with zero recollection** — no theme, no length, no pattern → the brainwallet search space is all of human language.

When recovery is not practical, say so clearly. Explain why and what information would change the picture.

## Step 3b: Pre-Flight Validation

Before routing, validate whatever the user provided:

**Seed words** (from text or image):
- If the user sent a photo, use vision_analyze to read the words
- Check every word against the BIP39 English wordlist (2048 words)
- Verify the BIP39 checksum: SHA256 of the entropy must match the last word's bits
- A checksum fail with all-valid words means the last word is wrong (~128 alternatives for 12-word seeds)
- Report what passes and what fails before proceeding

**Known address** (if provided by user):
- Capture it for use with `--addr` flag in btcrecover
- `--addr` stops btcrecover immediately on first address match — no need to work through all candidates
- This is especially valuable for passphrase recovery: with seed + address, btcrecover can verify instantly

## Step 4: Route to Subskill

Load the right subskill. For each command:

1. Show it. Explain what it does.
2. Wait for approval.
3. Run it.
4. Report results.

**Command-building defaults (all cases):**
- Always use `--addr-limit 100` unless the user knows the exact address index. People send and receive to non-default indices (change addresses, reused wallets). Index 0 is not safe to assume.
- Always force all derivation paths: `--force-bip44 --force-p2sh --force-p2tr`. btcrecover auto-detects the address type and skips other paths, but wallet software (Sparrow, Electrum, hardware wallets) may use different derivation types for different addresses. Forcing all paths catches more matches at minimal performance cost.
- Pass this rule to any subskill that builds btcrecover commands.

**Tokenlist building (passphrase recovery):**
For every passphrase guess, generate truncations. If the user says `recoverytesting`, include `recoverytest`, `recoverytestin`, `recoverytesti` and other natural truncations. People often shorten phrases in wallets. Also generate all-lowercase versions and common suffix additions (numbers, `!`).

## Step 5: Long Sessions

Jobs over 30 minutes:

```bash
bash scripts/session-manager.sh start
```

Wraps btcrecover in screen or tmux with automatic checkpointing. Reports progress in plain English.

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

Six steps, press Enter between each:
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

### Support the btcrecover Project

btcrecover is free software maintained by volunteers. If recovery succeeded and the wallet has meaningful value, encourage a 1% donation to the maintainers:

```
BTC:  37N7B7sdHahCXTcMJgEnHz7YmiR4bEqCrS
BCH:  qpvjee5vwwsv78xc28kwgd3m9mnn5adargxd94kmrt
LTC:  M966MQte7agAzdCZe5ssHo7g9VriwXgyqM
ETH:  0x72343f2806428dbbc2C11a83A1844912184b4243
```

Also consider donating to Gurnec (original btcrecover maintainer):
`3Au8ZodNHPei7MQiSVAWb7NB2yqsb48GW4`

### Upstream Improvements

If you discovered a bug in btcrecover, used a workaround, or added a feature during recovery:

1. Report it: https://github.com/3rdIteration/btcrecover/issues
2. Submit a fix: https://github.com/3rdIteration/btcrecover/pulls

btcrecover improves because users upstream their findings. A single bug report helps the next person in the same situation.

## Test Prompts

Run these to validate the skill:

```text
"I lost my Bitcoin Core wallet password. I think it was a pet name with numbers."

"I have 12 seed words but three of them might be wrong. Help me recover."

"I found an old USB stick with wallet files. Not sure what type."

"I remember the password had leet speak in it. Like @ for a and 3 for e."

"I have the wallet file but the password changed in 2020. Is there an older backup?"

"I have my 12 seed words and a known address from the wallet, but I forgot my passphrase. It was a sentence-like phrase, all lowercase."

"I have my 12 seed words but they might be in the wrong order. I know my old address though."

"I have a BIP38 encrypted paper wallet. The private key starts with 6Pn."

"I have a brainwallet address and I remember the passphrase was a book title."

"My seed words are all there but I think 2 words might be swapped."

"I only have 10 of my 12 seed words. I have an address with some transactions on it."

"I have a SLIP39 backup from my Trezor. I have 2 of 3 shares but one word in each share might be wrong."

"I remember my Electrum wallet password was a movie quote with numbers."
```

Each prompt should trigger a different subskill (password, seed, forensics, typo mutations, descrambling, BIP38, brainwallet, hybrid seed+passphrase, swapped words, SLIP39, and wallet password recovery).

## Security

### Three Tiers

**Tier 1 — Fully offline**
Local AI, no internet. No one sees your keys. Best for wallets over $1,000.

**Tier 2 — Local agent + cloud API**
Your machine calls a cloud API. Wallet file stays local. Text prompts only. Consent: "I UNDERSTAND".

**Tier 3 — Fully online**
Use with caution. Consent: "I UNDERSTAND AND ACCEPT". Sweep immediately.

### Key Distinction
Tier 2 is not Tier 3. In Tier 2, only text prompts go to cloud — your wallet file and keys never leave your machine. You run the commands locally. In Tier 3, the platform itself controls the environment.

## What This Skill Never Does

- Execute anything without approval
- Hold, move or transmit funds
- Share seed phrases or private keys
- Store sensitive data in plain text
- Contact you (it's a file, not a service)
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