#!/bin/bash
# verify-pack.sh — проверяет целостность пака перед публикацией.
# Запускается из корня пака: bash scripts/verify-pack.sh
#
# Детектор ссылок: ищет ТОЛЬКО `/skill-name` в backticks в *.md файлах.
# Это стандарт оформления slash-команд в нашем паке.
# Пути файлов (audience/voice-of-customer.md), URL (github.com/x/y), просто
# слова со слешем — не ловятся, потому что они не в backticks.
#
# Exit codes:
#   0 — всё ок, пак готов к публикации
#   1 — критические дыры (битые ссылки в local_skills/global_skills)
#   2 — ошибка чтения manifest

set -e

PACK_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MANIFEST="$PACK_ROOT/manifest.yaml"

if [ ! -f "$MANIFEST" ]; then
  echo "✗ manifest.yaml не найден в $PACK_ROOT"
  exit 2
fi

# --- Парсер manifest.yaml (без yq) ---
# Извлекаем имена скиллов из секции "name: <name>" под заголовком секции.
parse_skill_names() {
  local section="$1"
  # awk: между заголовком "section:" и следующим заголовком верхнего уровня
  awk -v section="$section" '
    $0 ~ "^" section ":" { in_section = 1; next }
    in_section && /^[a-z_]+:/ { exit }
    in_section && /^  - name:/ {
      gsub(/^  - name:[ ]*/, "")
      print
    }
  ' "$MANIFEST"
}

parse_simple_list() {
  local section="$1"
  awk -v section="$section" '
    $0 ~ "^" section ":" { in_section = 1; next }
    in_section && /^[a-z_]+:/ { exit }
    in_section && /^  - / {
      gsub(/^  - /, "")
      gsub(/[ \t]*#.*$/, "")
      gsub(/[ \t]+$/, "")
      if (length($0) > 0) print
    }
  ' "$MANIFEST"
}

LOCAL_SKILLS=$(parse_skill_names "local_skills")
GLOBAL_SKILLS=$(parse_skill_names "global_skills")
KNOWN_GAPS=$(parse_skill_names "known_gaps")
IGNORE_LIST=$(parse_simple_list "verify_ignore")

PACK_VERSION=$(grep -E '^version:' "$MANIFEST" | sed -E 's/^version:[ ]*//')

echo "=========================================="
echo "  alex-marketer-pack v${PACK_VERSION}"
echo "  verify-pack.sh"
echo "=========================================="
echo ""

# --- Проверка local skills ---
echo "→ Local skills (skills/<name>/):"
LOCAL_FAIL=0
for skill in $LOCAL_SKILLS; do
  if [ -d "$PACK_ROOT/skills/$skill" ] && [ -f "$PACK_ROOT/skills/$skill/SKILL.md" ]; then
    echo "  ✓ /$skill"
  else
    echo "  ✗ /$skill — заявлен в manifest, но skills/$skill/SKILL.md отсутствует"
    LOCAL_FAIL=$((LOCAL_FAIL + 1))
  fi
done
[ -z "$LOCAL_SKILLS" ] && echo "  (пусто в manifest)"
echo ""

# --- Проверка global skills ---
# Глобальные скиллы могут жить в одном из двух мест:
#  1. $PACK_ROOT/.claude/skills/<name>/  — внутри свежего клона репо (для публикации)
#  2. <WORKSPACE_ROOT>/.claude/skills/<name>/ — у ученика после установки
# WORKSPACE_ROOT находим подъёмом по дереву до первой папки с .claude/skills/ (но не самого пака)
# или до домашней директории.
find_global_skill() {
  local skill="$1"
  # 1. Свежий клон — внутри пака
  if [ -f "$PACK_ROOT/.claude/skills/$skill/SKILL.md" ]; then
    echo "$PACK_ROOT/.claude/skills/$skill"
    return 0
  fi
  # 2. Подъём по дереву до корня workspace
  local dir="$PACK_ROOT"
  while [ "$dir" != "/" ] && [ "$dir" != "$HOME" ]; do
    dir="$(dirname "$dir")"
    if [ -f "$dir/.claude/skills/$skill/SKILL.md" ] && [ "$dir/.claude/skills" != "$PACK_ROOT/.claude/skills" ]; then
      echo "$dir/.claude/skills/$skill"
      return 0
    fi
  done
  # 3. Глобально в $HOME (системные скиллы Claude Code)
  if [ -f "$HOME/.claude/skills/$skill/SKILL.md" ]; then
    echo "$HOME/.claude/skills/$skill"
    return 0
  fi
  return 1
}

echo "→ Global skills (.claude/skills/<name>/):"
GLOBAL_FAIL=0
for skill in $GLOBAL_SKILLS; do
  if FOUND_PATH=$(find_global_skill "$skill"); then
    # Относительный путь для красоты
    REL="${FOUND_PATH#$PACK_ROOT/}"
    [ "$REL" = "$FOUND_PATH" ] && REL="${FOUND_PATH/#$HOME/~}"
    echo "  ✓ /$skill ($REL)"
  else
    echo "  ✗ /$skill — заявлен как global, но не найден ни в паке, ни в workspace, ни в \$HOME"
    GLOBAL_FAIL=$((GLOBAL_FAIL + 1))
  fi
done
[ -z "$GLOBAL_SKILLS" ] && echo "  (пусто в manifest)"
echo ""

# --- Грепаем slash-команды ТОЛЬКО в backticks ---
echo "→ Сканирую *.md на ссылки \`/skill-name\` (только в backticks)..."
ALL_REFS=$(grep -rhoE '`/[a-z][a-z0-9-]{2,}`' --include="*.md" "$PACK_ROOT" 2>/dev/null \
  | tr -d '`' \
  | sort -u)

# Известные имена (local + global + ignore + known_gaps)
KNOWN_NAMES=$(echo -e "$LOCAL_SKILLS\n$GLOBAL_SKILLS\n$IGNORE_LIST\n$KNOWN_GAPS" | sort -u | grep -v '^$')

UNKNOWN_REFS=0
WARNING_REFS=0
UNKNOWN_LIST=""
echo ""
echo "→ Анализ ссылок:"
for ref in $ALL_REFS; do
  name="${ref#/}"
  [ ${#name} -lt 3 ] && continue

  if echo "$KNOWN_NAMES" | grep -qx "$name"; then
    if echo "$KNOWN_GAPS" | grep -qx "$name"; then
      echo "  ⚠ /$name — known gap (упомянут, не реализован)"
      WARNING_REFS=$((WARNING_REFS + 1))
    fi
    continue
  fi

  # Неизвестное slash-имя в backticks
  WHERE=$(grep -rl "\`/$name\`" --include="*.md" "$PACK_ROOT" 2>/dev/null | head -2 | sed "s|$PACK_ROOT/||" | tr '\n' ',' | sed 's/,$//')
  echo "  ✗ /$name — упомянут в [$WHERE], не в manifest"
  UNKNOWN_REFS=$((UNKNOWN_REFS + 1))
  UNKNOWN_LIST="$UNKNOWN_LIST /$name"
done

[ $UNKNOWN_REFS -eq 0 ] && [ $WARNING_REFS -eq 0 ] && echo "  ✓ (все ссылки соответствуют manifest)"
echo ""

# --- Итог ---
echo "=========================================="
TOTAL_FAIL=$((LOCAL_FAIL + GLOBAL_FAIL))

if [ $TOTAL_FAIL -gt 0 ]; then
  echo "✗ ПАК НЕ ГОТОВ К ПУБЛИКАЦИИ"
  echo "  Local fails:   $LOCAL_FAIL"
  echo "  Global fails:  $GLOBAL_FAIL"
  echo ""
  echo "  Почини дыры и запусти заново."
  exit 1
fi

if [ $UNKNOWN_REFS -gt 0 ]; then
  echo "✗ ПАК НЕ ГОТОВ К ПУБЛИКАЦИИ ($UNKNOWN_REFS неизвестных slash-команд)"
  echo ""
  echo "  Каждая такая ссылка — потенциальная дыра для ученика."
  echo "  Что делать для каждой:"
  echo "    1. Реализовать скилл → добавить в local_skills / global_skills"
  echo "    2. Это handoff на внешний агент → добавить в verify_ignore"
  echo "    3. Опечатка / убрать ссылку → поправить *.md"
  echo "    4. Запланированный, но не реализованный → добавить в known_gaps"
  echo ""
  echo "  Список неизвестных:$UNKNOWN_LIST"
  exit 1
fi

if [ $WARNING_REFS -gt 0 ]; then
  echo "✓ ПАК ГОТОВ К ПУБЛИКАЦИИ"
  echo "  Версия: $PACK_VERSION"
  echo "  Known gaps: $WARNING_REFS (документировано в manifest.yaml)"
else
  echo "✓ ПАК ГОТОВ К ПУБЛИКАЦИИ"
  echo "  Версия: $PACK_VERSION"
fi
echo "=========================================="
exit 0
