# RFC: Studio AI — apply_patch loop (PH-GD-3)

**Status:** Draft  
**Track:** PH-GD-3, PH-AGENT  
**Vision:** [world-studio-vision.md](../world-studio-vision.md)

## Problem

World Studio needs agent-driven edits with mandatory `lic check` before apply.

## Proposal

**`li-studio-ai`** (`import studio.ai`):

- `studio_ai_patch_new` / `studio_ai_apply_patch_stub`  
- Future: MCP `engine_apply_patch` → `lic diagnose` JSON  

## Phases

GD-3-0 stubs (landed) → GD-3-1 diff format → GD-3-2 Cursor SDK wire.

## Dependencies

`li-studio`, PH-AGENT MCP sketch.
