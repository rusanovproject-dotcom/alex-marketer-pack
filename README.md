# Алекс Маркетолог — пак для AI-офиса

Маркетолог-партнёр для твоего AI-офиса. Распаковывает целевую аудиторию через **JTBD-фрейм** (Jobs To Be Done), собирает Grand Slam Offer по Хормози, строит воронку. Голос живой, без AI-слопа. Не консультант со списком советов — **штурмит вместе**.

## Зачем JTBD (а не классический портрет ЦА)

Классическая сегментация работает с **демографией** (возраст, доход, профессия). JTBD работает с **причиной покупки** — какую работу клиент нанимает твой продукт сделать. Для **инфо-продуктов, услуг, экспертных программ, B2B** это даёт лендинг и оффер которые попадают в реальный мотив, а не в усреднённый портрет «успешный предприниматель 30-45 лет». Цитата клиента «у меня в голове каша» — точнее любой персоны.

**JTBD не оптимален** для импульсных и неосознанных покупок (еда, одежда, FMCG) — там работает классический подход с эмоцией и атрибутами. Для всего остального — JTBD точнее.

**Версия:** v2.0 (JTBD)
**Что нового vs v1.x:** переход с audience-pipeline (Internet-First) на JTBD (13 шагов на сегмент × 1-5 сегментов), новый скилл-критик `/jtbd-critic` (свежий взгляд в новом чате), Шаг 5.5 в онбординге — Алекс сам создаёт папку проекта.

---

## Что внутри

```
alex-marketer/
├── core.md              ← главная логика (читается при каждой сессии)
├── soul.md              ← характер
├── CLAUDE.md            ← layered-include точка
├── install.md           ← машиночитаемый манифест установки
├── memory.md            ← пустой шаблон (Алекс наполнит сам)
├── failures.md          ← пустой шаблон
├── overrides.md         ← пустой (для твоих кастомных правил поверх)
│
├── knowledge/           ← база знаний
│   ├── voice.md         ← как говорить с клиентом
│   ├── first-contact-protocol.md  ← 6 тактов первого контакта
│   ├── state-management.md
│   ├── hypothesis-system.md
│   ├── file-ownership.md
│   └── jtbd/            ← JTBD-методология (полная)
│       ├── methodology-core.md
│       ├── jtbd-handbook.md
│       ├── value-mechanics.md
│       ├── etalon-jobstories.md
│       ├── jtbd-interview-guide.md
│       ├── jtbd-extras.md
│       └── jtbd-handbook-chapters.md
│
├── skills/              ← 4 скилла
│   ├── alex-onboarding/ ← точка входа, 6 тактов первого контакта
│   ├── jtbd/            ← главный пайплайн, 13 шагов на сегмент
│   ├── jtbd-critic/     ← критик в новом чате (5 шагов проверки)
│   └── marketer-log-deal/ ← запись клиентских встреч (опционально)
│
├── extensions/
│   └── sales-meetings/  ← модуль клиентских встреч (активируется отдельно)
│
└── templates/
    ├── customers.template.md
    └── hypotheses.template.md
```

---

## Установка с нуля (если в офисе нет маркетолога)

1. **Клонировать пак рядом с офисом:**

   ```bash
   cd ~/path/to/your-office
   git clone https://github.com/<owner>/<repo>.git _temp/alex-marketer-pack
   ```

2. **Скопировать пак в офис:**

   ```bash
   cp -R _temp/alex-marketer-pack/. _agent-packs/alex-marketer/
   rm -rf _temp/alex-marketer-pack
   ```

3. **В Claude Code запустить установщик:**

   ```
   /install-agent alex-marketer
   ```

   Если такого скилла нет — установить вручную:

   ```bash
   # Папка агента
   mkdir -p office/agents/alex-marketer
   cp -R _agent-packs/alex-marketer/{core.md,soul.md,CLAUDE.md,knowledge,templates,extensions} \
         office/agents/alex-marketer/

   # Пустые рабочие файлы (Алекс сам наполнит)
   cp _agent-packs/alex-marketer/{memory.md,failures.md,overrides.md} office/agents/alex-marketer/
   touch office/agents/alex-marketer/agent-state.md

   # Скиллы — в Claude Code skills
   cp -R _agent-packs/alex-marketer/skills/. .claude/skills/
   ```

4. **Подключить в `CLAUDE.md` офиса:**

   В корневой `CLAUDE.md` добавить строку:
   ```
   @office/agents/alex-marketer/core.md
   ```

5. **Готово — позови Алекса:**

   ```
   привет алекс
   ```

   Он откроет офис, прочитает что есть, даст диагноз и спросит про направление.

---

## Миграция со старой версии (audience-pipeline → JTBD)

Если у тебя уже стоит предыдущая Алекс с audience-pipeline (`/audience-stage`, `/audience-internet-research` и т.д.):

### Что ты потеряешь
- Старые скиллы audience-pipeline (audience-stage, internet-research, validation, awareness-lite, resume, status, deliverable, check, competitors-research, marketer-revision, marketer-checkin, revise-segment, unpack-product, unpack-funnel, product-build, product-add, funnel-build)
- Knowledge: audience-framework, schwartz-awareness, classics-compact, pipeline-requirements, stage-lock, hormozi-offer-market

### Что сохранится
- Твоя `memory.md` — все рабочие записи Алекса
- Твоя `failures.md` — записи ошибок
- Твоя `agent-state.md` — активная задача
- Твой `overrides.md` — кастомные правила
- **Все папки проектов** (`projects/<slug>/`) — там твоя работа, ничего не трогаем

### Шаги миграции

1. **Сделай бэкап на всякий случай:**

   ```bash
   cd ~/path/to/your-office
   cp -R office/agents/alex-marketer ~/.alex-backup-$(date +%Y%m%d)
   cp -R .claude/skills ~/.claude-skills-backup-$(date +%Y%m%d)
   ```

2. **Удали старые скиллы и knowledge:**

   ```bash
   # Старые скиллы
   rm -rf .claude/skills/{audience-stage,audience-quick-capture,audience-internet-research,audience-validation,audience-awareness-lite,audience-resume,audience-status,audience-deliverable,audience-check}
   rm -rf .claude/skills/{competitors-research,marketer-revision,marketer-checkin,revise-segment}
   rm -rf .claude/skills/{unpack-product,unpack-funnel,product-build,product-add,funnel-build}

   # Старые knowledge
   rm -f office/agents/alex-marketer/knowledge/{audience-framework,classics-compact,hormozi-offer-market,schwartz-awareness,stage-lock,pipeline-requirements,voc-quality-rules}.md
   ```

3. **Скачай новый пак и положи рядом с офисом:**

   ```bash
   git clone https://github.com/<owner>/<repo>.git _temp/alex-pack
   ```

4. **Перезапиши пак (СОХРАНЯЯ memory/failures/agent-state/overrides):**

   ```bash
   # Безопасно перезаписываем — install.md явно помечает preserve_if_exists для рабочих файлов
   cp _temp/alex-pack/{core.md,soul.md,CLAUDE.md,install.md,README.md} _agent-packs/alex-marketer/
   cp -R _temp/alex-pack/knowledge/. _agent-packs/alex-marketer/knowledge/
   cp -R _temp/alex-pack/skills/. _agent-packs/alex-marketer/skills/
   cp -R _temp/alex-pack/extensions/. _agent-packs/alex-marketer/extensions/
   cp -R _temp/alex-pack/templates/. _agent-packs/alex-marketer/templates/

   # Убираем временную папку
   rm -rf _temp/alex-pack
   ```

5. **Установи новые файлы в офис (поверх старых, БЕЗ memory/failures/agent-state/overrides):**

   ```bash
   # Knowledge — полная замена
   cp -R _agent-packs/alex-marketer/knowledge/. office/agents/alex-marketer/knowledge/

   # Core — замена
   cp _agent-packs/alex-marketer/core.md office/agents/alex-marketer/core.md
   cp _agent-packs/alex-marketer/soul.md office/agents/alex-marketer/soul.md
   cp _agent-packs/alex-marketer/CLAUDE.md office/agents/alex-marketer/CLAUDE.md

   # Скиллы — установка новых
   cp -R _agent-packs/alex-marketer/skills/jtbd .claude/skills/
   cp -R _agent-packs/alex-marketer/skills/jtbd-critic .claude/skills/
   cp _agent-packs/alex-marketer/skills/alex-onboarding/SKILL.md .claude/skills/alex-onboarding/SKILL.md
   cp _agent-packs/alex-marketer/skills/marketer-log-deal/SKILL.md .claude/skills/marketer-log-deal/SKILL.md
   ```

6. **Проверь:**

   ```bash
   # должно быть 4 актуальных скилла
   ls .claude/skills/ | grep -E "(alex-onboarding|jtbd|jtbd-critic|marketer-log-deal)"

   # knowledge/jtbd/ существует
   ls office/agents/alex-marketer/knowledge/jtbd/

   # core.md содержит JTBD логику
   grep -c "JTBD" office/agents/alex-marketer/core.md
   ```

7. **Запусти Алекса в Claude Code:**

   ```
   привет алекс
   ```

   Если он начинает работать через `/jtbd` — миграция прошла успешно. Если ругается на отсутствие старых файлов — `agent-state.md` или `overrides.md` могут содержать ссылки на удалённые скиллы. Очисти их или скажи Алексу «начни заново».

---

## Что Алекс делает

### Точка входа: онбординг (6 тактов, 5-10 минут)

Алекс читает офис до первой реплики, потом:
1. Тёплое включение — наблюдения о том что в офисе уже есть
2. Объяснение роли — найти точку приложения усилий
3. Физика бизнеса (5 типов клиента)
4. Ревизия направлений
5. Выбор одного направления → создание папки `projects/<slug>/`
6. Запись `onboarding_completed: true` + переход в `/jtbd`

### Главный пайплайн: JTBD-распаковка (13 шагов на сегмент)

После онбординга — `/jtbd` ведёт через 13 шагов на каждый сегмент:

```
00. Диагностика и сбор фактуры
01a. Factbase
01b. Кластеризация сегментов (3-5)
─── per-segment: ───
02a. Extract & classify
02b. Ask & check
02c. Formulate Big Job
03. JobStory generate
04. JobStory check
05. Точки А/Б
06. Граф работ
07a. Consideration set
07b. Problems
08. Барьеры
09. Entry & Monetization Job
10. Оценка сегмента
─── общие: ───
11. Ранжирование сегментов
12. Механики ценности
13. Стратегические гипотезы
```

На выходе — единый документ `JTBD_анализ_<проект>.md` со всеми сегментами.

### Критик: `/jtbd-critic` (свежий взгляд в новом чате)

Отдельная сессия, чистый контекст. 5 шагов:
1. Флаги (5 типичных проблем)
2. Связи (между шагами)
3. Формат и единообразие
4. Абстракции и факт-чек
5. Аудит + 3 рекомендации

### Опционально: `/marketer-log-deal` (модуль встреч)

Активируется через `/marketer-enable-meetings`. Запись диагностических/продающих созвонов в карточки клиентов с цитатами, актуальностью оффера, банком возражений.

---

## Команда

Пак работает соло — не требует других агентов. Если в офисе есть Стратег / Дизайнер / Копирайтер — Алекс с ними координирует через файлы (`voice-of-customer.md`, `segment-core.md`).

---

## Структура папки проекта (создаётся автоматически)

При онбординге Алекс копирует `projects/_template-audience/` в `projects/<slug>/`:

```
projects/<slug>/
├── CLAUDE.md          ← минимальный контекст проекта
├── README.md
├── _state/            ← внутренняя память Алекса по проекту
├── _archive/
├── audience/          ← JTBD-распаковка ЦА
│   └── segments/      ← detail-файлы сегментов
├── deliverable/       ← готовые артефакты для ментора
├── inbox/             ← входящие материалы от клиента
│   └── _new/
├── hypotheses.md      ← реестр гипотез (макс 5 Active + 1 Key)
└── learnings.md
```

---

## Помощь

Если что-то не работает — позови Алекса в Claude Code и опиши проблему живой речью. Он скажет что упущено в установке.

Если хочешь предложить улучшение пака — issue или PR в этот репозиторий.

---

**Лицензия:** internal use only — пак для учеников AI-офисной программы.
