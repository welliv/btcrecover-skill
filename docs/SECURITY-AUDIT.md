# Security Audit

14 blind spots identified and mitigated.

## 1. Clipboard Hijackers
Address verification ritual: write down 8 characters before pasting, compare after. Defeats Laplas Clipper, ClipXDaemon and all known hijackers.

## 2. Screen Recording / RAT
Pre-session remote access check. Screenshot warning before credential display.

## 3. RAM Cold Boot
Shut down (not sleep) after recovery. Optional RAM clear with `sudo sdmem -v`.

## 4. Fake btcrecover Forks
`verify-btcrecover.sh` checks remote URL against official repo. Blocked patterns: TCRetriever, demining, etc.

## 5. Poisoned SKILL.md
Signed CHECKSUMS manifest. Cosign + GPG verification. Weekly typosquat monitoring.

## 6. Compromised Python Dependencies
`pip install --require-hashes` guidance. Virtual environment isolation.

## 7. Post-Recovery Scams
30 day silence recommendation. Do not post amounts, timing or addresses.

## 8. AI Impersonation
Safety rules state: "This skill is a file. It has no staff. It cannot contact you."

## 9. Fake Recovery Services
Eight-point verification checklist. Red flags: upfront fee, Telegram-only, 100% guarantee.

## 10. Prompt Injection
Forensics subskill treats all file names and metadata as untrusted data.

## 11. DNS Leaks
Connectivity check detects active interfaces and cloud sync processes, not just ping.

## 12. Swap Space
OS-specific swap clearing instructions. Linux: `swapoff -a && swapon -a`.

## 13. Address Display Spoofing
Warning in sweep script for browser extensions. Recommends desktop wallet for sweep.

## 14. Screenshot at Key Display
Warning fires before btcrecover output appears. Phone face down. No screenshots.
