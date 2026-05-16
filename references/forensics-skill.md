---
title: Forensics Skill Reference
description: 9-phase wallet file archaeology and backup discovery protocol (cprkrn Protocol)
---

# Forensics Skill Reference

This reference covers locating lost wallet files, backups, and seed material when the user no longer knows exact locations.

## The cprkrn Protocol (9 Phases)

Named after the legendary recovery that inspired this skill.

### Phase 1: User Interview

Ask the user:

- What wallet software was used? (Electrum, Sparrow, Bitcoin Core, Exodus, etc.)
- When was the wallet last accessed?
- What computer(s) were used?
- Any external drives, USB sticks, cloud sync, or old laptops?
- Any paper backups, metal backups, or screenshots?
- Any password managers or note-taking apps used?

### Phase 2: Standard Locations Scan

Common default paths:

**Bitcoin Core**
- `~/.bitcoin/wallet.dat`
- `~/Library/Application Support/Bitcoin/wallet.dat`
- `%APPDATA%\Bitcoin\wallet.dat`

**Electrum**
- `~/.electrum/wallets/`
- `~/Library/Application Support/Electrum/wallets/`

**Sparrow**
- `~/.sparrow/wallets/`
- `~/Library/Application Support/Sparrow/wallets/`

**Exodus**
- `~/.exodus/wallets/`

Run:
```bash
find ~ -name "wallet.dat" -o -name "*.wallet" 2>/dev/null
```

### Phase 3: Recursive Search with Content Matching

Search for known strings inside files:

```bash
grep -r "xpub" ~ 2>/dev/null | head -20
grep -r "bc1q" ~ 2>/dev/null | head -20
```

### Phase 4: File Type Carving

Recover deleted files using `testdisk`, `photorec`, or `scalpel`.

Focus on:
- `.dat` files
- `.json` files (Electrum, Sparrow)
- `.txt` files containing seed words
- Screenshots (`.png`, `.jpg`)

### Phase 5: Cloud & Sync Recovery

Check:
- Google Drive, Dropbox, OneDrive, iCloud
- Time Machine / Backblaze / other backup services
- Old email attachments
- Git repositories (never do this with real seeds)

### Phase 6: Memory Forensics (Advanced)

If the machine is still running:

```bash
strings /proc/$(pidof bitcoin-qt)/mem 2>/dev/null | grep -E "xpub|bc1q|seed" | head -10
```

**Warning**: Only on machines you own and control.

### Phase 7: Hardware Forensics

- Old phones (check secure notes, photos, password managers)
- USB drives and SD cards
- Old laptops in storage
- Printed paper in filing cabinets

### Phase 8: Social & Temporal Recovery

- Ask family members if they remember anything
- Check calendar entries around wallet creation date
- Search old chat logs for "seed", "backup", "wallet"

### Phase 9: Last Resort — Blind Recovery

If nothing is found:
- Accept that recovery may be impossible
- Document everything attempted
- Consider professional forensic services for high-value wallets

---

## Recommended Commands

### Quick Home Directory Scan

```bash
find ~ -type f \( -name "*.dat" -o -name "*.wallet" -o -name "*seed*" -o -name "*backup*" \) 2>/dev/null
```

### Content-Based Search

```bash
grep -r --include="*.txt" --include="*.json" --include="*.dat" "xpub" ~ 2>/dev/null
```

### Sparrow Wallet Specific

```bash
find ~ -path "*/sparrow/*" -name "*.json" 2>/dev/null
```

---

## Tools Reference

| Tool | Purpose | Install |
|------|---------|---------|
| `testdisk` | Recover deleted partitions | `apt install testdisk` |
| `photorec` | Carve files from disk | Comes with testdisk |
| `scalpel` | File carving | `apt install scalpel` |
| `strings` | Extract text from binaries | Usually pre-installed |
| `grep` | Content search | Pre-installed |
| `find` | File system search | Pre-installed |

---

## Important Warnings

- **Never** run forensics on a live machine that may have malware
- **Never** upload wallet files to any online service
- **Never** share seed material, even with "recovery experts"
- Always work on a copy of the drive when possible

---

## Post-Find Actions

Once a wallet file or seed is located:

1. Immediately copy it to a secure location
2. Run `verify-btcrecover.sh`
3. Proceed with normal recovery workflow
4. After success, run `sweep-reminder.sh`
5. Destroy all intermediate files with `nuke-session.sh`

---

*Reference for btcrecover-skill — Forensics Module*