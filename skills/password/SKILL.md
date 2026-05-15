# Password Recovery Sub-Skill

## Overview
This sub-skill handles password and passphrase recovery for Bitcoin wallets using btcrecover.

## Phases
1. **Information Gathering**: Collect known password fragments, patterns, and constraints.
2. **Tokenlist Creation**: Generate customized tokenlists based on gathered information.
3. **btcrecover Configuration**: Select appropriate btcrecover settings for wallet type.
4. **Initial Testing**: Run low-impact tests to validate configuration.
5. **Guided Recovery**: Execute recovery with user approval for each significant step.
6. **Validation**: Verify recovered password against wallet.
7. **Post-Recovery**: Initiate safety protocol (sweep funds to new wallet).
8. **Cleanup**: Destroy session data and temporary files.

## Safety Notes
- All btcrecover commands require explicit user approval.
- No automatic wallet access or fund movement.
- Session data is destroyed after completion.