#!/usr/bin/env bash
# Chemistry basic-corpus specimens (EQ/IG/RX/TH tranches) → zero open Prop goals.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
chmod +x "$ROOT/scripts/check-autovc-open-goals.sh"
for sample in \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_eq_003.li" \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_eq_008.li" \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_eq_013.li" \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_eq_018.li" \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_eq_023.li" \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_eq_028.li" \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_eq_033.li" \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_eq_038.li" \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_eq_043.li" \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_eq_048.li" \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_ig_001.li" \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_ig_006.li" \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_ig_011.li" \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_ig_016.li" \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_ig_021.li" \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_ig_026.li" \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_ig_031.li" \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_ig_036.li" \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_ig_041.li" \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_ig_046.li" \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_rx_002.li" \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_rx_007.li" \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_rx_012.li" \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_rx_017.li" \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_rx_022.li" \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_rx_027.li" \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_rx_032.li" \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_rx_037.li" \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_rx_042.li" \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_rx_047.li" \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_th_004.li" \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_th_009.li" \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_th_014.li" \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_th_019.li" \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_th_024.li" \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_th_029.li" \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_th_034.li" \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_th_039.li" \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_th_044.li" \
  "$ROOT/proof-db/chemistry/basic-corpus/chem_lm_bc_th_049.li";
do
  AUTOVC="$ROOT/build/generated/AutoVC.lean"
  rm -f "$AUTOVC"
  "$LIC" build "$sample" -o /dev/null
  test -f "$AUTOVC"
  "$ROOT/scripts/check-autovc-open-goals.sh" "$AUTOVC"
done
if command -v lake >/dev/null 2>&1; then
  (cd "$ROOT/docs/semantics" && lake build)
  echo "discharge_chemistry_basic_corpus_lean: lake ok"
else
  echo "discharge_chemistry_basic_corpus_lean: skipped lake (not installed)"
fi
echo "discharge_chemistry_basic_corpus_lean: ok"
