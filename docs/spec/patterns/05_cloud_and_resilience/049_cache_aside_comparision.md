# 049. Cache-Aside

Приложение загружает отсутствующее значение и явно инвалидирует кэш после записи в хранилище.

## Общий сценарий

Для одного фиксированного ключа store содержит 7. Выполнить get,get,put(9),get.

**Ожидаемое наблюдение:** Чтения возвращают 7,7,9; store.read вызван дважды. put сначала меняет store, затем сбрасывает ready.

**Граница сравнения:** Протокол и порты. TTL, внешние писатели, cache stampede между разными владельцами и сбой между записью и invalidation требуют дополнительного протокола.

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

### Асинхронная граница

Прикладной протокол выполняется обычными turns Message. post уже обеспечивает адресованный вызов, корреляцию и доставку обработчиков; второй scheduler не требуется. post не реализует очередь, транзакцию, barrier отмены или внешний I/O provider этого протокола: явно объявленные порты сохраняют свои договоры.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 182 | 15 |
| Go | 234 | 7 |
| C# | 222 | 9 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Все объявления, аргументы и ссылки на общий банк ошибок учитываются целиком.

## English explanation

The application loads a missing value and explicitly invalidates the cache after a store update.

**Scenario.** For one fixed key the store contains 7. Execute get,get,put(9),get.

**Expected observation.** Reads return 7,7,9; store.read is called twice. put updates the store before clearing ready.

**LMX.** LMX: a structure suffixed Message is a template for a separately created executable Message. The host explicitly creates its Thread and arena; addressed calls use post or the HTTP profile. Handlers run on the owner serial lane. This is a handler core, not a complete runnable server. Shared integration and its cost are documented in MESSAGE_HTTP_PROFILE.md. store.read(): int / write(int): void is a supplied single-key store with completed operations. All cache get/put calls are serial; ready distinguishes absence from zero.

**Comparison.** LMX places the cache in its owner Message, controlling get and put. Control versions have the same confinement; this is not a globally coherent distributed cache.

**Scope and limitations.** TTL, external writers, cross-owner cache stampedes and failure between write and invalidation require additional protocol.

The shown application protocol runs on existing Message turns. post already supplies addressed invocation, reply correlation and handler delivery; it needs no second scheduler here. It does not supply this protocol’s queue, transaction, cancellation barrier or external I/O provider. Those explicitly declared ports retain their stated contracts; this listing is not a hidden implementation of an entire networking/storage library.

### Dependencies and execution boundaries

- **LMX:** LMX: a structure suffixed Message is a template for a separately created executable Message. The host explicitly creates its Thread and arena; addressed calls use post or the HTTP profile. Handlers run on the owner serial lane. This is a handler core, not a complete runnable server. Shared integration and its cost are documented in MESSAGE_HTTP_PROFILE.md. store.read(): int / write(int): void is a supplied single-key store with completed operations. All cache get/put calls are serial; ready distinguishes absence from zero.
- **Go:** store.read(): int / write(int): void is a supplied single-key store with completed operations. All cache get/put calls are serial; ready distinguishes absence from zero. This Go fragment uses supplied functions/interfaces; package and test entry are shared harness.
- **C#:** store.read(): int / write(int): void is a supplied single-key store with completed operations. All cache get/put calls are serial; ready distinguishes absence from zero. This C# fragment uses supplied delegates; namespace and test entry are shared harness.

## Источники / Sources

- [Microsoft Azure — Cache-Aside](https://learn.microsoft.com/en-us/azure/architecture/patterns/cache-aside) — Приложение загружает отсутствующее значение и явно инвалидирует кэш после записи в хранилище.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
