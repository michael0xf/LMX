# 007. Clean Architecture

Политика предметной области и use case отделены от внешнего представления.

## Общий сценарий

При доходе 100 и расходах 60 правило требует остаток не менее 30; внешний presenter переводит решение в код 200.

**Ожидаемое наблюдение:** 200; при доходе 70 и расходах 60 — 422.

**Граница сравнения:** Ядро сценария. Числовой ответ — работа presenter, не отправка HTTP. Аутентификация, хранилище и compile-time module enforcement не показаны.

## LMX

```lmx
Policy:
    int: income
    int: expense
    return: int
    eligible:
        return: income - expense >= 30

Presenter:
    int: decision
    return: int
    render:
        if: decision != 0
            return: 200
        return: 422

UseCase:
    int: income
    int: expense
    @: output
    return: int
    execute:
        return: output(decision := Policy\eligible())
    demo:
        return: execute(100; 60; Presenter\render)
```

Вызов UseCase\demo(). output(decision:int)→int — внешний порт отображения; бизнес-правило не читает HTTP-профиль или GUI. Сокращение 23-Nov: income/expense use ordinary autofill; the predicate still sees both actual values.

[Отдельный листинг](examples/lmx/007_clean_architecture.lm3)

## Java

```java
class Example {
    interface Output { int present(boolean decision); }
    static boolean eligible(int income, int expense) { return income - expense >= 30; }
    static int execute(int income, int expense, Output output) {
        return output.present(eligible(income, expense));
    }
    static int render(boolean decision) { return decision ? 200 : 422; }
    static int demo() { return execute(100, 60, Example::render); }
}
```

Листинг ядра; внешний вызов Example.demo(), если он определён. Внешние порты описаны в границах сценария.

[Отдельный листинг](examples/java/007_clean_architecture.java)

## Go

```go
package main
func eligible(income, expense int) bool { return income-expense >= 30 }
func execute(income, expense int, output func(bool) int) int {
    return output(eligible(income, expense))
}
func render(decision bool) int { if decision { return 200 }; return 422 }
func demo() int { return execute(100, 60, render) }
```

Листинг пакета; внешний вызов demo(), если он определён. main и транспортный host не входят в подсчёт.

[Отдельный листинг](examples/go/007_clean_architecture.go)

## Разбор LMX

Вызов UseCase\demo(). output(decision:int)→int — внешний порт отображения; бизнес-правило не читает HTTP-профиль или GUI. Сокращение 23-Nov: income/expense use ordinary autofill; the predicate still sees both actual values.

## Сопоставление

Важна направленность зависимостей к policy/use case. Один файл показывает связи; отсутствие ссылок внутрь UI проверяется по выделенным модулям реального проекта.

### Небольшие варианты записи

Позиционные аргументы можно записать именованными, булев return — через if/return. Такие местные изменения записи и вызовов уже показанных leaf-методов не повторяются целыми листингами.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 286 | 22 |
| Java | 341 | 9 |
| Go | 268 | 7 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Все объявления, аргументы и ссылки на общий банк ошибок учитываются целиком.

## English explanation

Domain policy and the use case are separated from the outer presentation.

**Scenario.** For income 100 and expense 60, the policy requires at least 30 remaining; an outer presenter maps the decision to 200.

**Expected observation.** 200; income 70 and expense 60 produce 422.

**LMX.** Call UseCase\demo(). output(decision:int)→int is an outer presentation port; the business rule does not read an HTTP profile or GUI.

**Comparison.** The key is dependency direction toward policy/use cases. The single-file example shows links; project modules enforce the boundary.

**Scope and limitations.** The numeric response belongs to the presenter; it does not send HTTP. Authentication, storage, and compile-time module enforcement are excluded.

### Dependencies and execution boundaries

- **LMX:** Call UseCase\demo(). output(decision:int)→int is an outer presentation port; the business rule does not read an HTTP profile or GUI.
- **Java:** Core listing; call Example.demo() when supplied. External ports are described in the scenario boundary.
- **Go:** Package listing; call demo() when supplied. main and the transport host are excluded.

## Источники / Sources

- [Robert C. Martin — The Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html) — Правило направления зависимостей и use cases.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
