# Figma — competitive notes

**Media:** FI-* in [media-catalog.md](../media-catalog.md)

## Product intros

- **UI3 (2024):** Chrome minimized; **canvas is the product**.
- **Sections** for collaboration regions.

## UI/UX to steal

- Infinite pan/zoom; section labels.
- Minimal top bar; focus on artboard/canvas.

## Li mapping

| Figma | Li |
|-------|-----|
| Infinite canvas | `gui.canvas` |
| Sections | `canvas.region` / group nodes |
| Dev handoff | `lic build` + manifest (stronger than Figma inspect) |

Figma is **not** a runtime — Li adds **compile + sim + export**.
