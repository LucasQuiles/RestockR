#!/usr/bin/env bash
# Quick test to verify start.sh works

# Run start.sh in background with automatic exit
(echo -e "\n8\n" | timeout 3 ./start.sh 2>&1) | head -100 &
pid=$!

# Wait for it to finish or timeout
wait $pid 2>/dev/null

echo ""
echo "===== Exit code: $? ====="
echo ""
echo "===== Latest log file content: ====="
ls -t .restockr_logs/session_*.log 2>/dev/null | head -1 | xargs tail -30 2>/dev/null || echo "No log found"
