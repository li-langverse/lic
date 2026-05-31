import json, os, sys, time

out = os.environ["PH_ML_NUMPY_OUT"]
report = {
    "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    "suite": "ph-ml-competitor-numpy-matmul",
    "competitor_id": "python_numpy",
    "numpy_version": None,
    "executed": False,
    "cpu_sec": None,
    "validity_gate_pass": False,
    "workload": "matmul_4x4_pilot",
}

def write_report():
    with open(out, "w", encoding="utf-8") as f:
        f.write(json.dumps(report, indent=2) + "\n")
    print(out)

try:
    import numpy as np
except ImportError:
    report["note"] = "numpy not installed"
    write_report()
    sys.exit(0)

report["numpy_version"] = np.__version__
A = np.eye(4, dtype=np.float32)
B = np.eye(4, dtype=np.float32)
for _ in range(3):
    C = A @ B
if float(C[0, 0]) < 0.5:
    report["note"] = "numpy matmul sanity failed"
    write_report()
    sys.exit(0)

runs = 50
t0 = time.perf_counter()
for _ in range(runs):
    C = A @ B
    if float(C[0, 0]) < 0.5:
        report["note"] = "numpy matmul mid-run sanity failed"
        write_report()
        sys.exit(0)

report["cpu_sec"] = round((time.perf_counter() - t0) / runs, 6)
report["executed"] = True
report["validity_gate_pass"] = True
report["validity_ratio"] = 1.0
write_report()
