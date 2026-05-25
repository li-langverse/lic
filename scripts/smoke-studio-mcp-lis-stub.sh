#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
STUB="$ROOT/scripts/studio-mcp-lis-stub.sh"
DISPATCH="$ROOT/scripts/studio-mcp-lis-dispatch.sh"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
fail(){ echo "smoke-studio-mcp-lis-stub: $*" >&2; exit 1; }
[[ -x "$STUB" ]] || fail "missing stub"
[[ -x "$DISPATCH" ]] || fail "missing dispatch"
[[ -x "$LIC" ]] || fail "lic not built"
out="$($DISPATCH chem_dft_run)"
echo "$out" | grep -Eq '"tool_id": ?7' || fail "tool_id: $out"
echo "$out" | grep -Eq '"status": ?2' || fail "status: $out"
bad="$($DISPATCH not_a_tool || true)"
echo "$bad" | grep -Eq '"status": ?3' || fail "bad: $bad"
mcp_out="$(printf '%s\n' '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"smoke","version":"0"}}}' '{"jsonrpc":"2.0","method":"notifications/initialized"}' '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"chem_dft_run","arguments":{"input_path":"/tmp/in.xyz"}}}' | "$STUB")"
for n in world_scaffold sim_set_profile lic_check lic_build publish_bundle am_export_print chem_dft_run studio_adaptive_layout; do
  echo "$mcp_out" | grep -q "$n" || fail "missing $n"
done
echo "$mcp_out" | grep -q 'chem_dft_run' || fail "mcp call missing tool name"
echo "$mcp_out" | grep -q 'tool_id' || fail "mcp dispatch tool_id"
echo "$mcp_out" | grep -q 'status' || fail "mcp dispatch status"
echo "smoke-studio-mcp-lis-stub: ok"
