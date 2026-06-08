#!/usr/bin/env bash
# Discrete basic-corpus specimens (CMB/IND/NT/REC tranches) → zero open Prop goals.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
chmod +x "$ROOT/scripts/check-autovc-open-goals.sh"
for sample in \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_cmb_002.li" \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_cmb_007.li" \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_cmb_012.li" \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_cmb_017.li" \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_cmb_022.li" \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_cmb_027.li" \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_cmb_032.li" \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_cmb_037.li" \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_cmb_042.li" \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_cmb_047.li" \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_ind_001.li" \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_ind_006.li" \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_ind_011.li" \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_ind_016.li" \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_ind_021.li" \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_ind_026.li" \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_ind_031.li" \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_ind_036.li" \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_ind_041.li" \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_ind_046.li" \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_nt_003.li" \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_nt_008.li" \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_nt_013.li" \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_nt_018.li" \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_nt_023.li" \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_nt_028.li" \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_nt_033.li" \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_nt_038.li" \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_nt_043.li" \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_nt_048.li" \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_rec_004.li" \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_rec_009.li" \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_rec_014.li" \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_rec_019.li" \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_rec_024.li" \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_rec_029.li" \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_rec_034.li" \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_rec_039.li" \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_rec_044.li" \
  "$ROOT/proof-db/discrete/basic-corpus/d_lm_bc_rec_049.li";
do
  AUTOVC="$ROOT/build/generated/AutoVC.lean"
  rm -f "$AUTOVC"
  "$LIC" build "$sample" -o /dev/null
  test -f "$AUTOVC"
  "$ROOT/scripts/check-autovc-open-goals.sh" "$AUTOVC"
done
if command -v lake >/dev/null 2>&1; then
  (cd "$ROOT/docs/semantics" && lake build)
  echo "discharge_discrete_basic_corpus_lean: lake ok"
else
  echo "discharge_discrete_basic_corpus_lean: skipped lake (not installed)"
fi
echo "discharge_discrete_basic_corpus_lean: ok"
