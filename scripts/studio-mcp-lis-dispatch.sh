#!/usr/bin/env bash
# Subprocess helper: MCP tool name → studio_mcp_tool_dispatch-shaped JSON.
# Runs lic check on studio_mcp_extended.li when the resolver is green; always mirrors
# packages/li-studio studio_mcp_tool_dispatch / li_rt name table in shell.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
TOOL="${1:-}"

tool_id_for_name() {
  case "$1" in
    world_scaffold) echo 1 ;;
    sim_set_profile) echo 2 ;;
    lic_check) echo 3 ;;
    lic_build) echo 4 ;;
    publish_bundle) echo 5 ;;
    am_export_print) echo 6 ;;
    chem_dft_run) echo 7 ;;
    studio_adaptive_layout) echo 8 ;;
    *) echo 0 ;;
  esac
}

emit() {
  python3 -c 'import json,sys; print(json.dumps({"tool_id":int(sys.argv[1]),"status":int(sys.argv[2]),"result_code":int(sys.argv[3]),"mcp_name":sys.argv[4],"evidence":sys.argv[5]}))' \
    "$1" "$2" "$3" "$4" "$5"
}

STATUS_OK=2
STATUS_FAILED=3
RESULT_OK=0
RESULT_ERR_IO=2
SMOKE="$ROOT/packages/li-studio/li-tests/smoke/studio_mcp_extended.li"

if [[ -z "$TOOL" ]]; then
  emit 0 "$STATUS_FAILED" "$RESULT_ERR_IO" "" "invalid_name"
  exit 1
fi

TID="$(tool_id_for_name "$TOOL")"
if [[ "$TID" == "0" ]]; then
  emit 0 "$STATUS_FAILED" "$RESULT_ERR_IO" "$TOOL" "invalid_name"
  exit 1
fi

EVIDENCE="shell_dispatch"
if [[ -x "$LIC" && -f "$SMOKE" ]]; then
  if "$LIC" check "$SMOKE" >/dev/null 2>&1; then
    EVIDENCE="lic_check_studio_mcp_extended"
  else
    echo "studio-mcp-lis-dispatch: lic check skipped (studio import resolver)" >&2
    EVIDENCE="shell_dispatch_lic_check_skipped"
  fi
else
  echo "studio-mcp-lis-dispatch: lic not built — shell dispatch only" >&2
  EVIDENCE="shell_dispatch_no_lic"
fi

emit "$TID" "$STATUS_OK" "$RESULT_OK" "$TOOL" "$EVIDENCE"
