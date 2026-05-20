# COMSOL — competitive notes (CAE / multiphysics)

**Dimension:** [CAE §3](../ui-ux-by-dimension.md#3-cae--multiphysics-simulation-gui)  
**Media:** Capture Model Builder + Study tree locally.

## UI/UX to steal

- Model tree (geometry → physics → mesh → study → results)  
- Parameter sweep table  
- Run monitor + report export

## Li mapping

| COMSOL | Li |
|--------|-----|
| Study | `studio.adaptive` stages / canvas pipeline |
| Parameters | Inspector (typed Li + units) |
| Results | Viewport field + PH-PUB hash |

➕ Diffable config + `lic build` — not binary `.mph` for agents.
