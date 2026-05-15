# Security Policy — btcrecover skill

## Supported versions

| Version | Supported |
|---|---|
| v1.x (current) | ✅ Active security support |
| < v1.0 | ❌ Pre-release — no support |

---

## Reporting a vulnerability

**Do not open a public GitHub issue for security vulnerabilities.** Public disclosure before a fix is available puts users at risk. Please follow responsible disclosure.

### How to report

Send a private report to: **steve@cryptoguide.tips**

Subject line: `[SECURITY] btcrecover-skill — [brief description]`

### What to include

- Description of the vulnerability
- Affected files and line numbers
- Steps to reproduce
- Impact assessment
- Suggested fix (optional)

### Encrypted reports

For sensitive details, use the author's GPG key:

```bash
curl https://keybase.io/welliv/key.asc | gpg --import
gpg --encrypt --recipient welliv --armor your-report.txt
```

Send the encrypted output to the email above.

---

## Response timeline

| Action | Target time |
|---|---|
| Acknowledgment | Within 48 hours |
| Initial assessment | Within 5 days |
| Fix timeline communicated | Within 10 days |
| Fix released | Within 30 days of confirmation |
| Public disclosure | After fix is available |

For critical vulnerabilities (those that could cause immediate fund loss), the target for a fix is 7 days.

---

## Scope

**In scope:**

- `SKILL.md` and all subskill files in `skills/`
- All shell scripts in `scripts/`
- `install.sh` and the verification chain
- `references/safety-rules.md`
- Session management and cleanup flow
- Any issue that could expose private keys, seed phrases, or wallet files to unintended parties
- Any issue that could allow a malicious actor to manipulate recovery output (e.g. prompt injection in the forensics subskill)

**Out of scope (report to the relevant project):**

- btcrecover itself → https://github.com/3rdIteration/btcrecover/issues
- Ollama → https://github.com/ollama/ollama/issues
- Hermes Agent → https://github.com/NousResearch/hermes-agent/issues
- The AI models used with this skill
- Social engineering attacks targeting users directly (documented in `references/safety-rules.md §SCAM-DETECTION`)

---

## What constitutes a valid security vulnerability

**Valid:**
- A path by which private keys, seed phrases, or wallet files could be exfiltrated without the user's knowledge
- A prompt injection vector that could override safety rules or redirect funds
- A flaw in `nuke-session.sh` that causes sensitive data to persist after cleanup
- A flaw in `connectivity-check.sh` that falsely reports OFFLINE when online
- A flaw in `verify-btcrecover.sh` that allows a malicious btcrecover fork to pass integrity checks
- A flaw in `install.sh` that allows a tampered installation to pass signature verification
- A typosquatted package that could be confused with this skill

**Not valid (known limitations, not vulnerabilities):**
- The skill cannot detect malware present before it ran
- The skill cannot prevent users from ignoring safety warnings
- The skill cannot guarantee recovery success

---

## Bug bounty

There is no formal bug bounty. Critical findings (those that could directly cause fund loss) will be acknowledged in release notes by name (or anonymously if preferred) and may receive a discretionary BTC tip from the author.

---

## Hall of fame

Researchers who have responsibly disclosed issues and helped make this skill safer:

*This section will grow. The first entry will be here.*

---

## Coordinated disclosure

Once a fix is released, the author will:

1. Tag a new version with the fix
2. Update CHECKSUMS.sha256 and re-sign
3. Publish a security advisory on GitHub
4. Credit the reporter in the release notes (unless anonymity requested)
5. Update this file with the vulnerability in the hall of fame

The reporter is welcome to publish their own writeup after the fix is available. We ask only that public disclosure waits until the fix is out.

---

## A note on AI-specific vulnerabilities

This skill involves AI agents processing user input and external file content. Security researchers interested in prompt injection, indirect injection via wallet file metadata, or skill-injection attacks (as documented in the Skill-Inject paper, arXiv 2602.20156) are particularly welcome to review the skill files and report findings.

These are active research areas and real attack vectors for skills like this. Reports in this category will be treated with high priority.
