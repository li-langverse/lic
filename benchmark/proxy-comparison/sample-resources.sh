#!/usr/bin/env bash
# Sample container memory (docker stats) and CPU% during parallel burst.
set -euo pipefail
SERVICE="${1:?service name}"
DURATION="${2:-15}"
INTERVAL="${3:-0.2}"
ROOT="$(cd "$(dirname "$0")" && pwd)"
CID=$(docker compose -f "$ROOT/docker-compose.yml" ps -q "$SERVICE" 2>/dev/null | head -1)
[ -n "$CID" ] || { echo '{"rss_kb_max":0,"rss_mb_max":0,"cpu_pct_max":0,"samples":0}'; exit 0; }
python3 - "$CID" "$DURATION" "$INTERVAL" <<'PY'
import json, re, subprocess, sys, time

def parse_mem_mib(raw: str) -> float:
    # "12.34MiB / 15GiB" or "1.234GiB / ..."
    part = raw.split("/")[0].strip()
    m = re.match(r"([\d.]+)\s*([KMG]i?B)", part, re.I)
    if not m:
        return 0.0
    val, unit = float(m.group(1)), m.group(2).upper()
    if unit.startswith("G"):
        return val * 1024 * 1024
    if unit.startswith("M"):
        return val * 1024
    if unit.startswith("K"):
        return val
    return 0.0

cid, duration, interval = sys.argv[1], float(sys.argv[2]), float(sys.argv[3])
rss_kb_max = 0
cpu_max = 0.0
samples = 0
deadline = time.time() + duration
while time.time() < deadline:
    try:
        mem = subprocess.check_output(
            ["docker", "stats", "--no-stream", "--format", "{{.MemUsage}}", cid],
            text=True,
        ).strip()
        mib = parse_mem_mib(mem)
        rss_kb_max = max(rss_kb_max, int(mib))
        cpu = subprocess.check_output(
            ["docker", "stats", "--no-stream", "--format", "{{.CPUPerc}}", cid],
            text=True,
        ).strip().rstrip("%") or "0"
        cpu_max = max(cpu_max, float(cpu))
        samples += 1
    except Exception:
        pass
    time.sleep(interval)
print(json.dumps({
    "rss_kb_max": rss_kb_max,
    "rss_mb_max": round(rss_kb_max / 1024, 2),
    "cpu_pct_max": round(cpu_max, 2),
    "samples": samples,
}))
PY
