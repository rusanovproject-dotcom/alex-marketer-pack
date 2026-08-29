#!/usr/bin/env bash
set -euo pipefail

AGENT_DIR=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)

case "${1:-}" in
  mkt-recon|funnel) skill_name=$1 ;;
  *)
    echo 'usage: read-research-handoff-branch.sh <mkt-recon|funnel>' >&2
    exit 64
    ;;
esac

skill_file="$AGENT_DIR/skills/$skill_name/SKILL.md"
[ -f "$skill_file" ] || { echo "missing child skill: $skill_name" >&2; exit 66; }

awk '
  /^## / && active && $0 !~ /research_handoff/ { exit }
  /^## / && $0 ~ /research_handoff/ { active = 1; found = 1 }
  active { print }
  END { if (!found) exit 65 }
' "$skill_file"
