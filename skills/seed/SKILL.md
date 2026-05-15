# Seed Recovery

Handles mnemonic (BIP39, SLIP39) and seed phrase recovery for Bitcoin wallets.

## Safety

- All commands need your approval
- No automatic wallet access or fund movement
- Session data destroyed after use

## Problem Types

| Type | Problem | Approach |
|------|---------|----------|
| Missing words | 1–4 unknown words | Brute force with BIP39 constraints |
| Wrong word | Some words may be wrong | Tokenlist with alternatives |
| Scrambled | Words known, order unknown | Permutations with position hints |
| Invalid | Checksum fails | Last word correction |
| Wrong coin | Correct seed, wrong derivation path | Try BIP44/49/84/86 |
| Extra passphrase | Seed + unknown passphrase | Route to password subskill |

## Missing Words

BIP39 wordlist: 2048 words.

- 1 missing: 2048 tries (seconds)
- 2 missing: 4 million (minutes)
- 3 missing: 8.6 billion (hours CPU, minutes GPU)
- 4 missing: 17 trillion (GPU rental)

```bash
python seedrecover.py \
  --mnemonic "word1 word2 ? word4 word5 ? word7 word8 word9 word10 word11 word12" \
  --wallet-file wallet.dat \
  --bip39
```

## Wrong Word

Generate alternatives for suspected wrong words. Try common BIP39 confusions (abandon vs abacus, ability vs ablaze).

```bash
python seedrecover.py \
  --mnemonic "word1 word2 word3 ..." \
  --mnemonic-alternatives "word3_alt1,word3_alt2" \
  --wallet-file wallet.dat \
  --bip39
```

## Scrambled

12 words = 479 million permutations. Ask for any known positions. Even 2–3 help tremendously.

24 words = infeasible without position hints. Escalate.

```bash
python seedrecover.py \
  --mnemonic "word1 word2 ... word12" \
  --wallet-file wallet.dat \
  --bip39
```

## Invalid Checksum

If all but last word are correct, only ~128 options for the last word. Try that first.

```bash
python seedrecover.py \
  --mnemonic "word1 word2 ... word11 ?" \
  --wallet-file wallet.dat \
  --bip39
```

## Wrong Coin

Try in order: BIP44 (legacy), BIP49 (SegWit compatible), BIP84 (native SegWit), BIP86 (Taproot).

```bash
python seedrecover.py \
  --mnemonic "word1 word2 ... word12" \
  --wallet-file wallet.dat \
  --bip39 \
  --path "m/44'/0'/0'/0/0,m/49'/0'/0'/0/0,m/84'/0'/0'/0/0,m/86'/0'/0'/0/0"
```

If no address known, use address database method.

## Extra Passphrase

The passphrase is like a password appended to the seed. Route to password subskill.

```bash
python btcrecover.py \
  --wallet wallet.extract \
  --seed "word1 word2 ... word12" \
  --passphrase-list passphrase_list.txt \
  --typos 1 --typos-case \
  --addr-limit 100 \
  --force-bip44 --force-p2sh --force-p2tr
```

## Languages

BIP39 supports: Chinese, French, Italian, Japanese, Korean, Spanish.

```bash
python seedrecover.py \
  --mnemonic "..." --wallet-file wallet.dat --bip39 --language french
```

## Wallet Formats

BIP39, SLIP39, Electrum 1.x, Electrum 2.x. Use `--electrum1` or `--electrum2` for Electrum formats.