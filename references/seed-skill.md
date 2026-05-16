---
title: Seed Recovery Skill Reference
description: 6 problem types for BIP39, SLIP39, Electrum, aezeed, and other seed phrase recoveries
---

# Seed Recovery Skill

This reference covers seed phrase recovery using `seedrecover.py`.

## Problem Types

| Type | Description | Tool Flags | Difficulty |
|------|-------------|------------|------------|
| 1 missing word | One word unknown | `--mnemonic "..."` | Easy |
| 1 wrong word | One word incorrect | `--mnemonic "..."` | Medium |
| Scrambled order | Words in wrong order | `--mnemonic-prompt` | Hard |
| Invalid checksum | Last word fails checksum | Pre-filter + search | Medium |
| Wrong derivation path | Correct seed, wrong path | `--bip32-path` | Medium |
| Extra passphrase | Seed + unknown 25th word | `--passphrase-list` | Medium |

---

## Type 1: One Missing Word (Most Common)

```bash
seedrecover.py \
  --wallet-type bip39 \
  --addrs bc1q... \
  --mnemonic "word1 word2 word3 word4 word5 word6 word7 word8 word9 word10 word11 ?" \
  --addr-limit 100 \
  --no-eta
```

**Key insight**: Use `?` as placeholder. The tool tries all 2048 BIP39 words.

---

## Type 2: One Wrong Word

Same command as above. The tool will test replacements for the incorrect word.

**Tip**: If you have the checksum word, use the checksum pre-filter script in SKILL.md to reduce candidates from 2048 → ~128.

---

## Type 3: Scrambled Word Order

When the user remembers the words but not the sequence:

```bash
seedrecover.py \
  --wallet-type bip39 \
  --addrs bc1q... \
  --mnemonic-prompt \
  --addr-limit 50
```

The tool will try permutations. This becomes expensive quickly (12! = 479M).

---

## Type 4: Invalid Checksum

If the last word fails the BIP39 checksum:

1. Run the checksum pre-filter (see SKILL.md Step 3b)
2. Identify which word position is likely wrong
3. Run with multiple `?` placeholders if needed

---

## Type 5: Wrong Derivation Path

Correct seed but funds on non-standard path:

```bash
seedrecover.py \
  --wallet-type bip39 \
  --addrs bc1q... \
  --mnemonic "..." \
  --bip32-path "m/84'/0'/0'/1/*" \
  --addr-limit 200
```

**Common paths**:
- BIP84 (Native SegWit): `m/84'/0'/0'/0/*`
- BIP49 (P2SH-SegWit): `m/49'/0'/0'/0/*`
- BIP44 (Legacy): `m/44'/0'/0'/0/*`
- Change addresses: `m/84'/0'/0'/1/*`

---

## Type 6: Seed + Unknown Passphrase (Hybrid)

```bash
seedrecover.py \
  --wallet-type bip39 \
  --addrs bc1q... \
  --mnemonic "word1 word2 ... word12" \
  --passphrase-list passphrases.txt \
  --addr-limit 100 \
  --no-eta
```

**Critical**: Always generate truncations and variations in `passphrases.txt`:
```
recoverytesting
recoverytest
recoverytesti
recoverytestin
recoverytesting!
recoverytesting2024
```

---

## SLIP39 (Shamir Backup) Recovery

Requires `shamir-mnemonic`:

```bash
seedrecover.py --slip39 --share-length 20
```

**Install**:
```bash
pip install shamir-mnemonic[cli]
```

---

## aezeed (LND) Recovery

```bash
seedrecover.py \
  --wallet-type aezeed \
  --addrs 1... \
  --mnemonic "..." \
  --addr-limit 5
```

---

## Cardano Recovery

```bash
seedrecover.py \
  --wallet-type cardano \
  --addrs addr1... \
  --mnemonic "..."
```

**Note**: Cardano does not use `--addr-limit` the same way.

---

## Ethereum Validator Recovery

```bash
seedrecover.py \
  --wallet-type ethereumvalidator \
  --addrs 0x... \
  --mnemonic "..." \
  --addr-limit 1
```

---

## Pre-Flight Checklist

Before running any seed recovery:

- [ ] At least one known address or xpub
- [ ] BIP39 wordlist verified (all words valid)
- [ ] Checksum validated (or known to be invalid)
- [ ] `--addr-limit` set to at least 100
- [ ] `--no-eta` used for speed
- [ ] Passphrase list prepared with truncations (if applicable)

---

## Common Errors

| Error | Fix |
|-------|-----|
| `No module named 'coincurve'` | `pip install coincurve` |
| `shamir_mnemonic not found` | `pip install shamir-mnemonic[cli]` |
| `Bech polymod check failed` | Invalid address — double-check address |
| Phase 3 timeout | Normal — resume with `--skip` |

---

## Recommended Command Template

```bash
seedrecover.py \
  --wallet-type bip39 \
  --addrs bc1q... \
  --mnemonic "word1 word2 ... ?" \
  --addr-limit 100 \
  --no-eta \
  --no-dupchecks
```

---

*Reference for btcrecover-skill — Seed Recovery Module*