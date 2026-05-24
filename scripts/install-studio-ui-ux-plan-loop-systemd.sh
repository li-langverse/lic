#!/usr/bin/env bash
# Install user systemd unit for Studio UI/UX plan loop (continuous + linger).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
UNIT_NAME="li-studio-ui-ux-plan-loop"
SERVICE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
mkdir -p "$SERVICE_DIR"

cat >"$SERVICE_DIR/${UNIT_NAME}.service" <<EOF
[Unit]
Description=Li Studio UI/UX plan loop (studio_ui_ux_builder)
After=network-online.target

[Service]
Type=simple
WorkingDirectory=$ROOT
Environment=LI_CURSOR_AGENTS_ROOT=$ROOT/../li-cursor-agents
EnvironmentFile=-$HOME/Documents/Cursor/.env
ExecStart=$ROOT/scripts/studio-ui-ux-plan-continuous.sh
Restart=on-failure
RestartSec=60

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable "${UNIT_NAME}.service"
echo "Enabled ${UNIT_NAME}.service — start: systemctl --user start ${UNIT_NAME}"
echo "Optional: loginctl enable-linger \$USER  # survive reboot"
