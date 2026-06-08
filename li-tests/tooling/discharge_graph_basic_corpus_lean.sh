#!/usr/bin/env bash
# Graph basic-corpus specimens (COL/CON/HS/TR tranches) → zero open Prop goals.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
chmod +x "$ROOT/scripts/check-autovc-open-goals.sh"
for sample in \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_col_004.li" \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_col_009.li" \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_col_014.li" \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_col_019.li" \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_col_024.li" \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_col_029.li" \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_col_034.li" \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_col_039.li" \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_col_044.li" \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_col_049.li" \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_con_003.li" \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_con_008.li" \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_con_013.li" \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_con_018.li" \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_con_023.li" \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_con_028.li" \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_con_033.li" \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_con_038.li" \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_con_043.li" \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_con_048.li" \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_hs_001.li" \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_hs_006.li" \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_hs_011.li" \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_hs_016.li" \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_hs_021.li" \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_hs_026.li" \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_hs_031.li" \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_hs_036.li" \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_hs_041.li" \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_hs_046.li" \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_tr_002.li" \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_tr_007.li" \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_tr_012.li" \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_tr_017.li" \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_tr_022.li" \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_tr_027.li" \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_tr_032.li" \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_tr_037.li" \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_tr_042.li" \
  "$ROOT/proof-db/graph/basic-corpus/gt_lm_bc_tr_047.li";
do
  AUTOVC="$ROOT/build/generated/AutoVC.lean"
  rm -f "$AUTOVC"
  "$LIC" build "$sample" -o /dev/null
  test -f "$AUTOVC"
  "$ROOT/scripts/check-autovc-open-goals.sh" "$AUTOVC"
done
if command -v lake >/dev/null 2>&1; then
  (cd "$ROOT/docs/semantics" && lake build)
  echo "discharge_graph_basic_corpus_lean: lake ok"
else
  echo "discharge_graph_basic_corpus_lean: skipped lake (not installed)"
fi
echo "discharge_graph_basic_corpus_lean: ok"
