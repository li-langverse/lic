#!/bin/bash
cd "$(dirname "$0")"
for f in *.sh entrypoint-*.sh; do
  [ -f "$f" ] && sed -i 's/\r$//' "$f"
done
