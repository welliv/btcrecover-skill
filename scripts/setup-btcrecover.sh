#!/usr/bin/env bash
# =============================================================================
# setup-btcrecover.sh — btcrecover skill
# =============================================================================
# Guided installer for btcrecover. Runs once, writes a marker file.
# Now includes optional dependency groups for advanced wallet types.
#
# Usage:
#   ./scripts/setup-btcrecover.sh            # normal first-run
#   ./scripts/setup-btcrecover.sh --check    # status only
#   ./scripts/setup-btcrecover.sh --force    # reinstall
#   ./scripts/setup-btcrecover.sh --update   # git pull + pip upgrade
#   ./scripts/setup-btcrecover.sh --extras   # add optional deps to existing install
#
# Exit codes: 0=ready  1=failed/declined  2=prerequisites missing
# =============================================================================

set -euo pipefail

SKILL_DIR="${HOME}/.btcrecover-skill"
MARKER="${SKILL_DIR}/.btcrecover-verified"
BTCR_INSTALL="${SKILL_DIR}/btcrecover"
VENV_DIR="${SKILL_DIR}/venv"
OFFICIAL_REPO="https://github.com/3rdIteration/btcrecover"
OFFICIAL_DOCS="https://btcrecover.readthedocs.io"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Optional dep groups (benchmark-validated)
EXTRAS_CORE="coincurve py_crypto_hd_wallet pynacl"
EXTRAS_ETH_VALIDATOR="staking-deposit py_ecc"

FORCE=false; CHECK_ONLY=false; UPDATE=false; EXTRAS_ONLY=false
for arg in "$@"; do
  case "$arg" in
    --force)  FORCE=true ;;
    --check)  CHECK_ONLY=true ;;
    --update) UPDATE=true ;;
    --extras) EXTRAS_ONLY=true ;;
  esac
done

if [ -t 1 ]; then
  RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m'
  BOLD='\033[1m' DIM='\033[2m' NC='\033[0m'
else
  RED='' GREEN='' YELLOW='' BOLD='' DIM='' NC=''
fi

line() { echo -e "${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }
ok()   { echo -e "  ${GREEN}✓${NC} $*"; }
warn() { echo -e "  ${YELLOW}!${NC} $*"; }
fail() { echo -e "  ${RED}✗${NC} $*" >&2; }
info() { echo -e "  ${DIM}$*${NC}"; }

mkdir -p "$SKILL_DIR"

pip_install() {
  local packages="$1" quiet="${2:-true}"
  if [ -f "${VENV_DIR}/bin/pip" ]; then
    $quiet && "${VENV_DIR}/bin/pip" install --quiet $packages 2>/dev/null \
           || "${VENV_DIR}/bin/pip" install $packages
  else
    $quiet && python3 -m pip install --quiet --user $packages 2>/dev/null \
           || python3 -m pip install --user $packages
  fi
}

update_marker() {
  local key="$1" value="$2"
  [ -f "$MARKER" ] || return
  grep -q "^${key}:" "$MARKER" \
    && sed -i "s|^${key}:.*|${key}: ${value}|" "$MARKER" \
    || echo "${key}: ${value}" >> "$MARKER"
}

# ── --check ──────────────────────────────────────────────────────────────────
if $CHECK_ONLY; then
  echo ""
  echo -e "${BOLD}btcrecover installation status${NC}"
  echo ""
  if [ -f "$MARKER" ]; then
    ok "Installed and verified"
    grep -v "^#" "$MARKER" 2>/dev/null | while IFS=': ' read -r k v; do
      info "  $k: $v"
    done
  elif [ -f "${BTCR_INSTALL}/btcrecover.py" ]; then
    warn "Found but not verified — run setup again"
  else
    fail "Not installed — run ./scripts/setup-btcrecover.sh"
  fi
  echo ""; exit 0
fi

# ── --update ─────────────────────────────────────────────────────────────────
if $UPDATE; then
  echo ""
  echo -e "${BOLD}Updating btcrecover${NC}"; echo ""
  [ -d "${BTCR_INSTALL}/.git" ] || { fail "Not a git repo — run setup first"; exit 1; }
  REMOTE=$(git -C "$BTCR_INSTALL" remote get-url origin 2>/dev/null || echo "")
  if echo "$REMOTE" | grep -q "3rdIteration/btcrecover"; then
    git -C "$BTCR_INSTALL" pull --quiet
    ok "Updated to $(git -C "$BTCR_INSTALL" rev-parse --short HEAD)"
    pip_install "-r ${BTCR_INSTALL}/requirements.txt --upgrade" false
    ok "Dependencies updated"
    update_marker "btcrecover_commit" "$(git -C "$BTCR_INSTALL" rev-parse --short HEAD 2>/dev/null)"
    update_marker "updated" "$(date '+%Y-%m-%d %H:%M:%S')"
  else
    fail "Remote is not 3rdIteration/btcrecover: $REMOTE"; exit 1
  fi
  echo ""; exit 0
fi

# ── --extras (add optional deps to existing install) ─────────────────────────
if $EXTRAS_ONLY; then
  echo ""
  echo -e "${BOLD}Installing optional wallet support${NC}"; echo ""
  [ -f "$MARKER" ] || { fail "btcrecover not installed — run setup first"; exit 1; }

  echo "  Core extras: Ethereum Keystore, Polkadot, Helium, Warpwallet..."
  pip_install "$EXTRAS_CORE" false \
    && ok "Installed" \
    || warn "Some failed (may already be installed)"

  echo ""
  echo -n "  Also Ethereum Validator support? (~200MB) [y/N]: "
  read -r EV
  if [[ "${EV,,}" == "y" ]]; then
    pip_install "$EXTRAS_ETH_VALIDATOR" false \
      && ok "Ethereum Validator support installed" \
      || warn "Failed — see ${OFFICIAL_DOCS}/INSTALL"
    update_marker "ethereum_validator" "yes"
  fi
  update_marker "optional_extras" "yes"
  echo ""; ok "Done."; echo ""; exit 0
fi

# ── Already installed? ────────────────────────────────────────────────────────
[ -f "$MARKER" ] && ! $FORCE && exit 0

# ── Introduction ──────────────────────────────────────────────────────────────
echo ""; line; echo ""
echo -e "  ${BOLD}Setting up btcrecover — one-time setup${NC}"; echo ""
echo "  Downloads btcrecover by Stephen Rothery (3rdIteration),"
echo "  installs it in an isolated environment, and optionally adds"
echo "  support for advanced wallet types."
echo ""; line; echo ""
echo -n "  Ready? [Y/n]: "; read -r READY
[[ "${READY,,}" == "n" ]] && { warn "Run again when ready."; exit 1; }

# ── Step 1: Prerequisites ─────────────────────────────────────────────────────
echo ""; echo -e "${BOLD}[1/5]${NC} Checking prerequisites"
PREREQ_OK=true

if command -v python3 >/dev/null 2>&1; then
  PYVER=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
  OK=$(python3 -c "import sys; print('yes' if sys.version_info>=(3,8) else 'no')")
  [ "$OK" = "yes" ] && ok "Python ${PYVER}" || { fail "Python 3.8+ required (found ${PYVER})"; PREREQ_OK=false; }
else
  fail "Python 3 not found — install: sudo apt-get install python3 python3-pip python3-venv"
  PREREQ_OK=false
fi

command -v git >/dev/null 2>&1 \
  && ok "git $(git --version | awk '{print $3}')" \
  || { fail "git not found — install: sudo apt-get install git"; PREREQ_OK=false; }

$PREREQ_OK || { echo ""; fail "Fix prerequisites then run again."; exit 2; }

# ── Step 2: Clone ─────────────────────────────────────────────────────────────
echo ""; echo -e "${BOLD}[2/5]${NC} Downloading btcrecover"

ONLINE=false
ping -c 1 -W 3 8.8.8.8 >/dev/null 2>&1 \
  || curl -fsSL --max-time 5 https://github.com >/dev/null 2>&1 \
  && ONLINE=true || true

if [ -d "$BTCR_INSTALL" ]; then
  if $FORCE; then rm -rf "$BTCR_INSTALL"
  else
    warn "Existing install found at: ${BTCR_INSTALL}"
    echo -n "  Remove and reinstall? [Y/n]: "; read -r R
    [[ "${R,,}" != "n" ]] && rm -rf "$BTCR_INSTALL"
  fi
fi

if [ ! -d "$BTCR_INSTALL" ]; then
  if ! $ONLINE; then
    echo ""
    warn "Offline detected. btcrecover needs internet once to download."
    echo ""
    echo "  Option A: Connect briefly, run setup, then disconnect."
    echo "  Option B: On another machine: git clone ${OFFICIAL_REPO}"
    echo "            Copy folder to: ${BTCR_INSTALL}"
    echo "            Then run setup again."
    echo ""; exit 1
  fi
  echo -n "  Cloning..."
  git clone --quiet --depth=1 "$OFFICIAL_REPO" "$BTCR_INSTALL" \
    && echo "" && ok "Downloaded ($(git -C "$BTCR_INSTALL" rev-parse --short HEAD))" \
    || { echo ""; fail "Clone failed — check connection"; exit 1; }
fi

# ── Step 3: Core dependencies ─────────────────────────────────────────────────
echo ""; echo -e "${BOLD}[3/5]${NC} Installing core dependencies"
info "Isolated install — no system-level changes"

VENV_OK=false
if python3 -m venv --help >/dev/null 2>&1; then
  python3 -m venv "$VENV_DIR" 2>/dev/null && VENV_OK=true && ok "Virtual environment created" || true
fi
$VENV_OK || warn "Could not create venv — using user-level install"

echo -n "  Installing requirements..."
pip_install "-r ${BTCR_INSTALL}/requirements.txt" true \
  && echo "" && ok "Core requirements installed" \
  || { echo ""; fail "Install failed. Try: pip3 install -r ${BTCR_INSTALL}/requirements.txt"; exit 1; }

if command -v nvidia-smi >/dev/null 2>&1; then
  pip_install "pyopencl" true && ok "GPU acceleration (OpenCL) installed" || warn "GPU extras skipped"
fi

if $VENV_OK; then
  for tool in btcrecover seedrecover; do
    cat > "${SKILL_DIR}/${tool}-run" << WRAPPER
#!/usr/bin/env bash
exec "${VENV_DIR}/bin/python3" "${BTCR_INSTALL}/${tool}.py" "\$@"
WRAPPER
    chmod +x "${SKILL_DIR}/${tool}-run"
  done
  ok "Created wrappers: btcrecover-run and seedrecover-run"
fi

# ── Step 4: Optional dependencies ─────────────────────────────────────────────
echo ""; echo -e "${BOLD}[4/5]${NC} Optional wallet type support"; echo ""
echo "  Core install covers: Bitcoin, Ethereum, Litecoin, Dogecoin, Dash,"
echo "  Bitcoin Cash, MetaMask, Bitcoin Core, Electrum, BIP38, Brainwallet,"
echo "  Cardano, Stacks, Tron, Stellar, Ripple, aezeed (LND)."
echo ""
echo "  Extras add: Polkadot, Helium, Ethereum Keystore, Warpwallet."
echo ""
echo -n "  Install extras? [Y/n]: "
read -r INSTALL_EXTRAS

INSTALLED_EXTRAS=no; INSTALLED_ETH_VALIDATOR=no

if [[ "${INSTALL_EXTRAS,,}" != "n" ]]; then
  echo -n "  Installing..."
  pip_install "$EXTRAS_CORE" true \
    && echo "" && ok "Polkadot, Helium, ETH Keystore, Warpwallet support added" \
    || { echo ""; warn "Some extras failed — run './scripts/setup-btcrecover.sh --extras' to retry"; }
  INSTALLED_EXTRAS=yes

  echo ""
  echo -n "  Also Ethereum Validator (ETH 2.0 staking keys)? ~200MB [y/N]: "
  read -r EV
  if [[ "${EV,,}" == "y" ]]; then
    echo -n "  Installing..."
    pip_install "$EXTRAS_ETH_VALIDATOR" true \
      && echo "" && ok "Ethereum Validator support added" \
      || { echo ""; warn "Failed — see ${OFFICIAL_DOCS}/INSTALL"; }
    INSTALLED_ETH_VALIDATOR=yes
  fi
else
  info "Skipped. Run './scripts/setup-btcrecover.sh --extras' later."
fi

# ── Step 5: Verify ────────────────────────────────────────────────────────────
echo ""; echo -e "${BOLD}[5/5]${NC} Verifying installation"

VERIFY_SCRIPT="${SCRIPT_DIR}/verify-btcrecover.sh"
if [ -f "$VERIFY_SCRIPT" ] && [ -x "$VERIFY_SCRIPT" ]; then
  bash "$VERIFY_SCRIPT" "$BTCR_INSTALL" || {
    VCODE=$?
    [ "$VCODE" -eq 1 ] && { fail "Suspicious installation — see above. Reinstall from official source."; exit 1; }
  }
else
  warn "verify-btcrecover.sh not found — skipping"
fi

# ── Write marker ──────────────────────────────────────────────────────────────
cat > "$MARKER" << MARKER_EOF
# btcrecover-skill setup marker — do not edit
created: $(date '+%Y-%m-%d %H:%M:%S')
btcrecover_path: ${BTCR_INSTALL}
btcrecover_commit: $(git -C "${BTCR_INSTALL}" rev-parse --short HEAD 2>/dev/null || echo "unknown")
venv: ${VENV_DIR}
optional_extras: ${INSTALLED_EXTRAS}
ethereum_validator: ${INSTALLED_ETH_VALIDATOR}
verified: yes
MARKER_EOF

echo ""; line; echo ""
echo -e "  ${GREEN}${BOLD}✓ btcrecover ready${NC}"; echo ""
echo "  Location:  ${BTCR_INSTALL}"
$VENV_OK && echo "  Commands:  ${SKILL_DIR}/btcrecover-run | ${SKILL_DIR}/seedrecover-run"
echo ""
info "Add more wallet support later: ./scripts/setup-btcrecover.sh --extras"
info "Update btcrecover:             ./scripts/setup-btcrecover.sh --update"
echo ""
line; echo ""
echo "  Continuing to recovery..."; echo ""

# ── Post-setup: Disconnect prompt ──────────────────────────────────────────
echo ""
echo -e "${BOLD}${YELLOW}╔══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${YELLOW}║               NOW DISCONNECT FROM THE INTERNET                  ║${NC}"
echo -e "${BOLD}${YELLOW}╚══════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "  btcrecover is installed and ready. Before any recovery work:"
echo ""
echo "  1. ${BOLD}Disconnect Wi-Fi${NC} — turn off wireless"
echo "  2. ${BOLD}Unplug Ethernet${NC} — remove network cable"
echo "  3. ${BOLD}Disable VPN${NC} — disconnect any tunnel"
echo "  4. ${BOLD}Turn off mobile hotspot${NC} — disable tethering"
echo ""
echo "  Run the connectivity check to confirm:"
echo "    bash scripts/connectivity-check.sh --enforce"
echo ""
echo -e "  ${DIM}The safest path is the default path.${NC}"
echo ""
