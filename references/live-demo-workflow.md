# Live Demo Workflow — btcrecover-skill

This file documents the exact sequence used when running the skill in a live session (as demonstrated in May 2026).

## Recommended Live Session Flow

1. **Consent**
   - Display `DISCLAIMER.md`
   - User must type exactly `ACCEPT`
   - Log timestamp to `~/.btcrecover-skill/consent.log`

2. **Verification**
   - Always run `scripts/verify-btcrecover.sh` first
   - Confirm exit code 0 before proceeding

3. **Connectivity Gate (Hard Gate)**
   - Run `scripts/connectivity-check.sh --enforce`
   - Tier 1 (OFFLINE) is preferred
   - Only proceed on exit code 0

4. **Problem Classification**
   - Ask user to choose recovery type:
     - Password
     - Seed (missing/wrong word)
     - Passphrase (25th word)
     - Hybrid (seed + passphrase)
     - Forensics

5. **Pre-flight Validation**
   - For seed/passphrase: verify BIP39 words + checksum
   - Always require at least one known address

6. **Command Construction**
   - Use `--no-eta`
   - Use `--addr-limit 100` (never assume index 0)
   - For passphrases: always generate truncations (3–5 characters)
   - Show full command and wait for explicit approval

7. **Post-Recovery**
   - Immediately trigger `sweep-reminder.sh`
   - Run `nuke-session.sh` after funds are moved

## Demo Scenario (Passphrase Recovery)

Used successfully in live session:

- Seed: `element entire sniff tired miracle solve shadow scatter hello never tank side sight isolate sister uniform advice pen praise soap lizard festival connect baby`
- Known address: `bc1qv87qf7prhjf2ld8vgm7l0mj59jggm6ae5jdkx2`
- Passphrase list with truncations (see `passphrases.txt` example in session)

Command template:
```bash
python seedrecover.py \
  --wallet-type bip39 \
  --addrs bc1q... \
  --mnemonic "..." \
  --passphrase-list passphrases.txt \
  --addr-limit 100 \
  --no-eta
```

## Lessons Captured

- Users almost always remember a longer version of their passphrase than what they actually used.
- `--addr-limit 100` is mandatory — change addresses and reused wallets are common.
- Phase 3 timeouts produce scary but harmless tracebacks.