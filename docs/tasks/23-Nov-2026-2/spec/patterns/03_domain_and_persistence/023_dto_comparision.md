# 023. DTO — Data Transfer Object

Собрать разрешённые поля в одно передаваемое значение.

## Общий сценарий

Доменная запись имеет id=7, cents=1250 и секретное поле token. Проекция export выбирает только id и cents.

**Ожидаемое наблюдение:** Результат содержит ровно id=7 и cents=1250; token и методы доменного объекта не попадают в DTO.

**Граница сравнения:** Ядро сценария. Сетевой round trip не исполняется листингом. Транспортный профиль задаёт кодировку, versioning и допуск; DTO не является Value Object только из-за отсутствия методов.

## LMX

```lmx
independent: AccountDto:
    int: id 0
    int: cents 0

Export:
    @: account
    return: @
    dto:
        return: (merge(AccountDto; (int: id account\id; int: cents account\cents)))
```

AccountDto — independent-шаблон двух готовых примитивных полей. dto копирует его, явно записывает вычисленные значения в слоты и возвращает готовый DTO. HTTP-профиль LMX уже передаёт application/lmx; проекция предшествует сериализации и Message intake. Сокращение 23-Nov: One merge initializes both independent DTO fields; the source account is not returned.

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

AccountDto — independent-шаблон двух готовых примитивных полей. dto копирует его, явно записывает вычисленные значения в слоты и возвращает готовый DTO. HTTP-профиль LMX уже передаёт application/lmx; проекция предшествует сериализации и Message intake. Сокращение 23-Nov: One merge initializes both independent DTO fields; the source account is not returned.

## Сопоставление

Во всех трёх вариантах проекция явная. Само наличие сериализатора не делает автоматическую выгрузку всего доменного графа подходящим DTO.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки | Без сложного Throws |
| --- | ---: | ---: | ---: |
| LMX | 136 | 8 | 136 |
| Python | 145 | 7 | — |
| C# | 197 | 5 | — |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Дополнительная колонка «без сложного Throws» оставляет заголовок и первый аргумент каждого списка в исходном порядке, полностью считает ссылки/copy и первый аргумент общего банка. Меняется только расчёт, не исходник или контракт.

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

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
