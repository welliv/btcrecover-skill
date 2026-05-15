#!/usr/bin/env bash
# install.sh — btcrecover skill installer
# Usage: curl -fsSL https://raw.githubusercontent.com/welliv/btcrecover-skill/main/install.sh | bash

set -euo pipefail

REPO_URL="https://github.com/welliv/btcrecover-skill"
AGENT_DIRS=(
    "${HOME}/.claude/skills"
    "${HOME}/.hermes/skills"
    "${HOME}/.cursor/skills"
    "${HOME}/.codex/skills"
)
DEFAULT_INSTALL="${HOME}/.claude/skills"

if [ -t 1 ]; then
    BOLD='\033[1m' GREEN='\033[0;32m' YELLOW='\033[1;33m' DIM='\033[2m' NC='\033[0m'
else
    BOLD='' GREEN='' YELLOW='' DIM='' NC=''
fi

echo ""
echo -e "${BOLD}btcrecover skill — Installer${NC}"
echo -e "${DIM}${REPO_URL}${NC}"
echo ""

echo "Where should the skill be installed?"
for i in "${!AGENT_DIRS[@]}"; do
    echo "  $((i+1)). ${AGENT_DIRS[$i]}"
done
echo "  $((i+2)). Custom path"
echo ""
echo -n "Choice [1-5, default 1]: "
read -r CHOICE

case "${CHOICE:-1}" in
    1) INSTALL_DIR="${AGENT_DIRS[0]}/btcrecover-skill" ;;
    2) INSTALL_DIR="${AGENT_DIRS[1]}/btcrecover-skill" ;;
    3) INSTALL_DIR="${AGENT_DIRS[2]}/btcrecover-skill" ;;
    4) INSTALL_DIR="${AGENT_DIRS[3]}/btcrecover-skill" ;;
    5) echo -n "Custom path: "; read -r CUSTOM; INSTALL_DIR="${CUSTOM}/btcrecover-skill" ;;
    *) INSTALL_DIR="${AGENT_DIRS[0]}/btcrecover-skill" ;;
esac

if [ -d "$INSTALL_DIR" ]; then
    echo ""
    echo -e "${YELLOW}Directory exists: $INSTALL_DIR${NC}"
    echo -n "Overwrite? [y/N]: "
    read -r OVERWRITE
    if [ "${OVERWRITE,,}" != "y" ]; then
        echo "Cancelled."
        exit 0
    fi
    rm -rf "$INSTALL_DIR"
fi

echo ""
echo "Cloning from ${REPO_URL}..."
git clone --quiet "$REPO_URL" "$INSTALL_DIR"
chmod +x "${INSTALL_DIR}/scripts/"*.sh

echo ""
echo -e "${GREEN}${BOLD}✓ Installation complete${NC}${NC}"
echo "  Installed to: ${INSTALL_DIR}"
echo ""
echo "Open your AI agent and describe your recovery situation."
echo ""
echo -e "${DIM}btcrecover by Stephen Rothery: github.com/3rdIteration/btcrecover${NC}"
echo -e "${DIM}This skill: ${REPO_URL}${NC}"
