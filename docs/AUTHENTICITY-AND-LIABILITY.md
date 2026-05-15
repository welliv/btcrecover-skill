# Authenticity and Liability

## Anti-Impersonation

The skill uses several mechanisms to prove it's genuine:

1. GPG commit signing (verified by GitHub)
2. Cosign keyless signing on every release (recorded in Rekor transparency log)
3. SHA256 checksums for all files (CHECKSUMS.sha256)
4. Weekly typosquat monitoring via `scripts/typosquat-monitor.py`
5. Branch protection: signed commits required, no force push

## Liability

**Disclaimer.** The software is provided "as is", without warranty. You assume all risk.

**Your responsibilities:**
- Verify any tools you use (btcrecover, etc.)
- Follow the post-recovery safety protocol
- Keep your recovery process confidential
- Sweep funds to a new wallet immediately

**What this skill does not do:**
- Guarantee recovery
- Access or transmit wallet data without your approval
- Replace proper wallet security practices
- Provide legal or financial advice

## Reporting Issues

Report security vulnerabilities via the official GitHub repository.
