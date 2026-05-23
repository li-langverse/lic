# Cinematic algorithm fundamentals — Li ecosystem (AL-6)

**Status:** Active (2026-05-23) — encode / color / audio kernels; **`workload_class=stub`** until Wave E trusted encode.  
**Program:** [PH-CIN](../game-dev/world-studio-vision.md#116-cinematic--animation-ph-cin) (§11.6 — encode/color/audio, not UX-only) · [PH-world-studio-program.md](../game-dev/PH-world-studio-program.md)  
**RFC:** [li-cinematic-rfc.md](../game-dev/specs/li-cinematic-rfc.md)  
**Packages:** `seq`, `anim`, `studio` (`studio.publish` encode surface)  
**Plan:** [algorithms-and-libraries-plan.md](algorithms-and-libraries-plan.md) §3 · AL-6

Gate: `./scripts/check-cinematic-rfc.sh`

---

## North star

World Studio **`seq`** workspace covers **deterministic timeline → pixels → encode → mux** — algorithm depth for **video encode**, **color science**, and **audio sample-clock sync**, separate from UX-05 timeline chrome and UX-09 export handoff patterns.

## Honesty

- **`workload_class=stub`** — no DaVinci Resolve / UE Sequencer / Blender VSE parity claims in CI or docs.
- Layer B rows: `cinematic_encode`, `cinematic_color_grade`, `cinematic_audio_sync` in [verticals.toml](../../benchmarks/competitive/verticals.toml).
- UX intel ([UX-05](../game-dev/competitive-intel/ui-ux-by-dimension.md#ux-05--timeline--playback), [UX-09](../game-dev/competitive-intel/ui-ux-by-dimension.md#ux-09--export--handoff)) documents **patterns only** — this doc owns **kernels**.
- Wave A: trusted **ffmpeg** FFI stays T5-audited; no user `unsafe` until [provability-gaps](../verification/provability-gaps.md) 2e/2f are green.

---

## Encode vs color vs audio (AL-6 split)

| Track | Domain | Incumbent refs | Li v1 stance | Registry `id` |
|-------|--------|----------------|--------------|---------------|
| **Encode** | Container mux, codec presets, GOP | ffmpeg, x264, AV1 (SVT-AV1) | Preset IDs + deterministic frame queue stub; trusted ffmpeg at edge | `cinematic_encode` |
| **Color** | LUT, tone map, display transform | ACES, OCIO, Resolve color science | 1D LUT + Rec.709 linear segment stub; explicit per-channel ops | `cinematic_color_grade` |
| **Audio** | Sample clock, lip-sync to `seq` | ffmpeg `aresample`, Pro Tools pull-up | Integer sample index from timeline time + `sample_rate`; mux stub | `cinematic_audio_sync` |
| **Shared** | Shot / clip scheduling | UE Sequencer, Blender VSE | `import seq` + `import anim` (AL-12 landed) | composable smoke |

---

## Learned from incumbents

| System | Takeaway for Li |
|--------|-----------------|
| **ffmpeg** | Single audited T5 driver for encode/mux; Li owns preset tables + deterministic pre-mux frame hash |
| **DaVinci Resolve** | ACES/OCIO graphs → document color pipeline stages; implement 1D LUT + matrix stubs first |
| **UE Sequencer** | Sub-frame evaluation → `seq_local_time_in_span` + `anim` clips; encode reads baked frame queue |
| **Blender VSE** | Strip stack maps to `SeqTimeline`; audio strips share `seq` clock |
| **CapCut** | Consumer presets → `publish_encode_preset_*` IDs, not UI clone |

---

## Li package surface today (stub)

| `import` | Role today | Algorithm stubs |
|----------|------------|-----------------|
| `seq` | Shots, timeline, active shot at `t` | `seq_timeline_smoke_entry` (frame scheduling) |
| `anim` | Keyframes, clips | clip_id on `SeqShot` |
| `studio` | Shell wire | `publish_encode_preset_h264`, `publish_color_linear_to_rec709`, `publish_audio_sample_index_for_frame` |

Composable: `li-tests/composable/import_studio_cinematic_algorithms.li`.

Every export: mandatory contracts; explicit scalar ops — **no NumPy broadcasting**; matching shapes or compile fail.

---

## PH-CIN milestones

| Phase | ID | Deliverable | Status |
|-------|-----|-------------|--------|
| 0 | CIN-0 | This doc + RFC + `verticals.toml` encode/color/audio rows | **done (2026-05-23)** |
| 1 | CIN-1 | Deterministic pre-encode frame hash bench stub | open |
| 2 | CIN-2 | `cinematic_encode` trusted ffmpeg smoke (T5) | open |
| 3 | CIN-3 | OCIO-class 3×3 matrix + 1D LUT chain | open |
| 4 | CIN-4 | Multichannel audio mux + drift guard | open |
| 5 | CIN-5 | HDR10 / HLG export presets | open (Wave E) |

---

## Tier-0 numerics

- Color: per-channel `float` ops; matrix multiply via explicit `linalg` when 3×3 lands — no broadcast.
- Audio: integer sample indices from rational `fps_num` / `fps_den` and `sample_rate`.
- Encode: frame index `int` only until GPU readback path exists.

---

## Vertical / bench linkage

| Registry | Row | Notes |
|----------|-----|-------|
| [verticals.toml](../../benchmarks/competitive/verticals.toml) | `cinematic_encode`, `cinematic_color_grade`, `cinematic_audio_sync` | **stub**; ffmpeg oracle TBD |
| [vertical-algorithm-catalog.md](vertical-algorithm-catalog.md) | § per row | Honesty per row |
| Studio matrix §3 | Cinematic / animation | RFC + registry; bench **open** |

---

## Out of scope (v1)

Full ACES pipeline, GPU denoise, ML upscale, “Hollywood parity” marketing, httpd streaming (separate agent).

---

## Evidence for implement PRs

- Cite **PH-CIN** phase id and `workload_class=stub` in the PR body.
- Cite `verticals.toml` row `id` for encode vs color vs audio claims.
- Run `./scripts/check-cinematic-rfc.sh` with ecosystem doc gates.
