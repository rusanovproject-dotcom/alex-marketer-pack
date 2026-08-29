#!/usr/bin/env bash
set -euo pipefail

AGENT_DIR="${1:-office/agents/marketer}"
SCRIPT="$AGENT_DIR/scripts/wordstat.sh"
fail() { echo "FAIL: $1" >&2; exit 1; }

[ -f "$SCRIPT" ] || fail "missing $SCRIPT"

TEST_ROOT=$(mktemp -d)
trap 'rm -rf "$TEST_ROOT"' EXIT
mkdir -p "$TEST_ROOT/bin"
SECRETS_FILE="$TEST_ROOT/wordstat.json"
printf '%s\n' '{"api_key":"fixture-key","folder_id":"fixture-folder"}' > "$SECRETS_FILE"

FAKE_CURL="$TEST_ROOT/bin/curl"
cat > "$FAKE_CURL" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

printf '%s\n' "$*" | grep -q -- '--fail-with-body' || {
  echo 'mock curl: --fail-with-body is required' >&2
  exit 99
}

case "${WORDSTAT_MOCK_RESPONSE:-success}" in
  success)
    cat <<'JSON'
{"totalCount":"48885","results":[{"phrase":"buy a dog","count":"40000"}],"associations":[{"phrase":"how much is a poodle","count":"613"}]}
JSON
    ;;
  auth401)
    printf '%s\n' '{"code":401,"message":"Unauthorized"}'
    exit 22
    ;;
  auth403)
    printf '%s\n' '{"code":403,"message":"Forbidden"}'
    exit 22
    ;;
  malformed)
    printf '%s\n' '{"totalCount":'
    ;;
  wrong_schema)
    printf '%s\n' '{"results":[],"associations":[]}'
    ;;
  *)
    echo "unknown mock response: ${WORDSTAT_MOCK_RESPONSE:-}" >&2
    exit 98
    ;;
esac
EOF
chmod +x "$FAKE_CURL"

run_top() {
  WORDSTAT_SECRETS_FILE="$SECRETS_FILE" \
    WORDSTAT_CURL_BIN="$FAKE_CURL" \
    WORDSTAT_MOCK_RESPONSE="$1" \
    bash "$SCRIPT" top 'buy a dog' 10 --region 213
}

success_output=$(run_top success) || fail 'valid HTTP 200 fixture failed'
printf '%s\n' "$success_output" | grep -qFx 'totalCount: 48885' || \
  fail 'primary total was not read from totalCount'
printf '%s\n' "$success_output" | grep -qFx $'RESULT\t40000\tbuy a dog' || \
  fail 'results[] was not rendered'
printf '%s\n' "$success_output" | grep -qFx $'ASSOCIATION\t613\thow much is a poodle' || \
  fail 'associations[] was not rendered'

if run_top auth401 >/dev/null 2>&1; then
  fail 'HTTP 401 fixture unexpectedly succeeded'
fi
if run_top auth403 >/dev/null 2>&1; then
  fail 'HTTP 403 fixture unexpectedly succeeded'
fi
if run_top malformed >/dev/null 2>&1; then
  fail 'malformed JSON fixture unexpectedly succeeded'
fi
if run_top wrong_schema >/dev/null 2>&1; then
  fail 'response without totalCount unexpectedly succeeded'
fi

echo 'PASS: Wordstat mock contract (200, 401, 403, malformed JSON, wrong schema)'
