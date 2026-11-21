# 051. Sharding

Направлять ключи в выбранные горизонтальные разделы хранилища.

## Общий сценарий

Три шарда. Для неотрицательных customerId 7,8,9 вычислить shard=customerId%3 и передать get в соответствующий endpoint.

**Ожидаемое наблюдение:** Ключи идут в шарды 1,2,0. Повторный ключ всегда выбирает тот же shard при неизменном наборе.

**Граница сравнения:** Протокол и порты. Число шардов фиксировано и больше нуля; id>=0. Изменение N перемещает ключи, поэтому миграция, metadata epochs и распределённые запросы не покрыты. Это routing core, не готовая система ребалансировки.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
RouterMessage:
    []: @ targets
    @: transport
    int: id
    return: @
    get:
        throws: Shard
        if: id < 0 || length(targets) = 0
            throw: Shard()
        int: index id % length(targets)
        return: transport\get(targets[index]; id)
```

RouterMessage владеет таблицей targets и получает запросы. transport.get(target,id) — синхронный профиль документированного HTTP транспорта: target содержит endpoint+route, результат получен после Message intake/исполнения на шарде. Это отдельный явно переданный адаптер, не builtin HTTP singleton.

[Отдельный листинг](examples/lmx/051_sharding.lm3)

## Java

```java
import java.util.List;
interface Transport { Object get(String target,int id); }
final class Router {
    static Object get(List<String> targets,Transport transport,int id) {
        if (id<0 || targets.isEmpty()) throw new IllegalArgumentException("shard");
        int index=id%targets.size();
        return transport.get(targets.get(index),id);
    }
}
```

Число шардов фиксировано и больше нуля; id>=0. Изменение N перемещает ключи, поэтому миграция, metadata epochs и распределённые запросы не покрыты. Это routing core, не готовая система ребалансировки.

[Отдельный листинг](examples/java/051_sharding.java)

## Go

```go
package patterns
import "fmt"
type Transport interface { Get(string,int) (any,error) }
func Get(targets []string,transport Transport,id int) (any,error) {
    if id<0 || len(targets)==0 { return nil,fmt.Errorf("shard") }
    return transport.Get(targets[id%len(targets)],id)
}
```

Число шардов фиксировано и больше нуля; id>=0. Изменение N перемещает ключи, поэтому миграция, metadata epochs и распределённые запросы не покрыты. Это routing core, не готовая система ребалансировки.

[Отдельный листинг](examples/go/051_sharding.go)

## Разбор LMX

RouterMessage владеет таблицей targets и получает запросы. transport.get(target,id) — синхронный профиль документированного HTTP транспорта: target содержит endpoint+route, результат получен после Message intake/исполнения на шарде. Это отдельный явно переданный адаптер, не builtin HTTP singleton.

## Сопоставление

Каждый язык вычисляет одну и ту же функцию маршрутизации и вызывает порт. В LMX шарды — отдельные Message/сервисы с независимым состоянием.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 171 | 11 |
| Java | 291 | 9 |
| Go | 240 | 7 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Route keys to horizontal storage partitions.

**Scenario.** For three shards, route nonnegative customer IDs 7,8,9 using id modulo 3.

**Expected observation.** The selected shards are 1,2,0; repeated keys retain placement while the shard set is unchanged.

**LMX.** RouterMessage owns targets. transport.get(target,id) is an explicitly supplied synchronous adapter to the documented HTTP profile; target contains endpoint and route, and the result follows remote Message execution.

**Comparison.** Every language implements the same routing function and port call. LMX shards are separate Messages/services with isolated state.

**Scope and limitations.** The shard count is fixed and positive and IDs are nonnegative. Changing the count relocates keys; migration, epochs and cross-shard queries are outside this routing core.

### Dependencies and execution boundaries

- **LMX:** RouterMessage owns targets. transport.get(target,id) is an explicitly supplied synchronous adapter to the documented HTTP profile; target contains endpoint and route, and the result follows remote Message execution.
- **Java:** The shard count is fixed and positive and IDs are nonnegative. Changing the count relocates keys; migration, epochs and cross-shard queries are outside this routing core.
- **Go:** The shard count is fixed and positive and IDs are nonnegative. Changing the count relocates keys; migration, epochs and cross-shard queries are outside this routing core.

## Источники / Sources

- [Microsoft Azure Architecture Center — Sharding](https://learn.microsoft.com/en-us/azure/architecture/patterns/sharding) — Определение, механизм и границы гарантий.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md), [уточнение 21 ноября](../../TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
