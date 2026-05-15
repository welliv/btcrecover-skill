# Password Recovery

Handles password and passphrase recovery for Bitcoin wallets using btcrecover.

## Safety

- All commands need your approval
- No automatic wallet access or fund movement
- Session data destroyed after use

## Phase 1: Memory Interview

Do not ask "what was your password?" directly. Probe for anchors instead.

What were you doing when you created this wallet? What music did you listen to? What games did you play? What was happening in your life? Did you use a password manager?

On the password: any part you remember? Single word, phrase or random? Numbers? Dates? Special characters? Length? Capitalisation?

On the wallet: what software? When did you create it? Have you opened it before? Any old backups?

Previous attempts: what have you tried? Do you remember passwords for other services from that time?

Build a profile: known fragments, probable patterns, estimated length, character set, confidence.

## Phase 2: Search Space

| Space | CPU | GPU | Feasibility |
|-------|-----|-----|-------------|
| < 1M | Seconds | Seconds | Easy |
| 1M–1B | Minutes to hours | Seconds to minutes | Feasible |
| 1B–1T | Hours to days | Minutes to hours | May need GPU |
| > 1T | Days to weeks | Hours to days | GPU rental needed |

For over 10 trillion with no GPU, show rental costs. Vast.ai: RTX 4090 ~$0.50/hr, RTX 3090 ~$0.30/hr.

## Phase 3: Tokenlist

Build from fragments + anchors + common patterns. Show the user before running.

Common patterns: pet names + numbers, birth years, keyboard walks, leet speak, suffixes (123, !, 1!), dates.

## Phase 4: Typo Mutation

Select btcrecover typo flags based on likely errors. Reference: `references/typo-patterns.md`.

If confident: `--typos 1` with case swap. If unsure: `--typos 2`. If leet suspected: add `--typos-replace`.

## Phase 5: Wallet Extract (Tier 2 Only)

Bitcoin Core:
```bash
python extract-bitcoin-hash.py wallet.dat > wallet.extract
```

Electrum:
```bash
python extract-electrum-hash.py wallet > wallet.extract
```

Blockchain.com:
```bash
python extract-blockchain-hash.py wallet.aes.json > wallet.extract
```

Show the command. Wait for approval. Run.

## Phase 6: Command Assembly

```bash
python btcrecover.py \
  --wallet wallet.extract \
  --tokenlist tokenlist.txt \
  --typos 1 --typos-case --typos-swap \
  --threads 4 --checkpoint
```

Explain each flag in plain English. Wait for approval.

## Phase 7: Run and Monitor

Under 30 minutes: run directly.

Over 30 minutes:
```bash
bash scripts/session-manager.sh start
```

Translate progress to: "X% complete, about Y hours left."

If found: show password (no screenshots). Run sweep script. Do not celebrate yet.

## Phase 8: If Nothing Works

1. Increase typos to 2
2. Expand tokenlist
3. Try different wallet extract
4. Try passphrase mode
5. Escalate to forensics (find older backups)
6. GPU rental

If still impossible, tell the user honestly. No false hope.