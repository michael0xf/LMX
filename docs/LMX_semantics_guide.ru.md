# Руководство по семантике LMX — русская редакция готовится

**Действует английская редакция от 21 ноября 2026 года:** [LMX_semantics_guide.en.md](LMX_semantics_guide.en.md).

Прежний русский текст описывал норму до 2026-11-21. Он снят, чтобы устаревшие правила не читались как
действующие, и сохранён в истории репозитория: `git show 150f01f5:docs/LMX_semantics_guide.ru.md`. Русский перевод новой редакции —
отдельный шаг [плана](../next_core_tasks_v3.md#docs-20261121).

Ниже — якоря английской редакции. Ссылки из русских документов ведут на эти якоря, а отсюда — в
английский текст.

<a id="data-receiver-execution"></a>
- [Preparation does not execute the program](LMX_semantics_guide.en.md#data-receiver-execution)

<a id="blank-line-blocks"></a>
- [Blank lines are full block boundaries](LMX_semantics_guide.en.md#blank-line-blocks)

<a id="admission-stages"></a>
- [Admission and build checks](LMX_semantics_guide.en.md#admission-stages)

<a id="callable-description"></a>
- [Input description and composition](LMX_semantics_guide.en.md#callable-description)

<a id="receiver-arities"></a>
- [Place and value with `int` and `@`](LMX_semantics_guide.en.md#receiver-arities)

<a id="header-receivers"></a>
- [Header and service tables](LMX_semantics_guide.en.md#header-receivers)

<a id="get-descriptor"></a>
- [Header-field addresses through descriptor](LMX_semantics_guide.en.md#get-descriptor)

<a id="system-indexof"></a>
- [A field's index](LMX_semantics_guide.en.md#system-indexof)

<a id="callable-admission"></a>
- [What the callable interface check proves](LMX_semantics_guide.en.md#callable-admission)

<a id="method-pointer"></a>
- [A method name and a pointer to it](LMX_semantics_guide.en.md#method-pointer)

<a id="native-structures"></a>
- [Native and interpreter frames](LMX_semantics_guide.en.md#native-structures)

<a id="call-receivers"></a>
- [Structural call: `call`, `C()` and `C(args)`](LMX_semantics_guide.en.md#call-receivers)

<a id="structural-call"></a>
- [Structural call: `call`, `C()` and `C(args)`](LMX_semantics_guide.en.md#structural-call)

<a id="root-entry"></a>
- [root-entry](LMX_semantics_guide.en.md#root-entry)

<a id="removed-builtins"></a>
- [removed-builtins](LMX_semantics_guide.en.md#removed-builtins)

<a id="fn-signature"></a>
- [Named fn signatures and ordinary templates](LMX_semantics_guide.en.md#fn-signature)

<a id="return-in-data"></a>
- [return-in-data](LMX_semantics_guide.en.md#return-in-data)

<a id="declaration-selection"></a>
- [Declaration selection: readings W and E](LMX_semantics_guide.en.md#declaration-selection)

<a id="selection-examples"></a>
- [selection-examples](LMX_semantics_guide.en.md#selection-examples)

<a id="binding-places"></a>
- [Binding: own place and the caller's place](LMX_semantics_guide.en.md#binding-places)

<a id="binding-autofill"></a>
- [binding-autofill](LMX_semantics_guide.en.md#binding-autofill)

<a id="binding-caller-place"></a>
- [binding-caller-place](LMX_semantics_guide.en.md#binding-caller-place)

<a id="binding-fallback"></a>
- [binding-fallback](LMX_semantics_guide.en.md#binding-fallback)

<a id="binding-chain"></a>
- [binding-chain](LMX_semantics_guide.en.md#binding-chain)

<a id="private-binding"></a>
- [Receiver private: in both directions](LMX_semantics_guide.en.md#private-binding)

<a id="private-examples"></a>
- [private-examples](LMX_semantics_guide.en.md#private-examples)

<a id="shadowing-levels"></a>
- [Shadowing of levels](LMX_semantics_guide.en.md#shadowing-levels)

<a id="inline-declaration-control"></a>
- [inline-declaration-control](LMX_semantics_guide.en.md#inline-declaration-control)

<a id="call-frame-20261115"></a>
- [The call frame](LMX_semantics_guide.en.md#call-frame-20261115)

<a id="declaration-arguments"></a>
- [Passing a declaration form for repeated execution](LMX_semantics_guide.en.md#declaration-arguments)

<a id="binding-executors"></a>
- [binding-executors](LMX_semantics_guide.en.md#binding-executors)

<a id="flush-receiver-contract"></a>
- [flush-receiver-contract](LMX_semantics_guide.en.md#flush-receiver-contract)

<a id="direct-access-cache"></a>
- [direct-access-cache](LMX_semantics_guide.en.md#direct-access-cache)

<a id="native-merge"></a>
- [Compilation, mutation, and the next turn](LMX_semantics_guide.en.md#native-merge)

<a id="field-streams"></a>
- [Import, copy, and merge supply fields through the namespace](LMX_semantics_guide.en.md#field-streams)

<a id="stream-grouping"></a>
- [A field stream and one explicitly grouped Structure](LMX_semantics_guide.en.md#stream-grouping)

<a id="import-selection"></a>
- [Import keeps original identities and parents](LMX_semantics_guide.en.md#import-selection)

<a id="copy-relations"></a>
- [Copy maps preserve graph relationships](LMX_semantics_guide.en.md#copy-relations)

<a id="factory-result"></a>
- [A returned method and a copied product](LMX_semantics_guide.en.md#factory-result)

<a id="dynamic-fallback"></a>
- [Dynamic and lexical sources](LMX_semantics_guide.en.md#dynamic-fallback)

<a id="message-conversion-context"></a>
- [Message conversion context](LMX_semantics_guide.en.md#message-conversion-context)

<a id="post-transport"></a>
- [post: one call, multiple deliveries](LMX_semantics_guide.en.md#post-transport)

<a id="tables-and-registries"></a>
- [Tables and providers as data](LMX_semantics_guide.en.md#tables-and-registries)

<a id="expression-priority"></a>
- [Priorities, value dependencies, and assignment effects](LMX_semantics_guide.en.md#expression-priority)

<a id="operand-templates"></a>
- [A user operand is an ordinary method](LMX_semantics_guide.en.md#operand-templates)

<a id="operand-values"></a>
- [Prepared-value mode: PASS_ARGS_AS_IS 0](LMX_semantics_guide.en.md#operand-values)

<a id="operand-raw"></a>
- [Original-occurrence mode: PASS_ARGS_AS_IS 1](LMX_semantics_guide.en.md#operand-raw)

<a id="operand-references"></a>
- [References, storage, and explicit addresses](LMX_semantics_guide.en.md#operand-references)

<a id="operand-name-priority"></a>
- [Name strings and priorities](LMX_semantics_guide.en.md#operand-name-priority)
