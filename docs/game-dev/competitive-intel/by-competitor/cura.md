# Cura / slicers — competitive notes (additive)

**Dimension:** [AM §6](../ui-ux-by-dimension.md#6-additive-manufacturing--slicers)  
**Also:** PrusaSlicer, Bambu Studio — same UX patterns.

## UI/UX to steal

- 3D plater + layer preview slider  
- Material/profile presets  
- Warnings panel before print

## Li mapping

| Slicer | Li |
|--------|-----|
| Slice preview | Pre-export review step |
| Presets | `printer_profile` in `studio.toml` |
| Send print | `am_export_print` after **`require_sim_pass`** |

➕ Thermal/warp sim gate — slicers skip physics validity.
