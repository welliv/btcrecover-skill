# Hybrid Seed + Passphrase Recovery

**Trigger**: Known BIP39 seed (12/24 words from image or text) + partial passphrase memory ("recoverytesting", "recovertest", "recoverytesters" etc). All lowercase, no spaces.

**Key Lessons from verified sessions**
- User memory is often one or more characters longer than actual passphrase. Systematic truncation (remove last 2-5 characters) is essential.
- Sparrow Wallet commonly places funds on BIP84 change addresses (m/84'/0'/0'/1/10 or higher). `--addr-limit 100` is mandatory.
- Use `btcrecover.py` with `--bip39` and `--passwordlist` for passphrase recovery.
- Exact command template that succeeded (verified 2026-05-16):

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

**Passphrase list construction**
Create `/tmp/passphrases.txt` with:
- All user-suggested variants
- Truncations: `recoverytest`, `recoveryt`, `recovertes`, `recovertesti` etc.
- Common misspellings (`reovertest`, `recovertesters`)

**Pitfalls**
- `derivationpath-lists/BTC.txt` lookup is relative. Must `cd ~/btcrecover` or wrappers fail with FileNotFoundError.
- `--wallet-type bip39 --force-bip84` combination required for bc1q (native segwit) addresses.
- Tool prints "Seed found" on success. Check output carefully for which passphrase worked.
- After recovery: immediately sweep funds and run session cleanup (`scripts/nuke-session.sh`).

**Post-recovery**
Always follow tier 2/3 safety: new wallet on air-gapped device, donate 1% to btcrecover maintainers if significant funds recovered.

See `verified-scenarios.md` for benchmarks. This pattern has succeeded in multiple sessions.
