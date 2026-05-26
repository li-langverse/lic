# Release notes: 2026-05-26 — PH-AM AM-0 / PH-DRUG DRUG-0 workflows

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PH / REQ:** PH-AM AM-0, PH-DRUG DRUG-0  

## Summary

Additive slicer and drug-design LITL workflow stubs land in domain packages, wire into `studio_sim_step_hook`, and ship composable smokes for competitive bench registries.

## Verification

```bash
lic check packages/li-sim-additive/li-tests/smoke/tick_stub.li
lic check packages/li-sim-drug-design/li-tests/smoke/tick_stub.li
lic check li-tests/composable/import_sim_additive_slicer_workflow.li
lic check li-tests/composable/import_sim_drug_design_litl_workflow.li
```
