---
artifact: growth-plan
status: draft_for_validation
mode: fast
entry: <discovery | research_handoff>
updated: YYYY-MM-DD
project: <project name>
recommended_funnel: <quiz | consultation | direct | nurture | handling-fix>
owner_approved: false
---

# План роста

## Готовность фактуры

- Экономика: <🟢/🟡/⚪ — что известно и источник в PROJECT.md>
- Рынок: <🟢/🟡/⚪ — что известно и источник в MARKET.md>
- Критические пробелы: <что надо валидировать>

## Evidence anchors

| Evidence anchor | Источник (PROJECT.md / MARKET-RESEARCH.md / MARKETING-BRIEF.md) | Вес | Вывод для решения |
|---|---|---|---|
| <наблюдение или цитата> | <файл и раздел> | <🟢/🟡/🔴/⚪> | <что это меняет> |

## Главное ограничение

Главное ограничение: <одно ограничение и его метрика>

Основание: <ссылка на PROJECT.md/MARKET.md>

## Центральный оффер

<сегмент → работа → обещание → основание доверия; вес и источник>

## Решение по воронке

- Рекомендация: <механика>
- Почему подходит: <факты из PROJECT.md/MARKET.md>
- Ключевой риск: <риск>
- Первая метрика: <метрика>
- Решение владельца: <принято / отклонено / ждёт решения>

## Отвергнутые альтернативы

| Механика | Соответствие фактам | Ключевой риск | Первая метрика | Почему отвергнута |
|---|---|---|---|---|
| <вариант 1> | <PROJECT.md/MARKET.md> | <риск> | <метрика> | <причина> |
| <вариант 2> | <PROJECT.md/MARKET.md> | <риск> | <метрика> | <причина> |

## Карта воронки

| Этап | Действие клиента | Обещание/артефакт | Метрика перехода | Риск |
|---|---|---|---:|---|
| <этап> | <действие> | <что получает> | <метрика> | <риск> |

## Первая проверка

| Гипотеза | Метрика | Окно | Старт | Цель | Дата проверки | Стоп-критерий |
|---|---:|---|---:|---:|---|---|
| <проверяемая гипотеза> | <метрика> | 7–14 дней | <база> | <цель> | <YYYY-MM-DD> | <когда останавливаем> |

## Передача сборщику

- Consumer: <quiz-funnel | имя другого сборщика | future-builder>
- consumer_status: <available | conditional_unavailable>
- Если consumer отсутствует: `consumer_status: conditional_unavailable`.
- Read first: PROJECT.md, MARKET.md, GROWTH-PLAN.md
- Do not repeat: business model, target profit, selected segment, central offer, current bottleneck, funnel choice
- Ask only / missing inputs: <только отсутствующие поля для сборки>
- Acceptance result: <что именно принял владелец и дата>

## Следующая команда

<одна команда: передача сборщику или продолжение глубокого режима в той же папке>
