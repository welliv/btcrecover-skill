# Wallet Types Reference

## Supported Wallet Types

Eleven wallet types with exact commands, extract scripts, and GPU speed benchmarks.

---

## 1. Bitcoin Core (BTC)

**File:** `wallet.dat`
**Format:** Berkeley DB (BDB) or LevelDB
**Extract script:** `extract-bitcoincoin-hash.py`

### Extract command:
```bash
python extract-bitcoincoin-hash.py wallet.dat > wallet.extract
```

### btcrecover command:
```bash
python btcrecover.py --wallet wallet.extract --tokenlist tokenlist.txt --typos 1
```

### GPU benchmarks (passwords/sec):
| Hardware | Speed |
|----------|-------|
| CPU 8-core | 50,000 |
| RTX 3060 | 500,000 |
| RTX 3090 | 1,500,000 |
| RTX 4090 | 2,500,000 |

### Notes:
- BDB corruption is common in old wallet files. Use `bsddb3 recover` if needed.
- LevelDB format used in newer versions (v0.21+).

---

## 2. Electrum

**File:** `wallet` (no extension)
**Format:** JSON or binary
**Extract script:** `extract-electrum-hash.py`

### Extract command:
```bash
python extract-electrum-hash.py wallet > wallet.extract
```

### btcrecover command:
```bash
python btcrecover.py --wallet wallet.extract --tokenlist tokenlist.txt --typos 1
```

### GPU benchmarks (passwords/sec):
| Hardware | Speed |
|----------|-------|
| CPU 8-core | 100,000 |
| RTX 3060 | 1,000,000 |
| RTX 3090 | 3,000,000 |
| RTX 4090 | 5,000,000 |

### Notes:
- Electrum 1.x and 2.x use different seed formats. Specify `--electrum1` or `--electrum2`.
- Electrum wallets may have a seed phrase OR a password. Determine which before recovery.

---

## 3. Blockchain.com

**File:** `wallet.aes.json`
**Format:** AES-encrypted JSON
**Extract script:** `extract-blockchain-hash.py`

### Extract command:
```bash
python extract-blockchain-hash.py wallet.aes.json > wallet.extract
```

### btcrecover command:
```bash
python btcrecover.py --wallet wallet.extract --tokenlist tokenlist.txt --typos 1
```

### GPU benchmarks (passwords/sec):
| Hardware | Speed |
|----------|-------|
| CPU 8-core | 1,000 |
| RTX 3060 | 10,000 |
| RTX 3090 | 30,000 |
| RTX 4090 | 50,000 |

### Notes:
- Blockchain.com wallets are slower to crack due to high iteration count.
- Second password (if enabled) requires separate recovery.

---

## 4. Trezor

**File:** N/A (hardware wallet)
**Format:** BIP39 mnemonic + optional passphrase
**Extract script:** N/A (use seed recovery)

### Recovery approach:
Use seed recovery (seed/SKILL.md) with the BIP39 mnemonic. If a passphrase was set, use password recovery for the passphrase.

### Derivation paths:
- BIP44: m/44'/0'/0'/0/0 (legacy)
- BIP49: m/49'/0'/0'/0/0 (SegWit compatible)
- BIP84: m/84'/0'/0'/0/0 (native SegWit)
- BIP86: m/86'/0'/0'/0/0 (Taproot)

---

## 5. Ledger

**File:** N/A (hardware wallet)
**Format:** BIP39 mnemonic + optional passphrase
**Extract script:** N/A (use seed recovery)

### Recovery approach:
Same as Trezor. Use seed recovery with BIP39 mnemonic.

### Derivation paths:
- BIP44: m/44'/0'/0'/0/0 (legacy)
- BIP49: m/49'/0'/0'/0/0 (SegWit compatible)
- BIP84: m/84'/0'/0'/0/0 (native SegWit)

### Notes:
- Ledger uses a 24-word mnemonic by default.
- Ledger Live uses BIP44 for Bitcoin.

---

## 6. MetaMask

**File:** `vault.json` or browser extension data
**Format:** JSON with encrypted secret
**Extract script:** `extract-metamask-hash.py`

### Extract command:
```bash
python extract-metamask-hash.py vault.json > wallet.extract
```

### btcrecover command:
```bash
python btcrecover.py --wallet wallet.extract --tokenlist tokenlist.txt --typos 1
```

### Notes:
- MetaMask is primarily an Ethereum wallet but can hold BTC via bridges.
- Browser extension data location varies by OS.

---

## 7. Exodus

**File:** Various (check Exodus data directory)
**Format:** Encrypted wallet data
**Extract script:** `extract-exodus-hash.py`

### Extract command:
```bash
python extract-exodus-hash.py exodus.wallet > wallet.extract
```

### btcrecover command:
```bash
python btcrecover.py --wallet wallet.extract --tokenlist tokenlist.txt --typos 1
```

### Notes:
- Exodus uses a 12-word seed phrase. Seed recovery may be more effective than password recovery.

---

## 8. MultiBit Classic

**File:** `wallet.key` or `wallet.data`
**Format:** Encrypted key file
**Extract script:** `extract-multibit-hash.py`

### Extract command:
```bash
python extract-multibit-hash.py wallet.key > wallet.extract
```

### btcrecover command:
```bash
python btcrecover.py --wallet wallet.extract --tokenlist tokenlist.txt --typos 1
```

### Notes:
- MultiBit Classic is no longer maintained. Consider sweeping to a modern wallet.

---

## 9. MultiBit HD

**File:** `mbhd.wallet.aes`
**Format:** AES-encrypted wallet
**Extract script:** `extract-multibit-hd-hash.py`

### Extract command:
```bash
python extract-multibit-hd-hash.py mbhd.wallet.aes > wallet.extract
```

### btcrecover command:
```bash
python btcrecover.py --wallet wallet.extract --tokenlist tokenlist.txt --typos 1
```

### Notes:
- MultiBit HD uses a 12-word seed phrase. Seed recovery may be more effective.

---

## 10. Armory

**File:** `armory_*.wallet`
**Format:** Armory wallet format
**Extract script:** `extract-armory-hash.py`

### Extract command:
```bash
python extract-armory-hash.py armory_wallet.wallet > wallet.extract
```

### btcrecover command:
```bash
python btcrecover.py --wallet wallet.extract --tokenlist tokenlist.txt --typos 1
```

### Notes:
- Armory uses a unique backup system (paper backups, digital backups).
- Armory wallets may have multiple encryption layers.

---

## 11. Wasabi

**File:** `wallet.json`
**Format:** JSON wallet
**Extract script:** `extract-wasabi-hash.py`

### Extract command:
```bash
python extract-wasabi-hash.py wallet.json > wallet.extract
```

### btcrecover command:
```bash
python btcrecover.py --wallet wallet.extract --tokenlist tokenlist.txt --typos 1
```

### Notes:
- Wasabi uses BIP84 (native SegWit) by default.
- Wasabi coinjoin features may complicate recovery.

---

## 12. Sparrow

**File:** `wallet.json` or `wallet.sqlite`
**Format:** JSON or SQLite
**Extract script:** `extract-sparrow-hash.py`

### Extract command:
```bash
python extract-sparrow-hash.py wallet.json > wallet.extract
```

### btcrecover command:
```bash
python btcrecover.py --wallet wallet.extract --tokenlist tokenlist.txt --typos 1
```

### Notes:
- Sparrow is a modern Bitcoin wallet with good hardware wallet integration.
- Supports BIP44, BIP49, BIP84, and BIP86.

---

## The sharedKey Concatenation Bug

**Important:** btcrecover has a known bug where it concatenates the shared encryption key with the password in the wrong order during decryption. This was the root cause of the cprkrn 11-year failure.

**What to watch for:**
- If the user's password "should" work but doesn't, this bug may be the cause.
- The bug affects certain wallet types (primarily Electrum and Blockchain.com).
- Check the btcrecover GitHub issues for the latest status on this bug.
- If suspected, try reversing the concatenation order in the extract script.

**Reference:** https://github.com/3rdIteration/btcrecover/issues

---

## GPU Rental Guidance

For large search spaces (>1 trillion combinations), GPU rental may be necessary:

| Provider | GPU | Cost/Hour | Notes |
|----------|-----|-----------|-------|
| Vast.ai | RTX 4090 | $0.50 | Best performance |
| Vast.ai | RTX 3090 | $0.30 | Good performance |
| Vast.ai | RTX 3060 | $0.15 | Budget option |
| RunPod | RTX 4090 | $0.60 | Reliable |
| Lambda | A100 | $1.10 | Enterprise |

### Cost estimation:
```
cost = (search_space / gpu_speed) × hourly_rate
```

Example: 10 trillion passwords on RTX 4090 at $0.50/hour:
- Speed: 2,500,000 passwords/sec
- Time: 10T / 2.5M = 4,000,000 sec ≈ 1,111 hours
- Cost: 1,111 × $0.50 ≈ $555

### Always show cost estimate before recommending rental.

---
*Reference for btcrecover-skill sub-skills*