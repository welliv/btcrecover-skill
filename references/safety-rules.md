# btcrecover-skill safety rules
# Immutable security rules (read every session)

## Core Principles
1. **Never share your seed phrase or private keys with anyone.**
2. **Always assume any recovered wallet is compromised until you sweep funds to a new wallet.**
3. **Use offline methods whenever possible.**
4. **Verify all tools and downloads before use.**
5. **Keep your recovery process private and secure.**

## Session Rules
- This skill must read this file at the start of every session.
- All commands requiring wallet access must be explicitly approved by the user.
- No automatic transactions or fund movements will be performed by this skill.
- Session data will be destroyed after use unless explicitly preserved.

## Recovery Guidelines
- Start with the least invasive recovery method.
- Progress to more complex methods only if simpler ones fail.
- Document your steps but never store sensitive information in plain text.
- Use a password manager for any generated passwords during recovery.

## Post-Recovery
- Immediately sweep any recovered funds to a new, securely generated wallet.
- Consider the recovered wallet permanently compromised.
- Monitor the old address for unauthorized access.

---
*These rules are non-negotiable and designed to protect your assets.*