# 094. FindById — implementation

Реализовать импортируемый поиск первой записи по целочисленному id.

**Примеры использования:** [016. Repository](016_repository_comparision.md)

## Общий сценарий

Просмотреть упорядоченную последовательность записей, вернуть первую с нужным id или отсутствие.

**Ожидаемое наблюдение:** Для id 7 возвращается исходная запись 7; при повторном id возвращается первая; неизвестный id и пустой список дают отсутствие.

**Граница сравнения:** Реализация библиотеки. Узкий helper одного ключа; без произвольных predicate/context, lazy query planner, SQL или индекса. Последовательность не изменяется и не перечисляется дальше первого совпадения. Lifetime найденной записи остаётся у владельца коллекции/Message; возврат ссылки её не копирует.

Это самостоятельное сравнение реализаций. Весь показанный код считается здесь; связанные иностранные клиенты используют настоящие библиотечные средства. Общие runtime-примитивы и их границы перечислены отдельно.

## LMX

```lmx
FindLibrary:
    copy: sys\OPERANDS_TEMPLATE
    return: @
    findById:
        throws: OperandArity
        if: length(right) != 1
            throw: OperandArity()
        @: rows \left
        int: id \right[0]
        int: i 0
        while: i < length(rows)
            @: row rows[i]
            if: row\id = id
                return: row
            i += 1
        @: missing 0
        return: missing
```

FindLibrary использует copy: sys\OPERANDS_TEMPLATE: mode 0 и приоритет + готовы до анализа. Бинарный контракт проверяется length(right)=1. \left получает reference-value целой последовательности, \right[0] — int-значение id. Цикл читает каждую запись до первого совпадения, возвращая её исходную ссылку; пустая последовательность и отсутствие дают 0. Никакого captured predicate и сохранённого frame нет.

[Отдельный листинг](examples/lmx/094_find_by_id_implementation.lm3)

## Python

```python
def find_by_id(rows, id):
    for row in rows:
        if row.id == id:
            return row
    return None
```

Полный lookup.py; используются только for, чтение поля, сравнение и return.

[Отдельный листинг](examples/python/094_find_by_id_implementation.py)

## C#

```csharp
#nullable enable
using System.Collections.Generic;
namespace ExampleLib {
    public interface IIdentified { int Id { get; } }
    public static class Records {
        public static T? FindById<T>(IEnumerable<T> rows, int id) where T : class, IIdentified {
            foreach (T row in rows) {
                if (row.Id == id) return row;
            }
            return null;
        }
    }
}
```

Полный ExampleLib.Records с минимальным Id-контрактом; IEnumerable даёт только базовый обход, поиск написан здесь.

[Отдельный листинг](examples/csharp/094_find_by_id_implementation.cs)

## Разбор LMX

FindLibrary использует copy: sys\OPERANDS_TEMPLATE: mode 0 и приоритет + готовы до анализа. Бинарный контракт проверяется length(right)=1. \left получает reference-value целой последовательности, \right[0] — int-значение id. Цикл читает каждую запись до первого совпадения, возвращая её исходную ссылку; пустая последовательность и отсутствие дают 0. Никакого captured predicate и сохранённого frame нет.

## Сопоставление

Во всех трёх языках написаны собственный цикл, сравнение id, ранний return и ветвь отсутствия. Python next/filter и C# FirstOrDefault не используются для реализации helper. LMX и Python требуют поле id структурно, C# выражает тот же нужный доступ через IIdentified. Обобщённая версия 23-Nov сохранена [отдельно](extended_comparisons/094_find_by_id_implementation_generalized_comparision.md); она не подменяет эту узкую задачу.

## Отдельный расширенный договор

[Обобщённая или асинхронная пара 23-Nov](extended_comparisons/094_find_by_id_implementation_generalized_comparision.md). Она сохраняется отдельно и не включается в размер этой основной строки.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки | Без сложного Throws |
| --- | ---: | ---: | ---: |
| LMX | 227 | 17 | 227 |
| Python | 68 | 5 | — |
| C# | 266 | 13 | — |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Дополнительная колонка «без сложного Throws» оставляет заголовок и первый аргумент каждого списка в исходном порядке, полностью считает ссылки/copy и первый аргумент общего банка. Меняется только расчёт, не исходник или контракт.

## English explanation

Implement imported first-record lookup by integer id.

**Usage examples:** [016. Repository](016_repository_comparision.md)

**Scenario.** Scan an ordered record sequence and return the first matching id or absence.

**Expected observation.** Id 7 returns its original record; duplicate ids return the first; unknown ids and empty sequences return absence.

**LMX.** FindLibrary copies sys\OPERANDS_TEMPLATE, making mode 0 and additive priority ready before analysis. length(right)=1 checks the binary contract. \left reads the whole sequence reference value, and \right[0] the integer id. The loop visits rows until the first match and returns that original reference; empty/no-match cases return 0. No captured predicate or retained frame is involved.

**Comparison.** All implementations explicitly show their own loop, id comparison, early return, and absence branch. Python next/filter and C# FirstOrDefault are not used to implement the helper. LMX/Python require id structurally; C# exposes that required access through IIdentified. The wider 23-Nov contract remains in a separate comparison and does not replace this finite task.

**Scope and limitations.** This is a narrow single-key helper without arbitrary predicates/contexts, a lazy query planner, SQL, or an index. It neither mutates the sequence nor enumerates past the first match. The collection/Message owner retains the record lifetime; returning its reference does not copy it.

### Dependencies and execution boundaries

- **LMX:** FindLibrary copies sys\OPERANDS_TEMPLATE, making mode 0 and additive priority ready before analysis. length(right)=1 checks the binary contract. \left reads the whole sequence reference value, and \right[0] the integer id. The loop visits rows until the first match and returns that original reference; empty/no-match cases return 0. No captured predicate or retained frame is involved.
- **Python:** Complete lookup.py, using only for, field access, comparison, and return.
- **C#:** Complete ExampleLib.Records with the minimal Id contract; IEnumerable supplies basic traversal only, and search is implemented here.

## Источники / Sources

- [Martin Fowler — Repository](https://martinfowler.com/eaaCatalog/repository.html) — Определение и границы паттерна.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
