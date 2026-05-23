# RFC: Cinematic algorithms — encode, color, audio (PH-CIN)

**Status:** Draft stub (2026-05-23)  
**Track:** PH-CIN  
**Split from:** PH-PUB / creative UX — [publication-export-rfc.md](publication-export-rfc.md) (figures/zip) vs **timeline video**  
**Fundamentals:** [cinematic-algorithm-fundamentals.md](../../ecosystem/cinematic-algorithm-fundamentals.md)  
**Vision:** [world-studio-vision.md](../world-studio-vision.md)

## Problem

Cinematic / animation vertical listed “creative RFC” and UX-05/09 patterns without **algorithm tables** for encode (ffmpeg-class), color science (LUT/transfer), and audio sample-clock sync. Layer B registry could not cite kernel rows; agents risked UX-only deliverables for AL-6.

## Proposal

**Profile:** `seq` workspace · **Program:** PH-CIN

| Subsystem | Package | Canonical kernel (target) | `verticals.toml` id |
|-----------|---------|---------------------------|---------------------|
| Encode | `studio` (`publish_*`) | H.264/MP4 preset + mux stub | `cinematic_encode` |
| Color | `studio` (`publish_*`) | 1D LUT + Rec.709 segment | `cinematic_color_grade` |
| Audio | `studio` (`publish_*`) | sample index from frame + fps rational | `cinematic_audio_sync` |
| Timeline | `seq`, `anim` | shot span, clip scheduling | (composable; AL-12) |

```li
# illustrative — contracts required on real exports
import studio
import seq

def cinematic_workload_class_stub() -> int
  requires true
  ensures result == 0
=
  0
```

**Studio UX:** UE Sequencer / Blender VSE patterns live under UX-05; **this RFC does not duplicate** transport chrome — only kernels above.

## Phases (PH-CIN)

| ID | Deliverable |
|----|-------------|
| CIN-0 | Fundamentals doc + registry rows + this RFC |
| CIN-1 | Deterministic frame hash bench stub |
| CIN-2 | Trusted ffmpeg encode smoke (T5) |
| CIN-3 | 3×3 color matrix + LUT chain |
| CIN-4 | Audio mux + drift guard |
| CIN-5 | HDR10 / HLG presets (Wave E) |

## Li syntax

Python-style `def`; `requires` / `ensures` / `decreases` on exported APIs. Explicit linear algebra only — **no NumPy broadcasting**.

## Proof / trust

| Component | Proved | Trusted (T5 FFI) |
|-----------|--------|------------------|
| Sample index from timeline | integer rational math (future VC) | — |
| 1D LUT / transfer | per-channel bounds (future) | — |
| Encode / mux | preset ID tables | ffmpeg / libav |
| Full color pipeline | — | OCIO config (deferred) |

Until Wave A exit: label **`workload_class=stub`** in docs and PRs.

## Dependencies

- [PH-world-studio-program.md](../PH-world-studio-program.md) — PH-CIN after PH-GD-1, `seq`/`anim` AL-12
- [algorithms-and-libraries-plan.md](../../ecosystem/algorithms-and-libraries-plan.md) AL-6
- [vertical-algorithm-catalog.md](../../ecosystem/vertical-algorithm-catalog.md)

## Open questions

- [ ] Separate `li-publish` package vs `studio.publish_*` in `li-studio`?
- [ ] First ffmpeg oracle: frame MD5 vs PSNR on synthetic gradient?
- [ ] ACEScg working space before OCIO FFI?
