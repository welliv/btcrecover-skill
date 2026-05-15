#!/bin/bash
# btcrecover-skill sweep reminder
# 6-step post-recovery safety protocol

set -euo pipefail

echo "=== btcrecover-skill: Post-Recovery Safety Protocol ==="
echo
echo "If you have successfully recovered your wallet, follow these steps IMMEDIATELY:"
echo
echo "1. STOP USING THE RECOVERED WALLET FOR TRANSACTIONS"
echo "   - Do not send any transactions from the recovered wallet yet."
echo
echo "2. CREATE A NEW WALLET"
echo "   - Generate a new wallet using a secure, offline method."
echo "   - Use a hardware wallet if possible."
echo
echo "3. TRANSFER ALL FUNDS"
echo "   - Send the entire balance from the recovered wallet to the new wallet."
echo "   - Leave a small amount (dust) to cover transaction fees if needed."
echo
echo "4. VERIFY THE TRANSFER"
echo "   - Confirm the transaction has sufficient confirmations."
echo "   - Check that the new wallet shows the correct balance."
echo
echo "5. DESTROY THE OLD WALLET"
echo "   - Securely erase the old wallet file(s) and any backups."
echo "   - Consider the compromised wallet permanently unsafe."
echo
echo "6. MONITOR FOR UNAUTHORIZED ACCESS"
echo "   - Watch the old wallet address for any incoming transactions."
echo "   - If you see funds moved from the old wallet, investigate immediately."
echo
echo "=== Safety Reminder ==="
echo "Your security is paramount. Always assume the recovered wallet is compromised"
echo "until you have moved funds to a new, securely generated wallet."
echo