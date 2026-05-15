#!/bin/bash
# btcrecover-skill nuke session
# Secure destruction of all session data

set -euo pipefail

SESSION_DIR="$HOME/.btcrecover-skill/sessions"

if [[ -d "$SESSION_DIR" ]]; then
    echo "Securely erasing session data..."
    # Overwrite with random data, then delete
    find "$SESSION_DIR" -type f -exec shred -u -z -n 3 {} \;
    rm -rf "$SESSION_DIR"
    echo "Session data destroyed."
else
    echo "No session data found."
fi