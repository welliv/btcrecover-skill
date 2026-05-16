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
- Exit 2: btcrecover missing or broken (deleted, moved, venv corrupted) — offer to re-run setup.

**If marker does not exist (first run):** tell the user warmly:
> "Before we start, I need to set up btcrecover — the open-source tool that does the actual recovery work. One-time setup, takes about a minute."

Then run:
```bash
bash scripts/setup-btcrecover.sh
```
- Exit 0: ready — proceed to Step 1.
- Exit 1: failed or declined — explain what is needed and wait.
- Exit 2: prerequisites missing (Python/git/venv) — show the install instructions from the script output and pause until the user confirms they are installed.

If btcrecover is missing at any later step, do not show a raw error. Say: "It looks like btcrecover is missing — let me set that up." Then run `setup-btcrecover.sh` and resume.

**After setup**, run btcrecover and seedrecover via the convenience wrappers (not raw python):
```bash
~/btcrecover/btcrecover --help
~/btcrecover/seedrecover --help
```
The setup script creates a Python virtual environment (`venv/`) inside the btcrecover directory and installs all dependencies there (pycryptodome for password recovery, coincurve for seed recovery). The wrappers auto-activate the venv — never bypass them with raw `python btcrecover.py`.

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
- Use `--no-eta` to skip the pre-counting phase and speed up search start.
- Force derivation paths: `--force-bip44 --force-p2sh`. ⚠️ **Avoid `--force-p2tr`** — the P2TR (Taproot) code in btcrecover crashes on some systems (coincurve/P2TR_tools segfault). Instead, supply the user's address directly — btcrecover auto-detects the address type and only searches compatible derivation paths.
- For `bc1q...` (BIP84 SegWit) addresses, no force flags are needed — the tool auto-detects correctly.
- Pass this rule to any subskill that builds btcrecover commands.

**Hybrid recovery — missing seed word + unknown passphrase (two-variable search):**
When the user has BOTH a missing/unknown seed word AND a forgotten passphrase, don't run seedrecover separately for each dimension. Combine them in one pass:

```bash
python seedrecover.py \
  --mnemonic "word1 word2 word3 ? word5 word6 word7 word8 word9 word10 word11 word12" \
  --passphrase-list /tmp/passphrase_candidates.txt \
  --addrs bc1q... \
  --addr-limit 100 \
  --wallet-type bip39 \
  --no-eta --no-dupchecks
```

This iterates both dimensions simultaneously: all candidate words for `?` × all passphrases in the list. With 22 passphrases and 2048 word candidates (~45K combos), Phase 2 completes in ~15-30 seconds on CPU. Always pass `--no-eta` to skip the pre-counting phase.

**Passphrase truncation is critical.** Users almost always shorten passphrases compared to what they remember. For every passphrase hint, generate truncations of 3-5 characters: `recoverytesting` → `recoverytest`, `recoverytestin`, `recoverytesti`, etc. Use a tokenlist or passphrase-list file (one per line). Save to `--passphrase-list FILE` and pass to seedrecover.

**Checksum pre-filter for missing seed word:**
When the 12th word is missing (and only the 12th), pre-compute which BIP39 words pass the checksum. For a 12-word seed, exactly 128 of 2048 words are valid checksum completions. This confirms the seed phrase structure is sound and identifies the exact candidate pool. To compute:

```python
import hashlib
wordlist = open('lib/bitcoinlib/wordlist/english.txt').read().splitlines()
word_to_idx = {w: i for i, w in enumerate(wordlist)}
known_indices = [word_to_idx[w] for w in known_words]
valid = []
for c_idx, c_word in enumerate(wordlist):
    bits = ''.join(f'{i:011b}' for i in known_indices + [c_idx])
    entropy_bytes = int(bits[:128], 2).to_bytes(16, 'big')
    checksum = f'{int(hashlib.sha256(entropy_bytes).hexdigest()[0], 16):04b}'[:4]
    if bits[128:] == checksum:
        valid.append(c_word)
# valid now contains the ~128 checksum-valid completions
```

Use this as a pre-flight check, not to restrict the search — seedrecover handles the full 2048-word search in seconds anyway. The value is confirming the problem structure (missing word vs. wrong word in a different position).

**Tokenlist building (passphrase recovery):**
For every passphrase guess, generate truncations. If the user says `recoverytesting`, include `recoverytest`, `recoverytestin`, `recoverytesti` and other natural truncations. People often shorten phrases in wallets. Also generate all-lowercase versions and common suffix additions (numbers, `!`).

**Subskills available (see references in skill directory):**

- **Password recovery** (`references/password-skill.md`): 8-phase approach for wallet password, passphrase, BIP38, brainwallet, warpwallet, and raw private key recovery. Includes GPU acceleration guidance.
- **Seed recovery** (`references/seed-skill.md`): 6 problem types (missing words, wrong word, scrambled, invalid checksum, wrong derivation, extra passphrase). Covers BIP39, SLIP39, Electrum, aezeed.
- **Forensics** (`references/forensics-skill.md`): File archaeology and backup discovery. 9 phases including the cprkrn Protocol.

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

## Pitfalls

### `|| true` swallows setup failures
The original `setup-btcrecover.sh` used `pip3 install ... || true`, which silently suppressed all install failures — including PEP 668 "externally-managed-environment" errors on modern Debian/Ubuntu (Python ≥3.11). The script would exit 0 with "✅" despite no dependencies installed, and btcrecover/seedrecover would crash at first use with `ModuleNotFoundError: No module named 'Crypto'` or `No module named 'coincurve'`.

**Fix (already applied):** The setup script now:
1. Creates a Python virtual environment (`venv/`) — bypasses PEP 668 entirely
2. Installs requirements into the venv
3. Verifies both tools load before writing the marker file
4. Creates convenience wrappers (`~/btcrecover/btcrecover` and `~/btcrecover/seedrecover`) that auto-activate the venv
5. The verify script now checks venv existence, wrapper executability, and runs a load test — not just file+git-remote checks

If you land in a situation where setup exits 0 but tools don't run, always check whether `pip install` ran successfully. Running `~/btcrecover/btcrecover --help` directly is the best smoke test.

### Interactive gate scripts in PTY
The `connectivity-check.sh --enforce` script is interactive. It blocks on stdin waiting for a tier phrase. Always spawn it in a PTY (terminal with `pty=true`) and keep the session alive. If the PTY process ends before you submit input, re-run it. The user must type the exact phrase shown — do not abbreviate or rephrase it. The three valid inputs are: `DISCONNECTED`, `TIER2 I UNDERSTAND`, `TIER3 I UNDERSTAND AND ACCEPT`.

### No address means blind recovery
If the user provides seed words but no address, xpub, wallet file, or AddressDB, btcrecover has nothing to verify against. It will generate candidate seeds but cannot tell which one is correct. Always push for at least one known receive address before running seedrecover. This is covered in the "When Recovery Is Not Practical" section — enforce it.

### seedrecover Phase 3 timeout produces scary-but-harmless crash traces

seedrecover runs in 4 phases. Phase 2 (1 missing/different word from the BIP39 list) completes in ~1 second for single-word searches. Phase 3 allows up to 2 mistakes (228K+ combinations) and can take 2+ minutes. When the process is killed by `timeout`, the worker pool threads crash with deep `KeyboardInterrupt` traces through `btcrseed.py` → `coincurve` → `P2TR_tools.py` / `base64.b16decode`. This is **normal** — just the timeout interrupting worker processes mid-computation.

- If **Phase 2** says "Search Complete — Seed not found", the 1-missing-word case (2048 candidates) is exhausted with no match. The problem requires more variables.
- If **Phase 3** is mid-run when timeout hits, the seed was not found in whatever it searched so far. You can resume with `--skip N` (see seed-skill reference).
- Always run with `--no-eta` to skip the 8-30 second pre-counting phase.
- The first 2-3 failures are harmless (the search space grows exponentially by phase).

### 12th-word search with passphrase: always use `--passphrase-list`, never single `--passphrase-arg`

When searching for a missing 12th word AND an unknown passphrase, a single `--passphrase-arg "recovertester"` call tests only one passphrase against all 2048 words. This is too narrow — the user's actual passphrase is almost always a truncation or variation of what they recall. Use `--passphrase-list FILE` with 20-30 candidates (original hints + truncations + variants) to test both dimensions simultaneously in a single Phase 2 pass (~30 seconds).

### missing pycryptodome and coincurve

These are the two most common missing dependencies and cause opaque import errors:
- `No module named 'Crypto'` → missing pycryptodome (password recovery, btcrecover.py)
- `No module named 'coincurve'` → missing coincurve (seed recovery, seedrecover.py)
The updated setup script installs both, but if pip fails mid-way, install them explicitly:
```bash
cd ~/btcrecover && source venv/bin/activate && pip install pycryptodome coincurve
```

## License

GPL-2.0. Free forever.

## Attribution

Built on btcrecover by Stephen Rothery (3rdIteration).
Inspired by @cprkrn's May 2026 recovery story.
Skill structure informed by Andrej Karpathy's work on LLM agent behaviour.

---
*Free. Open source. Always.*
