---
title: Password Recovery Skill Reference
description: 8-phase approach for wallet password, passphrase, BIP38, brainwallet, and private key recovery
---

# Password Recovery Skill

This reference covers all password-related recovery scenarios using `btcrecover.py`.

## Recovery Types Covered

| Type | Tool | Key Flags | Difficulty |
|------|------|-----------|------------|
| Wallet password | btcrecover.py | `--tokenlist`, `--typos` | Medium |
| BIP39 passphrase (25th word) | seedrecover.py | `--passphrase-list` | Medium |
| BIP38 encrypted paper wallet | btcrecover.py | `--bip38` | Hard |
| Brainwallet / Warpwallet | btcrecover.py | `--brainwallet` | Very Hard |
| Raw private key | btcrecover.py | `--privkey` | Medium |

---

## Phase 1: Information Gathering

Collect everything the user remembers:

- **Password fragments** (beginning, middle, end)
- **Length** (exact or range)
- **Character set** (lowercase, uppercase, digits, symbols)
- **Theme / pattern** (pet name + year, "password123!", etc.)
- **Typos** (caps lock, swapped characters, repeated keys)
- **Language** (English, German, Spanish, etc.)

**Never proceed without at least 2–3 solid fragments.**

---

## Phase 2: Tokenlist Construction

Create a `tokenlist.txt` file with all known pieces:

```
password
Password
PASSWORD
!@#
123
2020
2021
2022
2023
2024
2025
2026
```

**Best practice**: Use `--keep-tokens-order` when order matters. Use `--max-tokens` and `--min-tokens` to limit combinations.

---

## Phase 3: Typos & Mutations

Apply realistic typo rules:

```bash
btcrecover.py --tokenlist tokenlist.txt \
  --typos 2 \
  --typos-capslock \
  --typos-swap \
  --typos-repeat \
  --typos-delete \
  --typos-case \
  --max-typos-swap 1 \
  --max-typos-repeat 2
```

**Common typo flags**:
- `--typos-capslock` — entire password typed in wrong case
- `--typos-swap` — adjacent character swaps
- `--typos-repeat` — repeated characters (`passw0rd` → `passww0rd`)
- `--typos-delete` — missing characters
- `--typos-case` — individual character case changes

---

## Phase 4: Wallet File Handling

Always prefer `--wallet FILE` over `--data-extract`:

```bash
btcrecover.py --wallet wallet.dat --tokenlist tokens.txt
```

For remote or sensitive environments, use `--data-extract` to avoid copying the full wallet file.

---

## Phase 5: Performance Tuning

| Flag | Purpose | When to Use |
|------|---------|-------------|
| `--no-eta` | Skip pre-counting | Always for speed |
| `--max-passwords` | Limit search space | Testing only |
| `--threads N` | Parallelism | Match CPU cores |
| `--gpu` | GPU acceleration | Large searches |
| `--skip N` | Resume from checkpoint | Long runs |

---

## Phase 6: BIP38 Recovery

BIP38 encrypted private keys require the `ecdsa` module:

```bash
btcrecover.py --bip38 --encrypted-key 6PY... \
  --tokenlist tokens.txt
```

**Install if missing**:
```bash
pip install ecdsa
```

---

## Phase 7: Brainwallet & Warpwallet

These are extremely hard. Only attempt with strong hints:

```bash
btcrecover.py --brainwallet \
  --tokenlist brainwordlist.txt \
  --addrs 1...
```

**Reality check**: Most brainwallets are already drained. Success rate is near zero without very specific information.

---

## Phase 8: Post-Recovery Verification

After a successful find:

1. Verify the password actually unlocks the wallet
2. Immediately run `sweep-reminder.sh`
3. Create new wallet on clean device
4. Move all funds
5. Run `nuke-session.sh`

---

## Common Error Messages & Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| `No module named 'Crypto'` | Missing pycryptodome | `pip install pycryptodome` |
| `Cannot load ecdsa module` | Missing ecdsa | `pip install ecdsa` |
| `ERROR: No tokenlist` | No `--tokenlist` provided | Create tokenlist file |
| Search takes forever | No `--no-eta` + huge space | Add `--no-eta` |

---

## Recommended Command Template

```bash
btcrecover.py \
  --wallet wallet.dat \
  --tokenlist tokens.txt \
  --typos 2 \
  --typos-capslock --typos-swap --typos-repeat \
  --no-eta \
  --addr-limit 100
```

---

*Reference for btcrecover-skill — Password Recovery Module*