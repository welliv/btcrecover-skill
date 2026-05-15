# Seed Recovery Sub-Skill

## Overview
Handles mnemonic (BIP39, SLIP39) and seed phrase recovery for Bitcoin wallets. Six problem classifications with distinct strategies.

## Safety Rules
- All btcrecover commands require explicit user approval
- No automatic wallet access or fund movement
- Session data is destroyed after completion
- Never share seed phrases or private keys with anyone

---

## Problem Classification

Classify the user's situation into one of six types:

| Type | Description | Strategy |
|------|-------------|----------|
| MISSING_WORDS | 1-4 unknown words in the mnemonic | Brute-force with BIP39 constraints |
| WRONG_WORD | Words known but some may be incorrect | Tokenlist mode with alternatives |
| SCRAMBLED | Words known but order unknown | Permutation with position hints |
| INVALID | Checksum failure | Last-word correction or multi-word fix |
| WRONG_COIN | Correct seed, wrong derivation path | Systematic path enumeration |
| EXTRA_PASSPHRASE | Seed + unknown passphrase | Route to password sub-skill |

---

## Type 1: MISSING_WORDS

**Scenario:** User knows some words but 1-4 are unknown.

### Search space math:
- BIP39 wordlist: 2048 words
- 1 missing: 2048 combinations (seconds)
- 2 missing: ~4.2 million (minutes)
- 3 missing: ~8.6 billion (hours on CPU, minutes on GPU)
- 4 missing: ~17.6 trillion (GPU rental recommended)

### Strategy:
1. Identify which positions are unknown
2. Use btcrecover's seedrecover mode with `--mnemonic-length 12` (or 24)
3. Specify known words with `--mnemonic "word1 word2 ? word4 ..."`
4. For 3+ missing words: provide GPU rental guidance

### btcrecover command:
```bash
python seedrecover.py \
  --mnemonic "word1 word2 ? word4 word5 ? word7 word8 word9 word10 word11 word12" \
  --wallet-file wallet.dat \
  --bip39
```

### GPU guidance for 3+ missing:
- RTX 4090: ~1000 seeds/sec for 3 missing words
- Estimated time: ~2.4 hours for 3 missing
- Cost: ~$1.20 on Vast.ai

---

## Type 2: WRONG_WORD

**Scenario:** User knows all words but suspects some may be misspelled or wrong.

### BIP39 visual/phonetic confusion pairs:
Reference: `references/typo-patterns.md`

Common confusions:
- "abandon" vs "abacus" (visual)
- "ability" vs "ablaze" (phonetic)
- "absent" vs "absorb" (visual)
- "abstract" vs "abuse" (prefix confusion)

### Strategy:
1. Generate alternatives for each suspected wrong word
2. Use tokenlist mode with the alternatives
3. btcrecover will try each combination

### btcrecover command:
```bash
python seedrecover.py \
  --mnemonic "word1 word2 word3 word4 word5 word6 word7 word8 word9 word10 word11 word12" \
  --mnemonic-alternatives "word3_alt1,word3_alt2" \
  --wallet-file wallet.dat \
  --bip39
```

---

## Type 3: SCRAMBLED

**Scenario:** User has all words but doesn't know the correct order.

### Search space:
- 12 words: 12! = 479,001,600 combinations
- 24 words: 24! = 6.2×10²³ (infeasible without position hints)

### Strategy:
1. Ask the user if they remember ANY word positions
2. Even 2-3 known positions dramatically reduce the search space
3. For 12 words with no known positions: feasible on GPU (~1 hour on RTX 4090)
4. For 24 words with no known positions: escalate immediately — this is infeasible

### If user knows some positions:
"That's very helpful. Knowing even 2-3 positions reduces the search space dramatically."

### btcrecover command:
```bash
python seedrecover.py \
  --mnemonic "word1 word2 word3 word4 word5 word6 word7 word8 word9 word10 word11 word12" \
  --mnemonic-order "0,1,2,3,4,5,6,7,8,9,10,11" \
  --wallet-file wallet.dat \
  --bip39
```

---

## Type 4: INVALID

**Scenario:** The mnemonic fails checksum validation.

### Diagnosis:
- Last word has checksum bits — if all other words are correct, there are only ~128 valid options for the last word
- If multiple words are wrong, the search space grows quickly

### Strategy:
1. First, try correcting just the last word (~128 options, seconds)
2. If that fails, try correcting the last 2 words (~262K options, minutes)
3. If that fails, escalate to multi-word correction

### btcrecover command (last word correction):
```bash
python seedrecover.py \
  --mnemonic "word1 word2 word3 word4 word5 word6 word7 word8 word9 word10 word11 ?" \
  --wallet-file wallet.dat \
  --bip39
```

---

## Type 5: WRONG_COIN

**Scenario:** The seed is correct but the wallet uses a different derivation path.

### Systematic derivation path check:
Try in order (most common first):
1. BIP44: m/44'/0'/0'/0/0 (Bitcoin legacy)
2. BIP49: m/49'/0'/0'/0/0 (Bitcoin SegWit compatible)
3. BIP84: m/84'/0'/0'/0/0 (Bitcoin native SegWit)
4. BIP86: m/86'/0'/0'/0/0 (Bitcoin Taproot)

### btcrecover command:
```bash
python seedrecover.py \
  --mnemonic "word1 word2 word3 word4 word5 word6 word7 word8 word9 word10 word11 word12" \
  --wallet-file wallet.dat \
  --bip39 \
  --path "m/44'/0'/0'/0/0,m/49'/0'/0'/0/0,m/84'/0'/0'/0/0,m/86'/0'/0'/0/0"
```

### Address database method:
If the user doesn't know their wallet address, use the address database method:
```bash
python seedrecover.py \
  --mnemonic "word1 word2 word3 word4 word5 word6 word7 word8 word9 word10 word11 word12" \
  --address-database addresses.txt \
  --bip39
```

---

## Type 6: EXTRA_PASSPHRASE

**Scenario:** The seed is correct but protected by an additional passphrase (BIP39 25th word).

### Strategy:
Route to password sub-skill for passphrase recovery. The passphrase is essentially a password that's appended to the seed.

### btcrecover command:
```bash
python btcrecover.py \
  --wallet wallet.extract \
  --seed "word1 word2 word3 word4 word5 word6 word7 word8 word9 word10 word11 word12" \
  --passphrase-list passphrase_list.txt \
  --typos 1 \
  --typos-case
```

---

## Multi-language Wordlists

BIP39 supports multiple languages. If the user's seed is not in English:
- Chinese (Simplified)
- Chinese (Traditional)
- French
- Italian
- Japanese
- Korean
- Spanish

### btcrecover command with language:
```bash
python seedrecover.py \
  --mnemonic "word1 word2 word3 ..." \
  --wallet-file wallet.dat \
  --bip39 \
  --language french
```

---

## Wallet Format Support

- BIP39 (standard mnemonic)
- SLIP39 (Shamir's Secret Sharing)
- Electrum 1.x (old seed format)
- Electrum 2.x (new seed format)

### Electrum-specific commands:
```bash
# Electrum 1.x
python seedrecover.py --mnemonic "..." --wallet-file wallet --electrum1

# Electrum 2.x
python seedrecover.py --mnemonic "..." --wallet-file wallet --electrum2
```