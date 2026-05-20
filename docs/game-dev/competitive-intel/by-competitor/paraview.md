# ParaView — competitive notes (scientific visualization)

**Dimension:** [SciVis §2](../ui-ux-by-dimension.md#2-scientific-visualization)  
**Media:** Add `PV-DOC-01` to [catalog.json](../catalog.json) when captured.

## UI/UX to steal

- Pipeline browser (source → filter → display)  
- 3D view + color map legend + time slider  
- Linked selection (tree ↔ view)

## Li mapping

| ParaView | Li |
|----------|-----|
| Pipeline | `canvas` nodes → `sim_scientific` |
| Color map | Field overlay in `li-render` viewport |
| Export figure | PH-PUB + validity row |

➕ Li shows **validity / oracle** under legend — ParaView does not.
