#!/bin/bash
# btcrecover-skill connectivity checker (2-tier version)
# Layered online/offline detection: ping → DNS → TCP
#
# Normal mode:
#   bash scripts/connectivity-check.sh
#   → exit 0 = ONLINE | exit 1 = OFFLINE
#
# Enforce mode (interactive consent):
#   bash scripts/connectivity-check.sh --enforce
#   → Shows tier menu if online, requires typed consent
#   → Only returns exit 0 after valid consent or confirmed offline

set -euo pipefail

LAYER1_TARGET="1.1.1.1"
LAYER2_TARGET="cloudflare.com"
LAYER3_TARGET="1.1.1.1:53"

SESSION_DIR="${HOME}/.btcrecover-skill"
CONSENT_LOG="${SESSION_DIR}/consent.log"

# Colours
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
step "Checking connectivity (2-tier)..."
echo ""

# Layer 1: ICMP ping
if ping -c 1 -W 2 "$LAYER1_TARGET" >/dev/null 2>&1; then
  echo "  ✓ Layer 1 (ICMP): Online"
  LAYER1=1
else
  echo "  ✗ Layer 1 (ICMP): Offline"
  LAYER1=0
fi

# Layer 2: DNS resolution
if timeout 3 bash -c "echo >/dev/tcp/$LAYER2_TARGET/53" 2>/dev/null; then
  echo "  ✓ Layer 2 (DNS): Online"
  LAYER2=1
else
  echo "  ✗ Layer 2 (DNS): Offline"
  LAYER2=0
fi

# Layer 3: Direct TCP
if timeout 3 bash -c "echo >/dev/tcp/${LAYER3_TARGET%:*}/${LAYER3_TARGET#*:}" 2>/dev/null; then
  echo "  ✓ Layer 3 (TCP): Online"
  LAYER3=1
else
  echo "  ✗ Layer 3 (TCP): Offline"
  LAYER3=0
fi

echo ""

if [[ $LAYER1 -eq 1 && $LAYER2 -eq 1 && $LAYER3 -eq 1 ]]; then
  ONLINE=1
  echo -e "${GREEN}Result: ONLINE${NC}"
else
  ONLINE=0
  echo -e "${YELLOW}Result: OFFLINE / PARTIAL${NC}"

  # Additional: check for active non-loopback interfaces
  if command -v ip >/dev/null 2>&1; then
    ACTIVE_IFACES=$(ip -br link show 2>/dev/null | awk '$2 == "UP" && $1 != "lo" {print $1}' | tr '\n' ' ')
    [ -n "$ACTIVE_IFACES" ] && echo -e "  ${YELLOW}Active interfaces: ${ACTIVE_IFACES}(verify these are off for Tier 1)${NC}"
  fi

  # Additional: warn if cloud sync processes are running
  for proc in Dropbox "Google Drive" OneDrive iCloud nextcloud syncthing; do
    pgrep -fi "$proc" >/dev/null 2>&1 && echo -e "  ${YELLOW}Warning: $proc appears to be running — pause before Tier 1 recovery${NC}"
  done

fi

# Enforce mode - two tier consent only
if [[ "${1:-}" == "--enforce" ]]; then
  if [[ $ONLINE -eq 1 ]]; then
    hr
    step "Connectivity detected. Choose tier:"
    echo ""
    echo -e "  ${GREEN}1${NC} — Tier 1 (offline)  |  Local model only (safest)"
    echo -e "  ${YELLOW}2${NC} — Tier 2 (recommended) |  Local data + cloud reasoning"
    echo ""
    read -rp "Enter tier number [1-2]: " choice

    case "$choice" in
      1)
        log_consent 1 "TIER1 I UNDERSTAND"
        echo -e "${GREEN}Tier 1 selected. Offline mode enforced.${NC}"
        ;;
      2)
        read -rp "Type 'TIER2 I UNDERSTAND' to confirm: " confirm
        if [[ "$confirm" == "TIER2 I UNDERSTAND" ]]; then
          log_consent 2 "TIER2 I UNDERSTAND"
          echo -e "${GREEN}Tier 2 selected.${NC}"
        else
          fail "Consent phrase incorrect. Aborting."
          exit 1
        fi
        ;;
      *)
        fail "Invalid choice."
        exit 1
        ;;
    esac
  else
    echo "Offline detected. Tier 1 enforced automatically."
    log_consent 1 "TIER1 AUTO (offline)"
  fi
fi

if [[ $ONLINE -eq 1 ]]; then
  exit 0
else
  exit 1
fi
