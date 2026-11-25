# 050. Materialized View

Поддерживать заранее вычисленную проекцию для дешёвого чтения.

## Общий сценарий

ProjectionMessage получает события (seq=1,delta=10),(2,5),дубль (2,5), затем ошибочный пропуск (4,9). Прочитать total.

**Ожидаемое наблюдение:** total=15,last=2. Дубль игнорируется. Пропуск последовательности выдаёт Gap до изменения состояния.

**Граница сравнения:** Протокол и порты. Это memory-only проекция, которую можно восстановить replay. Для сохранения между авариями total и checkpoint записываются атомарно; для нескольких потоков нужен checkpoint на каждый, а не общий last.

## LMX

```lmx
ProjectionMessage:
    int: total 0
    int: last 0
    int: seq
    int: delta
    return: int
    apply:
        throws: Gap
        if: seq <= node\last
            return: query()
        if: seq != node\last + 1
            throw: Gap()
        node\total += delta
        node\last := seq
        return: query()
    query:
        return: node\total
```

Один Message владеет total/last. Параметры seq/delta приходят по Message или HTTP intake, apply изменяет только собственный граф. Возврат query не сканирует исходный журнал.

[Отдельный листинг](examples/lmx/050_materialized_view.lm3)

## Java

```java
final class Projection {
    private int total,last;
    int apply(int seq,int delta) {
        if (seq<=last) return total;
        if (seq!=last+1) throw new IllegalStateException("gap");
        total+=delta;
        last=seq;
        return total;
    }
    int query() { return total; }
}
```

Это memory-only проекция, которую можно восстановить replay. Для сохранения между авариями total и checkpoint записываются атомарно; для нескольких потоков нужен checkpoint на каждый, а не общий last.

[Отдельный листинг](examples/java/050_materialized_view.java)

## Go

```go
package patterns
import "fmt"
type Projection struct { Total,Last int }
func (p *Projection) Apply(seq,delta int) (int,error) {
    if seq<=p.Last { return p.Total,nil }
    if seq!=p.Last+1 { return 0,fmt.Errorf("gap") }
    p.Total+=delta
    p.Last=seq
    return p.Total,nil
}
func (p *Projection) Query() int { return p.Total }
```

Это memory-only проекция, которую можно восстановить replay. Для сохранения между авариями total и checkpoint записываются атомарно; для нескольких потоков нужен checkpoint на каждый, а не общий last.

[Отдельный листинг](examples/go/050_materialized_view.go)

## Разбор LMX

Один Message владеет total/last. Параметры seq/delta приходят по Message или HTTP intake, apply изменяет только собственный граф. Возврат query не сканирует исходный журнал.

## Сопоставление

Все три варианта хранят сумму и checkpoint отдельно от источника событий. Дедупликация здесь корректна для одного упорядоченного непрерывного потока.

### Небольшие варианты записи

Позиционные аргументы можно записать именованными, булев return — через if/return. Такие местные изменения записи и вызовов уже показанных leaf-методов не повторяются целыми листингами.

### Асинхронная граница

Прикладной протокол выполняется обычными turns Message. post уже обеспечивает адресованный вызов, корреляцию и доставку обработчиков; второй scheduler не требуется. post не реализует очередь, транзакцию, barrier отмены или внешний I/O provider этого протокола: явно объявленные порты сохраняют свои договоры.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 208 | 17 |
| Java | <span style="color:#176233"><u>205</u></span> | 11 |
| Go | 269 | 11 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Все объявления, аргументы и ссылки на общий банк ошибок учитываются целиком.

## English explanation

Maintain a precomputed projection for cheap reads.

**Scenario.** Apply (1,10),(2,5), duplicate (2,5), then a gap (4,9); query total.

**Expected observation.** Total is 15 and last is 2. The duplicate is ignored; the gap fails before changing state.

**LMX.** One Message owns total/last. Events arrive through Message or HTTP intake. apply changes its own graph; query does not rescan the event log.

**Comparison.** Each version stores a sum and checkpoint separately from the source stream. Deduplication assumes one contiguous ordered stream.

**Scope and limitations.** This memory-only view can be rebuilt. Durable total/checkpoint must be committed atomically; multiple streams need separate checkpoints.

The shown application protocol runs on existing Message turns. post already supplies addressed invocation, reply correlation and handler delivery; it needs no second scheduler here. It does not supply this protocol’s queue, transaction, cancellation barrier or external I/O provider. Those explicitly declared ports retain their stated contracts; this listing is not a hidden implementation of an entire networking/storage library.

### Dependencies and execution boundaries

- **LMX:** One Message owns total/last. Events arrive through Message or HTTP intake. apply changes its own graph; query does not rescan the event log.
- **Java:** This memory-only view can be rebuilt. Durable total/checkpoint must be committed atomically; multiple streams need separate checkpoints.
- **Go:** This memory-only view can be rebuilt. Durable total/checkpoint must be committed atomically; multiple streams need separate checkpoints.

## Источники / Sources

- [Microsoft Azure Architecture Center — Materialized View](https://learn.microsoft.com/en-us/azure/architecture/patterns/materialized-view) — Определение, механизм и границы гарантий.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
