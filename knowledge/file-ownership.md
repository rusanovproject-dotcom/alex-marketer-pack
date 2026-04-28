# Файлы владения — где Алекс пишет напрямую, а где только diff

## Безопасные зоны — Алекс создаёт и обновляет сам

| Файл | Что | Когда обновляется |
|------|-----|-------------------|
| **`hypotheses.md`** | Тест-процесс | постоянно |
| **`audience/voice-of-customer.md`** | Voice of Customer (append only) | при разборе встреч/комментов/цитат |
| **`brand/expert-bank.md`** | Голос владельца (append only) | при разборе встреч/постов/голосовых |
| **`brand/competitors.md`** | Конкурентная карта | при анализе конкурентов |
| **`metrics.md`** | Цифры в AUTO-секциях | по факту цифр от владельца |
| **`inbox/_processed/`** | После разбора | классификация |
| **`customers/`** | Если активирован модуль встреч | после каждой встречи |

---

## Зоны владельца — Алекс пишет только diff в Log

Эти файлы Алекс **НЕ перезаписывает напрямую**. Только предлагает изменения через `hypotheses.md → Log`, владелец принимает командой `/accept H{N}`.

| Файл | Кто пишет | Откуда обновления |
|------|-----------|-------------------|
| `audience/NORTH-STAR.md` | владелец | из validated [ICP] H |
| `audience/segments/{slug}/segment-core.md` | владелец (с твоей помощью через `/segments-unpack`) | из validated [SEGMENT] H |
| `product/core-offer.md` | владелец | из validated [PRODUCT/OFFER] H |
| `product/ladder.md` | владелец | из validated [PRICE] H |
| `brand/positioning.md` | владелец | из validated [POSITIONING] H |
| `funnel/channels.md, welcome.md, scripts.md` | владелец (с твоей помощью через `/funnel-build`) | из validated [CHANNEL/LM/FUNNEL] H |

---

## Чужие зоны — не трогать никогда

- `strategy.md` — Стратег
- `voice.md` — Copywriter
- `progress.md` — Director
- `learnings.md` — только append после 3+ подтверждений паттерна

---

## Принцип

**Дополняешь блоком с датой**: *«## YYYY-MM-DD — что изменилось / новые гипотезы / что оспариваю»*. Старые версии → `projects/<main>/_archive/`. Не переписываешь старое.
