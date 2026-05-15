#!/bin/bash
# btcrecover-skill connectivity checker
# 3-layer online/offline detection: ping → DNS → TCP
#
# Normal mode (backward-compatible):
#   bash scripts/connectivity-check.sh
#   → exit 0 = FULLY_ONLINE | exit 1 = LOCAL_ONLY | exit 2 = OFFLINE
#
# Enforce mode (hard gate — interactive tier consent):
#   bash scripts/connectivity-check.sh --enforce
#   → Shows tier menu if online, requires typed consent
#   → Only returns exit 0 after valid consent or confirmed offline

set -euo pipefail

LAYER1_TARGET="1.1.1.1"
LAYER2_TARGET="cloudflare.com"
LAYER3_TARGET="1.1.1.1:53"

SESSION_DIR="${HOME}/.btcrecover-skill"
CONSENT_LOG="${SESSION_DIR}/consent.log"

# Colours (no-op if not a terminal)
if [ -t 1 ]; then
  RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m'
  CYAN='\033[0;36m' BOLD='\033[1m' DIM='\033[2m' NC='\033[0m'
else
  RED='' GREEN='' YELLOW='' CYAN='' BOLD='' DIM='' NC=''
fi

step() { echo -e "${BOLD}${1}${NC}"; }
ok()   { echo -e "  ${GREEN}✓${NC} $*"; }
warn() { echo -e "  ${YELLOW}!${NC} $*"; }
fail() { echo -e "  ${RED}✗${NC} $*" >&2; }
info() { echo -e "  ${DIM}$*${NC}"; }
hr()   { echo -e "${DIM}────────────────────────────────────────────────────────${NC}"; }

log_consent() {
  local tier="$1" phrase="$2"
  mkdir -p "$SESSION_DIR"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] consent: Tier ${tier} — ${phrase}" >> "$CONSENT_LOG"
  ok "Consent logged to ${CONSENT_LOG}"
}

# =============================================================================
# LAYERED CONNECTIVITY CHECK
# =============================================================================

echo ""
step "Checking connectivity (3-layer)..."
echo ""

# Layer 1: ICMP ping
if ping -c 1 -W 2 "$LAYER1_TARGET" >/dev/null 2>&1; then
  echo "  ✓ Layer 1 (ICMP): Online"
  LAYER1=1
else
  echo "  ✗ Layer 1 (ICMP): Offline"
  LAYER1=0
fi

# Layer 2: DNS resolution via TCP port 53
if timeout 3 bash -c "echo >/dev/tcp/$LAYER2_TARGET/53" 2>/dev/null; then
  echo "  ✓ Layer 2 (DNS): Online"
  LAYER2=1
else
  echo "  ✗ Layer 2 (DNS): Offline"
  LAYER2=0
fi

# Layer 3: Direct TCP connection
if timeout 3 bash -c "echo >/dev/tcp/${LAYER3_TARGET%:*}/${LAYER3_TARGET#*:}" 2>/dev/null; then
  echo "  ✓ Layer 3 (TCP): Online"
  LAYER3=1
else
  echo "  ✗ Layer 3 (TCP): Offline"
  LAYER3=0
fi

echo ""

# Determine overall status
if [[ $LAYER1 -eq 1 && $LAYER2 -eq 1 && $LAYER3 -eq 1 ]]; then
  ONLINE_STATUS="FULLY_ONLINE"
  EXIT_CODE=0
elif [[ $LAYER1 -eq 1 ]]; then
  ONLINE_STATUS="LOCAL_ONLY"
  EXIT_CODE=1
else
  ONLINE_STATUS="OFFLINE"
  EXIT_CODE=2
fi

echo "  STATUS: ${ONLINE_STATUS}"
echo ""

# =============================================================================
# BACKWARD-COMPATIBLE MODE (no --enforce flag)
# =============================================================================

ENFORCE=false
for arg in "$@"; do
  [ "$arg" = "--enforce" ] && ENFORCE=true
done

if ! $ENFORCE; then
  exit $EXIT_CODE
fi

# =============================================================================
# ENFORCE MODE — INTERACTIVE TIER CONSENT
# =============================================================================

# If already offline, no enforcement needed
if [[ $EXIT_CODE -eq 2 ]]; then
  echo -e "${GREEN}${BOLD}  ✅ OFFLINE — Tier 1 active (maximum security)${NC}"
  echo ""
  echo "  No consent required. This is the default safe path."
  echo ""
  exit 0
fi

# ──────────────────────────────────────────────────────────────────────────────
# ONLINE — Must show tier menu and obtain consent
# ──────────────────────────────────────────────────────────────────────────────

echo -e "${RED}${BOLD}  ⚠  YOU ARE ONLINE${NC}"
echo ""
echo "  Running wallet recovery while connected to the internet"
echo "  exposes your sensitive data to network-level threats."
echo ""

while true; do

hr
echo ""
step "Choose your security tier:"
echo ""
echo -e "  ${GREEN}1${NC} — DISCONNECT (recommended)"
echo "       Type: DISCONNECTED"
echo "       Disconnect Wi-Fi, Ethernet, VPN, and mobile hotspot."
echo "       The check will re-run to confirm offline status."
echo ""
echo -e "  ${YELLOW}2${NC} — TIER 2: Local agent + cloud API"
echo "       Type: TIER2 I UNDERSTAND"
echo "       Text prompts go to cloud AI. Wallet file and keys stay"
echo "       local. You run all btcrecover commands on your machine."
echo ""
echo -e "  ${RED}3${NC} — TIER 3: Fully online"
echo "       Type: TIER3 I UNDERSTAND AND ACCEPT"
echo "       Last resort. Platform controls the environment."
echo "       Treat all keys as compromised if recovery succeeds."
echo "       Sweep funds IMMEDIATELY."
echo ""
hr
echo ""
echo -n "  Type your choice > "
read -r USER_INPUT
echo ""

case "${USER_INPUT^^}" in  # Uppercase for case-insensitive matching

  DISCONNECTED)
    echo "  Re-running connectivity check..."
    echo ""
    # Re-run the layers
    LAYER1=0; LAYER2=0; LAYER3=0
    if ping -c 1 -W 2 "$LAYER1_TARGET" >/dev/null 2>&1; then LAYER1=1; fi
    if timeout 3 bash -c "echo >/dev/tcp/$LAYER2_TARGET/53" 2>/dev/null; then LAYER2=1; fi
    if timeout 3 bash -c "echo >/dev/tcp/${LAYER3_TARGET%:*}/${LAYER3_TARGET#*:}" 2>/dev/null; then LAYER3=1; fi

    if [[ $LAYER1 -eq 0 ]]; then
      echo -e "${GREEN}${BOLD}  ✅ Now offline — Tier 1 active${NC}"
      echo ""
      exit 0
    else
      warn "Still connected. Disconnect all network interfaces and try again."
      echo ""
      continue
    fi
    ;;

  "TIER2 I UNDERSTAND")
    log_consent "2" "I UNDERSTAND"
    echo ""
    echo "  TIER 2 ACTIVE — Wallet file stays local. Text prompts only."
    echo ""
    exit 0
    ;;

  "TIER3 I UNDERSTAND AND ACCEPT")
    log_consent "3" "I UNDERSTAND AND ACCEPT"
    echo ""
    echo -e "${RED}${BOLD}  TIER 3 ACTIVE — Sweep funds immediately on recovery.${NC}"
    echo ""
    exit 0
    ;;

  *)
    warn "Invalid input."
    echo "  Valid options:"
    echo "    DISCONNECTED"
    echo "    TIER2 I UNDERSTAND"
    echo "    TIER3 I UNDERSTAND AND ACCEPT"
    echo ""
    ;;

esac
done
