#!/bin/bash
# btcrecover-skill connectivity checker
# 3-layer online/offline detection: ping → DNS → TCP

set -euo pipefail

LAYER1_TARGET="1.1.1.1"  # Cloudflare DNS
LAYER2_TARGET="cloudflare.com"
LAYER3_TARGET="1.1.1.1:53"  # DNS over TCP

echo "Checking connectivity (3-layer)..."

# Layer 1: ICMP ping
if ping -c 1 -W 2 "$LAYER1_TARGET" >/dev/null 2>&1; then
    echo "✓ Layer 1 (ICMP): Online"
    LAYER1=1
else
    echo "✗ Layer 1 (ICMP): Offline"
    LAYER1=0
fi

# Layer 2: DNS resolution
if timeout 3 bash -c "echo >/dev/tcp/$LAYER2_TARGET/53" 2>/dev/null; then
    echo "✓ Layer 2 (DNS): Online"
    LAYER2=1
else
    echo "✗ Layer 2 (DNS): Offline"
    LAYER2=0
fi

# Layer 3: TCP connection
if timeout 3 bash -c "echo >/dev/tcp/${LAYER3_TARGET%:*}/${LAYER3_TARGET#*:}" 2>/dev/null; then
    echo "✓ Layer 3 (TCP): Online"
    LAYER3=1
else
    echo "✗ Layer 3 (TCP): Offline"
    LAYER3=0
fi

# Determine overall status
if [[ $LAYER1 -eq 1 && $LAYER2 -eq 1 && $LAYER3 -eq 1 ]]; then
    echo "STATUS: FULLY_ONLINE"
    exit 0
elif [[ $LAYER1 -eq 1 ]]; then
    echo "STATUS: LOCAL_ONLY"
    exit 1
else
    echo "STATUS: OFFLINE"
    exit 2
fi