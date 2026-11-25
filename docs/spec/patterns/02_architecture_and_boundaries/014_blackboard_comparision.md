# 014. Blackboard

Независимые источники знаний читают общую доску и добавляют применимые факты.

## Общий сценарий

В доске raw=4. Эксперт A выводит normalized=5, эксперт B выводит result=10. Планировщик пробует B раньше A.

**Ожидаемое наблюдение:** 10; требуется следующий проход после добавления normalized.

**Граница сравнения:** Ядро сценария. Два монотонных правила на положительном fixture. Для произвольных правил нужна политика agenda, конфликтов и завершения; zero служит доменным маркером отсутствующего факта, не LMX uninit.

## LMX

```lmx
Board:
    int: raw 4
    int: normalized 0
    int: result 0

Experts:
    @: board Board
    return: int
    normalize:
        if: board\normalized = 0
            board\normalized := board\raw + 1
            return: 1
        return: 0
    derive:
        if: board\normalized != 0 && board\result = 0
            board\result := board\normalized * 2
            return: 1
        return: 0
    demo:
        board\normalized := 0
        board\result := 0
        int: changed 1
        while: changed != 0
            changed := derive() + normalize()
        return: board\result
```

Вызов Experts\demo(). Доска и источники знаний живут в одном Message; общий граф меняет только его последовательный исполнитель.

[Отдельный листинг](examples/lmx/014_blackboard.lm3)

## Java

```java
class Example {
    static class Board { int raw = 4, normalized, result; }
    static int normalize(Board b) {
        if (b.normalized != 0) return 0;
        b.normalized = b.raw + 1;
        return 1;
    }
    static int derive(Board b) {
        if (b.normalized == 0 || b.result != 0) return 0;
        b.result = b.normalized * 2;
        return 1;
    }
    static int demo() {
        Board b = new Board(); int changed = 1;
        while (changed != 0) changed = derive(b) + normalize(b);
        return b.result;
    }
}
```

Листинг ядра; внешний вызов Example.demo(), если он определён. Внешние порты описаны в границах сценария.

[Отдельный листинг](examples/java/014_blackboard.java)

## Go

```go
package main
type Board struct { Raw, Normalized, Result int }
func normalize(b *Board) int {
    if b.Normalized != 0 { return 0 }
    b.Normalized = b.Raw + 1
    return 1
}
func derive(b *Board) int {
    if b.Normalized == 0 || b.Result != 0 { return 0 }
    b.Result = b.Normalized * 2
    return 1
}
func demo() int {
    b := &Board{Raw: 4}
    changed := 1
    for changed != 0 { changed = derive(b) + normalize(b) }
    return b.Result
}
```

Листинг пакета; внешний вызов demo(), если он определён. main и транспортный host не входят в подсчёт.

[Отдельный листинг](examples/go/014_blackboard.go)

## Разбор LMX

Вызов Experts\demo(). Доска и источники знаний живут в одном Message; общий граф меняет только его последовательный исполнитель.

## Сопоставление

Порядок B→A показывает отличие от фиксированной цепочки фильтров. Источник знаний проверяет применимость; controller повторяет проход до отсутствия изменений.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 354 | 24 |
| Java | 351 | 18 |
| Go | <span style="color:#176233"><u>325</u></span> | 18 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Все объявления, аргументы и ссылки на общий банк ошибок учитываются целиком.

## English explanation

Independent knowledge sources read a common board and contribute applicable facts.

**Scenario.** The board starts with raw=4. Expert A derives normalized=5, expert B derives result=10. The scheduler tries B before A.

**Expected observation.** 10; another pass is required after normalized is added.

**LMX.** Call Experts\demo(). The board and knowledge sources live in one Message; only its serial executor mutates the graph.

**Comparison.** The B→A order distinguishes this from a fixed filter chain. Knowledge sources test applicability; the controller repeats until no change.

**Scope and limitations.** Two monotone rules on a positive fixture. Arbitrary rules need agenda, conflict, and termination policies; zero is a domain sentinel, not LMX uninit.

### Dependencies and execution boundaries

- **LMX:** Call Experts\demo(). The board and knowledge sources live in one Message; only its serial executor mutates the graph.
- **Java:** Core listing; call Example.demo() when supplied. External ports are described in the scenario boundary.
- **Go:** Package listing; call demo() when supplied. main and the transport host are excluded.

## Источники / Sources

- [Daniel D. Corkill — Blackboard Systems](https://dancorkill.com/pubs/ai-expert.pdf) — Авторская статья об источниках знаний, доске и управлении.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
