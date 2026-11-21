# 090. MapReduce

Map порождает ключи, shuffle направляет их владельцам, reduce объединяет значения по ключу.

## Общий сценарий

Две входные части [1,2] и [3,4] группируются по чётности. Map выдаёт (n mod 2,1); reduce считает элементы.

**Ожидаемое наблюдение:** Результат {0:2,1:2}. Чтение итогов выполняется после четырёх подтверждённых reduce-операций.

**Граница сравнения:** Протокол и порты. Нет spill-to-disk, сбойного перезапуска map, dedup, сортировки ключей и durable shuffle. Неотрицательные целые ограничены четырьмя значениями; порядок обработки не влияет на сумму.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

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
        return: node\count
    read:
        return: node\count
```

LMX использует отдельные исполняемые Message с собственной ареной и последовательными turns. Шаблоны явно запускаются хостом; адресованные вызовы проходят общий post, а удалённый профиль — описанный HTTP transport. Полный контракт обвязки находится в MESSAGE_HTTP_PROFILE.md. Приведён авторский protocol/core пример, не проверенный парсером runtime fixture. Хост запускает два MapperMessage и два ReducerMessage. Каждый элемент partition посылается своему mapper. barrier.accepted(int):void считает четыре семантических ответа add; только затем хост запрашивает read у обоих reducers. Barrier не выводится из группировки post автоматически. Go/Erlang используют один reducer для двух ключей — та же агрегация с иным размещением.

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

LMX использует отдельные исполняемые Message с собственной ареной и последовательными turns. Шаблоны явно запускаются хостом; адресованные вызовы проходят общий post, а удалённый профиль — описанный HTTP transport. Полный контракт обвязки находится в MESSAGE_HTTP_PROFILE.md. Приведён авторский protocol/core пример, не проверенный парсером runtime fixture. Хост запускает два MapperMessage и два ReducerMessage. Каждый элемент partition посылается своему mapper. barrier.accepted(int):void считает четыре семантических ответа add; только затем хост запрашивает read у обоих reducers. Barrier не выводится из группировки post автоматически. Go/Erlang используют один reducer для двух ключей — та же агрегация с иным размещением.

## Сопоставление

LMX выражает shuffle явным выбором Message-владельца ключа; Go channel и Erlang mail переносят ключи. Это раскрывает алгоритм map/group/reduce, но ещё не распределённый движок Google MapReduce.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 220 | 22 |
| Go | 290 | 16 |
| Erlang | 267 | 7 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Map emits keys, shuffle routes them to owners, and reduce combines values per key.

**Scenario.** Two partitions [1,2] and [3,4] are grouped by parity. Map emits (n mod 2,1); reduce counts values.

**Expected observation.** Result {0:2,1:2}. Final reads occur after four acknowledged reduce operations.

**LMX.** LMX uses separate executable Messages with their own arenas and serial turns. Templates are explicitly launched by the host; addressed calls use post and remote delivery uses the documented HTTP transport. MESSAGE_HTTP_PROFILE.md defines shared integration. This is an original protocol/core example, not a parser-validated runtime fixture. The host launches two MapperMessages and two ReducerMessages. Partition items are mailed to their mapper. barrier.accepted(int):void counts four semantic add replies; only then does the host read both reducers. post grouping does not imply a barrier. Go/Erlang use one reducer for both keys: the same aggregation with different placement.

**Comparison.** LMX expresses shuffle as explicit selection of the key owner Message; Go channels and Erlang mail carry keys. This exposes map/group/reduce without claiming to implement the distributed Google MapReduce engine.

**Scope and limitations.** There is no disk spill, failed-map restart, deduplication, key sorting or durable shuffle. The fixture uses four nonnegative integers; processing order does not affect the count.

### Dependencies and execution boundaries

- **LMX:** LMX uses separate executable Messages with their own arenas and serial turns. Templates are explicitly launched by the host; addressed calls use post and remote delivery uses the documented HTTP transport. MESSAGE_HTTP_PROFILE.md defines shared integration. This is an original protocol/core example, not a parser-validated runtime fixture. The host launches two MapperMessages and two ReducerMessages. Partition items are mailed to their mapper. barrier.accepted(int):void counts four semantic add replies; only then does the host read both reducers. post grouping does not imply a barrier. Go/Erlang use one reducer for both keys: the same aggregation with different placement.
- **Go:** Go fragment; imports are included where needed; package/harness is separate. The host launches two MapperMessages and two ReducerMessages. Partition items are mailed to their mapper. barrier.accepted(int):void counts four semantic add replies; only then does the host read both reducers. post grouping does not imply a barrier. Go/Erlang use one reducer for both keys: the same aggregation with different placement.
- **Erlang:** Erlang functions for one module; -module/-export and the test harness are separate. The host launches two MapperMessages and two ReducerMessages. Partition items are mailed to their mapper. barrier.accepted(int):void counts four semantic add replies; only then does the host read both reducers. post grouping does not imply a barrier. Go/Erlang use one reducer for both keys: the same aggregation with different placement.

## Источники / Sources

- [Dean and Ghemawat — MapReduce](https://research.google/pubs/mapreduce-simplified-data-processing-on-large-clusters/) — Map порождает ключи, shuffle направляет их владельцам, reduce объединяет значения по ключу.
- [Go — Pipelines and cancellation](https://go.dev/blog/pipelines) — Map порождает ключи, shuffle направляет их владельцам, reduce объединяет значения по ключу.

**Норма LMX:** [CORE](../newdocs/CORE.md), [семантика](../newdocs/LMX_semantics.en.md), [guide](../newdocs/LMX_semantics_guide.en.md), [уточнение 21 ноября](../newdocs/TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
