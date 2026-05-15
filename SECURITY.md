# Security Policy — btcrecover skill

## Supported versions

| Version | Supported |
|---|---|
| v1.x (current) | ✅ Active security support |
| < v1.0 | ❌ Pre-release — no support |

---

## Reporting a vulnerability

**Do not open a public GitHub issue for security vulnerabilities.**

Public disclosure before a fix is available puts users at immediate risk.
Please follow the responsible disclosure process below.

### How to report

Send a private report to: **[your-security-email]**

Use this subject line: `[SECURITY] btcrecover-skill — [brief description]`

### What to include

- Description of the vulnerability
- The file(s) and line numbers affected
- Steps to reproduce the issue
- Your assessment of the potential impact
- Your suggested fix (optional — helpful but not required)

### Encrypted reports

If the vulnerability involves sensitive details you would prefer to
encrypt, use the author's GPG key:

```bash
curl https://keybase.io/[yourusername]/key.asc | gpg --import
gpg --encrypt --recipient [yourusername] --armor your-report.txt
```

Send the encrypted output to the email address above.

---

## Response timeline

| Action | Target time |
|---|---|
| Acknowledgment | Within 48 hours |
| Initial assessment | Within 5 days |
| Fix timeline communicated | Within 10 days |
| Fix released | Within 30 days of confirmation |
| Public disclosure | After fix is available |

For critical vulnerabilities (e.g. those that could cause immediate fund
loss), the target for a fix release is 7 days.

---

## Scope — what is in scope

**In scope for this skill's security policy:**

- `SKILL.md` and all sub-skill files in `skills/`
- All shell scripts in `scripts/`
- `install.sh` and the verification chain
- `references/safety-rules.md`
- The session management and cleanup flow
- Any issue that could cause a user to expose private keys, seed phrases,
  or wallet files to unintended parties
- Any issue that could allow a malicious actor to manipulate recovery
  output (e.g. prompt injection in the forensics sub-skill)

**Out of scope (report to the relevant project):**

- btcrecover itself → https://github.com/3rdIteration/btcrecover/issues
- Ollama → https://github.com/ollama/ollama/issues
- Hermes Agent → https://github.com/NousResearch/hermes-agent/issues
- The AI models used with this skill
- Social engineering attacks targeting users directly
  (these are documented in `references/safety-rules.md §SCAM-DETECTION`)

---

## What constitutes a valid security vulnerability

Valid:
- A path by which private keys, seed phrases, or wallet files could be
  exfiltrated without the user's knowledge
- A prompt injection vector in the skill files that could override
  safety rules or redirect funds
- A flaw in `nuke-session.sh` that causes sensitive data to persist
  after the cleanup step
- A flaw in `connectivity-check.sh` that falsely reports OFFLINE when
  the machine is online
- A flaw in `verify-btcrecover.sh` that allows a malicious btcrecover
  fork to pass the integrity check
- A flaw in `install.sh` that allows a tampered installation to pass
  signature verification
- A typosquatted package that could be confused with this skill

Not valid (these are known limitations, not vulnerabilities):
- The skill cannot detect malware that was present before it ran
- The skill cannot prevent users from ignoring its safety warnings
- The skill cannot guarantee recovery success

---

## Bug bounty

There is no formal bug bounty program. However:

Critical findings (those that could directly cause fund loss for users)
will be acknowledged in the release notes by name (or anonymously if
preferred) and may receive a discretionary BTC tip from the author.

The amount is at the author's discretion. The acknowledgment is guaranteed.

---

## Hall of fame

Researchers who have responsibly disclosed issues and helped make this
skill safer for everyone:

*This section will grow. The first entry will be here.*

---

## Coordinated disclosure

Once a fix is released, the author will:

1. Tag a new version with the fix
2. Update CHECKSUMS.sha256 and re-sign
3. Publish a security advisory on GitHub
4. Credit the reporter in the release notes (unless anonymity requested)
5. Update this file with the vulnerability in the hall of fame

The reporter is welcome to publish their own writeup after the fix is
released. We ask only that public disclosure not happen before the fix
is available.

---

## A note on AI-specific vulnerabilities

This skill involves AI agents processing user input and external file
content. Security researchers interested in prompt injection, indirect
injection via wallet file metadata, or skill-injection attacks (as
documented in the Skill-Inject paper, arXiv 2602.20156) are particularly
welcome to review the skill files and report findings.

These are an active research area and real attack vectors for skills of
this type. Reports in this category will be treated with high priority.
