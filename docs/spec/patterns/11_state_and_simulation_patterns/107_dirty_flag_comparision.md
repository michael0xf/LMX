# 107. Dirty Flag

Ленивое обновление производного максимума с объединением нескольких записей в один пересчёт.

Dirty Flag помечает производные данные устаревшими при изменении исходных и обновляет их, когда результат понадобится. Все пути изменения должны устанавливать флаг. Это основной механизм в [главе Nystrom](https://github.com/munificent/game-programming-patterns/blob/master/book/dirty-flag.markdown).

## Пара языков

C++ характерен для кэшей производных данных в движке; JavaScript — для состояния интерфейса и браузерной визуализации. Сравнение использует стандартный поиск максимума и явно показывает границу инвалидирования кэша.

## Единый контракт

Первичные данные — произвольный конечный массив целых значений общего диапазона `int32`. Производная величина — максимум; для пустого массива в этом сценарии определён результат `0`. Это соглашение данного сценария: стандартный `maximum` LMX на пустом массиве по-прежнему сообщает `SequenceSize`.

Создание и `reset(values)` копируют элементы входа и ставят `dirty = 1`, но ничего не пересчитывают. `set(index, value)` меняет ровно одну позицию и ставит флаг, **в том числе при записи прежнего значения**. Некорректный индекс даёт `InvalidIndex` до любого изменения состояния. Прямая запись клиентом в служебные поля находится вне API во всех языках.

`get()` пересчитывает результат только при установленном флаге, записывает `cached`, сбрасывает флаг и увеличивает `rebuilds` ровно на единицу. Повторный `get()` без изменения данных возвращает кэш без нового вычисления. Счётчик начинается с нуля для нового объекта; `reset` его сохраняет. Пустой массив также имеет один ленивый пересчёт при первом чтении. До первого чтения `cached = 0` и не считается актуальным.

Входные массивы после создания и `reset` независимы от внутреннего хранилища. Ошибка `set` сохраняет `values`, `cached`, `dirty` и `rebuilds`. Последовательность операций может быть пустой; если чтений нет, пересчётов нет. Число операций в области сравнения не превышает `2147483647`, чтобы счётчик оставался в общем точном диапазоне.

**Контрольное наблюдение.** Для `[3,1,5]`: `get,get,set(0,9),set(2,2),get,get` даёт значения чтений `[5,5,9,9]` и счётчики при чтениях `[1,1,2,2]`. Две записи между чтениями вызывают один пересчёт. После reset к `[-4,-7]` максимум равен `-4`, после reset к `[]` — `0`.

## LMX: общий механизм

Этот файл включается в каждый выбранный вариант ровно один раз. Полный вариант — общая часть и один из двух клиентов ниже; его граница не ограничивается клиентским вызовом.

```lmx
CachedMaximum:
    @: values
    int: dirty 1
    int: cached 0
    int: rebuilds 0

CacheMake:
    int[]: values
    return: @
    make:
        @: state (copy(CachedMaximum))
        return: CacheWrite\reset(state; values)

CacheWrite:
    CachedMaximum@: state
    int[]: values
    int: index
    int: value
    return: @
    reset:
        int[]: owned [copy(values)]
        state\values := owned
        state\dirty := 1
        return: state
    set:
        throws: InvalidIndex
        if: index < 0 || index >= length(state\values)
            throw: InvalidIndex()
        state\values[index] := value
        state\dirty := 1
        return: state

CacheRead:
    CachedMaximum@: state
    return: int
    get:
        throws: copy(Maximum\calculate\throws)
        if: state\dirty != 0
            state\cached := Maximum\calculate(state\values)
            state\dirty := 0
            state\rebuilds += 1
        return: state\cached
```

[Общий исходник](examples/lmx/shared/107_dirty_flag.lm3).

## LMX — процедурный

```lmx
Maximum:
    int[]: values
    return: int
    calculate:
        throws:
        if: length(values) = 0
            return: 0
        int: result values[0]
        int: i 1
        while: i < length(values)
            if: values[i] > result
                result := values[i]
            i += 1
        return: result
```

[Процедурный клиент](examples/lmx/procedural/107_dirty_flag.lm3) + [общая часть](examples/lmx/shared/107_dirty_flag.lm3).

## LMX — функциональный

```lmx
Maximum:
    int[]: values
    return: int
    calculate:
        throws: copy(maximum\throws)
        if: length(values) = 0
            return: 0
        return: \maximum(values)
```

[Функциональный клиент](examples/lmx/107_dirty_flag.lm3) + [общая часть](examples/lmx/shared/107_dirty_flag.lm3).

## Разбор LMX

Политика кэша определена один раз в общем файле. В сборку выбирается ровно одно определение `Maximum\calculate`: явный поиск циклом либо вызов уже существующего обобщённого `maximum`. Шаблон кэша не добавляет в ядро специализированный «максимум только для int».

`CacheRead\get` копирует Throws из выбранного вычисления. Если вычисление завершится ошибкой, присваивание `cached`, сброс флага и увеличение счётчика не выполняются; следующая попытка остаётся необходимой. Отдельная перехватывающая оболочка для сравнения ошибки не нужна.

Операционные вызовы: `@: cache CacheMake\make([3 1 5])`, затем `CacheRead\get(cache)`. Для записи используются именованные аргументы: `CacheWrite\set(state := cache; index := 0; value := 9)`. Это важно: `CacheWrite` также объявляет `values` для `reset`, поэтому позиционные три аргумента для `set` здесь не показаны. `CacheWrite\reset(cache; [-4 -7])` меняет первичный массив и откладывает расчёт до чтения.

## C++

```cpp
#include <algorithm>
#include <stdexcept>
#include <vector>

struct CachedMaximum {
    std::vector<int> values;
    bool dirty = true;
    int cached = 0;
    int rebuilds = 0;
    explicit CachedMaximum(const std::vector<int>& input) : values(input) {}
    void reset(const std::vector<int>& input) {
        values = input;
        dirty = true;
    }
    void set(int index, int value) {
        if (index < 0 || static_cast<std::size_t>(index) >= values.size())
            throw std::out_of_range("InvalidIndex");
        values[index] = value;
        dirty = true;
    }
    int get() {
        if (dirty) {
            cached = values.empty() ? 0 : *std::max_element(values.begin(), values.end());
            ++rebuilds;
            dirty = false;
        }
        return cached;
    }
};
```

[Полный исходник](examples/cpp/107_dirty_flag.cpp).

## JavaScript

```javascript
export class CachedMaximum {
    constructor(values) {
        this.rebuilds = 0;
        this.cached = 0;
        this.reset(values);
    }
    reset(values) {
        this.values = values.slice();
        this.dirty = true;
    }
    set(index, value) {
        if (index < 0 || index >= this.values.length)
            throw new RangeError("InvalidIndex");
        this.values[index] = value;
        this.dirty = true;
    }
    get() {
        if (this.dirty) {
            this.cached = this.values.length === 0 ? 0 :
                this.values.reduce((a, b) => Math.max(a, b));
            ++this.rebuilds;
            this.dirty = false;
        }
        return this.cached;
    }
}
```

[Полный исходник](examples/javascript/107_dirty_flag.mjs).

## Сопоставление

Функциональная LMX-форма, C++ max_element и JavaScript reduce с Math.max используют стандартные операции над последовательностью. Сам жизненный цикл кэша остаётся в показанном коде каждого языка. Счётчик вычислений позволяет отличить паттерн от программы, которая возвращает тот же максимум, но каждый раз повторяет обход. Для максимума после замены прежнего максимального элемента недостаточно просто обновить одну сумму; выбранный пример показывает реальную необходимость повторного просмотра.

## Граница и ограничения

Один последовательный владелец. Это кэш одного производного значения, не memoize по истории аргументов. Нет фонового пересчёта, конкурентных читателей, дискового сохранения, дедупликации равных записей или замера ускорения. Ускорение зависит от частоты записей и чтений; само наличие флага не доказывает выигрыш во времени.

Вызовы, парсинг тестовых входов, assertions и сериализация результатов находятся в тестовых адаптерах. Они одинаково вынесены за границу сравниваемого механизма. Расходы памяти и системные ошибки выделения ресурсов не сравниваются по переносимому коду ошибки.

## Статистика



## Проверка

[Общие fixtures и ожидаемые результаты](tests/fixture_expectations.json), [исполняемый прогон](tests/validate.py), [отчёт](tests/validation_results.json). Контрольные реализации выполняются на указанных в отчёте версиях инструментов. Для новых LMX-листингов **parser: NOT_RUN; runtime: NOT_RUN**: парсер и runtime LMX в рабочем архиве не предоставлены. Совпадение исходников, Markdown и JSON проверяется отдельно и не объявляется синтаксической проверкой.

## English explanation

A cached maximum is invalidated by reset and every successful indexed write, including a same-value write. Reads recompute at most once between mutations. Empty input yields the scenario fallback zero. Invalid writes are atomic. Reset copies the caller input and preserves the lifetime rebuild count. Tests inspect cache state and rebuild counts, not only returned maxima.



## Источники

- [Robert Nystrom — Dirty Flag, original author repository](https://github.com/munificent/game-programming-patterns/blob/master/book/dirty-flag.markdown) — Флаг устаревших производных данных и единая граница мутаций.
- [C++ working draft — minimum and maximum](https://eel.is/c++draft/alg.min.max) — Контракт max_element и пустой диапазон.
- [ECMAScript — Array.prototype.reduce](https://tc39.es/ecma262/multipage/indexed-collections.html#sec-array.prototype.reduce) — Последовательная свёртка элементов массива.

Норма LMX: [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [правила сравнения](../COMPARISON_RULES.md). Используемые общие операции: [collections.lmx](../LMX_Fn_Receivers/src/collections.lmx), [coreStandardFunctional.lmx](../LMX_Fn_Receivers/src/coreStandardFunctional.lmx), [coreStandardNumeric.lmx](../LMX_Fn_Receivers/src/coreStandardNumeric.lmx), [публикация имён](../LMX_Fn_Receivers/src/public.lmx).

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 802 | 53 |
| LMX — функциональный | 745 | 47 |
| C++ | 555 | 28 |
| JavaScript | <span style="color:#176233"><u>438</u></span> | 26 |

Для каждой LMX-формы считаются все её source_files, включая общие определения ровно один раз. Все объявления и Throws входят в размер. Зелёным подчёркнут минимум полного сопоставимого листинга; равные минимумы выделены вместе.
