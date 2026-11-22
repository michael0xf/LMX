# 055. Leader Election

Получить подтверждённое право лидера и защитить ресурс от старого владельца.

## Общий сценарий

A получает lease/token=10, B временно не получает. После потери lease B получает 11. Задержавшаяся работа A с 10 пытается записать в ресурс.

**Ожидаемое наблюдение:** Текущий B может записать с 11; запись A с 10 отвергается ресурсом. acquire возвращает 0 при отсутствии лидерства, тогда работа не запускается.

**Граница сравнения:** Протокол и порты. Внутренняя election/lease библиотека не входит в метрику кода. acquire должен возвращать монотонный fencing token, release — освобождать только свой lease. Исключения write не отменяют требования TTL/renewal; менеджер lease обеспечивает их. Сниппет обслуживает одну рабочую попытку.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
CandidateMessage:
    @: coordinator
    @: resource
    int: id
    return: int
    attempt:
        int: token coordinator\acquire(id)
        if: token = 0
            return: 0
        int: result resource\writeIfCurrent(token; id)
        coordinator\release(id; token)
        return: result
```

CandidateMessage — участник. coordinator.acquire(id) и resource.writeIfCurrent(token,id) — явные порты распределённой координации. Сервис атомарно проверяет актуальное владение и fencing при записи; один локальный Message или HTTP timeout не доказывает остановку прежнего лидера.

[Отдельный листинг](examples/lmx/055_leader_election.lm3)

## Java

```java
interface Coordinator {
    int acquire(int id);
    void release(int id,int token);
}
interface Resource { boolean writeIfCurrent(int token,int id); }
final class Candidate {
    static boolean attempt(Coordinator c,Resource r,int id) {
        int token=c.acquire(id);
        if (token==0) return false;
        boolean result=r.writeIfCurrent(token,id);
        c.release(id,token);
        return result;
    }
}
```

Внутренняя election/lease библиотека не входит в метрику кода. acquire должен возвращать монотонный fencing token, release — освобождать только свой lease. Исключения write не отменяют требования TTL/renewal; менеджер lease обеспечивает их. Сниппет обслуживает одну рабочую попытку.

[Отдельный листинг](examples/java/055_leader_election.java)

## Go

```go
package patterns
type Coordinator interface { Acquire(int) int; Release(int,int) }
type Resource interface { WriteIfCurrent(int,int) bool }
func Attempt(c Coordinator,r Resource,id int) bool {
    token:=c.Acquire(id)
    if token==0 { return false }
    result:=r.WriteIfCurrent(token,id)
    c.Release(id,token)
    return result
}
```

Внутренняя election/lease библиотека не входит в метрику кода. acquire должен возвращать монотонный fencing token, release — освобождать только свой lease. Исключения write не отменяют требования TTL/renewal; менеджер lease обеспечивает их. Сниппет обслуживает одну рабочую попытку.

[Отдельный листинг](examples/go/055_leader_election.go)

## Разбор LMX

CandidateMessage — участник. coordinator.acquire(id) и resource.writeIfCurrent(token,id) — явные порты распределённой координации. Сервис атомарно проверяет актуальное владение и fencing при записи; один локальный Message или HTTP timeout не доказывает остановку прежнего лидера.

## Сопоставление

Листинги сравнивают клиентский протокол использования избранного лидера, а не реализации Raft/Paxos. Java и Go получают те же контракты. etcd Election/Lease — пример возможной инфраструктуры, не неявная зависимость LMX.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 199 | 12 |
| Java | 319 | 14 |
| Go | 278 | 10 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Acquire confirmed leadership and reject stale-owner resource writes.

**Scenario.** A holds token 10 while B is refused; after lease loss B obtains 11. A delayed write still carries 10.

**Expected observation.** B can write with 11; the resource rejects A with 10. acquire returns zero when no leadership was obtained and no work starts.

**LMX.** CandidateMessage is one participant. Coordinator and protected-resource operations are explicit distributed ports. The resource atomically validates current ownership and fencing; a local Message or HTTP timeout cannot establish that an old leader stopped.

**Comparison.** The listings compare a leader client protocol, not Raft/Paxos implementations. Java and Go use the same contracts. etcd Election/Lease is a possible adapter infrastructure, not an implicit LMX dependency.

**Scope and limitations.** Coordinator implementation is excluded from code counts. acquire returns a monotonic fencing token; release affects only that lease. The lease manager provides TTL/renewal even when work fails. The snippet shows one work attempt.

### Dependencies and execution boundaries

- **LMX:** CandidateMessage is one participant. Coordinator and protected-resource operations are explicit distributed ports. The resource atomically validates current ownership and fencing; a local Message or HTTP timeout cannot establish that an old leader stopped.
- **Java:** Coordinator implementation is excluded from code counts. acquire returns a monotonic fencing token; release affects only that lease. The lease manager provides TTL/renewal even when work fails. The snippet shows one work attempt.
- **Go:** Coordinator implementation is excluded from code counts. acquire returns a monotonic fencing token; release affects only that lease. The lease manager provides TTL/renewal even when work fails. The snippet shows one work attempt.

## Источники / Sources

- [Microsoft Azure Architecture Center — Leader Election](https://learn.microsoft.com/en-us/azure/architecture/patterns/leader-election) — Определение, механизм и границы гарантий.
- [etcd Go concurrency package — Election and Session](https://pkg.go.dev/go.etcd.io/etcd/client/v3/concurrency) — Пример реального API координации; fencing ресурса остаётся явным требованием.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md), [уточнение 21 ноября](../../tasks/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
