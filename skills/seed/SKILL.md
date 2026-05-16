---
name: btcrecover-seed-recovery
description: Recover a BIP39/SLIP39/Electrum seed phrase with missing, wrong, or scrambled words using seedrecover.py. Handles 1-4 missing words, wrong-word typos, scrambled order, invalid checksum, and wrong derivation paths across 18+ wallet types. Invoke when the user has most of their seed phrase but cannot access their wallet.
---

# Seed Recovery

Handles mnemonic (BIP39, SLIP39, Electrum, aezeed) seed-level issues using seedrecover.py.
For passwords/passphrases on the wallet file, use the password subskill instead.

## Safety

- All commands need your approval
- seedrecover.py works offline — check connectivity first
- No automatic wallet access or fund movement
- If the user has no address, no xpub, no wallet file, and no AddressDB — recovery is blind. Tell them clearly.

### When Seed Recovery Is Not Practical

Be honest about feasibility:

- **No address, no xpub, no wallet file** → nothing to verify against. seedrecover has to run in checksum-only mode, which provides no guarantee the result is correct.
- **4+ missing words, no address** → ~17 trillion possibilities. Weeks of GPU time. Almost never worth attempting.
- **3+ missing words, no address** → effectively impossible. Even with an address, it's a large GPU job.
- **User has "no idea" about the phrase** — no words, no length, no theme → seedrecover needs at least a guess.

When recovery is not practical, say so. Explain what information would change the picture.

## Problem Types

| Type | Problem | Approach |
|------|---------|----------|
| Missing words | 1–4 unknown words | seedrecover with `?` placeholders |
| Wrong word | Some words may be wrong | `--big-typos` or expanded tokenlist |
| Scrambled | Words known, order unknown | `--dsw` + tokenlist with positional anchors |
| Swapped | Words in wrong positions | `--transform-wordswaps N` |
| Invalid | Checksum fails | Last word correction (~128 options) |
| Wrong derivation | Correct seed, wrong path | Force BIP44/49/84/86 |
| Extra passphrase | Seed + unknown 25th word | Route to password subskill |
| SLIP39 | Shamir shares | `--slip39` mode |
| Wrong language | Non-English BIP39 | `--language FR`, `--language ES`, etc. |

## seedrecover.py Basics

Two input modes:

1. **Mnemonic string** (`--mnemonic "word1 word2 ? word4 ..."`): Place unknowns with `?`
2. **Tokenlist** (`--tokenlist words.txt`): Word candidates for combination/descrambling
3. **Seedlist** (`--seedlist seeds.txt`): One seed phrase per line

Always include `--addr-limit 100` and `--force-p2sh` when a known address is available.

## Missing Words

Use `?` for each unknown word.

- 1 missing: 2048 tries (seconds)
- 2 missing: 4 million (minutes)
- 3 missing: 8.6 billion (hours CPU, minutes GPU)
- 4 missing: 17 trillion (GPU rental)

```bash
python3 seedrecover.py \
  --mnemonic "word1 word2 ? word4 word5 ? word7 word8 word9 word10 word11 word12" \
  --addrs bc1q... \
  --addr-limit 100 \
  --wallet-type bip39
```

Larger search spaces benefit from multi-device distribution:
```bash
python3 seedrecover.py --mnemonic "..." --addrs ... --worker 1,2/3  # PC1: slices 1+2 of 3
python3 seedrecover.py --mnemonic "..." --addrs ... --worker 3/3    # PC2: slice 3 of 3
```

## Descrambling (Known Words, Unknown Order)

12 words → 479 million permutations (feasible with positional hints).
24 words → infeasible without position hints.

Use `--dsw` (descramble with wildcards) + tokenlist with positional anchors:

**Tokenlist with positional anchors:**
```
^1^word1
^2^word6
^5^word4
+ word2 word3 word9    # required, unknown order
word5 word7 word8      # optional decoys
word10 word11 word12
```

Positional anchors (`^N^word`) fix known positions. `+` makes tokens required. Same-line tokens are mutually exclusive (at most one chosen).

```bash
python3 seedrecover.py \
  --no-dupchecks \
  --mnemonic-length 12 \
  --language EN \
  --dsw \
  --wallet-type bip39 \
  --addr-limit 1 \
  --addrs bc1q... \
  --tokenlist words.txt
```

For comma-separated token groups (words that must appear together in order):
```bash
python3 seedrecover.py --dsw --no-dupchecks \
  --mnemonic-length 24 \
  --tokenlist tokengroups.txt \
  --addrs bc1q... --addr-limit 10 \
  --wallet-type bip39 \
  --max-tokens 9 --min-tokens 8
```

Token groups example (`tokengroups.txt`):
```
^basic,dawn,renew,punch,arch,situate
arrest,question,armor
hole,lounge,practice
resist
zoo,zoo,zoo
```
Each comma-separated group stays together. `--min-tokens 8` = use at least 8 groups. `--max-tokens 9` = use at most 9 groups.

### Swapped Words

When you know all words but they may be in the wrong order. Complexity:
- 12-word seed: 1 swap = 67 tries, 2 swaps = 4,423, 3 swaps = 291,919
- 24-word seed: 1 swap = 277 tries, 2 swaps = 76,453

```bash
python3 seedrecover.py \
  --mnemonic "word1 word2 word3 word4 word5 word6 word7 word8 word9 word10 word11 word12" \
  --addrs bc1q... \
  --addr-limit 100 \
  --transform-wordswaps 2 \
  --typos 0 \
  --wallet-type bip39
```

`--typos 0` disables typo checking when you only need swaps.

## Wrong Word (Big Typos)

For SLIP39 or BIP39 with wrong multiple words:
```bash
python3 seedrecover.py --mnemonic "..." --addrs ... --big-typos 2
```

Big typos = different BIP39 words, not just character-level typos.

For BIP39 with tokenlist alternatives:
```bash
python3 seedrecover.py --no-dupchecks --dsw --wallet-type bip39 \
  --addrs ... --addr-limit 100 \
  --tokenlist words.txt \
  --mnemonic-length 12 --language EN
```

## Invalid Checksum

If you know all words but the checksum fails, the last word in a 12-word seed has ~128 valid alternatives. Try replacing the last word with `?`.

```bash
python3 seedrecover.py \
  --mnemonic "word1 word2 word3 word4 word5 word6 word7 word8 word9 word10 word11 ?" \
  --addrs bc1q... \
  --addr-limit 100 \
  --wallet-type bip39
```

## SLIP39 (Shamir Backup)

SLIP39 shares have a different format than BIP39. Words may be from a different wordlist.
```bash
python3 seedrecover.py --slip39 --mnemonic "share words here..." --typos 2
```

```bash
python3 seedrecover.py --slip39 --mnemonic "share words..." --big-typos 2
```

## Wrong Derivation Path

When the seed is correct but the address type doesn't match your wallet:

```bash
python3 seedrecover.py \
  --mnemonic "word1 word2 ... word12" \
  --addrs ... \
  --addr-limit 100 \
  --wallet-type bip39 \
  --bip32-path "m/44'/0'/0'/0,m/49'/0'/0'/0,m/84'/0'/0'/0,m/86'/0'/0'/0"
```

For specific coins like Litecoin:
```bash
--bip32-path "m/84'/2'/0'/0"
```

For non-standard wallets:
- **Atomic Wallet (ETH):** `--checksinglexpubaddress`
- **CoolWallet S (BTC/LTC):** `--force-p2sh`

## Extra Passphrase

The passphrase is like a password appended to the seed. Route to password subskill.

```bash
python3 btcrecover.py \
  --bip39 \
  --mnemonic "word1 word2 ... word12" \
  --tokenlist passphrase_list.txt \
  --addrs bc1q... \
  --addr-limit 100 \
  --force-bip44 --force-p2sh --force-p2tr \
  --typos 1 --typos-delete --typos-swap
```

## Wallet Types (seedrecover.py --wallet-type)

| Value | Wallets |
|-------|---------|
| `bip39` | Bitcoin, Litecoin, Dogecoin, Dash (most BIP39 wallets) |
| `electrum1` | Electrum 1.x (legacy) |
| `electrum2` | Electrum 2.x (SegWit) |
| `ethereum` | Ethereum, MEW, MyCrypto |
| `ethereumvalidator` | Ethereum 2.0 validator keys |
| `cardano` | Cardano (Daedalus, Yoroi, AdaLite) |
| `aezeed` | LND (Lightning Network Daemon) |
| `xlm` | Stellar |
| `tron` | Tron |
| `polkadotsubstrate` | Polkadot, Kusama, Substrate chains |
| `stacks` | Stacks blockchain |
| `elrond` | Elrond (now MultiversX) |
| `hederaed25519` | Hedera Hashgraph |
| `helium` | Helium (HNT) |
| `blockchainpasswordv3` | Blockchain.com legacy recovery mnemonic |

### Wallet Type Example Commands

**Ethereum (missing words):**
```bash
python3 seedrecover.py --wallet-type ethereum \
  --mnemonic "word1 ? word3 word4 ? word6 ..." \
  --addrs 0x... --addr-limit 100
```

**Cardano — Ledger seed, with stake address:**
```bash
python3 seedrecover.py --wallet-type cardano \
  --mnemonic "..." --addrs addr1... --addr-limit 5
```

**Polkadot Substrate — custom derivation path:**
```bash
python3 seedrecover.py --wallet-type polkadotsubstrate \
  --mnemonic "..." --addrs 1... \
  --substrate-path "//hard/soft///password"
```

**Stellar (XLM):**
```bash
python3 seedrecover.py --wallet-type xlm \
  --mnemonic "..." --addrs G... --addr-limit 2 --no-eta
```

**Hedera Hashgraph:**
```bash
python3 seedrecover.py --wallet-type hederaed25519 \
  --mnemonic "..." --addrs 0x... --addr-limit 1
```

**Helium (HNT):**
```bash
python3 seedrecover.py --wallet-type helium \
  --mnemonic "..." --addrs ... --addr-limit 2
```

**Elrond (MultiversX):**
```bash
python3 seedrecover.py --wallet-type elrond \
  --mnemonic "..." --addrs erd1... --addr-limit 2
```

**Tron:**
```bash
python3 seedrecover.py --wallet-type tron \
  --mnemonic "..." --addrs T... --addr-limit 1
```

**Stacks:**
```bash
python3 seedrecover.py --wallet-type stacks \
  --mnemonic "..." --addrs SP... --addr-limit 10
```

**Blockchain.com legacy v3 recovery mnemonic:**
```bash
python3 seedrecover.py --wallet-type blockchainpasswordv3 \
  --mnemonic "carve witch manage ..." --mnemonic-length 17
```

**Electrum Legacy (electrum1):**
```bash
python3 seedrecover.py --wallet-type electrum1 \
  --mnemonic "..." --addrs 1... --addr-limit 2
```

**Ethereum Validator (uses pubkey as address):**
```bash
python3 seedrecover.py --wallet-type ethereumvalidator \
  --mnemonic "..." --addrs 0x... --addr-limit 1
```

## aezeed (LND Lightning)

Add custom passphrase if needed:
```bash
python3 seedrecover.py --wallet-type aezeed \
  --mnemonic "..." --addrs ... --addr-limit 5
  --passphrase-arg "YOUR PASSPHRASE"
```

For checksum-only mode (no address known), omit `--addrs`.

## Non-English Languages

BIP39 supports: Chinese, French (`FR`), Italian (`IT`), Japanese (`JP`), Korean (`KO`), Spanish (`ES`).

```bash
python3 seedrecover.py --mnemonic "..." --addrs ... \
  --language FR --wallet-type bip39 \
  --addr-limit 100
```

## AddressDB Recovery

When you don't know the wallet type or derivation path:

```bash
python3 seedrecover.py --addressdb addresses-BTC.db \
  --wallet-type bip39 --mnemonic "..." \
  --addr-limit 2 --no-dupchecks
```

Bitcoin AddressDB needs ~16GB (DBLength 31). RAM ~2x DB size.
See `references/wallet-types.md` for AddressDB creation commands.

## Debugging

Use `--listpass` to see which seed phrases would be tried:
```bash
python3 seedrecover.py --listpass --tokenlist words.txt --mnemonic-length 12 --language EN
```

## Performance

- seedrecover runs in 4 phases by default: single typo, 2 typos + 1 different word, 3 typos + 1 different word, 2 typos as different words
- Use `--no-dupchecks` to reduce RAM usage and speed up
- Use `--no-eta` to skip the counting phase (speeds up start)
- For large searches: `--worker` across multiple machines or `--skip` to resume

### Compute Time by Wallet Type

Some wallet types require significantly more time because their key derivation is more expensive or their BIP39 wordlists are larger.

| Wallet type | 1 missing word | 1 wrong word (`--big-typos 1`) | GPU recommended? |
|---|---|---|---|
| `bip39` (Bitcoin) | Seconds | ~2-5 min | No |
| `ethereum` | Seconds | ~2-5 min | No |
| `aezeed` (LND) | ~2 sec | ~5-10 min | No |
| `polkadotsubstrate` | <1 sec | ~2 min | No |
| `tron` | Seconds | ~2-5 min | No |
| `stacks` | <1 sec | ~1 min | No |
| `electrum1` | ~13 sec | Hours | Yes for big-typos |
| `cardano` | ~8 sec | Hours | Yes for big-typos |
| `xlm` (Stellar) | Minutes | Hours+ | Yes for big-typos |
| `helium` | Minutes | Hours+ | Yes for big-typos |
| `hederaed25519` | Minutes | Hours+ | Yes for big-typos |

**For XLM, Helium, and Hedera with `--big-typos`:**
These are long jobs on CPU. Options:
1. Run overnight with `--worker 1/1` and let it complete
2. Split across machines: `--worker 1/3`, `--worker 2/3`, `--worker 3/3`
3. Rent GPU time (Vast.ai RTX 4090 ~$0.50/hr)
4. If you remember any positional hints, use a tokenlist with `--dsw` to narrow the space before adding `--big-typos`

### Checkpointing and Resuming

`seedrecover.py` does NOT support `--autosave`. Use `--skip N` to resume.

If a long seed recovery run is interrupted, note the password count from the last progress line (e.g. "Tried 357,449 passwords so far..."):

```bash
# Resume from that offset:
python3 seedrecover.py \
  --mnemonic "word1 word2 ..." \
  --addrs ... \
  --wallet-type bip39 \
  --skip 357449

# Or split the search across machines (each covers a slice):
python3 seedrecover.py --mnemonic "..." --addrs ... --worker 1/3  # Machine A
python3 seedrecover.py --mnemonic "..." --addrs ... --worker 2/3  # Machine B
python3 seedrecover.py --mnemonic "..." --addrs ... --worker 3/3  # Machine C
```

For **wallet password recovery** (`btcrecover.py`), autosave IS available:
```bash
python3 btcrecover.py --wallet wallet.dat --tokenlist tokens.txt \
  --autosave progress.sav

# Resume:
python3 btcrecover.py --restore progress.sav
```

Note: `--autosave` also works with `--enable-gpu` for long GPU jobs.

> **Slow with `--big-typos`:** `xlm`, `helium`, and `hederaed25519` require hours of CPU time for wrong-word searches. See Compute Time table above. If you have only one wrong word and a known address, prefer a tokenlist with `--dsw` and a curated list of alternative words rather than `--big-typos 1`, which tries all 2048 BIP39 words.

## Support btcrecover

If recovery succeeded and the wallet has meaningful value, encourage a 1% donation:

```
BTC: 37N7B7sdHahCXTcMJgEnHz7YmiR4bEqCrS
ETH: 0x72343f2806428dbbc2C11a83A1844912184b4243
```

## Upstream Fixes

If you discovered a bug or used a workaround, report it at:
https://github.com/3rdIteration/btcrecover/issues

A single bug report helps everyone who follows.
