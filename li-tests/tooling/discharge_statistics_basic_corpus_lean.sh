#!/usr/bin/env bash
# Statistics basic-corpus specimens (BER/BN/CH/CLT/COV/GAU/MGF/VR tranches) → zero open Prop goals.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
chmod +x "$ROOT/scripts/check-autovc-open-goals.sh"
for sample in \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_ber_009.li" \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_ber_019.li" \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_ber_029.li" \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_ber_039.li" \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_ber_049.li" \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_bn_006.li" \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_bn_016.li" \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_bn_026.li" \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_bn_036.li" \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_bn_046.li" \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_ch_004.li" \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_ch_014.li" \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_ch_024.li" \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_ch_034.li" \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_ch_044.li" \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_clt_005.li" \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_clt_015.li" \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_clt_025.li" \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_clt_035.li" \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_clt_045.li" \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_cov_007.li" \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_cov_017.li" \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_cov_027.li" \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_cov_037.li" \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_cov_047.li" \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_gau_010.li" \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_gau_020.li" \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_gau_030.li" \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_gau_040.li" \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_gau_050.li" \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_mgf_008.li" \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_mgf_018.li" \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_mgf_028.li" \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_mgf_038.li" \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_mgf_048.li" \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_vr_003.li" \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_vr_013.li" \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_vr_023.li" \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_vr_033.li" \
  "$ROOT/proof-db/statistics/basic-corpus/st_lm_bc_vr_043.li";
do
  AUTOVC="$ROOT/build/generated/AutoVC.lean"
  rm -f "$AUTOVC"
  "$LIC" build "$sample" -o /dev/null
  test -f "$AUTOVC"
  "$ROOT/scripts/check-autovc-open-goals.sh" "$AUTOVC"
done
if command -v lake >/dev/null 2>&1; then
  (cd "$ROOT/docs/semantics" && lake build)
  echo "discharge_statistics_basic_corpus_lean: lake ok"
else
  echo "discharge_statistics_basic_corpus_lean: skipped lake (not installed)"
fi
echo "discharge_statistics_basic_corpus_lean: ok"
