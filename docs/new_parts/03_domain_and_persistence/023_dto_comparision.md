# 023. DTO — Data Transfer Object

Собрать разрешённые поля в одно передаваемое значение.

## Общий сценарий

Доменная запись имеет id=7, cents=1250 и секретное поле token. Проекция export выбирает только id и cents.

**Ожидаемое наблюдение:** Результат содержит ровно id=7 и cents=1250; token и методы доменного объекта не попадают в DTO.

**Граница сравнения:** Ядро сценария. Сетевой round trip не исполняется листингом. Транспортный профиль задаёт кодировку, versioning и допуск; DTO не является Value Object только из-за отсутствия методов.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
independent: AccountDto:
    int: id 0
    int: cents 0

Export:
    @: account
    return: @
    dto:
        @: result (copy(AccountDto))
        result\id := account\id
        result\cents := account\cents
        return: result
```

AccountDto — independent-шаблон двух готовых примитивных полей. dto копирует его, явно записывает вычисленные значения в слоты и возвращает готовый DTO. HTTP-профиль LMX уже передаёт application/lmx; проекция предшествует сериализации и Message intake.

[Отдельный листинг](examples/lmx/023_dto.lm3)

## Python

```python
from dataclasses import dataclass
@dataclass(frozen=True)
class AccountDto:
    id: int
    cents: int
def export(account):
    return AccountDto(account.id, account.cents)
```

Сетевой round trip не исполняется листингом. Транспортный профиль задаёт кодировку, versioning и допуск; DTO не является Value Object только из-за отсутствия методов.

[Отдельный листинг](examples/python/023_dto.py)

## C#

```csharp
public sealed record AccountDto(int Id,int Cents);
public sealed record Account(int Id,int Cents,string Token);
public static class Export {
    public static AccountDto Dto(Account account) => new(account.Id,account.Cents);
}
```

Сетевой round trip не исполняется листингом. Транспортный профиль задаёт кодировку, versioning и допуск; DTO не является Value Object только из-за отсутствия методов.

[Отдельный листинг](examples/csharp/023_dto.cs)

## Разбор LMX

AccountDto — independent-шаблон двух готовых примитивных полей. dto копирует его, явно записывает вычисленные значения в слоты и возвращает готовый DTO. HTTP-профиль LMX уже передаёт application/lmx; проекция предшествует сериализации и Message intake.

## Сопоставление

Во всех трёх вариантах проекция явная. Само наличие сериализатора не делает автоматическую выгрузку всего доменного графа подходящим DTO.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 155 | 11 |
| Python | 145 | 7 |
| C# | 197 | 5 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Project allowed fields into one transport value.

**Scenario.** Account 7 has 1250 cents and a secret token. Export only id and cents.

**Expected observation.** The result contains exactly id=7 and cents=1250; neither token nor domain methods is included.

**LMX.** AccountDto is an independent template of two ready primitive fields. dto copies it, explicitly writes computed values to the result slots and returns the formed DTO. LMX HTTP already supports application/lmx; projection precedes serialization and Message intake.

**Comparison.** All three projections are explicit. A serializer does not make whole-domain-graph export an appropriate DTO.

**Scope and limitations.** The listing performs no network round trip. The transport profile defines encoding, versioning and admission; DTO and Value Object are distinct roles.

### Dependencies and execution boundaries

- **LMX:** AccountDto is an independent template of two ready primitive fields. dto copies it, explicitly writes computed values to the result slots and returns the formed DTO. LMX HTTP already supports application/lmx; projection precedes serialization and Message intake.
- **Python:** The listing performs no network round trip. The transport profile defines encoding, versioning and admission; DTO and Value Object are distinct roles.
- **C#:** The listing performs no network round trip. The transport profile defines encoding, versioning and admission; DTO and Value Object are distinct roles.

## Источники / Sources

- [Martin Fowler — Data Transfer Object](https://martinfowler.com/eaaCatalog/dataTransferObject.html) — Определение и границы паттерна.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md), [уточнение 21 ноября](../../TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
