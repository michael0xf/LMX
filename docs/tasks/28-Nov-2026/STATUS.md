# Статус поставки 28 ноября

Матричный пакет `doc/` содержит снимок до фиксов имён и квадратных форм. Пометки ниже относятся к его копиям спецификации и примерам. Исходные тексты и манифесты сохранены.

| Устаревшая норма и место в матричном снимке | Действующая норма |
| --- | --- |
| **Снятие кавычек и равенство токенов.** [Grammar RU](doc/spec/LMX_grammar.ru.md) (122, 1360), [EN](doc/spec/LMX_grammar.en.md) (129, 1405) и [книга RU](doc/spec/LMX_semantics.ru.md) (1207) с переводом сохраняют прежний договор. | Написанный идентификатор даёт полный байтовый ключ. Два различных написания остаются разными ключами. Правило действует и для операторов и служебных имён. `sys\name` сохраняет полное написание. [Имена](../../spec/LMX_grammar.ru.md#identifiers) · [Миграция и проверки](../../IDENTIFIER_BYTES_AND_STRING_KEYS.md) |
| **Вход в квадратный подпарсер только для INDEX и операций.** [Подпарсер RU](doc/spec/BRACKET_SUBPARSER.ru.md), [EN](doc/spec/BRACKET_SUBPARSER.en.md), §1–2 и §7, [Grammar RU](doc/spec/LMX_grammar.ru.md) (1137, 1364), [EN](doc/spec/LMX_grammar.en.md) (1169, 1409) и [Expression](doc/spec/EXPRESSION_ALGORITHM.md) (368) сохраняют раздельные пути. | Все структурные квадратные формы идут через один подпарсер. Общий P0 проверяет категорию любой распознанной продукции. Явный вызов `` `[]` `` использует точный ключ `60 5B 5D 60` и ту же подготовку, что квадратная запись. [Границы P0](../../spec/BRACKET_SUBPARSER.ru.md) · [Приёмка](../../spec/BRACKET_SUBPARSER.ru.md#square-acceptance) |

| Исходное поручение | Рабочее место |
| --- | --- |
| [Байты идентификатора и строковые ключи](IDENTIFIER_BYTES_AND_STRING_KEYS.md) | [Договор и миграция](../../IDENTIFIER_BYTES_AND_STRING_KEYS.md) · [Очередь грамматики](../../../next_core_tasks_v3.md#identifier-bytes-priority-20261128) |
| [Матричный пакет](LMX_MATRIX_TASK_2026-11-28.md) | [Сводка](../../MATRIX_REVIEW_2026-11-28.md) · [Тензорный план](../../TENSOR_IMPLEMENTATION_PLAN.md#integration-v3) |
| [Единый ресивер](SQUARE_BRACKET_RECEIVER.md) | [Норма](../../spec/BRACKET_SUBPARSER.ru.md#square-receiver) · [План общего P0](../../../next_core_tasks_v3.md#square-bracket-receiver-20261128) |

Статус черновиков и результатов исходного пакета относится к его маршрутам проверки. Приёмка реализации идёт по рабочему плану.
