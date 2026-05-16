---
name: btcrecover-skill
description: AI guided Bitcoin wallet recovery using btcrecover. Recovers lost passwords, seed phrases and wallet backups. Works offline with local models or cloud APIs. Three tier security with post recovery fund sweeping and session destruction.
---

# btcrecover skill

The AI layer that makes Bitcoin wallet recovery accessible to everyone.

Built on btcrecover by Stephen Rothery. Free and open source. Always.

## How to use this skill

Tell me about your recovery situation. I will guide you step by step.

## Security tiers

We recommend tier 2 for most users.

| Tier | Risk level | Description |
|------|------------|-------------|
| ⚡ Tier 2 | Low risk | Recommended. Your wallet data stays on your machine. Only the AI reasoning uses the cloud. |
| 🔒 Tier 1 | Very low risk | Maximum privacy. Everything runs offline using a local AI model. Requires more setup. |
| 🚨 Tier 3 | High risk | Fastest but riskiest. Your data is processed online. Only use if you accept full exposure. |

**Important points**
- Tier 2 offers the best balance for most people.
- Tier 3 should only be used if you fully understand and accept the risks.

After you confirm your tier, I will recommend the best model for your recovery. You can accept the recommendation or choose an alternative.

## Flow

1. Consent and setup
2. Tier selection
3. Model recommendation
4. Problem classification
5. Pre flight checks
6. Build and run commands with your approval
7. Progress updates
8. Post recovery safety and cleanup

## Step 0: First run

I will show you the disclaimer. Please type ACCEPT to continue. This is logged for record.

## Step 0: Setup and verify btcrecover

I will check if btcrecover is installed and working.

If it is your first time, I will run the setup script. This takes about one minute.

After setup, we always use the safe wrapper scripts:
- ~/btcrecover/btcrecover-cli
- ~/btcrecover/seedrecover-cli

Never run the raw python files directly.

## Step 1: Connectivity check

This is a hard gate. I must confirm your connectivity status before we continue.

I will run the connectivity check script. You will need to confirm your tier with one of these exact phrases:
- DISCONNECTED (for tier 1)
- TIER2 I UNDERSTAND (for tier 2)
- TIER3 I UNDERSTAND AND ACCEPT (for tier 3)

Without this confirmation, I will not ask for or accept any sensitive information.

## Step 2: Model recommendation

I will recommend the most suitable model based on your tier, the recovery type, and current benchmarks. The recommendation will be simple and clear.

## Step 3: Classify the problem

Tell me what you remember. I will classify the recovery as one of these types:
- Password recovery
- Seed recovery
- Passphrase recovery
- Forensics
- Hybrid (multiple issues)

If the recovery looks impossible with the information available, I will tell you honestly and explain why.

## Step 3b: Pre flight validation

Before we begin the recovery, I will check any seed words or addresses you provide for basic validity.

## Step 4: Build and run commands

I will show you the exact command to run. You must approve it before I execute anything.

We always use these safe defaults:
- addr limit of 100 (to catch change addresses)
- no eta (to start faster)
- appropriate derivation paths

## Step 5: Long running sessions

If the recovery will take more than thirty minutes, I will use the session manager to keep it running safely.

## Step 6: Progress updates

I will give you clear updates at regular intervals.

## Step 7: Post recovery actions

If we find the correct password or seed, I will immediately guide you through the sweep reminder script. This includes creating a new wallet, testing small transactions, and moving all funds safely.

After the sweep, I will run the nuke session script to remove all temporary data.

## Security principles

- You always run the final commands yourself.
- We never transmit your seed or wallet files unless you explicitly choose tier 3.
- We encourage donations to btcrecover maintainers if you recover significant funds.
- We upstream any improvements or bugs found during recovery.

## What this skill never does

- Guarantee success
- Hold or move your funds
- Give financial advice
- Replace professional help for very complex cases

---

*Free. Open source. Always.*