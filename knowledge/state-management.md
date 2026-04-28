# State management — Resume-pattern для JTBD-распаковки

JTBD-распаковка = `/jtbd` 13 шагов × 3-5 сегментов = много диалога. Один контекст не вытянет всё разом — модель деградирует. Resume-pattern разбивает работу на сессии с явной точкой восстановления.

---

## Структура сессий

| Сессия | Что делается | Время | Output |
|--------|--------------|-------|--------|
| **A — Discover** | Step 00 (диагностика) → 01a (factbase) → 01b (кластеризация сегментов) | ~1.5-2ч | Список 3-5 сегментов в `JTBD_анализ_<main>.md` |
| **B-N — Segment N** | Steps 02a → 10 для N-го сегмента (Big Job → jobStory → Точки А/Б → граф работ → Consideration Set → барьеры → Entry/Monetization → оценка) | ~2-2.5ч | Заполненный блок сегмента в `JTBD_анализ_<main>.md` |
| **C — Финал** | Step 11 (ранжирование) → 12 (механики ценности) → 13 (стратегические гипотезы) | ~1.5ч | Финальный документ |
| **D — Критик** | `/jtbd-critic` в **новом чате**, чистый контекст | ~30-60 мин | Правки БЫЛО / ПРЕДЛАГАЮ / ПРИЧИНА |

⚠️ N не строго 3-5 — клиент может проработать 1-2 сегмента и закрыть Stage 1, остальные в backlog.

---

## State-файл — точка восстановления

**Глобальный agent-state:** `office/agents/alex-marketer/agent-state.md`

Это единственный state-файл — всё что нужно для resume там. Без локального pipeline-progress (он избыточен — JTBD пишет прогресс прямо в `JTBD_анализ_<main>.md`).

### Формат `agent-state.md` (10 полей YAML)

```yaml
---
active_client: <имя клиента>          # кто владелец офиса
active_project: <slug>                 # папка projects/<slug>/
active_skill: /jtbd                    # текущий скилл (или null)
active_stage: 1                        # 1 (Audience-JTBD) | 2 | 3
active_step: 02a-extract-classify      # текущий Step внутри /jtbd
active_segment: <segment-slug>         # если в фазе углубления одного сегмента (B-N)
last_checkpoint: 2026-04-28 22:30      # когда последний раз обновили
interrupted: false                     # true если прервали посреди сессии
interrupted_reason: null               # описание если interrupted: true
resume_hint: null                      # что делать в следующей сессии если interrupted
onboarding_completed: true             # пройден ли /alex-onboarding
focus_direction: "основной продукт"   # выбранное направление
project_created_at: 2026-04-28 21:00   # когда создали papke projects/<slug>/
---
```

**Правило interrupted:** при ЛЮБОМ прерывании (клиент ушёл в другую тему / сессия закончилась / клиент сорвал в Stage 2-3) — Алекс **обязан** перед ответом на новую тему записать `interrupted: true` + причину + resume_hint. Иначе следующая сессия не сможет вернуться правильно.

---

## Алгоритм при старте `/jtbd`

```
Pre-flight Шаг 0 — Resume Check:
  cat office/agents/alex-marketer/agent-state.md

  if active_skill == "/jtbd" and active_step != null:
    # Сессия в процессе
    Сказать клиенту:
      «Распаковка уже в процессе. Текущий шаг: {active_step}
       (сегмент: {active_segment}).
       Last checkpoint: {last_checkpoint}.

       (a) Продолжить с этого шага — Stop+wait
       (b) Начать заново (старый JTBD_анализ_<main>.md → _archive/) — Stop+wait
       (c) Закрыть досрочно — записать что есть как Stage 1»
  else:
    # Свежий старт — Step 00
    обновить agent-state.md: active_skill: /jtbd, active_step: 00-entry-and-diagnostics
```

---

## Обновление state в каждой сессии

После каждого Step — Алекс **обязан** обновить `agent-state.md`:

- `active_step` ← следующий ожидаемый шаг
- `last_checkpoint` ← timestamp now
- `active_segment` ← если перешли на конкретный сегмент в фазе B
- `interrupted: false` (если всё ок) или `true` + `resume_hint` (если прервали)

---

## Кэширование артефактов в файлы — не в контекст

Цитаты живут в диалоге → попадают в context window. **Закон:** после каждого блока интервью — сразу записывать в `JTBD_анализ_<main>.md` (соответствующая секция сегмента), а в чате держать только короткое подтверждение `📌 записано (N цитат)`.

Один токен в чате вместо тысячи. Освобождает контекст для следующих шагов.

---

## Чек «не пора передохнуть»

После 3 stop+wait подряд или 90 минут диалога — Алекс пишет:

> *«Накопилось N цитат, M гипотез, J решений. Контекст забивается — давай сохраним прогресс и продолжим новой сессией. Нажми `/clear` когда готов — в новом чате прочитаю agent-state.md и продолжим с {next_step}.»*

Это safeguard от деградации.

---

## Anti-patterns

- ❌ Делать всю распаковку (8-12 часов) одной сессией без `/clear`
- ❌ Держать цитаты в контексте чата вместо записи в `JTBD_анализ_<main>.md`
- ❌ Не обновлять `agent-state.md` после каждого Step
- ❌ При прерывании не записать `interrupted: true` + `resume_hint`
- ❌ Не делать resume check в Pre-flight Шаг 0 при перезапуске `/jtbd`

---

## Связь со скиллами Алекса

- `/alex-onboarding` — пишет в agent-state.md `onboarding_completed: true` + `focus_direction` + `active_project`
- `/jtbd` — обновляет `active_step` после каждого Step, читает agent-state.md в Pre-flight Шаг 0 (resume check)
- `/jtbd-critic` — запускается в **новом чате**, читает `JTBD_анализ_<main>.md` готовый, agent-state.md не трогает (свежий контекст для свежего взгляда)
- `/marketer-log-deal` — пишет в `customers/` (если активирован модуль встреч), agent-state.md не трогает
