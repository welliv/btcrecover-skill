#!/usr/bin/env bash
# install.sh — btcrecover skill installer

set -euo pipefail

REPO="https://github.com/welliv/btcrecover-skill"
INSTALL_PATHS=(
    "${HOME}/.claude/skills"
    "${HOME}/.hermes/skills"
    "${HOME}/.cursor/skills"
    "${HOME}/.codex/skills"
)

echo ""
echo "btcrecover skill installer"
echo "This will install the skill for use with AI agents."
echo ""

echo "Where would you like to install it?"
for i in "${!INSTALL_PATHS[@]}"; do
    echo "  $((i+1)). ${INSTALL_PATHS[$i]}"
done
echo "  $((i+2)). Custom location"
echo ""

read -r -p "Choice [1-5, default 1]: " choice
choice=${choice:-1}

case $choice in
    1) TARGET="${INSTALL_PATHS[0]}" ;;
    2) TARGET="${INSTALL_PATHS[1]}" ;;
    3) TARGET="${INSTALL_PATHS[2]}" ;;
    4) TARGET="${INSTALL_PATHS[3]}" ;;
    5) read -r -p "Enter custom path: " custom; TARGET="$custom" ;;
    *) TARGET="${INSTALL_PATHS[0]}" ;;
esac

INSTALL_DIR="${TARGET}/btcrecover-skill"

if [ -d "$INSTALL_DIR" ]; then
    read -r -p "Folder already exists. Replace it? (y/N): " confirm
    if [[ "$confirm" != [yY]* ]]; then
        echo "Installation cancelled."
        exit 0
    fi
    rm -rf "$INSTALL_DIR"
fi

echo ""
echo "Downloading from official source..."
git clone --quiet "$REPO" "$INSTALL_DIR"

chmod +x "${INSTALL_DIR}/scripts/"*.sh

echo ""
echo "Installation complete."
echo "The skill is now in ${INSTALL_DIR}"
echo ""
echo "Open your AI agent and describe your recovery situation."
echo ""
echo "btcrecover by Stephen Rothery"
echo "This skill by welliv"
