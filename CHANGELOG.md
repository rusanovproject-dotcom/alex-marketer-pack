# alex-marketer-pack — CHANGELOG

Соблюдаем [Semantic Versioning](https://semver.org/lang/ru/).

---

## [2.1.0] — 2026-05-12

### 🔴 Критический фикс зависимостей

В v2.0 пак ссылался на `/custdev` как **обязательный путь** при `has_paying_customers: false`, но сам скилл физически отсутствовал в репозитории. Ученики упирались в тупик.

### Добавлено

- **`/custdev` теперь в паке** — `.claude/skills/custdev/SKILL.md`. Глобальный скилл, доступен как slash-команда во всём workspace после установки.
- **`/core-offer` v0.2** — `skills/core-offer/`. Stage 0-7 полный пайплайн упаковки центральной фразы: щёлк → направление vs продукт → 4 раунда штурма (Reason to Want) → объединённый раунд доказательств (Reason to Believe) → было/стало → 3 формы оффера.
- **`manifest.yaml`** — декларативное описание зависимостей пака (local_skills, global_skills, preserved_user_files, known_gaps).
- **`scripts/verify-pack.sh`** — проверка целостности перед публикацией. Грепает все `/skill-name` ссылки в `*.md` и сверяет с manifest. Запускается мейнтейнером.
- **`scripts/update-pack.sh`** — апдейт пака у ученика. Скачивает свежую версию, делает diff, бэкап, применяет с сохранением клиентских данных (overrides.md, projects/, customers/, etc).
- **`.alex-pack-baseline/`** — папка с эталонными версиями core.md/soul.md от последнего апдейта. Используется чтобы заметить если ученик правил core.md руками.
- **`CHANGELOG.md`** — этот файл.
- **`SPEC-v2.1.md`** — лог архитектурных решений.

### Изменено

- **`core.md` синхронизирован с актуальным workspace** — Stage 2 переведена из «не подключена» в «закрыта через `/core-offer`». Pipeline расширен, обновлены триггеры маршрутизации и Stage Lock. Связки с Producer/Copywriter/Designer обновлены под новый `core-offer.md`.
- **README.md** — добавлена секция «Обновление пака» с командой `bash scripts/update-pack.sh`.

### Известные дыры (не блокирующие)

- **`/marketer-enable-meetings`** — упомянут в `core.md`, `install.md`, `README.md`, `extensions/sales-meetings/CUSTOMER-INTELLIGENCE.md` как активатор опционального модуля Customer Intelligence. Физически скилл не реализован. Записан в `manifest.yaml` → `known_gaps:`. В следующей версии — либо реализуем, либо вычищаем упоминания.

### Миграция с v2.0 → v2.1

**Если у тебя пак v2.0 уже установлен:**

```bash
cd ~/path/to/your/office/agents/alex-marketer
bash scripts/update-pack.sh
```

Если `scripts/update-pack.sh` не у тебя локально (это новый файл в v2.1) — скачай и запусти:

```bash
curl -fsSL https://raw.githubusercontent.com/rusanovproject-dotcom/alex-marketer-pack/main/scripts/update-pack.sh -o /tmp/update-pack.sh
bash /tmp/update-pack.sh ~/path/to/your/office/agents/alex-marketer
```

Скрипт:
- Скачает свежий пак, сравнит с твоим
- Покажет что изменится
- Создаст бэкап старой версии в `.alex-pack-backups/`
- Применит апдейт, **сохранив**: `overrides.md`, `agent-state.md`, `memory.md`, `failures.md`, `projects/`, `customers/`, `inbox/`

---

## [2.0.0] — 2026-04-28

### Первая публичная версия

JTBD-распаковка для учеников. 61 файл, 4 скилла:
- `/alex-onboarding`
- `/jtbd`
- `/jtbd-critic`
- `/marketer-log-deal`

📚 [README](README.md) | 🚀 [Install](install.md)
