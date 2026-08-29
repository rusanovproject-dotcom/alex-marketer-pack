# Marketer — install manifest

Машиночитаемые метаданные для установки пака через скилл `/install-agent marketer`.
Скилл читает этот файл, копирует файлы по указанным путям, и вставляет указанные строки в базовые конфиги офиса.

---

## Metadata

```yaml
agent_id: marketer
agent_name_human: Маркетолог
agent_name_in_chat: Алекс
short_role: |
  Маркетолог-навигатор. Находит точку приложения усилий, где деньги жирные именно
  для этого бизнеса, и доводит её до цифры. Сам идёт в мир за фактурой (сайт, канал,
  ниша, конкуренты) вместо анкеты — приходит с догадкой о бизнесе на подтверждение,
  а не с вопросником. Семь тактов: физика и точка → деньги назад (обратная воронка
  от прибыли, предельный CPL) → спрос и сегменты → голос рынка → конкуренты и
  свободное место → обещание и продуктовая лестница → путь клиента с узким местом →
  гипотеза с критерием. Три закона: не выдумывай (внешняя сверка с источником),
  помечай вес знания 🟢🟡🔴⚪, ищи AI-рычаг с эффектом и сроком замера. Критик-гейт
  A-F вслух с цитатами, порог отдачи ≥ B.
trigger_keywords: [
  маркетолог, алекс, распакуй ЦА, сегменты, ICP, идеальный клиент, позиционирование,
  продуктовая лестница, ревизия маркетинга, где у меня деньги, сколько нужно лидов,
  посчитай воронку, узкое место, какую гипотезу проверяем, где здесь ИИ даст эффект,
  был созвон, вот транскрипт, конкуренты, с чем нас сравнивают, упакуй оффер,
  оцени оффер, разбери буллиты, какие воронки в моей нише, как в нише продают,
  кастдев без клиентов, поставил тебя — с чего начать, есть ли спрос, сколько ищут,
  частотность, вордстат, как это ищут, проведи меня от рынка до воронки,
  маркетинговый навигатор, подготовь проект к воронке,
  быстрый маркетинговый разбор для эфира
]
version: 3.2.0
requires: []
optional_mcp_servers: []
provides_pipeline:
  - onboard              # первый контакт, разведка вместо анкеты
  - mkt-recon            # такты 0-1: физика бизнеса + деньги назад
  - jtbd                 # такт 2: отбор и распаковка сегментов
  - wordstat-mining      # такт 2, слой спроса: частотность и язык поиска через Search API v2
  - voice-of-market       # такт 3: интервью, дословный банк, карточка покупателя
  - rivals               # такт 4: конкуренты, Gap Map, свободное место
  - core-offer           # такт 5: центральная фраза + продуктовая лестница + цена
  - offer-lab            # оценка и докрутка готового оффера (вне тактов)
  - niche-scan           # разведка ниши: как в ней вообще продают
  - synthetic-custdev    # кастдев без живых клиентов, честно 🔴
  - funnel               # такт 6: путь клиента, узкое место по Голдратту
  - growth-lab           # такт 7: гипотеза с критерием, AI-рычаг, еженедельный прогон
  - market-to-funnel     # сквозной учебный маршрут → PROJECT/MARKET/GROWTH-PLAN + handoff
```

**Что нового в 3.2.0:**
- 13-й навык `skills/market-to-funnel/SKILL.md`: быстрый/глубокий маршрут от экономики и
  доказательств рынка до принятого владельцем типа воронки;
- `templates/GROWTH-PLAN.template.md`: итоговое решение, первая проверка и контракт
  передачи сборщику без повторного базового интервью;
- четыре сквозных триггера добавлены в канон и генератор обёртки, точечный роутинг сохранён.

**Что нового в 2.0.0** (пересборка «Алекс 2.0» — сам идёт в мир за фактурой):
- 4 новых скилла: `onboard` (вход без анкеты), `niche-scan` (разведка воронок ниши по
  видео и статьям практиков со ссылками), `synthetic-custdev` (кастдев без клиентов),
  `offer-lab` (оценка и докрутка готового оффера и буллитов)
- Критик-гейт A-F вслух с цитатами вместо свободного self-check
- Три сквозных закона (внешняя сверка, вес знания, поиск AI-рычага) на все семь тактов
- Золотые файлы проекта (`PROJECT.md` / `MARKET.md` / `TRACK.md`) вместо разрозненных
  артефактов без единого паспорта

---

## Files to copy

Источник — `_agent-packs/marketer/`, цель — **одна папка `office/agents/marketer/`**.

**Модель установки: пак ложится зеркалом.** Весь пак копируется в `office/agents/marketer/`
офиса ученика с той же структурой, что у нас. Скиллы **остаются внутри агента**
(`office/agents/marketer/skills/`) и в `.claude/skills/` НЕ копируются и не регистрируются:
весь текст агента (таблица роутинга, семь тактов, ссылки на `knowledge/`, `templates/`,
`scripts/`) адресует их путями от своей папки. Разложи скиллы по `.claude/skills/` — и вся
таблица роутинга у ученика укажет в пустоту.

В `.claude/` попадает ровно один файл — обёртка субагента `.claude/agents/marketer.md`,
и её генерирует `scripts/build-wrapper.sh`, а не копирование.

```yaml
files:
  - src: core.md
    dest: office/agents/marketer/core.md
  - src: soul.md
    dest: office/agents/marketer/soul.md
  - src: CLAUDE.md
    dest: office/agents/marketer/CLAUDE.md
  - src: overrides.md
    dest: office/agents/marketer/overrides.md
    preserve_if_exists: true   # не затирать если пользователь уже правил
  - src: memory.md
    dest: office/agents/marketer/memory.md
    preserve_if_exists: true
  - src: failures.md
    dest: office/agents/marketer/failures.md
    preserve_if_exists: true
  - src: wins.md
    dest: office/agents/marketer/wins.md
    preserve_if_exists: true
  - src: agent-state-template.md
    dest: office/agents/marketer/agent-state-template.md
  - src: knowledge/
    dest: office/agents/marketer/knowledge/
  - src: skills/
    dest: office/agents/marketer/skills/   # НЕ в .claude/skills/ — см. модель установки выше
  - src: templates/
    dest: office/agents/marketer/templates/
  - src: scripts/
    dest: office/agents/marketer/scripts/

# agent-state.md (состояние активного проекта) НЕ входит в пакет — заводится из
# agent-state-template.md первым действием при первом обращении к агенту.
```

После копирования — сгенерируй обёртку субагента (нужен `Bash`):

```bash
bash office/agents/marketer/scripts/build-wrapper.sh
```

Скрипт кладёт `.claude/agents/marketer.md` — frontmatter (имя, описание с триггерами,
`tools`, модель) плюс полное тело `core.md` и якорь «моя папка — `office/agents/marketer/`».
Гонять после **каждой** правки `core.md`: обёртка сама изменения не подхватывает.

Старые имена команд, которые ученики знают по прошлым версиям (`jtbd`, `alex-onboarding`,
`marketer-funnel` и прочие), отдельно регистрировать **не нужно** — карта алиасов лежит
в `office/agents/marketer/CLAUDE.md`, и агент разводит их по своим скиллам сам.

---

## Updates to `office/AGENTS.md`

Найти канонический реестр `### Зарегистрированные субагенты` и обновить существующую
строку `marketer`. Если строки ещё нет — добавить её в эту таблицу. Если в конкретном
офисе нет такого реестра, не создавать вымышленную таблицу: пропустить интеграцию и
явно сообщить об этом в install-report.

```markdown
| `marketer` | Сегменты, ЦА/ICP, позиционирование, экономика, оффер и решение по воронке. 13 скиллов бандлом, включая `market-to-funnel` с входами discovery/research-handoff (обёртка ген. `scripts/build-wrapper.sh` → `.claude/agents/marketer.md`) | `office/agents/marketer/core.md` | opus |
```

---

## Updates to root `CLAUDE.md`

**НЕТ.** Корневой `CLAUDE.md` не редактируется. Текущая интеграция Маркетолога — строка
в `office/AGENTS.md` и сгенерированная обёртка `.claude/agents/marketer.md`.

---

## First-task suggestion

```yaml
first_task:
  suggestion: "С чего начать разбор моего бизнеса?"
  why: "Маркетолог сам сходит посмотреть сайт/канал и вернётся с догадкой о бизнесе на подтверждение — первый разбор будет через пару минут, не после анкеты из 20 вопросов."
  skill: null   # онбординг вшит в core (skills/onboard), отдельно вызывать не нужно
```

---

## Требования (опционально)

Маркетолог содержит 13 скиллов. 11 из 13 не требуют ни одной из двух опциональных
tool-backed зависимостей и работают «из коробки» на WebSearch/WebFetch и своих знаниях.
Один скилл (`niche-scan`, разведка воронок практиков по видео) умеет
дополнительно тянуть субтитры YouTube через `yt-dlp`:

```bash
brew install yt-dlp
```

Без него `niche-scan` пропускает видео-источники и работает по статьям и блогам.

Второй опциональный tool-backed скилл — `wordstat-mining`. Для автоматического режима
ему нужны API-ключ сервисного аккаунта Yandex Search API v2 и `folder_id` в локальном
`~/.secrets/wordstat.json`; без них используется ручной checklist. Ни `yt-dlp`, ни ключ
Wordstat не являются обязательными для установки остальных 11 скиллов.

---

## Post-install message to client

```
✅ Маркетолог (Алекс) в команде. Можно сразу разбирать проект.

Скажи «с чего начать» или расскажи в двух словах, чем занимаешься — он сам сходит
посмотрит сайт/канал/нишу и вернётся с догадкой о бизнесе: «вот что я понял — поправь,
где не прав». Спросит только то, чего снаружи не достать: сколько хочешь чистыми,
какая маржа, что происходит внутри.

Дальше — пиши что нужно:
- **«с чего начать»** — первый разбор проекта без анкеты
- **«где у меня деньги»** — обратная воронка от прибыли, сколько нужно лидов
- **«распакуй ЦА»** — сегменты, кто реально платит и за что
- **«конкуренты»** — с чем сравнивают, где свободное место
- **«упакуй оффер»** — центральная фраза + продуктовая лестница
- **«оцени оффер»** — жирность готового оффера и буллитов по 14 критериям
- **«какие воронки в моей нише»** — разведка практиков со ссылками на источники
- **«кастдев без клиентов»** — синтетические интервью, если живых клиентов ещё нет
- **«проведи меня от рынка до воронки»** — быстрый или глубокий сквозной маршрут до `GROWTH-PLAN.md`

После каждого разбора Маркетолог печатает вслух самооценку A-F с цитатами из своего же
текста и выносит развилку тебе — сам за тебя не решает.
```

---

## Manual install (если в офисе нет команды `/install-agent`)

Если ты не используешь `client-office-template` или скилл `/install-agent` не установлен — пакет можно поставить руками. Терминал, из корня твоего AI-офиса:

```bash
# 1. Убедись что пак лежит в _agent-packs/marketer (скопируй из своего
#    источника дистрибуции паков, если его там ещё нет)

# 2. Создать папки агента (всё живёт в одной папке, скиллы — внутри неё)
mkdir -p office/agents/marketer/knowledge
mkdir -p office/agents/marketer/templates
mkdir -p office/agents/marketer/scripts
mkdir -p office/agents/marketer/skills

# 3. Скопировать файлы агента
cp _agent-packs/marketer/CLAUDE.md                 office/agents/marketer/CLAUDE.md
cp _agent-packs/marketer/core.md                   office/agents/marketer/core.md
cp _agent-packs/marketer/soul.md                   office/agents/marketer/soul.md
cp _agent-packs/marketer/agent-state-template.md   office/agents/marketer/agent-state-template.md
cp -R _agent-packs/marketer/knowledge/*  office/agents/marketer/knowledge/
cp -R _agent-packs/marketer/templates/*  office/agents/marketer/templates/
cp -R _agent-packs/marketer/scripts/*    office/agents/marketer/scripts/

# 4. Шаблоны памяти — копировать только если их ещё нет
for f in memory failures wins overrides; do
  [ -f "office/agents/marketer/$f.md" ] || \
    cp "_agent-packs/marketer/$f.md" "office/agents/marketer/$f.md"
done

# 5. Скиллы — ВНУТРЬ папки агента, не в .claude/skills/
#    (весь текст агента адресует их путями от своей папки)
cp -R _agent-packs/marketer/skills/* office/agents/marketer/skills/

# 6. Сгенерировать обёртку субагента → .claude/agents/marketer.md
bash office/agents/marketer/scripts/build-wrapper.sh
```

Проверка, что установка легла верно (обе команды должны что-то вывести):

```bash
ls office/agents/marketer/skills/     # 13 папок скиллов
ls .claude/agents/marketer.md         # обёртка субагента
```

После копирования обнови строку `marketer` в `office/AGENTS.md` по инструкции выше.

После — просто скажи «с чего начать»: Маркетолог сам сходит посмотреть проект и
вернётся с догадкой на подтверждение. Дальше пиши.

---

## Uninstall (future)

Для будущей поддержки `/uninstall-agent marketer`. Реверс установки:

```yaml
uninstall:
  remove_folders:
    - office/agents/marketer/    # вместе со скиллами: они живут внутри агента
  remove_files:
    - .claude/agents/marketer.md   # сгенерированная обёртка — единственный след в .claude/
  # remove_skill_folders: НЕТ. Скиллы в .claude/skills/ не ставятся (см. модель установки),
  # сносить там нечего. Есть папки вроде .claude/skills/jtbd/ — это остатки старой установки
  # версии 1.x, снести их можно, но проверь глазами: там могли остаться правки ученика.
  remove_lines_from:
    - path: office/AGENTS.md
      match: "| `marketer` |"
  preserve:
    - projects/   # артефакты проекта владельца (PROJECT.md/MARKET.md/customers.md и т.д.), не трогать
```
