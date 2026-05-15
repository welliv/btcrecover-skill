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
python seedrecover.py \
  --mnemonic "word1 word2 ? word4 word5 ? word7 word8 word9 word10 word11 word12" \
  --addrs bc1q... \
  --addr-limit 100 \
  --wallet-type bip39
```

Larger search spaces benefit from multi-device distribution:
```bash
python seedrecover.py --mnemonic "..." --addrs ... --worker 1,2/3  # PC1: slices 1+2 of 3
python seedrecover.py --mnemonic "..." --addrs ... --worker 3/3    # PC2: slice 3 of 3
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
python seedrecover.py \
  --no-dupchecks \
  --mnemonic-length 12 \
  --language EN \
  --dsw \
  --wallet-type bip39 \
  --addr-limit 1 \
  --addrs bc1q... \
  --tokenlist words.txt
```

## Swapped Words

When you know all words but they may be in the wrong order. Complexity:
- 12-word seed: 1 swap = 67 tries, 2 swaps = 4,423, 3 swaps = 291,919
- 24-word seed: 1 swap = 277 tries, 2 swaps = 76,453

```bash
python seedrecover.py \
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
python seedrecover.py --mnemonic "..." --addrs ... --big-typos 2
```

Big typos = different BIP39 words, not just character-level typos.

For BIP39 with tokenlist alternatives:
```bash
python seedrecover.py --no-dupchecks --dsw --wallet-type bip39 \
  --addrs ... --addr-limit 100 \
  --tokenlist words.txt \
  --mnemonic-length 12 --language EN
```

## Invalid Checksum

If you know all words but the checksum fails, the last word in a 12-word seed has ~128 valid alternatives. Try replacing the last word with `?`.

```bash
python seedrecover.py \
  --mnemonic "word1 word2 word3 word4 word5 word6 word7 word8 word9 word10 word11 ?" \
  --addrs bc1q... \
  --addr-limit 100 \
  --wallet-type bip39
```

## SLIP39 (Shamir Backup)

SLIP39 shares have a different format than BIP39. Words may be from a different wordlist.
```bash
python seedrecover.py --slip39 --mnemonic "share words here..." --typos 2
```

```bash
python seedrecover.py --slip39 --mnemonic "share words..." --big-typos 2
```

## Wrong Derivation Path

When the seed is correct but the address type doesn't match your wallet:

```bash
python seedrecover.py \
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
python btcrecover.py \
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
| `blockchainpasswordv3` | Blockchain.com legacy recovery mnemonic |

## aezeed (LND Lightning)

Add custom passphrase if needed:
```bash
python seedrecover.py --wallet-type aezeed \
  --mnemonic "..." --addrs ... --addr-limit 5
  --passphrase-arg "YOUR PASSPHRASE"
```

For checksum-only mode (no address known), omit `--addrs`.

## Non-English Languages

BIP39 supports: Chinese, French (`FR`), Italian (`IT`), Japanese (`JP`), Korean (`KO`), Spanish (`ES`).

```bash
python seedrecover.py --mnemonic "..." --addrs ... \
  --language FR --wallet-type bip39 \
  --addr-limit 100
```

## AddressDB Recovery

When you don't know the wallet type or derivation path:

```bash
python seedrecover.py --addressdb addresses-BTC.db \
  --wallet-type bip39 --mnemonic "..." \
  --addr-limit 2 --no-dupchecks
```

Bitcoin AddressDB needs ~16GB (DBLength 31). RAM ~2x DB size.
See `references/wallet-types.md` for AddressDB creation commands.

## Debugging

Use `--listpass` to see which seed phrases would be tried:
```bash
python seedrecover.py --listpass --tokenlist words.txt --mnemonic-length 12 --language EN
```

## Performance

- seedrecover runs in 4 phases by default: single typo, 2 typos + 1 different word, 3 typos + 1 different word, 2 typos as different words
- Use `--no-dupchecks` to reduce RAM usage and speed up
- Use `--no-eta` to skip the counting phase
- For large searches: `--worker` across multiple machines or `--skip` to resume interrupted runs

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
