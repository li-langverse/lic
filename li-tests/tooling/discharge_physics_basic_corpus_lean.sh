#!/usr/bin/env bash
# Physics basic-corpus specimens (EM/EX/TH/WV tranches) → zero open Prop goals.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
chmod +x "$ROOT/scripts/check-autovc-open-goals.sh"
for sample in \
  "$ROOT/proof-db/physics/basic-corpus/p_lm_bc_em_015.li" \
  "$ROOT/proof-db/physics/basic-corpus/p_lm_bc_em_016.li" \
  "$ROOT/proof-db/physics/basic-corpus/p_lm_bc_em_017.li" \
  "$ROOT/proof-db/physics/basic-corpus/p_lm_bc_em_018.li" \
  "$ROOT/proof-db/physics/basic-corpus/p_lm_bc_em_020.li" \
  "$ROOT/proof-db/physics/basic-corpus/p_lm_bc_ex_041.li" \
  "$ROOT/proof-db/physics/basic-corpus/p_lm_bc_ex_042.li" \
  "$ROOT/proof-db/physics/basic-corpus/p_lm_bc_ex_043.li" \
  "$ROOT/proof-db/physics/basic-corpus/p_lm_bc_ex_044.li" \
  "$ROOT/proof-db/physics/basic-corpus/p_lm_bc_ex_045.li" \
  "$ROOT/proof-db/physics/basic-corpus/p_lm_bc_ex_046.li" \
  "$ROOT/proof-db/physics/basic-corpus/p_lm_bc_ex_047.li" \
  "$ROOT/proof-db/physics/basic-corpus/p_lm_bc_ex_048.li" \
  "$ROOT/proof-db/physics/basic-corpus/p_lm_bc_ex_049.li" \
  "$ROOT/proof-db/physics/basic-corpus/p_lm_bc_ex_050.li" \
  "$ROOT/proof-db/physics/basic-corpus/p_lm_bc_th_025.li" \
  "$ROOT/proof-db/physics/basic-corpus/p_lm_bc_th_026.li" \
  "$ROOT/proof-db/physics/basic-corpus/p_lm_bc_th_027.li" \
  "$ROOT/proof-db/physics/basic-corpus/p_lm_bc_th_028.li" \
  "$ROOT/proof-db/physics/basic-corpus/p_lm_bc_th_029.li" \
  "$ROOT/proof-db/physics/basic-corpus/p_lm_bc_wv_031.li" \
  "$ROOT/proof-db/physics/basic-corpus/p_lm_bc_wv_032.li" \
  "$ROOT/proof-db/physics/basic-corpus/p_lm_bc_wv_033.li" \
  "$ROOT/proof-db/physics/basic-corpus/p_lm_bc_wv_034.li" \
  "$ROOT/proof-db/physics/basic-corpus/p_lm_bc_wv_035.li" \
  "$ROOT/proof-db/physics/basic-corpus/p_lm_bc_wv_036.li" \
  "$ROOT/proof-db/physics/basic-corpus/p_lm_bc_wv_037.li" \
  "$ROOT/proof-db/physics/basic-corpus/p_lm_bc_wv_038.li" \
  "$ROOT/proof-db/physics/basic-corpus/p_lm_bc_wv_039.li" \
  "$ROOT/proof-db/physics/basic-corpus/p_lm_bc_wv_040.li"; do
  AUTOVC="$ROOT/build/generated/AutoVC.lean"
  rm -f "$AUTOVC"
  "$LIC" build "$sample" -o /dev/null
  test -f "$AUTOVC"
  "$ROOT/scripts/check-autovc-open-goals.sh" "$AUTOVC"
done
if command -v lake >/dev/null 2>&1; then
  (cd "$ROOT/docs/semantics" && lake build)
  echo "discharge_physics_basic_corpus_lean: lake ok"
else
  echo "discharge_physics_basic_corpus_lean: skipped lake (not installed)"
fi
echo "discharge_physics_basic_corpus_lean: ok"
