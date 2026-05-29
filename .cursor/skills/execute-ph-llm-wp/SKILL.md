# Execute PH-LLM work package

Single-WP workflow for the lillm native inference library.

## When to use

Implementing any **WP-LLM-01** through **WP-LLM-08** work package.

## Workflow

1. **Identify WP** — confirm WP-LLM-XX from [PH-LLM-program.md](../../docs/game-dev/PH-LLM-program.md)
2. **Check dependencies** — prerequisite WPs merged and smokes green
3. **Read scope** — [ph-llm-wp-scope.mdc](../../rules/ph-llm-wp-scope.mdc)
4. **Implement** — `packages/li-llm/src/lib.li` (or submodule)
5. **Test** — add smoke under `packages/li-llm/li-tests/smoke/`
6. **Verify** — `lic check packages/li-llm/li-tests/smoke/<gate>.li`
7. **Honesty** — bump `li_llm_version()` only when WP gate passes
8. **PR** — one WP per PR; title includes `WP-LLM-XX`

## Exit gates

| WP | Gate command |
|----|--------------|
| WP-LLM-01 | `lic check packages/li-llm/li-tests/smoke/llm_tokenize_roundtrip.li` |
| WP-LLM-02 | load fixture weights smoke |
| WP-LLM-03 | forward logits ULP smoke |
| WP-LLM-04 | greedy decode smoke |
| WP-LLM-05+ | tier-3 bench row |

## Constraints

- All inference in `.li`
- No PyTorch runtime
- Orchestration changes go to `packages/li-studio-ai`, not `li-llm`
