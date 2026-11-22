# 094. FindById — implementation

Реализовать импортируемый поиск первой записи по целочисленному id.

**Примеры использования:** [016. Repository](016_repository_comparision.md)

## Общий сценарий

Просмотреть упорядоченную последовательность записей, вернуть первую с нужным id или отсутствие.

**Ожидаемое наблюдение:** Для id 7 возвращается исходная запись 7; при повторном id возвращается первая; неизвестный id и пустой список дают отсутствие.

**Граница сравнения:** Реализация библиотеки. Узкий helper одного ключа; без произвольных predicate/context, lazy query planner, SQL или индекса. Последовательность не изменяется и не перечисляется дальше первого совпадения. Lifetime найденной записи остаётся у владельца коллекции/Message; возврат ссылки её не копирует.

Показана реализация компонента на всех трёх языках. Её код полностью включён в эту строку сравнения; связанный прикладной пример считает только использование готового компонента.

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

Во всех трёх языках написаны собственный цикл, сравнение id, ранний return и ветвь отсутствия. Python next/filter и C# FirstOrDefault не используются для реализации helper. LMX и Python требуют поле id структурно, C# выражает тот же нужный доступ через IIdentified.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 227 | 17 |
| Python | 68 | 5 |
| C# | 266 | 13 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Implement imported first-record lookup by integer id.

**Usage examples:** [016. Repository](016_repository_comparision.md)

**Scenario.** Scan an ordered record sequence and return the first matching id or absence.

**Expected observation.** Id 7 returns its original record; duplicate ids return the first; unknown ids and empty sequences return absence.

**LMX.** FindLibrary copies sys\OPERANDS_TEMPLATE, making mode 0 and additive priority ready before analysis. length(right)=1 checks the binary contract. \left reads the whole sequence reference value, and \right[0] the integer id. The loop visits rows until the first match and returns that original reference; empty/no-match cases return 0. No captured predicate or retained frame is involved.

**Comparison.** All implementations explicitly show their own loop, id comparison, early return, and absence branch. Python next/filter and C# FirstOrDefault are not used to implement the helper. LMX/Python require id structurally; C# exposes that required access through IIdentified.

**Scope and limitations.** This is a narrow single-key helper without arbitrary predicates/contexts, a lazy query planner, SQL, or an index. It neither mutates the sequence nor enumerates past the first match. The collection/Message owner retains the record lifetime; returning its reference does not copy it.

### Dependencies and execution boundaries

- **LMX:** FindLibrary copies sys\OPERANDS_TEMPLATE, making mode 0 and additive priority ready before analysis. length(right)=1 checks the binary contract. \left reads the whole sequence reference value, and \right[0] the integer id. The loop visits rows until the first match and returns that original reference; empty/no-match cases return 0. No captured predicate or retained frame is involved.
- **Python:** Complete lookup.py, using only for, field access, comparison, and return.
- **C#:** Complete ExampleLib.Records with the minimal Id contract; IEnumerable supplies basic traversal only, and search is implemented here.

## Источники / Sources

- [Martin Fowler — Repository](https://martinfowler.com/eaaCatalog/repository.html) — Определение и границы паттерна.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md), [уточнение 21 ноября](../../tasks/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
