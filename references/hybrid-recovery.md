# Hybrid Seed + Passphrase Recovery

## Schema

**Trigger**  
Known BIP39 seed (12/24 words) + partial passphrase memory.

**Key Insight**  
User memory is often 1–5 characters longer than the actual passphrase. Systematic truncation is essential. Sparrow Wallet frequently places funds on BIP84 change addresses at index 10+.

**Exact Command (Verified 2026-05-16)**

```bash
cd ~/btcrecover
python3 btcrecover.py \
  --bip39 --wallet-type bip39 \
  --mnemonic "word toward monitor crazy clip later estate pledge chimney crack connect scale" \
  --passwordlist passphrases.txt \
  --bip32-path "m/84'/0'/0'/0" \
  --addr-limit 100 \
  --addrs bc1q9ea307s7nl3mn7e96hfu3ekf4cjdm9hw3haayv \
  --dsw
```

**Passphrase List Construction**
- All user-suggested variants
- Truncations (remove last 2–5 characters)
- Common misspellings

**Pitfalls**
- Must `cd ~/btcrecover` — derivation path lookup is relative.
- Use `--bip32-path "m/84'/0'/0'/0"` for Sparrow change addresses.
- Check output for "Seed found" message.

**Verified Outcome**
Pattern succeeded in multiple sessions. See `docs/verified-recoveries.md` for full log.
