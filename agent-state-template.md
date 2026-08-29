---
active_client: null
active_project: null
active_skill: null
active_stage: null
active_step: null
active_segment: null
project_root: null
onboarding: false
takt2_critic_passed: false
takt2_reviewer_skipped: null
takt2_source: null
market_pipeline_entry: null
market_pipeline_entry_confirmed: false
market_pipeline_mode: null
market_pipeline_stage: 0
market_pipeline_status: idle
last_checkpoint: null
interrupted: false
interrupted_reason: null
resume_hint: null
---

# Алекс Маркетолог — состояние проекта (шаблон)

> Скопируй в `agent-state.md` и заполняй по ходу работы. Читаешь первым при старте
> любой задачи, до первой реплики владельцу. Файла `agent-state.md` нет — создаёшь
> его отсюда **первым действием**, молча.

## Поля

| Поле | Что кладём |
|---|---|
| `active_client` | имя или slug владельца офиса |
| `active_project` | slug проекта: папка `projects/<slug>/` (в этом офисе — хаб маркетинга) |
| `active_skill` | путь скилла в работе, например `skills/jtbd/SKILL.md`, или `null` |
| `active_stage` | номер такта 0-7 (см. таблицу тактов в `core.md`) |
| `active_step` | шаг внутри скилла, например `02a-разметка-сегментов` |
| `active_segment` | slug сегмента, если углубляемся в один конкретный |
| `project_root` | путь к папке проекта. Discovery-маршрут ведёт там `PROJECT.md`, `MARKET.md`, `TRACK.md`; подтверждённый research handoff начинает с read-only `PROJECT.md`, `MARKET-RESEARCH.md`, `MARKETING-BRIEF.md` и выводит производные `MARKET.md`/`GROWTH-PLAN.md` без prerequisite `TRACK.md`. В шаблоне `null` — папку заводит `skills/onboard/SKILL.md` первой discovery-сессией и записывает путь сюда. Путь записан, а папки по нему нет — стоп и один вопрос владельцу: переезд, новый проект или опечатка. Молча заводить новое или писать в старое одинаково запрещено |
| `onboarding` | пройден ли первый контакт. `false` (и в шаблоне тоже) — обычный discovery-вход идёт через `skills/onboard/SKILL.md`, а не через такт 0. Исключение: trigger `market-to-funnel` сначала выбирает `route`; для любого `research_handoff` onboarding не является гейтом и `onboard` не открывается. `true` — обычный маршрут: агент говорит, на каком рубеже проект, и предлагает продолжить с него; первая сессия не переигрывается. Новый проект у того же владельца — `onboard` в режиме «новый проект»: новая папка, новый `project_root`, старые файлы не трогаются и не переносятся |
| `takt2_critic_passed` | маркер закрытия такта 2 (`skills/jtbd/SKILL.md`, шаг 4). `true` — спрос подтверждён критиком: обещание такта 5 стоит на клиентах владельца. `false` / `null` / ветка `no_data` — обещание собирается и такт 5 идёт, но результат помечается 🔴 и вслух называется «стоит на рыночной фактуре, а не на твоих клиентах». Маркер не запирает вход, он определяет, с какой пометкой выходит обещание |
| `takt2_reviewer_skipped` | почему на отборе ТОП-3 сегментов не было ревьюера. `null` — ревьюер был, как и положено. `no_data` — пропущен по ветке «данных нет»: свежему взгляду не на чём стоять. Любое значение, кроме `null`, обязано быть проговорено владельцу вслух и продублировано строкой в файле сегментов |
| `takt2_source` | на чём стоит такт 2. `live` — живые платящие: интервью, переписки, выгрузки. `synthetic` — синтетический кастдев (`skills/synthetic-custdev/`), весь производный выход 🔴. `null` — такт 2 ещё не проходили. Значение `synthetic` произносится вслух первой фразой при каждой отдаче, где оно участвует |
| `market_pipeline_entry` | вход сквозного маршрута: `discovery`, `research_handoff` или `null`. Наличие трёх handoff-файлов позволяет поставить `research_handoff`, но само по себе не означает согласие владельца |
| `market_pipeline_entry_confirmed` | `false`, пока владелец явно не подтвердил актуальность `PROJECT.md`, `MARKET-RESEARCH.md`, `MARKETING-BRIEF.md`; только его ответ меняет поле на `true` |
| `market_pipeline_mode` | режим результата: `fast`, `deep` или `null`; это отдельное измерение от способа входа |
| `market_pipeline_stage` | этап сквозного маршрута `0`–`7`; до старта `0` |
| `market_pipeline_status` | `idle`, `in_progress`, `waiting_owner`, `draft_for_validation` или `complete` |
| `last_checkpoint` | когда последний раз обновляли, `YYYY-MM-DD HH:MM` |
| `interrupted` | `true`, если прервались посреди работы |
| `interrupted_reason` | одной строкой, почему прервались |
| `resume_hint` | что делать в следующей сессии: такт, шаг, первое действие. Указатель, не хранилище: решение или договорённость, не записанные в золотые файлы проекта, для следующей сессии НЕ существуют — перед прощанием сессия обязана дописать золотые файлы, потом состояние |

## Изоляция market-to-funnel до route

До выбора `route` не читай ни одного дочернего навыка. Разрешены только это
состояние/шаблон, `scripts/market-pipeline-entry.sh` и три возможных входа:
`PROJECT.md`, `MARKET-RESEARCH.md`, `MARKETING-BRIEF.md`. Для любого
`research_handoff` не открывай `onboard`, discovery- и research-навыки; после
подтверждения их явные разделы читай только через
`scripts/read-research-handoff-branch.sh mkt-recon|funnel`. Прямое чтение этих
child-файлов запрещено. Обычный onboarding возобновляется лишь после
`route=discovery`.
Write allowlist `research_handoff`: только `agent-state.md` и производные
`MARKET.md`/`GROWTH-PLAN.md`; `memory.md` и другие файлы агента не меняются.

## Правило interrupted (железно)

При **любом** прерывании — владелец ушёл в другую тему, сессия закончилась,
разговор съехал на другой такт — **перед ответом на новую тему** запиши
`interrupted: true` + причину + `resume_hint`. Без этого следующая сессия не
вернётся в правильную точку и начнёт заново, потеряв контекст.

Вернулись и продолжили — ставь `interrupted: false`, чисти `interrupted_reason`
и `resume_hint`, обновляй `last_checkpoint`.

## Правило Stage Lock

Такт закрыт только когда его выход собран полностью **и** владелец явно сказал
«принимаю». Пока такт не закрыт — держишь фокус на нём. Владелец тянет вперёд
(из спроса в оффер, из оффера в воронку) — коротко фиксируешь его мысль в
заметках проекта, объясняешь одной фразой, почему рано, и возвращаешься.

## Журнал

Ниже — append-only лог переключений: дата, время, что произошло.

- (пусто)
