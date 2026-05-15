#!/bin/bash
# btcrecover-skill nuke session
# Secure destruction of all session data
# Destroys in order: session files → tokenlists → extract files → btcrecover outputs → clipboard → shell history → nuke log → terminal scrollback

set -euo pipefail

SESSION_DIR="$HOME/.btcrecover-skill"
CONSENT_LOG="$SESSION_DIR/consent.log"
NUKE_LOG="$SESSION_DIR/nuke.log"
DRY_RUN=false
FORCE=false

# Parse arguments
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        --force) FORCE=true ;;
        --test) echo "Testing deletion tools..."; command -v shred >/dev/null 2>&1 && echo "  shred: OK" || echo "  shred: NOT FOUND"; command -v gshred >/dev/null 2>&1 && echo "  gshred: OK" || echo "  gshred: NOT FOUND"; command -v srm >/dev/null 2>&1 && echo "  srm: OK" || echo "  srm: NOT FOUND"; command -v wipe >/dev/null 2>&1 && echo "  wipe: OK" || echo "  wipe: NOT FOUND"; exit 0 ;;
        --donation-only) echo "Donation-only mode: skipping nuke"; exit 0 ;;
        *) echo "Unknown option: $arg"; echo "Usage: $0 [--dry-run] [--force] [--test] [--donation-only]"; exit 1 ;;
    esac
done

echo "=== btcrecover-skill: Session Destruction ==="
echo

if [[ "$DRY_RUN" == true ]]; then
    echo "DRY RUN MODE — no files will be deleted"
    echo
fi

# Confirmation gate (unless --force)
if [[ "$FORCE" != true ]]; then
    echo "This will permanently destroy ALL session data including:"
    echo "  - Session files and logs"
    echo "  - Tokenlists and passwordlists"
    echo "  - Wallet extract files"
    echo "  - btcrecover output and savestate files"
    echo "  - Clipboard contents"
    echo "  - Shell history lines referencing btcrecover"
    echo "  - Terminal scrollback buffer"
    echo
    echo "This action cannot be undone."
    echo
    read -r -p "Type NUKE to confirm: " CONFIRM
    if [[ "$CONFIRM" != "NUKE" ]]; then
        echo "Aborted."
        exit 1
    fi
fi

echo
echo "Starting secure deletion..."
echo

# Determine secure deletion tool (in preference order)
SECURE_DELETE=""
if command -v shred >/dev/null 2>&1; then
    SECURE_DELETE="shred -u -z -n 3"
elif command -v gshred >/dev/null 2>&1; then
    SECURE_DELETE="gshred -u -z -n 3"
elif command -v srm >/dev/null 2>&1; then
    SECURE_DELETE="srm -z -r"
elif command -v wipe >/dev/null 2>&1; then
    SECURE_DELETE="wipe -rf"
else
    SECURE_DELETE=""  # Fallback to manual overwrite
fi

secure_delete() {
    local target="$1"
    if [[ ! -e "$target" ]]; then
        return 0
    fi
    if [[ "$DRY_RUN" == true ]]; then
        echo "  [DRY RUN] Would delete: $target"
        return 0
    fi
    if [[ -n "$SECURE_DELETE" ]]; then
        $SECURE_DELETE "$target" 2>/dev/null || rm -f "$target"
    else
        # Fallback: 3-pass manual overwrite (zeros + urandom + zeros)
        if [[ -f "$target" ]]; then
            local size
            size=$(stat -f%z "$target" 2>/dev/null || stat -c%s "$target" 2>/dev/null || echo 0)
            if [[ "$size" -gt 0 ]]; then
                dd if=/dev/zero of="$target" bs=1 count="$size" 2>/dev/null
                dd if=/dev/urandom of="$target" bs=1 count="$size" 2>/dev/null
                dd if=/dev/zero of="$target" bs=1 count="$size" 2>/dev/null
            fi
        fi
        rm -rf "$target"
    fi
    echo "  Deleted: $target"
}

# 1. Session base directory
echo "[1/8] Session files..."
if [[ -d "$SESSION_DIR" ]]; then
    # Delete everything except the nuke log (which we write last)
    find "$SESSION_DIR" -type f ! -name "nuke.log" -print0 2>/dev/null | while IFS= read -r -d '' f; do
        secure_delete "$f"
    done
    # Remove empty directories
    if [[ "$DRY_RUN" != true ]]; then
        find "$SESSION_DIR" -type d -empty -delete 2>/dev/null || true
    fi
else
    echo "  No session directory found."
fi

# 2. Tokenlists and passwordlists
echo "[2/8] Tokenlists and passwordlists..."
for pattern in tokenlist*.txt passwordlist*.txt *.tokenlist *.passwordlist; do
    for f in $pattern; do
        secure_delete "$f"
    done
done

# 3. Wallet extract files
echo "[3/8] Wallet extract files..."
for pattern in *.extract extract.txt wallet.extract; do
    for f in $pattern; do
        secure_delete "$f"
    done
done

# 4. btcrecover output and savestate files
echo "[4/8] btcrecover output files..."
for pattern in *.savestate btcrecover_*.txt recover_*.txt; do
    for f in $pattern; do
        secure_delete "$f"
    done
done

# 5. Clipboard
echo "[5/8] Clipboard..."
if [[ "$DRY_RUN" != true ]]; then
    if command -v xclip >/dev/null 2>&1; then
        echo -n "" | xclip -selection clipboard 2>/dev/null || true
        echo "  Clipboard cleared (xclip)."
    elif command -v wl-copy >/dev/null 2>&1; then
        echo -n "" | wl-copy 2>/dev/null || true
        echo "  Clipboard cleared (wl-copy)."
    elif command -v xsel >/dev/null 2>&1; then
        xsel --clipboard --delete 2>/dev/null || true
        echo "  Clipboard cleared (xsel)."
    elif command -v pbcopy >/dev/null 2>&1; then
        echo -n "" | pbcopy 2>/dev/null || true
        echo "  Clipboard cleared (pbcopy)."
    else
        echo "  No clipboard tool found."
    fi
else
    echo "  [DRY RUN] Would clear clipboard."
fi

# 6. Shell history
echo "[6/8] Shell history..."
if [[ "$DRY_RUN" != true ]]; then
    for histfile in "$HOME/.bash_history" "$HOME/.zsh_history"; do
        if [[ -f "$histfile" ]]; then
            # Remove lines referencing btcrecover, seedrecover, wallet paths, etc.
            grep -v -i -E "(btcrecover|seedrecover|wallet\.dat|extract|tokenlist|passwordlist|--password|--mnemonic|--passphrase|WIF|bc1|1[A-HJ-NP-Za-km-z]{25,34})" "$histfile" > "${histfile}.tmp" 2>/dev/null && \
                mv "${histfile}.tmp" "$histfile" || true
            echo "  Cleaned: $histfile"
        fi
    done
else
    echo "  [DRY RUN] Would clean shell history."
fi

# 7. Nuke log (self-destruct)
echo "[7/8] Nuke log..."
if [[ "$DRY_RUN" != true ]]; then
    echo "[$(date)] Nuke completed. Session data destroyed." > "$NUKE_LOG"
    secure_delete "$NUKE_LOG"
else
    echo "  [DRY RUN] Would self-destruct nuke log."
fi

# 8. Terminal scrollback
echo "[8/8] Terminal scrollback..."
if [[ "$DRY_RUN" != true ]]; then
    # Try to clear scrollback
    printf '\033[3J' 2>/dev/null || true
    clear 2>/dev/null || true
    echo "  Terminal scrollback cleared."
else
    echo "  [DRY RUN] Would clear terminal scrollback."
fi

echo
echo "=== Session destruction complete ==="
echo
echo "The script cannot destroy the following. Please do these manually:"
echo "  1. Any files you created outside the skill directory"
echo "  2. Browser history (clear manually in your browser)"
echo "  3. If on a shared machine, log out completely"
echo
echo "Recommended: Shut down (don't sleep) after recovery."
echo "  Linux: sudo shutdown -h now"
echo "  macOS: sudo shutdown -h now"
echo "  Windows: shutdown /s /t 0"
echo
echo "Optional: Clear swap space"
echo "  Linux: sudo swapoff -a && sudo swapon -a"
echo "  Windows: cipher /w:C:\\"
echo "  macOS: sudo rm /var/vm/sleepimage"
echo
echo "Then tell no one about your recovery for 30 days."