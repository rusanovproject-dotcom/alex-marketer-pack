# Student Checklist

## Предварительные условия

- Пройден предварительный research-гайд: https://research-evidence-guide.vercel.app/
- В папке проекта есть `PROJECT.md`, `MARKET-RESEARCH.md`, `MARKETING-BRIEF.md`.
- Эти три файла считаются read-only evidence-входом.
- Ты готов принять решение владельца или честно оставить `waiting_owner`.

## Если вход неполный

Если одного из трёх входных файлов нет: STOP: handoff не готов.

не продолжай личный post-research route и не запускай команду recovery. Выбери observer/demo/recovery:

- observer: смотри demo-разбор ведущего и не меняй свою папку проекта.
- demo: тренируй маршрут на готовых demo-файлах урока.
- recovery: Вернись к research-гайду, восстанови недостающий файл и только после этого запускай handoff-команду.

Если готового research-handoff не будет до конца эфира, закончи вход через research-гайд или явно выбери старый discovery-маршрут. Не изображай, что handoff готов.

## Команда research-handoff

```text
Проведи меня от готового research к решению по воронке.
Папка проекта: <папка проекта>.
Сначала прочитай PROJECT.md, MARKET-RESEARCH.md и MARKETING-BRIEF.md как read-only evidence-вход.
Новый research не начинай.
Покажи выбранный сегмент, 3–5 evidence anchors и критические gaps.
После моего подтверждения создай или обнови MARKET.md и GROWTH-PLAN.md.
```

Эта команда читает PROJECT.md, MARKET-RESEARCH.md, MARKETING-BRIEF.md до любого решения, запрещает новый research и просит агента не повторять базовый сбор вводных.

## Ожидаемый итог: GROWTH-PLAN.md

- `MARKET.md` — нормализованный слой evidence с 3–5 anchors и ссылками на входные файлы.
- `GROWTH-PLAN.md` — экономика, одно ограничение, сравнение механик, решение владельца, первый тест и handoff.

## Маршрут решения

| Блок | Что должно произойти | Мини-проверка |
|---|---|---|
| Аудит входа | Агент прочитал три входных файла | Названы сегмент, anchors, gaps |
| Экономика | Проверена экономика назад | Есть целевая прибыль, заказы, заявки, CPL |
| Evidence anchors | Выбраны 3–5 evidence anchors | У каждого anchor есть файл-источник и вес |
| Ограничение | Названо одно главное ограничение | Нет списка равноправных проблем |
| Сравнение | Сравнены минимум три механики | У каждой есть fit, risk, first metric |
| Решение | Владелец принял или отложил выбор | Есть `owner_approved` и причина |
| Тест | Решение превращено в проверку | Есть baseline, target, дата и stop criteria |
| Передача | Следующий consumer получает контекст | Нет повторного базового интервью |

## Команда recovery

Команда recovery не используется при неполном bundle. Используй её только после подтверждённого research-handoff bundle, когда три входных файла уже есть и маршрут нужно продолжить с сохранённого состояния.

```text
Продолжи research-handoff маршрут в той же папке проекта.
Сначала прочитай agent-state.md, PROJECT.md, MARKET-RESEARCH.md, MARKETING-BRIEF.md, MARKET.md и GROWTH-PLAN.md.
Новый research не начинай.
Не повторяй уже заполненное интервью.
Покажи, какой блок следующий, какие gaps остались и какой файл будет изменён.
```

## Самопроверка GROWTH-PLAN.md

- Экономика: цель прибыли после маркетинга, бюджет, маржа, заказы, заявки, допустимый CPL.
- Anchors: 3–5 evidence anchors со ссылками на `PROJECT.md`, `MARKET-RESEARCH.md`, `MARKETING-BRIEF.md`.
- Ограничение: ровно одно главное ограничение.
- Сравнение: минимум три механики, у каждой есть fit, risk и first metric.
- Решение владельца: `owner_approved` записан вместе с причиной.
- Проверка: тест на 7–14 дней с baseline, target, датой проверки и стоп-критерием.
- Передача: next command запрещает повторное базовое интервью.

## Handoff в quiz-funnel

Передавай в `quiz-funnel` только если в `GROWTH-PLAN.md` выбран диагностический квиз и владелец принял решение.

Минимальный контракт:

```text
Consumer: quiz-funnel
Read first: PROJECT.md, MARKET.md, GROWTH-PLAN.md
Do not repeat: business model, target profit, selected segment, central offer, current bottleneck, funnel choice
Ask only: missing fields required for quiz outcomes, questions and entry offer
```
