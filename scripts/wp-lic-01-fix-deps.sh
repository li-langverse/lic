#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

git show 0e32a8af:packages/lig/src/lib.li > packages/lig/src/lib.li
python3 <<'PY'
from pathlib import Path
p = Path('packages/lig/src/lib.li')
text = p.read_text()
needle = """extern proc li_rt_lig_host_native_pixels() -> int
  requires true
  ensures result >= 0
  ensures result <= 1
  decreases 0

def li_std_lig_version()"""
insert = """extern proc li_rt_lig_host_native_pixels() -> int
  requires true
  ensures result >= 0
  ensures result <= 1
  decreases 0

extern proc li_rt_lig_cpu_present_active() -> int
  requires true
  ensures result >= 0
  ensures result <= 1
  decreases 0

extern proc li_rt_lig_wgpu_present_intent_active() -> int
  requires true
  ensures result >= 0
  ensures result <= 1
  decreases 0

def li_std_lig_version()"""
text = text.replace(needle, insert)
old = """  if li_rt_lig_host_present_active() != 1:
    out.native_pixels = 0
  return out

def lig_present_host_active()"""
new = """  if li_rt_lig_host_present_active() != 1:
    out.native_pixels = 0
    if li_rt_lig_cpu_present_active() == 1:
      out.native_pixels = li_rt_lig_host_native_pixels()
  return out

def lig_present_host_active()"""
text = text.replace(old, new)
text = text.rstrip() + """

def lig_present_cpu_framebuffer_active() -> int raises IO
  requires true
  ensures result >= 0
  ensures result <= 1
  decreases 0
=
  return li_rt_lig_cpu_present_active()

def lig_present_wgpu_intent_active() -> int raises IO
  requires true
  ensures result >= 0
  ensures result <= 1
  decreases 0
=
  return li_rt_lig_wgpu_present_intent_active()

type LigMemoryLedger = object
  public budget_mib: int
  public allocated_bytes: int
  public peak_bytes: int

def lig_memory_budget_mib() -> int
  requires true
  ensures result == 512
  decreases 0
=
  return 512

def lig_alloc_within_budget(ledger: var LigMemoryLedger, bytes: int) -> int
  requires bytes >= 0
  ensures result >= 0
  ensures result <= 1
  decreases bytes
=
  if bytes == 0:
    return 1
  var cap: int = ledger.budget_mib * 1048576
  if ledger.allocated_bytes + bytes > cap:
    return 0
  ledger.allocated_bytes = ledger.allocated_bytes + bytes
  if ledger.allocated_bytes > ledger.peak_bytes:
    ledger.peak_bytes = ledger.allocated_bytes
  return 1
"""
p.write_text(text + '\n')
PY

git show 56047f22:packages/li-scene/src/lib.li > packages/li-scene/src/lib.li 2>/dev/null || git show HEAD:packages/li-scene/src/lib.li > packages/li-scene/src/lib.li
python3 <<'PY'
from pathlib import Path
p = Path('packages/li-scene/src/lib.li')
text = p.read_text()
if text.startswith('type LigMemoryLedger'):
    idx = text.find('\ntype EntityId')
    if idx != -1:
        text = text[idx + 1 :]
if not text.startswith('import lig'):
    text = 'import lig\n\n' + text.lstrip()
p.write_text(text)
PY

sed -i '/^import ml\.rl$/d' packages/li-studio/src/lib.li
sed -i '/^import lig\.present$/d; /^import lig\.memory$/d' packages/li-studio/src/lib.li
