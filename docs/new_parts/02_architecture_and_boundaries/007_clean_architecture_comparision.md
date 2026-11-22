# 007. Clean Architecture

Политика предметной области и use case отделены от внешнего представления.

## Общий сценарий

При доходе 100 и расходах 60 правило требует остаток не менее 30; внешний presenter переводит решение в код 200.

**Ожидаемое наблюдение:** 200; при доходе 70 и расходах 60 — 422.

**Граница сравнения:** Ядро сценария. Числовой ответ — работа presenter, не отправка HTTP. Аутентификация, хранилище и compile-time module enforcement не показаны.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
Policy:
    int: income
    int: expense
    return: int
    eligible:
        if: income - expense >= 30
            return: 1
        return: 0

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
        return: output(decision := Policy\eligible(income := income; expense := expense))
    demo:
        return: execute(income := 100; expense := 60; output := Presenter\render)
```

Вызов UseCase\demo(). output(decision:int)→int — внешний порт отображения; бизнес-правило не читает HTTP-профиль или GUI.

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

Вызов UseCase\demo(). output(decision:int)→int — внешний порт отображения; бизнес-правило не читает HTTP-профиль или GUI.

## Сопоставление

Важна направленность зависимостей к policy/use case. Один файл показывает связи; отсутствие ссылок внутрь UI проверяется по выделенным модулям реального проекта.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 354 | 24 |
| Java | 341 | 9 |
| Go | 268 | 7 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

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

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md), [уточнение 21 ноября](../../tasks/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
