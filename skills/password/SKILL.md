# Password Recovery Sub-Skill

## Overview
Handles password and passphrase recovery for Bitcoin wallets using btcrecover. Eight phases from initial interview through escalation.

## Safety Rules
- All btcrecover commands require explicit user approval
- No automatic wallet access or fund movement
- Session data is destroyed after completion
- Never share seed phrases or private keys with anyone

---

## Phase 1: Deep Memory Interview

**Goal:** Extract maximum password-relevant information from the user's memory.

Do NOT ask "what was your password?" directly. Instead, probe for contextual anchors — what the user was doing, listening to, playing, working on at the time they created the password. These unlock password memory more reliably than direct questions.

### Interview Questions (adapt based on user responses):

**Contextual anchors:**
- What were you doing when you created this wallet? (working, gaming, specific project)
- What music were you listening to? What games were you playing?
- What was happening in your life at that time?
- Did you use a password manager? Which one?
- Do you remember any password patterns from that era?

**Password structure:**
- Do you remember any part of the password? Even a single character or word?
- Was it a single word, a phrase, or random characters?
- Did you use any numbers? Dates? Special characters?
- How long do you think it was? (rough estimate)
- Did you use capital letters? Where?

**Wallet context:**
- What wallet software did you use? (Bitcoin Core, Electrum, etc.)
- When did you create the wallet? (approximate date)
- Have you ever successfully opened this wallet before?
- Do you have any old backups of the wallet file?

**Previous attempts:**
- Have you tried to recover this password before?
- What methods have you tried?
- Do you remember any passwords you've used for other services from that time?

### Output:
Build a structured profile:
```
Known fragments: [list]
Probable patterns: [list]
Estimated length: [range]
Character set: [lowercase, uppercase, numbers, symbols]
Contextual anchors: [list]
Confidence: HIGH | MEDIUM | LOW
```

---

## Phase 2: Search Space Estimation

**Goal:** Calculate the size of the password search space and present it in human terms.

Based on the interview results, estimate:
- Tokenlist size (number of base words)
- Mutation rules (typo patterns to apply)
- Total search space = tokenlist_size × mutation_combinations

### Present in human terms:

| Search Space | Time (CPU) | Time (GPU) | Feasibility |
|---|---|---|---|
| < 1 million | Seconds | Seconds | ✅ Trivial |
| 1M - 1B | Minutes to hours | Seconds to minutes | ✅ Feasible |
| 1B - 1T | Hours to days | Minutes to hours | ⚠️ May need GPU |
| > 1T | Days to weeks | Hours to days | 🔴 GPU rental recommended |

If > 10 trillion and no GPU: provide GPU rental guidance with cost estimates.

### GPU Rental Guidance:
- Vast.ai: ~$0.50/hour for RTX 4090
- Vast.ai: ~$0.30/hour for RTX 3090
- Estimated cost = (search_space / gpu_speed) × hourly_rate
- Always show cost estimate before recommending rental

---

## Phase 3: Tokenlist Construction

**Goal:** Build a customized tokenlist based on the interview results.

### Tokenlist format (one per line):
```
base_word1
base_word2
base_word3
...
```

### Construction rules:
1. Start with known fragments (exact words the user remembers)
2. Add contextual anchors (pet names, dates, interests from the interview)
3. Add common password patterns from the era
4. Add variations (capitalization, leet speak, common suffixes)
5. Show the tokenlist to the user with plain-English explanation before running

### Common password patterns to include:
- Pet names + numbers
- Birth years and dates
- Keyboard walks (qwerty, asdfgh)
- Common substitutions (a→@, s→$, e→3, i→1, o→0)
- Common suffixes (123, !, !!, 1!, 2014, 2015, 2016)
- Repeated characters

---

## Phase 4: Typo Mutation Selection

**Goal:** Select appropriate btcrecover typo flags based on the user's likely errors.

Reference: `references/typo-patterns.md`

### Common typo flags:
```
--typos 1                    # Allow 1 typo per word
--typos 2                    # Allow 2 typos per word
--typos-case                 # Case toggling
--typos-swap                 # Adjacent character swap
--typos-repeat               # Repeated characters
--typos-delete               # Deleted characters
--typos-replace              # Character replacement
--typos-insert               # Inserted characters
```

### Selection logic:
- If user is confident in the base words: use `--typos 1` with `--typos-case --typos-swap`
- If user is uncertain: use `--typos 2` with more mutation flags
- If user suspects leet speak: add `--typos-replace`
- Always explain the mutation strategy in plain English before running

---

## Phase 5: Wallet Extract (Tier 2)

**Goal:** Extract the wallet data for btcrecover to attack.

**For Tier 1 (offline):** Run locally, no data leaves the machine.
**For Tier 2 (cloud reasoning):** Use extract scripts to ensure the wallet file never goes near the API.

### Extract commands by wallet type (reference: `references/wallet-types.md`):

**Bitcoin Core:**
```bash
python extract-bitcoincoin-hash.py wallet.dat > wallet.extract
```

**Electrum:**
```bash
python extract-electrum-hash.py wallet > wallet.extract
```

**Blockchain.com:**
```bash
python extract-blockchain-hash.py wallet.aes.json > wallet.extract
```

Show the command to the user in plain English. Wait for approval. Run.

---

## Phase 6: Command Assembly

**Goal:** Build the complete btcrecover command.

### Base command structure:
```bash
python btcrecover.py \
  --wallet wallet.extract \
  --tokenlist tokenlist.txt \
  --typos 1 \
  --typos-case \
  --typos-swap \
  --passwordlist passwordlist.txt \
  --threads 4 \
  --checkpoint
```

### Explain each flag in plain English:
- `--wallet`: The wallet file we're trying to open
- `--tokenlist`: The list of base words from our interview
- `--typos`: How many mistakes to try per word
- `--passwordlist`: Additional passwords to try
- `--threads`: How many CPU cores to use
- `--checkpoint`: Save progress so we can resume if interrupted

### Show the complete command to the user. Wait for explicit approval.

---

## Phase 7: Launch and Monitor

**Goal:** Run btcrecover and monitor progress.

### For short jobs (< 30 minutes):
Run directly and wait for result.

### For long jobs (> 30 minutes):
```bash
bash scripts/session-manager.sh start
```

This wraps btcrecover in a managed session with automatic checkpointing.

### Progress monitoring:
- Parse btcrecover's native output
- Translate to plain English: "X% complete, estimated Y hours remaining"
- Report at each milestone (25%, 50%, 75%)
- If progress stalls, alert the user and suggest alternatives

### If password found:
1. Display the found password (warn user not to screenshot)
2. Immediately initiate post-recovery protocol (sweep-reminder.sh)
3. Do NOT celebrate — remind user that accessible ≠ safe

---

## Phase 8: Escalation on Failure

**Goal:** If the initial search fails, expand systematically.

### Escalation order:
1. **Expand typo mutations:** Increase from `--typos 1` to `--typos 2`
2. **Expand tokenlist:** Add more contextual anchors, common passwords
3. **Try different wallet extract:** May be a different wallet format
4. **Try passphrase mode:** The "password" might be a BIP39 passphrase
5. **Escalate to forensics:** Look for wallet backups that predate the password change
6. **GPU rental:** If search space is too large for CPU

### Honest assessment:
If the search space exceeds what is feasible even with GPU rental, tell the user honestly. Do not give false hope. Suggest:
- Taking a break and trying again later (memory may surface)
- Professional recovery services (with scam warnings from safety-rules.md)
- Accepting the loss if the wallet value doesn't justify further effort