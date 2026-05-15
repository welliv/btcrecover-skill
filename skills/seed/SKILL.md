# Seed Recovery Sub-Skill

## Overview
This sub-skill handles mnemonic (BIP39, SLIP39) and seed phrase recovery for Bitcoin wallets.

## Problem Types
1. **Missing words**: One or more words in the mnemonic are unknown.
2. **Incorrect order**: Words are known but may be in the wrong sequence.
3. **Typos/misspellings**: Words are close to correct but have errors.
4. **Wrong wordlist**: Using the wrong language or wordlist for the mnemonic.
5. **Partial phrase**: Only a portion of the mnemonic is remembered.
6. **Passphrase protection**: The mnemonic is protected by an additional passphrase.

## Phases
1. **Information Gathering**: Collect known words, possible wordlist, and any hints about the mnemonic.
2. **Wordlist Identification**: Determine the correct BIP39 wordlist (language) used.
3. **Recovery Strategy**: Select approach based on problem type (brute-force, pattern matching, etc.).
4. **btcrecover Configuration**: Configure btcrecover for seed recovery (using appropriate scripts and flags).
5. **Guided Recovery**: Execute recovery with user approval for each significant step.
6. **Validation**: Verify recovered seed generates correct wallet addresses.
7. **Post-Recovery**: Initiate safety protocol (sweep funds to new wallet).
8. **Cleanup**: Destroy session data and temporary files.

## Safety Notes
- All btcrecover commands require explicit user approval.
- No automatic wallet access or fund movement.
- Session data is destroyed after completion.