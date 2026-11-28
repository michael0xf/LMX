# 090. MapReduce

Map порождает ключи, shuffle направляет их владельцам, reduce объединяет значения по ключу.

## Общий сценарий

Две входные части [1,2] и [3,4] группируются по чётности. Map выдаёт (n mod 2,1); reduce считает элементы.

**Ожидаемое наблюдение:** Результат {0:2,1:2}. Чтение итогов выполняется после четырёх подтверждённых reduce-операций.

**Граница сравнения:** Протокол и порты. Нет spill-to-disk, сбойного перезапуска map, dedup, сортировки ключей и durable shuffle. Неотрицательные целые ограничены четырьмя значениями; порядок обработки не влияет на сумму.

## LMX

```lmx
MapperMessage:
    int: value
    @: even
    @: odd
    @: barrier
    map:
        @: reducer even
        if: value % 2 = 1
            reducer := odd
        post:
            ask:
                reducer\add()
            answer:
                barrier\accepted

ReducerMessage:
    int: count 0
    return: int
    add:
        node\count += 1
        return: read()
    read:
        return: node\count
```

LMX использует отдельные исполняемые Message с собственной ареной и последовательными turns. Шаблоны явно запускаются хостом; адресованные вызовы проходят общий post, а удалённый профиль — описанный HTTP transport. Полный контракт обвязки находится в MESSAGE_HTTP_PROFILE.md. Приведён авторский protocol/core пример, не проверенный парсером runtime fixture. Хост запускает два MapperMessage и два ReducerMessage. Каждый элемент partition посылается своему mapper. barrier.accepted(int):void считает четыре семантических ответа add; только затем хост запрашивает read у обоих reducers. Barrier не выводится из группировки post автоматически. Go/Erlang используют один reducer для двух ключей — та же агрегация с иным размещением. ReducerMessage повторно использует свой read после изменения count; mapper, отдельные владельцы и подтверждения барьера остаются прежними.

[Отдельный листинг](examples/lmx/090_map_reduce.lm3)

## Go

```go
import "sync"
func MapReduce(parts [][]int) map[int]int {
    keys := make(chan int)
    var wg sync.WaitGroup
    for _, part := range parts {
        wg.Add(1)
        go func(xs []int) {
            defer wg.Done()
            for _, x := range xs { keys <- x % 2 }
        }(part)
    }
    go func(){ wg.Wait(); close(keys) }()
    totals := map[int]int{0:0,1:0}
    for key := range keys { totals[key]++ }
    return totals
}
```

Фрагмент Go; import перечислен там, где нужен; package/harness вынесен. Хост запускает два MapperMessage и два ReducerMessage. Каждый элемент partition посылается своему mapper. barrier.accepted(int):void считает четыре семантических ответа add; только затем хост запрашивает read у обоих reducers. Barrier не выводится из группировки post автоматически. Go/Erlang используют один reducer для двух ключей — та же агрегация с иным размещением.

[Отдельный листинг](examples/go/090_map_reduce.go)

## Erlang

```erlang
map_reduce(Parts) ->
    Parent = self(),
    [spawn(fun() -> [Parent ! {key,X rem 2} || X <- Part] end) || Part <- Parts],
    reduce(lists:sum([length(P) || P <- Parts]), #{0=>0,1=>0}).
reduce(0, Totals) -> Totals;
reduce(N, Totals) ->
    receive {key,K} -> reduce(N-1, maps:update_with(K,fun(V)->V+1 end,1,Totals)) end.
```

Функции Erlang для одного модуля; -module/-export и запускающий тест вынесены. Хост запускает два MapperMessage и два ReducerMessage. Каждый элемент partition посылается своему mapper. barrier.accepted(int):void считает четыре семантических ответа add; только затем хост запрашивает read у обоих reducers. Barrier не выводится из группировки post автоматически. Go/Erlang используют один reducer для двух ключей — та же агрегация с иным размещением.

[Отдельный листинг](examples/erlang/090_map_reduce.erl)

## Разбор LMX

LMX использует отдельные исполняемые Message с собственной ареной и последовательными turns. Шаблоны явно запускаются хостом; адресованные вызовы проходят общий post, а удалённый профиль — описанный HTTP transport. Полный контракт обвязки находится в MESSAGE_HTTP_PROFILE.md. Приведён авторский protocol/core пример, не проверенный парсером runtime fixture. Хост запускает два MapperMessage и два ReducerMessage. Каждый элемент partition посылается своему mapper. barrier.accepted(int):void считает четыре семантических ответа add; только затем хост запрашивает read у обоих reducers. Barrier не выводится из группировки post автоматически. Go/Erlang используют один reducer для двух ключей — та же агрегация с иным размещением. ReducerMessage повторно использует свой read после изменения count; mapper, отдельные владельцы и подтверждения барьера остаются прежними.

## Сопоставление

LMX выражает shuffle явным выбором Message-владельца ключа; Go channel и Erlang mail переносят ключи. Это раскрывает алгоритм map/group/reduce, но ещё не распределённый движок Google MapReduce.

### Небольшие варианты записи

Позиционные аргументы можно записать именованными, булев return — через if/return. Такие местные изменения записи и вызовов уже показанных leaf-методов не повторяются целыми листингами.

### Асинхронная граница

Прикладной протокол выполняется обычными turns Message. post уже обеспечивает адресованный вызов, корреляцию и доставку обработчиков; второй scheduler не требуется. post не реализует очередь, транзакцию, barrier отмены или внешний I/O provider этого протокола: явно объявленные порты сохраняют свои договоры.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 216 | 22 |
| Go | 290 | 16 |
| Erlang | 267 | 7 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Все объявления, аргументы и ссылки на общий банк ошибок учитываются целиком.

## English explanation

Map emits keys, shuffle routes them to owners, and reduce combines values per key.

**Scenario.** Two partitions [1,2] and [3,4] are grouped by parity. Map emits (n mod 2,1); reduce counts values.

**Expected observation.** Result {0:2,1:2}. Final reads occur after four acknowledged reduce operations.

**LMX.** LMX uses separate executable Messages with their own arenas and serial turns. Templates are explicitly launched by the host; addressed calls use post and remote delivery uses the documented HTTP transport. MESSAGE_HTTP_PROFILE.md defines shared integration. This is an original protocol/core example, not a parser-validated runtime fixture. The host launches two MapperMessages and two ReducerMessages. Partition items are mailed to their mapper. barrier.accepted(int):void counts four semantic add replies; only then does the host read both reducers. post grouping does not imply a barrier. Go/Erlang use one reducer for both keys: the same aggregation with different placement. ReducerMessage reuses its read after changing count; the mapper, separate owners and barrier acknowledgements are unchanged.

**Comparison.** LMX expresses shuffle as explicit selection of the key owner Message; Go channels and Erlang mail carry keys. This exposes map/group/reduce without claiming to implement the distributed Google MapReduce engine.

**Scope and limitations.** There is no disk spill, failed-map restart, deduplication, key sorting or durable shuffle. The fixture uses four nonnegative integers; processing order does not affect the count.

The shown application protocol runs on existing Message turns. post already supplies addressed invocation, reply correlation and handler delivery; it needs no second scheduler here. It does not supply this protocol’s queue, transaction, cancellation barrier or external I/O provider. Those explicitly declared ports retain their stated contracts; this listing is not a hidden implementation of an entire networking/storage library.

### Dependencies and execution boundaries

- **LMX:** LMX uses separate executable Messages with their own arenas and serial turns. Templates are explicitly launched by the host; addressed calls use post and remote delivery uses the documented HTTP transport. MESSAGE_HTTP_PROFILE.md defines shared integration. This is an original protocol/core example, not a parser-validated runtime fixture. The host launches two MapperMessages and two ReducerMessages. Partition items are mailed to their mapper. barrier.accepted(int):void counts four semantic add replies; only then does the host read both reducers. post grouping does not imply a barrier. Go/Erlang use one reducer for both keys: the same aggregation with different placement. ReducerMessage reuses its read after changing count; the mapper, separate owners and barrier acknowledgements are unchanged.
- **Go:** Go fragment; imports are included where needed; package/harness is separate. The host launches two MapperMessages and two ReducerMessages. Partition items are mailed to their mapper. barrier.accepted(int):void counts four semantic add replies; only then does the host read both reducers. post grouping does not imply a barrier. Go/Erlang use one reducer for both keys: the same aggregation with different placement.
- **Erlang:** Erlang functions for one module; -module/-export and the test harness are separate. The host launches two MapperMessages and two ReducerMessages. Partition items are mailed to their mapper. barrier.accepted(int):void counts four semantic add replies; only then does the host read both reducers. post grouping does not imply a barrier. Go/Erlang use one reducer for both keys: the same aggregation with different placement.

## Источники / Sources

- [Dean and Ghemawat — MapReduce](https://research.google/pubs/mapreduce-simplified-data-processing-on-large-clusters/) — Map порождает ключи, shuffle направляет их владельцам, reduce объединяет значения по ключу.
- [Go — Pipelines and cancellation](https://go.dev/blog/pipelines) — Map порождает ключи, shuffle направляет их владельцам, reduce объединяет значения по ключу.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
