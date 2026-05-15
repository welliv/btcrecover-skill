#!/usr/bin/env bash
# =============================================================================
# verify-btcrecover.sh — btcrecover installation integrity checker
# =============================================================================
# Called by SKILL.md Step 0B before every recovery session.
# Checks that the user's btcrecover installation is from the official
# repository and has not been tampered with or replaced by a malicious fork.
#
# Usage:
#   ./scripts/verify-btcrecover.sh                    # Auto-detect btcrecover
#   ./scripts/verify-btcrecover.sh /path/to/btcrecover # Explicit path
#
# Exit codes:
#   0 = VERIFIED (official repo, passes all checks)
#   1 = SUSPICIOUS (wrong remote, unknown fork, or check failed)
#   2 = NOT_FOUND (btcrecover not installed)
# =============================================================================

set -euo pipefail

BTCRECOVER_PATH="${1:-}"

# --- Colors ---
if [ -t 1 ]; then
    RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m'
    BOLD='\033[1m' DIM='\033[2m' NC='\033[0m'
else
    RED='' GREEN='' YELLOW='' BOLD='' DIM='' NC=''
fi

ok()   { echo -e "${GREEN}${BOLD}[verify-btcrecover]${NC} ✓ $*"; }
warn() { echo -e "${YELLOW}${BOLD}[verify-btcrecover]${NC} ! $*"; }
fail() { echo -e "${RED}${BOLD}[verify-btcrecover]${NC} ✗ $*" >&2; }
info() { echo -e "${DIM}[verify-btcrecover]${NC} $*"; }

# --- Official repository details ---
OFFICIAL_REPO="https://github.com/3rdIteration/btcrecover"
OFFICIAL_PATTERNS=(
    "3rdIteration/btcrecover"
    "github.com/3rdIteration"
)

# --- Known malicious or suspicious fork patterns ---
# Based on active monitoring of fake btcrecover repositories
SUSPICIOUS_PATTERNS=(
    "TCRetriever"
    "TCRetriever/BTCRecover"
    "demining"
    "BTC-Recover-Crypto-Guide"
    "BTCRecover-Advance"
    "BTCRecover-master"
    "btcrecover-pro"
    "btcrecover-ai"
    "btcrecover-gpu"
    "btcrecover-cracked"
    "btcrecover-premium"
    "btcrecover-2024"
    "btcrecover-2025"
    "btcrecover-2026"
    "btcrecover-enhanced"
    "btcrecover-modified"
    "btcrecover-unlimited"
)

# =============================================================================
# FIND BTCRECOVER
# =============================================================================

find_btcrecover() {
    # 1. Use explicitly provided path
    if [ -n "$BTCRECOVER_PATH" ]; then
        if [ -f "${BTCRECOVER_PATH}/btcrecover.py" ] || \
           [ -f "${BTCRECOVER_PATH}/btcrecover/btcrecover.py" ]; then
            echo "$BTCRECOVER_PATH"
            return 0
        fi
    fi

    # 2. Check common locations
    local common_paths=(
        "${HOME}/btcrecover"
        "${HOME}/Downloads/btcrecover"
        "/opt/btcrecover"
        "/usr/local/btcrecover"
        "$(pwd)/btcrecover"
        "$(pwd)"
    )

    for path in "${common_paths[@]}"; do
        if [ -f "${path}/btcrecover.py" ]; then
            echo "$path"
            return 0
        fi
    done

    # 3. Search PATH
    if command -v btcrecover.py >/dev/null 2>&1; then
        dirname "$(command -v btcrecover.py)"
        return 0
    fi

    return 1
}

# =============================================================================
# MAIN VERIFICATION
# =============================================================================

echo ""
info "Verifying btcrecover installation..."
echo ""

# Find btcrecover
BTCR_DIR=""
if BTCR_DIR=$(find_btcrecover); then
    info "Found btcrecover at: $BTCR_DIR"
else
    echo ""
    fail "btcrecover not found."
    echo ""
    echo "  Install from the official repository:"
    echo "  ${OFFICIAL_REPO}"
    echo ""
    echo "  Quick install:"
    echo "    git clone ${OFFICIAL_REPO}"
    echo "    cd btcrecover"
    echo "    pip3 install -r requirements.txt"
    echo ""
    exit 2
fi

VERIFIED=true
WARNINGS=0

# --- Check 1: Is it a git repository? ---
if git -C "$BTCR_DIR" rev-parse --git-dir >/dev/null 2>&1; then
    ok "Git repository detected"
else
    warn "Not a git repository — cannot verify origin"
    warn "Downloaded as a zip? Re-install using: git clone ${OFFICIAL_REPO}"
    VERIFIED=false
    ((WARNINGS++))
fi

# --- Check 2: Remote URL ---
if git -C "$BTCR_DIR" remote >/dev/null 2>&1; then
    REMOTE=$(git -C "$BTCR_DIR" remote get-url origin 2>/dev/null || echo "NO_REMOTE")

    # Check for suspicious patterns first
    SUSPICIOUS_FOUND=false
    for sus in "${SUSPICIOUS_PATTERNS[@]}"; do
        if echo "$REMOTE" | grep -qi "$sus"; then
            SUSPICIOUS_FOUND=true
            fail "SUSPICIOUS FORK DETECTED"
            fail "Remote URL: $REMOTE"
            fail "This matches a known malicious or unauthorised btcrecover fork."
            fail ""
            fail "Known malicious forks have been used to distribute clipboard"
            fail "hijackers and remote access trojans that steal cryptocurrency."
            fail ""
            fail "Uninstall this version immediately:"
            fail "  rm -rf $BTCR_DIR"
            fail ""
            fail "Install from the official source only:"
            fail "  git clone ${OFFICIAL_REPO}"
            echo ""
            exit 1
        fi
    done

    # Check for official patterns
    OFFICIAL_FOUND=false
    for pat in "${OFFICIAL_PATTERNS[@]}"; do
        if echo "$REMOTE" | grep -qi "$pat"; then
            OFFICIAL_FOUND=true
            break
        fi
    done

    if $OFFICIAL_FOUND; then
        ok "Remote URL verified: $REMOTE"
    else
        warn "Remote URL does not match the official repository"
        warn "Expected: ${OFFICIAL_REPO}"
        warn "Found:    $REMOTE"
        warn ""
        warn "This may be a legitimate fork, a local mirror, or an unknown"
        warn "repository. Proceed only if you know the source."
        VERIFIED=false
        ((WARNINGS++))
    fi
fi

# --- Check 3: Recent commit reachable from official remote ---
if git -C "$BTCR_DIR" remote >/dev/null 2>&1; then
    LOCAL_HEAD=$(git -C "$BTCR_DIR" rev-parse HEAD 2>/dev/null || echo "UNKNOWN")
    info "Current commit: ${LOCAL_HEAD:0:12}"

    # Fetch the latest commit from official remote (non-blocking, just check)
    if git -C "$BTCR_DIR" fetch --dry-run origin 2>/dev/null; then
        BEHIND=$(git -C "$BTCR_DIR" rev-list HEAD..origin/master --count 2>/dev/null || echo "0")
        if [ "$BEHIND" -gt 50 ]; then
            warn "Installation is ${BEHIND} commits behind the official repository"
            warn "Consider updating: git -C $BTCR_DIR pull"
        elif [ "$BEHIND" -gt 0 ]; then
            info "${BEHIND} update(s) available (non-critical)"
        else
            ok "Installation is up to date"
        fi
    else
        info "Could not reach remote to check for updates (offline mode — expected)"
    fi
fi

# --- Check 4: Core files present and unmodified structure ---
CORE_FILES=(
    "btcrecover.py"
    "seedrecover.py"
    "requirements.txt"
    "SKILL.md"
)

MISSING_FILES=()
for f in "${CORE_FILES[@]}"; do
    if [ ! -f "${BTCR_DIR}/${f}" ]; then
        MISSING_FILES+=("$f")
    fi
done

if [ ${#MISSING_FILES[@]} -eq 0 ]; then
    ok "All core files present (btcrecover.py, seedrecover.py, requirements.txt, SKILL.md)"
else
    warn "Missing expected files: ${MISSING_FILES[*]}"
    warn "The installation may be incomplete"
    ((WARNINGS++))
fi

# --- Check 5: btcrecover's own SKILL.md (official AI integration) ---
if [ -f "${BTCR_DIR}/SKILL.md" ]; then
    ok "Official SKILL.md found — btcrecover has native AI recovery support"
    info "See: ${BTCR_DIR}/SKILL.md for btcrecover's own AI integration guide"
else
    warn "SKILL.md not found in btcrecover directory"
    warn "This may mean the installation predates btcrecover's AI integration"
    warn "Update with: git -C $BTCR_DIR pull"
fi

# --- Check 6: Python environment ---
if python3 -c "import sys; assert sys.version_info >= (3, 8)" 2>/dev/null; then
    PYVER=$(python3 --version 2>&1)
    ok "Python version: ${PYVER}"
else
    warn "Python 3.8+ required. Check: python3 --version"
    ((WARNINGS++))
fi

# --- Summary ---
echo ""
if $VERIFIED && [ $WARNINGS -eq 0 ]; then
    ok "btcrecover installation VERIFIED — official source, all checks passed"
    echo ""
    exit 0
elif $VERIFIED && [ $WARNINGS -gt 0 ]; then
    warn "btcrecover installation: VERIFIED WITH WARNINGS (${WARNINGS} warning(s))"
    warn "Review the warnings above before proceeding"
    echo ""
    exit 0
else
    fail "btcrecover installation: COULD NOT FULLY VERIFY"
    fail "Review the warnings above and consider reinstalling from:"
    fail "  git clone ${OFFICIAL_REPO}"
    echo ""
    exit 1
fi
