#!/bin/bash
# btcrecover-skill session manager
# Background session + cron wrapper for long recovery jobs

set -euo pipefail

SESSION_DIR="$HOME/.btcrecover-skill/sessions"
LOG_FILE="$SESSION_DIR/session.log"
PID_FILE="$SESSION_DIR/session.pid"
START_TIME=""

mkdir -p "$SESSION_DIR"

start_session() {
    START_TIME=$(date +%s)
    echo "$$" > "$PID_FILE"
    echo "[$(date)] Session started (PID: $$)" >> "$LOG_FILE"
}

stop_session() {
    if [[ -f "$PID_FILE" ]]; then
        kill "$(cat "$PID_FILE")" 2>/dev/null || true
        rm -f "$PID_FILE"
    fi
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    echo "[$(date)] Session ended (Duration: ${DURATION}s)" >> "$LOG_FILE"
}

status_session() {
    if [[ -f "$PID_FILE" && -d "/proc/$(cat "$PID_FILE")" ]]; then
        echo "Session is running (PID: $(cat "$PID_FILE"))"
    else
        echo "No active session"
    fi
}

case "${1:-}" in
    start)
        start_session
        ;;
    stop)
        stop_session
        ;;
    status)
        status_session
        ;;
    *)
        echo "Usage: $0 {start|stop|status}"
        exit 1
        ;;
esac