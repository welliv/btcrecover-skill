# Forensics Recovery Sub-Skill

## Overview
This sub-skill handles file archaeology and backup discovery for Bitcoin wallets.

## Phases
1. **Information Gathering**: Collect details about the system, backup habits, and possible file locations.
2. **File System Scan**: Search for common Bitcoin wallet file patterns and extensions.
3. **Backup Discovery**: Locate potential backups in cloud storage, email, and external drives.
4. **File Analysis**: Examine found files for wallet data (using btcrecover's extraction scripts if applicable).
5. **Recovery Strategy**: Determine if the found file is a wallet backup and plan recovery approach.
6. **btcrecover Configuration**: Configure btcrecover to work with the discovered wallet format.
7. **Guided Recovery**: Execute recovery with user approval for each significant step.
8. **Validation**: Verify recovered wallet can sign transactions or generate correct addresses.
9. **Cleanup**: Destroy session data and temporary files (securely if needed).

## Safety Notes
- All file operations are read-only unless explicitly approved for writing (e.g., to extract wallet data).
- No automatic uploading or sharing of found files.
- Session data is destroyed after completion.