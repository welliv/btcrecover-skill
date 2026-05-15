#!/bin/bash
# btcrecover-skill session manager
# Wraps btcrecover in a managed screen/tmux session for long-running recovery jobs
# Auto-adds --savefile for checkpoint support
# Subcommands: start, status, resume, stop, report, cron

set -euo pipefail

SESSION_DIR="$HOME/.btcrecover-skill"
CHECKPOINT_DIR="$SESSION_DIR/checkpoints"
LOG_FILE="$SESSION_DIR/session.log"
SESSION_NAME="btcrecover-recovery"
COMMAND=""

mkdir -p "$SESSION_DIR" "$CHECKPOINT_DIR"

usage() {
    echo "Usage: $0 {start|status|resume|stop|report|cron} [options]"
    echo
    echo "Subcommands:"
    echo "  start                Start a new btcrecover session (interactive)"
    echo "  status               Check if session is running"
    echo "  resume               Resume a checkpointed session"
    echo "  stop                 Stop the running session"
    echo "  report               Generate a plain-English progress report"
    echo "  cron                 Install hourly progress report cron job"
    echo
    echo "Options:"
    echo "  --command \"...\"       btcrecover command to run (for 'start')"
    echo "  --savefile FILE       Checkpoint file path"
    echo "  --no-screen           Run in background (nohup), not screen"
    exit 1
}

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

find_terminal_multiplexer() {
    if command -v screen >/dev/null 2>&1; then
        echo "screen"
    elif command -v tmux >/dev/null 2>&1; then
        echo "tmux"
    else
        echo "none"
    fi
}

# Parse arguments
SAVEFILE=""
NO_SCREEN=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        start|status|resume|stop|report|cron)
            SUBCOMMAND="$1"
            shift
            ;;
        --command)
            COMMAND="$2"
            shift 2
            ;;
        --savefile)
            SAVEFILE="$2"
            shift 2
            ;;
        --no-screen)
            NO_SCREEN=true
            shift
            ;;
        *)
            usage
            ;;
    esac
done

if [[ -z "${SUBCOMMAND:-}" ]]; then
    usage
fi

case "$SUBCOMMAND" in
    start)
        if [[ -z "$COMMAND" ]]; then
            echo "Error: --command is required for 'start'"
            echo "Example: $0 start --command \"python btcrecover.py --wallet wallet.extract --tokenlist tokenlist.txt\""
            exit 1
        fi

        # Auto-add --savefile if not present
        if [[ -z "$SAVEFILE" ]]; then
            SAVEFILE="$CHECKPOINT_DIR/checkpoint-$(date +%s).savestate"
        fi
        if [[ "$COMMAND" != *"--savefile"* ]]; then
            COMMAND="$COMMAND --savefile $SAVEFILE"
        fi

        MULTIPLEXER=$(find_terminal_multiplexer)

        if [[ "$MULTIPLEXER" == "screen" && "$NO_SCREEN" == false ]]; then
            echo "Starting btcrecover in screen session: $SESSION_NAME"
            screen -dmS "$SESSION_NAME" bash -c "$COMMAND; echo '--- btcrecover completed with exit code \$? ---'"
            log "Started in screen session '$SESSION_NAME': $COMMAND"
            echo "Session started. Use '$0 status' to check, '$0 stop' to stop."
            echo "To attach: screen -r $SESSION_NAME"
        elif [[ "$MULTIPLEXER" == "tmux" && "$NO_SCREEN" == false ]]; then
            echo "Starting btcrecover in tmux session: $SESSION_NAME"
            tmux new-session -d -s "$SESSION_NAME" "$COMMAND"
            log "Started in tmux session '$SESSION_NAME': $COMMAND"
            echo "Session started. Use '$0 status' to check, '$0 stop' to stop."
            echo "To attach: tmux attach -t $SESSION_NAME"
        else
            echo "Starting btcrecover in background (nohup)..."
            SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
            nohup bash -c "$COMMAND" > "$SESSION_DIR/nohup.out" 2>&1 &
            echo $! > "$SESSION_DIR/background.pid"
            log "Started in background (PID $!): $COMMAND"
            echo "Session started (PID $!). Use '$0 status' to check."
        fi
        ;;

    status)
        MULTIPLEXER=$(find_terminal_multiplexer)
        if [[ "$MULTIPLEXER" == "screen" ]]; then
            if screen -list | grep -q "$SESSION_NAME"; then
                echo "Session is RUNNING (screen: $SESSION_NAME)"
                log "Status check: running"
            else
                echo "Session is STOPPED"
                log "Status check: stopped"
            fi
        elif [[ "$MULTIPLEXER" == "tmux" ]]; then
            if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
                echo "Session is RUNNING (tmux: $SESSION_NAME)"
                log "Status check: running"
            else
                echo "Session is STOPPED"
                log "Status check: stopped"
            fi
        else
            if [[ -f "$SESSION_DIR/background.pid" ]]; then
                PID=$(cat "$SESSION_DIR/background.pid")
                if kill -0 "$PID" 2>/dev/null; then
                    echo "Session is RUNNING (PID: $PID)"
                    log "Status check: running (PID $PID)"
                else
                    echo "Session is STOPPED (PID $PID no longer running)"
                    log "Status check: stopped"
                fi
            else
                echo "No session found"
            fi
        fi
        ;;

    resume)
        MULTIPLEXER=$(find_terminal_multiplexer)
        if [[ "$MULTIPLEXER" == "screen" ]]; then
            if screen -list | grep -q "$SESSION_NAME"; then
                echo "Session already running. Attaching..."
                screen -r "$SESSION_NAME"
            else
                echo "No running session to resume."
                echo "If you have a checkpoint file, use 'start' with the saved command."
            fi
        elif [[ "$MULTIPLEXER" == "tmux" ]]; then
            if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
                echo "Session already running. Attaching..."
                tmux attach -t "$SESSION_NAME"
            else
                echo "No running session to resume."
            fi
        else
            echo "No multiplexer available. Use 'start' to restart."
        fi
        ;;

    stop)
        MULTIPLEXER=$(find_terminal_multiplexer)
        if [[ "$MULTIPLEXER" == "screen" ]]; then
            if screen -list | grep -q "$SESSION_NAME"; then
                echo "Stopping screen session: $SESSION_NAME"
                screen -S "$SESSION_NAME" -X quit
                log "Stopped screen session '$SESSION_NAME'"
                echo "Session stopped."
            else
                echo "No running session found."
            fi
        elif [[ "$MULTIPLEXER" == "tmux" ]]; then
            if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
                echo "Stopping tmux session: $SESSION_NAME"
                tmux kill-session -t "$SESSION_NAME"
                log "Stopped tmux session '$SESSION_NAME'"
                echo "Session stopped."
            else
                echo "No running session found."
            fi
        else
            if [[ -f "$SESSION_DIR/background.pid" ]]; then
                PID=$(cat "$SESSION_DIR/background.pid")
                echo "Stopping background process (PID $PID)..."
                kill "$PID" 2>/dev/null || true
                rm -f "$SESSION_DIR/background.pid"
                log "Stopped background process (PID $PID)"
                echo "Session stopped."
            else
                echo "No running session found."
            fi
        fi
        ;;

    report)
        # Read the log file for recent progress
        if [[ -f "$LOG_FILE" ]]; then
            echo "=== btcrecover-skill: Progress Report ==="
            echo
            echo "Session log (last 10 entries):"
            tail -10 "$LOG_FILE"
            echo
            echo "Checkpoints:"
            ls -lh "$CHECKPOINT_DIR" 2>/dev/null || echo "  No checkpoints found."
        else
            echo "No session log found."
        fi
        ;;

    cron)
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        CRON_CMD="$SCRIPT_DIR/session-manager.sh report"
        CRON_COMMENT="# btcrecover-skill hourly progress report"
        
        # Check if the cron job already exists
        if crontab -l 2>/dev/null | grep -q "btcrecover-skill"; then
            echo "Cron job already exists. Updating..."
            (crontab -l 2>/dev/null | grep -v "btcrecover-skill"; echo "0 * * * * $CRON_CMD $CRON_COMMENT") | crontab -
        else
            echo "Installing hourly cron job..."
            (crontab -l 2>/dev/null; echo "0 * * * * $CRON_CMD $CRON_COMMENT") | crontab -
        fi
        log "Installed hourly cron job for progress reports"
        echo "Cron job installed. Progress reports will run hourly."
        echo "Use 'crontab -e' to modify or remove."
        ;;
esac