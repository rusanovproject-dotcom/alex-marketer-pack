#!/bin/bash
# update-pack.sh — обновление alex-marketer-pack у ученика.
# Запускается из корня офиса ученика:
#   bash update-pack.sh                       (обновляет в текущую папку)
#   bash update-pack.sh ~/workspace/office    (обновляет в указанную папку)
#
# Что делает:
#   1. Скачивает свежий пак из GitHub
#   2. Сравнивает версии (по manifest.yaml)
#   3. Показывает diff
#   4. Создаёт бэкап старой версии
#   5. Применяет rsync, сохраняя preserved_user_files
#   6. Копирует global_skills в .claude/skills/
#   7. Запускает verify-pack локально
#
# Зависимости: bash, git, rsync, curl. Никакого yq/python/jq.

set -e

PACK_REPO="https://github.com/rusanovproject-dotcom/alex-marketer-pack.git"
INSTALL_TARGET="${1:-$(pwd)}"
INSTALL_TARGET="$(cd "$INSTALL_TARGET" && pwd)"

echo "=========================================="
echo "  alex-marketer-pack — update"
echo "  Target: $INSTALL_TARGET"
echo "=========================================="
echo ""

# --- Скачиваем свежий пак ---
TMP_DIR=$(mktemp -d -t alex-marketer-pack-update.XXXXXX)
trap "rm -rf $TMP_DIR" EXIT

echo "→ Скачиваю свежий пак из GitHub..."
git clone --depth 1 --quiet "$PACK_REPO" "$TMP_DIR/pack" 2>&1 || {
  echo "✗ Не удалось скачать. Проверь интернет / доступность GitHub."
  echo "  Альтернатива: скачай zip-архив руками:"
  echo "  curl -L https://github.com/rusanovproject-dotcom/alex-marketer-pack/archive/refs/heads/main.zip -o /tmp/pack.zip"
  exit 1
}
echo "  ✓ Скачано"
echo ""

# --- Сверка версий ---
LOCAL_VERSION="unknown"
if [ -f "$INSTALL_TARGET/manifest.yaml" ]; then
  LOCAL_VERSION=$(grep -E '^version:' "$INSTALL_TARGET/manifest.yaml" | sed -E 's/^version:\s*//' || echo "unknown")
fi
REMOTE_VERSION=$(grep -E '^version:' "$TMP_DIR/pack/manifest.yaml" | sed -E 's/^version:\s*//')

echo "→ Версии:"
echo "  Установлено:   $LOCAL_VERSION"
echo "  В репозитории: $REMOTE_VERSION"
echo ""

if [ "$LOCAL_VERSION" = "$REMOTE_VERSION" ]; then
  echo "✓ У тебя последняя версия. Обновление не требуется."
  exit 0
fi

# --- Подгружаем preserved_user_files из свежего manifest ---
PRESERVED=$(awk '/^preserved_user_files:/,/^[a-z_]+:/' "$TMP_DIR/pack/manifest.yaml" \
  | grep -E '^\s+- ' | sed -E 's/^\s+- //')

# --- Показ diff (списком файлов) ---
echo "→ Что изменится:"
diff -rq "$INSTALL_TARGET" "$TMP_DIR/pack" 2>/dev/null \
  | grep -v "^Only in $INSTALL_TARGET" \
  | head -40 || true
echo ""

# --- Проверка если ученик правил core.md ---
if [ -f "$INSTALL_TARGET/core.md" ]; then
  if ! diff -q "$INSTALL_TARGET/core.md" "$TMP_DIR/pack/core.md" >/dev/null 2>&1; then
    # Сравним с тем core.md что был при предыдущем апдейте (если есть .alex-pack-baseline)
    BASELINE="$INSTALL_TARGET/.alex-pack-baseline/core.md"
    if [ -f "$BASELINE" ] && ! diff -q "$INSTALL_TARGET/core.md" "$BASELINE" >/dev/null 2>&1; then
      echo "⚠  ВНИМАНИЕ: ты правил core.md руками после прошлого апдейта."
      echo "   Апдейт перезапишет твои правки."
      echo "   Перенеси изменения в overrides.md перед продолжением."
      echo ""
      read -p "   Всё равно продолжить? (y/n) " -n 1 -r
      echo ""
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Отменено. Перенеси правки в overrides.md и запусти снова."
        exit 0
      fi
    fi
  fi
fi

# --- Подтверждение ---
read -p "→ Применить обновление с $LOCAL_VERSION до $REMOTE_VERSION? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Отменено."
  exit 0
fi

# --- Бэкап ---
BACKUP="$INSTALL_TARGET/.alex-pack-backups/$(date +%Y%m%d-%H%M%S)-v${LOCAL_VERSION}"
mkdir -p "$(dirname "$BACKUP")"
echo "→ Бэкап старой версии..."
rsync -a --quiet --exclude=".alex-pack-backups" "$INSTALL_TARGET/" "$BACKUP/" 2>/dev/null || {
  # Если первая установка — INSTALL_TARGET может быть пустым, бэкап не нужен
  rm -rf "$BACKUP"
  echo "  (пропущено — установка с нуля)"
}
[ -d "$BACKUP" ] && echo "  ✓ Бэкап: $BACKUP"
echo ""

# --- Сборка rsync excludes ---
# .claude/skills/ нужно класть НЕ внутрь пака, а в корень workspace.
# Поэтому исключаем из основного rsync и обрабатываем отдельно ниже.
RSYNC_EXCLUDES="--exclude=.git --exclude=.alex-pack-backups --exclude=.alex-pack-baseline --exclude=.claude"
for p in $PRESERVED; do
  # Если файл существует у ученика — добавляем в exclude
  if [ -e "$INSTALL_TARGET/$p" ] || [ -d "$INSTALL_TARGET/$p" ]; then
    RSYNC_EXCLUDES="$RSYNC_EXCLUDES --exclude=$p"
  fi
done

# --- Применяем апдейт основных файлов агента ---
echo "→ Применяю обновление основных файлов агента..."
rsync -a $RSYNC_EXCLUDES "$TMP_DIR/pack/" "$INSTALL_TARGET/"
echo "  ✓ Файлы агента обновлены"

# --- Глобальные скиллы — в корень workspace ---
# Ищем корень workspace: подъём по дереву до первой папки которая содержит .claude/
# или которая является корневым `office/`-родителем
WORKSPACE_ROOT=""
SEARCH_DIR="$INSTALL_TARGET"
while [ "$SEARCH_DIR" != "/" ] && [ "$SEARCH_DIR" != "$HOME" ]; do
  SEARCH_DIR="$(dirname "$SEARCH_DIR")"
  if [ -d "$SEARCH_DIR/.claude" ] || [ -d "$SEARCH_DIR/office" ]; then
    WORKSPACE_ROOT="$SEARCH_DIR"
    break
  fi
done

if [ -z "$WORKSPACE_ROOT" ]; then
  echo "  ⚠ Корень workspace не найден (нет родительской папки с .claude/ или office/)."
  echo "    Глобальные скиллы кладу в $INSTALL_TARGET/.claude/skills/"
  WORKSPACE_ROOT="$INSTALL_TARGET"
fi

if [ -d "$TMP_DIR/pack/.claude/skills" ]; then
  echo "→ Глобальные скиллы → $WORKSPACE_ROOT/.claude/skills/"
  mkdir -p "$WORKSPACE_ROOT/.claude/skills"
  for skill_dir in "$TMP_DIR/pack/.claude/skills/"*/; do
    [ -d "$skill_dir" ] || continue
    skill_name="$(basename "$skill_dir")"
    rsync -a "$skill_dir" "$WORKSPACE_ROOT/.claude/skills/$skill_name/"
    echo "  ✓ /$skill_name"
  done
fi

# --- Сохраняем baseline (для следующего апдейта — сравнить правил ли ученик) ---
mkdir -p "$INSTALL_TARGET/.alex-pack-baseline"
cp "$TMP_DIR/pack/core.md" "$INSTALL_TARGET/.alex-pack-baseline/core.md"
cp "$TMP_DIR/pack/soul.md" "$INSTALL_TARGET/.alex-pack-baseline/soul.md"
echo "  ✓ Baseline сохранён"
echo ""

# --- Verify локально ---
echo "→ Проверяю целостность установленного пака..."
if [ -f "$INSTALL_TARGET/scripts/verify-pack.sh" ]; then
  bash "$INSTALL_TARGET/scripts/verify-pack.sh" || {
    echo "⚠ Verify нашёл проблемы. Возможно, ты в кастомной структуре."
  }
fi
echo ""

echo "=========================================="
echo "✓ Обновление завершено: v$LOCAL_VERSION → v$REMOTE_VERSION"
[ -d "$BACKUP" ] && echo "  Бэкап: $BACKUP"
echo "=========================================="
