#!/usr/bin/env bash
# shellcheck disable=SC2016 # literal Markdown backticks are intentional fixtures
set -euo pipefail
AGENT_DIR="${1:-office/agents/marketer}"
LESSON_DIR="${2:-}"
SKILL="$AGENT_DIR/skills/market-to-funnel/SKILL.md"
MKT_RECON="$AGENT_DIR/skills/mkt-recon/SKILL.md"
FUNNEL="$AGENT_DIR/skills/funnel/SKILL.md"
STATE_TEMPLATE="$AGENT_DIR/agent-state-template.md"
TEMPLATE="$AGENT_DIR/templates/GROWTH-PLAN.template.md"
ROUTE_CHECK="$AGENT_DIR/scripts/market-pipeline-entry.sh"
BRANCH_READER="$AGENT_DIR/scripts/read-research-handoff-branch.sh"
WORDSTAT_SKILL="$AGENT_DIR/skills/wordstat-mining/SKILL.md"
WORDSTAT_TEST="$AGENT_DIR/scripts/test-wordstat.sh"
fail() { echo "FAIL: $1" >&2; exit 1; }
require_file() { [ -f "$1" ] || fail "missing $1"; }
require_text() { grep -qF "$2" "$1" || fail "$1 misses: $2"; }
require_no_tree_match() {
  if grep -REn "$2" "$1" >&2; then
    fail "$1 contains forbidden pattern: $3"
  fi
}
require_no_file_match() {
  if grep -En "$2" "$1" >&2; then
    fail "$1 contains forbidden pattern: $3"
  fi
}
require_no_unexpected_url() {
  if grep -REn 'https?://|www\.' "$1" | grep -vF 'https://research-evidence-guide.vercel.app/' >&2; then
    fail "$1 contains forbidden pattern: unexpected URL"
  fi
}
require_count_at_least() {
  count=$(grep -cF "$2" "$1" || true)
  [ "$count" -ge "$3" ] || fail "$1 has $count occurrences of $2; need at least $3"
}
require_count_exact() {
  count=$(grep -cF "$2" "$1" || true)
  [ "$count" -eq "$3" ] || fail "$1 has $count occurrences of $2; need exactly $3"
}

require_file "$SKILL"
require_file "$TEMPLATE"
require_file "$MKT_RECON"
require_file "$FUNNEL"
require_file "$STATE_TEMPLATE"
require_file "$ROUTE_CHECK"
require_file "$BRANCH_READER"
require_file "$WORDSTAT_SKILL"
require_file "$WORDSTAT_TEST"
for field in 'name: market-to-funnel' 'Быстрый режим' 'Глубокий режим' \
  'skills/onboard/SKILL.md' 'skills/mkt-recon/SKILL.md' 'skills/jtbd/SKILL.md' \
  'skills/wordstat-mining/SKILL.md' 'skills/niche-scan/SKILL.md' \
  'skills/core-offer/SKILL.md' 'skills/funnel/SKILL.md' 'GROWTH-PLAN.md' \
  'draft_for_validation' 'quiz-funnel' 'agent-state.md' 'market_pipeline_mode' \
  'market_pipeline_stage' 'market_pipeline_status' 'last_checkpoint' \
  'market_pipeline_entry' 'market_pipeline_entry_confirmed' 'research_handoff' 'PROJECT.md' 'MARKET-RESEARCH.md' \
  'MARKETING-BRIEF.md' 'read-only' 'не запускай новый внешний research' \
  'вернись к research-гайду' '**ровно 5** наиболее важных evidence anchors' \
  'сохраняй все базовые поля' 'scripts/market-pipeline-entry.sh' \
  'scripts/read-research-handoff-branch.sh' \
  'конкретная календарная дата `YYYY-MM-DD` через 7–14 дней' \
  'write allowlist исчерпывающий' '`memory.md`' \
  'До выбора `route` не читай ни одного дочернего навыка.' \
  'helper — единственный разрешённый reader'; do
  require_text "$SKILL" "$field"
done
[ -x "$BRANCH_READER" ] || fail 'research-handoff branch reader is not executable'
for child_name in mkt-recon funnel; do
  branch_output=$("$BRANCH_READER" "$child_name") || \
    fail "branch reader failed for $child_name"
  printf '%s\n' "$branch_output" | grep -qF '## Ветка `research_handoff`' || \
    fail "branch reader missed research_handoff heading for $child_name"
  printf '%s\n' "$branch_output" | grep -qF 'market_pipeline_entry_confirmed: true' || \
    fail "branch reader missed confirmation contract for $child_name"
  printf '%s\n' "$branch_output" | grep -qF 'первым шагом' && \
    fail "branch reader leaked ordinary discovery entry for $child_name"
done
if "$BRANCH_READER" onboard >/dev/null 2>&1; then
  fail 'branch reader accepted a non-handoff child'
fi
for field in 'project_root: null' 'onboarding: false' 'interrupted: false' \
  'interrupted_reason: null' 'resume_hint: null' 'market_pipeline_entry: null' \
  'market_pipeline_entry_confirmed: false' 'market_pipeline_mode: null' \
  'market_pipeline_stage: 0' 'market_pipeline_status: idle' \
  'До выбора `route` не читай ни одного дочернего навыка.'; do
  require_text "$STATE_TEMPLATE" "$field"
done
for child in "$MKT_RECON" "$FUNNEL"; do
  for field in '## Ветка `research_handoff`' 'market_pipeline_entry_confirmed: true' \
    'PROJECT.md' 'MARKET-RESEARCH.md' 'MARKETING-BRIEF.md' \
    '`MARKET.md` и `TRACK.md` не являются входными prerequisites' \
    '`onboarding` не является гейтом' 'Не вызывай `niche-scan`' \
    'не запускай внешний research' 'read-only'; do
    require_text "$child" "$field"
  done
done
for section in '# План роста' '## Готовность фактуры' '## Главное ограничение' \
  '## Центральный оффер' '## Решение по воронке' '## Отвергнутые альтернативы' \
  '## Карта воронки' '## Первая проверка' '## Передача сборщику' \
  '## Следующая команда' '## Evidence anchors' '7–14 дней'; do
  require_text "$TEMPLATE" "$section"
done
require_text "$TEMPLATE" 'entry: <discovery | research_handoff>'
require_text "$TEMPLATE" 'consumer_status: conditional_unavailable'
require_text "$TEMPLATE" 'Главное ограничение: <одно ограничение и его метрика>'
require_text "$SKILL" 'consumer_status: conditional_unavailable'

fixture_dir=$(mktemp -d)
trap 'rm -rf "$fixture_dir"' EXIT
mkdir -p "$fixture_dir/project"
touch "$fixture_dir/project/PROJECT.md" "$fixture_dir/project/MARKET-RESEARCH.md" \
  "$fixture_dir/project/MARKETING-BRIEF.md"
cat > "$fixture_dir/confirmed-state.md" <<'EOF'
---
market_pipeline_entry: research_handoff
market_pipeline_entry_confirmed: true
---
EOF
route_output=$("$ROUTE_CHECK" "$fixture_dir/project" "$fixture_dir/confirmed-state.md")
printf '%s\n' "$route_output" | grep -qFx 'route=research_handoff_confirmed' || \
  fail 'clean handoff without MARKET.md/TRACK.md did not select research_handoff_confirmed'
printf '%s\n' "$route_output" | grep -qF 'discovery' && \
  fail 'clean confirmed handoff routed to discovery'
[ ! -e "$fixture_dir/project/MARKET.md" ] || fail 'fixture unexpectedly has MARKET.md'
[ ! -e "$fixture_dir/project/TRACK.md" ] || fail 'fixture unexpectedly has TRACK.md'
cat > "$fixture_dir/pending-state.md" <<'EOF'
---
market_pipeline_entry: research_handoff
market_pipeline_entry_confirmed: false
---
EOF
pending_output=$("$ROUTE_CHECK" "$fixture_dir/project" "$fixture_dir/pending-state.md")
printf '%s\n' "$pending_output" | grep -qFx 'route=research_handoff_needs_confirmation' || \
  fail 'unconfirmed handoff did not stop at confirmation'
printf '%s\n' "$pending_output" | grep -qFx 'confirmed=false' || \
  fail 'bundle detection silently confirmed handoff'

bash "$WORDSTAT_TEST" "$AGENT_DIR"
for field in 'totalCount' 'results[]' 'associations[]' 'search-api.webSearch.user' \
  'yc.search-api.execute' 'wordstat-gettop.html'; do
  require_text "$WORDSTAT_SKILL" "$field"
done
for file in core.md CLAUDE.md README.md install.md; do
  require_file "$AGENT_DIR/$file"
  require_text "$AGENT_DIR/$file" 'market-to-funnel'
done
require_text "$AGENT_DIR/core.md" 'Trigger `market-to-funnel` имеет приоритет над `onboarding: false`.'
require_text "$AGENT_DIR/core.md" 'разрешены записи только в `agent-state.md`'
require_text "$AGENT_DIR/CLAUDE.md" 'Trigger `market-to-funnel` имеет приоритет над `onboarding: false`:'
require_text "$AGENT_DIR/install.md" 'office/AGENTS.md'
require_text "$AGENT_DIR/install.md" '13 скиллов'
require_text "$AGENT_DIR/install.md" '`niche-scan`'
require_text "$AGENT_DIR/install.md" '`wordstat-mining`'
require_no_file_match "$AGENT_DIR/install.md" 'office/map-team\.md|office/agents/director/' 'obsolete install target'

# Пак ставится зеркалом, поэтому проверяем не только канонический генератор, но и
# реальную чистую раскладку ученика: build-wrapper обязан породить binding agent
# с полным набором release-триггеров.
case "$AGENT_DIR" in
  office/agents/marketer) MIRROR_DIR="_agent-packs/marketer" ;;
  _agent-packs/marketer) MIRROR_DIR="office/agents/marketer" ;;
  *) MIRROR_DIR='' ;;
esac
if [ -n "$MIRROR_DIR" ]; then
  for rel in core.md CLAUDE.md scripts/build-wrapper.sh scripts/wordstat.sh \
    scripts/test-wordstat.sh scripts/test-market-to-funnel.sh \
    scripts/read-research-handoff-branch.sh \
    skills/market-to-funnel/SKILL.md agent-state-template.md \
    templates/GROWTH-PLAN.template.md; do
    cmp -s "$AGENT_DIR/$rel" "$MIRROR_DIR/$rel" || \
      fail "mirror differs: $rel"
  done
fi
for script in wordstat.sh test-wordstat.sh test-market-to-funnel.sh \
  read-research-handoff-branch.sh; do
  [ -x "$AGENT_DIR/scripts/$script" ] || \
    fail "required executable bit is missing: scripts/$script"
done
installed_root=$(mktemp -d)
trap 'rm -rf "$fixture_dir" "$installed_root"' EXIT
mkdir -p "$installed_root/office/agents"
cp -R "$AGENT_DIR" "$installed_root/office/agents/marketer"
bash "$installed_root/office/agents/marketer/scripts/build-wrapper.sh" >/dev/null
installed_wrapper="$installed_root/.claude/agents/marketer.md"
require_file "$installed_wrapper"
installed_frontmatter="$installed_root/marketer.frontmatter"
awk 'NR == 1 && $0 == "---" { inside = 1; next } inside && $0 == "---" { exit } inside { print }' \
  "$installed_wrapper" > "$installed_frontmatter"
for trigger in 'проведи меня от рынка до воронки' 'маркетинговый навигатор' \
  'подготовь проект к воронке' 'быстрый маркетинговый разбор для эфира'; do
  require_text "$installed_frontmatter" "$trigger"
done
if [ -n "$LESSON_DIR" ]; then
  for rel in LESSON-CORE.md FACILITATOR-RUNBOOK.md STUDENT-CHECKLIST.md \
    demo/PROJECT.md demo/MARKET-RESEARCH.md demo/MARKETING-BRIEF.md \
    demo/MARKET.md demo/GROWTH-PLAN.md; do
    require_file "$LESSON_DIR/$rel"
  done
  require_text "$LESSON_DIR/LESSON-CORE.md" 'title: "Готовая фактура → решение по воронке"'
  require_text "$LESSON_DIR/LESSON-CORE.md" '# Урок: Готовая фактура → решение по воронке'
  require_text "$LESSON_DIR/LESSON-CORE.md" 'За 120 минут ученик проходит маршрут `готовая фактура → решение`: превращает готовые `PROJECT.md`, `MARKET-RESEARCH.md` и `MARKETING-BRIEF.md` в принятое владельцем решение `GROWTH-PLAN.md`'
  require_text "$LESSON_DIR/LESSON-CORE.md" 'status: core-for-design'
  require_text "$LESSON_DIR/LESSON-CORE.md" 'готовая фактура → решение'
  require_text "$LESSON_DIR/LESSON-CORE.md" 'https://research-evidence-guide.vercel.app/'
  require_text "$LESSON_DIR/LESSON-CORE.md" 'Новый research не начинай'
  require_text "$LESSON_DIR/LESSON-CORE.md" '3–5 evidence anchors'
  require_text "$LESSON_DIR/LESSON-CORE.md" '120 минут'
  for heading in '## 0. Обещание урока' '## 1. Драматургия часа' \
    '## 2. Поэкранная структура' '## 3. Раздатка-шпаргалка' \
    '## 4. Домашка-артефакт'; do
    require_text "$LESSON_DIR/LESSON-CORE.md" "$heading"
  done
  require_count_at_least "$LESSON_DIR/LESSON-CORE.md" 'Микро-действие' 4
  for field in '00–10  мост от research к решению' \
    '10–20  аудит готового входа' \
    '20–40  экономика назад' \
    '40–55  3–5 evidence anchors' \
    '55–70  одно ограничение' \
    '70–90  сравнение трёх механик' \
    '90–105 решение владельца' \
    '105–115 первый тест' \
    '115–120 handoff и recovery' \
    'checkpoint artifact' \
    'STOP: handoff не готов' \
    'observer/demo/recovery' \
    'Если нет доступа к агенту' 'Если агент не стартует' \
    'Если нет калькулятора/данных' \
    'Если данных мало' 'Если владелец не готов принять' \
    'Если один из входных файлов отсутствует'; do
    require_text "$LESSON_DIR/FACILITATOR-RUNBOOK.md" "$field"
  done
  require_no_tree_match "$LESSON_DIR" 'Wordstat|market scan|new market scan|fast market scan|новый поиск рынка|live Wordstat' 'live-research or new-market-scan wording'
  require_no_tree_match "$LESSON_DIR" 'title: "От рынка до воронки: один агент собирает маркетинговый фундамент"|# Урок: От рынка до воронки|За один эфир ученик перестаёт выбирать воронку на вкус|За один эфир ученик не исследует рынок заново, а превращает готовые|fast-mode command|stages 0–7|deep-mode continuation|deep-mode homework|project intake' 'old lesson positioning'
  for field in 'Команда research-handoff' 'читает PROJECT.md, MARKET-RESEARCH.md, MARKETING-BRIEF.md' \
    'Новый research не начинай' 'Команда recovery' \
    'Ожидаемый итог: GROWTH-PLAN.md' 'Самопроверка GROWTH-PLAN.md' \
    'Handoff в quiz-funnel' \
    'Если одного из трёх входных файлов нет: STOP: handoff не готов' \
    'не продолжай личный post-research route' \
    'observer/demo/recovery' \
    'Вернись к research-гайду' \
    'или явно выбери старый discovery-маршрут' \
    'Команда recovery не используется при неполном bundle'; do
    require_text "$LESSON_DIR/STUDENT-CHECKLIST.md" "$field"
  done
  require_no_file_match "$LESSON_DIR/STUDENT-CHECKLIST.md" 'This command|expected output|decision route|Prerequisites|research guide' 'random English checklist wording'
  require_text "$LESSON_DIR/demo/PROJECT.md" 'Демо полностью вымышленное'
  require_text "$LESSON_DIR/demo/PROJECT.md" 'Бизнес не регулируемый'
  require_text "$LESSON_DIR/demo/MARKET-RESEARCH.md" 'Демо полностью вымышленное'
  require_text "$LESSON_DIR/demo/MARKET-RESEARCH.md" 'без fake URLs'
  require_text "$LESSON_DIR/demo/MARKETING-BRIEF.md" 'Демо полностью вымышленное'
  require_text "$LESSON_DIR/demo/MARKETING-BRIEF.md" 'без fake URLs'
  require_text "$LESSON_DIR/demo/MARKET.md" 'Демо полностью вымышленное'
  require_text "$LESSON_DIR/demo/MARKET.md" 'без fake URLs'
  require_text "$LESSON_DIR/demo/MARKET.md" 'MARKET-RESEARCH.md'
  require_text "$LESSON_DIR/demo/MARKET.md" 'MARKETING-BRIEF.md'
  for field in 'Целевая прибыль после маркетинга | 120 000 ₽' \
    'Маркетинговый бюджет | 44 000 ₽' \
    'Заказов до цели | 29' 'Заявок до цели | 65' \
    'Допустимый CPL | до 676 ₽' \
    '29 заказов × 5 700 ₽ - 44 000 ₽ = 121 300 ₽'; do
    require_text "$LESSON_DIR/demo/PROJECT.md" "$field"
  done
  require_text "$LESSON_DIR/demo/GROWTH-PLAN.md" '29 заказов после маркетинга дают 121 300 ₽ прибыли'
  require_text "$LESSON_DIR/demo/GROWTH-PLAN.md" 'MARKET-RESEARCH.md'
  require_text "$LESSON_DIR/demo/GROWTH-PLAN.md" 'MARKETING-BRIEF.md'
  require_text "$LESSON_DIR/demo/GROWTH-PLAN.md" 'owner_approved: true'
  require_text "$LESSON_DIR/demo/GROWTH-PLAN.md" 'mode: fast'
  require_text "$LESSON_DIR/demo/GROWTH-PLAN.md" 'entry: research_handoff'
  require_text "$LESSON_DIR/demo/GROWTH-PLAN.md" '## Отвергнутые альтернативы'
  require_text "$LESSON_DIR/demo/GROWTH-PLAN.md" '## Первая проверка'
  require_text "$LESSON_DIR/demo/GROWTH-PLAN.md" '| Primary 7–14 day test |'
  require_text "$LESSON_DIR/demo/GROWTH-PLAN.md" '⚪ измерить первым действием'
  require_text "$LESSON_DIR/demo/GROWTH-PLAN.md" '## Backlog проверок'
  require_count_exact "$LESSON_DIR/demo/GROWTH-PLAN.md" '| Primary 7–14 day test |' 1
  require_no_file_match "$LESSON_DIR/demo/GROWTH-PLAN.md" '70%|55%|35%|\| 0% \| 60%|\| 45% \| 55%|\| 0% \| 50%' 'unmeasured baseline presented as fact'
  require_no_tree_match "$LESSON_DIR/demo" 'Синтет[^\n]*🟡|синтет[^\n]*🟡|\| 🟡 \|[^\n]*(Синтет|синтет)' 'synthetic demo evidence labeled above red'
  require_text "$LESSON_DIR/LESSON-CORE.md" '`waiting_owner` — незавершённый результат'
  require_text "$LESSON_DIR/LESSON-CORE.md" 'Обещание урока выполнено только'
  require_no_tree_match "$LESSON_DIR/demo" 'без ответственности' 'unsupported responsibility claim'
  require_text "$LESSON_DIR/demo/MARKET.md" 'после вебинара'
  require_text "$LESSON_DIR/demo/GROWTH-PLAN.md" 'после вебинара'
  require_no_tree_match "$LESSON_DIR" '/Users/|[~]/workspace|\.env|sk-[A-Za-z0-9]' 'private path, env, or token'
  require_no_unexpected_url "$LESSON_DIR"

  VERIFY_DIR="$LESSON_DIR/verify"
  for rel in COMMITTED-TRACE.md check-committed-trace-shape.sh \
    run-isolated-replay.sh test-isolated-replay-harness.sh \
    validate-replay-events.py validate-replay-artifacts.py \
    test-validate-replay-artifacts.py PROVIDER-REPLAY-SUMMARY.md RUN-REPORT.md; do
    require_file "$VERIFY_DIR/$rel"
  done
  bash "$VERIFY_DIR/test-isolated-replay-harness.sh"
  require_text "$VERIFY_DIR/RUN-REPORT.md" 'Acceptance-run source HEAD'
  require_text "$VERIFY_DIR/RUN-REPORT.md" 'Committed trace evidence HEAD'
  require_text "$VERIFY_DIR/RUN-REPORT.md" 'Provider replay source HEAD'
  require_text "$VERIFY_DIR/RUN-REPORT.md" 'git diff --check 80cd4559..HEAD'
  SUMMARY="$VERIFY_DIR/PROVIDER-REPLAY-SUMMARY.md"
  summary_status=$(sed -n 's/^status: //p' "$SUMMARY" | head -1)
  case "$summary_status" in
    PASS)
      require_text "$SUMMARY" 'source_head:'
      require_text "$SUMMARY" '## Input SHA-256 (before = after)'
      require_text "$SUMMARY" '## Observed output SHA-256'
      require_text "$SUMMARY" '## Observed assertions'
      require_text "$SUMMARY" 'read-only input hashes unchanged: PASS'
      ;;
    INVALIDATED)
      require_text "$SUMMARY" 'reason:'
      ;;
    *) fail "provider replay summary has unsupported status: ${summary_status:-missing}" ;;
  esac
fi
echo 'PASS: market-to-funnel contract'
