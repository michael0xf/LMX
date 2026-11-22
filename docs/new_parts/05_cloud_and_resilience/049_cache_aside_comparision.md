# 049. Cache-Aside

Приложение загружает отсутствующее значение и явно инвалидирует кэш после записи в хранилище.

## Общий сценарий

Для одного фиксированного ключа store содержит 7. Выполнить get,get,put(9),get.

**Ожидаемое наблюдение:** Чтения возвращают 7,7,9; store.read вызван дважды. put сначала меняет store, затем сбрасывает ready.

**Граница сравнения:** Протокол и порты. TTL, внешние писатели, cache stampede между разными владельцами и сбой между записью и invalidation требуют дополнительного протокола.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
CacheMessage:
    @: store
    int: value
    int: ready 0
    int: cached 0
    return: int
    get:
        if: node\ready = 0
            node\cached := store\read()
            node\ready := 1
        return: node\cached
    put:
        store\write(value)
        node\ready := 0
        return: value
```

LMX: структура с суффиксом Message — шаблон отдельного исполняемого Message. Хост явно создаёт его Thread с собственной ареной; удалённые вызовы допускаются через post/HTTP-профиль. Каждый обработчик выполняется на последовательной полосе владельца. Это ядро обработчика, а не полный запускаемый сервер. Общая обвязка и её стоимость описаны в MESSAGE_HTTP_PROFILE.md. store.read(): int / write(int): void — предоставленное хранилище одного ключа с завершёнными операциями. Все get/put данного кэша идут последовательно; отдельный ready отличает отсутствие от числового нуля.

[Отдельный листинг](examples/lmx/049_cache_aside.lm3)

## Go

```go
type Store interface { Read() int; Write(int) }
type Cache struct { store Store; ready bool; value int }
func (c *Cache) Get() int {
    if !c.ready { c.value = c.store.Read(); c.ready = true }
    return c.value
}
func (c *Cache) Put(v int) int { c.store.Write(v); c.ready = false; return v }
```

store.read(): int / write(int): void — предоставленное хранилище одного ключа с завершёнными операциями. Все get/put данного кэша идут последовательно; отдельный ready отличает отсутствие от числового нуля. Фрагмент Go использует переданные функции/интерфейсы; package и запускающий тест остаются общей обвязкой.

[Отдельный листинг](examples/go/049_cache_aside.go)

## C#

```csharp
interface IStore { int Read(); void Write(int value); }
sealed class Cache(IStore store) {
    bool ready; int value;
    public int Get() {
        if (!ready) { value = store.Read(); ready = true; }
        return value;
    }
    public int Put(int v) { store.Write(v); ready = false; return v; }
}
```

store.read(): int / write(int): void — предоставленное хранилище одного ключа с завершёнными операциями. Все get/put данного кэша идут последовательно; отдельный ready отличает отсутствие от числового нуля. Фрагмент C# использует переданные делегаты; namespace и запускающий тест остаются общей обвязкой.

[Отдельный листинг](examples/csharp/049_cache_aside.cs)

## Разбор LMX

LMX: структура с суффиксом Message — шаблон отдельного исполняемого Message. Хост явно создаёт его Thread с собственной ареной; удалённые вызовы допускаются через post/HTTP-профиль. Каждый обработчик выполняется на последовательной полосе владельца. Это ядро обработчика, а не полный запускаемый сервер. Общая обвязка и её стоимость описаны в MESSAGE_HTTP_PROFILE.md. store.read(): int / write(int): void — предоставленное хранилище одного ключа с завершёнными операциями. Все get/put данного кэша идут последовательно; отдельный ready отличает отсутствие от числового нуля.

## Сопоставление

LMX хранит кэш у Message-владельца, контролирующего get и put. Контрольные версии имеют то же confinement; это не многоклиентский распределённый согласованный кэш.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 182 | 15 |
| Go | 234 | 7 |
| C# | 222 | 9 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

The application loads a missing value and explicitly invalidates the cache after a store update.

**Scenario.** For one fixed key the store contains 7. Execute get,get,put(9),get.

**Expected observation.** Reads return 7,7,9; store.read is called twice. put updates the store before clearing ready.

**LMX.** LMX: a structure suffixed Message is a template for a separately created executable Message. The host explicitly creates its Thread and arena; addressed calls use post or the HTTP profile. Handlers run on the owner serial lane. This is a handler core, not a complete runnable server. Shared integration and its cost are documented in MESSAGE_HTTP_PROFILE.md. store.read(): int / write(int): void is a supplied single-key store with completed operations. All cache get/put calls are serial; ready distinguishes absence from zero.

**Comparison.** LMX places the cache in its owner Message, controlling get and put. Control versions have the same confinement; this is not a globally coherent distributed cache.

**Scope and limitations.** TTL, external writers, cross-owner cache stampedes and failure between write and invalidation require additional protocol.

### Dependencies and execution boundaries

- **LMX:** LMX: a structure suffixed Message is a template for a separately created executable Message. The host explicitly creates its Thread and arena; addressed calls use post or the HTTP profile. Handlers run on the owner serial lane. This is a handler core, not a complete runnable server. Shared integration and its cost are documented in MESSAGE_HTTP_PROFILE.md. store.read(): int / write(int): void is a supplied single-key store with completed operations. All cache get/put calls are serial; ready distinguishes absence from zero.
- **Go:** store.read(): int / write(int): void is a supplied single-key store with completed operations. All cache get/put calls are serial; ready distinguishes absence from zero. This Go fragment uses supplied functions/interfaces; package and test entry are shared harness.
- **C#:** store.read(): int / write(int): void is a supplied single-key store with completed operations. All cache get/put calls are serial; ready distinguishes absence from zero. This C# fragment uses supplied delegates; namespace and test entry are shared harness.

## Источники / Sources

- [Microsoft Azure — Cache-Aside](https://learn.microsoft.com/en-us/azure/architecture/patterns/cache-aside) — Приложение загружает отсутствующее значение и явно инвалидирует кэш после записи в хранилище.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md), [уточнение 21 ноября](../../tasks/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
