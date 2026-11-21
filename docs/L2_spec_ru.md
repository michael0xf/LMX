# Спецификация L2 — русская редакция готовится

**Действует английская редакция от 21 ноября 2026 года:** [L2_spec_en.md](L2_spec_en.md).

Прежний русский текст описывал норму до 2026-11-21. Он снят, чтобы устаревшие правила не читались как
действующие, и сохранён в истории репозитория: `git show 150f01f5:docs/L2_spec_ru.md`. Русский перевод новой редакции —
отдельный шаг [плана](../next_core_tasks_v3.md#docs-20261121).

Ниже — якоря английской редакции. Ссылки из русских документов ведут на эти якоря, а отсюда — в
английский текст.

<a id="scope"></a>
- [1. Scope](L2_spec_en.md#scope)

<a id="lmx"></a>
- [2. The `Lmx` structure](L2_spec_en.md#lmx)

<a id="interpretable-tree"></a>
- [2.1. Interpretable tree](L2_spec_en.md#interpretable-tree)

<a id="get-descriptor"></a>
- [2.2. descriptor and actual header fields](L2_spec_en.md#get-descriptor)

<a id="header-receivers"></a>
- [2.3. Reading the header and service tables](L2_spec_en.md#header-receivers)

<a id="system-indexof"></a>
- [2.4. A field's index](L2_spec_en.md#system-indexof)

<a id="type-by-range"></a>
- [3. Value record: the type beside the value](L2_spec_en.md#type-by-range)

<a id="value-record"></a>
- [3. Value record: the type beside the value](L2_spec_en.md#value-record)

<a id="uninit-record-control"></a>
- [3.1. P01 resolved — a type code without a value](L2_spec_en.md#uninit-record-control)

<a id="pool"></a>
- [4. Allocation of records](L2_spec_en.md#pool)

<a id="method-array"></a>
- [5. Native entry and Array](L2_spec_en.md#method-array)

<a id="arena"></a>
- [6. Arena](L2_spec_en.md#arena)

<a id="array-capacity"></a>
- [6.1. Common variable-size Arrays and capacity](L2_spec_en.md#array-capacity)

<a id="message"></a>
- [7. Message record](L2_spec_en.md#message)

<a id="thread"></a>
- [8. L3 Thread](L2_spec_en.md#thread)

<a id="root-close"></a>
- [8.1. R0 and shutdown](L2_spec_en.md#root-close)

<a id="mailbox"></a>
- [9. Mailbox](L2_spec_en.md#mailbox)

<a id="own"></a>
- [10. Structure execution](L2_spec_en.md#own)

<a id="call"></a>
- [11. Call](L2_spec_en.md#call)

<a id="call-receivers"></a>
- [Structural call and the `call` receiver](L2_spec_en.md#call-receivers)

<a id="structural-call"></a>
- [Structural call and the `call` receiver](L2_spec_en.md#structural-call)

<a id="return-in-data"></a>
- [Result: `return` in data](L2_spec_en.md#return-in-data)

<a id="fn-signature"></a>
- [The `fn` signature](L2_spec_en.md#fn-signature)

<a id="declaration-selection"></a>
- [Declaration selection](L2_spec_en.md#declaration-selection)

<a id="binding-places"></a>
- [Binding: own place and caller's place](L2_spec_en.md#binding-places)

<a id="binding-autofill"></a>
- [binding-autofill](L2_spec_en.md#binding-autofill)

<a id="binding-caller-place"></a>
- [binding-caller-place](L2_spec_en.md#binding-caller-place)

<a id="binding-fallback"></a>
- [binding-fallback](L2_spec_en.md#binding-fallback)

<a id="binding-chain"></a>
- [binding-chain](L2_spec_en.md#binding-chain)

<a id="private-binding"></a>
- [Receiver private: two-way `private`](L2_spec_en.md#private-binding)

<a id="call-frame-20261115"></a>
- [Call frame](L2_spec_en.md#call-frame-20261115)

<a id="declaration-arguments"></a>
- [Declaration receivers supplied as arguments](L2_spec_en.md#declaration-arguments)

<a id="shadowing-levels"></a>
- [shadowing-levels](L2_spec_en.md#shadowing-levels)

<a id="inline-declaration-control"></a>
- [inline-declaration-control](L2_spec_en.md#inline-declaration-control)

<a id="binding-executors"></a>
- [Native code, the walker and the bridge](L2_spec_en.md#binding-executors)

<a id="catch-common-model"></a>
- [`catch` in the common model](L2_spec_en.md#catch-common-model)

<a id="native-structures"></a>
- [11.1. Explicit compilation and direct native calls](L2_spec_en.md#native-structures)

<a id="direct-access-cache"></a>
- [11.1. Explicit compilation and direct native calls](L2_spec_en.md#direct-access-cache)

<a id="explicit-compilation"></a>
- [11.1. Explicit compilation and direct native calls](L2_spec_en.md#explicit-compilation)

<a id="endturn-receiver"></a>
- [11.2. sys\endturn](L2_spec_en.md#endturn-receiver)

<a id="child"></a>
- [12. Child reservation](L2_spec_en.md#child)

<a id="copy-merge"></a>
- [13. Import, copy, merge, and namespace field streams](L2_spec_en.md#copy-merge)

<a id="implements"></a>
- [14. implements](L2_spec_en.md#implements)

<a id="gc"></a>
- [15. Collection](L2_spec_en.md#gc)

<a id="special"></a>
- [16. Special L2 operations](L2_spec_en.md#special)

<a id="lowlevel-scope"></a>
- [17. Machine profile](L2_spec_en.md#lowlevel-scope)

<a id="lowlevel-address"></a>
- [18. Addresses, loading, and writing](L2_spec_en.md#lowlevel-address)

<a id="lowlevel-array"></a>
- [19. Raw C storage](L2_spec_en.md#lowlevel-array)

<a id="lowlevel-abi"></a>
- [20. External types and ABI](L2_spec_en.md#lowlevel-abi)

<a id="lowlevel-expression"></a>
- [21. Machine expressions and ordinary operand methods](L2_spec_en.md#lowlevel-expression)

<a id="operand-contract"></a>
- [Operand discovery and typed transport](L2_spec_en.md#operand-contract)

<a id="raw-operand-context"></a>
- [Raw arguments and the shared evaluator](L2_spec_en.md#raw-operand-context)

<a id="name-priority"></a>
- [Name strings and priority queries](L2_spec_en.md#name-priority)

<a id="lowlevel-sync"></a>
- [22. synchronized](L2_spec_en.md#lowlevel-sync)
