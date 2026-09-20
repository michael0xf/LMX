#!/bin/bash
# run_mixa_milestone.sh — verifies the mixa application milestone:
#   go.sh just-build → launch → wait → close → check exit code.
# Usage: ./run_mixa_milestone.sh [timeout_sec]
# Exit: 0 = BUILD_OK + RUN_OK + CLOSED, 1 = failure at any stage.
set -eu
SANDBOX="/c/Nyasha_Planet/L1/dev/mixa_sandbox"
EXE="/tmp/mixa_app.exe"
TIMEOUT="${1:-8}"

cd "$SANDBOX"

echo "=== 1. build ==="
bash go.sh just-build 2>&1 | tail -5
if [ ! -f "$EXE" ]; then
    echo "FAIL: $EXE not produced"
    exit 1
fi
echo "BUILD OK: $EXE"

echo "=== 2. launch ==="
"$EXE" "." &
APP_PID=$!
echo "launched PID=$APP_PID, waiting ${TIMEOUT}s..."

# Wait for the app to initialize (or timeout).
sleep "$TIMEOUT"

echo "=== 3. close ==="
# Try graceful close first (WM_CLOSE), then SIGTERM if still alive.
if kill -0 "$APP_PID" 2>/dev/null; then
    kill "$APP_PID" 2>/dev/null || true
    sleep 2
    if kill -0 "$APP_PID" 2>/dev/null; then
        kill -9 "$APP_PID" 2>/dev/null || true
        echo "WARN: had to SIGKILL"
    fi
fi

wait "$APP_PID" 2>/dev/null
EXIT_CODE=$?
echo "=== 4. result ==="
echo "exit=$EXIT_CODE"
if [ "$EXIT_CODE" -eq 0 ]; then
    echo "RUN OK: app ran and exited cleanly"
    exit 0
else
    echo "FAIL: exit code $EXIT_CODE"
    exit 1
fi
