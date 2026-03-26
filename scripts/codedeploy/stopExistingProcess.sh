#!/bin/bash

# Print script base path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "=== Script Base Path ==="
echo "$SCRIPT_DIR"
echo ""

# Print all environment variables
echo "=== Environment Variables ==="
printenv
echo ""

echo "starting STOP script - 2"
pwd
ls -ltr
sudo pkill -f "oltp-0.0.1-SNAPSHOT.jar"
sleep 5

# Force kill if still running
if pgrep -f "oltp-0.0.1-SNAPSHOT.jar" > /dev/null; then
    echo "Process still running, forcing shutdown..."
    pkill -9 -f "oltp-0.0.1-SNAPSHOT.jar"
fi

echo "Application stopped"
