# btcrecover-skill — Complete Project Document

> The AI layer that makes Bitcoin wallet recovery accessible to everyone.
> Built on btcrecover by 3rdIteration. Free and open source. Always.

---

## Table of Contents

1. [The Origin Story](#1-the-origin-story)
2. [The Problem](#2-the-problem)
3. [The Vision](#3-the-vision)
4. [What We Built](#4-what-we-built)
5. [Architecture](#5-architecture)
6. [Complete File Manifest](#6-complete-file-manifest)
7. [Security Model — Three Tiers](#7-security-model--three-tiers)
8. [How Recovery Works](#8-how-recovery-works)
9. [Local Setup — Ollama and Hermes](#9-local-setup--ollama-and-hermes)
10. [Model Selection — The Game-Theory Router](#10-model-selection--the-game-theory-router)
11. [Post-Recovery Protocol](#11-post-recovery-protocol)
12. [Security Hardening — 14 Blind Spots Addressed](#12-security-hardening--14-blind-spots-addressed)
13. [Anti-Impersonation and Authenticity](#13-anti-impersonation-and-authenticity)
14. [Liability Protection](#14-liability-protection)
15. [Maintainers and Attribution](#15-maintainers-and-attribution)
16. [Roadmap](#16-roadmap)
17. [Publishing and Distribution](#17-publishing-and-distribution)

---

## 1. The Origin Story

On **13 May 2026**, a pseudonymous X user known as [@cprkrn](https://x.com/cprkrn/status/2054586810475364536?s=20) posted a thread
that went viral across the crypto world. He had been locked out of a Bitcoin
wallet containing 5 BTC — worth approximately $400,000 at the time — for over
11 years. He had tried everything: brute-force attacks renting GPU time,
testing roughly 3.5 trillion password combinations at a cost of about $15,
commercial recovery services, and multiple btcrecover configurations. Every
attempt had failed.

In a final act of desperation, he uploaded his entire old college computer
to Claude AI.

What happened next was not AI magic. It was AI-assisted digital forensics.
Claude found a December 2019 wallet backup buried in years of file clutter —
a backup that predated the forgotten password change. It matched a mnemonic
phrase cprkrn had found in an old college notebook. Then it found something
else: a bug in btcrecover itself, where the tool was concatenating a shared
encryption key with the password in the wrong order during decryption. This
silent logic error had been causing every prior recovery attempt to fail.
Claude corrected the logic. The wallet decrypted on the first corrected run.

The thread generated 6 million views within hours. Crypto journalists,
security researchers, and lost-wallet holders across the world read the same
thought simultaneously: *if only I had known to try this.*

That moment is why this skill exists.

---

## 2. The Problem

The cprkrn story revealed two problems sitting on top of each other.

**The technical problem:** btcrecover is a powerful, well maintained, and
extensively documented tool. But it requires technical knowledge to use.
You need to understand wallet formats, extraction scripts, tokenlist syntax,
typo flags, derivation paths, and GPU acceleration. Most people who have
lost access to a wallet do not have this knowledge and cannot acquire it
under the stress of knowing real money is at stake.

**The AI problem:** Using an AI like Claude directly for recovery — as
cprkrn did — works. But it carries serious security risks when done naively.
cprkrn uploaded his entire computer. His keys passed through Anthropic's
infrastructure. He did the right thing and swept immediately, so he was safe.
Not everyone will know to do that. Not everyone will be lucky.

The gap between "technically powerful tool exists" and "non-technical user
can use it safely" is exactly where this skill lives.

---

## 3. The Vision

**Simply, simple, stupid, and safe.**

A non-technical user should be able to describe their situation in plain
English, provide the details they have, and receive guided, step by step
help through recovery — with every dangerous decision made safe by default,
every technical complexity abstracted away, and every scam vector anticipated
and defended against.

The skill is:

- **Free** — always, without exception, at every tier
- **Open source** — GPL-2.0, fully auditable, no black boxes
- **Agent-agnostic** — works with Claude Code, Cursor, Cline, Codex, Hermes,
  and any agent that supports the agentskills.io SKILL.md standard
- **Model-agnostic** — works with local models (Ollama) and cloud APIs
  (Claude, GPT, Gemini, DeepSeek, and 200+ others via OpenRouter)
- **Offline-first** — the safest path is the default path
- **Security-first** — safety mechanisms cannot be bypassed by user prompts

---

## 4. What We Built

Thirty-four files, 6,676 lines. Here is everything at a glance before the detail sections.

```
btcrecover-skill/
│
├── PROJECT.md                    ← This document — complete project overview
├── SKILL.md                      ← The main AI orchestrator (start here)
├── README.md                     ← Human-facing introduction and install
├── MAINTAINERS.md                ← Attribution, contributor list, donations
├── DISCLAIMER.md                 ← Legal protection and informed consent
├── SECURITY.md                   ← Responsible disclosure policy
├── VERIFIED.md                   ← Cryptographic authenticity anchor
├── install.sh                    ← One-command installer (git clone + chmod)
│
├── .github/                      ← GitHub automation and governance
│   └── CODEOWNERS                ← Security-critical file ownership rules
│
├── references/                   ← Data and rules (loaded by subskills on demand)
│   ├── safety-rules.md           ← Immutable security rules (read every session)
│   ├── benchmarks.json           ← AI model performance data + game-theory router
│   ├── wallet-types.md           ← Per-wallet recovery commands and GPU benchmarks
│   └── typo-patterns.md          ← Password and seed word error pattern library
│
├── scripts/                      ← Executable tools (all bash/python, no deps)
│   ├── connectivity-check.sh     ← 3-layer online/offline detection
│   ├── session-manager.sh        ← Background session + cron wrapper for long jobs
│   ├── sweep-reminder.sh         ← 6-step post-recovery safety protocol
│   ├── nuke-session.sh           ← Secure destruction of all session data
│   ├── verify-btcrecover.sh      ← btcrecover installation integrity checker
│   ├── benchmark-updater.py      ← Self-updating model benchmark fetcher
│   └── typosquat-monitor.py      ← Weekly fake skill detection (GitHub + skills.sh)
│
├── skills/                       ← Subskills (loaded by SKILL.md per recovery type)
│   ├── password/
│   │   └── SKILL.md              ← Password and passphrase recovery (8 phases)
│   ├── seed/
│   │   └── SKILL.md              ← Mnemonic/BIP39/SLIP39 recovery (6 problem types)
│   └── forensics/
│       └── SKILL.md              ← File archaeology and backup discovery (9 phases)
│
├── agents/                       ← Agent-specific installation and setup guides
│   ├── hermes.md                 ← Hermes Agent (Nous Research) — primary agent
│   ├── claude-code.md            ← Claude Code (Anthropic)
│   ├── cline.md                  ← Cline (VS Code)
│   ├── cursor.md                 ← Cursor
│   └── generic.md                ← Universal fallback — any LLM or chat interface
│
├── guides/                       ← User guides
│   └── local-recovery-setup.md   ← Complete Ollama + Hermes setup (10 parts)
│
└── docs/                         ← Design and research documentation
    ├── btcrecover-skill-design.md ← Full technical blueprint (for contributors)
    ├── SECURITY-AUDIT.md         ← 14 blind spots identified and mitigated
    └── AUTHENTICITY-AND-LIABILITY.md ← Anti-impersonation and legal research
```

**Total: 34 files**

---

## 5. Architecture

### How the SKILL.md standard works

The skill uses the agentskills.io four-stage progressive disclosure pattern,
originally developed by Anthropic and now an open standard supported by
Claude Code, Cursor, Cline, Codex, Hermes, and 15+ other agents.

```
L1 — Advertise (~80 tokens in system prompt)
     name + description only
     Agent knows the skill exists and when to use it
     Cost: essentially zero at idle

L2 — Load (< 5,000 tokens, loaded when triggered)
     The main SKILL.md orchestrator
     Loaded when user describes a recovery situation

L3 — Sub-skills (loaded per recovery type)
     skills/password/SKILL.md   → password/passphrase recovery
     skills/seed/SKILL.md       → mnemonic recovery
     skills/forensics/SKILL.md  → file archaeology

L4 — References and scripts (loaded on demand)
     references/ files loaded only when the subskill needs them
     scripts/ executed only when the user approves each command
```

### The orchestration flow

```
User describes situation (plain English)
          │
          ▼
    SKILL.md reads safety-rules.md (MANDATORY, every session)
          │
          ▼
    connectivity-check.sh (3-layer: ping → DNS → TCP)
          │
     ┌────┴────┐
  OFFLINE    ONLINE
     │           │
  Green       Tier warning
  light       + acknowledgment
     │           │
     └────┬───────┘
          │
    Model router reads benchmarks.json
    Calculates EV: (task_score × evidence_quality) - cost_penalty - risk_penalty
    Recommends optimal model
          │
          ▼
    Natural language triage interview
    Classifies: PASSWORD | SEED | FORENSIC | HYBRID
          │
          ▼
    Routes to appropriate subskill
          │
          ▼
    Subskill builds btcrecover command
    Shows command to user in plain English
    User approves → runs (never auto-executes)
          │
    ┌─────┴──────┐
  Found      Not found
    │              │
    ▼         Expand search
  sweep-    or escalate
  reminder
  .sh (6 steps)
    │
    ▼
  nuke-session.sh
  (secure destroy everything)
```

---

## 6. Complete File Manifest

### `SKILL.md` — The Main Orchestrator

The L2 skill file. Seven mandatory steps:

- **Step 0A**: First-run consent gate. User types ACCEPT once.
- **Step 0B**: btcrecover integrity check via `verify-btcrecover.sh`.
- **Step 1**: Connectivity gate via `connectivity-check.sh`.
- **Step 2**: Model recommendation via `references/benchmarks.json`.
- **Step 3**: Natural language triage interview. Classifies recovery type.
|- **Step 4**: Routes to subskill. Builds and previews btcrecover command.
- **Step 5**: Long-session management via `session-manager.sh`.
- **Step 6**: Progress briefing at each milestone.
- **Step 7**: Post-recovery protocol via `sweep-reminder.sh` then `nuke-session.sh`.

Key design constraint: the skill never executes anything without explicit
user approval. It is an advisor, not an actor.

---

### `references/safety-rules.md` — The Security Backbone

Read by the orchestrator at the start of every session. Contains:

- **§CORE**: The Three Laws — Sweep Law, No Third Parties, Local First
- **§ONLINE-TIER2**: Split-workflow warning with typed consent gate
- **§ONLINE-TIER3**: Full-upload warning — "I UNDERSTAND AND ACCEPT" required
- **§SCAM-DETECTION**: Nine red flags that halt the session immediately
- **§VERIFICATION**: How to verify btcrecover installation authenticity
- **§PROFESSIONAL-SERVICES**: Legitimate services vs scam services — how to tell
- **§POST-RECOVERY**: The complete sweep protocol in plain English

These rules cannot be overridden by user prompts. They are loaded fresh
every session. The AI agent must read them before doing anything else.

---

### `references/benchmarks.json` — The Model Performance Database

Self-updating via `scripts/benchmark-updater.py`. Contains:

- Per-model scores (0-100) across four task types: password, seed, forensics, passphrase
- Cost per session estimates
- VRAM requirements for local models
- Ollama pull commands
- Hardware recommendation table (CPU-only through 24GB VRAM)
- btcrecover hardware benchmarks (passwords/sec for common wallet types)
- The game-theory router formula: `EV = (task_score × evidence_multiplier) - cost_penalty - risk_penalty`
- Community benchmark submission instructions

Models currently benchmarked: Claude Opus 4, Claude Sonnet 4, GPT-4o,
Hermes-3-Llama-3.1-8B, Qwen3-14B, DeepSeek-R1-14B, Gemma3-12B.

---

### `references/wallet-types.md` — Per-Wallet Recovery Guide

Eleven wallet types with exact commands, extract scripts, and GPU speed
benchmarks. Covers: Bitcoin Core, Electrum, Blockchain.com, Trezor,
Ledger, MetaMask, Exodus, MultiBit Classic, MultiBit HD, Armory, Wasabi,
Sparrow. Includes GPU rental guidance for large search spaces.

Includes GPU rental guidance for large search spaces and extract script
references for Tier 2 (split-workflow) recovery.

---

### `references/typo-patterns.md` — Human Error Patterns

Three sections: password typos, seed word mistakes, passphrase patterns.
Covers: visual character confusion, capitalisation errors, keyboard proximity
errors, leet substitutions, BIP39 4-character uniqueness rule, look-alike
seed words, non-English wordlists, and a complete btcrecover flag reference
with performance impact notes.

---

### `scripts/connectivity-check.sh` — The Network Gate

Three-layer detection in order:
1. ICMP ping to 8.8.8.8
2. DNS resolution via nslookup (fallback for firewalled ICMP)
3. TCP port 53 check via netcat or curl (last resort)

Exit codes: 0 = FULLY_ONLINE, 1 = LOCAL_ONLY (ICMP only), 2 = OFFLINE (safe).
These match the values in SKILL.md Step 1.

---

### `scripts/sweep-reminder.sh` — The Post-Recovery Protocol

Six mandatory steps with Enter gates between each:

1. **The reframe**: "Accessible is not the same as safe."
2. **New wallet setup**: Generates on a clean device. Paper seed phrase.
3. **Address display**: Double-check format, write down 8 characters.
4. **Test transaction gate**: Send smallest possible amount. Paste tx link.
   Mandatory YES/NO confirmation. Script halts on NO with diagnostics.
   Addresses clipboard hijacker detection (Tier 3 fast-path).
5. **Full sweep**: Sweep not Import. Pre-broadcast checklist.
6. **On-chain verification**: Paste sweep tx link. Handles pending gracefully.

Then: celebration → donation ask → `nuke-session.sh` handoff.

The typed confirmation word is `DONE`. The script exits code 1 if anything
in Steps 4-5 fails, leaving the user with a clear path to resume.

---

### `scripts/nuke-session.sh` — Secure Session Destruction

Destroys in order:

1. Session base directory (`~/.btcrecover-skill/`) — checkpoint, logs, PID
2. Tokenlists and passwordlists from skill and working directory
3. Wallet extract files (`*.extract`, `extract.txt`)
4. btcrecover output and savestate files
5. Clipboard (xclip → wl-copy → xsel → pbcopy, by platform)
6. Shell history lines referencing btcrecover, seedrecover, wallet paths,
   `--password`, `--mnemonic`, `--passphrase`, WIF
7. The nuke log itself (self-destructs as final entry)
8. Terminal scrollback buffer

Supports: `--dry-run` (preview without deleting), `--force` (skip NUKE
confirmation), `--test` (verify available deletion tools), `--donation-only`.

Secure deletion uses: `shred` → `gshred` → `srm` → `wipe` → 3-pass
manual overwrite (zeros + urandom + zeros), in fallback order.

Final message includes three specific post-nuke tasks the script cannot
do: delete manually-created files, clear browser history, log out on
shared machines.

---

### `scripts/session-manager.sh` — Long Recovery Sessions

Wraps btcrecover in a managed `screen` or `tmux` session (nohup fallback).
Automatically adds `--savefile` to every btcrecover command for checkpoint
support. Subcommands: `start`, `status`, `resume`, `stop`, `report`, `cron`.

The `cron` subcommand installs an hourly progress report job with a tagged
comment so it can be cleanly removed without hunting through crontab.

Progress parsing reads btcrecover's native output format and translates
to plain English: "X% complete, estimated Y hours remaining."

---

### `scripts/benchmark-updater.py` — Self-Updating Benchmarks

Pure stdlib, no pip dependencies. Three update sources:
1. btcrecover's official hardware benchmark page (fetches, parses HTML)
2. GitHub Discussions in the "Benchmarks" category (structured JSON submissions)
3. Timestamp and metadata updates on every run

Community submissions use a weighted average: existing score × 0.8 + new
submission × 0.2, preventing single outliers from distorting results.
Supports: `--dry-run`, `--community`, `--hardware`.

---

### `skills/password/SKILL.md` — Password Recovery Sub-Skill

Eight phases: deep memory interview → search space estimation → tokenlist
construction → typo mutation selection → wallet extract (Tier 2) → command
assembly → launch and monitor → escalation on failure.

The memory interview probes for contextual anchors (what the user was doing,
listening to, playing, working on at the time) because these unlock password
memory more reliably than direct questions about the password itself.

Search space is shown in human terms: time at three GPU tiers. If >10 trillion
and no GPU: GPU rental guidance with cost estimates.

Most common password patterns are tried in frequency order. Tokenlist is
shown to the user with plain-English explanation before running.

---

### `skills/seed/SKILL.md` — Seed Recovery Sub-Skill

Six problem classifications with distinct strategies:

- **MISSING_WORDS**: 1-4 unknown words. Search space math shown. GPU guidance
  for 3+ missing words.
- **WRONG_WORD**: Alternatives generated per BIP39 visual/phonetic confusion.
  Uses tokenlist mode.
- **SCRAMBLED**: 12! = 479M combinations. Asks for any known positions to
  narrow. 24-word scrambled: escalates immediately.
- **INVALID**: Checksum failure. Last word has ~128 valid options if all others
  correct. Tokenlist approach for multiple wrong words.
- **WRONG_COIN**: Systematic derivation path check — BIP44/49/84/86 in order.
|- **EXTRA_PASSPHRASE**: Routes to password subskill for passphrase recovery.

Covers: BIP39, SLIP39, Electrum 1.x/2.x. Multi-language wordlists.
Address database method for recovery without a known address.

---

### `skills/forensics/SKILL.md` — File Archaeology Sub-Skill

The cprkrn scenario. Nine phases:

1. Data sources inventory (drives, cloud, email, phones, USB)
2. Timeline construction (establishes the golden rule: older = better)
3. File search by OS (Linux find commands, macOS Library paths, Windows
   PowerShell recursive search)
4. Identify and sort candidates (by modification date, magic bytes, md5
   deduplication)
5. Cloud storage and email search (Dropbox, Google Drive, IMAP)
6. Triage results and hand-off to appropriate subskill
7. **The cprkrn Protocol**: named procedure for finding pre-password-change
   backups. The pattern that resolved the cprkrn case.
8. Corrupted file handling (bsddb3, testdisk, photorec)
9. When nothing is found: data recovery tools, mobile wallets, honest
   assessment of what is and is not possible.

Python magic-byte identifier included for wallet format detection
independent of file extension.

---

### `guides/local-recovery-setup.md` — Ollama and Hermes Guide

Ten parts covering every platform:

- Mode 1 (fully offline), Mode 2 (local Hermes + cloud API), Mode 3 (fully
  online) — with a diagram explaining exactly what leaves the machine in
  each mode and when Mode 2 is genuinely safe
- Hardware requirements table: CPU-only through Apple Silicon M4
- Ollama install: Linux (systemd), macOS (homebrew and app), Windows (WSL2)
- The critical context length fix: `OLLAMA_CONTEXT_LENGTH=65536` (the #1
  failure mode — Hermes rejects models with <64K context)
- Model pull guide by recovery type with download sizes
- Hermes install and configuration for each mode
- Cloud API providers: Anthropic, OpenAI, OpenRouter, Ollama Cloud
- The skill-driven recommendation system with example dialogue
- Why Mode 2 is not Mode 3 — the "who controls the machine" test
- Quick reference commands: Ollama and Hermes essentials
- Troubleshooting: 7 common failure modes with exact solutions
- Security checklist: 12 items to verify before sharing wallet data

---

## 7. Security Model — Three Tiers

```
TIER 1 — FULLY OFFLINE (maximum security)
─────────────────────────────────────────
What it means:    Local AI model + internet disconnected + btcrecover local
Who sees keys:    Nobody outside your machine
Connectivity:     connectivity-check.sh must return OFFLINE
Consent gate:     none — this is the default safe path
Recommended for:  any wallet above $1,000
How to set up:    Ollama + local model, then disconnect. See guides/local-recovery-setup.md
Sweep urgency:    Standard — sweep because it is good practice, not emergency

TIER 2 — LOCAL AGENT + CLOUD API (safe cloud reasoning)
────────────────────────────────────────────────────────
What it means:    Hermes on your machine calls a cloud AI API
Who sees prompts: The cloud AI provider (Claude, OpenAI, etc.)
Who sees keys:    Nobody — wallet file and btcrecover run locally
What goes to API: Your description, password patterns, error messages
What stays local: Wallet file, seed phrase, WIF key, btcrecover execution
Consent gate:     "I UNDERSTAND" — typed explicitly
Recommended for:  Complex forensics, users without GPU hardware
Use extract scripts to ensure the wallet file never goes near the API
Sweep urgency:    Standard — keys were never exposed

TIER 3 — FULLY ONLINE (use with clear understanding)
─────────────────────────────────────────────────────
What it means:    Skill runs on Claude.ai, Grok, VPS, or any uncontrolled environment
Who sees keys:    The platform running the inference
What leaves:      Depends entirely on what the user shares
Consent gate:     "I UNDERSTAND AND ACCEPT" — typed explicitly
When appropriate: Last resort after Tier 1 and 2 have failed
Sweep urgency:    IMMEDIATE — treat all keys as compromised the moment recovery succeeds
```

### The distinction that matters most

Mode 2 is not Mode 3. This is the most important thing to communicate to
users who will assume "using the internet = risky."

In Mode 2, Hermes is a local program running on your computer. The cloud
API receives text prompts — your description of the problem, the password
patterns you remember, the wallet type. It does not receive your wallet
file, seed phrase, or private keys. Those are processed by btcrecover on
your machine. The cloud AI is a reasoning engine generating command-line
instructions. You are the one who runs those instructions locally.

In Mode 3, the inference environment itself is not under your control.
The risk is not from the AI being malicious — it is from not knowing what
is logged, what is retained, and whether your data is ever seen by someone
with access to the infrastructure.

---

## 8. How Recovery Works

### The user experience

The user does not need to know about any of this. They describe their
situation in plain English. The skill handles classification, tool selection,
command generation, and safety enforcement transparently.

What the user sees:
1. A warm, plain-language conversation
2. A clear security status at the top (OFFLINE ✅ or ONLINE ⚠️)
3. An honest time and effort estimate before anything starts
4. Every command explained in plain English before running
5. Progress briefings in human terms (percentage, time remaining)
6. A guided post-recovery protocol that cannot be rushed through

What the user never sees:
- Raw btcrecover syntax
- Technical wallet format details
- BIP44/49/84 derivation path numbers
- The game-theory router calculation
- Any of the 6,676 lines of implementation

### Recovery type taxonomy

| Type | Description | Sub-skill | Typical duration |
|---|---|---|---|
| PASSWORD | Forgotten wallet encryption password | password/ | Minutes to days |
| SEED | Missing or wrong BIP39/SLIP39 words | seed/ | Seconds to weeks |
| PASSPHRASE | Forgotten BIP39 25th word | password/ (passphrase mode) | Seconds to days |
| FORENSIC | Unknown wallet file location | forensics/ | 30 min to 2 hours |
| HYBRID | Multiple issues combined | All subskills in sequence | Variable |

### Evidence quality and its effect on recovery

The skill classifies the user's evidence quality before estimating search
space:

- **HIGH**: Strong candidates, small space (<1 billion). Likely minutes to hours.
- **MEDIUM**: Partial memory, medium space (1B-1T). Likely hours to days.
- **LOW**: Very vague, large space (>1T). May require GPU rental or be infeasible.

LOW evidence does not mean failure. It means the skill asks more questions,
tries to find contextual anchors, and considers the forensics approach before
concluding that the search space is unmanageable.

---

## 9. Local Setup — Ollama and Hermes

### The recommended path for most users

```
Step 1: Install Ollama (5 minutes)
  Linux:   curl -fsSL https://ollama.com/install.sh | sh
  macOS:   download from ollama.com/download
  Windows: install WSL2 first, then follow Linux steps

Step 2: Set context length (critical — do not skip)
  sudo systemctl edit ollama.service
  Add: Environment="OLLAMA_CONTEXT_LENGTH=65536"
  sudo systemctl daemon-reload && sudo systemctl restart ollama

Step 3: Pull a model
  8GB RAM or 6GB VRAM:  ollama pull hermes3:8b       (5GB)
  14GB VRAM or 20GB RAM: ollama pull qwen3:14b        (9GB)
  24GB VRAM:             ollama pull deepseek-r1:32b  (20GB)
  No GPU, any RAM:       ollama pull hermes3:8b:q4_0 (4GB)

Step 4: Install Hermes Agent
  curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
  source ~/.bashrc

Step 5: Configure Hermes for local model
  hermes model
  → Custom endpoint
  → URL: http://127.0.0.1:11434/v1
  → Key: (blank)
  → Model: hermes3:8b (or whichever you pulled)

Step 6: Disconnect from internet (for Tier 1)
  Disable WiFi or unplug ethernet
  Verify: ping 8.8.8.8 should fail

Step 7: Install the btcrecover skill
  cp -r btcrecover-skill ~/.hermes/skills/
  chmod +x ~/.hermes/skills/btcrecover-skill/scripts/*.sh

Step 8: Start recovery
  hermes --tui
  Describe your situation in plain English
```

### For users who want cloud model power without local GPU

Install Hermes locally, then connect it to a cloud API. The agent runs
on your machine. The wallet file never leaves. Only text prompts go out.

```
hermes model
→ Anthropic
→ Paste your API key from console.anthropic.com
→ Select: claude-sonnet-4-6 (fast) or claude-opus-4-6 (best for forensics)
```

This is Mode 2. It is safe. The cprkrn recovery happened in something closer
to Mode 3 (direct claude.ai upload). Mode 2 is architecturally safer than
that while giving access to the same model capability.

---

## 10. Model Selection — The Game-Theory Router

### The formula

```
EV = (task_score × evidence_multiplier) - cost_penalty - risk_penalty

Where:
  task_score         = model's benchmark score for this recovery type (0-100)
  evidence_multiplier = HIGH: ×1.0 | MEDIUM: ×0.85 | LOW: ×0.70
  cost_penalty       = (estimated_cost_usd / wallet_value_usd) × 20, capped at 20
  risk_penalty       = 0 (Tier 1) | 5 (Tier 2) | 15 (Tier 3)
```

The router calculates EV for every available model and recommends the best scorer in plain English.

### Current benchmark leaders by task

| Task | Best offline | Best cloud | Best budget offline |
|---|---|---|---|
| Forensics | qwen3:14b | Claude Opus 4 | hermes3:8b |
| Password | deepseek-r1:14b | Claude Sonnet 4 | hermes3:8b |
| Seed | qwen3:14b | Claude Sonnet 4 | hermes3:8b |
| Passphrase | deepseek-r1:14b | Claude Opus 4 | hermes3:8b |

### Live data sources

All benchmark data comes from public verified sources and updates daily:

| Source | What it provides | Update frequency |
|---|---|---|
| [OpenRouter](https://openrouter.ai) | Model pricing, context length, availability | Daily (cron) |
| [btcrecover GPU docs](https://github.com/3rdIteration/btcrecover/blob/master/docs/GPU_Acceleration.md) | Password/sec speeds per wallet type | On btcrecover release |
| Nvidia, AMD | GPU specs and performance ratings | Per hardware generation |

Task scores (forensics, password, seed, passphrase) are derived from general LLM capability benchmarks and refined through community submissions. They start at reasonable defaults and improve over time.

### Updating benchmarks

`scripts/benchmark-updater.py` fetches current pricing and model data:
- OpenRouter API (no key needed) — model listing, pricing, context length
- btcrecover GPU Acceleration guide — password/sec hardware data

Run it manually, or add to crontab for automatic updates:
```bash
# Run once
python3 scripts/benchmark-updater.py

# Add to crontab for daily updates at 06:00
0 6 * * * python3 /path/to/btcrecover-skill/scripts/benchmark-updater.py
```

Every model entry records its data source and the timestamp of its last update.
If a source is unreachable, cached data persists. No data is lost on failure.

---

## 11. Post-Recovery Protocol

### The seven stages after btcrecover finds the credential

**Stage 1 — Intercept (before congratulations)**
The skill intercepts the found credential and does not celebrate. It says:
"We found it. Before anything else, I need to walk you through something
important." Then `sweep-reminder.sh` takes over.

**Stage 2 — The reframe (Step 1 of sweep-reminder)**
"Your wallet is accessible. That is not the same as safe."
The user must press Enter to advance. Cannot be skipped.

**Stage 3 — New wallet (Steps 2-3)**
Guided setup of a fresh wallet on a clean device. Write seed phrase on
paper. Display receive address. Write down 8 characters before touching
the clipboard.

**Stage 4 — Test transaction gate (Step 4)**
Send the smallest possible amount to the new wallet. Paste the transaction
link. Confirm arrival. If the user says NO, the script halts with diagnostics
for three specific failure modes: pending, wrong address, broadcast failure.
This step defeats clipboard hijackers because a swapped address means the
test goes to the attacker — and the user catches it before the full sweep.

**Stage 5 — Full sweep (Step 5)**
Sweep, not Import. Pre-broadcast checklist: verify destination, verify
balance, set fee. Broadcast, then return to the terminal.

**Stage 6 — On-chain verification (Step 6)**
Paste sweep tx link. Handles pending gracefully — user types `pending` and
the script completes, knowing the sweep is broadcast.

**Stage 7 — Celebration, donation ask, nuke (Step 7 and nuke-session.sh)**
Celebration only after DONE is typed. Donation ask structured as:
"Support btcrecover first: https://github.com/3rdIteration/btcrecover#if-this-tool-or-other-content-on-my-youtube-channel-was-helpful-feel-free-to-send-a-tip-to. Support this skill second, only if you want to."
Then nuke-session.sh destroys all session data and exits clean.

### What nuke-session.sh destroys

In order: session files → tokenlists → extract files → btcrecover outputs →
clipboard → shell history (bash + zsh) → nuke log (self-destructs) →
terminal scrollback buffer.

Secure deletion: 3-pass overwrite (zeros + urandom + zeros) as fallback
if shred/srm/wipe are unavailable.

The script cannot destroy: files the user created outside the skill
directory, browser history, swap space and hibernate files (documented,
user given manual instructions). These three are explicitly listed in the
final output so nothing is left unclear.

---

## 12. Security Hardening — 14 Blind Spots Addressed

Full detail in `SECURITY-AUDIT.md`. Summary:

### Category 1 — Active Malware on the Recovery Machine

**1. Clipboard hijacker replaces sweep address (HIGH)**
Fix: Written address verification ritual — write 8 characters before pasting,
compare 8 characters after. Defeats Laplas Clipper (which spoofs first/last
chars), ClipXDaemon (Linux, Feb 2026), and all known clipboard hijackers.
Also: malware scan guidance before sweeping, ClamAV commands provided.

**2. Screen recording / RAT captures keys (HIGH)**
Fix: Pre-session remote access check. Question set covering recently
installed "recovery tools", external help offers, browser extensions.
Screenshot warning fires before btcrecover prints the found credential.

**3. RAM cold boot attack (MEDIUM)**
Fix: Shut down (not sleep) after recovery. `sudo sdmem -v` optional RAM
clear. Swap clearing instructions per OS.

### Category 2 — Supply Chain Attacks

**4. Fake btcrecover forks on GitHub (HIGH)**
Fix: `verify-btcrecover.sh` checks git remote URL against official repo and
a list of known malicious fork patterns (TCRetriever, demining, etc.).
Run mandatory before first session.

**5. Poisoned SKILL.md (HIGH)**
Fix: Prompt injection awareness in forensics subskill. Typosquat monitoring via `scripts/typosquat-monitor.py` (run manually or add to crontab). All changes tracked via git history.

**6. Compromised Python dependencies (MEDIUM)**
Fix: `pip install --require-hashes` guidance. Virtual environment for
btcrecover isolates dependencies from the rest of the system.

### Category 3 — Social Engineering

**7. Post-viral double-scam targeting (HIGH)**
Fix: 30-day silence recommendation in nuke-session.sh closing message.
Specific guidance: do not post amounts, timing, or wallet addresses publicly.

**8. AI impersonation — "btcrecover support" (HIGH)**
Fix: Added to safety-rules.md §SCAM-DETECTION: "This skill is a file.
It does not have staff. It cannot contact you." Pre-empts the most likely
impersonation vector for this skill specifically.

**9. Fake recovery service double-scam (HIGH)**
Fix: Eight-point verification checklist distinguishing legitimate services
from scams. Key red flags: upfront fee, Telegram/Gmail-only contact, 100%
success guarantee, seed phrase required for "verification."

**10. Prompt injection via wallet file metadata (MEDIUM)**
Fix: Forensics subskill explicitly instructs the AI to treat all file
names and metadata as untrusted data, not instructions.

### Category 4 — Operational

**11. DNS leaks during "offline" recovery (MEDIUM)**
Fix: connectivity-check.sh uses 3-layer check (ICMP → DNS → TCP).

**12. Swap space persists key data (MEDIUM)**
Fix: OS-specific swap clearing instructions in nuke-session.sh output.
Linux: `swapoff -a && swapon -a`. Windows: `cipher /w:C:\`. macOS: delete
sleepimage.

**13. Address display spoofing via browser extension (MEDIUM)**
Fix: Warning in sweep-reminder.sh Step 3 for web-based wallets. Recommends
desktop wallet (Sparrow, Electrum) as sweep destination.

**14. Screenshot of terminal at key display moment (MEDIUM)**
Fix: Warning fires before btcrecover output appears: phone face-down, close
screen recording, do not screenshot to "save for later."

---

## 13. Anti-Impersonation and Authenticity

Full detail in `AUTHENTICITY-AND-LIABILITY.md`. Summary:

### Trust model

The canonical source is `https://github.com/welliv/btcrecover-skill`.
Anyone cloning from this URL gets exactly what the repository owner published.

To verify an installation: check the remote URL after cloning:
```bash
git remote -v
# Must show: origin  https://github.com/welliv/btcrecover-skill
```

CODEOWNERS enforces that security-critical files (SKILL.md, safety-rules.md,
the sweep and nuke scripts, install.sh, verify-btcrecover.sh) require the
repository owner's approval before any pull request can merge.

GPG commit signing and Keybase cross-verification are planned improvements
that will strengthen this model when implemented.

### Clone detection

- Weekly typosquat monitoring via `scripts/typosquat-monitor.py` (add to crontab manually)
- CODEOWNERS file: security-critical files require author approval
- skills.sh canonical listing under the exact registered name

### The VERIFIED.md trust anchor

Published in the repo. States: canonical GitHub URL, and critically — what the real skill never
does. Anyone who receives the skill from outside the canonical URL can compare
against this file.

---

## 14. Liability Protection

Full detail in `AUTHENTICITY-AND-LIABILITY.md`. Summary:

### The three legal protections working together

**1. GPL-2.0 baseline**: Users assume all risks. No warranty expressed
or implied. Standard open source protection.

**2. DISCLAIMER.md**: Plain-English document defining informed consent,
scope limitations, explicit enumeration of what the skill is not liable for.
Specifies jurisdiction. Written in plain English, not legal boilerplate.

**3. Advisor-not-actor architecture**: The most important protection is
structural. The skill generates commands. The user runs them. The skill
never executes anything automatically. It never holds, moves, or transmits
funds. This is the structure of a legal advisor: liable for the quality of
advice, not for what the advisee does with it.

### Consent gates as legal evidence

Every major decision point requires a typed word of confirmation:
`ACCEPT` (first run), `I UNDERSTAND` (Tier 2), `I UNDERSTAND AND ACCEPT`
(Tier 3), `DONE` (post-sweep), `NUKE` (session destruction).

Each confirmation is timestamped in `~/.btcrecover-skill/consent.log`
during the session window. The log is destroyed in the nuke step — its
purpose is contemporaneous evidence during the period when a dispute could
arise, not permanent surveillance.

### Five additional gaps addressed

- **Gap A**: Rate limiting on recovery retries (prevents blind repetition)
- **Gap B**: Cloud sync warning in connectivity-check.sh
- **Gap C**: Windows user guide (WSL2 and Linux USB boot)
- **Gap D**: 2-hour session length limit with checkpoint resume
- **Gap E**: Protocol for test transaction failure (clipboard hijacker detection)

---

## 15. Maintainers and Attribution

Full detail in `MAINTAINERS.md`. The structural philosophy:

Stephen Rothery (3rdIteration) goes first in every attribution document.
Not second. Not in a footnote. First. His tool is what makes recovery
possible. The skill is a UI layer on top of years of his work. The donation
link to his project appears before any other donation address in every
file that mentions donations.

The skill author is listed under "This Skill" — not under a title, not
as "creator" or "founder," but as the person who built this specific layer
with a job description: skill author, security architecture, initial build.

The maintainers table has open slots from day one. This signals that the
project is meant to be collaborative, not owned.

The attribution file also credits @cprkrn (the case that sparked the project)
and Andrej Karpathy ([tweet](https://x.com/karpathy/status/2015883857489522876), [repo](https://github.com/multica-ai/andrej-karpathy-skills)) whose LLM coding observations informed the skill structure.

---

## 16. Roadmap

### v1.0 — Core skill (publish-ready)
All 20 files as documented. The complete implementation detailed in this
document. Ready to publish to skills.sh and GitHub on the day the
skill files are complete and verified.

### v1.1 — Community and hardening
- Community benchmark submission system active
- `scripts/typosquat-monitor.py` available for weekly monitoring (add to crontab manually)
- `agents/claude-code.md`, `agents/cline.md`, `agents/cursor.md`, `agents/generic.md`
- `SECURITY.md` with responsible disclosure policy live
- Windows-specific guidance expanded
- First security audit results incorporated

### v1.2 — Intelligence layer
- Hermes persistent memory integration (recovery context survives sessions)
- Multi-language UX: Spanish, Portuguese, Mandarin (high demand regions)
- Mobile-friendly flow for phone-based recovery sessions
- GPU rental integration guide with cost estimator
- Extended wallet type coverage (Sparrow, Wasabi edge cases, mobile wallets)

### v2.0 — Ecosystem
- Published bounty board for feature development
- Benchmark self-update fully automated
- Official skills.sh verified listing
- btcrecover upstream contribution (the cprkrn concatenation bug fix)

---

## 17. Publishing and Distribution

### Before the first public commit

Complete in this order. Do not skip or reorder.

```
1. Generate a GPG key:
   gpg --gen-key

2. Add GPG key to GitHub:

3. Enable commit signing
   git config --global user.signingkey [fingerprint]
   git config --global commit.gpgsign true

4. Create the GitHub repository
   Name exactly: btcrecover-skill (no variation)
   Set as Public
   Enable branch protection on main
   Require signed commits

5. Add CODEOWNERS file
   @welliv on all security-critical files

6. Fill in placeholders (welliv, email, etc.)
   - MAINTAINERS.md, VERIFIED.md, README.md, install.sh, and agent guides

7. Commit everything and push to main

8. Submit to skills.sh
   npx skills publish
   Canonical name: btcrecover-skill
   Description: use the one from SKILL.md frontmatter verbatim

9. First public announcement
   Post the canonical GitHub URL
```

### The canonical install command (publish this everywhere)

### The canonical install command (publish this everywhere)

```bash
curl -fsSL https://raw.githubusercontent.com/welliv/btcrecover-skill/main/install.sh | bash
```

This command downloads and installs the skill.
It is the only command users should ever run to install this skill.
Any other installation method bypasses the verification chain.

---

## Summary

Thirty-four files. 6,676 lines. Built to address the gap between a powerful
technical recovery tool and the non-technical users who need it most —
with 14 documented security controls, recovery support for 18+ wallet types
across multiple blockchains, offline-first operation, and a post-recovery
protocol that self-destructs all session data after use.

The skill's purpose is not to be impressive. Its purpose is to be the thing
that works when someone who does not know what a derivation path is finds an
old laptop in a closet and wonders if the Bitcoin they bought a decade ago
might still be recoverable.

For those people: this skill is for you. It is free. Run it offline. Trust no one
who contacts you offering to help. Move your funds the moment you get them back.

Then tell no one about it for thirty days.

---

*btcrecover-skill v1.0*
*Built on btcrecover by Stephen Rothery (3rdIteration)*
*GPL-2.0 — free forever*

*Canonical source: https://github.com/welliv/btcrecover-skill*
