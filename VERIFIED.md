# VERIFIED — btcrecover skill authenticity anchor

Use this file to verify any installation you did not download from the canonical source. If the information here doesn't match what you see at the GitHub URL below, or if you received this file from anywhere else, treat the installation as potentially compromised.

---

## Canonical source

```
https://github.com/welliv/btcrecover-skill
```

This is the only official repository. Every other copy is either a fork (verify separately) or a fake.

---

## Author identity — cross-verified

These accounts all belong to the same person. Each proof is cryptographically signed and publicly auditable on Keybase.

| Platform | URL |
|---|---|
| Keybase | https://keybase.io/welliv |
| GitHub | https://github.com/welliv |
| X (Twitter) | https://x.com/welliv |

To verify:

```bash
# Install Keybase: https://keybase.io/download
keybase id welliv
# Output shows all verified accounts linked to the same cryptographic key
```

---

## GPG key fingerprint

```
[YOUR FULL 40-CHARACTER GPG FINGERPRINT HERE]
Example format: DEAD BEEF 1234 5678 ABCD  EF01 2345 6789 ABCD EF01
```

Import and verify:

```bash
curl https://keybase.io/welliv/key.asc | gpg --import
gpg --verify CHECKSUMS.sha256.asc CHECKSUMS.sha256
```

---

## Sigstore / Cosign identity

Every release is signed via GitHub Actions using Sigstore's keyless signing, recorded in the Rekor transparency log — a tamper-resistant public record.

```
Certificate identity:
  https://github.com/welliv/btcrecover-skill/.github/workflows/release.yml@refs/tags/[version]

OIDC issuer:
  https://token.actions.githubusercontent.com
```

Verify with Cosign:

```bash
cosign verify-blob \
  --bundle CHECKSUMS.sha256.bundle \
  --certificate-identity-regexp="github.com/welliv" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  CHECKSUMS.sha256

# Expected output: Verified OK
```

---

## File integrity

Every release includes `CHECKSUMS.sha256` containing SHA256 hashes of all skill files.

```bash
sha256sum -c CHECKSUMS.sha256
# Every file should show: OK
# Any FAILED result means the file has been altered
```

---

## One-command verified install

Does Cosign, GPG, and SHA256 checks automatically:

```bash
curl -fsSL https://raw.githubusercontent.com/welliv/btcrecover-skill/main/install.sh | bash
```

Only proceed if all three checks pass.

---

## What the real skill NEVER does

Use this list to detect fakes and scams:

```
✗  Asks you to install software from a non-canonical source
✗  Contacts you via DM, email, Telegram, Discord, or any channel
✗  Accepts payment of any kind
✗  Runs a website requiring login to use the skill
✗  Asks for your seed phrase in any online chat
✗  Asks for your private key or WIF key in any online chat
✗  Has a support team, staff, or human representatives
✗  Guarantees recovery success
✗  Asks for an upfront fee
✗  Offers to run the recovery for you remotely
```

The skill is a file. It has no staff. It cannot contact you. Anyone doing any of the above in its name is a scammer.

---

## If you suspect a fake

1. Do not interact with it further
2. Do not share any wallet data, seed phrases, or private keys
3. Open an issue at the canonical GitHub URL above
4. If you sent funds to an address provided by the fake: contact local law enforcement and file a report at ic3.gov (US) or actionfraud.police.uk (UK)

---

## Reporting impersonators and typosquats

If you find a package on skills.sh, GitHub, npm, or any platform impersonating this skill, open an issue at: https://github.com/welliv/btcrecover-skill/issues

Title it: `[IMPERSONATION] found fake skill at [URL]`

Include the URL and any details. We will investigate and file takedown requests where applicable.

---

*This file is part of every official release and its SHA256 hash is included in CHECKSUMS.sha256. If the hash doesn't match, the file has been tampered with.*
