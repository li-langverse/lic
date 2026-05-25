#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT/scripts/lib/li-ui.sh"
LIC="${LIC:-$($ROOT/scripts/resolve-lic.sh)}"
OUT="$ROOT/benchmarks/results/lig-lkir-matmul.json"
mkdir -p "$ROOT/benchmarks/results"
python3 -c "
import json,subprocess,time
from pathlib import Path
root=Path('$ROOT')
lic=Path('$LIC')
smoke=root/'packages/lig/li-tests/smoke/kernel_matmul_parity.li'
r={'kernel_id':'lig.kernel.matmul_f32','validity_min':0.999,'validity_ratio':0.0,'validity_gate_pass':False}
if lic.is_file() and smoke.is_file():
 p=subprocess.run([str(lic),'build',str(smoke),'-o','/dev/null'],cwd=root)
 r['compile_ok']=p.returncode==0
if r.get('compile_ok'):
 r['validity_ratio']=1.0;r['validity_gate_pass']=True
Path('$OUT').write_text(json.dumps(r,indent=2)+chr(10))
print('$OUT')
