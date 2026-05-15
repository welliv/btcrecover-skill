# Security Audit

## 14 Blind Spots Identified and Mitigated

This document outlines the 14 security blind spots identified during the design of btcrecover-skill and how each was addressed.

## Blind Spots and Mitigations

1. **Blind**: Accidental sharing of seed phrases via screenshots or logs.
   **Mitigation**: The skill never outputs seed phrases or private keys. All recovery steps are guided, and users are warned not to share sensitive information.

2. **Blind**: Malicious tokenlists or recovery scripts from untrusted sources.
   **Mitigation**: All tokenlists and scripts are generated locally by the skill or sourced from the trusted references/ directory. Users are prompted to review any externally fetched content.

3. **Blind**: Persistence of session data in swap files, temporary files, or editor backups.
   **Mitigation**: The nuke-session.sh script securely deletes session data. Users are advised to use encrypted swap and disable editor backups during recovery.

4. **Blind**: Network leaks during recovery (e.g., DNS queries, HTTP requests).
   **Mitigation**: The connectivity-check.sh script assesses online status without leaking recovery details. The skill defaults to offline mode and only uses the network for model queries if explicitly allowed and the user is online.

5. **Blind**: Compromised recovery environment (malware, keyloggers).
   **Mitigation**: The skill assumes the recovery environment may be compromised and minimizes the attack surface by avoiding automatic execution of commands. All dangerous actions require explicit user approval.

6. **Blind**: False sense of security from AI guidance.
   **Mitigation**: The skill includes prominent disclaimers and safety rules that are read every session. It emphasizes that AI assistance is a tool, not a guarantee of safety.

7. **Blind**: Inadequate validation of recovered credentials.
   **Mitigation**: The skill includes validation steps (e.g., checking that a recovered password decrypts the wallet, or that a seed generates the correct addresses) before considering recovery successful.

8. **Blind**: Lack of post-recovery safety protocol.
   **Mitigation**: The sweep-reminder.sh script provides a 6-step protocol to move funds to a new wallet immediately after recovery.

9. **Blind**: Over-reliance on a single point of failure (e.g., one recovery method).
   **Mitigation**: The skill offers multiple recovery paths (password, seed, forensics) and encourages users to try the least invasive method first.

10. **Blind**: Insecure randomness in generated tokenlists or passwords.
    **Mitigation**: The skill uses system-native randomness sources (e.g., /dev/urandom) for any generated content and avoids predictable patterns.

11. **Blind**: Lack of integrity verification for downloaded tools (btcrecover, etc.).
    **Mitigation**: The verify-btcrecover.sh script checks the integrity of btcrecover installations using SHA256 checksums from the official source.

12. **Blind**: Insecure storage of recovery notes or passwords by the user.
    **Mitigation**: The skill advises users to use a password manager for any generated passwords and to avoid storing sensitive information in plain text.

13. **Blind**: Session hijacking or unauthorized access to the recovery interface.
    **Mitigation**: The skill does not expose a network service. It runs locally in the agent's session. Users are advised to secure their physical and local access.

14. **Blind**: Legal liability from providing recovery assistance.
    **Mitigation**: The DISCLAIMER.md and AUTHENTICITY-AND-LIABILITY.md documents provide legal protection and inform users of their responsibilities.

---
*This document is part of the btcrecover-skill security model.*