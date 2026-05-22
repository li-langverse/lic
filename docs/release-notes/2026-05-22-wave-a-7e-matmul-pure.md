# Wave A 7e — pure-Li matmul verify + perf honesty

## Summary

Tier-1 `matmul_naive` (256×256 IKJ) and `matmul_blocked` (512×512, BK=64 tiles) Li drivers match `reference.py` / C `*_core.c` init and checksums. Harness `verify-results` compares Li vs native via `LI_PRINT_SINK_F64`.

## Changed

| Path | What |
|------|------|
| `benchmarks/tier1_micro/matmul_naive/li/main.li` | Full 256³ pure-Li IKJ + LUT init |
| `benchmarks/tier1_micro/matmul_blocked/li/main.li` | Full 512³ blocked IKJ + LUT init |
| `benchmarks/harness/reference.py` | Normative tier-1 specs |
| `benchmarks/harness/bench.py` | `verify-results`, Li/native parity |
| `runtime/li_rt.c` | `LI_PRINT_SINK_F64` on volatile sink |
| `benchmarks/results/latest.csv` | Refreshed tier-1 timings |

## Verify

```bash
./scripts/bench-verify-results.sh 1
./scripts/verify-math-physics-goldens.sh
./scripts/compiler-studio-plan-gates.sh
```

## Performance (advisory)

- `matmul_naive`: Li ≈ C++ (1.0×)
- `matmul_blocked`: Li ~2.0× C++ (honest pure-Li loops; not parity-gated)
