# Установка модуля Sales Meetings

## Триггер активации

Владелец говорит:
- «у меня есть продающие созвоны»
- «активируй встречи»
- «подключи модуль созвонов»
- `/marketer-enable-meetings`

ИЛИ автоматически: маркетолог при первой обработке транскрипта встречи сам предлагает: «Вижу первый транскрипт — у тебя бизнес со созвонами? Активирую модуль встреч?»

## Что делает скилл `/marketer-enable-meetings`

1. **Копирует структуру в проект:**
   ```
   projects/<main>/customers/
       ├── INDEX.md                ← из templates/customers-INDEX.template.md
       └── refusals/.gitkeep
   ```

2. **Добавляет секцию в `funnel/scripts.md`** (создаёт файл если не существует):
   ```markdown
   ## Банк возражений
   <!-- AUTO:objections — наполняется из customers/{name}/*-diag.md и *-deal.md -->
   ```

3. **Добавляет строки в `metrics.md`** (секция Воронка):
   ```markdown
   | Diagnostic calls | — | — | — |
   | Конверсия Diag → Deal | — % | — | — |
   | Средняя actuality оффера | —/10 | — | критично если <7 |
   ```

4. **Регистрирует триггеры** для `core.md` маркетолога:
   ```markdown
   ## Активные расширения
   - sales-meetings ON → `/marketer-log-deal`, `/parse-meeting`
   ```

5. **Записывает в `CHANGELOG.md` проекта**:
   ```
   ## YYYY-MM-DD — активирован модуль Sales Meetings
   Добавлено: customers/, секция возражений в funnel/scripts.md, метрики Diag→Deal.
   ```

6. **Сообщает владельцу**:
   > Готово. Теперь:
   > — После каждой встречи скажи «провёл диагностику с {имя}» — заведу карточку
   > — Кинь транскрипт — разберу в 7 артефактов параллельно
   > — Цифры по диагностикам и actuality оффера автоматически в metrics.md

## Шаблоны (templates/)

| Шаблон | Куда копируется при активации |
|--------|-------------------------------|
| `customers-INDEX.template.md` | `customers/INDEX.md` |
| `customer-summary.template.md` | `customers/{name}/_summary.md` (при первой встрече с клиентом) |
| `customer-card-diag.template.md` | `customers/{name}/{date}-diag.md` (по триггеру `/marketer-log-deal`) |
| `customer-card-deal.template.md` | `customers/{name}/{date}-deal.md` (по триггеру оплаты) |
| `transcript-summary.template.md` | `customers/{name}/transcripts/{date}-{type}.md` (по триггеру `/parse-meeting`) |
| `refusal.template.md` | `customers/refusals/{name}-{date}.md` (по триггеру отказа) |

## Деактивация

Скилл `/marketer-disable-meetings`:
- НЕ удаляет `customers/` (архив остаётся)
- Снимает регистрацию триггеров `/marketer-log-deal`, `/parse-meeting`
- Записывает в CHANGELOG

## Зависимости

Модуль работает поверх базового скелета `projects/_template/`. Требует наличия:
- `audience/voice-of-customer.md` (для цитат ЦА из транскриптов)
- `brand/expert-bank.md` (для голоса владельца)
- `brand/competitors.md` (для упоминаний)
- `hypotheses.md` (для идей в Backlog из встреч)
- `metrics.md` (для цифр)
- `inbox/_raw/transcripts/` (буфер до классификации)

Все эти файлы есть в базовом скелете — модуль не требует дополнительной установки.
