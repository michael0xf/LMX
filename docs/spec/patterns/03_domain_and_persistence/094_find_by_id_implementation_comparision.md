# 094. FindById — implementation

Общий findFirst возвращает Maybe первого элемента по переданному предикату.

**Примеры использования:** [016. Repository](016_repository_comparision.md)

## Общий сценарий

Просмотреть упорядоченную последовательность записей, вернуть первую с нужным id или отсутствие.

**Ожидаемое наблюдение:** Для id 7 возвращается исходная запись 7; при повторном id возвращается первая; неизвестный id и пустой список дают отсутствие.

**Граница сравнения:** Реализация библиотеки. LMX показывает общий алгоритм с фактическими типами и исходным контекстом. Контрольные реализации сохраняют явно указанный прикладной профиль. Сравнение одного профиля не означает одинакового охвата библиотек или скорости; для полной стоимости прибавляются общие зависимости и runtime каждого языка.

Это самостоятельное сравнение реализаций. Весь показанный код считается здесь; связанные иностранные клиенты используют настоящие библиотечные средства. Общие runtime-примитивы и их границы перечислены отдельно.

## LMX

```lmx
FxFindFirst:
    private:
        @: items
        @: accepts
    required: items accepts
    return: @
    findFirst:
        throws: copy(FxThrows\predicate)
        FxSeqInfo\get(items)
        private: int: count length(items)
        private: int: i 0
        while: i < count
            private: @: value FxSeqRead\read(items; i)
            private: @: accepted FxApply\apply(accepts; FxOne\make(value))
            if: FxSeqPredicate\truth(accepted) != 0
                return: FxSome\some(value := value)
            i += 1
        return: FxNone\none()
```

Точное текущее определение FxFindFirst извлечено из общего ядра. Клиенты используют его каноническое имя и явные доменные аргументы; второго алгоритма в локальном модуле нет. Общие зависимости перечислены и считаются один раз в [реестре](../COMMON_OPERATION_DEPENDENCIES.md). Изменённый исходник LMX не исполнялся.

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

Точное текущее определение FxFindFirst извлечено из общего ядра. Клиенты используют его каноническое имя и явные доменные аргументы; второго алгоритма в локальном модуле нет. Общие зависимости перечислены и считаются один раз в [реестре](../COMMON_OPERATION_DEPENDENCIES.md). Изменённый исходник LMX не исполнялся.

## Сопоставление

Во всех трёх языках написаны собственный цикл, сравнение id, ранний return и ветвь отсутствия. Python next/filter и C# FirstOrDefault не используются для реализации helper. LMX и Python требуют поле id структурно, C# выражает тот же нужный доступ через IIdentified. Обобщённая версия 23-Nov сохранена [отдельно](extended_comparisons/094_find_by_id_implementation_generalized_comparision.md); она не подменяет эту узкую задачу.

## Отдельный расширенный договор

[Обобщённая или асинхронная пара 23-Nov](extended_comparisons/094_find_by_id_implementation_generalized_comparision.md). Она сохраняется отдельно и не включается в размер этой основной строки.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 371 | 18 |
| Python | <span style="color:#176233"><u>68</u></span> | 5 |
| C# | 266 | 13 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Все объявления, аргументы и ссылки на общий банк ошибок учитываются целиком.

## English explanation

Generic findFirst returns Maybe of the first element accepted by the supplied predicate.

**Usage examples:** [016. Repository](016_repository_comparision.md)

**Scenario.** Scan an ordered record sequence and return the first matching id or absence.

**Expected observation.** Id 7 returns its original record; duplicate ids return the first; unknown ids and empty sequences return absence.

**LMX.** The exact current FxFindFirst definitions are extracted from the common core. Clients use canonical names and explicit domain arguments. The dependency ledger accounts for shared definitions once; no local duplicate algorithm is introduced. The revised LMX source has not been executed.

**Comparison.** All implementations explicitly show their own loop, id comparison, early return, and absence branch. Python next/filter and C# FirstOrDefault are not used to implement the helper. LMX/Python require id structurally; C# exposes that required access through IIdentified. The wider 23-Nov contract remains in a separate comparison and does not replace this finite task.

**Scope and limitations.** LMX shows the common algorithm with actual types and original context. Foreign implementations retain the stated application profile. A comparison for one profile does not establish equal library coverage or speed; complete cost includes shared dependencies and each runtime.

### Dependencies and execution boundaries

- **LMX:** The exact current FxFindFirst definitions are extracted from the common core. Clients use canonical names and explicit domain arguments. The dependency ledger accounts for shared definitions once; no local duplicate algorithm is introduced. The revised LMX source has not been executed.
- **Python:** Complete lookup.py, using only for, field access, comparison, and return.
- **C#:** Complete ExampleLib.Records with the minimal Id contract; IEnumerable supplies basic traversal only, and search is implemented here.

## Источники / Sources

- [Martin Fowler — Repository](https://martinfowler.com/eaaCatalog/repository.html) — Определение и границы паттерна.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
