# RFC stub: publication-export-rfc

**Status:** Draft stub  
**Date:** 2026-05  
**Vision:** [world-studio-vision.md](../world-studio-vision.md)

## Problem

Scientific **figure** and **repro bundle** export (PH-PUB) was conflated with **cinematic video** encode/color/audio (PH-CIN). Agents need separate tracks: static publication vs timeline mux.

## Proposal

| Track | Program | RFC |
|-------|---------|-----|
| Figures, SVG, repro zip | PH-PUB | this RFC (future API) |
| Video encode, color, audio sync | PH-CIN | [li-cinematic-rfc.md](li-cinematic-rfc.md) |

`studio.publish` figure/bundle APIs remain PH-PUB. H.264/MP4 presets and sample-clock sync live under PH-CIN (`publish_encode_*`, `publish_color_*`, `publish_audio_*` on `import studio`).

## Li syntax

Use Python-style `def` for functions; `requires` / `ensures` / `decreases` on exported APIs.

## Proof / trust

PH-PUB: manifest checksums for repro bundles. PH-CIN: trusted ffmpeg T5 at CIN-2 — see [cinematic-algorithm-fundamentals.md](../../ecosystem/cinematic-algorithm-fundamentals.md).

## Dependencies

See [PH-world-studio-program.md](../PH-world-studio-program.md).

## Open questions

- [ ] Merge figure export into `li-studio` or separate `li-publish` package?
- [ ] Shared manifest schema between PH-PUB zip and PH-CIN encode jobs?
