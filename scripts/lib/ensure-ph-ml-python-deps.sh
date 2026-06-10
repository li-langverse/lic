#!/usr/bin/env bash
# Skip pip when benchmark-oracle image marker exists or core imports already work.
# Marker: /opt/ph-ml-venv/.installed (li-cursor-agents deploy/Dockerfile.benchmark-oracle)
ensure_ph_ml_python_deps() {
  local root="${1:-.}"
  shift || true
  local req_files=("$@")
  if [[ ${#req_files[@]} -eq 0 ]]; then
    req_files=(
      "$root/scripts/requirements-ph-ml-competitive.txt"
      "$root/scripts/requirements-ph-ml-wave12-rl.txt"
    )
  fi

  if [[ -f /opt/ph-ml-venv/.installed ]] \
    && python3 -c "import numpy, torch, jax" 2>/dev/null; then
    return 0
  fi
  if python3 -c "import numpy, torch, jax" 2>/dev/null; then
    return 0
  fi

  local args=()
  local f
  for f in "${req_files[@]}"; do
    [[ -f "$f" ]] && args+=(-r "$f")
  done
  [[ ${#args[@]} -gt 0 ]] || return 0
  python3 -m pip install --user --break-system-packages "${args[@]}" >/dev/null 2>&1 || true
}
