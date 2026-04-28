# State management — Resume-pattern для длинных пайплайнов

Полный пайплайн `/audience-stage` = 6-7 сессий по 1.5-2ч. Один контекст не вытянет 7000+ строк диалога — модель деградирует. Resume-pattern разбивает работу на сессии с явной точкой восстановления.

Краткая сводка в `audience-stage/SKILL.md`. Полный протокол — здесь.

---

## Структура сессий полной распаковки

| Сессия | Что делается | Время | Output |
|--------|--------------|-------|--------|
| **1A — Discover** | Шаги 1-3 + двойное интервью + money-map + hypotheses + Discovery → ТОП-3 | ~2ч | `NORTH-STAR.md` + `_state/pipeline-progress.md` |
| **1B-N — Unpack #N** | `/segments-unpack {slug}` для N-го сегмента (N = 1..3) | ~2ч | `segment-portrait.md` секции 0,1,2,5,6 |
| **1C-N — Awareness #N** | `/segments-awareness {slug}` для каждого | ~1.5ч × N | секции 3,4,7,8 + `segment-core.md` |

⚠️ N не строго 3 — клиент может проработать 1-2 сегмента и закрыть Stage 1 (3-й в backlog).

---

## State-файл — точка восстановления

**Локальный pipeline-state:** `projects/<main>-audience/_state/pipeline-progress.md`
**Глобальный agent-state:** `office/agents/alex-marketer/agent-state.md`

Связь: agent-state.md (что я делаю сейчас) ссылается на pipeline-progress.md (где в pipeline).

### Формат `pipeline-progress.md`

```markdown
# Pipeline Progress — Stage 1 Audience

**Started:** YYYY-MM-DD HH:MM
**Last update:** YYYY-MM-DD HH:MM
**Current session:** 1A | 1B-1 | 1B-2 | 1B-3 | 1C-1 | 1C-2 | 1C-3 | DONE
**Mode:** established | early-stage | greenfield

## Completed steps
- [x] 1A — discover ТОП-3 (NORTH-STAR.md заполнен)
- [ ] 1B-1 — unpack hot-сегмента
- [ ] ...

## Active state (для resume)
- Hot slug: {h-slug}
- Warm slug: {w-slug}
- Cold slug: {c-slug}
- Last completed: {что закончили}
- Next action: {что делать в следующей сессии}

## Context для следующей сессии
- Какие файлы прочитать первым делом
- Ключевые находки (3-5 буллетов)
- Открытые вопросы
```

---

## Алгоритм при старте `/audience-stage`

```
Pre-flight Шаг 0 — Resume Check:
  if [ -f "projects/<main>-audience/_state/pipeline-progress.md" ]; then
    # Сессия в процессе — НЕ запускать заново
    cat _state/pipeline-progress.md
    Сказать клиенту:
      «Stage 1 уже в процессе. Текущая сессия: {1B-2 — unpack warm}.
       Last completed: {hot-сегмент распакован}.
       Next action: {запустить /segments-unpack {warm-slug}}.

       (a) Продолжить с этого места — Stop+wait
       (b) Начать заново (старая папка → _archive/) — Stop+wait
       (c) Завершить разбор досрочно — отметить DONE»
  else
    # Свежий старт — Шаг 1 (создать папку)
    создать pipeline-progress.md в Шаге 1
  fi
```

---

## Обновление state в каждой сессии

После каждого Шага — Алекс **обязан** обновить:

**`pipeline-progress.md`:**
- Отметить шаг как `[x]` completed
- Обновить `Last update` timestamp
- Записать `Last completed` и `Next action`
- 3-5 ключевых находок в «Context для следующей сессии»

**`agent-state.md`** (глобальный):
- `active_step: <текущий>`
- `last_checkpoint: <date>`
- `interrupted: false` (если всё ок) или `true` + `resume_hint` (если прервали)

---

## Кэширование артефактов в файлы — НЕ в контекст

Сейчас цитаты живут в диалоге → попадают в context window. **Закон:** после каждого блока интервью — сразу записывать в `segment-portrait.md` или `voice-of-customer.md`, а в чате держать только `📌 записано (43 цитаты)`.

Один токен в чате вместо тысячи. Освобождает контекст для следующих шагов.

---

## Чек «не пора передохнуть»

После 3 stop+wait подряд или 90 минут диалога — Алекс пишет:

> *«Накопилось N цитат, M гипотез, J решений. Контекст забивается — давай сохраним прогресс и продолжим новой сессией с `/audience-stage --resume`. Нажми `/clear` когда готов.»*

Это safeguard от деградации.

---

## Anti-patterns

- ❌ Делать всю распаковку (4-6 часов) одной сессией без `/clear`
- ❌ Держать цитаты в контексте чата вместо записи в файл
- ❌ Не обновлять `pipeline-progress.md` после каждого Шага
- ❌ Забыть про resume check в Pre-flight Шаг 0
- ❌ Не синхронизировать локальный pipeline-progress с глобальным agent-state

---

## Связь со скиллами `/audience-resume`, `/audience-status`, `/audience-check`

- `/audience-status` — read-only, читает оба state-файла, возвращает где мы по плану vs реальности
- `/audience-check` — auto-call каждые 5 ходов, проверяет на drift, обновляет agent-state.md
- `/audience-resume` — после `/clear`, поднимает контекст из pipeline-progress.md, запускает нужный скилл с `--resume`
