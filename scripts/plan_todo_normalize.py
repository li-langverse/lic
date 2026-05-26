"""Canonical plan todo ids — strip swarm apply-actions mirror prefixes."""


def normalize_plan_todo_id(todo_id: str, runner_id: str) -> str:
    """Strip repeated ``gap-{runner_id}-`` prefixes from orchestrator mirror ids."""
    tid = str(todo_id).strip()
    prefix = f"gap-{runner_id}-"
    while tid.startswith(prefix):
        tid = tid[len(prefix) :]
    return tid or str(todo_id)
