---
active_client: null            # имя владельца офиса (заполняется на /alex-onboarding)
active_project: null           # slug папки в projects/<slug>/
active_skill: null             # текущий скилл: /alex-onboarding | /jtbd | /jtbd-critic | /marketer-log-deal | null
active_stage: null             # 1 (Audience-JTBD) | 2 | 3 | null
active_step: null              # текущий Step внутри /jtbd: 00 | 01a | 01b | 02a | ... | 13 | null
active_segment: null           # slug сегмента если в фазе углубления (B-N): hot-segment | warm-segment | cold-segment | null
last_checkpoint: null          # YYYY-MM-DD HH:MM последнего обновления
interrupted: false             # true если прервали посреди сессии
interrupted_reason: null       # описание если interrupted: true
resume_hint: null              # что делать в следующей сессии если interrupted
onboarding_completed: false    # true после /alex-onboarding
onboarding_date: null          # YYYY-MM-DD когда прошёл онбординг
focus_direction: null          # выбранное направление работы (одной фразой клиента)
project_created_at: null       # YYYY-MM-DD HH:MM когда создали папку projects/<slug>/
has_paying_customers: null     # true / false — есть ли в нише ≥1 платящих (заполняется в /alex-onboarding 3.2). При false /jtbd Step 00 включит ГЕЙТ ZERO-DATA
paying_customers_count: null   # сколько именно платящих (число или 0)
stage_1_critic_passed: false   # true когда /jtbd-critic пройден (закрытие Stage 1)
---

# Alex Marketer — Global State

> Append-only лог активной задачи. Алекс читает первым в Pre-flight любого скилла.

> Шапка YAML — машиночитаемый snapshot текущего состояния. Заполняется по ходу работы скиллов:
> - `/alex-onboarding` пишет: `active_client`, `active_project`, `onboarding_completed`, `onboarding_date`, `focus_direction`, `project_created_at`, переключает `active_skill: /jtbd`
> - `/jtbd` обновляет: `active_step`, `active_segment`, `last_checkpoint` после каждого Step
> - При прерывании: `interrupted: true` + `interrupted_reason` + `resume_hint`

## Журнал сессий

> Append-only. Каждая сессия добавляет блок ниже шапки.

(пусто — заполняется при первом запуске)
