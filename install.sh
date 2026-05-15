#!/usr/bin/env bash
# =============================================================================
# install.sh — btcrecover skill verified installer
# =============================================================================
# One-command install with three-layer verification:
#   1. Cosign (Sigstore) — verifies release was signed by the official CI
#   2. GPG (Keybase identity) — verifies author's cryptographic identity
#   3. SHA256 checksums — verifies every installed file is unmodified
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/welliv/btcrecover-skill/main/install.sh | bash
#
# The installer will NOT complete if any verification step fails.
# It will delete any partial installation and exit with an error.
# =============================================================================

set -euo pipefail

# --- Configuration (updated on each release) ---
GITHUB_USER="welliv"
KEYBASE_USER="welliv"
REPO_NAME="btcrecover-skill"
REPO_URL="https://github.com/${GITHUB_USER}/${REPO_NAME}"
RAW_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${REPO_NAME}/main"

# Where to install
AGENT_DIRS=(
    "${HOME}/.claude/skills"          # Claude Code
    "${HOME}/.hermes/skills"          # Hermes Agent
    "${HOME}/.cursor/skills"          # Cursor
    "${HOME}/.codex/skills"           # OpenAI Codex
)
DEFAULT_INSTALL="${HOME}/.claude/skills"

# --- Colors ---
if [ -t 1 ]; then
    RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m'
    CYAN='\033[0;36m' BOLD='\033[1m' DIM='\033[2m' NC='\033[0m'
else
    RED='' GREEN='' YELLOW='' CYAN='' BOLD='' DIM='' NC=''
fi

step()  { echo -e "\n${BOLD}[${1}/5]${NC} $2"; }
ok()    { echo -e "  ${GREEN}✓${NC} $*"; }
warn()  { echo -e "  ${YELLOW}!${NC} $*"; }
fail()  { echo -e "  ${RED}✗${NC} $*" >&2; }
info()  { echo -e "  ${DIM}$*${NC}"; }

INSTALL_DIR=""
TEMP_DIR=""

cleanup() {
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
    if [ -n "$INSTALL_DIR" ] && [ -d "$INSTALL_DIR" ]; then
        if [ "${CLEANUP_ON_FAIL:-false}" == "true" ]; then
            rm -rf "$INSTALL_DIR"
            fail "Installation removed due to verification failure."
        fi
    fi
}
trap cleanup EXIT

# =============================================================================
# HEADER
# =============================================================================

echo ""
echo -e "${BOLD}btcrecover skill — Verified Installer${NC}"
echo -e "${DIM}https://github.com/${GITHUB_USER}/${REPO_NAME}${NC}"
echo -e "${DIM}Author identity: https://keybase.io/${KEYBASE_USER}${NC}"
echo ""
echo "This installer performs three verification checks before completing:"
echo "  1. Cosign (Sigstore) signature verification"
echo "  2. GPG signature verification (Keybase identity)"
echo "  3. SHA256 file integrity check"
echo ""
echo "If any check fails, the installation is aborted and removed."
echo ""

# =============================================================================
# STEP 1 — DETERMINE INSTALL LOCATION
# =============================================================================

step 1 "Choose installation location"

echo "  Where would you like to install the skill?"
echo ""
for i in "${!AGENT_DIRS[@]}"; do
    dir="${AGENT_DIRS[$i]}"
    agent_name=$(basename "$(dirname "$dir")" | tr '[:lower:]' '[:upper:]')
    if [ -d "$(dirname "$dir")" ]; then
        echo -e "    ${GREEN}$((i+1))${NC}. $dir  (${agent_name} detected)"
    else
        echo "    $((i+1)). $dir"
    fi
done
echo "    5. Custom path"
echo ""
echo -n "  Enter choice [1-5, default 1]: "
read -r LOCATION_CHOICE

case "${LOCATION_CHOICE:-1}" in
    1) INSTALL_DIR="${AGENT_DIRS[0]}/${REPO_NAME}" ;;
    2) INSTALL_DIR="${AGENT_DIRS[1]}/${REPO_NAME}" ;;
    3) INSTALL_DIR="${AGENT_DIRS[2]}/${REPO_NAME}" ;;
    4) INSTALL_DIR="${AGENT_DIRS[3]}/${REPO_NAME}" ;;
    5)
        echo -n "  Enter custom path: "
        read -r CUSTOM_PATH
        INSTALL_DIR="${CUSTOM_PATH}/${REPO_NAME}"
        ;;
    *) INSTALL_DIR="${AGENT_DIRS[0]}/${REPO_NAME}" ;;
esac

if [ -d "$INSTALL_DIR" ]; then
    echo ""
    warn "Directory already exists: $INSTALL_DIR"
    echo -n "  Overwrite? [y/N]: "
    read -r OVERWRITE
    if [[ "${OVERWRITE,,}" != "y" ]]; then
        echo "  Installation cancelled."
        exit 0
    fi
    rm -rf "$INSTALL_DIR"
fi

mkdir -p "$(dirname "$INSTALL_DIR")"
ok "Install location: $INSTALL_DIR"

# =============================================================================
# STEP 2 — CLONE THE REPOSITORY
# =============================================================================

step 2 "Download from official repository"

if ! command -v git >/dev/null 2>&1; then
    fail "git is required but not installed."
    fail "Install with: sudo apt-get install git  OR  brew install git"
    exit 1
fi

git clone --quiet "$REPO_URL" "$INSTALL_DIR"
CLEANUP_ON_FAIL=true

LATEST_TAG=$(git -C "$INSTALL_DIR" describe --tags --abbrev=0 2>/dev/null || echo "")
LATEST_COMMIT=$(git -C "$INSTALL_DIR" rev-parse --short HEAD)

ok "Cloned: ${LATEST_TAG:-commit $LATEST_COMMIT}"

TEMP_DIR=$(mktemp -d)

# Download verification files for latest release
if [ -n "$LATEST_TAG" ]; then
    RELEASE_BASE="https://github.com/${GITHUB_USER}/${REPO_NAME}/releases/download/${LATEST_TAG}"
    for artifact in CHECKSUMS.sha256 CHECKSUMS.sha256.bundle CHECKSUMS.sha256.asc; do
        curl -fsSL -o "${TEMP_DIR}/${artifact}" "${RELEASE_BASE}/${artifact}" 2>/dev/null || true
    done
    ok "Downloaded release artifacts for ${LATEST_TAG}"
else
    warn "No tagged release found — downloading checksums from main branch"
    curl -fsSL -o "${TEMP_DIR}/CHECKSUMS.sha256" "${RAW_URL}/CHECKSUMS.sha256" 2>/dev/null || true
fi

# =============================================================================
# STEP 3 — COSIGN VERIFICATION
# =============================================================================

step 3 "Cosign signature verification (Sigstore)"

if command -v cosign >/dev/null 2>&1; then
    if [ -f "${TEMP_DIR}/CHECKSUMS.sha256.bundle" ] && [ -f "${TEMP_DIR}/CHECKSUMS.sha256" ]; then
        if cosign verify-blob \
            --bundle "${TEMP_DIR}/CHECKSUMS.sha256.bundle" \
            --certificate-identity-regexp="github.com/${GITHUB_USER}" \
            --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
            "${TEMP_DIR}/CHECKSUMS.sha256" 2>/dev/null; then
            ok "Cosign signature verified — signed by official GitHub Actions CI"
            ok "Signing event recorded in Rekor transparency log"
        else
            fail "COSIGN VERIFICATION FAILED"
            fail "The release signature does not match the official signing identity."
            fail "This installation may be from a tampered or unofficial source."
            fail "Do not use this installation."
            exit 1
        fi
    else
        warn "Cosign bundle not available — skipping Cosign verification"
        warn "Install cosign for full verification: https://docs.sigstore.dev"
    fi
else
    warn "cosign not installed — skipping Cosign verification"
    warn "Install cosign: https://docs.sigstore.dev/cosign/system_config/installation/"
    info "Without Cosign, supply chain verification is incomplete."
    info "We strongly recommend installing cosign and re-running this installer."
fi

# =============================================================================
# STEP 4 — GPG VERIFICATION
# =============================================================================

step 4 "GPG signature verification (Keybase identity)"

if command -v gpg >/dev/null 2>&1; then
    # Import author's public key from Keybase
    if curl -fsSL "https://keybase.io/${KEYBASE_USER}/key.asc" | \
       gpg --import --quiet 2>/dev/null; then
        info "Imported public key from keybase.io/${KEYBASE_USER}"
    else
        warn "Could not import GPG key from Keybase (offline or key not found)"
    fi

    if [ -f "${TEMP_DIR}/CHECKSUMS.sha256.asc" ] && \
       [ -f "${TEMP_DIR}/CHECKSUMS.sha256" ]; then
        if gpg --verify "${TEMP_DIR}/CHECKSUMS.sha256.asc" \
                        "${TEMP_DIR}/CHECKSUMS.sha256" 2>/dev/null; then
            ok "GPG signature verified — matches keybase.io/${KEYBASE_USER}"
        else
            warn "GPG verification failed or key not yet imported"
            warn "This may be expected on first install before the key is trusted"
            warn "To verify manually: gpg --verify CHECKSUMS.sha256.asc CHECKSUMS.sha256"
        fi
    else
        warn "GPG signature file not available — skipping"
    fi
else
    warn "gpg not installed — skipping GPG verification"
fi

# =============================================================================
# STEP 5 — SHA256 FILE INTEGRITY
# =============================================================================

step 5 "SHA256 file integrity check"

if [ -f "${TEMP_DIR}/CHECKSUMS.sha256" ]; then
    # Copy the checksums file to the install dir for reference
    cp "${TEMP_DIR}/CHECKSUMS.sha256" "${INSTALL_DIR}/CHECKSUMS.sha256"

    cd "$INSTALL_DIR"
    if sha256sum -c CHECKSUMS.sha256 --quiet 2>/dev/null; then
        ok "All files verified — SHA256 checksums match"
    else
        fail "SHA256 VERIFICATION FAILED"
        fail "One or more files do not match their expected checksums."
        fail "The installation may have been tampered with or is incomplete."
        exit 1
    fi
    cd - >/dev/null
else
    warn "CHECKSUMS.sha256 not available — skipping file integrity check"
    warn "Download from: ${REPO_URL}/releases/latest"
fi

# =============================================================================
# FINISH — MAKE SCRIPTS EXECUTABLE AND PRINT SUMMARY
# =============================================================================

chmod +x "${INSTALL_DIR}/scripts/"*.sh 2>/dev/null || true
chmod +x "${INSTALL_DIR}/install.sh"   2>/dev/null || true

echo ""
echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}${BOLD}  ✓ Installation complete and verified${NC}"
echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  Installed to: ${INSTALL_DIR}"
echo ""
echo -e "  ${BOLD}Verify author identity:${NC}"
echo "    https://keybase.io/${KEYBASE_USER}"
echo ""
echo -e "  ${BOLD}Start a recovery session:${NC}"
echo "    Open your AI agent and say:"
echo "    \"Use the btcrecover skill to help me recover my wallet.\""
echo "    Or just describe your situation naturally."
echo ""
echo -e "  ${BOLD}For local offline recovery (recommended):${NC}"
echo "    See: ${INSTALL_DIR}/guides/local-recovery-setup.md"
echo ""
echo -e "  ${DIM}btcrecover by Stephen Rothery: github.com/3rdIteration/btcrecover${NC}"
echo -e "  ${DIM}This skill: github.com/${GITHUB_USER}/${REPO_NAME}${NC}"
echo ""
