#!/usr/bin/env bash
# Smoke: lipar-dual-mode-csv serial/parallel tagging + num_dot_axpy alias.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

cat >"$WORK/input.csv" <<'CSV'
benchmark,lang,variant,threads,metric,value,stddev,sample_runs,unit,git_sha,cpu_model,flags,os,passed,oracle_kind,verify_abs_err,verify_rel_err,verify_ulps,verify_within_1ulp
matmul_blocked,li,release,1,wall_time,0.001,0.0001,3,s,test,cpu,flags,linux,,,,,,
reduce_sum,li,release,1,wall_time,0.002,0.0002,3,s,test,cpu,flags,linux,,,,,,
simd_dot,li,release,1,wall_time,0.003,0.0003,3,s,test,cpu,flags,linux,,,,,,
matmul_blocked,cpp,release,1,wall_time,0.004,0.0004,3,s,test,cpu,flags,linux,,,,,,
CSV

python3 "$ROOT/scripts/lipar-dual-mode-csv.py" --csv "$WORK/input.csv" --mode serial

# Simulate parallel pass overwriting li rows while keeping cpp.
cat >"$WORK/input.csv" <<'CSV'
benchmark,lang,variant,threads,metric,value,stddev,sample_runs,unit,git_sha,cpu_model,flags,os,passed,oracle_kind,verify_abs_err,verify_rel_err,verify_ulps,verify_within_1ulp
matmul_blocked,li,release,1,wall_time,0.0005,0.00005,3,s,test,cpu,flags,linux,,,,,,
reduce_sum,li,release,1,wall_time,0.001,0.0001,3,s,test,cpu,flags,linux,,,,,,
simd_dot,li,release,1,wall_time,0.0015,0.00015,3,s,test,cpu,flags,linux,,,,,,
matmul_blocked,cpp,release,1,wall_time,0.004,0.0004,3,s,test,cpu,flags,linux,,,,,,
CSV

python3 "$ROOT/scripts/lipar-dual-mode-csv.py" --csv "$WORK/input.csv" --mode parallel --cores 8

python3 - "$WORK/input.csv" <<'PY'
import csv
import sys

path = sys.argv[1]
required = ("matmul_blocked", "reduce_sum", "simd_dot", "num_dot_axpy")
rows = list(csv.DictReader(open(path, newline="", encoding="utf-8")))
by = {(r["benchmark"], r["lang"]) for r in rows if r.get("metric") == "wall_time"}
missing = []
for bid in required:
    for lang in ("li_serial", "li_parallel"):
        if (bid, lang) not in by:
            missing.append(f"{bid}/{lang}")
if missing:
    print("missing dual-mode rows:", ", ".join(missing), file=sys.stderr)
    sys.exit(1)
print("li_parallel_dual_mode_csv: ok")
PY

# WP-PAR-44 — stale num_dot_axpy li_serial must not block li_parallel alias from simd_dot.
cat >"$WORK/stale.csv" <<'CSV'
benchmark,lang,variant,threads,metric,value,stddev,sample_runs,unit,git_sha,cpu_model,flags,os,passed,oracle_kind,verify_abs_err,verify_rel_err,verify_ulps,verify_within_1ulp
num_dot_axpy,li_serial,serial,1,wall_time,0.0026,0.0001,3,s,t,cpu,f,linux,,,,,,
simd_dot,li,release,1,wall_time,0.0391,0.0001,3,s,t,cpu,f,linux,,,,,,
CSV
python3 "$ROOT/scripts/lipar-dual-mode-csv.py" --csv "$WORK/stale.csv" --mode serial
cat >"$WORK/stale.csv" <<'CSV'
benchmark,lang,variant,threads,metric,value,stddev,sample_runs,unit,git_sha,cpu_model,flags,os,passed,oracle_kind,verify_abs_err,verify_rel_err,verify_ulps,verify_within_1ulp
num_dot_axpy,li_serial,serial,1,wall_time,0.0026,0.0001,3,s,t,cpu,f,linux,,,,,,
simd_dot,li,release,1,wall_time,0.0391,0.0001,3,s,t,cpu,f,linux,,,,,,
CSV
python3 "$ROOT/scripts/lipar-dual-mode-csv.py" --csv "$WORK/stale.csv" --mode parallel --cores 8
python3 - "$WORK/stale.csv" <<'PY'
import csv, sys
rows = list(csv.DictReader(open(sys.argv[1], newline="", encoding="utf-8")))
by = {(r["benchmark"], r["lang"]) for r in rows if r.get("metric") == "wall_time"}
if ("num_dot_axpy", "li_parallel") not in by:
    print("stale partial-alias: num_dot_axpy/li_parallel missing", file=sys.stderr)
    sys.exit(1)
print("li_parallel_dual_mode_csv: stale partial-alias ok")
PY

# WP-PAR-48 — whole-catalog scope tags every lang=li row (not only Class A).
cat >"$WORK/catalog.csv" <<'CSV'
benchmark,lang,variant,threads,metric,value,stddev,sample_runs,unit,git_sha,cpu_model,flags,os,passed,oracle_kind,verify_abs_err,verify_rel_err,verify_ulps,verify_within_1ulp
md_lennard_jones,li,release,1,wall_time,0.010,0.0001,3,s,t,cpu,f,linux,,,,,,
md_lennard_jones,cpp,release,1,wall_time,0.012,0.0001,3,s,t,cpu,f,linux,,,,,,
matmul_blocked,li,release,1,wall_time,0.001,0.0001,3,s,t,cpu,f,linux,,,,,,
CSV
python3 "$ROOT/scripts/lipar-dual-mode-csv.py" --csv "$WORK/catalog.csv" --mode serial --scope all
cat >"$WORK/catalog.csv" <<'CSV'
benchmark,lang,variant,threads,metric,value,stddev,sample_runs,unit,git_sha,cpu_model,flags,os,passed,oracle_kind,verify_abs_err,verify_rel_err,verify_ulps,verify_within_1ulp
md_lennard_jones,li,release,1,wall_time,0.008,0.0001,3,s,t,cpu,f,linux,,,,,,
md_lennard_jones,cpp,release,1,wall_time,0.012,0.0001,3,s,t,cpu,f,linux,,,,,,
matmul_blocked,li,release,1,wall_time,0.0005,0.0001,3,s,t,cpu,f,linux,,,,,,
CSV
python3 "$ROOT/scripts/lipar-dual-mode-csv.py" --csv "$WORK/catalog.csv" --mode parallel --scope all --cores 8
python3 - "$WORK/catalog.csv" <<'PY'
import csv, sys
rows = list(csv.DictReader(open(sys.argv[1], newline="", encoding="utf-8")))
by = {(r["benchmark"], r["lang"]) for r in rows if r.get("metric") == "wall_time"}
for bench in ("md_lennard_jones", "matmul_blocked"):
    for lang in ("li_serial", "li_parallel"):
        if (bench, lang) not in by:
            print(f"catalog scope missing {bench}/{lang}", file=sys.stderr)
            sys.exit(1)
if ("md_lennard_jones", "cpp") not in by:
    print("catalog scope dropped cpp row", file=sys.stderr)
    sys.exit(1)
print("li_parallel_dual_mode_csv: catalog scope ok")
PY
