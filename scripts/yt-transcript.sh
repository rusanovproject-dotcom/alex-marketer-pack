#!/usr/bin/env bash
# Тянет русские субтитры YouTube-видео в чистый текст.
# Использование: yt-transcript.sh <video_id|url> [outdir]
#
# Коды выхода — РАЗНЫЕ причины, не сваленные в одну:
#   0  — текст на stdout
#   2  NO_SUBS        — yt-dlp отработал, субтитров у ролика нет
#   3  NETWORK_TIMEOUT— не уложился в 120 секунд
#   4  BLOCKED        — площадка не пустила (429, «Sign in to confirm you're not a bot»)
#   5  TOOL_MISSING   — нет yt-dlp
# Причина печатается в stderr вместе с последней строкой ошибки yt-dlp.
#
# ВАЖНО для того, кто читает вывод: коды 3, 4 и 5 — это отказ инструмента, а НЕ факт о рынке.
# Пересказывать их владельцу как «в нише мало разборов» запрещено.

set -uo pipefail

VID="${1:?нужен video id или url}"
OUT="${2:-$(pwd)}"
mkdir -p "$OUT"

ID="$(printf '%s' "$VID" | sed -E 's#.*(v=|youtu\.be/|shorts/)([A-Za-z0-9_-]{11}).*#\2#')"
[ -z "$ID" ] && ID="$VID"

cd "$OUT" || exit 1

if ! command -v yt-dlp >/dev/null 2>&1; then
  echo "TOOL_MISSING:yt-dlp — поставь: brew install yt-dlp (или pipx install yt-dlp)" >&2
  exit 5
fi

# На macOS без coreutils нет ни timeout, ни gtimeout. Безусловный вызов `timeout`
# возвращал 127, yt-dlp не запускался вообще, и скрипт печатал NO_SUBS на всё подряд.
if command -v timeout >/dev/null 2>&1; then
  TIMEOUT_CMD=(timeout 120)
elif command -v gtimeout >/dev/null 2>&1; then
  TIMEOUT_CMD=(gtimeout 120)
else
  TIMEOUT_CMD=()
fi

ERRLOG="$(mktemp -t yt-transcript.XXXXXX)"
trap 'rm -f "$ERRLOG"' EXIT

# Раскрытие через ${a[@]+"${a[@]}"} — иначе пустой массив под `set -u` валит bash 3.2,
# который на macOS штатный. Проверено живым прогоном.
${TIMEOUT_CMD[@]+"${TIMEOUT_CMD[@]}"} yt-dlp --skip-download \
  --write-auto-subs --write-subs \
  --sub-langs "ru,ru-orig,ru-RU" --sub-format "vtt" \
  --extractor-args "youtube:player_client=android_vr,web" \
  -o "%(id)s.%(ext)s" \
  "https://www.youtube.com/watch?v=$ID" >/dev/null 2>"$ERRLOG"
RC=$?

LAST_ERR="$(grep -E 'ERROR|WARNING' "$ERRLOG" 2>/dev/null | tail -1)"

if [ "$RC" -eq 124 ]; then
  echo "NETWORK_TIMEOUT:$ID — 120 секунд не хватило. Это отказ инструмента, не вывод о рынке." >&2
  exit 3
fi

if grep -qE '429|Too Many Requests|Sign in to confirm|not a bot|blocked' "$ERRLOG" 2>/dev/null; then
  echo "BLOCKED:$ID — площадка не пустила. Это отказ инструмента, не вывод о рынке." >&2
  echo "  ${LAST_ERR:-нет строки ошибки}" >&2
  echo "  Лечится куками авторизованного аккаунта (--cookies-from-browser) или сменой адреса." >&2
  exit 4
fi

F="$(ls -1 "$ID"*.vtt 2>/dev/null | head -1)"
if [ -z "$F" ]; then
  if [ "$RC" -ne 0 ]; then
    echo "TOOL_MISSING:$ID — yt-dlp вышел с кодом $RC, файла нет. Это отказ инструмента, не вывод о рынке." >&2
    echo "  ${LAST_ERR:-нет строки ошибки}" >&2
    exit 5
  fi
  echo "NO_SUBS:$ID — yt-dlp отработал, субтитров у ролика нет." >&2
  exit 2
fi

# vtt -> чистый текст без таймкодов и дублей
python3 - "$F" <<'PY'
import re, sys
raw = open(sys.argv[1], encoding='utf-8', errors='ignore').read()
lines, prev = [], None
for ln in raw.splitlines():
    if '-->' in ln or ln.startswith(('WEBVTT','Kind:','Language:')) or not ln.strip():
        continue
    t = re.sub(r'<[^>]+>', '', ln).strip()
    if not t or t == prev:
        continue
    lines.append(t); prev = t
text = ' '.join(lines)
text = re.sub(r'\s+', ' ', text)
print(text)
PY
