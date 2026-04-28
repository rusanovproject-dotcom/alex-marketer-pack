# Hypothesis-Driven System — полные правила

Все тесты живут в `projects/<main>/hypotheses.md`.

---

## Базовые правила

- **Макс 5 активных** гипотез + 1 Key Hypothesis
- Каждая гипотеза с **тегом типа** (12 тегов в словаре ниже)
- Без тега = в Active не принимается
- Обязателен **критерий успеха/провала в цифрах** + дедлайн

---

## Сквозной словарь тегов (12)

| Тег | Что про | Валидация обновляет файл |
|------|---------|--------------------------|
| `[ICP]` | про КОГО (ЦА) | `audience/NORTH-STAR.md` |
| `[SEGMENT]` | конкретный под-сегмент | `audience/segments/{slug}/segment-core.md` |
| `[PRODUCT]` | продукт под ЦА | `product/core-offer.md` |
| `[OFFER]` | Value Stack, гарантия | `product/core-offer.md` |
| `[PRICE]` | ценовое | `product/ladder.md` |
| `[POSITIONING]` | как отстраиваемся | `brand/positioning.md` |
| `[COMPETITOR]` | про конкурентов | `brand/competitors.md` |
| `[CHANNEL]` | каналы трафика | `funnel/channels.md` |
| `[LM]` | лид-магнит | `funnel/welcome.md` |
| `[FUNNEL]` | последовательность касаний | `funnel/welcome.md` + `scripts.md` |
| `[MESSAGE]` | хуки, заголовки | `brand/voice.md` или `audience/voice-of-customer.md` |
| `[METRIC]` | про цифры | `metrics.md` |

---

## Жизненный цикл гипотезы

```
🌱 Starter (стартовая гипотеза владельца)
    ↓
🧊 Backlog → 🧪 Active (max 5) → ✅ Validated / ❌ Invalidated
                                         ↓
                            Предложение diff в hypotheses.md → Log
                                         ↓
                            Владелец → /accept H{N} → файл вывода обновлён
                                         ↓
                            3+ подтверждений в разных проектах → memory.md (Key Learnings)
```

---

## Правило обновления файлов выводов

**Ты НЕ перезаписываешь** `product/core-offer.md`, `brand/positioning.md`, `audience/NORTH-STAR.md` напрямую.

При validated H предлагаешь diff в `hypotheses.md → Log`:

```markdown
## YYYY-MM-DD — предложение из H{N}
Файл: product/core-offer.md, секция Value Equation
Предлагаемое изменение:
[diff с оригиналом и новой версией]
Владелец принимает командой /accept H{N} или отвергает.
```

Голос остаётся за владельцем.

---

## Когда промоутить гипотезу из Backlog в Active

1. У тебя свободный слот (< 5 Active)
2. Есть **источник данных** для теста (не «спросим клиента позже»)
3. Есть **критерий успеха в цифрах** + дедлайн
4. Гипотеза имеет **тег из словаря**
5. Multi-perspective пройден (4 угла: ресурсы / рынок / боль / конкуренция) — нет пустых углов

Если хоть один пункт нет — гипотеза остаётся в Backlog или 🔴 Требует уточнения.

---

## Key Hypothesis — отдельный слот

Одна главная гипотеза на проект. Если она invalidated — пересматриваешь стратегию, не просто меняешь тактику. Помечается `(Key)` в `hypotheses.md`.
