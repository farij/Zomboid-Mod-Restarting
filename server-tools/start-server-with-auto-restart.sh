#!/usr/bin/env bash
# =============================================================================
# UdderlyUpToDate Build 42 - Linux/macOS auto-restart wrapper
# =============================================================================
# The mod can only QUIT the Project Zomboid process. It cannot start it again.
# Run this script instead of your normal start script so the server comes back
# up after UdderlyUpToDate (or a crash) exits the process.
#
# 1. Copy this file next to your dedicated server start script
# 2. Edit SERVER_SCRIPT / RESTART_DELAY_SECONDS below as needed
# 3. chmod +x start-server-with-auto-restart.sh
# 4. Start the server with THIS file
#
# Note: Linux start scripts usually exit when the server quits. If yours waits
# for a keypress at the end, remove that read/pause or the loop will hang.
# =============================================================================

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_SCRIPT="${SERVER_SCRIPT:-start-server.sh}"
RESTART_DELAY_SECONDS="${RESTART_DELAY_SECONDS:-10}"

if [[ ! -f "${SCRIPT_DIR}/${SERVER_SCRIPT}" ]]; then
	echo "ERROR: Could not find ${SCRIPT_DIR}/${SERVER_SCRIPT}"
	echo "Place this script in the same folder as your dedicated server start script,"
	echo "or set SERVER_SCRIPT to the correct filename."
	exit 1
fi

if [[ ! -x "${SCRIPT_DIR}/${SERVER_SCRIPT}" ]]; then
	chmod +x "${SCRIPT_DIR}/${SERVER_SCRIPT}" || true
fi

while true; do
	echo
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting Project Zomboid server via ${SERVER_SCRIPT} ..."
	"${SCRIPT_DIR}/${SERVER_SCRIPT}"
	exit_code=$?
	echo
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] Server process exited with code ${exit_code}."
	echo "Restarting in ${RESTART_DELAY_SECONDS} seconds... (Ctrl+C to stop)"
	sleep "${RESTART_DELAY_SECONDS}"
done
