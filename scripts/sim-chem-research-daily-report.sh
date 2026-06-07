#!/usr/bin/env bash
export SIM_RESEARCH_VERTICAL=chem
exec "$(cd "$(dirname "$0")" && pwd)/sim-algo-research-daily-report.sh" "$@"
