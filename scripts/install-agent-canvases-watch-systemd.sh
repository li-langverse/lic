#!/usr/bin/env bash
# User systemd unit: refresh all agent canvases every AGENT_CANVASES_INTERVAL_SEC (default 15).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
UNIT_NAME="li-agent-canvases-watch.service"
INTERVAL="${AGENT_CANVASES_INTERVAL_SEC:-15}"
USER_UNIT_DIR="${HOME}/.config/systemd/user"
mkdir -p "$USER_UNIT_DIR"

cat >"${USER_UNIT_DIR}/${UNIT_NAME}" <<EOF
[Unit]
Description=Live refresh for goal-directed agent canvases (goal, sim, studio)
After=network.target

[Service]
Type=simple
WorkingDirectory=${ROOT}
Environment=LI_LANGVERSE_ROOT=${ROOT}/..
Environment=AGENT_CANVASES_INTERVAL_SEC=${INTERVAL}
ExecStart=${ROOT}/scripts/agent-canvases-watch.sh
Restart=always
RestartSec=5

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now "${UNIT_NAME}"
echo "Installed and started ${UNIT_NAME} (interval=${INTERVAL}s)"
systemctl --user status "${UNIT_NAME}" --no-pager || true
