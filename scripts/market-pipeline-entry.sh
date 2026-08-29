#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="${1:-}"
STATE_FILE="${2:-}"

fail() {
  echo "FAIL: $1" >&2
  exit 1
}

[ -n "$PROJECT_ROOT" ] || fail 'usage: market-pipeline-entry.sh <project_root> [agent-state.md]'
[ -d "$PROJECT_ROOT" ] || fail "project_root is not a directory: $PROJECT_ROOT"

state_value() {
  local key=$1
  if [ -z "$STATE_FILE" ] || [ ! -f "$STATE_FILE" ]; then
    return 0
  fi
  awk -F': *' -v wanted="$key" '$1 == wanted { print $2; exit }' "$STATE_FILE"
}

entry=$(state_value market_pipeline_entry)
confirmed=$(state_value market_pipeline_entry_confirmed)
entry=${entry:-null}
confirmed=${confirmed:-false}

case "$confirmed" in
  true|false) ;;
  *) fail "market_pipeline_entry_confirmed must be true or false, got: $confirmed" ;;
esac

missing=()
for name in PROJECT.md MARKET-RESEARCH.md MARKETING-BRIEF.md; do
  [ -f "$PROJECT_ROOT/$name" ] || missing+=("$name")
done

if [ "$entry" = discovery ]; then
  echo 'route=discovery'
  echo 'entry=discovery'
  echo 'confirmed=false'
  exit 0
fi

if [ "${#missing[@]}" -gt 0 ]; then
  if [ "$entry" = research_handoff ]; then
    echo 'route=research_handoff_incomplete'
    echo 'entry=research_handoff'
    echo 'confirmed=false'
  else
    echo 'route=unselected'
    echo 'entry=null'
    echo 'confirmed=false'
  fi
  printf 'missing=%s\n' "$(IFS=,; echo "${missing[*]}")"
  exit 0
fi

if [ "$entry" = research_handoff ] && [ "$confirmed" = true ]; then
  echo 'route=research_handoff_confirmed'
  echo 'entry=research_handoff'
  echo 'confirmed=true'
  exit 0
fi

echo 'route=research_handoff_needs_confirmation'
echo 'entry=research_handoff'
echo 'confirmed=false'
