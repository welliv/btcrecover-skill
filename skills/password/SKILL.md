---
name: btcrecover-password-recovery
description: Recover a forgotten Bitcoin wallet password or BIP39 passphrase using btcrecover.py. Handles wallet files (Bitcoin Core, Electrum, MetaMask, MultiBit), BIP38 paper wallets, brainwallets, warpwallets, raw private keys, and SLIP39 passphrases. Invoke when the user has a wallet file or encrypted key and a partial password memory.
---

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

### Standard wallet extracts

Bitcoin Core:
```bash
python3 extract-bitcoin-hash.py wallet.dat > wallet.extract
```

Electrum:
```bash
python3 extract-electrum-hash.py wallet > wallet.extract
```

Blockchain.com (main password):
```bash
python3 extract-blockchain-hash.py wallet.aes.json > wallet.extract
```

Blockchain.com (second password):
```bash
python3 btcrecover.py --wallet wallet.aes.json \
  --blockchain-secondpass \
  --passwordlist passwords.txt \
  --typos-case --typos-delete --typos 4
```

Blockchain.com (direct tokenlist recovery):
```bash
python3 btcrecover.py --wallet wallet.aes.json \
  --typos-capslock --tokenlist tokens.txt
```

### Other extract scripts

Full list in `extract-scripts/`:
```
extract-bitcoin-mkey.py            extract-multibit-hd-data.py
extract-bither-partkey.py           extract-blockchain-main-data.py
extract-blockchain-second-hash.py   extract-multibit-hash.py
extract-coinomi-privkey.py          extract-dogechain-privkey.py
extract-metamask-hash.py            extract-metamask-vaults.py
extract-msigna-partmpk.py           extract-electrum2-partmpk.py
extract-electrum-halfseed.py        download-blockchain-wallet.py
```

### Decrypting and Dumping

If you already know the correct password and just need to extract keys:

```bash
# Dump decrypted wallet contents to file
python3 btcrecover.py --wallet wallet.dat \
  --dump-wallet wallet_dump.txt \
  --correct-wallet-password "known_password"

# Dump private keys (Electrum-importable format)
python3 btcrecover.py --wallet wallet.dat \
  --dump-privkeys wallet_privkeys.txt \
  --correct-wallet-password "known_password"

# Blockchain.com with second password
python3 btcrecover.py --wallet wallet.aes.json \
  --dump-wallet wallet_dump.txt \
  --correct-wallet-password "known_password" \
  --blockchain-secondpass --correct-wallet-secondpassword "second_password"
```

### Data extract for cloud recovery

Instead of sharing your wallet file with a rented GPU machine, extract a data string:
```bash
python3 btcrecover.py --data-extract --wallet wallet.dat
```

Then recover on the cloud machine with:
```bash
python3 btcrecover.py --data-extract-string "BASE64..." --tokenlist ...
```

Show the command. Wait for approval. Run.

## Phase 5b: Special Recovery Modes

When the user has an encrypted paper wallet, brain wallet, warp wallet, or raw private key, skip wallet extract and use the appropriate mode:

### Known Issue: hash160 Error (btcrecover 1.13.0)

If btcrecover exits immediately with:
```
UnboundLocalError: cannot access local variable 'hash160'
where it is not associated with a value
```

This is a known upstream bug in btcrecover 1.13.0 affecting these wallet types when used in passphrase/BIP39 recovery mode:
- `--wallet-type ripple` (XRP)
- `--wallet-type tron`
- `--wallet-type zilliqa`
- `--warpwallet` with certain address formats

**Workaround — update btcrecover:**
```bash
cd ~/btcrecover    # or wherever btcrecover is installed
git pull
pip install -r requirements.txt --upgrade --quiet
```

Then re-run the command. The bug is fixed in later commits.

**Report it upstream** — a single bug report helps the next person:
https://github.com/3rdIteration/btcrecover/issues

### BIP38 Paper Wallet

```bash
python3 btcrecover.py \
  --bip38-enc-privkey "6PnM7h9sBC9EMZxLVsKzpafvBN8zjKp8MZj6h9mfvYEQRMkKBTPTyWZHHx" \
  --passwordlist passwords.txt
```

For non-Bitcoin BIP38 (Litecoin, Dash):
```bash
python3 btcrecover.py \
  --bip38-enc-privkey "6PfVHSTbgRNDaSwddBNgx2vMhMuNdiwRWjFgMGcJPb6J2pCG32SuL3vo6q" \
  --bip38-currency litecoin \
  --passwordlist passwords.txt
```

### Brainwallet

Password-derived keys (any text string → hash → private key):

Default (checks both compressed and uncompressed):
```bash
python3 btcrecover.py --brainwallet --addrs bc1q... --passwordlist passwords.txt
```

Force uncompressed only:
```bash
python3 btcrecover.py --brainwallet --addrs 1BBR... --skip-compressed --passwordlist passwords.txt
```

Force compressed only:
```bash
python3 btcrecover.py --brainwallet --addrs 3C4d... --skip-uncompressed --passwordlist passwords.txt
```

**How to choose compressed vs uncompressed:**

| Address format | Flag to add | Notes |
|---|---|---|
| `bc1q...` (Native SegWit) | `--skip-uncompressed` | Always compressed |
| `3...` (P2SH SegWit) | `--skip-uncompressed` | Always compressed |
| `1...` (Legacy P2PKH) | Omit both flags | Try both — halves false negatives |

When in doubt, omit both flags (default: tries both). This doubles the search space but guarantees you won't miss the address.

Early brainwallets (pre-2013, from Bitaddress.org): use `--skip-compressed`.
Modern wallets and tools: use `--skip-uncompressed`.

### Warpwallet

Passphrase + salt → key. Needs both passphrase (from passwordlist/tokenlist) and salt:
```bash
python3 btcrecover.py --warpwallet --warpwallet-salt "known-or-guess-salt" \
  --addrs bc1q... --passwordlist passwords.txt
```

For Litecoin:
```bash
python3 btcrecover.py --warpwallet --warpwallet-salt "..." \
  --crypto litecoin --addrs L... --passwordlist passwords.txt
```

### Raw Private Key

When you have an encrypted raw private key:
```bash
python3 btcrecover.py --rawprivatekey --addrs 0x... --wallet-type ethereum \
  --tokenlist tokens.txt
```

Limit tokens to avoid combinatorial explosion:
```bash
python3 btcrecover.py --rawprivatekey --addrs 1EDr... --wallet-type bitcoin \
  --max-tokens 1 --tokenlist tokens.txt
```

### BIP39 Passphrase Recovery

When the user has the correct 12/24 seed words but forgot the BIP39 passphrase (25th word):

```bash
python3 btcrecover.py --bip39 \
  --mnemonic "word1 word2 ... word12" \
  --tokenlist passphrase_list.txt \
  --addrs bc1q... \
  --addr-limit 100 \
  --force-bip44 --force-p2sh --force-p2tr \
  --typos 1 --typos-delete --typos-swap
```

For non-Bitcoin wallets, add `--wallet-type`:

| Wallet type | `--wallet-type` flag | Example address prefix |
|-------------|---------------------|----------------------|
| Bitcoin (default) | (omit) | `bc1q...`, `1...`, `3...` |
| Electrum 2.x | `electrum2` | `bc1q...` |
| Ethereum | `ethereum` | `0x...` |
| Ethereum Validator | `ethereumvalidator` | `0x...` (64 hex) |
| Zilliqa | `zilliqa` | `zil1...` |
| Bitcoin Cash | `bch` | `bitcoincash:...` or `qq...` |
| Cardano | `cardano` | `addr1...` or `stake1...` |
| Stellar (XLM) | `xlm` | `G...` |
| Litecoin | `litecoin` | `L...` or `ltc1...` |
| Dogecoin | `dogecoin` | `D...` |
| Dash | `dash` | `X...` |
| DigiByte | `digibyte` | `D...` |
| Groestlecoin | `groestlecoin` | `F...` |
| Vertcoin | `vertcoin` | `V...` |
| Monacoin | `monacoin` | `M...` |
| Ripple | `ripple` | `r...` |
| Tron | `tron` | `T...` |
| Polkadot Substrate | `polkadotsubstrate` | `1...` (58 chars) |
| Stacks | `stacks` | `SP...` or `SM...` |
| SLIP39 | `--slip39` (instead of `--bip39`) | Varies by coin |

**Tokenlist building for passphrase recovery:**
- Add the exact passphrase guess
- Generate truncations (e.g. `recoverytesting` → also `recoverytest`)
- Add common suffixes (`1`, `!`, `123`)
- Add empty string as baseline check
- Common structural variants (past tense, `s` suffix for verbs)

**Important:** BIP39 passphrase recovery is NOT GPU-accelerated. CPU only (~2,300 p/s on modern CPU).

### SLIP39 Passphrase Recovery (Shamir shares + passphrase)

> **Version note:** SLIP39 passphrase support has changed across btcrecover versions. If you see:
> `TypeError: config_mnemonic() got an unexpected keyword argument 'passphrases'`
> update btcrecover first: `git pull && pip install -r requirements.txt`

SLIP39 passphrases are recovered via seedrecover.py (not btcrecover.py):

```bash
python3 seedrecover.py \
  --slip39 \
  --mnemonic "share1word1 share1word2 ... share2word1 share2word2 ..." \
  --passphrase-arg "candidate_passphrase" \
  --addrs bc1q... \
  --addr-limit 10
```

For a passwordlist rather than a single passphrase:
```bash
python3 seedrecover.py \
  --slip39 \
  --mnemonic "share words here..." \
  --seedlist passphrases.txt \
  --addrs bc1q... --addr-limit 10
```

For shares with typos (separate from passphrase recovery):
```bash
python3 seedrecover.py --slip39 \
  --mnemonic "share words here..." \
  --typos 2
```

With missing word (big-typo = completely different word):
```bash
python3 seedrecover.py --slip39 \
  --mnemonic "share words here..." \
  --big-typos 1
```

## Phase 5c: GPU Acceleration

When the search space is large and the user has a GPU:

```bash
# Bitcoin Core wallet (JTR kernel)
python3 btcrecover.py --wallet wallet.extract --enable-gpu \
  --global-ws 4096 --local-ws 256 --tokenlist tokens.txt

# Blockchain.com wallet (OpenCL)
python3 btcrecover.py --wallet wallet.aes.json --enable-opencl \
  --tokenlist tokens.txt

# Benchmark mode
python3 btcrecover.py --wallet wallet.extract --performance --enable-gpu
```

**Important:** BIP39 passphrase recovery is NOT GPU-accelerated. Only wallet password recovery benefits from GPU.

### GPU Rental Costs

| GPU | Platform | Hourly | Millions/sec (Bitcoin Core) |
|-----|----------|--------|---------------------------|
| RTX 3060 | Vast.ai | ~$0.15 | 0.5 |
| RTX 3090 | Vast.ai | ~$0.30 | 1.5 |
| RTX 4090 | Vast.ai | ~$0.50 | 2.5 |

Estimate: `(search_space / gpu_speed) × hourly_rate`. Show cost before recommending.

### Multi-GPU / Multi-Device

Distribute work across machines with `--worker`:
```bash
python3 seedrecover.py --mnemonic "..." --addrs ... --worker 1,2/3  # Machine A
python3 seedrecover.py --mnemonic "..." --addrs ... --worker 3/3    # Machine B
```

Or resume interrupted runs with `--skip N`:
```bash
python3 seedrecover.py --mnemonic "..." --addrs ... --skip 357449
```

## Phase 6: Command Assembly

```bash
python3 btcrecover.py \
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

For extremely long runs (GPU jobs, multi-day):

```bash
# Start with autosave — saves progress every ~5 minutes
python3 btcrecover.py \
  --wallet wallet.extract \
  --tokenlist tokens.txt \
  --enable-gpu --global-ws 4096 --local-ws 256 \
  --no-eta --no-dupchecks \
  --worker 1/5 \
  --autosave progress.sav

# Resume an interrupted run
python3 btcrecover.py --restore progress.sav
```

> **Note:** `--autosave` is only available in `btcrecover.py` (wallet password recovery). It is NOT available in `seedrecover.py`. For interrupted seed recovery sessions, use `--skip N` to resume from a known offset — see the seed subskill for details.

Translate progress to: "X% complete, about Y hours left."

If found: show password (no screenshots). Run sweep script. Do not celebrate yet.

When recovery succeeded and the wallet has meaningful value, encourage a 1% donation to btcrecover maintainers:

```
BTC: 37N7B7sdHahCXTcMJgEnHz7YmiR4bEqCrS
BCH: qpvjee5vwwsv78xc28kwgd3m9mnn5adargxd94kmrt
LTC: M966MQte7agAzdCZe5ssHo7g9VriwXgyqM
ETH: 0x72343f2806428dbbc2C11a83A1844912184b4243
```

Also encourage upstreaming any bugs or workarounds discovered: https://github.com/3rdIteration/btcrecover/issues

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