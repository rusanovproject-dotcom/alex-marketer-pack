# Alex Marketer — install manifest

Машиночитаемые метаданные для установки пака через скилл `/install-agent alex-marketer`.

---

## Metadata

```yaml
agent_id: alex-marketer
agent_name_human: Алекс Маркетолог
agent_name_in_chat: Алекс
short_role: Маркетолог-Хормози. Рынок > Оффер > Копия. Распаковывает ЦА через JTBD-фрейм (13 шагов на сегмент × 3-5 сегментов), собирает Grand Slam Offer, строит воронку. Двигает проект гипотезами. Режет хуйню, защищает сильные идеи.
trigger_keywords: [алекс, маркетолог, хормози, hormozi, маркетинг, ЦА, целевая аудитория, сегмент, сегменты, JTBD, jobs to be done, big job, jobstory, оффер, value equation, grand slam, позиционирование, воронка, лид-магнит, трипваер, лестница, продуктовая линейка, онбординг алекс, алекс онбординг, привет алекс, зашёл алекс, давай алекс, алекс представься, алекс начни, познакомимся, распакуй ЦА, распакуй проект, распакуй сегменты, jobstory клиента, что мешает клиенту, за что клиент платит, кто наш клиент, на кого работаем, провёл диагностику, был созвон, клиент оплатил, клиент отказался, проверь JTBD, свежий взгляд, аудит JTBD, критик JTBD]
version: 2.0.0
requires: []
provides_pipeline:
  - audience-jtbd-pipeline   # JTBD-распаковка ЦА (13 шагов на сегмент × 3-5 сегментов)
```

---

## Files to copy

Источник — `_agent-packs/alex-marketer/`, цель — `office/agents/alex-marketer/`. Копируется рекурсивно.

```yaml
files:
  - src: core.md
    dest: office/agents/alex-marketer/core.md
  - src: soul.md
    dest: office/agents/alex-marketer/soul.md
  - src: CLAUDE.md
    dest: office/agents/alex-marketer/CLAUDE.md
  - src: overrides.md
    dest: office/agents/alex-marketer/overrides.md
    preserve_if_exists: true
  - src: memory.md
    dest: office/agents/alex-marketer/memory.md
    preserve_if_exists: true   # сохраняем рабочие записи клиента
  - src: failures.md
    dest: office/agents/alex-marketer/failures.md
    preserve_if_exists: true   # сохраняем рабочие записи клиента
  - src: agent-state.md
    dest: office/agents/alex-marketer/agent-state.md
    preserve_if_exists: true   # сохраняем активную задачу клиента
  - src: knowledge/
    dest: office/agents/alex-marketer/knowledge/
    recursive: true
  - src: skills/
    dest: .claude/skills/
    recursive: true

# Templates копируются в папку агента — используются при первом запуске
templates:
  - src: templates/customers.template.md
    dest: office/agents/alex-marketer/templates/customers.template.md
  - src: templates/hypotheses.template.md
    dest: office/agents/alex-marketer/templates/hypotheses.template.md

# Шаблон папки распаковки — используется в /alex-onboarding Шаг 3.1
# (Алекс копирует _template-audience/ в projects/<slug>/ при выборе направления)
project_templates:
  - src: ../../projects/_template-audience/
    dest: projects/_template-audience/
    recursive: true
    preserve_if_exists: true
    description: |
      Шаблон папки проекта — копируется Алексом в `projects/<slug>/`
      при онбординге, когда клиент выбирает направление.
      Содержит: audience/, audience/segments/, inbox/, hypotheses.md и т.д.

# Опциональное расширение (модуль встреч) — не копируется автоматически,
# активируется отдельной командой /marketer-enable-meetings
extensions:
  - id: sales-meetings
    src: extensions/sales-meetings/
    dest: office/agents/alex-marketer/extensions/sales-meetings/
    auto_install: false
    activated_by: /marketer-enable-meetings
```

---

## Migration from v1.x (audience-pipeline) → v2.0 (JTBD)

Если у клиента уже стоит предыдущая версия Алекса с audience-pipeline скиллами:

```yaml
remove_skills:
  - .claude/skills/audience-stage
  - .claude/skills/audience-quick-capture
  - .claude/skills/audience-internet-research
  - .claude/skills/audience-validation
  - .claude/skills/audience-awareness-lite
  - .claude/skills/audience-resume
  - .claude/skills/audience-status
  - .claude/skills/audience-deliverable
  - .claude/skills/audience-check
  - .claude/skills/competitors-research
  - .claude/skills/marketer-revision
  - .claude/skills/marketer-checkin
  - .claude/skills/revise-segment
  - .claude/skills/unpack-product
  - .claude/skills/unpack-funnel
  - .claude/skills/product-build
  - .claude/skills/product-add
  - .claude/skills/funnel-build

remove_knowledge:
  - office/agents/alex-marketer/knowledge/audience-framework.md
  - office/agents/alex-marketer/knowledge/classics-compact.md
  - office/agents/alex-marketer/knowledge/hormozi-offer-market.md
  - office/agents/alex-marketer/knowledge/schwartz-awareness.md
  - office/agents/alex-marketer/knowledge/stage-lock.md
  - office/agents/alex-marketer/knowledge/pipeline-requirements.md
  - office/agents/alex-marketer/knowledge/voc-quality-rules.md  # если был установлен фикс apr-2026

# Сохраняем у клиента (preserve):
preserve:
  - office/agents/alex-marketer/memory.md
  - office/agents/alex-marketer/failures.md
  - office/agents/alex-marketer/agent-state.md
  - office/agents/alex-marketer/overrides.md
  - projects/<slug>/  # ВСЕ рабочие папки клиентских проектов
```

---

## Updates to existing files

```yaml
updates:
  - file: CLAUDE.md
    section: "## Обязательный layered include при старте"
    add_line: "@office/agents/alex-marketer/core.md"

  - file: office/AGENTS.md
    section: "## Активная команда"
    add_row: |
      | **Алекс Маркетолог** | Маркетолог-Хормози: распаковка ЦА через JTBD (13 шагов × N сегментов), оффер, воронка | *«привет алекс», «распакуй ЦА», «JTBD», «провёл диагностику»* |

  - file: office/agents/director/core.md
    section: "## Роутинг"
    add_rows: |
      | онбординг алекс, привет алекс, зашёл алекс, давай алекс, познакомимся, алекс представься | **Алекс** → `/alex-onboarding` (точка входа — 6 тактов первого контакта) |
      | распакуй ЦА, найди сегменты, кто наша ЦА, на кого работаем, JTBD, jobs to be done, big job, jobstory клиента | **Алекс** → `/jtbd` *(если онбординг не пройден — авто-route на `/alex-onboarding`)* |
      | проверь JTBD, аудит JTBD, свежий взгляд, критик JTBD | **Алекс** → `/jtbd-critic` *(в новом чате, чистый контекст)* |
      | провёл диагностику, был созвон, клиент оплатил, клиент отказался, вот транскрипт | **Алекс** → `/marketer-log-deal` *(требует активации модуля встреч)* |
```

---

## Post-install message to client

```
✅ Алекс в команде.

Когда захочешь начать — напиши **«привет алекс»** или **«онбординг алекс»**.
Я открою твой офис, посмотрю что у тебя живое, и вернусь с диагнозом
и одним острым вопросом — про точку приложения усилий, где деньги жирные
именно для тебя.

Никаких анкет, никаких длинных опросников. Просто живой разговор.

—

Что я делаю дальше (если интересно прочитать на ходу):

• Распаковываю твою целевую аудиторию — кто реально твой клиент,
  что у него болит, что он хочет на самом деле, через что покупает,
  что мешает купить. Работаю на твоих кейсах и фактуре, не на
  парсинге интернета.

• На выходе — один документ-карта по сегментам, готовый материал
  для оффера, лендинга, постов и работы с возражениями.

• Потом проверяю свежим взглядом в отдельной сессии — выловлю
  абстракции, противоречия, недосказанное.

—

Если есть продающие/диагностические созвоны: скажи «активируй встречи» —
добавлю в офис карточки клиентов и банк возражений из транскриптов.

Поехали — напиши «привет алекс».
```
