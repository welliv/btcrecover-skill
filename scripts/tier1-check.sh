#!/bin/bash
# btcrecover-skill: tier1-check.sh
# Lightweight Tier 1 Readiness Checker
#
# Verifies that the user is ready for fully offline (Tier 1) recovery.
# This script does NOT install anything. It only checks readiness.

set -euo pipefail

# Colours
if [ -t 1 ]; then
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    YELLOW='\033[1;33m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    GREEN=''
    RED=''
    YELLOW=''
    BOLD=''
    NC=''
fi

ok()    { echo -e "${GREEN}✓${NC} $*"; }
fail()  { echo -e "${RED}✗${NC} $*"; }
warn()  { echo -e "${YELLOW}!${NC} $*"; }
info()  { echo -e "  $*"; }

echo ""
echo "=== Tier 1 Readiness Check ==="
echo "This checks if your environment is ready for fully offline recovery."
echo ""

READY=true

# 1. Check offline status
echo "1. Checking network connectivity..."
if ping -c 1 -W 2 1.1.1.1 >/dev/null 2>&1; then
    fail "Internet access detected (ping succeeded)"
    info "Tier 1 requires you to be fully offline."
    READY=false
else
    ok "No internet access detected (good for Tier 1)"
fi

# 2. Check for local AI model
echo ""
echo "2. Checking for local AI model..."

LOCAL_MODEL_FOUND=false

# Check Ollama
if command -v ollama >/dev/null 2>&1; then
    if ollama list >/dev/null 2>&1; then
        MODELS=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}' | head -3)
        if [ -n "$MODELS" ]; then
            ok "Ollama is running with local model(s):"
            echo "$MODELS" | sed 's/^/     - /'
            LOCAL_MODEL_FOUND=true
        fi
    fi
fi

# Check for local Hermes / other local endpoints (basic check)
if [ "$LOCAL_MODEL_FOUND" = false ]; then
    # Check common local ports
    if timeout 2 bash -c 'echo > /dev/tcp/127.0.0.1/11434' 2>/dev/null; then
        ok "Local model detected on port 11434 (likely Ollama)"
        LOCAL_MODEL_FOUND=true
    elif timeout 2 bash -c 'echo > /dev/tcp/127.0.0.1/8080' 2>/dev/null; then
        ok "Local model detected on port 8080"
        LOCAL_MODEL_FOUND=true
    fi
fi

if [ "$LOCAL_MODEL_FOUND" = false ]; then
    fail "No local AI model detected"
    info "You need to run a local model (e.g. Ollama) for Tier 1."
    info "See docs/tier1-setup.md for setup instructions."
    READY=false
fi

# Final result
echo ""
if [ "$READY" = true ]; then
    echo -e "${GREEN}${BOLD}✅ Tier 1 Ready${NC}"
    echo "You can proceed with fully offline recovery."
    exit 0
else
    echo -e "${RED}${BOLD}❌ Tier 1 Not Ready${NC}"
    echo "Please resolve the issues above before using Tier 1."
    exit 1
fi
