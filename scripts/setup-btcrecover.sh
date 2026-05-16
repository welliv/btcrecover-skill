#!/usr/bin/env bash
# btcrecover-skill: setup-btcrecover.sh
set -euo pipefail
BTC_RECOVER_DIR="${HOME}/btcrecover"
MARKER_DIR="${HOME}/.btcrecover-skill"
MARKER_FILE="${MARKER_DIR}/.btcrecover-verified"
mkdir -p "${MARKER_DIR}"

MISSING_PREREQS=()
command -v python3 &>/dev/null || MISSING_PREREQS+=("python3")
command -v git &>/dev/null || MISSING_PREREQS+=("git")
command -v pip3 &>/dev/null || MISSING_PREREQS+=("pip3")
if [ ${#MISSING_PREREQS[@]} -gt 0 ]; then
  echo "Missing prerequisites: ${MISSING_PREREQS[*]}"
  echo "Install: sudo apt install python3 python3-pip python3-venv git  (or equivalent)"
  exit 2
fi

echo "Cloning btcrecover from official repository..."
if [ -d "${BTC_RECOVER_DIR}" ]; then
  echo "btcrecover directory already exists — checking for update..."
  cd "${BTC_RECOVER_DIR}"
  git pull 2>&1 || echo "Could not update (will use existing clone)"
else
  git clone https://github.com/3rdIteration/btcrecover.git "${BTC_RECOVER_DIR}" 2>&1 || { echo "Failed to clone."; exit 1; }
fi

echo "Creating Python virtual environment..."
cd "${BTC_RECOVER_DIR}"
python3 -m venv venv 2>&1 || { echo "Failed to create venv. Try: sudo apt install python3-venv"; exit 1; }
# Ensure python symlink exists (some systems only create python3)
[ -L "${BTC_RECOVER_DIR}/venv/bin/python" ] || ln -sf python3 "${BTC_RECOVER_DIR}/venv/bin/python"

echo "Installing Python dependencies into venv..."
# Use explicit venv pip path to avoid externally-managed-environment issues
"${BTC_RECOVER_DIR}/venv/bin/pip" install -r requirements.txt --quiet 2>&1 || {
  echo "Requirements install failed. Installing core packages individually..."
  "${BTC_RECOVER_DIR}/venv/bin/pip" install pycryptodome coincurve --quiet 2>&1 || {
    echo "Failed to install core dependencies. Check network connectivity or package availability."
    exit 1
  }
}

# Create convenience wrappers (use python3 — venv may not create a 'python' symlink)
# Note: use -cli suffix because ~/btcrecover/btcrecover conflicts with the
# btcrecover/ subdirectory inside the cloned repo.
cat > "${BTC_RECOVER_DIR}/btcrecover-cli" <<'WRAPPER'
#!/usr/bin/env bash
DIR="$(cd "$(dirname "$0")" && pwd)"
exec "$DIR/venv/bin/python3" "$DIR/btcrecover.py" "$@"
WRAPPER
chmod +x "${BTC_RECOVER_DIR}/btcrecover-cli"
# Legacy alias for scripts that reference the old path
ln -sf btcrecover-cli "${BTC_RECOVER_DIR}/btcrecover" 2>/dev/null || true

cat > "${BTC_RECOVER_DIR}/seedrecover-cli" <<'WRAPPER'
#!/usr/bin/env bash
DIR="$(cd "$(dirname "$0")" && pwd)"
exec "$DIR/venv/bin/python3" "$DIR/seedrecover.py" "$@"
WRAPPER
chmod +x "${BTC_RECOVER_DIR}/seedrecover-cli"
ln -sf seedrecover-cli "${BTC_RECOVER_DIR}/seedrecover" 2>/dev/null || true

# Verify both tools load (using venv python3 explicitly)
echo "Verifying installation..."
"${BTC_RECOVER_DIR}/venv/bin/python3" btcrecover.py --help &>/dev/null || { echo "btcrecover.py failed to load after install"; exit 1; }
"${BTC_RECOVER_DIR}/venv/bin/python3" seedrecover.py --help &>/dev/null || { echo "seedrecover.py failed to load after install"; exit 1; }

date -u +'%Y-%m-%dT%H:%M:%SZ' > "${MARKER_FILE}"
(cd "${BTC_RECOVER_DIR}" && git rev-parse HEAD) >> "${MARKER_FILE}" 2>/dev/null || true

echo ""
echo "✅ btcrecover is set up and ready."
echo "  ~/btcrecover/btcrecover-cli --help"
echo "  ~/btcrecover/seedrecover-cli --help"
echo ""
echo "💡 Always use the wrappers (or activate the venv):"
echo "  source ~/btcrecover/venv/bin/activate"
echo ""
echo "   Note: ~/btcrecover/btcrecover is a directory (part of the repo)."
echo "   Use btcrecover-cli/seedrecover-cli for the CLI wrappers."
exit 0
