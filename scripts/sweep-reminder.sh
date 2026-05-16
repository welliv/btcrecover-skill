#!/bin/bash
# Sweep reminder. 6-step post-recovery safety protocol.
# Each step needs Enter to advance.

set -euo pipefail

echo "=== Post-Recovery Safety Protocol ==="
echo
echo "We found it. Before anything else, walk through this with me."
echo

# Step 1
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 1: THE REFRAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "Your wallet is accessible. That is not the same as safe."
echo "The password we just found has been in a compromised state"
echo "since before we started. You must move your funds now."
echo
read -r -p "Press Enter to continue..."

# Step 2
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 2: NEW WALLET"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "Create a new wallet on a clean device."
echo "Use a hardware wallet if possible. Write the seed on paper, not digitally."
echo
read -r -p "Press Enter when done..."

# Step 3
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 3: VERIFY ADDRESS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "Display the receive address of your new wallet."
echo "1. Write down the first 8 characters on paper"
echo "2. Copy the address to clipboard"
echo "3. Paste it in the send field"
echo "4. Compare the first 8 characters with what you wrote"
echo "5. If they do not match, stop. You may have a clipboard hijacker."
echo
read -r -p "Press Enter when verified..."

# Step 4
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 4: TEST TRANSACTION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "Send the smallest possible amount to the new wallet."
echo "This detects clipboard hijackers. If the test goes to a wrong"
echo "address, you catch it before the full sweep."
echo
read -r -p "Paste the transaction link (or type 'pending'): " TX_LINK

if [[ "$TX_LINK" == "pending" ]]; then
    echo "Transaction pending. That is fine."
else
    echo "Transaction broadcast. Waiting for confirmation..."
    read -r -p "Did the test amount arrive in your new wallet? (YES/NO): " ARRIVED
    if [[ "$ARRIVED" != "YES" ]]; then
        echo
        echo "Test transaction failed. Possible causes:"
        echo "1. Still pending (wait for confirmations)"
        echo "2. Wrong address (check for clipboard hijacker)"
        echo "3. Broadcast failure"
        echo
        echo "Do not proceed with the full sweep until resolved."
        exit 1
    fi
    echo "Test confirmed."
fi

read -r -p "Press Enter to continue..."

# Step 5
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 5: FULL SWEEP"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "Sweep (not import) the entire balance to your new wallet."
echo
echo "Checklist before broadcasting:"
echo "  Destination address verified (first 8 chars match)"
echo "  Balance is correct"
echo "  Fee is appropriate"
echo "  You are sending to your wallet, not an exchange"
echo
read -r -p "Paste the sweep transaction link (or type 'pending'): " SWEEP_TX
echo "Sweep broadcast."

read -r -p "Press Enter to continue..."

# Step 6
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 6: VERIFY ON CHAIN"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
read -r -p "Paste the sweep transaction link (or type 'pending'): " VERIFY_TX

echo
echo "Your funds are now in a new, secure wallet."
echo "The old wallet is permanently compromised."
echo

read -r -p "Type DONE to confirm: " DONE
if [[ "$DONE" != "DONE" ]]; then
    echo "Please type DONE to confirm."
    exit 1
fi

# Donation ask
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "SUPPORT THE PROJECT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "This skill is free and always will be."
echo ""
Support btcrecover — the tool that did the actual recovery work:
  Stephen Rothery (3rdIteration)
  BTC: 37N7B7sdHahCXTcMJgEnHz7YmiR4bEqCrS
  https://github.com/3rdIteration/btcrecover


# Optional feedback report
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "OPTIONAL: Help the next person"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "Anonymous recovery reports help improve the skill"
echo "and show others that recovery is possible."
echo "No sensitive data — wallet type and scenario only."
echo
echo -n "Generate a report to share? [y/N]: "
read -r FEEDBACK

if [[ "${FEEDBACK,,}" == "y" ]]; then
    echo ""
    echo "Copy the block below and paste it at:"
    echo "https://github.com/welliv/btcrecover-skill/discussions"
    echo "(category: Recovery Reports)"
    echo ""
    echo "────────────────────────────────────────"
    echo "**Recovery Report**"
    echo "Outcome: SUCCESS"
    echo "Date: $(date '+%Y-%m')"
    echo "Wallet software: [e.g. Electrum 2.8, MetaMask, Bitcoin Core]"
    echo "Blockchain: [e.g. Bitcoin, Ethereum, Cardano]"
    echo "Recovery type: [PASSWORD / SEED / PASSPHRASE / FORENSICS / HYBRID]"
    echo "Scenario: [e.g. forgot password / 1 missing seed word / wrong word]"
    echo "Time to recover: [e.g. 3 minutes / 2 hours]"
    echo "Agent used: [e.g. Claude Code, Hermes + Ollama, Claude.ai]"
    echo "Notes: [optional — what helped or what was unexpected]"
    echo ""
    echo "DO NOT include: passwords, seed phrases, private keys,"
    echo "                addresses, wallet balances, or amounts."
    echo "────────────────────────────────────────"
    echo ""
fi

# Nuke handoff
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "SESSION DESTRUCTION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
read -r -p "Destroy all session data now? (YES/NUKE): " NUKE

if [[ "$NUKE" == "YES" || "$NUKE" == "NUKE" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    bash "$SCRIPT_DIR/nuke-session.sh"
else
    echo "Remember to manually delete tokenlists, extracts, and shell history."
fi

echo
echo "Tell no one about your recovery for 30 days."
echo "No amounts, no timing, no addresses."