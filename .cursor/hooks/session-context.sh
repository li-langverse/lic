#!/usr/bin/env bash
# Cursor sessionStart — remind agents of mandatory gates (stdout = context for agent).
set -euo pipefail
cat <<'EOF'
Li session: read docs/ecosystem/engineering-standards.md and vision-and-roadmap.md first.
Strict gates: functionality, security, performance. std/** = 100% coverage; lip publish >= 80%.
CVE: test classes relevant to this repo. New features: document "Learned from" (2-4 ecosystems).
EOF
exit 0
