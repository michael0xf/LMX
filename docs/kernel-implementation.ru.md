# Реализация ядра — русская редакция готовится

**Действует английская редакция от 21 ноября 2026 года:** [kernel-implementation.en.md](kernel-implementation.en.md).

Прежний русский текст описывал норму до 2026-11-21. Он снят, чтобы устаревшие правила не читались как
действующие, и сохранён в истории репозитория: `git show 150f01f5:docs/kernel-implementation.ru.md`. Русский перевод новой редакции —
отдельный шаг [плана](../next_core_tasks_v3.md#docs-20261121).

Ниже — якоря английской редакции. Ссылки из русских документов ведут на эти якоря, а отсюда — в
английский текст.

<a id="binding-callables-20261119"></a>
- [Current call and graph baseline](kernel-implementation.en.md#binding-callables-20261119)

<a id="principles"></a>
- [1. Principles](kernel-implementation.en.md#principles)

<a id="contract"></a>
- [1a. The builder and the two consumers](kernel-implementation.en.md#contract)

<a id="arena"></a>
- [2. The arena](kernel-implementation.en.md#arena)

<a id="value-record"></a>
- [2.0. Value records](kernel-implementation.en.md#value-record)

<a id="lmx"></a>
- [3. The Lmx graph](kernel-implementation.en.md#lmx)

<a id="get-descriptor"></a>
- [3.1.1. Actual header addresses](kernel-implementation.en.md#get-descriptor)

<a id="header-receivers"></a>
- [3.1.2. Header and service queries](kernel-implementation.en.md#header-receivers)

<a id="system-indexof"></a>
- [3.1.3. A field's physical index](kernel-implementation.en.md#system-indexof)

<a id="primitive-storage"></a>
- [3.2. Primitive places and exact scalar ABI](kernel-implementation.en.md#primitive-storage)

<a id="operand-contract"></a>
- [3.3.1. Ordinary methods used as operands](kernel-implementation.en.md#operand-contract)

<a id="call-receivers"></a>
- [Structural call](kernel-implementation.en.md#call-receivers)

<a id="fn-signature"></a>
- [Named positional signatures](kernel-implementation.en.md#fn-signature)

<a id="declaration-selection"></a>
- [Explicit-only selection and actual effects](kernel-implementation.en.md#declaration-selection)

<a id="private-binding"></a>
- [Two-way private and place ownership](kernel-implementation.en.md#private-binding)

<a id="call-frame-20261115"></a>
- [Call-local declarations and passed forms](kernel-implementation.en.md#call-frame-20261115)

<a id="declaration-arguments"></a>
- [declaration-arguments](kernel-implementation.en.md#declaration-arguments)

<a id="names"></a>
- [4. Identifier strings](kernel-implementation.en.md#names)

<a id="tables"></a>
- [5. Tables and correspondences](kernel-implementation.en.md#tables)

<a id="interpreter"></a>
- [6. The interpreter](kernel-implementation.en.md#interpreter)

<a id="direct-access-cache"></a>
- [direct-access-cache](kernel-implementation.en.md#direct-access-cache)

<a id="endturn-receiver"></a>
- [endturn-receiver](kernel-implementation.en.md#endturn-receiver)

<a id="flush-receiver-contract"></a>
- [6.6. No local-frame publication](kernel-implementation.en.md#flush-receiver-contract)

<a id="native"></a>
- [7. Native and the C boundary](kernel-implementation.en.md#native)

<a id="codec"></a>
- [8. Graph serialization and restoration](kernel-implementation.en.md#codec)

<a id="audit"></a>
- [9. Legacy representation audit](kernel-implementation.en.md#audit)

<a id="example"></a>
- [10. Worked places and stream examples](kernel-implementation.en.md#example)

<a id="transition"></a>
- [11. Acceptance and implementation integration](kernel-implementation.en.md#transition)
