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
  --threads 4 \
  --addr-limit 100 \
  --force-bip44 --force-p2sh --force-p2tr \
  --checkpoint
```

**Always include these flags:**
- `--addr-limit 100` — checks 100 address indices per derivation path. Funds may be at a change address (index 15, 27, etc.), not just index 0. Do not assume index 0.
- `--force-bip44 --force-p2sh --force-p2tr` — forces all derivation paths. btcrecover auto-detects the address type from `--addrs` and skips non-matching types, but wallet software sometimes uses multiple types within the same wallet.
- If the user provided a known address, include `--addrs ADDRESS` so btcrecover stops instantly on first match.

**Tokenlist building:**
For passphrase recovery, generate truncations of every user guess. If the user says the phrase was `recoverytesting`, also include `recoverytest`, `recoverytestin`, `recoverytesti`. People naturally shorten phrases when typing into a wallet. Also include empty string (no passphrase) as a baseline check.

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
2. Expand tokenlist — include truncations, common suffixes, leet speak variants
3. Try different wallet extract
4. **Diagnostic: verify the seed alone** — run btcrecover with `--mnemonic` and `--addrs` but no tokenlist (empty passphrase). If the address doesn't match with no passphrase, the seed itself may be wrong or the address belongs to a different wallet.
5. **Diagnostic: expand address search** — increase `--addr-limit` to 500 or 1000. Funds may be deep in the change chain.
6. **Diagnostic: try all derivation paths individually** — if `--force-bip44 --force-p2sh --force-p2tr` didn't work, try each path separately with a wider address range. Some wallets use non-standard paths.
7. **Ask the user for more clues** — length, theme, numbers, symbols, when the wallet was created, what software was used. A single new clue can collapse the search space.
4. Try passphrase mode
5. Escalate to forensics (find older backups)
6. GPU rental

If still impossible, tell the user honestly. No false hope.