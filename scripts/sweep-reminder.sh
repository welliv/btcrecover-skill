#!/bin/bash
# btcrecover-skill sweep reminder
# 6-step post-recovery safety protocol
# Each step requires Enter to advance. Cannot be skipped.

set -euo pipefail

echo "=== btcrecover-skill: Post-Recovery Safety Protocol ==="
echo
echo "We found it. Before anything else, I need to walk you through something important."
echo

# Step 1: The Reframe
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 1: THE REFRAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "Your wallet is accessible. That is not the same as safe."
echo
echo "The password/seed we just found has been in a compromised state"
echo "since before we started. Anyone who had access to your wallet file"
echo "or seed phrase may have already copied it."
echo
echo "The moment you get access, you must move your funds to a new wallet."
echo
read -r -p "Press Enter to continue..."

# Step 2: New Wallet Setup
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 2: CREATE A NEW WALLET"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "Create a NEW wallet on a CLEAN device (not the one you just recovered on)."
echo
echo "Recommended: Use a hardware wallet (Trezor, Ledger) if possible."
echo "Alternative: Use Sparrow or Electrum on a clean computer."
echo
echo "IMPORTANT: Write your seed phrase on PAPER. Do not store it digitally."
echo
read -r -p "Press Enter when you have created your new wallet..."

# Step 3: Address Verification
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 3: VERIFY THE RECEIVE ADDRESS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "Display the receive address of your NEW wallet."
echo
echo "SECURITY RITUAL (defeats clipboard hijackers):"
echo "  1. Write down the FIRST 8 CHARACTERS of the address on paper"
echo "  2. Copy the address to clipboard"
echo "  3. Paste it into the send field"
echo "  4. Compare the first 8 characters with what you wrote down"
echo "  5. If they don't match, STOP — you may have a clipboard hijacker"
echo
read -r -p "Press Enter when you have verified the address..."

# Step 4: Test Transaction
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 4: TEST TRANSACTION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "Send the SMALLEST POSSIBLE AMOUNT from your recovered wallet to the new wallet."
echo
echo "This test transaction serves two purposes:"
echo "  1. Confirms you can send from the recovered wallet"
echo "  2. Detects clipboard hijackers (if address was swapped, test goes to attacker)"
echo
read -r -p "Paste the test transaction link (or type 'pending'): " TX_LINK

if [[ "$TX_LINK" == "pending" ]]; then
    echo "Transaction is pending. That's OK — we'll verify after the full sweep."
else
    echo "Transaction broadcast. Please verify it arrives in your new wallet."
    read -r -p "Did the test amount arrive in your new wallet? (YES/NO): " ARRIVED
    
    if [[ "$ARRIVED" != "YES" ]]; then
        echo
        echo "⚠️ TEST TRANSACTION FAILED ⚠️"
        echo
        echo "Possible causes:"
        echo "  1. Transaction is still pending (wait for confirmations)"
        echo "  2. Wrong address (check for clipboard hijacker)"
        echo "  3. Broadcast failure (check the transaction link)"
        echo
        echo "DO NOT proceed with the full sweep until the test transaction is confirmed."
        echo
        echo "If you suspect a clipboard hijacker:"
        echo "  - Run a malware scan (ClamAV: sudo clamscan -r /)"
        echo "  - Use a different device for the sweep"
        echo "  - Consider the recovered wallet compromised"
        exit 1
    fi
    
    echo "Test transaction confirmed. Proceeding to full sweep."
fi

read -r -p "Press Enter to continue..."

# Step 5: Full Sweep
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 5: FULL SWEEP"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "SWEEP (not import) the entire balance to your new wallet."
echo
echo "Pre-broadcast checklist:"
echo "  □ Destination address verified (first 8 characters match)"
echo "  □ Balance is correct"
echo "  □ Fee is appropriate (not too low, not too high)"
echo "  □ You are sending to YOUR new wallet (not an exchange)"
echo
echo "IMPORTANT: Use SWEEP, not IMPORT."
echo "  - SWEEP: Sends all funds, old wallet is empty after"
echo "  - IMPORT: Moves the private key, old wallet still has funds"
echo
read -r -p "Paste the sweep transaction link (or type 'pending'): " SWEEP_TX

if [[ "$SWEEP_TX" == "pending" ]]; then
    echo "Transaction is pending. That's OK."
else
    echo "Sweep transaction broadcast."
fi

read -r -p "Press Enter to continue..."

# Step 6: On-Chain Verification
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 6: ON-CHAIN VERIFICATION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "Verify the sweep transaction on a block explorer."
echo
read -r -p "Paste the sweep transaction link (or type 'pending'): " VERIFY_TX

if [[ "$VERIFY_TX" == "pending" ]]; then
    echo
    echo "Transaction is pending. That's OK — the sweep is broadcast."
    echo "You can verify later at:"
    echo "  https://mempool.space/tx/[your-tx-id]"
    echo "  https://blockstream.info/tx/[your-tx-id]"
else
    echo "Transaction verified on-chain."
fi

# Celebration
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 CONGRATULATIONS 🎉"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "Your funds are now in a new, secure wallet."
echo "The old wallet should be considered permanently compromised."
echo
read -r -p "Type DONE to confirm you have completed all steps: " DONE

if [[ "$DONE" != "DONE" ]]; then
    echo "Please type DONE to confirm."
    exit 1
fi

# Donation ask
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "SUPPORT THE PROJECT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "This skill is free and always will be."
echo
echo "If you want to support the people who made this possible:"
echo
echo "  1. Support btcrecover first (the engine that made this work):"
echo "     https://github.com/3rdIteration/btcrecover"
echo
echo "  2. Support this skill second (only if you want to):"
echo "     https://github.com/welliv/btcrecover-skill"
echo
echo "All donations are voluntary. This skill takes no percentage."
echo

# Nuke handoff
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "SESSION DESTRUCTION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "Now we destroy all session data (tokenlists, extracts, clipboard, history)."
echo
read -r -p "Run nuke-session.sh? (YES/NUKE): " NUKE_CONFIRM

if [[ "$NUKE_CONFIRM" == "YES" || "$NUKE_CONFIRM" == "NUKE" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    bash "$SCRIPT_DIR/nuke-session.sh"
else
    echo "Skipping nuke. Remember to manually delete:"
    echo "  - Tokenlists and passwordlists"
    echo "  - Wallet extract files"
    echo "  - btcrecover output files"
    echo "  - Shell history (history -c)"
fi

echo
echo "=== Final Reminder ==="
echo
echo "Tell no one about your recovery for 30 days."
echo "Do not post amounts, timing, or wallet addresses publicly."
echo
echo "Stay safe. Recover responsibly."
echo