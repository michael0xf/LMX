# Дефекты — отдельный список (автор, 2026-09-24: «дефекты вносите в отдельный список и поправляйте сразу как находите»)

Правило: любой измеренный дефект (падение, молчаливый отказ, неверное значение, мёртвый/устаревший код, расхождение с принятой нормой, для которого норма уже есть) заносится сюда в момент обнаружения и **исправляется сразу**, отдельным малым тикетом, не дожидаясь стадии плана. Пункты плана `next_core_tasks.md` — нормы и стадии; дефекты живут здесь. Запись: дата · где найден · минимальная программа/анкер · владелец · статус (OPEN / IN WORK <тикет> / FIXED <SHA>). Закрытый дефект остаётся в списке с SHA (история), не удаляется.

## Текущие и недавно закрытые

<a id="compiler-text-view-ownership"></a>
### COMPILER-TEXT-VIEW-OWNERSHIP — 2026-10-03, Codex, IN WORK

Targeted allocation probes for the shared Array-place slice expose a counted
translation-storage residue even on the successful baseline: n2295/free1227/
live1068. Failing its first retained compact-head allocation leaves live1065;
therefore that residue does not require any successful new head-cache or path
workspace allocation. Do not claim that all1065 have one cause without exact
pointer tracing.

Source-confirmed older ownership gaps: `l2_text_skip` allocates a Text view
without an owner, while repeated `l2_foreign_intern` may return an existing
type without retaining/releasing that view; `l2_foreign_free` drops the
registry arrays but not owned views. The static Lmx/sender/payload Text caches
also require explicit lifetime review. These are compiler Text views, not
language atoms or permission to add runtime metadata.

Repair the common ownership boundary: transient views must not accumulate
for repeated classification, and any retained view must have an exact owner
and release path. Preserve raw-C admission, primitive/foreign contract
identity and source-byte lifetime. A whole-allocation list or a runtime graph
is not a substitute. Exact evidence and limitations:
[resource probe](critical-graph-namespace-source-layout-20261003.md#array-place-resource-evidence).
The initial probe is historical evidence, not an all-heap leak certificate.
The follow-up sandbox slice removes transient heap views and lets the
existing type interner own one Text-plus-bytes block per new entry. Existing
fixed-name pointer caches retain one literal-backed view each and are freed
and reset at the translation's release boundary; the Array descriptor name
is a borrowed local view. Sender/payload cache failures are diagnosed before
their namespace rows are published. Focused05 is GREEN41 but exact pointer
tracking still finds1068 leaked addresses:1065 table names, two procedure
adapter shells and one discarded foreign-type name. The final owner repair
frees table names, synthetic shells before borrowed P0 document destruction,
and interner rows before count rollback. Focused06 is GREEN41 and the
independent until/trailer07 gate GREEN11 on source3B903EC6. Exact tracing
frees all2296 counted baseline allocations and all1453 allocations after
the second retained-cache allocation fails. P0/uncounted CRT allocations
are not covered. Full24 completes RED199/1329: the lazy-load oracle
recovers, but15 exact unresolved-name locations regress, while184 old
failure details remain unchanged. Cloning dynamic-name bytes broke
`l2_source_text`'s original-byte identity. The follow-up keeps an owned
Text view in the existing dynamic table with borrowed original bytes;
the foreign interner still owns independent byte copies. Provenance08
is GREEN64 on6E4E0FD8, restoring all15 locations and preserving the
previous ownership/Array/until controls. Full25 completes RED184/1329 on
that source: all15 locations recover, with184 unchanged failure details,
no added/removed target and no new regression relative to full24.
Fresh exact traces on frozen08 independently free all2296 baseline and
all1453 retained-second-cache failure allocations, with zero outstanding
counted addresses. Uncounted P0/CRT remains outside this scoped certificate;
the result is not an inference from frozen06.
This is not a runtime graph or a claim that source reconstruction is complete.

Preserved attempts `critical_graph_text_ownership_01`/02 fail before building
the compiler: a global valued foreign Text is checked before predef types
are registered. Attempt03's explicit `foreign` duplicates its registration
on the pinned L1 validator's second pass. No L1/parser edit or fake qualifier
was introduced to hide that ordering defect. Attempt04 builds the compiler
but refuses a misspelled selected fixture name. These four attempts are not
accepted gates or cleanup evidence. Full hashes, mechanisms, fault controls
and remaining diagnostic limitations:
[bounded ownership evidence](critical-graph-namespace-source-layout-20261003.md#compiler-ownership-evidence).

<a id="graph-builder-observer-identity"></a>
### GRAPH-BUILDER-OBSERVER-IDENTITY — 2026-10-03, Codex, IN WORK

The harness's text observer confused reusable construction locals with
allocated graph objects. A namespace body read through its existing `nsp`
handle lost executable reachability relative to an equivalent unit-slot
spelling. A native binding to an unknown leaf could inherit a prior method's
slot. These are harness defects, not permission to alter runtime storage.

The bounded repair scans only the actual emitted program builder, observes
each existing allocation and its current aliases in statement order, and
preserves captured root edges/native targets across later leaf reuse.
Explicit zero/replacement stores remove prior edges, including stores through
an alias of the root. Namespace handle identity changes or repeated allocation
are refused by this limited observer rather than merged speculatively.
Observer allocation tags exist only in the test's transient facts, never in
the language graph or compiler output.

The ignored local pure-control script
`build/l2_harness/critical_graph_builder_identity_oracle_01.ps1` passes27
controls without a compiler build or program execution. It preserves exact
reachable sets44/63/121/43 for four frozen full25 artifacts under equivalent
namespace alias spelling. Controls reject stale slots, unknown/forward aliases,
cycles, explicit nulls, ambiguous root attachments, allocation reuse and
identity-changing rebinding; another function cannot overwrite builder facts.
Two sequential ordinary allocations through the same leaf stay distinct.
An earlier unresolved direct-slot binding is also refused when final writes
clear that slot or replace it with a different object.
This is not a full emitted-code dataflow proof or independent source decoder.
Focused05 tests the first25-control observer: the existing102 rows and two
new sibling rows pass; the two new copied-parent rows are refused by the
translator, not by this observer. The last direct-slot guards are later than
frozen05. Full26 completes RED188/1343:184 old failures are unchanged;
two old shape observers omit retained INIT, and two new language copy-call
witnesses refuse. The exact INIT/copy observer and eight damage controls
subsequently pass in focused07/08/09. Full27 completes RED189/1351 on070B6123:
the two INIT observers recover, three shared explicit-copy call rows refuse,
and186 other failure details remain unchanged. Later output binding05 is
RED7/139; expanded merge/output01 is RED7/152 with unchanged failures.
These focused results do not certify a full later-source gate or source
reconstruction.

<a id="graph-computed-output-place"></a>
### GRAPH-COMPUTED-OUTPUT-PLACE — 2026-10-03, Codex, bounded cut verified

Synthetic null-storage siblings inflated repeated-output body width10 versus
source width8. Translator5CDEF70B now stores each computed descriptor in child1
of its real output OWN/AT operand. Borrows share that edge; explicit typed
targets retain their cells. No pointer-cell, second graph or runtime metadata.
Focused compact02 GREEN13 verifies width, parents, distinct places, aliases,
names and four damage controls at unchanged result7. Ordinary kernel compact02
GREEN292 executes109 selftests; new output-place witness passes16 checks,
including copied cached/physical isolation and compact immutable no-store.
The earlier RED1/292 kernel compact01 was a new test's L1 grouping error only.
Compact03/04 RED10/154 expose three old static OWN/alias expectations;
compact05 RED7/154 restores those three rows. Later line-time/last-store
observer fixes pass21 controls; two actual runtime mutants exit1. L3 compact01
passes11 suites and four budget units. Full28 on intermediate F9F42142 is
terminal RED203/1361. Its15 newly failing rows recover in compact06 GREEN33:
six foreign-holder C failures, two typed @: producer failures, four compact
shape expectations and three migrated receiving fixtures. Four additional
historical-fixture migrations pass GREEN14 without restoring implicit merge.
Full29 is terminal RED184/1361:19 recoveries, zero new failing rows against
full28. Later path-schema03 is GREEN43 on5A70F7CB/8A013A1D, repairing common
method/body-to-own/schema paths, registered-body merge/ABI/receive planning
and authoritative path/literal CHECK diagnostics. Three obsolete text pins
now observe copy independence and recursive123 at exit7. Neither result
closes the full source-graph or pointer ticket.
Full30 is RED138/1364:47 common recoveries, three new positives and one
root-versus-tail diagnostic regression. The common root-resolver repair
restores that row in focused05 RED1/10; the unchanged local S producer remains
the sole focused refusal. [Delta and connected next slice](critical-graph-namespace-source-layout-20261003.md#full30-local-source-next).
Typed @Structure and current held callable/capture are not repaired by this
placement cut. [Exact bytes and boundaries](critical-graph-namespace-source-layout-20261003.md#compact-output-place).

<a id="local-source-and-capture-place"></a>
### LOCAL-SOURCE-AND-CAPTURE-PLACE — 2026-10-03, Codex, OPEN

The unchanged `unit_local_ns_node_nested` is refused at S's declaration in
full29 and path-schema02. Local namespaces lack an original-body route into
the common source producer; their native field constructor is not a complete
retained graph. NODE projections lack their precise lexical stop. Capture
collection accepts only namespace ids; MAD constructors flatten capture
slots and share nonprimitive graph nodes through a primitive-cell helper.
This does not authorize a persistent data context graph. Repair source
occurrence, ownership, full schema, stable required-model instance, complete
place and ordinary composition/copy coherently. [Exact omissions and tests](critical-graph-namespace-source-layout-20261003.md#local-source-capture-closure).

Later sandbox source production is measured in focused12 GREEN24: exact local
registration, full original/T7 bodies, shared namespace-reference fill and
source layout provenance replace reached-declaration cloning. Local S now
persists (measured99); real NODE/local walker controls pass. Updated source
oracles preserve INIT and copied ownership. Run14 RED2/23 isolates new explicit
local-callable-copy refusals; common phase-order repair passes run18 GREEN19
with independent original/copy counters1/1/2/2 under native and actual walking.
The nullary held-call positive, local callable-boundary binding/scanning,
complete capture/actual-input formation, full gates and pointer ticket remain
open. [Measured scope, not release](critical-graph-namespace-source-layout-20261003.md#local-source-producer-measured).

Full31 is RED135/1380:15 common recoveries,11 new discrepancies,16 additive
rows (15 pass; nullary held-call remains a positive failure), no removed rows.
The next scope-boundary correction passes all four new native/walker local
binding/hosted-merge positives in context02 RED11/22; its remaining11 rows
are the full31 discrepancies. UNTIL original-owner projection, opaque-source
walker admission and exact call/declaration classification still need repair;
stale construction regexes must be replaced only with measured physical/effect
assertions. [Full delta and scope evidence](critical-graph-namespace-source-layout-20261003.md#full31-source-context).

Later canonical-cell/admission context10 GREEN24/24 removes duplicated
borrowed-body declaration cells and verifies independent copy storage.
Opaque source facts survive checked pointer cast/return/forwarding; indirect
receiving instructions reserve maps before declaration without attributing
referent writes to pointer holders. A failed admission leaves storage intact
and uses ordinary implements, not INVALID; UNKNOWN is never target proof.
The new ordinal control distinguishes FIRST from LAST. Kernel292/109 actual
selftests and L3 eleven suites/four budgets pass; two status/fallback mutants
are rejected. Full32 on later identity-request cleanup completes RED130/1395:
seven old rows recover, no old green regresses, no target is removed;
13 of15 new targets pass, both new copy-call positives fail. The128 retained
failure summary details are unchanged. The real
copied-Structure R() and nullary held-call positives still refuse; full source
codec/comments, capture/original-owner, old table caps and pointer acceptance
remain OPEN. [Exact scope and witness corrections](critical-graph-namespace-source-layout-20261003.md#canonical-cell-opaque-admission).

<a id="graph-call-origin-current-value"></a>
### GRAPH-CALL-ORIGIN-CURRENT-VALUE — 2026-10-03, Codex, IN WORK

A fresh `copied: merge Outer` has constructor provenance but lacks the
ordinary named-constructor call route. A trial shared `l2_own_call_origin`
consuming `l2_mres_source.layout` passes both copied-parent runtime witnesses.
It is not a closed fix: an actual receiving/reference store can replace a
resolved storage place, while its constructor record remains unchanged.
A separately written computed output can instead declare a new occurrence;
repeated spelling alone proves neither replacement nor identity.
Existing own-layout evidence has the
same lifetime limitation. The copy-origin extension was withdrawn; positive
copy-call refusals remain visible rather than repinned to expected refusal.

The current source factors a stack-only own-place view and receiver output
projection. Prepass/CHECK/native/walker use the same source-site selected
own index, rather than independently selecting first/latest same-name rows.
The next implementation boundary is common native/walker input formation and
admission for the actual selected callable, not mandatory whole-program
constructor-origin replay. Evaluate its current value once; retain the
receiving contract, caller-current dynamic inputs and lexical fallback, then
dispatch its actual native word or graph. Existing prototype-only native
preparation and call-site-only walker witnesses do not supply the candidate's
complete interface. No METHOD/sig record, new Lmx field, native registry,
atom metadata, hidden graph or prototype substitution is permitted.
[Exact scope and witnesses](critical-graph-namespace-source-layout-20261003.md#current-value-call-origin).

<a id="merge-root-copy-identity"></a>
### MERGE-ROOT-COPY-IDENTITY — 2026-10-03, Codex, IN WORK (bounded fix verified)

With one operand, no supplied body and no active overrides, the runtime copied
the closure, then allocated another result root from its child edges. Self
edges and nested backedges still targeted the abandoned copied root; the
published root lost its native word, including on an empty callable body.
The new runtime selftest against frozen baseline1F950CA7 reproduces all four
failures (12 checks, exit1). No source syntax or normative rule changes.

The bounded sandbox fix returns the copier's completed root and publishes its
staged names. Only a fresh copied occurrence gets the execution parent; an
exact retained profile keeps its physical address, old parent and native.
Ordinary kernel fixed02 passes291 targets with108 executed selftests; the
new closure/call witness passes15 checks, names102 and qualified range44.
Mutants returning the original, cancelling names or reparenting a retained
profile are all rejected. L3 passes11 suites plus four budget units; the
expanded focused harness is RED7/152 with no added failure from its RED7/139
scope. General multioperand native selection and critical-graph acceptance
remain open. [Exact hashes and scope](critical-graph-namespace-source-layout-20261003.md#merge-root-integrity).

<a id="critical-graph-bug"></a>
### critical_graph_bug — 2026-10-02, Codex, CRITICAL / OPEN

The retained graph loses source structure during construction: method value
fields/control containers precede an appended executable-step region, and
`l2_body_inert` removes the contents of pure anonymous expressions such as
`(2 + 2)`. The assignment `i: 6` is retained as SET; this is not a claim that
its effect disappears. Independently, unknown `A: b` is refused by
`l2_tail_is_structure` instead of retaining a Structure with atom `b`.

Confirmed by code inspection and five translation-only probes on `36bbefca`;
no new runtime/build gate was run. The full requirement is structural recovery
from the graph, including source-defined field order, while allowing receivers
to materialize typed cells. Runtime results alone cannot establish it.
Owner Codex (inherited sandbox repair in work); the author-requested ticket, exact provenance,
examples and structural/mutation acceptance are in
[critical_graph_bug](tickets/critical_graph_bug.md). This is an open K10 defect,
not implementation completed by this documentation commit.

<a id="critical-pointer-to-struct-bug"></a>
### critical_pointer_to_struct_bug — 2026-10-02, Codex, CRITICAL / OPEN

Source-confirmed descriptor exemption erases one level of unary address-taking:
`@A` returns the Structure descriptor instead of the actual reference-holding
cell. `l2_address_name`, `l2_own_addr`, `l2_emit_address`, `l2_rw_address` all
participate. Ordinary Lmx storage is already by reference; no general C-valued
Structure regression is claimed. Old normative docs duplicated this defect.

Required: A is conceptually Lmx*, @A is Lmx**; preserve real place, depth,
formals/paths/Array-reference parity and C99 pointer-cell storage. No new runtime
gate is claimed by this audit. Take after critical_graph_bug, before the new
reference-application refactoring. Detailed evidence and acceptance:
[critical_pointer_to_struct_bug](tickets/critical_pointer_to_struct_bug.md).
Owner unclaimed; documentation correction is not code closure.

Обязательные позитивы K03 RECEIVE-OUTPUT (Codex K03-OUTPUT-ORACLES-20261007-24), красные до этого маршрута:
`unit_output_named_receive_address` и `unit_output_receive_address_method` (с двойниками) — `@m` выхода `receiveMessage: m`
адресует ячейку, держащую ссылку, и не равен нулю рядом с письмом и рядом с 0; сегодня `@m` равен 0 рядом с 0 (код 82) —
в методе так же, как в теле именованной Structure.

Статус в заголовке относится к текущему состоянию. Описания первоначальных
падений и промежуточных прогонов сохраняют историю проверки; checkpoint
`661735a` включил перечисленные ниже исправления прежнего VERIFIED WIP.
Оставшиеся границы каждого исправления не считаются закрытыми вместе с ним.

<a id="stopped-call-result-consumption"></a>
### STOPPED-CALL-RESULT-CONSUMPTION — 2026-10-01, Codex, FIXED `621e8af`

Общий native/walker ремонт выпущен: адаптер и вызывающий проверяют
существующий stop до потребления результата; walker переносит внутренний
STOPPED, публикует dirty и освобождает scratch. Нормализация в успех без
результата происходит только на публичной границе. Свидетель проходит
47 native / 48 caller-walk проверок; kernel stop — 37/37, focus — 35/35,
kernel — 286/286, L3 — 11/295. Полный gate — 1052/1100, прежние 48 отказов
не изменились. Контрольные поломки различают assertion и runtime-invariant
отказы. [Точные байты, проверки и границы](native-selfbuild-20260930.md#native-call-dispatch).

Ниже — первоначальный дефект и промежуточные свидетельства.

Read-only ревью dispatch focus02 обнаружило смешение остановки Message
с нормальным возвратом. `l2_emit_poll` при `lmx_msg_poll_escape() != 0`
публикует dirty и выдаёт `return: 0`; бросающий метод может поэтому
вернуться без записи `out_result`. Его адаптер принимает нулевой статус
за успешный результат и читает неинициализированный локал (`l2_tv`),
а вызывающий — результат до следующего межоператорного poll. В
`uniform_dispatch_focus_20261001_02/gen/unit_uniform_aggregate.c`
это видно в теле:46–63 и адаптере:428–437. Ошибка раннего «успеха»
предшествует ABI-правке; точный foreign-локал сделал её видимой и в
новом адаптере. Обычные зелёные вызовы не проверяют остановку.

Источник stop уже существует: `Message.running == 0`, проверяемый
`lmx_msg_poll_escape` (`lmx_thread.lm1`). `sendMessage: exit(...)`
сам по себе не доказывает синхронную установку stop. Нужен свидетель
с настоящим `lmx_stop_request` текущего Thread и проверкой дальнейших
эффектов. Общий ремонт должен перенести остановку без чтения/декодирования
отсутствующего результата, следующего фактического аргумента или store;
нативный и интерпретируемый пути сохраняют публикацию и освобождение
activation scratch. Для walker задействовать существующее распространение
управления, не превращать stop в `throw`, INVALID или новое значение.
Новый data-граф и фиктивная инициализация результата нулём не являются
исправлением. Итоговая runtime-проверка приведена выше.

Исходный runtime-дефект независимо подтверждён в
`build/l2_harness/uniform_dispatch_stop_probe_20261001_04` на неизменном
трансляторе `0EE039AF…` (git blob `869b4ba28eba29cb4c571bffb08ee0359e0eea4b`).
Компиляция и линковка зелёные; native — 14 отказов из 47 проверок,
caller-walk — 14 из 48, оба exit 1. Driver останавливает текущий Thread
через `lmx_stop_request`, затем вызывает сохранённый настоящий адаптер
через типизированный `LmxPrimitiveEntry`. Во втором прогоне обнулено
только слово native вызывающего; корень и останавливающий callee остаются
нативными. Нарушаются отсутствие результата, неизменность получателя 99
и запрет следующего аргумента/тела получателя. Проверки реального stop
и предварительной физической публикации 73 проходят. Детерминированных
scalar/store/counter-проверок достаточно: случайные байты foreign-результата
не используются как единственное доказательство.

Пробы 01–03 отказали при подготовке L1-драйвера, до runtime, и не являются
свидетельствами stop. Финальный test-only saved-callback массив типизирован;
переход function-pointer через `void*` не используется. Параллельный
`unit_cf_call_pointer_refused` теперь действительно вызывает callable-формал
с адресом int и читает 41, затем 73; в probe04 он проходит 13 проверок / Entry 7.
Это замена прежнего невыполнявшегося запрета numeric-only allowlist,
не разрешение несовместимой глубины или сигнатуры указателя.

Граница отдельного ремонта C99 ABI —
[небросающий aggregate-result](#nonthrow-aggregate-stop-abi); зелёный
status/out-путь не закрывает её вместе с переносом stop.

<a id="nonthrow-aggregate-stop-abi"></a>
### NONTHROW-AGGREGATE-STOP-ABI — 2026-10-01, Codex, OPEN

Read-only ревью `l2_emit_poll` и typed-body ABI: небросающее тело с результатом
C-aggregate тоже получает `return: 0` от `l2_emit_poll`, что не является
допустимым возвратом агрегата в C. Положительный Pair-свидетель имеет
`throws: Oops` и потому status/out ABI; он эту границу не закрывает.
Общее завершение без значения нужно выразить механизмом управления,
не придумывать нулевой aggregate или считать его языковым результатом.
Это отдельный прежний дефект генерации C, а не новый запрет типов языка
и не основание требовать от пользователя фиктивный `throws`. Перед
ремонтом сохраняется самостоятельный небросающий aggregate-свидетель:
`build/l2_harness/uniform_dispatch_aggregate_boundary_20261001_01`.
Одинаковый источник проходит L2/L1, но отказывает в C на `return 0`
из Pair-тела (строка 51) и на pre-stop `0EE039AF…`, и на выпущенном
`6F3F4EC9…`. Это подтверждённая прежняя граница, не runtime-отказ.
Нынешний зелёный throwing Pair не подменяет её исправление.

Read-only карта следующего ремонта на `621e8af`: `l2_emit_sig` выбирает
status/out только по `l2_m_throws`; `l2_emit_ret_tr`, inline-return в
`l2_emit_stmts`, `l2_mad_emit` и `l2_emit_empty_return` повторяют это
разделение. `l2_emit_poll` при этом вынужден возвращать фиктивный scalar 0
из небросающего typed-body. Возможный общий путь — отделить внутренний
ABI завершения от наличия языкового `throws` и использовать уже имеющийся
status/out для всех генерируемых typed-body. Это проект ремонта, не новая
норма и не выполненное изменение. Нужно вместе перевести prototype/body,
платформенные варианты, возвращаемый callable и `l2_emit_tramp_call`,
сохранив точный тип result storage и текущее различение stop/throw/value.
Публичный C-wrapper — отдельная граница: `l2_emit_library_wrappers` ещё
вызывает typed-body напрямую и имеет незакрытый owner-lifetime; его нельзя
случайно сломать сменой внутреннего прототипа или считать проверенным
по обычному root-gate. Свидетели должны включать небросающий Pair,
примитив, указатель, void, настоящий throw и stop до выдачи результата;
никакого выдуманного значения и искусственного `throws` в пользовательском
исходнике.

<a id="foreign-value-member-projection"></a>
### FOREIGN-VALUE-MEMBER-PROJECTION — 2026-10-01, Codex, OPEN

Новая ABI-фикстура `unit_uniform_aggregate` в
`build/l2_harness/uniform_dispatch_focus_20261001_01` проходит L2/L1,
но C99-компиляция отвергает обращения к полям by-value C-формала:
`fn: echo (c.L2DispatchPair: value) c.L2DispatchPair` с
`value\value: 99` выдаёт `l2_p0_0->value = 99`, хотя параметр имеет
тип `L2DispatchPair`, не указатель. То же чтение в `read` выдаёт `->`
вместо доступа к полю C-значения (generated C:62,82,88; точный лог —
`logs/fixture.unit_uniform_aggregate.compile.log`). Это машинная
C99-структура, не передача LMX Structure по значению.

Исправление относится к общей проекции объявленного C-типа и доступа
к его полям, не к выбору native/walker. Не угадывать тип по имени и
не сканировать C-заголовки; использовать уже разрешённый контракт
формала и глубину указателя. В ABI-срезе изолировать передачу/возврат
C-значения через обычные типизированные C-helper'ы; такой свидетель
не закрывает этот дефект. Соседний `c.original.value: 41` в неудачной
фикстуре — ошибочная попытка записать поле через raw C-call, не
самостоятельное доказательство дефекта языка. Общий ремонт должен
проверить чтение/запись by-value формала и контрольный pointer-формал.

Read-only trace `621e8af`: общий `l2_emit_raw_path` правильно выбирает
own/formal/local root, затем копирует весь исходный backslash-suffix без
учёта глубины разрешённого root-типа. Поэтому generated L1 сохраняет
`l2_p0_0\value`, хотя его prototype объявляет `L2DispatchPair: l2_p0_0`;
L1 закономерно выдаёт C `->`. Ремонт должен проецировать первый member-step
по фактической категории и глубине root, общей для чтения, записи и адреса,
а не менять foreign-ABI формал на указатель. Типы последующих opaque C-полей
нельзя придумывать из имени или получать запрещённым сканированием headers.

<a id="compiler-metadata-caps"></a>
### COMPILER-METADATA-CAPS — 2026-10-01, Codex, OPEN

Read-only проверка выпущенного `71c4743` и SITE expanded06 подтверждает
искусственные ограничения в `dev/l2src_sandbox/l2trans.lm1`:
`l2_rw_path` и `l2_rw_path_bodies` отказывают при `n >= 12`,
`l2_d105_edge` — при 128 различных рёбрах передачи. Это не границы языка
и не отказ выделения памяти. В SITE запись сегмента walker-пути расширена
с пары до тройки (позиция, вид, принимающая модель); буфер из 42 int
сохраняет прежний предел 12 сегментов и **не исправляет его**.
`l2_join_path` также возвращает «не путь», когда исходный путь длиннее
выданного вызывающим буфера: нехватка ёмкости не должна менять разбор.

Заменить ограниченные compiler-only записи хранением фактической длины,
используемым общими потребителями. Не повышать константы, не вводить
отдельный runtime-граф или другой разбор длинных путей. Свидетели должны
пересечь старые границы, сохранить приём, точное выбранное объявление,
чтение/запись/адрес и native/walker parity. Эти новые пограничные
свидетели ещё не выполнялись; текущий ограниченный SITE-выпуск сам по
себе не закрывает требование произвольной глубины clean-kernel.

### CAPTURED-STRUCTURE-ADDRESS-CATEGORY — 2026-10-01, Codex, OPEN

Read-only trace подтверждает прежний дефект уже в `71c4743`:
`l2_address_name` для параметра берёт модель только из `l2_nsty_get`,
а `l2_input_is_descriptor` отвергает любой hidden-index. Поэтому скрытый
захват Structure трактуется как обычная pointer-cell: `@m` получает
лишнюю глубину вместо адреса дескриптора. Одного добавления модели
недостаточно: категория и модель должны проецироваться вместе по
существующему происхождению захвата (`l2_cap_arg_ns`), не по совпадению
машинного типа `Lmx*` у всех скрытых входов.

Минимальный будущий свидетель **ещё не запускался**: make принимает
`(Model: m)` и возвращает inner, который читает `m\value`, затем
объявляет `@: Model p @m` и проверяет descriptor identity и `p\value`.
Вызов make(Model) и обычное `m\value` дают контроль захвата; отдельная
явная pointer-cell должна сохранить настоящую дополнительную глубину
своего адреса. Нынешний ремонт captured-path не закрывает этот адресный
случай. Включить в общий receiving/capture follow-up, без нового registry
и без изменения правил `@`.

<a id="merge-result-value-projection"></a>
### MERGE-RESULT-VALUE-PROJECTION — 2026-10-01, Codex, BOUNDED FIX `8359a59`

Ограниченный срез сохранён и перенесён в main; окончательные границы, 25 файлов
и свежие гейты — [release record](native-selfbuild-20260930.md#merge-result-value-release).
Full: 1062/1110, те же 48 прежних отказов, без новых регрессий; kernel 286/286,
L3 11 наборов/295 проверок. История ниже не объявляет закрытыми соседние
held/formal/hidden-input, expression-receiving и selector/use-edge задачи.
По просьбе автора после документационной передачи кодовая работа остановлена.

**Исправление атрибуции свидетельства, 2026-10-01.** Нижний первоначальный
пример `copy: merge Model` совпадает с документированной формой, но текущий
`l2_merge_frame` узнаёт только вложенный Frame `merge`, например
`copy: merge: Model`. Поэтому его отказы нельзя приписывать только
проекции результата: обработчик merge для него вообще не был выбран.
Это отдельный пробел общего разрешения receiver-выражений, не ошибочный
пользовательский синтаксис и не разрешение молча поменять норму. Исходные
логи сохранены, в том числе новый `merge_value_probe_20261001_03`.

Независимый контроль существующей Frame-формы сохранён в
`build/l2_harness/merge_value_corrected_preflight_01`: на выпущенном
`621e8af` root отказывает «unresolved name», `atom=copy`, на 5:12,
method — на 6:16. На промежуточном `DCEE6BC5…` обе программы уже
выдают непустой L1. Это подтверждает отдельную нужность ремонта
ordinary own/schema, но ещё не runtime-успех: следующий `_04` остановлен
C-компилятором на ошибочно выданном несуществующем `LMX_WALK_OP_SELF`.
Дальше требуется корректная общая проекция фактического self/host,
не указатель на первоначальный метод вместо его скопированного вхождения.

Промежуточный runtime-контроль `merge_value_probe_20261001_09`, исходник
транслятора `895BE26C…`: **8/8**, пять фикстур, каждая с нативным корнем
и настоящим driver-cleared root walk. Отдельная пара фикстур различает
нативный метод и метод, действительно исполняемый обходчиком. Проверены
добавленные и переопределённые поля, merge предыдущего результата,
независимость копий при рекурсии/повторных вызовах и hosted-пути
`while\copy\value` для чтения/записи/адреса. Разрешение ближайшего
объявления исправлено через общую identity его host; составная схема
проходит дальше по физическому пути. Отдельный ручной runtime-свидетель
`build/merge_value_self_20261001_03` — 49/49: один code исполняется с
первоначальным и скопированным data, и новый результат получает именно
фактического родителя. Это ещё не RELEASE: удержание qualified-корня,
отказ merge и полные regression/kernel gates требуют завершения.
Реальный SELF — внутренний лист обходчика для уже существующего executing
occurrence, не новый source receiver и не изменение смысла `node`.

Первоначальное наблюдение (его уточнённая атрибуция — выше):

На frozen binary `site_visibility_20261001_expanded02` минимальный
`copy: merge Model` / `@: Model b copy` отвергается в корне на 5:1
«implements is false in assignment», а внутри `fn make` на 6:5
«assignment value has unknown type». Источники и логи:
`build/l2_harness/site_visibility_merge_value_probe.lm2` / `.log`,
`site_visibility_merge_method_probe.lm2` / `.log` и `_walk.log`.
Второй отказ одинаков с `--walk-methods`; L1 не выдан, runtime ещё
не проверялся. Model имеет `int: value 1`; принимающее объявление должно
сохранить физический результат копирования, а не ссылку на исходный Model.

Source trace: связанные merge-results уже имеют физические ссылки и карту
полей для путей, но цельное значение не проходит через общий
`l2_colon_bound_ty` / `l2_actual_ns` / `l2_reference_descriptor` /
`l2_address_name`. Кроме того, `l2_rw_stmt` разрешает обычный merge лишь
при `l2_rw_mi == l2_e`. Это пробел проекции существующего результата,
не новый синтаксис, не новая разновидность Structure и не вопрос Q58.

Нужна общая value/model/address-проекция результата с обычным admission
и однократным вычислением, в корне и в методе, native и в действительно
интерпретируемом теле. Сохранить новое копирование при каждом достижении
merge, независимость исходника и копии, равенство ссылок на один результат
и правильную глубину `@copy`. Не заменять копию alias на Model ради
зелёного теста. Удаление старых `Model: fresh` setup-форм зависит от этого
ремонта там, где тест доказывает копирование/повторный вход; проверки
адреса обычной исходной Structure могут использовать явное её определение.

Read-only путь ремонта: само объявление результата привязать к обычной
own-строке (`l2_own_add` уже различает method + P0 declaration), сохранив
`l2_mrs` как описание составных полей, а не второй name-binding индекс.
Объявление локальной Structure уже заканчивает однократное построение
через `l2_own_store`; legacy clone-ветвь делает то же после merge.
Walker имеет `l2_rw_write` / `l2_rw_own` и Structure-capable working rows
в `lmx_walk_work_make`. Поэтому новый LOCAL/SET_LOCAL или отдельная
таблица активационных значений не обоснованы. Использовать общий приём
результата в объявленное место и общую проекцию составного контракта.

При этом `l2_own_direct` пока исключает graph-slot из cached-маршрута:
полноту существующего рабочего состояния для этого вида нужно проверить
и при необходимости закончить с парными local-Structure/merge свидетелями
повторного входа. Это ещё не выполненная правка и не новое правило срока
жизни результата. Корень и метод используют обычные source-declared own
места; запрета хранить результат метода в собственном графе нет.

Уточнение read-only на выпущенном `e70689c`: `l2_merge_scan` и
`l2_mres_find` пока различают результаты только по тексту имени во всём
unit, а native store и `l2_rw_merge` адресуют `l2_mres_base + res` в unit.
Поэтому добавления одного случая в type checker недостаточно. При общем
ремонте привязать результат к исходному объявлению/методу/host и тому же
own-месту, не добавляя параллельный scoped merge-name registry. Отдельно
проверить одинаковые имена результатов в двух методах, вложенные места
объявления с отсутствующей в их окружении головой,
повторное достижение и сохранённую ссылку на предыдущую независимую копию.
Это source trace и план свидетелей; эти дополнительные случаи ещё не запускались.

Уточнение пути ordinary own-store: `l2_own_cell_store` спрашивает
primitive `l2_own_store_helper` раньше своей ветки Structure-slot и потому
до неё не доходит для этого вида. При ремонте использовать существующую
ветку slot до выбора примитивного helper, а не заводить отдельный механизм
локальных merge-результатов. Объявление результата регистрируется один раз
по исходному `mi`/P0 statement; операнды разрешаются в предшествующем
окружении, до появления нового имени. Только после перевода всех
потребителей на это ordinary own-место удаляются `l2_mres_base` и отдельные
дети unit для результатов. Compiler-only описания `mrs/msrc` остаются:
это состав полей, не второе хранилище значений в графе.

Дополнительная граница read-only: ordinary own-строка не должна получать
`nsty` первого операнда. У `merge A B` полная раскладка уже определена
`l2_mrs_build` / `l2_mrs_join` / `l2_msrc_*`; она может содержать поля B,
переопределённые слоты и сохранённые повторы A. Объявленный C-тип Lmx*
не заменяет эту информацию. Общие candidate-side value/path/admission
потребители должны видеть именно итоговую схему и её declaration identity,
а не схему A или ненастоящий ns-index. Возможный минимальный путь — общий
compiler-only вид над существующими `nsf` и `mrs` с едиными field/slot
операциями. Это вариант реализации для проверки, не новый языковой тип,
runtime-граф или дополнительный индекс bindings. Свидетели: B добавляет
поле и переопределяет совместимое поле A; результат всё ещё допускается
потребителем A, но сохраняет добавленное поле, физическую карту и все
исходные occurrences. Нынешние `l2_mrs_join` отказы разных kind/моделей
нужно сверить с общим implements, а не принять как норму по наличию кода.

Независимый preflight текущего тикета уточнил две обязательные границы.
Родитель новой копии определяется местом merge-выражения
([семантика композиции](../docs/LMX_semantics.ru.md#composition)),
не unit и не родителем первого операнда; root-only тест этого не различает.
Повторные поля в admission выбираются по фактическим `uses(Consumer,bVar)`:
bare-путь выбирает последнее вхождение, `[N]` — указанное; неиспользуемые
повторы не сравниваются. Нельзя автоматически попарно сопоставить все
декларации модели или удалить повторы из candidate schema. Нынешний отказ
`l2_d105_table` при втором совпадении имени проверять отдельным выбранным
Consumer-путём. Это существующая общая норма, не особый implements для merge.

Граница, уточнённая при повторном полном прогоне: `return: merge(...)`
нельзя считать объявлением результата с именем `return`. Внешняя голова
сначала получает обычную роль; только действительно новое имя результата
регистрирует own-место. Исправление этого ошибочного разбора выявило ещё
не реализованный общий путь merge-выражения в принимающем контексте.
Исторический `unit_t7_from_int` теперь помечает этот implementation debt,
а не доказывает запрет data-first композиции или допуск результата к int.
Для последнего добавлен отдельный свидетель: реальное `copy: merge: Model`
и затем `return: copy` в методе с int-результатом; положительная пара
возвращает копию через совместимый структурный контракт.
Общий ремонт выражений должен возвращать значение через существующий
типизированный временный результат, не создавать фиктивное поле графа
для `return`, вызывающего receiver или любого другого принимающего контекста.
Новый диагностический текст не закрывает эту границу реализации.

<a id="merge-held-operand-layout"></a>
### MERGE-HELD-OPERAND-LAYOUT — 2026-10-01, Codex, OPEN

Read-only trace текущего merge-среза: `l2_mrs_build` берёт схему own-операнда
через `l2_own_nsty_get`, то есть declared receiving model ссылки; native
и walker передают в merge её фактический descriptor. Минимальный
различающий случай:

```text
A: (int: x 1)
B: (int: pad 10; int: x 20)
@: A alias B
copy: merge: alias
```

По коду результат содержит физические поля B (`pad`, затем `x`), но
compiler-only mrs описывает A (`x` в позиции 0). Тогда `copy\x` выбирает
не то поле; фиксированный token такого результата также не доказывает
его настоящую раскладку. Runtime подтверждён на источниковом срезе
`merge_value_probe_20261001_11` (`32FD3AD6…`): отдельные
`build/l2_harness/merge_held_layout_20261001_01` (метод walked) и `_02`
(метод native) проходят L2/L1/C/link, но оба способа запуска каждого
артефакта завершают программу 81 вместо 7 на первом чтении `copy\x`.
В измеренном входе A.x=11, B.pad=22, B.x=33; source trace выбирает слот
pad вместо x. Следующие проверки admission/записи ещё не достигнуты.
Зелёный `merge_value_probe_20261001_09` использует именованные операнды
и предыдущие результаты, а не этот случай.

Тот же классификатор вообще не принимает формальный merge-операнд:
первый вариант `unit_merge_value_failure` в frozen `_11` отказывает
на 3:18 «unknown merge operand» для `source`. Это отказ трансляции,
не ошибка уже исполняемого merge и не норма запрета формалов. Отдельный
`merge_failure_20261001_01` с обычной own-ссылкой сохраняет назначение
теста отказа: caught merge не меняет принимающую ссылку и исходный Model;
два запуска завершаются успешно (13 и 17 driver-проверок соответственно).

Ремонт удержания qualified-операнда решает другую задачу: если kernel
возвращает исходный descriptor, нельзя переименовывать его происхождение
token-ом нового объявления. Однако сохранение правильного token само
по себе не исправляет новую копию из операнда с иной фактической раскладкой.
Нужна общая проекция фактических операндов и итоговой составной схемы;
нельзя подставить receiving model вместо неё, обрезать копируемые поля,
ввести особый runtime registry или объявить законную ссылку запрещённой.
Проверить два разных порядка полей B/C, выбор ссылки во время исполнения,
чтение/запись/адрес результата, его последующий admission и повторный merge,
native и действительно walked method. Нынешний ограниченный срез
статически известных схем этот дефект не закрывает.

Read-only проверка пути ремонта: простая передача tagged mrs-схемы как
required в D105 не работает. `l2_d105_table`, model/Consumer-эмиттеры
и часть receiving-потребителей предполагают named ns и существующий
descriptor модели. Удаление `req < 0` не устраняет это предположение.
Не создавать скрытую Structure схемы ради подгонки ABI. При единственном
доказанном физическом источнике можно составить mrs по нему; это ещё
не общий случай меняющейся ссылки B/C. Общий случай должен опираться
на тот же путь проекции использований, что следующий дефект selectors:
одно обычное место результата, настоящая раскладка в существующих
метаданных соответствий, отбор физических мест для каждого использования
и обычного допуска в другой receiving model. Поэтому в очереди общая
проекция selectors/uses предшествует закрытию этого случая.

<a id="merge-hidden-input-projection"></a>
### MERGE-HIDDEN-INPUT-PROJECTION — 2026-10-01, Codex, FIXED срезом K02c (fable, 2026-10-01)

Исправлено по ответу Codex (DS-CODEX-004; запись — `k02-merge-values-20261001.md` §4–5): merge-результат
единицы, названный свободно в методе, — обычный скрытый вход этого метода (как `int: total` в
`unit_named_struct_hidden_input`); его принимающие метаданные — tagged-схема merge через общую
`l2_input_schema`, экземпляр модели для допуска — сам результат (его own-слот, или рабочее значение
эмитируемого метода); промежуточный вызывающий без своей привязки наследует вход; обходчик берёт модель
ADMIT_AS/OF как кадр, вычисляемый на месте (`lmx_walk_model_operand` в ядре). Свидетели:
`unit_merge_hidden_input` (22, не 1; native и walked), `_forward` (через `mid`), `_lexical` (1),
`_position` (поле по имени, 22), `_refused` (отказ трансляции на вызове). Открытым остаётся
runtime-выбираемый операнд merge (B/C на разных вызовах) — §2 заметки K02.

Ниже — исходная запись дефекта.


`build/l2_harness/merge_hidden_source_20261001_01`: unit объявляет
`copy: merge: Model` с value=1; метод read читает свободное `copy\value`;
caller объявляет своё `copy: merge: Other` с value=22 и вызывает read.
По общему приоритету hidden-входов результат должен быть 22. Оба запуска
артефакта (native root и cleared-root walk) завершаются 81 вместо 7;
проверка не прошла. Это не свидетельство исполнения обоих helper-методов
обходчиком и не новая норма захвата глобального merge-имени.

Source trace: ранний `l2_mres_find` в сканировании имени обходит обычную
регистрацию hidden-входа. Простого удаления раннего return недостаточно:
input-model и receiving-потребители пока требуют named ns, а схема этого
значения — tagged mrs. Использовать общее разрешённое значение/контракт
и приоритет caller-local → inherited input → lexical fallback; не
подменять вход глобальным result-slot и не создавать hidden schema/data
Structure. Ремонт зависит от общей проекции используемых полей составных
схем. Проверить настоящий native и walker helper, два caller-значения,
лексический fallback без caller-источника и явный физический путь,
который по правилам не становится динамическим входом.

<a id="admission-occurrence-selector-collapse"></a>
### ADMISSION-OCCURRENCE-SELECTOR-COLLAPSE — 2026-10-01, Codex, FIXED срезом K01b

Read-only trace на `621e8af`, runtime-свидетель ещё не выполнен. Пусть
required содержит два одноимённых поля x, candidate — три. Один Consumer
читает и bare `v\x`, и `v\[1]x`. В required обе записи выбирают физическую
позицию 1, но в candidate должны выбирать соответственно 2 и 1. Нынешнее
соответствие «позиция required → позиция candidate» не может выразить оба
доступа. Это пробел реализации общей нормы выбора, не неопределённость языка.

`l2_uses_path_add` ещё сохраняет разные пути; `l2_cap_fields` сводит их к
позициям required, `l2_d105_pair` — к паре схем. Native `l2_d105_emit_slot`
и walker OF передают позицию и модель, без исходного вида селектора.
`LmxImplEntry` выбирается по `(value, req)`; регистрация требует ширину
карты, равную ширине req. Добавление только Consumer в ключ не решает
пример, потому что оба доступа принадлежат одному Consumer.

Перед ремонтом выполнить минимальный свидетель с различимыми значениями
10/20/30 и проверить native/walker, чтение/запись/адрес, а не только
успешный implements. Сохранять semantic-use identity из существующего
пути до общей проекции; возможное расширение метаданных соответствия
должно различать LAST и ORDINAL N, не заводя runtime-имена или новый граф.
Не обходить дефект копированием/удалением повторов, новой нормой отказа
или попарным сравнением неиспользуемых полей. Срез ordinary merge-result
с одинаковым числом повторов сам по себе этот общий случай не закрывает.

Исследованный путь следующего ремонта: отделить стабильное соответствие
мест от множества путей, используемых нынешним Consumer. Одного
«базового допуска всех полей + поправки адреса для `[N]`» недостаточно:
он либо отвергнет неиспользуемое несовместимое поле, либо разрешит доступ
к выбранному полю, тип которого вообще не проверялся. Существующее
соответствие должно сохранить selector identity для каждого используемого
ребра; чтение, запись, адрес и capture используют то же ребро, что admission.
Физические пути ручных runtime-потребителей остаются физическими и сохраняют
явно переданную перестановку, а не превращаются в совпадение номеров слотов.
Конкретная раскладка общей таблицы пока не выбрана; второго registry,
графа или параллельного fallback-алгоритма этот ремонт не требует.
Добавочный свидетель: candidate с `char x`, `int x`, `int x` допускается
потребителем одного последнего `x`, но отвергается потребителем `[0]x`,
если его required-поле имеет тип int. Проверить оба порядка допусков:
кэш соответствия не означает разрешения любого последующего Consumer.

**Проба на замороженном срезе (deepseek, 2026-10-01; `steps/k01-selector-identity-20261001.md`).**
Оба селектора сегодня до соответствия не доходят: bare-чтение по повторяющемуся имени
(refused, `unresolved name`, и через формал, и от корневого значения); `[N]` через формал
(refused, `unknown field path root` на стадии эмиттера); `[N]` от корневого значения
(check проходит, но эмитится невалидный C — отдельный дефект
[NAMED-MODEL-OCCURRENCE-PATH-LOWERING](#named-model-occurrence-path-lowering)). Работающий
сегодня случай — bare-last через admitted-формал при requirement с одним именем
(`unit_merge_value_repeat`: `read (Last: value)` читает `value\x` merged-`copy{x,x}` и
получает 33 = LAST факта); это половина LAST↔LAST, ordinal-половина покрытия не имеет,
т.к. запись не компилируется. Свидетели-фикстуры добавлены: `unit_occ_selector_read`,
`unit_occ_selector_unused_first`, `unit_occ_selector_first_refused` (красные до ремонта;
строки harness добавляются вместе с фиксом). План срезов K01a–K01e — в записке.

**K01a выпущен — дефект ОТКРЫТ наполовину (deepseek, 2026-10-01; там же §5a, §8).**
Разрешение имени и понижение пути теперь occurrence-exact на всех общих путях
(`l2_seg_split`/`l2_after_bracket`: `l2_ns_slot_named`, `l2_mrs_slot_named`,
`l2_own_seg_scan`; сборка `[N]name` в `l2_join_path`/`l2_uses_scan_follow`; общий
joined-path в `l2_emit_fields`), поэтому bare = LAST и `[N]` = вхождение N работают и в
identity-раскладке (root-значение, формал того же типа) — свидетели
`unit_occ_selector_root`, `unit_occ_selector_ident_formal` (native + walked),
и закрыт `NAMED-MODEL-OCCURRENCE-PATH-LOWERING`. Дыра в таблице соответствия
(`l2_d105_table`, holes=1) больше не отвергает candidate из-за неиспользуемого
несовместимого поля: `unit_occ_selector_unused_first` зелёный, а потребитель `[0]x`
по-прежнему отвергается — `unit_occ_selector_first_refused`. Полный гейт
(`build/l2_harness/k01a_full_20261001_03`): 48 отказов из 1114 — ровно базовые 48,
ноль регрессий. **Остаток — сам коллапс соответствия**: `unit_occ_selector_read`
транслируется, но красный на runtime (exit 82), потому что обе записи всё ещё идут
через одну позицию requirement; карта `2n` (ordinal-половина / LAST-половина) и её
потребители — срез K01b, обязательства ревью — §8 записки.

**K01b выпущен — дефект ЗАКРЫТ (deepseek, 2026-10-01; записка [K01](k01-selector-identity-20261001.md)
§9, §9a).** Соответствие несёт по две цели на поле требования: половина ordinal (`t[j]` — вхождение
r_j кандидата, её выбирает запись `[N]name`) и половина LAST (`t[w+j]` — последнее вхождение имени в
значении, её выбирает голое имя). Решение автора — «обращение по имени»: `v\x` — последнее вхождение
имени x в кандидате v, `v\[1]x` — второе вхождение в том же кандидате. Каждое обращение исполняется
на том ребре, которое названо его собственным селектором: `slot` для `[N]name` и `slot + width` для
голого имени — и в нативном чтении/записи (`l2_d105_emit_slot`), и в walked-индексе OF/PUT_OF
(`l2_rw_path` → `path[6+3n]`); runtime резолвит ребро (`lmx_implements_at_last`,
`lmx_implements_slot`), `lmx_implements_same_map` сверяет обе половины, `ADMIT_AS` принимает
`default_n = 0` или `2*width` при stride `2*width+1`, а запись регистрируется с семантической шириной
`req`. Свидетель `unit_occ_selector_read`: через допущенный `Triple` голое `v\x` даёт 30, `v\[1]x` —
20, нативно и walked (в L1 понижаются рёбра 3 и 1). Неиспользуемое несовместимое поле по-прежнему не
отвергает кандидата (`unit_occ_selector_unused_first`), потребитель этого поля отвергается
(`unit_occ_selector_first_refused`), явная физическая перестановка клиента сохраняется
(`unit_d105_perm_native`, `unit_walk_d105_perm`). Гейты: harness `k01b_full_20261001_03` — 1115 целей,
48 базовых отказов, ноль новых; kernel `k01b_kernel_20261001_02` — 286/286; L3 — 11 наборов, 295
проверок, бюджет типов ok. Изменение — миграция ABI плоской инструкции `ADMIT_AS`; вместе с ней
мигрированы три клиента (`lmx_implements_table_selftest`, `lmx_gc_selftest`,
`lmx_walk_admit_selftest`) и обновлены пины формы в `tools/l2_harness.ps1`. Пять мутантов краснят
ровно своих свидетелей (схлопывание половин, оба use-site, обе половины runtime); шестой —
`at_last_map_ordinal` — до свидетеля не доходит, потому что его запись — кадр допуска, а у
перестановочных фикстур половины совпадают; это записано как пробел покрытия, а не как «мёртвый»
мутант.

<a id="named-model-occurrence-path-lowering"></a>
### NAMED-MODEL-OCCURRENCE-PATH-LOWERING — 2026-10-01, deepseek, FIXED срезом K01a

`m\[0]x` по значению именованной модели с повторяющимся именем проходит проверку, но
понижается как цепь C-членов: в сгенерированном C стоит `l2_q0 = l2_q2 ->[0] x;`
(gcc: `expected identifier before '[' token`). Общая форма (`s\[N]name` — селектор
вхождения) либо должна понижаться корректно, либо получать локализованный отказ; сейчас
нет ни того, ни другого. Минимальный свидетель — `build/l2_harness/occsel_probe_20261001_01`
(проба `unit_occ_sel_g4`; там же `v\[0]x` через формал отвергается «unknown field path
root»). Закрывается срезом K01a ([K01](k01-selector-identity-20261001.md)).

**Ремонт (K01a, 2026-10-01).** Значение позиции пути понижается общим
joined-path маршрутом в `l2_emit_fields`: `l2_join_path` собирает `[N]name` в один
сегмент, `l2_path_root`/`l2_path_kind` разрешают его тем же occurrence-exact поиском, и
числовой лист (`size_t`/`char`/`int`/`unsigned`/`ulong`) загружается через
`lmx_*_value_known(l2_pxp[0])`. Тот же маршрут обслуживает return-значения, фактические
аргументы вызова и прочие позиции значения. Свидетели: `unit_occ_selector_root`
(`r\x`, `r\[0]x`, `r\[1]x`, `r\[2]x`; записи и `@`) и `unit_occ_selector_ident_formal`
(то же через формал того же типа) — native и walked, полный гейт
`build/l2_harness/k01a_full_20261001_03`. Порядок материализации: чтение пути в
аргументе вызова обязано попасть в типизированный temp в точке вычисления пути, а не
инлайниться в список аргументов после публикации checkpoint (иначе четыре строки
`unit_body_path_for`, `unit_body_path_while`, `unit_pathwrite_cell_kept`,
`unit_cache_for_call` краснеют — проверено мутантом `inline_actual`).

<a id="site-binding-category-regressions"></a>
### SITE-BINDING-CATEGORY-REGRESSIONS — 2026-10-01, Codex, FIXED `e70689c`

Ограниченное исправление выпущено: full03 1047/1095, 48 прежних отказов,
ноль новых регрессий, 43 добавленные строки зелёные; focused 107/107,
kernel 284/284, L3 11/295 плюс четыре инвентаризации. Ниже сохранена
история диагностики, не нынешний статус промежуточных срезов.
[Финальные байты, мутации и границы](native-selfbuild-20260930.md#site-visibility-release).

**Исторический блокирующий свидетель — потеря происхождения раскладки.**
`site_visibility_20261001_expanded05` прошёл 288/288 (285 фикстур),
но дополнительный `site_visibility_map_ambiguity_01` на его точных
frozen-байтах выявил неправильный результат в обоих режимах: native
81 (одна ошибка из 13 проверок), настоящий WalkRoot 81 (одна из 17).
Источник — `build/l2_harness/site_visibility_map_ambiguity.lm2`.
У модели A одно поле x; B — y; C имеет x,y,pad, D — x,pad,y.
Два вызова C/D → relay(A) → observe(B) должны читать 22/44.
Однако карты C → A и D → A одинаковы `[0]`, а карты в B различны:
`[1]` и `[2]`. Сравнение исходных карт выбирает последнюю альтернативу
для обеих фактических раскладок. Равенство проекций не доказывает
равенство исходных раскладок; native D-105 имеет ту же потерю сведений.

Нельзя закрыть это запретом законного последующего допуска, выбором
первой/последней карты или добавлением исключения для этих моделей.
Простая предварительная регистрация downstream-моделей тоже не доказана:
`lmx_implements_register` выполняет проверку текущего графа, затем
публикует сохранённый YES; перенос раньше меняет момент первой проверки.
Следующий ремонт должен сохранить необходимое происхождение в общем
механизме соответствий, без нового графа/реестра имён и без изменения
базовых Lmx/Array. До свежего свидетельства выпуск этого этапа не готов.

Промежуточный `site_visibility_20261001_30`: 7/8 targets. Новый вариант
со свидетельством физической раскладки в существующем ImplEntry прошёл
исходное столкновение C/D и отдельную инициализацию `@: A p @C` с
переприсваиванием на D, native и настоящий WalkRoot. Также зелёные
разнонаправленные model-view и null контроли. Остаётся
`unit_site_hidden_model`: native зелёный, walked явный формал → скрытый
вход останавливается до exit. Прогоны `_25`–`_29` остановились на
compiler/generator ошибках и не являются runtime-свидетельствами.
Полный ремонт, lifecycle и свежие общие гейты пока не подтверждены.

Последующий `_31` прошёл 11/11; `site_visibility_kernel_20261001_02` — 284/284,
включая table selftest 69/69 и walk admission 23/23. Это промежуточные
свидетельства, а не выпуск: дополнительный
`site_visibility_own_map_01` с моделью `[x]`, фактическим значением
`[y=22,x=11]` и ссылкой `@: Model p @Other` после успешных компиляции
и линковки получает 81 вместо 7 и native, и настоящим WalkRoot.
Приём сохраняет карту, но чтение/запись `p\x` ещё выбирает позицию 0.
Исправление обязано использовать соответствие при чтении, записи и
взятии адреса через выбранную типизированную привязку. То же относится
к привязке, достигнутой не первым сегментом пути (`while\p\x`,
`check\p\x`); это переход через ссылку, а не повторное лексическое
разрешение остальных сегментов. Контроли иной раскладки, адреса и
неизменённого соседнего поля остаются частью текущего ремонта.

`site_visibility_20261001_expanded06`: 293 targets, 286 OK, 7 FAIL.
Дополнительные own/hosted read/write/address и return-проверки прошли;
остался настоящий отказ `unit_rhs_returned_model_refused`: новый
`l2_d105_close` отвергает программу на 11:5 вместо вычисления `make()`
и последующего runtime-отказа допуска. Полная проверка принимающей
ссылки/результата должна происходить на достигнутой операции. При этом
нельзя просто убрать раннюю проверку и считать отсутствующие поля
«доказанно неиспользуемыми»: это свойство конкретного Consumer.
В работе — явное различие полного требования и доказанных используемых
путей в общей metadata допуска, проверка полной принимающей модели
через выбранную pending-карту перед публикацией успеха. Остальные шесть
отказов отдельно проверяются как старые наблюдатели формы/текста; до
этого они не считаются мигрированными или зелёными.

Исправление момента допуска проверено `_35`: 11/11, включая прежний
`unit_rhs_returned_model_refused` с неизменённым runtime-ожиданием.
Однако `site_visibility_local_layout_01` обнаружил ошибку самого
представления происхождения: локальный `mo` через `l2_own_layout` →
`l2_type_inst` получает unit[4], где находится `l2_children`, а не схема
`mo`. Правильная статическая карта скрывает неверное свидетельство;
успех aligned/reordered local-проверки native этого не оправдывает.
В том прогоне `check.native` остался установлен: интерпретация
локального производящего тела не доказана.

Вариант «слабый Lmx-указатель на схему для всех объявлений» отменён:
у локального объявления нет такого постоянного Lmx. Адрес очередного
экземпляра, родительского метода или принимающей модели не заменяет
идентичность исходной схемы. Общий ремонт — непрозрачный ключ исходного
объявления в метаданных модуля, сохраняемый существующим ImplEntry;
без новых графов, runtime-реестра имён или полей базового Lmx/Array.
Точная граница и критерии —
[план происхождения раскладки](callable-actual-projection-20260930.md#admission-layout-provenance).

Новая реализация с непрозрачными ключами: `_39` — 12/12; затем kernel
`site_visibility_kernel_20261001_04` — 284/284, admission 32/32,
implements-table 71/71. Четыре отказа предыдущего kernel `_03` были
ошибками ручных ADMIT_AS-фикстур: отсутствовали обязательные числовые
поля с нулём. Ожидания отказа полного Consumer и успешного частичного
допуска сохранены; исправлены поля, а не ожидания.

`site_visibility_20261001_expanded07` — **297/298**, ещё не приёмка.
Свидетель локальных производителей проверяет разные экземпляры и ячейки
при повторном создании, затем действительно интерпретируемые relay/observer;
сами конструкторы остаются нативными. Единственный отказ — новый
`unit_site_layout_local_target.lm2:6:8`: `@: Model ref @Other` не узнаёт
объявленную выше локальную `Model`, L1 не выдан. Разрыв предшествует
runtime-допуску: `contract_formal`/`resolve_type_atom` и
`contract_model_depth` используют поиск только глобальных моделей.
Нужно согласовать обе проекции с выбранным локальным объявлением;
одного распознавания C-типа указателя недостаточно. Это не нормативный
отказ и не свидетельство работы локальной принимающей модели.

Локальная проекция и разбор заголовков затем исправлены; `_43` — 15/15.
Но полный `site_visibility_full_20261001_01` на замороженном трансляторе
`2EE3E7C76499F1595E05B8437915A4BD87D7236FF3F1A3633E56A4726444C805`
получил **1010/1093, 83 FAIL**. Независимое сравнение с выпущенным full02:
48 прежних отказов остались, четыре стали OK, 34 прежде зелёные строки
регрессировали; добавлена 41 строка (40 OK, одна FAIL), удалений и
дубликатов нет. Новый `unit_site_model_header_context` остановлен
наблюдателем оставшегося native-слова; его runtime-проверки этим полным
прогоном не подтверждены.

У 16 регрессий «не выдан L1» одна измеренная причина: emission допуска
запрашивает default D105 map после фиксации массива карт, а closure не
зарезервировал эту пару без перенесённого свидетельства происхождения.
Исправление резервирования карты не должно придумывать происхождение
значения или заранее выполнять допуск следующего Consumer. Остальные
регрессии, включая место диагностики и допустимость интерпретации
преобразований, разбираются отдельно; это не разрешение заменить все
ожидания новым фактическим результатом. SITE ещё не выпущен.

Исправленный focused `site_visibility_full_repair_20261001_04` — **93/93**
(90 фикстур), транслятор
`0A47F6C8EC0C3507E5569A732FB98434C9A575BAFFEA359135ECF8D70074131C`.
Восстановлены места диагностики, default-карты до фиксации metadata,
полные отложенные проверки и прежние отрицательные admission-контроли.
Сведения о свежей копии записываются при её создании, не выводятся из
объявления при каждом чтении own-строки. `unit_site_constructor_reception`
проверяет замену этой строки письмом: старое значение сохраняет своё
свидетельство, полученное неизвестное не приобретает его. В режиме WalkRoot
действительно интерпретируется также `inspect`; сырой наблюдатель `layout`
остаётся нативным. Независимо сверены 67 live-хэшей и 51 присутствующий
owned-вход focused staging. Это ещё не полный gate и не выпуск;
новый full02 и актуальные контрольные поломки должны быть проверены отдельно.

Последующий full02 — **1042/1094, 52 FAIL**: 48 старых отказов, четыре
старых исправления, 42 добавленные зелёные строки, ноль удалений/дубликатов.
Четыре регрессировавшие строки отдельно разобраны: два ожидания должны
указывать исходное неизвестное имя (`shared` 7:39 и `k` в подключаемой части
4:5), поскольку тип скрытого входа не получается из будущего объявления;
два `sizeof`-свидетеля имели недопустимый valued return верхнего тела.
Снятие маскирующего return обнаружило настоящий общий дефект:
сканирование и отложенная проверка принимали имя в описании типа за
свободное значение. `l2_sizeof_is_type` теперь выделяет существующую роль
операнда независимо от успеха разрешения типа; scan/waits/check/emission
используют один признак. Обычный `sizeof(value)` сохраняет разрешение
значения, включая скрытый вход. Исторический primitive-only предел
`l2_sizeof_type_frame` этим не расширен и не является нормой языка.

Замороженный транслятор
`F9A2D6E600CB301DD256F7C1E3A7C9E432C64F0511DB3F3E26C8BC2830578ABF`,
70 owned-путей: `site_visibility_final_focus_20261001_01` — **107/107**
(104 фикстуры), `site_visibility_kernel_20261001_final` — **284/284**,
admission 32/32, table 71/71. Новый `sizeof`-контроль сравнивает указательный
тип с переменной того же типа, не предполагая равенства размеров разных
C99-указателей. Его root действительно обходится, но оба тела с `sizeof`
остаются нативными. Последующие финальные мутации, full03 и L3 завершены
на этих же байтах; результат — в записи выпуска выше. Красные full01/full02
остаются историей восстановления, не промежуточными «зелёными» базами.

Расширенный промежуточный прогон `site_visibility_20261001_expanded02`:
279 targets, 251 OK, 28 FAIL; это **не** acceptance текущего среза.
Независимый source trace отделил две регрессии от старых setup-форм
`Model: fresh`, которые требуют миграции на явный merge:

- `unit_send_ref_method.lm2:21:5`: видимое объявление
  `receiveMessage: m MainLetter` уже имеет own-строку, но scanner не
  отмечает соответствующую привязку в `m_uses/seen`; `l2_scan_ident`
  ошибочно добавляет скрытый вход m, и checker затем видит формал.
  Регистрировать уже разрешённую receiver-привязку в общих scan-данных;
  не возвращать подавление скрытого имени по будущему `own_any`.
- `unit_capture_struct_formal.lm2:16:9`: `return: m\value` после
  общего `l2_path_root` получает индекс скрытого захвата, однако
  `l2_nsty_get` проецирует только явный формал. Потеря модели даёт
  преждевременный D-97 отказ. Использовать существующий
  `l2_cap_arg_ns`, уже применяемый walker-путём, при общей проекции
  типа захвата; отдельной таблицы моделей не требуется.

Миграция устаревшего setup не подменяет исправление этих регрессий.
Сохранить исходные проверки приёма письма, поля и независимости копии;
свежий native/walker gate и exact source hashes обязательны до выпуска.

Следующий `site_visibility_20261001_expanded03`: 281/282. Остаётся
`unit_field_path_terminal_checklist:51:18`: hidden `u_struct` выбран
как переданный аргумент, но compound path теряет модель его лексического
контракта. Исправить общую input/model-проекцию и native/walker ARG-путь,
а не читать вместо аргумента внешнюю ячейку. Приём hidden Structure
обязан сохранить implements и соответствие полей: native prep и walker
CALL пока регистрируют карту только для captured-Structure случая,
а D-105 helpers исходят из явных формалов. Нужны отличный от parent
совместимый actual (в том числе иной порядок полей), несовместимый
actual и opaque-formal контроль. Эти дополнительные свидетели пока
не заявлены пройденными; дефект не маскировать старым `Model: fresh` setup.

Последующие focused-прогоны уточнили границу: `_20` прошёл 13/13 с
совместимой иной раскладкой, несовместимым actual и opaque-formal отказом.
В `_21` из восьми строк прошли семь: цепочка C → relay(A) → observe(B)
с различным порядком полей в принимающих моделях проходит native,
но действительно интерпретируемое тело возвращает ошибочный 81.
Простое наличие карты для первого допуска недостаточно: следующий
допуск должен сохранять связь с фактической раскладкой того же значения.

Исправление в работе использует одну плоскую инструкцию ADMIT_AS:
исходная/принимающая модели и числовые карты находятся в её собственных
полях, существующий ImplEntry заимствует frame+offset. Никаких отдельных
Structure для карт, нового графа состояния, новых opcode или расширения
Lmx/Array нет. Компактная identity-карта имеет длину 0. Значение кандидата
вычисляется один раз; null проходит до поиска/регистрации карты;
неизвестная исходная модель не подменяется принимающей.

`site_visibility_20261001_23` прошёл 10/10, включая противоположные
направления передачи C → A → B и C → B → A и null. После этого ревью
исправлены ещё два потребителя: источник уже допущенного явного формала
при следующей передаче и тест перехвата отказа после inline-карт.
Поэтому `_23` **не** подтверждает итоговые байты: нужны свежие kernel,
L3, generated и контрольные поломки. Старый `_22` с отдельными
служебными Structure для карт — отвергнутый промежуточный вариант,
не архитектура и не кандидат на выпуск.

### NAMED-DECLARATION-SLOT-IDENTITY — 2026-10-01, Codex, FIXED `e70689c`

`unit_site_part_repeat` проходит native и настоящий root-walk в финальном
SITE full03. Исправление использует P0-identity объявления; нижеследующий
разбор сохраняет исходную причину. Общие структурные selector-пути этим
не заменены лексическим поиском.

Новый `unit_site_part_repeat` в `site_visibility_20261001_14` выявил
существовавший раньше отказ: повторные `int: shared 11` / `int: shared 22`
в корне подключаемой части дают internal error «a declaration of a named
Structure's body is not a field of the Structure». Тот же исходник
отвергает выпущенный бинарник `71c4743`; отдельное свидетельство —
`build/l2_harness/site_visibility_20261001_14/released_part_repeat.log`.

Причина в `l2_own_mslot`: для процедуры именованной Structure он вызывает
`l2_ns_slot_named` по тексту имени, а тот отвергает повтор как неоднозначный.
При назначении места конкретному объявлению поиск по имени не нужен:
own-строка и `l2_nsf_fname` уже сохраняют идентичность исходного имени P0.
Сопоставить конкретное объявление с существующим физическим полем по этой
идентичности, без новой таблицы и без исключения для подключаемой части.
Проверить разные значения и адреса повторных полей. Это не разрешает
подменять отдельный структурный выбор `S\[N]field` лексическим поиском;
общий `l2_ns_slot_named` и его поведение при повторных именах требуют
самостоятельной проверки при унификации структурных путей.

### RAW-C-TYPE-PROVENANCE — 2026-10-01, Codex, OPEN

Read-only trace на `71c4743`: `l2_contract_type` сохраняет исходное
`c.Lmx` в `L2TypeContract.word`, но `l2_contract_formal` /
`l2_ptr_type_word` / `l2_resolve_type_atom` интернируют C-имя без `c.`.
Затем `l2_ty_raw_c_members` запрещает сырой member-путь только потому,
что это имя равно `Lmx`. Явное `@: c.Lmx p` ошибочно сливается с модельной
ссылкой, понижаемой в тот же C-тип. Это name-specific нарушение общей
двери, не допустимое исключение для внутреннего типа ядра.

Минимальный будущий compile-only свидетель: `fn: raw_parent (@: c.Lmx p)
@: c.Lmx` с `return: p\parent`; **ещё не запускался**. C-компилятор
проверяет настоящий member C-структуры. Парный graph-model контроль
должен сохранить обычный языковой поиск поля, а не получить сырой C-доступ.
Нужный признак уже есть в исходном контракте и доступном объявлении
(`l2_formal_decl`, `l2_own_decl`, `L2Declaration.contract`): сохранить
происхождение raw-door через разрешённую привязку, не классифицировать
по конкретному C-имени. Владелец — bounded raw-C/type-projection срез
§0; к текущему source-site ремонту автоматически не примешивать.

Связанный предел описания типа у `sizeof:` сохранён в SITE-срезе:
`l2_sizeof_type_frame` принимает только `l2_prim_type_word`, а его старое
обоснование опиралось на различие понижения type-frame в L1. Исправленная
роль операнда (`l2_sizeof_is_type`) не снимает этот предел. Общий ремонт
должен получать разрешённый тип, глубину ссылки и происхождение `c.*`
из существующего контракта и корректно понижать именно этот C-тип,
не расширять список разрешённых имён и не подменять размер любого
указателя размером `void*`. Будущие контроли — известная graph-model
ссылка, явно сырой C-тип и неизвестный тип; первые два пока отдельно
не запускались. Это оставшаяся работа перед clean-kernel, не новая
норма отказа для непримитивного типа.

### C99-POINTER-CELL-ALIASING — 2026-10-01, Codex, OPEN

В `0c5dd61` общие `lmx_pointer_new_owned/value_known/store_known`
(`dev/l2src_sandbox/lmx_value_owned.lm1:135–161`) обращаются к указательной
ячейке как к `void*`, а generated native использует настоящий тип этой
же ячейки, например `int*` через `int**`. Read-only аудит frozen
`portable_reference_typed_eval_20261001_20` подтверждает оба вида доступа.
Разрешённая C99-конверсия значений указателей не разрешает такой aliasing
их ячеек. Оптимизированное неверное выполнение пока **не измерено**;
зелёный focused gate без оптимизации не закрывает дефект.

Владелец — следующий ограниченный C99 storage-тикет единственного writer.
Нужен один типокорректный контракт native/walker-хранилища с реальным `@p`;
не `-fno-strict-aliasing`, не возврат адреса transport box, не второй ABI.
Новые `void*` transport boxes сами по себе корректны и не являются причиной.
[Границы, источники стандарта и оптимизированные контроли](native-selfbuild-20260930.md#c99-pointer-cell-storage).

### COMMON-ASSIGNMENT-RHS-TYPING — 2026-09-30, Codex, FIXED `6be1235`

Полный `dst_chars_cleanup_full_20260930_01` выявил 12 регрессий прежде зелёных строк после подключения machine-local assignment к общему checker. Все текущие фикстуры принимаются прежним `after_return_full` binary, но уже отказываются pre-API `diagnostic14_final` binary: удаление `dst_chars` их не создало. Десять отказов — неизвестный тип RHS, `parser_text_heap` — несовместимость известного `void*` с типизированным C-указателем, `unit_local_init_graph_ref_admit_refused` — незавершённый маршрут структурного admission. В частности, `unit_sizeof_type_frame` и C-member строки падают на присваивании pointer-cast до sizeof/доступа к члену: `l2_colon_simple_ty` знает только скалярные cast, хотя эмиттер уже поддерживает указательные.

Исправить общее получение типа/принимающего контракта и преобразование, не возвращать обход checker для machine locals. Сохранить raw-C door без знания имён C, const, реальную глубину ссылки, отказ несовместимым указателям и implements для Structure. Проверить прежние 12 строк и отрицательные контроли pointer/const/depth/admission; не менять их ожидания на отказ. [Полная таблица запуска, контрольная атрибуция и хэши](native-selfbuild-20260930.md#api-cleanup-full-checkpoint). Эта работа предшествует callable-actual и следующему clean-kernel gate.

Development-checkpoint `661735a` опубликован с явным списком отказов. Исправление выполнено тикетом `COMMON-ASSIGNMENT-RHS-TYPING-20260930` и сохранено в `6be1235`. При C99-преобразовании void* в объектный указатель implements структурной цели сохраняется: admission определяется принимающей моделью, а не старым предикатом RHS `graph || opaque-C`. Инициализатор и последующее присваивание используют одно решение о типе/допуске.

Целевой итог `assignment_rhs_20260930_final01` — 59/59: прежние 12 регрессий без изменения ожидаемой нормы, 15 новых свидетелей и 29 смежных контролей. Общий контракт cast, C99 object-pointer compatibility и единый receiving check покрывают инициализатор/присваивание; machine conversion предшествует структурному admission, кандидат вычисляется один раз. При ревью также исправлены отсутствие admission-site у compound initializer, const-temporary, классификация raw-C atom и checkpoint вызова через C-указатель функции. Четыре инверсии runtime-проверок, шесть поломок совместимости, одна поломка checkpoint и четыре runtime-обхода implements обнаружены; точные байты восстановлены. Полный `assignment_rhs_full_20260930_01`: 949/1003, 16 прежних отказов исправлены, 52 сохраняются, 15 новых фикстур прошли; две старые диагностические строки затем мигрированы в runtime-свидетели без правки production. Восстановительный `assignment_rhs_observers_20260930_final` — 61/61, обе дополнительные инверсии обнаружены (81/83 вместо 7). Все 21 путь проверены по хэшам, источниковый срез — `6be1235`; нового полного прогона после fixture-only дельты не заявляем. [Область доказанного и хэш](native-selfbuild-20260930.md#assignment-rhs-repair). Полная C99-типизация, общие пути и чистое ядро этим не закрыты.

### WHOLE-ARRAY-DESCRIPTOR-ADDRESS — 2026-09-30, Codex, FIXED `e7935be`

Read-only аудит актуального sandbox после исправления assignment: `l2_address_name` немедленно отказывает own-Array; `l2_own_addr` не имеет проекции его дескриптора. Это расходится с общей нормой `@Array`: адрес уже существующего дескриптора, не backing, не первый элемент и не служебный slot. Зарегистрированные `unit_addr_own_array_element` / `unit_addr_own_array_arith` подтверждают только адреса элементов. Незарегистрированный `address_array_field.lm2` не является готовым положительным контролем: он возвращает указатель из `fn ... int`.

Исправлено через существующий `L2Address` и дескриптор из `l2_own_from_expr`, без нового runtime-представления/аллокации или Array-specific синтаксиса. `whole_array_address_20260930_final` — 92/92 (89 фикстур): identity, arena-kind/type, пустой/непустой Array, длина/backing, element-address и pointer-depth контроли. Подмены на slot/backing обнаруживаются безопасным runtime-наблюдением (87 вместо 7); точные положительные байты восстановлены. [Хэши, контрольные поломки и границы](native-selfbuild-20260930.md#whole-array-address-repair). Передача Array в сигнатурах и generated-walker `@Array` остаются отдельными отсутствующими потребителями того же дескриптора; успех own-Array их не закрывает.

### ARRAY-INDEX-LEXICAL-SHADOW — 2026-09-30, Codex, FIXED `e7935be`

Новый свидетель `whole_array_address_20260930_03` обнаружил отдельную старую ошибку: при внешнем `[]: int values 4` и внутреннем `[]: char values 5` запись `values[0]: 'B'` понижается через внешний int-массив (`self`, slot 2), хотя следующие `@values` и `@values[0]` правильно находят внутренний char-массив (`l2_h1`, slot 0). После выхода внешнее 17 стало 66, проверка возвращает 84. Точная генерация — `gen/unit_address_array_descriptor.c:114–149` этого запуска.

Native store идёт через `l2_emit_own_index` / `l2_own_index_head`; прежний `l2_dyn_own_index` тоже сканировал первое подходящее Array-вхождение. Теперь `l2_resolved_own` использует существующий приоритет formal/own, выбирает ближайшую привязку и только затем проверяется Array-категория. Более близкий non-Array или формал не открывает внешнее имя. Общий lookup применяется к индексным чтению/записи, адресу и own-length, без нового индекса имён или особого shadow-правила. Исходный внутренний write восстановлен; однотипные literal/dynamic записи, scalar/formal shadow и восстановление внешней области проходят итоговый 92/92. Возврат first-match lookup даёт неверные runtime-результаты 92/81 и пропускает оба недопустимых scalar-index случая; formal-контроль ловит его на трансляции. Произвольные index expressions этим не реализованы.

### WHOLE-ARRAY-VALUE-PROJECTION — 2026-09-30, Codex, FIXED `5f11b50`

Явный `@Array` исправлен в `e7935be`, но bare Array как значение ещё имеет
прежнее понижение в backing: `l2_prep` вызывает `l2_emit_array_ptr`.
`l2_colon_bound_ty` → `l2_ft_of_own` сохраняет own-коды массива вместо
descriptor-pointer контракта. После подключения общего pointer-checker
типизированный actual к void*/VoidArray* отказывается — это отсутствующая
положительная возможность, не норма несовместимости. Raw-C actual обходит
формал L2 и всё ещё может получить backing через тот же `l2_prep`.
Общая норма L2 [передачи аргументов](../docs/L2_spec_en.md#copy-merge)
требует ссылку на дескриптор массива; backing получают явно через адрес
элемента. Нужна общая проекция типа и значения whole Array для обычного
выражения/actual, а не специальный decay у места вызова. Проверить typed
void*/descriptor-pointer и raw-C actual по реальной identity/kind/type;
Array-формалы и generated walker остаются отдельными границами.

Первый expanded indexed-span gate прошёл 111/112: единственная старая
фикстура `unit_addr_own_array_element` передавала bare buf к int* и прямо
называла это decay. Этот контракт противоречит норме, а formal-write
проверка была пустой: до вызова и внутри него писалось одно значение 9.
Согласована миграция в явный `@buf[0]`, distinct write 13 и проверку как
результата, так и изменённого caller-элемента, плюс отдельный отрицательный
контроль bare Array → int*. Это исправляет свидетель, но не whole-value
проекцию; production indexed-span при этой миграции не меняется.

Исправлено в `5f11b50`: общие `l2_value_ft_of_own` и `l2_emit_array_desc`
передают существующий дескриптор без изменения storage-кодов и аллокаций.
Focused 140/140, полный 977/1029: те же 52 прежних отказа, семь новых строк
зелёные, новых регрессий/удалений нет. Мутации и exact-byte проверка завершены.
Array-формалы, hidden-входы, целые значения по пути и generated walker
этим не закрыты. [Доказательства и границы](native-selfbuild-20260930.md#whole-array-value-projection).

### ARRAY-ELEMENT-ADDRESS-TYPE-LIST — 2026-09-30, Codex, FIXED `5f11b50`

Свидетель `whole_array_value_20260930_03` для уже поддержанного массива
указателей читает/пишет элементы, но `@values[0]` отвергается (9:127).
`l2_elem_ptr_ty` содержит отдельный список четырёх storage-кодов:
int/char/size_t/ulong. Общий `l2_address_type` уже умеет получить адресный
тип с дополнительной глубиной и сохранением квалификатора, поэтому отдельный
список не нужен. Источник типа — исходный контракт элемента из
`L2Declaration.contract.operand` через `l2_contract_formal`, а не расширенный
числовой тип прочитанного значения: это важно также для imported unsigned char.

Узкое исправление сохранено в `5f11b50`. Промежуточный focused
`whole_array_value_20260930_05` — 13/13; свидетель меняет настоящую
указательную ячейку через её адрес и читает изменённый элемент, depth/const
контроли отказываются. Восстановительный focused — 140/140, полный —
977/1029 без новых регрессий. Синтаксис, число измерений, правила индексации
и runtime-представление Array не менялись.

### INDEXED-EXPRESSION-SPAN — 2026-09-30, Codex, FIXED `c8167af`

В ходе Array-свидетелей сохранены три прежних отказа общих потребителей: dynamic own-index внутри OR (`whole_array_address_20260930_06`, `unit_array_index_shadow`, 13:56: `own array index requires a supported integer expression`); `int: seen values[i]` (`_07`, 13:9: `unsupported body`); прямой `@element` в вызове с несколькими actual (`_06`, `unit_array_index_formal_shadow`, 13:23: `address arithmetic past an own-array element is not yet supported`). Поддерживаемые промежуточные выражения в итоговых тестах изолируют indexed write и formal shadow, а не исправляют эти отказы. Исследовать общий source-span/index projection для expression, declaration initializer и call actual; не вводить Array-specific синтаксис или новые ожидаемые запреты языка. [Артефакты и границы](native-selfbuild-20260930.md#whole-array-address-repair).

### LOGICAL-RHS-EAGER-LOAD — 2026-09-30, Codex, FIXED `c8167af`

Read-only ревью общего expression-emitter обнаружило прежнюю ошибку:
`l2_eval_fields` включает short-circuit splitting только при
`l2_fields_has_call != 0`. Если правая часть не вызывает callable, но читает
массив, `l2_emit_array_load_at` может выдать загрузку во временную ячейку
до итогового `&&`/`||`; пропущенная по логике правая часть всё равно читается.
Это наблюдается по исходнику ещё до нынешнего indexed-span среза для literal
индексов и затрагивает новые dynamic operands. Вызовы в индексе уже проходят
существующий call-aware short-circuit; это не доказывает отсутствие обычной
загрузки в пропущенной ветви. Исправление — общий logical lowering независимо
от наличия вызова, с прежним приоритетом операторов, не Array-specific ветка.
Свидетель должен проверять положение загрузки относительно условной ветви
на безопасном индексе; не выдавать исполнение undefined out-of-bounds доступа
за положительный runtime-тест. Включено как зависимость текущего writer-среза.

### POINTER-ACTUAL-CONTRACT-BYPASS — 2026-09-30, Codex, FIXED `c8167af`

Отрицательные контроли `bounded_indexed_expression_20260930_05` показали,
что L2-вызов допускает `@` char-элемента к формалу int* и адрес int-элемента
к int**. `l2_check_value_convert_field` рано возвращает успех для
непримитивного принимающего типа, минуя уже существующий общий контракт
указателей. Подключить `l2_check_receiving_value` для pointer actual:
сохранить настоящую глубину, const, C99 void*/null/opaque-C различия и
имеющийся последующий admission именованной Structure. Не вводить правило
для массива, не назначать модель generic-указателю и не вычислять actual
повторно. Эта проверка не заменяет следующую проекцию callable-аргументов.

Первый полный прогон этого среза на SHA256 `97022323…996270` выявил две
настоящие регрессии ранее зелёных строк: `unit_named_addr_gap`, строка 17,
`pokez(@: A\e)`, и `unit_arg_addr_dyn_types`, строка 100,
`setnull(@: dp)`, отказываются как `assignment value has unknown type`.
Не менять эти положительные ожидания. В первом случае `l2_address_node`
ограничен идентификатором, тогда как прежний emitter уже умеет адрес
graph-path; общий тип/категорию надо получить тем же path resolver.
Во втором `l2_waits` видит атомы и безымянные контейнеры, но не зависимость
операнда receiver-Frame от ещё не типизированного hidden dp. Само
преобразование dynamic → own → formal в `l2_input_ft` сохраняет тип.
Нужны общая зависимость операнда от завершения type closure и единая
проекция адреса для checker/emitter; ни пропуск проверки, ни тип адреса
из желаемого формала не являются исправлением. Этот полный прогон
`bounded_indexed_expression_full_20260930_01` завершён: 964/1019, 55 FAIL.
Относительно предыдущего полного среза две ранее мигрированные фикстуры
прошли, 52 старых отказа остаются, все 16 новых строк прошли, удалённых
строк нет. Три прежде зелёных строки стали красными: два отказа адресов
выше и старый отрицательный P47-свидетель ниже.

`unit_callable_model_decl_refused` ожидал отказ для `int: q m\value`
во вложенном callable. Общий полный initializer-span теперь корректно
распознаёт q, и восстановление прежнего отказа было бы искусственным
ограничением. Но старая фикстура содержит снятый `Model: left` и не
проверяет результат. Её преемник должен передать существующий Model,
проверить ненулевое поле и результаты двух вызовов с разными аргументами,
а инверсия результата должна упасть. Это не доказательство полной native
компиляции возвращаемого callable: нынешний held/walked маршрут остаётся
отдельным долгом. Попытка заменить setup на явный merge выявила ещё
неподдержанный транспорт merge-result в захват формала; сохранить этот
отказ отдельно, а не возвращать неявное клонирование ради теста.

Итог перечисленных трёх исправлений — `c8167af`: восстановительный focused
gate 131/131 (128 фикстур); полный `bounded_indexed_expression_full_20260930_02`
— 970/1022, те же 52 прежних отказа, новых регрессий и удалённых строк нет.
Обе промежуточные адресные регрессии устранены, P47 проверяет результаты 8/9,
все 19 добавленных строк прошли. Контрольные поломки обнаруживают чтение
за actual-span, потерю initializer, eager RHS, неверные pointer-контракты,
раннюю проверку hidden-операнда и перезапись адреса соседним actual.
Описания выше сохраняют ход обнаружения и не означают, что эти исправления
ещё ожидаются. [Точные байты, результаты и оставшиеся границы](native-selfbuild-20260930.md#bounded-indexed-expressions).

### WALKED-CALL-REFERENCE-RESULT — 2026-09-30, Codex, FIXED `74df17d`

Ниже сохранены диагностика и границы исправления. Общая проекция return-cell
и модели результата проверена native и настоящим walker; фактические
байты, гейты и отдельно ограниченное покрытие callable-formal —
[в checkpoint](native-selfbuild-20260930.md#own-reference-cell-reception).

При подготовке кандидата `@: A p candidate()` найдено расхождение:
`l2_rw_call` отвергает результат trampoline-class > 4 как нечисловой,
а `l2_rw_call_ty` после int/char/size_t/unsigned/ulong возвращает int
для остальных типов. При этом `l2_ret_cell_ty`, заголовок результата
и общий runtime CALL уже передают контракт ссылочного результата.
Нельзя заменять вызов `candidate()` ссылкой на его callable occurrence
или обходить настоящий walker в положительном свидетеле.

В ограниченное исправление включена проекция существующего return-cell
контракта в checker/builder CALL. Использовать общую категорию поддержанной
ссылки, не особое имя/модель; неизвестный результат не считать int.
Проверить объявленный модельный и generic pointer результат с однократным
вычислением и обычным последующим admission. Runtime/opcode и более широкий
callable-actual механизм этой зависимостью не закрываются. Приведённые ниже
диагностики предшествуют итоговым runtime-свидетелям checkpoint.

Первый исполняемый diagnostic `own_reference_reception_20260930_03`
выявил связанную потерю объявленной модели: collector записывал return
`nsty` только для атома `Model`, но не для `@: Model`. Поэтому
`initial: typed()` отказывался до построения графа, хотя машинный тип
результата был указательным. Положительный контроль `@: Model` сохраняется;
замена его на более удобную запись не является исправлением.
Общий путь — выделить contract-to-model проекцию из
`l2_declaration_model`, использовать её для исходного return-contract
с тем же правилом сигнатуры depth 0/1, не угадывая модель по C ABI
и не считая ссылку большей глубины непосредственной Structure.

### OWN-REFERENCE-PATH-REPRESENTATION — 2026-09-30, Codex, FIXED `74df17d`

История обнаружения ниже сохранена. Итоговый общий шаг пути различает
direct Structure slot и pointer cell, сохраняет модель референта и допускает
запись до изменения настоящей ячейки; EQ открывает ссылочную ячейку один
раз. Native/walker и отдельная матрица EQ проверены [тем же checkpoint](native-selfbuild-20260930.md#own-reference-cell-reception).

Diagnostic `own_reference_reception_20260930_06` сохраняет положительные
свидетели повторного объявления: `while\ref` и `for\ref`, где `ref`
объявлено через `@: Model`, отвергнуты как непримитивные листья пути.
`l2_own_seg_scan` объединяет собственный direct Structure slot и pointer
cell в kind 3; namespace kind 3 уже означает прямую Structure-ссылку.
Native и walker при этом по-разному открывают промежуточный kind 3.
Расширение списка разрешённых листьев или безусловный DEREF kind 3
не исправляет это смешение представлений.

Исправление должно передавать существующую identity разрешённого own-row
через общий шаг пути: прямой слот остаётся прямым, explicit pointer cell
сохраняет точный pointer-контракт и отдельно модель референта. Общий
pointee lookup использует уже выбранную строку, не повторный поиск имени;
на следующем namespace-шаге прежняя row identity не переносится.
Лист читает значение настоящей ячейки, промежуточная ссылка открывается
один раз. Контроли — hosted leaf и `while\ref\value`, прямой вложенный
Structure-путь, native и настоящий walker; исключений для циклов нет.
Это зависимость текущей приёмки, не новый отдельный синтаксис или норма.

Diagnostic `own_reference_reception_20260930_08` проходит эти два
runtime-свидетеля нативно, но настоящий WalkRoot возвращает INVALID.
Сравнение `OF` pointer-cell с кэшированным `OWN` значением той же Structure
попадает между раздельными ветками EQ в `lmx_walk_eval`. Нужна одна
проекция ссылочного операнда: ячейка открывается один раз, descriptor/null
сохраняет identity; это не дополнительный implements или защитный валидатор.
Проверить оба порядка операндов, равенство/неравенство и null, не меняя
числовые сравнения. Runtime-правка требует свежих kernel и L3 гейтов.

Read-only ревью того же среза нашло и ранее недостижимый путь записи:
kind 10 пропускает receiving-check в `l2_check_path_write`, а native
pointer-store и walker `PUT_OF` не выполняют структурный admission.
Общий resolved pointer-контракт и модель поля должны поступить в обычный
receiving/admission путь до физической записи. Явный путь остаётся
физическим `PUT`, bare-присваивание — рабочим `SET`; несовместимый
candidate, вычисленный один раз, не заменяет прежнюю допустимую ссылку.
Свидетель отказа сохраняет обе проверки: caught-ошибку и старое значение.

### REENTRY-PUBLICATION-SUPPRESSION — 2026-09-30, Codex, FIXED `0c5dd61`

Guard и обслуживающие native/walker счётчики/связи удалены. Восстановленные
свидетели проверяют публикацию внутренней активации, чистый внешний возврат
и адрес реальной объявленной ячейки. Focused 192/192, kernel 281/281,
L3 11/295, полный корпус 988/1040 с теми же 52 прежними отказами.
[Точные байты и границы](native-selfbuild-20260930.md#reentry-publication-repair).
Ниже — исходное наблюдение до исправления.

`l2_emit_publish` требует `l2_reent = 0`, а `lmx_walk_publish` сразу
возвращается при `f.reent`. Это подавляет записи рекурсивной активации
вместо обычной dirty-публикации. `steps/working-state-7b.md` §3 и commit
`cf7dd58b` прямо приписывают исключение прежнему прочтению Codex;
первичной авторской нормы об этом не найдено. Удаление скрытого I2
не отменяет общие границы публикации. Действующие спецификации теперь
согласованы на одной S и отдельных рабочих значениях активаций.

Старые `unit_cache_reentry*` ожидают 223, хотя общая последовательность
публикаций даёт 293. Снятие guard уже измерялось как исторический мутант
TM10/KM5, а не как самостоятельное новое правило. Следующий ограниченный
срез после own-reference checkpoint снимает guard и обслуживающие его
счётчики/связи, сохраняет ordinary frames и добавляет настоящий native/walker
контроль чистого внешнего возврата. [Точные границы и приёмка](native-selfbuild-20260930.md#reentry-publication-repair).

### LOCAL-REFERENCE-PATH-ROOT — 2026-09-30, Codex, OPEN

Diagnostic `build/l2_harness/own_reference_reception_20260930_13` сохраняет
`unit_reference_callable_result.lm2`: после `@: Model ref f()`, где формал
f возвращает `@: Model`, выражение `ref\value` отказывает на 12:27
с `unknown field path root`. У Model есть `size_t: value 7U`.
Отдельный `_14` доказывает вызов формала, identity результата и счётчики
1/2 при инициализации и перепривязке, но не чтение поля через локальную
ссылку; дополнительное чтение не объявлено поддержанным.

Сопоставить общий resolved local binding, его model metadata и контекст
`l2_path_root` с [единой lexical-local identity](callable-actual-projection-20260930.md#site-aware-hidden-source).
Не создавать новый поиск по имени для одной записи `ref\value`. Сохранить
положительный свидетель с обоими чтениями поля и настоящий walker при
исправлении. Пока это измеренный пробел: сравнение с исходным baseline
не выполнено, поэтому он не помечен доказанно старым или регрессией.

### MERGE-RESULT-PHANTOM-NAMESPACE — 2026-09-30, Codex, OPEN

Диагностика `build/l2_harness/reentry_publication_20260930_04`,
`unit_named_self_path_copy`: после явного `R: merge: Counter` последующее
`R()` ошибочно собирается как новая статическая namespace R. Порожденный
L1 сохраняет merge-result в слоте 4, но читает `R\hits` через пустой слот 6;
вызов R не порождается. Native и walked строка останавливаются с
`a field path met no Structure`, exit 3. Это не основание менять правила
вызова: R уже объявлено явным merge. Проверить identity существующей
привязки в общей предварительной классификации и её потребителях;
не добавлять исключение для написания `R()` или имени результата.
Срез повторного входа исследует минимальную общую зависимость; широкая
переделка относится к [классификации известной головы](native-selfbuild-20260930.md#known-structure-call-classification).
Прямое сравнение этой новой фикстуры с исходным baseline пока не проведено.

Следующий diagnostic `_05` исключил `R()` и всё равно получил
`unresolved name` на 16:48 при передаче голого R обычному C-вызову.
Значит, проблема шире скобочной формы. Предварительная классификация
`l2_head_absent` / `l2_unit_declares` и последующий `l2_merge_scan` должны
видеть одну привязку результата; известный callable-result затем должен
поступать в общий call-путь, а не требовать статической namespace.
Тестовый observer, захватывающий действительный результат существующего
merge и вызывающий его через обычный dispatcher, позволяет отдельно
проверить self-пути копии, но не закрывает эти два source-level отказа.

### WALK-PATH-CALL-ORIGINAL-OCCURRENCE — 2026-09-30, Codex, FIXED `0c5dd61`

Общий path-headed call передаёт существующее выражение пути в EXEC child 2;
цель вычисляется один раз, dispatch использует выбранный дескриптор.
Независимые оригинал и копия дают 1,1,2,2 при фактических native и walker
вызовах; возврат к статической исходной цели обнаружен runtime-мутантом.
[Приёмка](native-selfbuild-20260930.md#reentry-publication-repair).
Source-level привязка R после merge и внешний `A\M\hits` этим не исправлены.
Ниже — сохранённая диагностика до исправления.

`reentry_publication_20260930_09`: native `unit_self_path_copy` проходит,
а действительный walked-root запуск `unit_walk_self_path_copy` возвращает
ошибку свидетеля 81. Четыре CALL для `A\M()` / `R\M()` сохраняют
статический исходный M одновременно как callee и owner, а не выбранное
пути вхождение. Явные self-пути внутри M уже используют текущую Structure;
ошибка находится раньше, при построении CALL. Использовать общий resolved
path для выбора вызываемого, без особого маршрута «вызов копии».
Это непосредственная зависимость среза повторного входа.

Предшествовавшая зелёная строка с одним `WalkMethods` не была доказательством
walker: native root вызывал нативную C-функцию напрямую, минуя очищенное
слово `native` дескриптора. `WalkedMethods` проверяет наличие графа и слово
дескриптора, но не доказывает исполнение этого графа. Приёмка должна
прослеживать фактический dispatcher/CALL и запускать нужное тело обходчиком;
название фикстуры или флаг сами по себе этого не подтверждают.

### NESTED-CALLABLE-OWN-FIELD-PATH — 2026-09-30, Codex, OPEN

`reentry_publication_20260930_03/src/unit_self_path_copy.lm2:18:9`:
`A\M\hits` отказывает с `unknown field path segment`, хотя вызовы
`A\M()` и `R\M()` в следующем diagnostic `_04` исполняются и возвращают
независимые значения явного self-пути `M\hits`. Поддержка вызова не
доказывает поддержку последующего шага к объявленному полю callable.
Сохранить исходный внешний path-свидетель для общего обхода разрешённой
Structure/метода и его own-layout; возвращаемый self-path не закрывает
этот пробел. Связанный маршрут — [canonical body/copy и общая identity](native-selfbuild-20260930.md#one-complete-lexical-graph).

### NAMED-PRIMITIVE-OMITTED-INITIALIZER — 2026-09-30, Codex, OPEN

`reentry_publication_20260930_03/src/unit_named_self_path_copy.lm2:2:1`:
поле `size_t: hits` в именованной Counter отвергнуто как
`a named Structure field needs a name`; имя hits при этом явно есть.
В диагностике `_04` явное `size_t: hits 0U` проходит трансляцию.
Отсутствие initializer не означает отсутствие имени и не разрешает
требовать особую форму объявления внутри named Structure. Исправление
должно использовать общий declaration/receiver contract, не отдельную
ветку для size_t или неявное обнуление всех примитивов. Пока зафиксированы
эти два конкретных входа; остальные типы и baseline отдельно не проверены.

### OWN-REFERENCE-CANDIDATE-LOSS — 2026-09-30, Codex, FIXED `74df17d`

Исходный дефект описан ниже. В итоговом срезе общий declaration/receiving
путь выполняет initializer, в том числе нулевой при повторном объявлении;
отказ admission сохраняет прежнюю ссылку. [Приёмка и оставшиеся границы](native-selfbuild-20260930.md#own-reference-cell-reception).

Read-only проверка общего контракта `@:` подтвердила различие реализации,
не неоднозначность нормы. Machine-local `@: A p`, `@: A p 0` и `p: 0`
используют общий receiving-checker; native admission имеет условие
`candidate != 0`, поэтому ноль не проверяется как Structure и не порождает
её экземпляр. Omitted Model-ссылка реально проверена в
`assignment_rhs_observers_20260930_final`, `unit_rhs_reference_admission`;
явный ноль Model-ссылки здесь установлен чтением кода, не отдельным новым
runtime-свидетелем.

У own/root pointer-cell маршрута есть другой дефект: ветви
`l2_own_ref_decl` в native statement emission и retained-graph construction
пропускают объявление целиком, полагаясь на заранее нулевую ячейку.
Начальный ненулевой candidate также пропускается. Позднее `p: 0`
не представлено общим присваиванием: `l2_rw_ref_bind` принимает только
двухпольное `@ v` и отказывает до обычного receiving/admission маршрута.
Это не отказ `implements(null,A)` и не разрешённое различие root/method.

Нужна общая инициализация/перепривязка существующей pointer-cell через
тот же declaration/value/receiving контракт: ноль, существующая ссылка,
Structure-кандидат после преобразования и admission, однократное вычисление.
Отрицательные type/depth/const/admission проверки сохраняются. Проверить
нулевое начало, ненулевой candidate, последующую смену/обнуление и сохранение
старого значения при отказе, как native, так и реально интерпретируемым
телом. Не добавлять отдельную семантику верхнего тела или второй data-граф.
Исправление выполнено после `5f11b50`. Повторное достижение объявления
после ненулевой привязки проверено: отсутствие initializer означает тот
же ноль, что явный initializer 0, а не сохранение прежнего значения.

### HIDDEN-POINTER-LOCAL-SOURCE — 2026-09-30, Codex, FIXED `e70689c`

SITE-срез закрыл видимость по месту через существующие own-строки,
сохранённые SourceSite и общий input/model resolver. Прямое и многошаговое
forwarding, host/formal shadow, initializer exclusion, future/depth/const
отказы проверены на финальном срезе. Ниже — исходные измерения;
[точная приёмка](native-selfbuild-20260930.md#site-visibility-release).

Актуальный срез — `71c4743`: явные указатели уже находятся в общих own-строках,
поэтому описанная ниже первоначальная причина с machine-local больше
не действует. Повторный прямой и многошаговый forwarding с реальной
identity и изменённым pointee проходит native и настоящий WalkRoot.
Новая проверка `site_visibility_20261001_preflight` выявила недостающую
видимость по месту: вызов **до** единственного объявления p ошибочно
принимается и читает будущую ячейку (runtime 99 в обоих режимах).
Исправленный по синтаксису `host_shadow` в `site_visibility_20261001_preflight02`
падает в обоих режимах с 82: вызов внутри блока до объявления выбирает
будущий внутренний p вместо ещё видимого внешнего. Формальное затенение
проходит native, но настоящее walked исполнение пока INVALID.

Владелец — единственный source writer. Нужен общий source-site selector
по **существующим** own-строкам, сохранение области/места/exclusion для
отложенных проверок и отдельных call sites; не второй pointer registry.
Прежний случай теперь регрессионный контроль, не новое исправление.
Следующие абзацы сохраняют историческую диагностику до `71c4743`.

Сохранённая `bounded_indexed_expression_20260930_07/src/unit_pointer_actual_contract.lm2`
вызывает `hidden()` из `check`, где уже объявлен локальный `@: int p @values[0]`;
`hidden` передаёт свободный p в `read(p)`. И прежний frozen binary
`whole_array_address_20260930_final`, и новый дают `unresolved dynamic=p`
в 13:14. `l2_ml_collect` уже сохраняет точный pointer-контракт, но
`l2_dyn_step` и `l2_hidden_from` ищут источник скрытого входа среди
formal/own, пропуская machine local. Нужен общий источник binding/category
для замыкания типов и передачи actual. Нельзя просто видеть все locals
метода: сохранить видимость только вперёд и точную область места вызова,
затенение, const/глубину и идентичность указателя. Значение передаётся в
обычную активацию по Q52, без нового постоянного data/context-графа.
Прямой и многошаговый forwarding, изменение исходного pointee до вызова,
позднее/внешнее объявление и depth/const-отказы нужны как свидетели.
Исправление следует отдельным срезом; explicit-параметры текущих actual-тестов
изолируют проверку pointer-контракта, но не закрывают этот скрытый вход.

Повторный аудит обнаружил связанный общий долг local identity:
`l2_ml_collect` дедуплицирует весь метод по первому имени, а
`l2_emit_reference_declaration` выводит каждое объявление с исходным
именем без уникальной привязки. Вложенные области действительно дают
вложенные C-блоки, но повторные pointer-декларации в одной области
порождают повторное C-объявление, а metadata различает только первое.
Поэтому два новых lookup в hidden closure/emission ещё не закроют
общее разрешение locals: тот же source-site/declaration identity нужен
type/model/address/target/value потребителям и native-именованию.
[Уточнённые границы и потребители](callable-actual-projection-20260930.md#site-aware-hidden-source)
не вводят ограничения языка на повторные объявления.

<a id="callable-formal-hidden-contract"></a>
<a id="callable-formal-free-names-by-contract"></a>
### CALLABLE-FORMAL-HIDDEN-CONTRACT — 2026-10-01, Codex, OPEN (блокер G5); первый срез, транспорт отсутствующего входа и требования по месту вызова исправлены 2026-10-04

**Первый срез, 2026-10-04.** Вызов через callable-формал формирует скрытые входы методов, которые до
формала доходят, и никогда — список метода-образца. Транслятор записывает, где фактический встречает
формал (названный метод единицы; формал, переданный дальше; вызываемый, который сам значение
формала), замыкает эти факты до неподвижной точки скрытых входов, и свободные имена доходящих
методов входят в неё как обычное известное требование: потребитель наследует то, чего сам не
связывает, а его вызывающие подают это по обычному правилу. Измеренные программы выше дают 10, 41 и
значения фактического; цепочка «внешний формал `other` 40 — `run` без `other` — `g1` через `q`» даёт
41; взаимная рекурсия и вызываемый-формал сохраняют имена; поданный ноль присутствует; вход, которого
нет ни у кого, отвергается до входа (`unbound dynamic input`); определение, которое никто не
вызывает, транслируется и ничего не требует.

**Второй срез, часть первая, 2026-10-04.** Вход, которого не связывает ни один вызывающий, передаётся
отсутствующим (`refs[k] = 0`). Метод, который имя только пересылает, отдаёт свою запись дальше как она
есть и собственный лексический источник не читает. Метод, который имя читает, берёт собственный
лексический источник через родителя своего вхождения: нативный вход делает это так же, как ARG
обходимого тела. Поданный ноль присутствует. Метод, который читает или присваивает имя сам, передаёт
дальше своё рабочее значение; поле единицы при этом не пишется. Измерено: `unit_absent_input_forward`
и `unit_absent_input_reader` на трансляторе `5afcb650` дают неверное значение нативно и
`walk error: INVALID` при обходе методов; теперь проходят в обоих режимах. Сравнение лексических
объявлений из условия «входы формируются одинаково» снято:
`unit_callable_formal_free_names_lexical_differ`, которую первый срез отвергал, а транслятор до него
исполнял верно, снова даёт 2 и 2 ([§58 журнала](fable-continuation-20261003.md#absent-input)).

**Второй срез, часть вторая, 2026-10-04.** Один формал получает callable с разными свободными именами:
вызов через формал выбирает формирование по точному вхождению, которое формал держит, и формирует
входы именно этого callable; список метода-образца не используется ни одной ветвью, последний класс —
доказанный остаток, без сравнения и без остановки. Место вызова спрашивает у вызывающего только имена
того callable, который оно подаёт: записи остальных альтернатив передаются отсутствующими, и
вызывающий без имени чужой альтернативы не отвергается. Условия, при которых метод нуждается в имени,
хранятся целиком, без предела на их число. Обязательный вход, который некому подать, отвергается при
трансляции там, где начинается цепочка (`unbound dynamic input`), а не остановкой процесса: аварийная
проверка входа, добавленная первой частью, снята. Измерено: `unit_callable_formal_free_names_differ`
даёт 10, 5, 4105 и 1077; `unit_callable_formal_site_names` и три её продолжения транслируются и дают
значения поданного callable; цепочка, где имя нужно только при шести условиях сразу, не требует его у
корня ([§59 журнала](fable-continuation-20261003.md#site-requirements)).

Что ещё не построено, каждое с отказом на месте как предел реализации и красным обязательным
позитивом: ссылка среди имён альтернативы, которую место вызова не подаёт, — отсутствующим передаётся
пока только число ([SITE-REFERENCE-NOT-LEFT-OUT](#site-reference-not-left-out)); до формала доходит
вхождение, за которым трансляция не следит, — вхождение из другой трансляции через экспортированную
обёртку метода библиотечной единицы (`unit_lib_callable_formal`); потребитель с callable-формалом при
обходе методов (`_self_walk`); узел, построенный при исполнении, — возвращённого определения или
merge — среди callable другого формирования у одного формала
([HELD-ACTUAL-NODE-CLASS](#held-actual-node-class), там же `unit_callable_formal_unfollowed_actual`).
Узел merge как фактическое теперь прослеживается (`unit_t7_convert` зелёная). Это покрытие
реализации, не ограничение языка ([§57](fable-continuation-20261003.md#formal-formation),
[§58](fable-continuation-20261003.md#absent-input),
[§59](fable-continuation-20261003.md#site-requirements),
[§61](fable-continuation-20261003.md#held-actual) и
[§62 журнала](fable-continuation-20261003.md#merge-actual)).

**Измерено 2026-10-04, fable, транслятор `69d3d9a5`, нативно.** Минимальные программы запущены.

```text
int: base 5
int: other 9
fn: f0 () int
    return: base
end: f0
fn: g1 () int
    return: other + 1
end: g1
fn: run (f0: q) int
    return: q()
end: run
int: r run(g1)             # даёт 6: g1 получил base на месте other; по норме 10
```

С `int: other 40` внутри `run` — снова 6, по норме 41 (привязка вызывающего). Фактический с двумя
свободными именами против одного у образца, без свободных имён против одного, с одним против нуля —
программа принимается и останавливается при исполнении: `lmx: invariant: a trampoline was called
outside its method's signature`. Верен только случай, когда свободные имена фактического совпадают с
образцом. С обходом методов любая из программ отвергается (`a callable result or a callable formal
is outside the walkable subset`) — это долг реализации, не нормативный отказ.

Решение Codex (FABLE-CODEX-20261004-12, второй ответ): фактически выбранное вхождение даёт свой
полный контракт входов; список скрытых входов образца — не вектор аргументов постороннего
фактического. Источники свободного имени фактического: ближайшая текущая привязка вызывающего, затем
его уже унаследованный динамический вход, затем допустимый лексический источник самого вхождения.
Отсутствующий обязательный вход — обычный отказ вызова до входа, не аварийный останов; присутствующая
несовместимая привязка вызывающего — не отсутствие и не должна молча заменяться лексическим
значением. Не чинить `l2_method_sig_compatible` требованием одинаковых скрытых имён или дополнением
недостающих ячеек.

Ответ автора о механизме, 2026-10-04: таблица имён во время исполнения запрещена при любых условиях,
имена служат только трансляции и `toLmx`; адреса существующих объектов не двигаются
([запись](../LMX_blog/2026-10-04.md#no-runtime-name-table),
[закрытый вопрос](../LMX_blog/q/graph-hidden-input-name-binding.md)). По решению Codex (третий и
четвёртый ответы) соответствие входов фактического их источникам разрешается при трансляции, а
исполнение идёт по ссылкам, выбранным местам объявления и позициям входов. Реестр хешей имён, запись
METHOD, поле Lmx, метаданные атома и постоянный вспомогательный граф не допускаются. Раскладка
свободных имён при вхождении не считается утверждённой только потому, что в ней адреса вместо строк.

Где связь теряется, строки на `69d3d9a5`. Источник скрытого входа известного вызываемого выбирает
`l2_hidden_from` (:26333): формал или унаследованный вход вызывающего, его используемое собственное
поле, затем объявление в лексическом окружении вызываемого. Structure достигается через родителя
выбранного вхождения (`l2_c<self>\parent`, :26374); ячейка числа — как место поля от собственных
объемлющих Structure вызывающего (`l2_own_from_expr`, :11419), не через вхождение. Имя
разрешается при трансляции, исполнение получает адрес или значение. Вызов через формал
(`l2_emit_call`, :27958) берёт число явных и скрытых входов у метода-образца (:28014, :28015) и
выбирает источники для образца (:28114); список фактического в вызов не входит. Трамплин
фактического проверяет только число входов (:29209). У самого вхождения фактического его входы
физически есть: часть аргументов подписи держит по ячейке на формал и на сквозное имя
(`l2_emit_parts`, :43400, :43428). У обходимого тела отсутствующий скрытый вход читает лексический
источник через `node` (`l2_rw_arg_fb`, :34271; `l2_mad_inputs`, :38827); у нативного трамплина такого
чтения нет. Проект общего пути идёт Codex до правки транслятора.

Обязательные позитивы, красные: `unit_callable_formal_free_names_other` (равное число, другие имена),
`_override` (привязка вызывающего), `_extra` (лишний скрытый вход), `_none` (ни одного против одного
и один против нуля), `_forward` (пересылка формала), `_self_walk` (точное совпадение с обходом
методов). Зелёный контроль: `unit_callable_formal_free_names_self`.
[HELD-CALLABLE-TO-CALLABLE-FORMAL](#held-callable-to-callable-formal) ждёт того же пути
([§54](fable-continuation-20261003.md#formal-free-names) и
[§55 журнала](fable-continuation-20261003.md#actual-inputs-ruling)). Запись под именем
CALLABLE-FORMAL-FREE-NAMES-BY-CONTRACT, заведённая в `a87822ea`, была дублем этой и свёрнута сюда;
её якорь сохранён. Ниже — запись, как она стояла.

Read-only аудит `71c4743`: `l2_method_sig_compatible` сверяет явные
аргументы/результат/throws, но `l2_emit_call` при вызове через формал
готовит скрытые входы по требуемому образцу, не по фактически выбранному
callable. Если образец имеет только int x, а переданный метод читает
свободный delta, передаётся один физический аргумент в adapter с двумя.
При равном числе скрытых входов, но разных именах a и b, возможна тихая
подстановка a на место b. Это пока source-traced дефект; минимальные
программы **ещё не запускались**.

Норма уже есть: формировать обычные требуемые входы фактически выбранного
callable по [приоритету источников](../docs/LMX_semantics.ru.md#dynamic).
Не требовать равенства списков скрытых имён как нового правила допуска.
Владелец — следующий bounded callable-projection срез после текущей
видимости и static native-dispatch; последний сам по себе это не закрывает.
[Пути и раздельные свидетели arity/wrong-name](native-selfbuild-20260930.md#native-call-dispatch).

<a id="named-structure-number-argument-typed-unknown"></a>
<a id="callable-formal-statement-call-internal"></a>
### CALLABLE-FORMAL-STATEMENT-CALL-INTERNAL — 2026-10-01, deepseek, FIXED срезом K04d

Минимальная программа (`build/deepseek_k04d/src/s7_simple.lm2`), найденная при работе над строкой 6
матрицы K04:

```text
int: hits 0
sub: task ()
    node\hits: node\hits + 1U
end: task
fn: recv (task: f) int
    f()
    return: 0
end: recv
int: a recv(task)
```

Даёт `l2trans error: …: internal: a refusal said nothing (a step failed without a located diagnostic)`:
шаг вернул отказ без локализованной диагностики. Это не отказ языка — явное исполнение полученного
callable-формала (`f()`) законно.

Повторное измерение 2026-10-02 на неизменённых байтах `5576e6f8` (аудит Codex
`GROK-CODEX-CALLABLE-AUDIT-20261002-02`, те же пробы Grok): отдельная строка `f()` падает тем же
`internal` и для возвращающего контракта (`fn: mk () int`). Прежняя фраза «возвращающий оператор
транслируется» этим измерением не подтверждается: зелёный контроль был `return: f()`, приём
результата, а не отдельная строка. Позиция значения по-прежнему даёт локализованный отказ
«a callable without a result has no value». Неизвестное `f()` остаётся пустой именованной Structure.
Обычное связывание указателя от этой починки callable не становится.

Измеренные границы (временные печати в пробной сборке; исходник восстановлен):

- падает операторная форма и невозвращающего, и возвращающего формала; вызов
  не-возвращающего формала в позиции ЗНАЧЕНИЯ даёт правильный локализованный отказ
  «a callable without a result has no value»;
- фаза: `l2_emit_body` метода с формалом (печать `emit_body method=1` есть, следующая
  `ret_tr method=1` — нет); это не обходчик (`l2_rw_methods_emit` — его печать не срабатывает) и не
  `l2_eval_discard` (его печать не срабатывает);
- `l2_discard_run` для кадра `f()` возвращает 0 (`l2_expr_span` = 1, условие `n > 1` не выполнено),
  поэтому оператор не идёт общим путём отбрасываемого выражения — а именно там живёт работающая
  ветка для голого атома callable (`l2_eval_discard` → `l2_emit_call` с sel 2). Гипотеза владельца:
  операторный кадр вызова формала должен идти тем же путём; иначе — локализованный отказ, а не
  `internal`.

Закрыто срезом K04d. Эмиссия больше не принимает отдельную строку известного callable-формала за
присваивание ему: `l2_head_is_call` уже признавал вызов, и существующий путь отброшенного вызова
теперь до него доходит. Свидетели native: `unit_formal_frame_stmt` (`m 1`, код 5) и
`unit_formal_frame_sub_stmt` (`s 1`, код 0). Обходчик для этих строк не заявлен. Полный гейт
`build/l2_harness/gk_formal_frame_full_01`: 36 из 1145, те же 36 удержанных отказов, что у K04c
(1143 цели); новых отказов нет. Блоб исходника `9168b081`.

<a id="named-structure-number-argument-typed-unknown"></a>
### NAMED-STRUCTURE-NUMBER-ARGUMENT-TYPED-UNKNOWN — 2026-10-01, deepseek, FIXED срезом K04c

Измерено пробой при работе над строкой 7 матрицы K04: `A: (int: x 1)` в корне единицы, метод
`fn: m () int` с `return: g(A)` и `fn: g (int: n) int` **принимался**, и сгенерированный C читал
дескриптор Structure как int (`int: l2_arg2 lmx_arena_ref_struct(node, 5U)`, затем
`lmx_int_value_known(refs[0])`). Та же форма с локальным объявлением (`A: b`, затем `g(b)`) в методе
отвергается «a reference where a number is asked» (строка `unit_valkind_arg_ref_refused`), то есть
две формы одного правила расходились.

Read-only причина: `l2_colon_bound_ty` типизирует собственное поле, формал, динамический вход, слот и
machine local, но имя именованной Structure верхнего уровня — ни одно из них; функция возвращала 1
(«неизвестно»), а `l2_check_value_convert` при неизвестном типе источника не проверяет ничего.

Ремонт: `l2_colon_bound_ty` типизирует имя именованной Structure верхнего уровня как ссылочное
(`l2_colon_graph_ty()`), и существующая проверка места-числа отвергает его тем же текстом. Свидетели —
`unit_named_struct_number_arg_refused` и соседи строки 7.

<a id="sub-actual-number-argument-classification"></a>
### SUB-ACTUAL-NUMBER-ARGUMENT-CLASSIFICATION — 2026-10-01, deepseek, FIXED срезом K04c

Классификационная половина [SUB-ACTUAL-REFERENCE-CLASSIFICATION](#sub-actual-reference-classification)
в позиции аргумента: callable без результата, переданный числовому формалу, отвергался
«a callable without a result has no value» вместо обычного отказа ссылки. Теперь обе формы
(голый атом и нульарный кадр) дают «a reference where a number is asked» — тот же текст, что уже
закреплён за Structure в числовом аргументе. Свидетели — `unit_value_call_sub_refused` (переведена на
новый текст), `unit_callable_frame_int_refused`. Остальное у дефекта-родителя (обычный ссылочный
формал, получающий callable; пути; проекция в native/walker) остаётся открытым.

<a id="sub-actual-reference-classification"></a>
### SUB-ACTUAL-REFERENCE-CLASSIFICATION — 2026-09-30, Codex, OPEN

После исправления неправильного valued return корня `unit_value_call_sub_refused` сохраняет `sub: s ()`, `fn: g (int: n) int` и `g(s)`. Корректен отказ несовместимому int-аргументу, но текущий `l2_check_value_call` сначала запрещает любое callable без результата как значение. Это не только текст: обычный ссылочный формал тоже попадает в этот путь вместо передачи дескриптора; отдельный callable-formal fast path принимает лишь ATOM имени unit-метода, не общую разрешённую привязку или переданный дальше формал.

Read-only цепочка на translator blob `e19c599184993d79ff6c42e15619b39b08b12d33`: `l2_check_call` → `l2_check_fields` → `l2_check_primary` → `l2_check_value_call` (около 18961); Frame-ветвь `l2_frame_void_call` повторяет запрет. Простого удаления ошибок недостаточно: native `l2_prep` всё ещё вызовет тело. Норма [аргументов](../docs/LMX_semantics.ru.md#callables) выбирает результат либо ссылку по принимающему контракту; sub передаётся ссылкой, а явное исполнение в позиции оператора сохраняется. Исправление должно дать общую проекцию аргумента checker/native/walker, без отдельного поведения скобочной формы, автоматического снятия уровня `@` или нового графа. Проверить reference identity без выполнения, последующий явный вызов, пересылку формала, пути и эквивалентные формы, обычный структурный admission, int/depth-отказы и returning-callable контроли. Полноту обхода тела callable-формала отдельно не приписывать прохождению root-walker, который может вызвать ещё нативного получателя.

Точный [аудит потребителей и путь общей переделки](callable-actual-projection-20260930.md#shared-projection) отделяет норму от предлагаемой реализации.

Native-половина строки 5 закрыта срезом [K04e](k04-callable-actuals-20261001.md#k04e). Обычный непримитивный формал `(Holder: x)` и `(@: Holder x)` принимает вхождение callable без результата по его собственным полям. `unit_occ_descriptor_formal` читает `mark` равным 4; три передачи не меняют `hits`; следующий явный вызов доводит `hits` до 2; вход 7. Несовместимое поле отказывается `unit_occ_descriptor_refused.lm2:17:13: implements is false in function argument`. Возвращающий callable в той же позиции по-прежнему исполняется. Обходчик, строка 8 и пересылка формала этим срезом не закрыты.

Путь и тень own строки 6 закрыты срезом [K04f](k04-callable-actuals-20261001.md#k04f). `Holder\other` и `Holder\other()` выбирают вхождение `other`, не одноимённый unit-метод `task`; две передачи и по одному вызову формала оставляют `hits` равным 20; вход 7. Own `int: task` скрывает unit-метод: `unit_occ_own_shadow.lm2:15:5: incompatible entry signature`. Явная pointer-привязка этой строки не измерена. Обходчик и строка 8 этим срезом не закрыты.

### MERGE-RESULT-STALE-LITERAL-CHECK — 2026-09-30, Codex, FIXED `661735a`

Новая native/walker-проверка `observer_migration_20260930_02`, `unit_root_merge_three_operands`: native завершается с кодом 3 (`merge result check 72`), настоящий walker проходит. После `R: merge Model B C` программа явно пишет `R\x: 6U`, затем делает `S: merge R`. В generated C около строки 1376 после второго merge проверяется не текущее значение R, а старый литерал `3U`. Источник — `l2_mrs_val` в безусловной эмиссии result-check (текущий `l2trans.lm1`, около 31789/31791). Такая проверка отвергает законное изменение исходных данных. Нельзя исправлять её исключением для R, новым литералом 6 или отказом от parity. Проверить весь блок `merge result check 71…91`: отделить реальные ошибки операции/admission от тестовых проверок результата, перенести последние в соответствующие свидетели вместо постоянной генерации защитных проверок. Пока после исправления не прошли чтение S\x, немодификация исходников и alias/copy checks, правильность самого native merge не считать доказанной.

Read-only аудит подтвердил: весь post-success блок 71…91 — самопроверки width/value/alias/copy/native/qualified свойств, не языковой admission. `l2_mrs_take_entry/result/join` переносят литералы в `l2_mrs_vk/val` только при статическом построении карты; runtime-присваивание не должно обновлять эти метаданные. Удаляются ненужные значения, семь используемых лишь этой диагностикой helpers и emitted locals `l2_myp/l2_malias`; реальные kind/name/ent, ширины и пары полей сохраняются. Девять harness-строк требуют замены пинов результата настоящими наблюдениями. Writer принят после RELEASE наблюдателей; `observer_migration_20260930_final02` намеренно оставляет данный native/walker отказ красным.

Исправление прошло `merge_live_20260930_03` (17/17) и расширенный `merge_live_20260930_final` (43/44). Единственный отказ последнего — прежний абсолютный slot-pin в `unit_a3_capture_direct_vs_copy`, уже красный на полном baseline; отдельно программа прошла 13 проверок с результатом 7. Оба root-merge проходят native и настоящий walker, второй merge читает изменённое значение 6. Новая фикстура проверяет изменения scalar/CHAR до merge и независимость копии; Array-проверки отдельно наблюдают физическую копию пустого/непустого backing. Восемь неверных тестовых ожиданий и пять намеренных повреждений обнаружены, исходные байты восстановлены. Alias/cycle остаются предметом существующих kernel-тестов, не новой заявленной generated-проверкой. Код опубликован в `661735a`; [точные байты и границы](native-selfbuild-20260930.md#merge-live-verified-wip).

### CATCH-FORMAL-RETAINED-GRAPH — 2026-09-30, Codex, FIXED `661735a`

Полный `after_return_full_20260930_01`, `unit_s1_catch_user_break`: нативное тело содержит catch/break/continue, но в generated L1 нет ни одного `LMX_WALK_OP_*`; сохраняется лишь граф полей и методов. Причина по замороженному исходнику: общий `l2_rw_methods_count` вызывает `l2_rw_may`, который через `l2_rw_is_hosted` отвергает поля catch-формалов; `m_steps=-1` убирает всё операторное тело. Это настоящая потеря представления поддержанного L3-тела, не дрейф номера временной переменной. Исправлять общий допуск catch/PAD-хранилища для любой callable, без обхода проверки только для E.

Уточнение read-only аудита: numeric catch-поля уже имеют реальные `fid/fchild`, PAD ссылается на ту же ячейку, а `l2_own_cached` независимо отключает рабочий cache для catch-owned полей в обоих режимах. Поэтому eligibility можно исправить отдельным небольшим срезом до унификации body: убрать исключение catch из `l2_rw_is_hosted`, сохранить общий типизированный допуск и прямые OF/PUT_OF, в `l2_rw_catch_stmt` использовать общий `l2_rw_enter/leave`, чтобы handler-local declaration не оставлял binding формала после выхода. Native/PAD layout и runtime bind менять для этого не требуется. Проверить исходный результат 105 и реальные PAD/BREAK/CONTINUE/CALL; дополнительно чтение и изменение параметра (3 → 7), повторную доставку разных значений, восстановление scope и физическое равенство PAD-параметра ячейке catch-body. Root и обычный метод должны исполняться native и настоящим walker с подтверждённым очищенным native-word проверяемого callable. Empty-catch сам по себе этот дефект не проверяет. Копирование графа handler остаётся отдельным пунктом canonical-body/copy, а неподдержанные типы не становятся поддержанными от снятия numeric-исключения.

Первый focused runtime-прогон после снятия eligibility-исключения сохранил PAD/WHILE/CALL, но свидетель затенения обнаружил ещё два потребителя той же области: `l2_rw_formal_slot` исключал объявления в catch, а native `l2_host_is_body` не распознавал зарегистрированное handler-body внутри операндов catch и оставлял binding формала после выхода. Они входят в исправление общего scope. Явный путь `once\catch\x` пока мешает walker-понижению; этот отдельный путь не считать поддержанным по прохождению свидетельства PAD/ячейки.

Итог `catch_pointer_20260930_final2`: 47/47, включая исходный результат 105, параметры 3 → 7 и повторные 3/5 → 7/9; после затенения формала общий результат 20. Проверено native и настоящим обходчиком того же графа, с очищенным native-word у проверяемых методов; PAD хранит ссылку на каноническую ячейку. Мутация без восстановления scope даёт 83 вместо 20. Код опубликован в `661735a`; точные байты и границы — [в рабочей записке](native-selfbuild-20260930.md#catch-pointer-verified-wip).

### CHAR-ADDRESS-ASSIGNMENT-TYPE — 2026-09-30, Codex, FIXED `661735a`

Свидетель `char_declared_old_20260930_02` на исходнике `9d5fc38` остановился раньше runtime: после объявлений `char: a 'A'` и `@: char p` запись `p: @ a` даёт `assignment value has incompatible type`. Это не доказательство ошибки интернирования. Срез хранения измеряется отдельно через уже поддержанный явный cast в инициализаторе указателя; он не закрывает прямое присваивание адреса.

Read-only причина: `l2_slot_decl_ty` помечает `@: char p` кодом 3 (`const char*`), `l2_collect_decls` сохраняет его в `l2_st`, тогда как общий `l2_declaration`/`l2_contract_formal` и правильное `l2_address_name(@a)` дают код 12 (`char*`). Native slot-пролог при коде 3 всё равно печатает mutable `@: char`. Тип нельзя выводить из исторического места хранения: брать уже разрешённый тип из общего declaration-contract и печатать его через `l2_pointer_decl_text`, не разрешать 3↔12 в admission. Проверить flat/Frame адрес, адрес самого `p` (mutable `char**`), int/size_t-контроли, const и отказы несовместимых типа/глубины. Коррекция не меняет Structure-descriptor address и независима от Q58 и char-хранилища. Разделение legacy slots/machine locals этим ещё не устраняется.

Первый пробный `_01` с прямым инициализатором `@: char p @a` дал более ранний `unsupported body`: это отдельное ограничение candidate-span общего объявления. Не считать его закрытым исправлением ложного типа назначения; оно относится к общей переделке разрешения ресиверов.

Новый положительный контроль раздельного объявления/присваивания char*/char**, int* и size_t* прошёл; отрицательный int*-контроль выявил дополнительный общий дефект: machine-local assignment обходил `l2_colon_check_assignment` целиком. Присваивание направлено через общий checker, без разрешения несовместимых типов/глубины и без char-specific ветви; `l2_graph_nsty` получает существующее model metadata machine-local. Финальный focused gate с отрицательными контролями — 47/47. Возврат старого slot-типа снова отказывает корректному char*-присваиванию; удаление checker пропускает неправильное int* ← char*. Этот срез опубликован в `661735a`; последующие RHS-регрессии устранены в `6be1235`.

Независимый просмотр после подключения checker выявил две регрессии: `p: 0` для объявленного указателя и `buf: c.calloc(...)` для `@: void buf`. Результат сырого C-вызова ошибочно классифицировался тем же кодом, что целый литерал. Исправленная непрозрачная категория не добавляет список C-имён: машинную совместимость проверяет C, а структурный admission сохраняется. Положительный и отрицательный `c.memmove` проверяют именно runtime implements; `entry_index`/`entry_strcmp` снова зелёные. Нулевой литерал распознаётся существующим декодером (проверены `0`, `0U`, `(0)`, `-0`), обычная числовая переменная и ненулевой литерал отвергаются; полнота C99 constant expressions остаётся открытой. Старые незарегистрированные `unit_ptr_local_scope`/`unit_unsigned_ptr` не записаны как зелёные: у них независимые препятствия (valued return корня и отсутствующий int→size_t converter), сохранённые в `_04`. Null-контролям соответствуют новые исполняемые свидетели итогового gate.

### SEND-SITE-ARTIFICIAL-CAPS — 2026-09-30, Codex, FIXED 2026-10-06 (Opus)

Чтение текущего WIP `l2_msend_register` подтвердило предел 64 мест отправки и 16 полей письма: статические `l2_msend_at/owner/inputs[64]`, буферы `calloc(64)`/`calloc(1024)`, индексация `k * 16 + nf`, явные отказы `more than 64 sends in method bodies` и `a message of more than 16 fields`. Унификация root/method сама по себе этот предел не убрала. Это не предел языка и не исчерпание памяти. Требуется динамическое compiler-only описание каждого разрешённого source-site с фактическим числом полей; native и graph emission используют одну запись. Не добавлять очереди/реестры runtime, не поднимать константы. Свидетели должны пересекать обе прежние границы и сохранять данные/порядок отправки. Runtime-свидетели именно этого ограничения пока не запускались.

Тот же аудит обнаружил отсутствие reset/free этой метаинформации в `l2_translate_unit`/`l2_release`; исправление должно охватить её время жизни. Минимальная замена — одна запись source-statement + owner + ID с точным массивом описаний полей; связанные потребители: `l2_check_body`, `l2_rw_send`, `l2_emit_msend`, `l2_send_copies_text`, `l2_emit_send`, эмиссия прототипов/тел. Корневые 70 отправок и письмо с 20+ полями можно проверить существующим тестовым перехватом `l2_driver_service_post` перед обычной доставкой. Mail внутри обходимого не-root метода пока явно не поддержан; флаг WalkMethods не доказывает его исполнение, если метод остался нативным.

**Исправлено 2026-10-06 (Opus)** ([§93 журнала](fable-continuation-20261003.md#send-sites-any-count)): место
отправки — одна запись (statement, owner, входы, число полей, смещение, has_ref), поля всех мест — один
массив, поля места k — с его смещения. Пока хватает 64 мест и 1024 полей единицы, используются они, дальше —
память вдвое больше (`l2_msend_room`, `l2_msend_froom`); описание освобождается и сбрасывается с трансляцией
(`l2_release`). Проверка, нативная и графовая эмиссия и `l2_emit_send` читают одну запись; в runtime ничего не
добавлено. `l2_send_copies_text` никто не вызывает с 6ea06df8 (`<string.h>` — в каждой преамбуле): она удалена,
а не переписана. Свидетели — через перехват драйвера `l2_driver_service_post`: факт `postlog 1` пишет каждую
отправку до доставки строкой с полями письма по порядку, `Says` фиксирует строки. `unit_send_sites_many`
(+`_walk`): 70 мест в корне, 69 писем по 17 полей и exit (1176 полей), все 70 отправок по порядку, со всеми
полями, нативно и обходом; `unit_send_fields_many` (+`_walk`): письмо метода из 24 полей и корня из 20, тексты
среди чисел; `unit_send_site_kinds_refused`: проверка читает поля своего места. Прежний транслятор отвергает оба
позитива на 17-м поле; девять мутантов (три возвращают пределы, шесть читают чужое место) убиты.

### SEND-TARGET-PRELAYOUT-TYPE — 2026-09-30, Codex, OPEN

`after_return_full_20260930_01`, `unit_send_ref_root_fail`: после `receiveMessage: m` попытка `sendMessage: m` должна проверять обычное соответствие Message/Thread, но отказывает как для значения, не являющегося ссылкой. Это не безопасная замена текста ожидаемой ошибки. Read-only трасса: `l2_msend_register` вызывает `l2_rw_fields_ty` ещё в `l2_check_body`; `l2_rw_own_ty` требует уже назначенный `l2_own_uchild`, тогда как `l2_layout_owns` вызывается позднее в `l2_emit_unit`. Семантический тип не должен зависеть от позднего размещения поля. Исправлять общий источник разрешённого типа, не переставлять весь layout ради send и не распознавать имя `m`. Проверить положительную ссылку Thread, отрицательные Message и примитив, в корне и методе; отказ Message должен оставаться настоящим admission-отказом. Сходный `unit_send_ref_root_type_refused` передаёт реальный int и сам по себе этой ошибки классификации не доказывает.

### CHAR-DECLARED-CELL-IDENTITY — 2026-09-30, Codex, FIXED `661735a`

Начальный аудит выявил противоречие действующему L2 §18.2: `l2_emit_cell_new_ty` для обычного own `char` сохранял `lmx_char_cell_known(process_chars, 0)` вместо отдельной типизированной ячейки; `lmx_char_rebind_known` затем менял ссылку поля на другой байт общей таблицы. `l2_own_addr` выдавал сам этот байт как writable `char*`. Таблица — обычный profile-0 диапазон `LMX_TYPE_CHAR`; комментарий об immutable-байтах не делает изменяемое объявленное поле read-only. Поэтому два равных изменяемых поля имели один адрес: запись через `@a` затрагивала и `b`. Последующий runtime-свидетель на старых байтах подтвердил дефект.

Свидетель: два объявленных `char` со значением 65, публикация через обычный вызов, `p: @a`, запись 66 через `p`; явные графовые чтения должны дать `a=66`, `b=65`, чистые рабочие копии остаются 65. Адрес `a` не должен меняться от обычного присваивания ему нового char. Проверить native и walker по действующим правилам, не запрещать законный mutable-адрес и не менять `@` на внутренний слот ссылки.

Исправление охватывает и `lmx_copy_value`: прежняя ветвь `LMX_TYPE_CHAR` возвращала источник при `dst_chars=0`, иначе интернировала по значению в общей таблице назначения, обходя карту адресов. Теперь действуют общие правила копирования примитивных ячеек: разные исходные ячейки остаются разными, несколько ссылок на одну ячейку используют одну копию. Интернирование литералов не даёт права склеивать изменяемые объявления. Это реализационная ошибка, не вопрос о новой семантике; другие политики копирования указательных значений данным пунктом не меняются.

Граница среза: `lmx_value_owned`, все изменяемые char-создания/записи транслятора, `lmx_walk` (публикация, destination результата, локальная запись аргумента, capture), обычная карта копирования `lmx_graph_copy_owned`. Первый char-конструктор сохраняет существующий порядок таблицы литералов перед изменяемыми ячейками. Проверки разделены честно: generated native доказывает `@`/стабильный адрес; runtime walker/copy — собственные операции и alias topology. Общего walker-разыменования указателя на примитив пока нет, поэтому данный срез не обещает generated native/walker parity для такого `@`.

Начальный runtime-свидетель подтверждён на старых байтах в `char_declared_old_20260930_03`: оба теста скомпилированы и исполнены, результат 81 вместо 7. Один обнаруживает одинаковый адрес двух равных объявленных char, другой — устаревший сохранённый адрес после присваивания и checkpoint. Проверки записи через указатель читают граф явно, не требуют обновления чистого рабочего значения. Прямое `p: @a` ещё имеет отдельный дефект типизации выше.

Исправленный срез: kernel `char_identity_20260930_final2` — 280/280, 104 selftests; L3 с тем же именем — 11/11, 295 проверок и четыре инвентаря; generated `char_identity_20260930_final3` — 19/19. Шесть детерминированных мутантов отказаны; включая возврат стекового адреса held-char helper, обнаруженный по принадлежности диапазону арены до выхода из helper, без обращения к уже умершей памяти. Свежие ячейки/запись на месте применены к объявлениям, capture, публикации, результатам и обычному копированию; alias topology сохраняет общая карта. Первый L3-прогон выявил недостающую реализацию `lmx_chars_init`; исправлена зависимость самого `lmx_value_owned` на существующий `lmx_chars.lm1`, и все итоговые гейты выполнены после этого. Полный generated gate не запускался заново. Точные хэши и границы — [в рабочей записке](native-selfbuild-20260930.md#char-declared-cell-identity-verified-wip); срез опубликован в `661735a`, без продвижения в stable.

### RETURN-ABI-EMPTY-HANDLER — 2026-09-30, Codex, FIXED `661735a`

Положительный контроль к `unit_s1_throws_entry_unhandled_refused` выявил два независимых дефекта генератора. При `m()` с `throws: Oops` обработчик `catch: Oops ()` с телом `0` порождает пустой условный блок L1: `l2_emit_handler` печатает условие, а pure-discard затем не печатает ни одного оператора. С телом `return` тот же пример порождает C `return;` в функции, которая по своему ABI возвращает статус `int`: атомарная ветка `l2_emit_stmts` проверяет лишь отсутствие языкового результата, не нативный протокол возврата. Frame/trailer-пути уже различают эти случаи. Evidence — `build/l2_harness/native_diagnostics_20260930_mutants` и `_mutants_02`; это не отказ языка и не вопрос автору. Тикет исправляет общую эмиссию пустого тела/возврата без особого правила для E; приёмка включает обычный и throws-status callable, runtime-наблюдения и C constraint check с `-Werror=return-type`.

Проверка `return_abi_empty_20260930_final2`: 27/27, три новых свидетеля с `-Werror=return-type`; 142 staged inputs и 24 фикстуры совпадают с исходниками. Общий `l2_emit_empty_return` выбирает ABI возврата; `l2_emit_empty_body` сохраняет пустое тело только для нового выходного блока, где оно требуется, а не после уже выданной нативной преамбулы. Старые генераторы дают конкретные ошибки компиляции; удаление раннего возврата либо throw меняет результат на 81 вместо 7 в обоих режимах. Транслятор SHA256 `7A4A380C00FB2F55750329C1CC32BDE6E85818696ACE26AD9C635860712A14D1`, blob `9d5fc38fed49153379a3718493cf0d2a5f6cc79e`. Это историческая идентичность проверенного среза, затем включённого в `661735a`, а не результат полного gate.

### EMPTY-SUB-TRAILER-ATTACHMENT — 2026-09-30, Codex, OPEN

При разработке свидетеля возвратов `return: ()` на уровне открытия `sub` остался отдельным оператором верхнего тела вместо trailer процедуры. Сохранённый замер: `return_abi_empty_20260930_02/src/unit_void_return_abi.lm2:18,48` и `gen/unit_void_return_abi.lm1:666,669`; лишние верхние возвраты завершали программу до проверок. Срез RETURN-ABI не меняет парсер: его финальные тесты проверяют голые trailer и нормализованные пустые возвраты внутри тела. Присоединение пустого trailer требует отдельного P0-свидетеля по общим правилам пустого тела/возврата; нельзя считать его закрытым по ABI-гейту или вводить особую семантику sub.

### ROOT-HOSTED-GRAPH — 2026-09-30, Codex, FIXED `661735a`

В `unit_root_for_refused.lm2` нативный цикл вычисляет сумму 6, но сохранённый граф не содержит FOR. В `l2_rw_stmt` объявление вложенного счётчика отказывается только для `l2_e`; неуспех count-pass затем убирает все операторы корня. Общий hosted-field путь уже существует для остальных методов. Исправление: единый вход/выход области и разрешение hosted-полей, без второго root-only стека `l2_rw_cblk[64]`. Свидетели — native и обход того же графа с очищенным тестовым драйвером `native`, вложенные циклы/ветвления, фактические FOR/OWN_OF/SET_OF. Дублирование body и неверный лексический порядок графа — следующие отдельные части того же барьера. [Границы](native-selfbuild-20260930.md#one-complete-lexical-graph).

Правка проверена в `root_hosted_graph_20260930_final`: 30/30, четыре свидетеля native+walker одного бинарника; четыре инверсии ожидаемых значений отказаны в обоих режимах. Включён 70-уровневый `if`. Точный исходник транслятора — blob `1e2a3d4dbad948777a58cd4b3b5d0820a4a364ae`. Срез включён в `661735a`; это не закрытие полного графового барьера.

### C99-COMMON-ARITHMETIC — 2026-09-30, Codex, OPEN

После char-promotions walker всё ещё отказывает разным числовым типам (`a != b`), а беззнаковые операции выполняет в size_t scratch. `l2_rw_unify` тоже отказывает разным известным типам. Это расходится с уже принятой Q55, не требует новой семантики. Нужен общий алгоритм C99 promotions/usual arithmetic conversions; типизированные операции после него. Отдельный `LMX_TYPE_SIZE_T` описывает хранение, не несовместимый C-тип: target typedef/base совместимость устанавливает целевой компилятор, не ширина и не таблица Lmx-конвертеров. [Маршрут и свидетели](native-selfbuild-20260930.md#c99-expression-types-versus-arena-storage-domains).

### ARRAY-COMPOSITION-DEPTH — 2026-09-30, Codex, OPEN

Норма Q56: вложенные принимающие выражения обрабатываются общим механизмом без фиксированной глубины; `[]: []:` — не отдельная форма Array. Измеренный отказ `[]: A: b` после `A: ()`: парсер принимает, `l2_collect_decls` отказывает `unsupported own array declaration`. `l2_ns_arrarr_field` отдельно распознаёт ровно int/char → [] → []; own-поля, named-поля и формалы имеют разные распознаватели. Их требуется заменить общим разрешением приложения и сохранением его типа/binding для всех потребителей, не расширять отдельный Array-сканер. Обязательный свидетель автора: `[]: []: b a[i]`, затем `[]: c: b[j]`. Принятый прямой доступ `a[i]\[j]\[k]` использует общий путь: после каждого `\` адресуется выбранное значение; это также требуется реализовать. Си-подобная ровная `[][][]` сохраняется отдельно. [Путь замены](receiver-resolution-20260930.md); кодовый дефект OPEN.

| # | Найден | Дефект (анкер, минимальная программа) | Владелец | Статус |
| --- | --- | --- | --- | --- |
| D-01 | 2026-09-24, Opus -138 | Голый атом-оператор (`m`, `s`, `2`, `y`, `m` в методе, `S`) роняет транслятор: `l2_check_body` :13591 пропускает `stmt\as\frame = 0`, :13592 читает `frame\head` | Opus | Opus | FIXED (F-24 `f33a1a9`) |
| D-02 | 2026-09-24, Opus -138 | Имя метода в позиции значения передаёт ссылку на вхождение как int: `fn: m () int`/`return: 7`; `fn: g (int: x) int`/`return: x`; `return: g(m)` → −1287876288 (норма 7); `sub` в значение — указатель как int; trailer `return: m` колонки 0 — ссылка как int; `return: s` (sub) в теле `fn` ломает эмиссию (`l2_emit_nullary_call` :14404 void-ветка теряет `ind`, l1trans «level decrease must be one step») | Opus | Opus | FIXED (F-25 `cbc97c7`) |
| D-03 | 2026-09-24, Opus -138 | L3 `l3_exec_stmt` :241/:245 — голый CALLABLE-оператор, plain Structure-оператор и примитив дают молча `L3_OK`; walker `lmx_walk_body` :809–:821 пропускает голую callable-ссылку в теле молча — норма N7 требует исполнения или явного UNSUPPORTED | Grok | FIXED -140 |
| D-04 | 2026-09-23, Opus -133 | Walker не проверяет число аргументов на входе: лишний Structure-аргумент нульарному callee интерпретатор не отвергает (native отвергает) | Grok | FIXED -140 (prepare/call: n != arity → INVALID) |
| D-05 | 2026-09-23, Opus -133/-135 | Null-path bails (`l2_emit_path_bail`, `l2_emit_path_load`) и пролог `if: self = 0` возвращают статус 0 со значением 0 («тихий успех») — должны идти маршрутом X1 (инвариант) или located-отказом | Opus | Opus | FIXED (F-30) |
| D-06 | 2026-09-23, Opus -133 | Диагностики checkpoint/nextMessage/rebinding печатают и продолжают (`lmx_msg_poll_abort` во время хода доставляет в никуда) — привести к X1 (`l2_emit_invariant`) | Opus | Opus | FIXED (F-30) |
| D-07 | 2026-09-23, Opus -133 | Ловушка драйвера покрывает `lmx_merge_owned`, но не `lmx_merge_profiles_owned` (qualified-операнды) — отказ merge профилей не свидетельствуется | Opus/Grok | FIXED -152 (profiles tap + `unit_s1_merge_profiles_uncaught.lm2`; shared `mergefail N`) |
| D-08 | 2026-09-23, Opus -135 | `l2_uses_is_control` — мёртвый код (нет вызовов) | Opus | Opus | CLOSED (stale, -195 измерено: 0 ссылок) — удалён `0ded44c` (Opus -139, «D-08: drop the dead l2_uses_is_control»); строка не была обновлена |
| D-09 | 2026-09-23, Opus -135/-136 | Callable на throw-канале через `lmx_call0` (callable-формал) вызывается с plain ABI; библиотечные обёртки вызывают throw-канальные методы с plain ABI (library-метод с `throws:`/merge не компилируется) | Opus | CLOSED (stale miscompile, remeasured 2026-09-26, `steps/d09-throw-abi.md`). Формал — F-38: `lmx_call_prim`, не plain ABI; свидетель `unit_dyn_call_throw_caught` Entry 10. Библиотека с `throws:` или `merge` — located «unsupported library ABI», обёртка не эмитируется; метод без throw-канала переводится. Публичный C-вызов throw-канала не заводился. |
| D-10 | 2026-09-23, Sonnet -131 | Двойная попытка `l2_own_find_last`/`l2_own_find` в `l2_check_sizeof` и `l2_prep` избыточна после -129 (второй поиск не находит ничего, чего не нашёл первый) | Sonnet | FIXED (F-17) |
| D-11 | 2026-09-24, Opus -138 | Устаревшая tracked-копия `tmp_unitroot_test/` (169 файлов: старый `parser.lm1` 431fa51e, `LmxArrayDesc` в 17 файлах) — не собирается, не гейтится, расходится с деревом | Grok | FIXED -140 (git rm -r tmp_unitroot_test; no tools/provenance/docs consumers) |
| D-12 | 2026-09-23, Opus S3 | `dev/l2src_sandbox/printTree.lm2` — документный пример на старом `fn: main (int: argc; @@: char argv)`; ничем не собирается; L2-спека §18.2 ссылается. **2026-09-26, -198:** корневой `l2src/` теперь копия песочницы (автор, Q8), так что второй экземпляр — та же копия; дефект сужен до примера в песочнице, переписать его на корень-вход / `mainArgs` — отдельный тикет (fable) | Codex | fable (Codex закрыт) | FIXED (F-71): корень принимает `mainArgs`; `@document` передаёт метод `run`. l2trans/l1trans/gcc зелёные. Прогон: usage exit 0; разбор `entry_argc_if.lm2` exit 0; нет файла — entry 1. |
| D-13 | 2026-09-23, Opus S3 | `address_array_element_sum.lm2` — тот же устаревший own-array случай `@ buf[i]`, что удалённая `address_array_element.lm2` | Sonnet | FIXED (F-22) |
| D-14 | 2026-09-23, Opus -136 | Книга §14: пример t2 ставит `checkedGreeting(...)` внутрь обработчика, в оригинале `t2.lmx` вызов на уровне catch после обработчика | Codex | fable (Codex закрыт; правка книги своими руками) | FIXED (F-32) |
| D-15 | 2026-09-24, Opus -138 | Именованная Structure не принимает поле `int:` (`l2_ns_field_kind` :10913: только size_t/char/вложенная/`Name: field`/fn/массивы) — `int: greeting 0` читается как Structure-ссылка и отвергается | Sonnet | Sonnet/Opus | Opus | FIXED (F-29) |
| D-16 | 2026-09-24, Opus -138 | Мёртвый реестр P0 `lm_p0_registry_*` (6 заглушек, всегда 0; вызовы :653/:658/:4652) и переменные `LM_*_REGISTRY`, которые все раннеры очищают, но никто не читает | Opus | Opus -151 к.1 | FIXED (F-33) |
| D-18 | 2026-09-24, автор | Дублёр типа: `LmxByteArray`/`LmxByteDynamicArray` (-134) для `{size_t len; char *data}` — по норме это `LmxCharArray` (тип строкового литерала с точной `len`, без NUL), один тип на элемент char | Grok | FIXED (F-18) |
| D-19 | 2026-09-24, Sonnet -141 | Отрицательный литерал в вечном поле именованной Structure (`int: x -1`): `l2_literal_value` не кодирует отрицательные значения, `l2_signed_num` проверяет лишь ведущий `-` — сегодня токен-проверка `l2_num` отвергает `-1` located-отказом (не молча); поддержка отрицательных литералов полей отсутствует | Sonnet | FIXED (F-74). Знак — часть литерала int (`l2_int_literal_bits`); именованная Structure хранит биты в `l2_nsf_val` и пишет их прежним `%d`. `unit_ns_int_neg`: `Model\x` = -1, Entry 7. INT_MIN — `unit_lit_range_ns_int_neg_min`; на единицу дальше — «literal not representable as int». |
| D-20 | 2026-09-24, Grok -140 | Транслятор понижает/запечатывает строки как NUL-терминированные `char *`, тогда как по норме (автор, 2026-09-24) строковый литерал — `LmxCharArray {size_t len; char *data}` с точной `len` без NUL: письмо argv (`l2trans.lm1` ~:18858 — `strlen(argv[i])+1` с NUL в `LMX_TYPE_ARRAY_OF_CHAR`), `l2_tok_text` (~:13783–:13801, `dest[len]=0`), unquote-помощники путей (~:4013, :4134, :4381, :4502, :4582), C-буферы имён/payload (~:7261–:7274, :9177, :14134–:14156), `l2_fmt_l1_string` (~:2572), strlen-арифметика (~:13815, :14288) | Grok | FIXED (F-76). Срез — значения письма, не буферы транслятора. Элемент `mainArgs` — char Array с `len = strlen(argv[i])`, без NUL (`lmx_root.lm1`). `lmx_argv_letter_selftest`: argv `ok` — len 2, `data[1]` = `k`; мутант `+ 1` краснит только сценарий C (`checks=23 failures=1`). `entry_arg_len` Entry 7. Литерал текста в письме уже копирует `t\length - 2` без лишнего NUL (`l2trans.lm1` :19867). Остаток буферов и двери `c.*` — D-81. |
| D-21 | 2026-09-24, Sonnet -141 | **Молчаливая потеря данных:** `@` от элемента ГОЛОГО own-массива (без пути через поле Structure; `[]: int buf 3` в методе): `p: @ buf[1]` / `\p: 9` / `return: buf[1]` — эмитируется `l2_t1: l2_a0_data[1U]` и `p: @ l2_t1` (адрес мёртвого временного через `l2_emit_array_load`), запись через `p` теряется, чтение заново копирует исходное; путь через поле (`@ a\buf[1]`, `l2_emit_array_ptr`) адресует backing правильно | Sonnet | FIXED (F-23) |
| D-22 | 2026-09-24, Sonnet -141 | `@ x + y + z` (адрес в составном выражении) молча даёт указатель как int на обоих маршрутах — ловит только gcc `-Wint-conversion`, не l2trans; нужен located-отказ или типизированная адресная арифметика по норме | Sonnet | FIXED узко (F-26): located-отказ `@ buf[i] + …`; полная адресная арифметика по спеке §18.2 (типизированное выражение, приём в pointer-цель) — отдельная задача, см. D-24 |
| D-23 | 2026-09-23, Grok -143 | Named call-arg field with empty Structure f(x: ()) (book SS12 / plan SS2 :111 opaque position for empty Structure as one value) refuses as "unknown method" (frame=x) instead of admitting one named argument; min program: fn: f (int: n) int / return: n / return: f(x: ()); fixture unit_matrix_empty_named_value.lm2 (measured refuse). Contrast: empty arg list f() -- unit_matrix_empty_arglist.lm2 | Grok | FIXED (F-77, `8c897ac`). `E: ()` / `end: E` — тип без полей. `take(E: x)` / `take(x: ())` допускает пустую Structure (FRESH + `lmx_walk_admit`) и даёт Entry 7. Мутант `l2_named_empty_actual` → 0: «unknown method», frame=x. |
| D-24 | 2026-09-24, Sonnet -144 | Адресная арифметика по L2-спеке §18.2 («@array[i] … loads, stores and address arithmetic follow the C machine contract») не реализована: у составных выражений нет вывода типа (`l2_check_fields` без `out_ty`; `l2_colon_simple_ty` — только простые формы), поэтому `q: @ buf[0] + 1` в pointer-цель тоже отвергается (узкий отказ -144 вместо молчаливого pointer-as-int) | Grok | FIXED (F-78, `010b2fb`). `@ buf[0] + 1` в `@: int` пишет `buf[1]` (Entry 7, `unit_addr_own_array_arith`); `@ buf[2] - 1` пишет туда же 8. Возврат `@ buf[0] + buf[1] + buf[2]` как int — «assignment value has incompatible type». Мутант без проверки совместимости переводит эту строку (`return: @ l2_a3_data[0U] + …`). Не этот срез: уже взятый указатель `p + 1`, массив указателей, аргумент вызова. |
| D-25 | 2026-09-24, Sonnet -142 | Осиротевшие незарегистрированные фикстуры (форма D-13): `unit_node_array_paths.lm2` (нужна возможность `node\buf[k]` — `l2_own_array_root_span` явно отказывает), 10× `unit_forj_*.lm2` (до -121), `unit_addr_arg.lm2`, `unit_addr_depth.lm2`, `unit_addr_take.lm2`, `unit_own_dirty_rhs.lm2` — не собираются, не гейтятся | Sonnet | FIXED (учёт 2026-09-26, `steps/d25-fixtures.md`; посадка `298ef1e`). Семь удалены с причиной: `unit_forj_{again,bare,graph,nest,order,path}` (`for` вне своего тела — `unresolved name`) и `unit_node_array_paths` (`node\buf[k]` не построен). Семь в harness и на диске обоих деревьев: `unit_forj_{parent,sib,stale}`, `unit_addr_{arg,depth,take}`, `unit_own_dirty_rhs`. Повтор: 411 строк, имён без файла нет; удалённые отсутствуют. Прочие `.lm2` вне harness — не этот список. |
| D-26 | 2026-09-23, Grok -148 | Bare METHOD still constructed in Structure child[0] by producers outside descriptor-only emission: `dev/l2src_sandbox/tests/lmx_call_selftest.lm1` (stores METHOD, expects `lmx_call_ready` OK + `lmx_call0` legacy ABI); many `tests/lmx_app_*` / close/mail/manager selftests (`lmx_arena_ref_store(graph, 0U, method)`); `dev/mixa_sandbox/mixa_manager/mixa_app_main_msg.lm1` (ui/file/audio/proc graphs); `dev/l3_interp/tests/l3_01/02_selftest.lm1`; frozen `l2src/l2trans.lm1` still emits bare `rec` into leaf child[0]. Sandbox `dev/l2src_sandbox/l2trans.lm1` emission is already descriptor-only (`lmx_callable_new_owned` -> slot 0). `lmx_walk.lm1:510/:728` are not producers. GATE -148 Commit1 STOPPED: cannot remove transitional METHOD fallback in `lmx_call.lm1` / `lmx_call.h.lm1` while these producers remain; no partial fallback kept. | Opus/Sonnet (translator+selftest migration) | FIXED (-150 producers + descriptor-only `lmx_call`; frozen `l2src/l2trans.lm1` still emits bare METHOD until promotion) |
| D-27 | 2026-09-24, Sonnet -146 | Безкорневая форма `\[N]x` для НЕ-параметрного own-локала, объявленного и дважды присвоенного (`int: x` / `x: 10` / `x: 20` / `\[0]x`) — «translation failed with no located diagnostic» (падение без located-отказа), измерено на нетронутой базе | Sonnet | FIXED (F-73). `\[0]x` после `x: 10` / `x: 20` читает единственную ячейку (20, Entry 7). Кадр, за которым идёт `\`, больше не склеивается с этой строкой. `\[1]x` — «no such occurrence». |
| D-28 | 2026-09-24, Opus -147 | Формал, названный как unit-level именованная Structure (`fn: bump (@(Lmx Model))`, L1-запись `@(Type name)` в 5 фикстурах): внутри тела `Model` должен быть формалом (лексически ближайшая привязка), а `l2_path_root` с -113 пишет unit-level Structure (`lmx_arena_ref_struct(node, N)`), не читая `l2_p0_0`; фикстуры -113 не различают (пишут и читают то же место); минимальная программа Opus → 91 вместо 0 | Sonnet | Sonnet (D-28 + fixup) | FIXED (F-34) |
| D-29 | 2026-09-24, координатор (q20-next) | Скопированный merge метод читает поля лексического родителя по индексам, запечённым для исходного родителя, а его `node` после merge — результат с другой раскладкой: `A: fn: M; tag 7U` / unit `tag 3U` / `M`: `v: node\tag` / `R: merge: A` / `R\M()` → 7 вместо 3 (entry 81), `Q: merge: B A` → слот 1 = само вхождение (мусор). Own-поля метода (`self`) не страдают | ждёт решения автора (прочтение I: base в дескрипторе; II: `node` копии = исходный родитель) | Grok -153 (ядро: offset в дескрипторе) + Opus -154 (транслятор: адресация от offset) | Grok -153 (ядро: offset в дескрипторе — ПОСАЖЕН `5214386`) + Opus -154 к.1 (транслятор: адресация от offset — ДЕРЖИТСЯ на Q22) | Grok -161 к.0/к.2 (откат offset; ссылка на метод — терминал) + Q21 = А | FIXED (F-42): `offset` не нужен — раскладка модели не сдвигается; q22 → 3 |
| D-17 | 2026-09-23 | Канал `codex_inbound.py` → Codex (pipe `codex-browser-use`) лежит; ответы Codex стоят в очереди у lmx_uds | инфраструктура/автор | ОТМЕНЁН 2026-09-26: Codex нет. Канал и всё, что его ждало, закрыто до повторного открытия. |
| D-65 | 2026-09-24, Sonnet c.3 (FABLE-SONNET-NATIVE-WORD-20260926-191, `dev/l3_interp/tests/l3_mail_prim_selftest.lm1`, чек «a fourth distinct letter») | `letter4: lmx_arena_take(a, sizeof(LmxMsg), MSG_RECORD, MSG_RECORD)` иногда совпадает адресом с ранее взятым из инбокса и собранным `letter`/`letter2`/`letter3` (переиспользование освобождённого блока тем же размером тем же аллокатором) — падение чека «distinct»; частота 1/5 прогонов идентичного, уже починенного кода (замерено напрямую отладочной печатью адресов: 4 прогона — все 4 адреса разные, 1 прогон — `letter3`/`letter4` совпали побайтово); НЕ регрессия k.4 — миграция c.2/c.3 не трогала этот путь аллокации/освобождения, обнаружено случайно при первом успешном прогоне файла после многомесячного простоя (L3 не транслировался вовсе). **2026-09-26, Sonnet -194 к.3b (измерено):** `lmx_turn.lm1:173` зовёт `lmx_gc_collect` безусловно на каждой границе хода («whatever this Message's own roots can no longer reach is garbage NOW»); `letter`/`letter2`/`letter3` после взятия и показа держатся только локалами теста и неотслеживаемым C-глобалом `sink_letter`'s `sunk_last` — ни то ни другое GC-корень; между третьим take и аллокацией `letter4` проходит несколько `run_graph`-ходов, каждый со своей GC-границей — три старых письма гарантированно собраны мусором раньше, чем берётся `letter4`. Переиспользование их освобождённых блоков тем же (kind,type) для `letter4` — корректная работа GC'd-арены, не висячая ссылка и не double-free; чек сравнивал свежую аллокацию с тремя давно мёртвыми и ожидал неравенства, которое ядро никогда не обещало | Sonnet (диагноз + фикс, -194 к.3b) | FIXED (F-59) |

## Исправлены сегодня (для истории)

| # | Дефект | SHA |
| --- | --- | --- |
| F-01 | D1: formal-корень пути читал объявление, не аргумент | `7421feb` (-121) |
| F-02 | D2: inline merge `Model: fresh` писал только ячейку графа, dirty-load локал оставался 0 | `520b8fe` (-121 fixup) |
| F-03 | Запись в поле единицы из вложенного метода падала молча (`l2_own_find_last` без unit-fallback; тупиковый `return: 1`) | `765e70c` (-129) |
| F-04 | `l2_hidden_from` через `l2_own_first` читал одноимённое поле чужого метода | `3616700` (-131) |
| F-05 | Пять ручных копий формулы own-ячейки (одна без cache-guard) | `3616700` (-131) |
| F-06 | Скан корня пути в `l2_path_root` без unit-fallback («unknown field path root» для unit-Structure из другого метода) | `7b64331` (-131 ч.3) |
| F-07 | Повторная проверка формы пустой Structure на emit не узнавала своё объявление; `if` без тела; необъявленный `l2_tN`; вторая молчаливая строка при P0-отказе | `7cc4310` (-132) |
| F-08 | Trailer `return: X` у throw-ABI метода эмитировался как СТАТУС | `1abafa4` (-133) |
| F-09 | `return: f` в теле для callable на throw-канале — `l2_emit_nullary_call` с (node, self), gcc отказывал | `9f299a5` (-135) |
| F-10 | Анонимный блок `---` — segfault `l2_check_body` (Frame вместо Structure) | `b2667dd` (-136) |
| F-11 | Пробел порядка проверки: nsty заполнялся при проверке E, E — последняя (`u_struct\value` в составном выражении из раннего метода) | `4f50a90` (-137 ч.1) |
| F-12 | Возврат именованной Structure из метода падал молча (три места читали `l2_m_ret` сырым: `l2_emit_sig`, `l2_colon_simple_ty`, `l2_prep`) | `b7f0548` (-137 ч.2) |
| F-13 | Результат predef C-функции не присваивался («unknown type») | `790258b` (-137 ч.3) |
| F-14 | Mix-узел `{...}` разворачивался нормализацией единственного контейнера | `e446835` (-127 PART1b) |
| F-15 | Таблица имён типов заголовков l1trans 64/4096 на пределе → 128/8192, перепин | `9bacfd0` (-134) |
| F-16 | D-15: именованная Structure не принимала поля `int:`/`unsigned:`/`ulong:` (цепочка `l2_take_ns_body` без этих звеньев → «a Structure reference field needs a name») | -141 D-15 (Sonnet `3b669cb`, на main следующим SHA) |
| F-18 | D-18: дублёр `LmxByteArray`/`LmxByteDynamicArray` → `LmxCharArray`/`LmxCharDynamicArray`, один тип на char; гейт `tools/gate_dynarray_capacity.ps1` запрещает старые имена | -140 (Grok `6bb6b4c`) |
| F-19 | D-03: голый CALLABLE-оператор в L3/walker исполняется, plain Structure/примитив — явный UNSUPPORTED (не молча OK) | -140 (Grok `78c92f1`) |
| F-20 | D-04: walker отвергает неверную арность вызова (`LMX_WALK_INVALID`), как native | -140 (Grok `012e327`) |
| F-21 | D-11: устаревшая tracked-копия `tmp_unitroot_test/` (169 файлов) удалена | -140 (Grok `99de444`) |
| F-22 | D-13: устаревшая незарегистрированная фикстура `address_array_element_sum.lm2` удалена (история — implementation-notes, `steps/lowlevel-operations.md`) | -141 (Sonnet `a7f4774`) |
| F-23 | D-21: `@` от элемента голого own-массива адресует настоящий backing (`l2_emit_fields`: `@` + own-index → `l2_emit_array_ptr`, лvalue-текст `PTR[INDEX]`), запись через указатель видна при чтении | -144 (Sonnet `d116df7`) |
| F-24 | D-01: голый атом-оператор через один резолвер (`l2_check_bare`): callable — нульарный вызов путём `m()`, значение — discard, Structure — located-отказ до коммита 4, неизвестное имя — «unresolved name»; segfault устранён | -139 к.1 (Opus `f33a1a9`) |
| F-25 | D-02: контракт получателя — результатный callable в позиции значения исполняется (`g(m)` → 7), `sub` в значение/`return: s` — located-отказ, trailer `return: m` — путь тела (`l2_emit_nullary_call` удалён), `f()` при существующей Structure — присваивание пустой Structure через admission | -139 к.2 (Opus `cbc97c7`) |
| F-26 | D-22: `@` + own-index с чем-либо после элемента — located-отказ вместо pointer-as-int (`unit_addr_own_array_arithmetic_refused.lm2`, бывшая форма D-13) | -144 (Sonnet `f0a448a`) |
| F-27 | 11 подтверждённо мёртвых функций ядра удалены (lmx_dec_sub, lmx_copy_retained, lmx_graph_copy_many_profiled_owned, lmx_int_take/value/store, lmx_interp_method, lmx_list_etype, lmx_post_inbox_len, lmx_settle_cascade_one_level, lmx_thread_set_current); 36 из списка -145 исключены как живые | -148 (Grok `37fc590`) |
| F-28 | D-26: producers emit LmxCallable in child[0]; `lmx_call` descriptor-only; bare METHOD mutant NOT_CALLABLE; frozen l2trans remains until promotion | -150 (Grok) |
| F-29 | D-15 (переоткрытый): builder создаёт ячейки для полей kinds 7/8/9 (`l2_emit_ns_num_cell` для 0/7/8/9, eternal-ветка `lmx_arena_take_profiled` + seal UNSIGNED/ULONG); свидетели `unit_struct_int_field` (ужесточён, entry 7), `unit_struct_num_fields`, `unit_eternal_num_fields`; пробы `return: 5`/инвертированные проверки — падают | -147 ч.2 (Opus `95e2ff1`→main) |
| F-30 | D-05/D-06: null-path bails, пролог `if: self = 0`, поиск control-тел, диагностики checkpoint/nextMessage/rebinding — маршрут X1 (`lmx: invariant: …` + abort) вместо тихого `return: 0` / print-and-continue; пробел: нет фикстуры с `os:`-блоком (пролог `l2_emit_os_fn` не покрыт) | -147 ч.3 (Opus `506c1f5`→main) |
| F-31 | D-07: ловушка драйвера на lmx_merge_profiles_owned (общий счётчик mergefail N); свидетель unit_s1_merge_profiles_uncaught.lm2; мутант без -Dlmx_merge_profiles_owned — RED | -152 (Grok) |
| F-32 | D-14: книга §14 — вставка `{{older:10132-10181}}` (отрисовка старой спеки с вызовом `checkedGreeting(...)` внутри обработчика) заменена кодом по оригиналу `lingvamyxa_prev/tests/t2.lmx` (вызов на уровне `catch`, после обработчика) + пояснение RU/EN; заодно по правилам автора 2026-09-24: неуточнённое имя = последнее вхождение (`[lastIndex]`, книга §fields/§10/§composition, CORE §3.1), merge-абзац (простыня, методы копируются, `offset` в дескрипторе копии, возвращаемый вложенный метод через merge; L2-спека §13/§11), правило уровней (Structure — L3, L2 — только в телах методов, L3 ⊂ L2, `@` любой глубины в L3 — только receiver объявления; книга §scope + таблица `@`, L2-спека §1, CORE §1), именованная Structure — только голый `return`, путь `Counter\n` не исполняет | fable (этот коммит) | `python tools/build_semantics.py` + `check_docs` OK; рендер `docs/LMX_semantics.*` :532–:536 — вызов на уровне `catch` |
| F-33 | D-16: мёртвый P0-реестр удалён (`lm_p0_*registry*` в трёх копиях парсера + `parser_trailer_role.lm2`/`trailer_role_abi.lm1` + 6 инструментов), пин L1 → `F70407F5…` | -151 к.1 (Opus 6a8cc35 → main 2bbe8a0) | self-build 8/8 (fixed point), parser 42 / 131 (8 diverged as recorded), harness 320/320, build_l2src 251, L3 11/11, check_docs, diff --check — на интегрированном дереве |
| F-34 | D-28: формал ищется в `l2_path_root` ПЕРВЫМ (лексически ближайшая привязка затеняет unit-level Structure с тем же именем); тип формала — только из объявления (`l2_nsty_get`), вывод типа из ИМЕНИ формала (первая версия) отвергнут координатором и удалён в fixup; свидетель `unit_formal_shadows_struct` (`Model: Model`, успех 7, 91/92 отказы); 2 старые фикстуры (`unit_field_path_formal`, `unit_struct_int_field`) ходили путём через `@(Lmx Model)` и опирались на баг — переписаны на типизированный формал; мутант (блок формалов выключен) — 13/328 регресс | Sonnet `d762a6f` + `c6cd6cc` | harness 328, build 252, L3 11/11, check_docs, diff --check — интегрированное дерево |
| F-35 | D-31/D-32: блок COW-клона + перезаписи parent поднят в один помощник `lmx_merge_owned.lm1`; `lmx_callable_offset` классифицирует child 0 (sentinel для не-CALLABLE) + строка selftest | Grok -156 к.0 (`ee7085e`) | build 252, harness 329, L3 11/11 — интегрированное дерево |
| F-36 | D-35/D-34: `l2_predef_result_ty` (рядом с `l2_predef_has_function`, тот же обход predef-файлов) + `l2_proto_ret_ty` — результат predef-функции несёт тип из `prototype:`; −10 только для `c.*`-двери без прототипа; попутно: `l1src/own.h.lm1` получил `include: "l1src/p0.lm1.h"`, harness генерирует заголовки и из `l1src/*.h.lm1`; мутант (accessor всегда «не найдено») → `unit_lm_own_actual_span` RED; D-34: `c.LmP0*` в двух фикстурах | Sonnet -160 (`3a18970`, `dc4714e`, `77d3e5c`) | harness 331, build 252, L3 11/11 — интегрированное дерево |
| F-37 | D-41/D-42: `l2_ptr_type_word` (pointer-local word+depth→code, 3 сайта: `l2_ptr_local_ty`/`l2_own_array_pointer_ty`/`l2_typed_formal`'s `@:`/`@@:`) + `l2_ret_type_word`/`l2_ret_type_node` (return-code, 2 сайта: `l2_collect_method`/`l2_proto_ret_ty`→переименован); `l2_prim_type_word` — тонкая обёртка; попутно D-42 (LmxMsgBlock пропущенный `return: 0`); witness — 553 `.lm2`-фикстуры, byte-identical L1/диагностики до/после (0 расхождений); мутант (один сайт с чужим ответом) → 4 файла расходятся, включая полный провал перевода трёх | Sonnet -162 к.2 | harness 331, build 252, L3 11/11, 553/553 byte-identical — интегрированное дерево ожидается |
| F-17 | D-10: избыточная вторая попытка own-поиска в `l2_check_sizeof`/`l2_prep` (обе функции различаются лишь выбором first/last при нескольких совпадениях; unit-fallback идентичен) — удалена; 514 сгенерированных .c байт-идентичны | -141 D-10 (Sonnet `14cb573`) |
| F-38 | D-38: `lmx_call_prim(arena, callable, refs, nargs, dest, out) → status` — `addr != 0` → трамплин, `addr = 0` → walk-хук; нативная ветка `lmx_call0` через локальный dest, `LmxCallEntrySelf` удалён (бюджет L3 71 → 70); 6 динамических мест транслятора (`l2_emit_dyn_call`) на prim-ABI — остаток S1.2 закрыт (`unit_dyn_call_throw_caught`, 10); трамплин `<sym>_tr` на каждый метод с телом (1112 на 586 входах), nargs/out/dest вне сигнатуры — X1, статус = собственная S1.1-нумерация; 24 natives в 18 selftest’ах ядра на prim-ABI; мутанты (результат отброшен 32758; динамика не пробрасывает 32762; статус отброшен 3) RED | Opus -159 к.1 (`9a66ce6`) | harness 332, build 252, L3 11/11 — интегрированное дерево |
| F-39 | D-41 (частично) + D-42: `l2_ptr_type_word` (3 места → 1), `l2_ret_type_word`/`l2_ret_type_node` (2 → 1), `l2_prim_type_word` — обёртка; `LmxMsgBlock` fall-through в `l2_typed_formal` починен; свидетель — 553 входа байт-в-байт (374 .lm1, 179 отказов), мутант (char/depth 1 → 99) — 4 расхождения | Sonnet -162 (`a54d0fe`, `9387371`) | harness 332, build 252, L3 11/11 — интегрированное дерево |
| F-40 | D-40: одно правило «callable без результата — не значение» — одна диагностика везде. `return: d(0)` (`l2_check_body` ~:14003, «incompatible entry signature» → «a callable without a result has no value») и `x: d()` (`l2_colon_check_assignment` ~:5761, value_ty=8 проверяется ДО generic incompatible-type) — оба чинены; `g(d())` уже давал верное сообщение (замер на реалистичном `sub:`-теле, не на пустом). `unit_void_value.lm2` — гейтованный свидетель (l2trans-refuses); `unit_predef_result_void_refused.lm2`'s Needle обновлён (та же проверка теперь ловит его раньше, точнее). Мутант (старый текст на одном сайте) → RED | Sonnet -163 к.1 | harness 333, build 252, L3 11/11 — интегрированное дерево ожидается |
| F-41 | D-37/D-44/D-45: ошибки walker’а 1..7 → X1 (имя в stderr + abort) в `lmx_call_note_walk_fail`, throw кодируется `LMX_WALK_THROWN + k`, канал хода несёт только k; NO_GRAPH при подготовке — X1, не молчаливое NOT_CALLABLE = 2; поле с parent 0 — объявление (пропуск) | Grok -161 к.3 (`33bb554`) + D-45 (`bbce046`) | build 254, harness 334, L3 11/11; мутант «status: said без THROWN» → walk_selftest RED, thread_turn abort |
| F-42 | D-29/D-30 по Q21 = А: `LmxCallable.offset` и COW-клон удалены (к.0), карта позиций `LmxMergePair` в `lmx_merge_*` (к.1, null = дописывание; авторизованный null-pass в 4 местах эмиссии l2trans + драйвер), ссылка на метод объемлющей Structure — терминал копира, check 77 = тот же адрес для kind-4 (к.2); программа q22.md → 3 | Grok -161 к.0–к.2 (`27e7b01`, `207361e`, `2cbe790`/`de368b5`) | build 254, harness 334 — интегрированное дерево |
| F-44 | D-43: before dispose, `lmx_gc_drop_arrays_in_block` detaches embedded `LmxPost.nodes` from `arena->arrays`; `lmx_gc_cells` does not word-walk POST (else `nodes.next` retains the arrays list); selftest `lmx_post_sweep_selftest` (5 orphan Posts + live mail, recycle + post_init OK); mutant (no drop) RED | Grok -161 D-43 | build 255, harness 337, L3 11/11 |
| F-45 | D-50: walker LT — INT (and int temps) compare signed after load (`(cast: (int) ua) < (cast: (int) ub)`); char/size_t/unsigned/ulong stay unsigned; selftest negative int LT + char 200>100; mutant unsigned int LT RED | Grok -174 c0 | build/harness on tip |
| F-46 | D-51: walker working width `LmxWalkOwn.value` / load_numeric / load_operand / publish_slot / arith_out / eval temps — one type `size_t` (widest numeric); on MinGW LLP64 ulong was 32-bit and truncated size_t at 2^32; selftest size_t 2^32 EQ; mutant width back to ulong RED | Grok -174 c0 | build/harness on tip |

| F-43 | D-49: `lmx_copy_is_terminal_profiles` — запись примитива (`LMX_DOMAIN_KIND_PRIMITIVE`) — общий терминал копира как METHOD; plain `is_terminal` — тот же помощник; selftest: копия под unit с prim-соседом сохраняет тот же адрес, мутант → GRAPH_COPY_INVALID RED; 9 строк перестали падать в exit 1 | Grok (`99db452`) | build 254, harness 337, L3 11/11 — интегрированное дерево (вместе с Opus -159 к.3) |
| F-47 | Общий reference field `@: T name`/`@@: T name` в `l2_take_ns_body` (kind 10 depth 1, kind 11 depth 2, pointee-код в `l2_nsf_ref`) + shared `l2_kernel_ptr_word` (fold `l2_const_local_ty`/`l2_typed_formal`'s const-ветки, char=3/LmxMsgRuntime=28/LmxMsg=29/LmxMsgCopy=30/L2ImmutQuery=6, коды не менялись); read/write проводка (`l2_field_path_check`/`l2_field_path_read` через `l2_own_ty_of_param`, `l2_emit_path_to`'s terminal-gate, `l2_emit_body`'s field-path запись — `lmx_pointer_store_known`); D-52 (prototype-построитель, см. выше). Свидетель `unit_ns_ref_field_general.lm2` — kind-10 поле полный live round-trip (адрес не-null, поточно-идентичен взятому); Model-поле (kind 11) — только декларация, живой round-trip блокирован D-50. Мутант (обе новые ветки построителя убраны) — RED, тот же abort | Sonnet -172 к.1 | harness 339, build 256, L3 11/11, check_docs, diff --check |
| F-48 | D-54: walker `LMX_WALK_OP_PUT_OF` = 19 `[put_of, struct-expr, slot, value]` — держатель ВЫЧИСЛЯЕТСЯ (`lmx_walk_eval` child 1, обязан быть KIND_STRUCT), затем запись слота как PUT (pointer-ячейка / числовая по типу); `lmx_walk_slot` X1: держатель-Structure, чей слот 0 — OP-узел (role-of-head > NONE, без `lmx_walk_kind` — та дверь считает classified), отказан → DEREF на месте держателя plain PUT = INVALID, не тихая запись в узел; scan/arity/void-list покрывают PUT_OF; selftest `lmx_walk_put_of_selftest` (merge Model в pointer-ячейку, PUT_OF DEREF(AT) slot0 LIT 7 читает 7; PUT с DEREF-держателем INVALID); мутанты (walk_slot на child 1; DEREF как держатель) RED | Grok -177 к.4 (`5fa10a3` → main `4d97e22`) | build 265, harness 345, L3 11/11 |
| F-49 | D-55: статусы примитива `LMX_PRIMITIVE_THROW_MERGE` = 2 / `LMX_PRIMITIVE_THROW_IMPLEMENTS` = 3 (`lmx_primitive.h.lm1`); `lmx_walk_prim` отображает их в `LMX_WALK_THROWN + 1` / `+ 2` (корень: d = 0; в теле метода — по S1.1 d_caller + 1/+ 2, через per-site таблицу -171), прочий ненулевой статус — `LMX_WALK_PRIMITIVE` (X1); `lmx_walk_merge_model` — 2 при не-Structure модели и при отказе merge; `lmx_walk_receive_if`: IMPLEMENTS_YES — take, IMPLEMENTS_NO — пропуск письма (выборочный приём, не отказ примитива), UNKNOWN/прочее — 3 (допуск не удостоверен); пустой ящик/нет совпадения — null OK; selftest `lmx_walk_admit_throw_selftest` (merge PRIM с не-Structure моделью → THROWN+1, не PRIMITIVE); мутант (throw → PRIMITIVE) RED | Grok -177 к.5 (`fdedc53` → main `8ee2d7f`) | build 266, harness 345, L3 11/11 |
| F-50 | D-56: kind 10/11's representation исправлено на slot-ссылку (fable's дизайн) — слот хранит адрес pointee ПРЯМО (`lmx_arena_ref_store`/`ref_value`, как kind 3), не адрес отдельно-аллоцированной pointer-ячейки; prototype-построитель для kind 10/11 убран целиком (слот остаётся null, как kind 3/4 — `lmx_implements_walk`'s `if: c != 0` пропускает null consumer-слот как unused); write-сторона — прямая запись `l2_pxp[0]: (cast: (@: void) %s)` (не `lmx_pointer_store_known`); read-сторона — прямое чтение `l2_xp[0]` через `l2_emit_raw_pointer_type` (не `l2_emit_cell_load`/`l2_own_ty_of_param`, та ветка — для отдельной pointer-ячейки, другое представление). 2 L1-синтаксис ловушки по пути (ladder-indentation cutter; отсутствующий `fputs(ind, l2_out)` перед типом — обе пойманы тестированием, не гаданием. Свидетель `unit_receive_letter_model.lm2` — receiveMessage: m MainLetter внутри метода, R0's own mainArgs letter: m\sender != 0 И m\payload\mainArgs оба читаются живьём. Регрессионный пин: `unit_ns_ref_field_general.lm2` (commit 1's `@: int p` round-trip) — по-прежнему GREEN под новым представлением. Мутант (prototype-построитель для kind 10/11 восстановлен) — unit_receive_letter_model RED (то же «R0 was stopped»), unit_ns_ref_field_general остаётся GREEN (write перезаписывает устаревшую ячейку, никогда не читая её) — изолирует ровно то, что должно | fable (дизайн) + Sonnet -172 к.2 | harness 343, build 260, L3 11/11, check_docs, diff --check |
| F-51 | D-58: walker роли `LMX_WALK_OP_MUL` = 20 / `DIV` = 21 / `MOD` = 22 (`COUNT` = 23) той же формы и типизации, что ADD/SUB (`lmx_walk_arith_out`: типы операндов совпадают, int — знаковая арифметика (как D-50; ADD/SUB для INT тоже переведены на знаковую), size_t/ulong — беззнаковая); деление/остаток на ноль — `LMX_WALK_INVALID`, walk остановлен (класс X1, не throw); selftest `lmx_walk_arith_mul_selftest` (6*7, 7/2, 7%2, -7/2 = -3, -7%2 = -1, size_t 10/3, смешанные типы INVALID, 1/0 стоп); мутанты (MUL как ADD; деление на ноль допущено) RED | Grok -170 к.1 (`5658389` → main `85314d1`) | build 267, harness 348, L3 11/11 |
| F-52 | D-57: -178 к.3 — письмо допускается и связывается по PAYLOAD (слот 1): нативно (приём в форме с одним именем, письмо в типизированный формал, `m: raw` письма — `lmx_arena_ref_value(v, 1U)`, null остаётся null) и в корне (`lmx_walk_admit_letter`, -180); свидетель `unit_native_typed_receive` (Entry 7; было exit 1, Thrown 2); мутант — нативный приём, допускающий всё письмо → RED (exit 1), двухимённая форма `unit_receive_letter_model` не затронута | Opus -178 к.3 (`319f713` → main `89a1e2b`) | build 268, harness 349, L3 11/11 |
| F-54 | D-56 (SUPERSEDES F-50): the author's Q26.2 ruling (2026-09-25) -- a slot holding a Structure's address directly makes it a CHILD of the holder (the copier descends); a reference (`@: T name`) is a reference TO a reference, so it needs its own pointer CELL, not a direct slot-address. Reverted -172 c2's D-56 fix (kind 10/11's slot-reference representation) back to D-52's pointer cells in l2trans.lm1: prototype builder's two construction arms restored byte-for-byte from commit 1 (`lmx_pointer_new_owned`/`lmx_arena_take_profiled`, `LMX_TYPE_POINTER_BASE + <code>`); read side back to `l2_emit_cell_load`/`l2_own_ty_of_param` (one level through the cell, not a direct `l2_xp[0]` deref); write side back to `lmx_pointer_store_known` (through the cell, not a bare slot assignment). D-56's REAL cause was never the representation choice itself -- it was that -173's mainArgs letter and this ticket's own sendMessage letter emission stored the sender's address DIRECTLY (matching kind 3's shape, wrongly, since a Message reference needs the SAME cell treatment as any other reference): fixed both letter builders to store a pointer cell (LMX_TYPE_POINTER_BASE + 29, LmxMsg) instead -- l2trans.lm1's `l2_emit_send` (this ticket's own site) and lmx_root.lm1's mainArgs build (lmx_root_launch_tapped, edited under fable's authorization for this ticket) together with `lmx_root_exit_admit`'s own sender read (also authorized), which now classifies the slot (PRIMITIVE, type >= POINTER_BASE) before dereferencing it -- a raw address left there is now a located INVALID, not a misread. Three downstream kernel selftests broken by the change (self-consistent raw sender read/write, outside l2trans) fixed under the same authorization: `lmx_argv_letter_selftest.lm1` (`al_make`/`al_holds`, scenario C), `lmx_root_host_selftest.lm1` (`host_send_exit`, `host_r0_body`). Mutation witness: reverted just the letter-builder cell-wrapping (raw address restored in the letter, prototype/read/write left as cells) -- `unit_receive_letter_model`/`unit_send_ref_method` RED (exit admission / implements admission both now correctly refuse a domain mismatch), confirming both sides must agree as cells, not just one | Sonnet -172 к.4 | harness 354, build 270, L3 11/11, check_docs, diff --check |
| F-53 | D-59: копир — `lmx_copy_is_terminal_profiles` (`lmx_graph_copy_owned.lm1`, помощник D-49): запись Message (`LMX_DOMAIN_KIND_MSG_RECORD`), классифицированная в ЛЮБОЙ арене (таблица диапазонов этой арены / импорт), — общий терминал: слот копии держит тот же адрес LmxMsg, спуска нет; selftest `lmx_copy_msg_terminal_selftest` (пул MSG арены B запечатан и импортирован в A; merge + graph_copy сохраняют адрес Message, payload — свежая копия); `kind_collision` обновлён (OK + тот же адрес, не INVALID); мутанты (MSG как Structure; копия записи) RED | Grok -181 (`e8e8e0c` → main `8d707fe`) | build 269, harness 349, L3 11/11 |
| F-55 | D-63: `lmx_array_new_owned`'s `ARRAY_OF_CHAR` branch calls `lmx_chars_init(arena)` before taking its own backing (Option C, fable-approved) — the interned char table always claims the shared (KIND_PRIMITIVE, TYPE_CHAR) pool first as its head chunk, regardless of construction order; no-op once already laid out. predef of `lmx_chars.h.lm1` (header-only, not the full body) into `lmx_array_owned.lm1` to avoid a multiple-definition link collision with `lmx_walk.lm1`'s pre-existing full predef. Witness `lmx_chars_array_order_selftest.lm1`: char array built with no prior char-table request (D-63's exact order), array itself correct, table still reachable via `lmx_arena_find`, `lmx_char_cell`/`lmx_char_value` round-trip correct, array's own `data[0]` independently writable/readable (table doesn't alias the array's storage) | Sonnet -192 к.2 (`b8c9e28`) | build_l2src -Run + L3 + harness GATE pending |
| F-56 | D-66: `lmx_root_exit_admit` copies `out`/`err`'s bytes into host-owned `calloc`'d memory at admission (`LmxRootExit.owns_text` flag) instead of leaving raw pointers into the taken letter's GC-unreachable arena; `lmx_root_exit_write` frees the copies once written; `lmx_root_exit_set`'s static "why" strings explicitly marked `owns_text: 0` (never freed). Root cause traced via a controlled GC-watch A/B (fable's (kind,type)-mail-import hypothesis measured and disproven en route) -- see D-66 for the mechanism. Witness: the existing `lmx_root_host_selftest` case 2 (R0 exit(7; out-text; err-text) through the real `lmx_root_launch` machinery) | Sonnet -192 к.2 (`b8c9e28`) | build_l2src -Run + L3 + harness GATE pending |
| F-57 | D-61: `l2_field_path_check` (the one read-position path resolver: the expression check `l2_check_fields` and the emission `l2_field_path_read`) admits a bound merge result (`l2_mres_find`) as a root, beside an own field, a typed name and node/for; resolution and emission are the general ones (`l2_path_root`/`l2_path_kind`/`l2_emit_path` over the slot map), no special branch; a segment must be a name, so `merged~[N]x` stays the occurrence branch's.  Witnesses: `unit_merge_path_condition` (4, `if: R~x != 1U`), `unit_merge_path_expr` (-183's `c~s` in a condition, arithmetic and a while condition, 7); main before refuses both | Opus -193 (`f6720b6`) | build_l2src -Run + L3 + harness GATE pending |
| F-58 | D-68: `l2_ccall_box_int` does not stage a `define:` constant (`l2_define_name`, asked after every L2 name) -- it is passed as itself and C checks its type against the prototype (a define has no declared type: it is L1 passed through); the fall-through boxed it into an `int` and cut a char* to 32 bits (the b5 mixa crash).  l2_harness also translates the fixtures' own predef headers (`tests~*.h.lm1`, a loop of their own: a refused one is its own FAIL row).  Witnesses: `unit_define_actual` (staging Absent, the calls with the constants pinned), `unit_define_ccall` (strlen of a predef and a unit define, 11; main before: segfault) | Opus -193 (`7743606`) | build_l2src -Run + L3 + harness GATE pending |
| F-59 | D-65: the flaky `l3_mail_prim_selftest` "a fourth distinct letter" check compared a fresh allocation against three already-taken-and-dropped letters, expecting inequality the kernel never promised -- measured `lmx_turn.lm1:173`'s `lmx_gc_collect`, unconditional at every turn boundary, collects them (neither the test's own locals nor `sink_letter`'s untracked `sunk_last` global is a GC root) before `letter4` is ever taken, so reusing one of their freed same-(kind,type) blocks is the allocator working as designed, not a dangling reference. Dropped the stale-address comparison, kept `letter4 != 0`, mechanism recorded in the comment | Sonnet -194 к.3b (`dc33bd9`) | build_l2src -Run + L3 + harness GATE pending |
| F-60 | D-70: `l2_rw_path_value` takes a root path's unit slot by the path's kind -- a method's occurrence `l2_unit_base + mi`, a qualified branch its eternal slot, a named Structure `l2_ns_base + l2_ns_rank` -- instead of ranking a method's number among the named Structures first (read past their table: l2trans crashed on a root `M\x` of a later method in a unit with no named Structure).  Witness: `unit_occ_root_second` (main: segfault) | Opus -193 T4a (`d4dcd1a`) | GATE pending |
| F-61 | D-71: a declaration built by `l2_rw_*` (the walked root, a walked method) hides its own row from its initializer (`l2_own_excl`, as the native emission does, Q24/D-48): `int: x 1` / `int: x (x + 2)` gives 3.  Witness: `unit_root_decl_init_prev` (main: exit 81) | Opus -193 T4a (`d4dcd1a`) | GATE pending |
| F-62 | D-72 (K-RET): a walked call copies its numeric result into `call_dest` by the callee's rtype; only a non-numeric result leaves as a reference.  Witness: `unit_walk_loop` (`clamp(..) + clamp(..) + clamp(..)` = 13 walked) | Sonnet -194 k.5b (`312a08b`) | GATE GREEN (main 7634aa2) |
| F-63 | D-73 (K-ARITY): a walked callee's arity is the width of its args part (form A, slot 0), not the highest ARG + 1.  Witness: `unit_method_sig_distinct` under `--walk-methods` (`a(5)` never reads its formal) | Sonnet -194 k.5b (`312a08b`) | GATE GREEN (main 7634aa2) |
| F-64 | D-74: `l2_head_is_call` -- a c.* head (the raw C door, spec 6.6.6) is a call in every form, so an empty statement call (`c.abort()`, `c.rand()`) goes the call check, which admits the door's empty argument list; it was checked as an update of a field of that name and its value of no fields refused.  Witnesses: `unit_head_call_c_empty_abort` / `_c_empty_rand` (translates; main: refused), `unit_c_empty_call` (runs, 0; main: refused), with the three other raw-door forms kept from the retired twin gate | Opus -198 (`8dc0273`) | GATE pending |
| F-69 | D-78: `lmx_post_sweep_selftest` больше не требует, чтобы malloc повторил адрес Post. После `lmx_gc_collect` адрес встроенного `LmxPost.nodes`, снятый до collect, отсутствует в `arena\arrays`; `lmx_post_init` каждой взятой ячейки — `LMX_POST_OK`. `reused=` печатается и отказом не является. Ядро не менялось. Мутант: `lmx_gc_drop_arrays_in_block` сразу возвращается (`if: 1 = 1`) — RED `checks=9 failures=1`, строка `FAIL D-43 embedded pool left the arena`, exit 1; откат GREEN `checks=25 failures=0 reused=4 post=216`, exit 0. Полный прогон `build/l2src/20260925_150326`: `checks=25 failures=0 reused=4 post=216` | Grok |
| D-30 | 2026-09-24, fable (замер на `5214386`) | Эмитируемые транслятором пост-merge инварианты (`lmx: invariant: merge result check 78`, метка 78 стоит на ДВУХ разных проверках в одном файле — «дескриптор первого операнда разделяется по адресу» и «ячейки копии не алиасят источник») аборттят `Q: merge: B A` с callable во втором операнде после COW-клона дескриптора в -153; фикстур с callable не в первом операнде нет — harness 325 зелёный; программа `q20-next.md` §2: было entry 81, стало X1 «check 78» | Opus -154 к.1 | Grok -161 к.0/к.2 | FIXED (F-42): COW откачен, check 77 по kind-4 требует тот же адрес, номера проверок уникальны |
| D-31 | 2026-09-24, fable (ревью -153) | `lmx_merge_owned.lm1`: блок COW-клона дескриптора + перезаписи parent продублирован дословно (~25 строк ×2: цикл операндов и тело) — правило автора «не плодить дублёров» | Grok -156 к.0 | Grok -156 к.0 | Grok -156 к.0 | FIXED (F-35) |
| D-32 | 2026-09-24, fable (ревью -153) | `lmx_callable_offset` (`lmx_call.lm1`): комментарий обещает отказ (sentinel) для не-CALLABLE значения в child 0, код классификацию не делает — cast и чтение | Grok -156 к.0 | Grok -156 к.0 | FIXED (F-35) |
| D-33 | 2026-09-24, fable (замер) | Чтение поля за пределами Structure молчит: `node\tag` с индексом 2 у двухслотного `R` (программа `q22.md`) даёт мусор (entry 90), не X1 — `lmx_arena_ref_cell/ref_struct` не сверяют индекс с `len` (или транслятор не сверяет статически) | Grok (ядро) — измерить, где граница | Grok -156 к.0 (замер: граница статическая, у транслятора — не в ядре) | MEASURED → транслятор (open) |
| D-34 | 2026-09-24, Sonnet -155 к.2 | `unit_indent_stack_field_index.lm2` / `unit_void_value.lm2` (негейтованные) падают «unknown type» на голых `LmP0IndentStack`/`LmP0Text` как целях cast — устарели против миграции a2cf69e на `c.LmP0*` | Sonnet (после -155) | Sonnet -160 к.3 | FIXED (F-36) — обе фикстуры по-прежнему негейтованы: следующие пробелы D-37/D-38 |
| D-35 | 2026-09-24, Sonnet -155 к.2 | `l2_colon_simple_ty` (:5496) даёт ЛЮБОМУ известному вызову тип −10 (только числовой) — результат predef-функции нельзя присвоить типизированной цели («assignment value has incompatible type», `unit_lm_own_actual_span.lm2`); результат должен нести объявленный тип возврата | Sonnet (отдельный малый тикет после -155) | Sonnet -160 к.2 | FIXED (F-36) |
| D-36 | 2026-09-24, fable (ревью -156) | `lmx_call_install_walk` — процесс-глобальный fnptr `lmx_call_walk_fn`, устанавливаемый lmx_walk (`roles_open`/`program_bind`) и L3 (`lmx_call_install_walk_status`): стык компоновки (call.o не линкует walk/plan/scratch), не режим; при постоянной компоновке walker’а с ядром — прямой вызов | Grok (позже, после -158/-159) | ОТМЕНЁН 2026-09-26: записан 23.09 22:38 Сан-Пауло, старше 24.09 10:00. |
| D-37 | 2026-09-24, Opus -159 (чтение -158) | Статусный канал walk смешивает собственные ошибки walker’а (`LMX_WALK_INVALID` 1, `NO_GRAPH` 2, `NOMEM` 3, `CHECKPOINT` 4, `UNSUPPORTED` 5, `PRIMITIVE` 6, `NOT_CALLABLE` 7) с номерами throw (`status: said` в нативной ветке `lmx_walk_call`, `ec7b86f`); `lmx_call_note_walk_fail` и ход (`lmx_thread.lm1` :557–:561) не различают — испорченное op-дерево (INVALID = 1) неотличимо от неотловленного `merge` (1); строки `thrown 1/2` прошли бы вакуумно | Grok -161 (ядро): ошибки walker’а — X1 (abort с именем), канал несёт только throw; внутри walker’а throw представляется отдельно (например `LMX_WALK_THROWN` + k), диспетчер конвертирует | Grok -161 к.3 | Grok -161 к.3 | FIXED (F-41) |
| D-38 | 2026-09-24, Opus -159 | `lmx_call0` нативная ветка кастует `addr` в `LmxCallEntrySelf (node, self)` (`lmx_call.lm1` :147–:149) — после -159 к.1 (addr = prim-ABI трамплин) это UB для любого сгенерированного дескриптора; 6 сгенерированных мест динамического вызова (`l2trans.lm1` :15130) нуждаются в раздельных status/dest | Opus -159 к.1 (разрешено трогать `lmx_call.lm1`: `lmx_call_prim(arena, callable, refs, nargs, dest, out) → status`, нативная ветка `lmx_call0` на prim-ABI, два selftest’а ядра на prim-ABI natives) | Opus -159 к.1 (`lmx_call_prim`, `lmx_call0` на prim-ABI, 24 natives 18 selftest’ов) | FIXED (F-38) |
| D-39 | 2026-09-24, Sonnet -160 к.3 | `stack\columns[idx]: value` с `size_t` локалом `idx` через сырой member-путь отказывает «own array index requires an in-bounds primitive literal» — динамический индекс не понижается (`unit_indent_stack_field_index.lm2`, негейтована) | Sonnet -163 к.2 (измерено, не чинено) | FIXED (F-72). Индекс ELEM/ELEMPUT — вычисленный `size_t` (`lmx_walk_index`), не сырая ячейка и не каст из `int`. `entry_dyn_array_index` Entry 7; int-индекс — отказ конверсии. `stack\columns[idx]` — индекс `c.*` (`l2_raw_c_root` / `l2_raw_index_head`), не own-массив; `unit_indent_stack_field_index` переводится (`l2_p0_0\columns[l2_p0_1]`, `stack\columns[2]`). Прогон фикстуры не в замыкании ядра (`lm_own_new_zero`). Нативный own-массив метода по-прежнему литерал в границах. Замер: `steps/d39-member-path-index.md`; посадка: `steps/d39-dyn-index.md` |
| D-40 | 2026-09-24, Sonnet -160 к.3 | `return: d(0)` при `sub: d` отказывает «incompatible entry signature», а та же форма в других местах — «a callable without a result has no value» (`unit_value_call_sub_refused`, `unit_return_sub_refused`): две диагностики на одно правило (`unit_void_value.lm2`, негейтована) | Sonnet -163 к.1 | Sonnet -163 к.1 | FIXED (F-40) — попутно нашёл третий, ранее скрытый вариант: `x: d()` (присваивание) давало «assignment value has incompatible type», тоже починено; `g(d())` (аргумент) уже давал верное сообщение (мой первый замер на пустом теле `sub:` был артефактом фикстуры, не багом) |
| D-41 | 2026-09-24, fable (ревью -160 к.2) | Отображение слова типа → код типа рассыпано по ~9 местам `l2trans.lm1` (:5059/:5083/:7886/:7931/:7943/:8006/:8754 + новый `l2_proto_ret_ty` :4601, `l2_prim_type_word` :8849 — только да/нет): правило автора «не плодить дублёров» — одна функция слово→код для всех мест | Sonnet -162 (измерить сначала) | Sonnet -162 к.2 | Sonnet -162 (две согласованные группы свёрнуты: `l2_ptr_type_word`, `l2_ret_type_word`/`l2_ret_type_node`; пять узких пространств — в GATE-инвентаре «измерено, не сведено») | FIXED частично (F-39) |
| D-42 | 2026-09-24, fable (ревью -160 к.2, `l2_typed_formal` :12463 при чтении collision LmxMsgBlock/LmxArenaBlock=26) | Ветка `LmxMsgBlock` в `l2_typed_formal`'s `@@:`-блоке не имела своего `return: 0` — падала сквозь проверку `LmxArenaBlock` (не совпадает) дальше по цепочке вместо немедленного возврата с ty=26; у ветки `LmxArenaBlock` — лишний задвоенный `return: 0` сразу после (похоже одна строка попала на уровень if: выше). Минимальная программа: `fn: probe (@@: LmxMsgBlock m) int` / `return: 0` / `end: probe` — ДО фикса: «unknown type», atom=LmxMsgBlock (exit 1); ПОСЛЕ: exit 0. Ни одна .lm2-фикстура в корпусе не использует `LmxMsgBlock` (измерено, `rg` = 0) — дефект был спящим | Sonnet -162 к.2 | Sonnet -162 к.2 | FIXED (F-37) |
| D-43 | 2026-09-24, Opus -159 WIP (измерено) | 5-й Message на одной арене отказан: `lmx_post_init` → `lmx_pool_open` → `lmx_arena_array` находит `box->nodes` уже в `arena->arrays` — новый Post получил ячейку ранее свёрнутого Post (тот же адрес), а его встроенный пул при sweep не был сброшен; `lmx_thread_turn_selftest` | Grok -161 | FIXED (F-44) |
| D-44 | 2026-09-24, Opus -159 WIP | `lmx_walk_call0_dispatch` сворачивает отказ подготовки (NO_GRAPH — тело без шага) в `LMX_CALL_NOT_CALLABLE` = 2 без `lmx_call_note_walk_fail` — ход молча возвращает 2 | Grok -161 к.3 (D-37: X1) | Grok -161 к.3 | Grok -161 к.3 | FIXED (F-41) |
| D-45 | 2026-09-24, Opus -159 WIP | `independent:` (вечная ветвь) среди полей корня — unit-поле с parent 0, walk отвечает UNSUPPORTED (5) вместо пропуска как объявления (G3) | Grok -161 | Grok -161 | Grok -161 (D-45 коммит `bbce046`) | FIXED (F-41) |
| D-46 | 2026-09-25, Opus -159 к.2h (измерено) | `lmx_settle_one` удаляет неуспешного ребёнка из Array, а `lmx_child_handoff` = `lmx_arena_attach` (склейка диапазонов/массивов/блоков донора в арену родителя); комментарий `lmx_root.lm1` :307 «its failure root is retained» коду не соответствует — записи о корне неуспеха нет, дамп при success = 0 печатает склеенный инвентарь массивов, а не граф неуспешного Message от его корня | Grok (после -161): запись о сохранённом корне неуспеха при settle | Opus -159 к.2h (уточнено: корень неуспеха СОХРАНЯЕТСЯ для ребёнка, зарезервированного с result-ячейкой — `lmx_child_publish_prepared` :224–:226, `lmx_settle_one` чистит её только при успехе :127–:130; у `lmx_root_create` result = 0 — верхний ребёнок без ячейки; в H1 R0 резервируется host’ом с ячейкой → корень сохранён, дамп печатает граф R0) | FIXED формой H1 (-159 к.2h) |
| D-47 | 2026-09-24, Sonnet -164 к.2 | `l2_own_seg_scan` (:11589, резолвер `test\arg`/`test\[N]arg` через `l2_path_root`'s `root <= -1000` ветку, единственный live-механизм для method-rooted occurrence путей — НЕ `l2_check_fields`/`l2_emit_fields`'s flat-token ветки, которые для этой формы мертвы) даёт LAST при чтении ИЗНУТРИ метода (замерено пробой), но FIRST при чтении с КОРНЯ (замерено напрямую на `unit_occ_root_named.lm2`'s сгенерированном C/L1: `test\arg` читает cell 1 = occurrence 0, не cell 2). `unit_occ_root_named.lm2`'s собственные ассерты (2/2/2) это не ловят — `arg` там argument-bound, occurrence 0's checkpoint-resync совпадает с последним значением независимо от того, какая строка «occurrence 0». Root cause не найден (l2_own_host/l2_scope_host выглядят одинаково для root и method контекста; расхождение где-то в регистрации, не в чтении) | Sonnet | RETRACTED, не баг (Sonnet -165): «cell 1» был прочитан из МУТАНТНОЙ сборки (`harness_164_mutant`, flat-token сайты намеренно возвращены на occ=0 для witness -164) — сравнение с чистой (реальный фикс) сборкой даёт cell 2 верно. Прямая инструментация (временная, полностью убрана) подтвердила: какой из двух резолверов срабатывает, решает ФОРМА ОПЕРАТОРА (operand `if:`-условия → flat-token ветка; RHS plain-присваивания → `l2_field_path_read`→`l2_path_root`→`l2_own_seg_scan`), НЕ root-vs-method контекст; оба уже корректно дают last и с корня, и из метода, в обеих формах — проверено напрямую, root-level plain-assignment включительно. Полный разбор в `steps/last-occurrence-inventory.md` («D-47 retracted» секция) |
| D-48 | 2026-09-25, Sonnet -164 (измерено) + автор Q24 = A | `l2_own_add` отказывает «duplicate declaration» на второе типизированное объявление того же имени в одном теле (правило 4 S2 -112, самодельное) — противоречит книге §fields и Q24 = A: второе объявление — второе вхождение (`[0]`/`[1]`, неуточнённое — последнее); сегодня повтор возникает лишь из привязки формала по имени; уточнение автора: и с другим типом (`int: x 1; char: x (x + 2)` → `[1]x` = 3 — инициализатор читает предыдущее вхождение); разруливает транслятор: своя C-ячейка на вхождение, разнотипное значение — через абсолютную конвертацию с валидацией (порт §7), не C-каст; до порта — локализованный отказ | Sonnet -166 к.3 | CLOSED (stale, -195 измерено: строки «duplicate declaration» в трансляторе нет) — исправлено `540c7fe` (Sonnet -166 commit 3, Q24 = A: повторное типизированное объявление — второе вхождение); строка не была обновлена |
| D-49 | 2026-09-25, Opus -159 к.3 (измерено на `df7aa21`) | `lmx_copy_is_terminal_profiles` (:364–:382) держит по адресу METHOD/CALLABLE/OP/ROLE, но не запись примитива (`LMX_DOMAIN_KIND_PRIMITIVE` 20, тип 34): с 2b шаги корня лежат в unit, копир merge (`lmx_copy_process` :673 копирует структурного родителя до parent 0) доходит до `prim`-шага `sendMessage`, `lmx_copy_value` падает в INVALID → merge бросает 1 → R0 стоп — 9 строк exit 1 | Grok (-161 D-49, перед D-43/-167): запись примитива — общий терминал копира | Grok -161 | Grok -161 D-49 | FIXED (F-43) |
| D-50 | 2026-09-25, Opus -175 (измерено на `6dea450`) | Регрессия -167 к.2: `lmx_walk.lm1` LT сравнивает `ua < ub` после загрузки операндов как ulong — отрицательный int грузится огромным беззнаковым (char — байт 0..255, `lmx_char_value_known` = `& 255`, не затронут; уточнение Opus): `-1 < 0` ложно (проба в корне: exit 0 вместо 1); строк с отрицательными сравнениями в harness нет, потому 338 зелёный | Grok -174 к.0: для INT сравнивать со знаком; регрессионная строка (проба Opus, Entry 1) | FIXED (F-45) |
| D-51 | 2026-09-25, Opus -175 (измерено): `size_t: big 4294967296U` / `if: big = 0U -> r: 1` / `if: big = 4294967296U -> r: r + 2` — expected Entry 2, got 3 (big and literal loaded as 0). Cause: working width `ulong` = 32 bits on MinGW LLP64 while size_t = 64; LIT store_size already 64-bit | Grok -174 к.0: working width = `size_t` in Own.value / load_numeric / load_operand / publish_slot / arith_out (one type, no twins); INT-only signed LT kept | FIXED (F-46) |
| D-52 | 2026-09-25, Sonnet -172 к.1 (замер + fable, диагноз) | Именованной Structure новый reference-field kind (10/11, `@: T name`) не имел арма в per-kind построителе прототипа (`l2trans.lm1` ~`:20556`, цикл `fx` по `l2_nsf_n`: char даёт `lmx_char_cell_known`, массив — `lmx_array_new_owned`, kind 3 сознательно ничего — материализуется позже своим merge; для 10/11 арма не было вовсе) — слот оставался сырым обнулённым child arena, никогда не прошедшим `lmx_value_allocate_owned`; `lmx_pointer_store_known`/`_value_known` и копир `lmx_merge_owned` не могут обращаться с такой ячейкой как со значением: `Holder: h` / любое чтение-или-запись `h\p` (kind 10) → `lmx: invariant: a field path met no Structure` на каждый доступ. Витрина: сосед-поле обычного kind в ТОЙ ЖЕ Structure по другому индексу читает/пишет верно тем же `l2_pst` — сразу следующий вызов, тот же `l2_pst`, индекс поля kind 10 — null | fable (диагноз по бисекции Sonnet) | Sonnet -172 к.1 | FIXED (F-47) |
| D-53 | 2026-09-25, Sonnet -172 к.1 (замер, строя свидетеля) | Бинарный `@x` (без call-arg sugar — `l2_eval_fields`'s `l2_addr_tail`, `:17895` area) на Structure-типизированном own field (`Model: mo` затем `@mo`) наивно эмитирует `& l2_q%d` (адрес WORKING-COPY POINTER-переменной, не её значение) — double indirection; own field уже хранит указатель на Structure, `@x` должен вернуть само значение. Единственная существующая фикстура с этой комбинацией (`unit_field_path_unit_addr.lm2`, `p: @fresh`) — root-level, root-pending (Opus's -159 root-walk refusal), никогда фактически не исполняется — баг спал. Найден при построении свидетеля -172 к.1 (`unit_ns_ref_field_general.lm2` изначально хотел `h\q: @mo`); сравни `l2_check_addr`'s (`:14520`) более осторожную ветку — у неё ЕСТЬ `l2_own_is_pointer`-специальный случай для локалов/формалов, но она РЕФЬЮЗИТ Structure-типизированные own fields целиком (нет обходного пути ни там, ни там сегодня). **Перепроверено fable 2026-09-25 на main `b7cce8c` (l2trans собран gcc в облаке, пробы `Model: mo` / `q: @mo` и `peek(@mo)` в теле метода):** рабочих копий после -189 c3b-3 нет, двойной косвенности нет — обе формы **отказ** `expression too long` / `atom=@` (`l2trans.lm1:15864` и `:19343`: `l2_own_addr` возвращает 1 для слота — «a slot has no cell to address», `:6190` — и отказ уходит веткой переполнения буфера с чужим текстом). По модели «Две формы» (§3) own-Structure — прямой слот, держащий саму Structure: `@mo` = значение слота, `(cast: (@: Model) l2_q%d_from[0])` — то, что `l2_own_load` уже даёт для слота (`:6168`). Переформулирован: не double indirection, а отсутствующая ветка слота в `l2_own_addr` + неверный текст отказа | Opus (транслятор, мелкое: ветка слота в `l2_own_addr`, located-текст отказа; свидетель — `unit_ns_ref_field_general` получает `h\q: @mo` round-trip, инвертированная проверка) | FIXED (F-65, Opus, main `5dae906`: ветка слота в `l2_own_addr`, отказ «this field has no address to take», `unit_ns_ref_field_general` Entry 7 с независимым маршрутом `h\q != mo`, мутанты D53a/D53b; `steps/defect-d53.md`; машинный гейт GATE DONE `19d2180`) |
| D-54 | 2026-09-25, Opus -178 к.2 (измерено) | У walker’а нет PUT с ВЫЧИСЛЯЕМЫМ держателем: `lmx_walk_slot` (:503–:512) берёт child 1 как фиксированную ссылку; запись поля Structure, которую держит pointer-ячейка (`m\f: v`, Structure существует только во время исполнения), невозможна; DEREF-узел на месте держателя прошёл бы проверку KIND_STRUCT и запись легла бы в сам узел молча | Grok -177 к.4: `PUT_OF` с вычисляемым держателем + X1 на OP-узел в держателе PUT | FIXED F-48 (`4d97e22`) |
| D-55 | 2026-09-25, Opus -178 к.2 (измерено) | Неуспех примитива-допуска (merge PRIM `lmx_walk_merge_model`; допуск payload в receive-if) уходит как `LMX_WALK_PRIMITIVE` (по D-37 — ошибка walker’а = X1), а должен быть неявным throw вызывающего: merge = d_caller + 1, implements = d_caller + 2 (`unit_s1_merge_uncaught_entry`: Thrown 1 / Stopped) | Grok -177 к.5 | FIXED F-49 (`8ee2d7f`) |
| D-56 | 2026-09-25, Sonnet -172 к.2 (замер) | Типизированная admission (`l2_emit_admit`→`lmx_runtime_implements`) никогда фактически не исполнялась ни одной фикстурой в истории (`unit_admit_letter_typed.lm2`, `unit_admit_rebind_read.lm2` и т.п. — все `root-pending`); первый живой свидетель (`receiveMessage: m Model` внутри метода, -172 к.2) падает «R0 was stopped» (неотловленный `implements`-throw). Дебаг-печать на месте вызова опровергла первую гипотезу fable (арена): `l2_program_arena` = текущий `lmx_thread_current()\slot\arena` побайтово, классификация letter\graph в этой арене успешна (classify=6, не NONE) — арена НЕ причина. Прочтение `lmx_implements_walk` (`lmx_implements.lm1:106-184`) до конца показывает настоящий отказ: по каждому используемому полю (`:142-149`) сравниваются `lmx_domain_kind` ТРЁХ адресов — значения на входящем varA, на B и на прототипе C (`consumer`) — и любое расхождение kind → NO. Для sender-поля (kind 10, commit 1's D-52 фикс) прототип хранит адрес СВЕЖЕ АЛЛОЦИРОВАННОЙ `lmx_pointer_new_owned`-ячейки (`KIND_PRIMITIVE`), а РЕАЛЬНОЕ письмо хранит в том же слоте СЫРОЙ адрес `LmxMsg*` (`lmx_arena_ref_store(letter_graph, 0U, message)` — без обёртки, -173's own code) — разные домены (kind_primitive vs kind записи-сообщения), несовпадение. D-52's фикс корректен для commit 1's `@: int p` (пишется ПОСЛЕ конструирования, ячейка нужна заранее) — но конфликтует с admission (значение уже финально на входе, а не пишется позже) для kind-10 полей типа `@: LmxMsg`, чей источник — не `lmx_value_allocate_owned`-ячейка, а прямой адрес ядерной записи | fable (диагноз арены — опровергнут прямым замером; я, диагноз домен-несовпадения; fable, финальный дизайн — slot-ссылка) | Sonnet -172 к.2 | FIXED (F-50), СУПЕРСЕДЕД в -172 к.4 (F-54): slot-ссылка (D-56's фикс) была НЕВЕРНОЙ формой по author's ruling Q26.2 (2026-09-25) — reference = reference К reference, не прямой адрес; настоящий фикс — letter's sender = pointer cell (см. F-54) |
| D-57 | 2026-09-25, Opus -178 к.3 подготовка (измерено) | Нативный приём в типизированное поле (`T: m` + `receiveMessage: m`, `l2_emit_admit` на `l2_ngraph` = `letter\graph`, l2trans.lm1 ~:19598/:10979) допускает ВСЁ письмо, а после -173 письмо — `(sender; payload)`: `sender` в слоте 0 сравнивается с первым полем модели, допуск отказывает, неявный throw `implements` — любое письмо host’а отвергается. Проба (метод `probe`: `MainLetter: m` / `receiveMessage: m` / `return: 7`, MainLetter = `char: []: []: mainArgs`): exit 1, Thrown 2, R0 stopped вместо 7. Спало: все строки с этой формой были root-pending | Opus -178 к.3 (по ответу q25): допуск PAYLOAD (слот 1) против T на обоих путях — нативном и в корне | FIXED F-52 (`89a1e2b`) |
| D-58 | 2026-09-25, Grok -170 к.1 (класс «арифметика» корня, `steps/root-walk-blocks-arrays.md`) | У walker’а не было ролей `*`, `/`, `%`: 4 строки класса K4 + codex/rethrow/nested_while стояли на «this expression» | Grok -170 к.1 | FIXED F-51 (`85314d1`) |
| D-59 | 2026-09-25, Opus -178 к.3 (измерено) | В ИНТЕРПРЕТИРУЕМОМ корне любой merge ПОСЛЕ приёма бросает `merge` (THROWN+1): `receiveMessage: raw` / `Model: m` (Model = {size_t v}) → exit 1, Thrown 1, R0 stopped; без приёма merge проходит, в методе те же два оператора проходят (exit 7). Вероятная причина (по образцу D-49): merge PRIM копирует родительский unit, а он после приёма держит pointer-ячейку raw → письмо → его слот 0 (sender) = Message host’а, запись в арене host’а, которую копировщик R0 не классифицирует; метод держит письмо вне копируемого поддерева | Grok FABLE-GROKBOT-COPY-MSG-TERMINAL-20260925-181: ссылка на запись Message — терминал копировщика, общий по ссылке (помощник D-49) | FIXED F-53 (`8d707fe`) в том, что покрывает -181; строка `unit_admit_letter_formal` НЕ переведена — корень остаётся на D-60 |
| D-60 | 2026-09-25, Opus -183 к.2 (измерено, приватная трасса копировщика) | После -181 (e0b07cb) проба «приём, затем merge» в ИНТЕРПРЕТИРУЕМОМ корне всё так же бросает `merge` (walk noted 1 = THROWN+1, exit 1, R0 stopped; пробы b3 Model / b1 MainLetter и `unit_admit_letter_formal`). Трасса: `lmx_walk_mail_take` отдаёт `letter\graph`, слот 0 = sender (Message host’а); `lmx_walk_merge_model` зовёт `lmx_merge_owned` с src = dst = арена программы; последний классифицируемый копировщиком адрес перед отказом — этот sender, `lmx_range_classify(арена программы, sender)` = 0 (LMX_KIND_NONE). Арена программы никогда не импортирует диапазон Message host’а, поэтому терминал -181 (MSG_RECORD) не достигается: ветка KIND_NONE (`lmx_graph_copy_owned.lm1` ~:491) → UNSUPPORTED → merge → THROWN+1 в корне после приёма | Grok FABLE-GROKBOT-SENDER-RANGE-20260925-185: получатель получает диапазон Message отправителя явным актом доставки (post/attach или take — измеряет Grok), без обхода в копировщике | устарел после -186 (F-68: копир не спускается в pointee ячейки слота 0), строка бежит (Entry 4; инверт `entry 0` RED; `6b06a5b`) |
| D-61 | 2026-09-25, Opus -183 к.4 (измерено на main da4f9a1, проба n159/probe/mcond.lm2) | Путь по связанному результату merge как операнд ВЫРАЖЕНИЯ — «unresolved name» нативно, и в методе, и в корне: `c: merge: Counts` затем `if: c\s = 3U` отказан; через локал (`v: c\s`, `if: v = 3U`) транслируется — читатели результата merge (`l2_mrs_slot_named`) не подключены к резолверу операндов выражений. **2026-09-26, Opus -193 T1 (измерено на 1889ca1):** та же форма (`if: R\x != 1U`) теперь проходит трансляцию и падает в gcc «R undeclared» — located-отказа нет вовсе; фикстуры обходят через локал | Opus (после -193 T1; общий резолвер операнда для корней результата merge, не спец-ветка) | FIXED (F-57) — opus/d61-d68 `f6720b6`: `l2_field_path_check` (общий резолвер пути в позиции чтения, и проверка, и эмиссия) принимает связанный результат merge как корень; разрешение и эмиссия — общие (`l2_path_root`/`l2_path_kind`/`l2_emit_path` по карте слотов); сегмент — имя (`merged\[N]x` остаётся за веткой вхождений). Строки: `unit_merge_path_condition` (4), `unit_merge_path_expr` (-183 `c\s`: условие, арифметика, while; 7) |
| D-62 | 2026-09-25, Sonnet -172 к.3 (измерено, 3 пробы) | В ИНТЕРПРЕТИРУЕМОМ корне `sendMessage: Ref X` с Ref = ссылка на Structure, которая не является Thread/Message-адресом (проба: bare `receiveMessage: m` letter-ссылка сама как Ref) — переводится и собирается чисто (статическая проверка типа Ref верна: `m` действительно ссылка), но в рантайме крашится неконтролируемо: `lmx_service_post` возвращает MISSING/не-OK, генерируемое тело `l2_send<k>`/`l2_msend<k>` отвечает голым `return: 1`, которое `lmx_walk_prim` (`lmx_walk.lm1:1119-1136`) маппит в generic `LMX_WALK_PRIMITIVE` (не `LMX_PRIMITIVE_THROW_*` — тех статусов тут нет) — печатает «lmx: walk error: PRIMITIVE» и завершает процесс, не located-отказ и не X1 (в отличие от метод-тела формы, чей caller уже оборачивает то же самое в X1: `c.fprintf(stderr, "lmx: invariant: sendMessage failed\n"); c.abort()`). НЕ специфично для Ref — та же форма для ЛЮБОГО внутреннего отказа `l2_send<k>` (OOM и т.п.) уже была раньше, Ref просто впервые делает адресата пользовательски управляемым, так что путь стал реально достижимым не только через OOM | Кернел-сторона (генерируемое тело `l2_emit_send` / `lmx_walk_prim`'s generic-PRIMITIVE fallback, не translator's статическая проверка типа — та отработала верно) | FIXED: отказ тела `l2_send`/`l2_msend` — `l2_send_fail` (тот же X1, `abort`), не `return: 1`. Свидетель `unit_send_ref_root_fail` exit 3. |
| D-63 | 2026-09-25, Opus -184 prep (измерено на scratch-ядре с ELEM/ELEMPUT) | Char-массив, созданный ДО таблицы интернированных char-ячеек, блокирует таблицу: оба — «массив (PRIMITIVE, CHAR) арены»; построитель делает backing `command` (8 байт) первым, `lmx_chars_init` отказывает (`lmx_chars.lm1:43`, массив уже есть), `lmx_char_cell` читает этот backing как таблицу на 256 ячеек и отдаёт 0 → `lmx_walk_store_char` падает в `l2_program_build` (#21, «the host could not make R0»): любой char-литерал/элемент в корне после объявления char-массива | Grok (в -170 к.2, до ELEM char-строк): таблица char в своём пуле/типе или её раскладка до первого char-backing (`lmx_array_new_owned` → `lmx_chars_init` первой; scratch-фикс Opus n159/mkchars.py зелёный) | FIXED (F-55) |
| D-66 | 2026-09-26, Sonnet -192 к.2 (измерено, реализуя D-63's фикс C; fable's исходная гипотеза — почтовый путь путает (kind,type) — трассирована и опровергнута прямым замером) | Use-after-free: `lmx_root_exit_admit` (`lmx_root.lm1`) копирует `out\data`/`err\data` как СЫРЫЕ указатели в байты арены письма в `LmxRootExit` — обычный C-struct (`LmxRootLaunch`'s C-стек локал), который `lmx_gc_mark`'s корневой обход НИКОГДА не посещает (не узел графа); взятое письмо держат только локалы `lmx_root_host_take`, исчезающие в момент возврата — байты `out`/`err` GC-недостижимы сразу после admission, НЕЗАВИСИМО от D-63. Подтверждено эмпирически (GC-watch A/B на одном адресе): и в чистом baseline (фикс C выключен) блок `out` тоже сметается (`live=0`), но байты выживают по удаче (никто не переиспользует именно этот слот до записи); с фиксом C аллокации char-таблицы надёжно переиспользуют именно этот освобождённый слот, портя байты до записи | Sonnet -192 к.2 (по решению fable): host-шов копирует байты при admission (`calloc`, `LmxRootExit` владеет копией через `owns_text`), `lmx_root_exit_write` освобождает после записи; `lmx_root_exit_set`'s статические "why"-строки явно помечены `owns_text: 0` (никогда не освобождаются) | FIXED (F-56) |
| D-67 | 2026-09-26, Sonnet -192 к.2 (измерено при трассировке D-66, не чинено — по указанию fable, отдельный тикет ядра) | `lmx_pool_add_chunk` (`lmx_pool.lm1:108`, `bytes: pool\chunk_capacity * pool\stride`) растит ПОЗДНИЕ чанки общего пула по `chunk_capacity` ПУЛА (зафиксирован при первой же аллокации, создавшей пул), а не по запросу ВЫЗЫВАЮЩЕГО для этого конкретного роста: если интернированная char-таблица (256 ячеек) первой claims пул (PRIMITIVE, CHAR), любой позже растущий в том же пуле запрос (например `out`'s 8 байт) получает лишний 256-байтовый чанк вместо точного по размеру. Не первопричина D-66's порчи (baseline-тест показал ту же недостижимость и для корректно изолированного 8-байтного блока), но реальный отдельный сопутствующий дефект | Sonnet (D-67 по `steps/tickets-20260925.md` §5; замер и вопрос — `steps/pool-chunk-growth-d67.md`) | FIXED (F-67) — `claude/continue-sonnet-next-doc-aaz95e` `54fd6df`: вариант A как решил fable — `lmx_pool_add_chunk(arena, pool, want)`, чанк = `max(want, pool\chunk_capacity)`, `pool\chunk_capacity` больше нигде не пишется (save/restore в `lmx_pool_take_n` снят); `lmx_pool.h.lm1:42-54` переписан под новое правило. Селфтест `lmx_pool_selftest.lm1` (grow_pool, шаг 4): широкий запрос 8 не поднимает `chunk_capacity`; второй, малый рост после него получает чанк ровно 4 (не 8) — `lmx_chunk_room`; неудачный рост тоже не трогает шаг. Мутант — возврат старого write-back + `want` игнорируется в `add_chunk`: все три новых чека RED, откат — GREEN. `python tools/build_l2src.py --only lmx_pool` зелёный; полный прогон 174/230, тот же набор красных, что и базовый `<windows.h>`-замыкание. `l2src/`-двойник обновлён тем же диффом. Harness eternal-runs и L3 — машинный гейт, не прогнаны в облаке |
| D-68 | 2026-09-26, Opus -193 T1b (измерено: одинаково на main до T1b и после; фикстура не имела строки harness) | char* define-константа как аргумент вызова стадируется в `int`-временную и теряет старшие биты — регресс b5 mixa (mixa_app_window, `L2_RUNTIME_MODULE_LIST_AUDIT.txt`): `dev/l2src_sandbox/tests/unit_define_actual.lm2` — `probe_define_take(panel, 0U, PROBE_DEFINE_LABEL, PROBE_DEFINE_FG)` (predef `define: PROBE_DEFINE_LABEL "OK"`, формал `const: @(char label)`) даёт `int: l2_t0` / `l2_t0: PROBE_DEFINE_LABEL`, то же для `PROBE_DEFINE_FG` (`4294967295U`, формал `unsigned`) и для `define:` самого unit (`PROBE_UNIT_LABEL`); сравнение с `PROBE_DEFINE_OK` идёт как есть. Константа не требует стадирования — передаётся сама собой (или временная получает тип формала) | Opus после -193 | FIXED (F-58) — opus/d61-d68 `7743606`: `l2_ccall_box_int` не стадирует `define:`-константу (`l2_define_name`, после всех имён L2) — она передаётся сама собой, тип проверяет C по прототипу; `unit_define_actual` — стадирование в Absent, вызовы с константами пинованы; новая бегущая строка `unit_define_ccall` (strlen predef- и unit-define, 11; без фикса — segfault); harness переводит и заголовки фикстур tests\*.h.lm1 (своим циклом, отказ — своя строка, драйвер не трогает) |
| D-69 | 2026-09-26, Opus -193 T4a (измерено: одинаково на main 939bfc8 и на ветке T4a) | Метод с формалом `char: c` не собирается: `l2_emit_parts` (часть args, форма A, -189 c4) пишет типизированную ячейку формала через `lmx_char_cell_known(process_chars, 0)` — ни функции, ни `process_chars` в программе нет (gcc: «implicit declaration of function 'lmx_char_cell_known'», «'process_chars' undeclared»). Минимальная программа: `fn: low (unsigned: u; char: c) unsigned` / `return: u`, вызов из корня. Корень дефекта — эмиссия ячейки args-части для char (как у own-поля char: через таблицу интернированных char-ячеек программы), не строка | Opus | FIXED в ветке (`steps/defect-d69.md`): `l2_parts_have_char()` добавлен в условие таблицы `process_chars` и предефа `lmx_chars_owned`; строка `unit_char_formal_parts` (7) |
| D-70 | 2026-09-26, Opus -193 T4a (измерено, gdb: `l2_ns_rank` ← `l2_rw_path_value`) | Корневой путь через вхождение метода `M\x` (-196) крашит l2trans, когда M — не первый метод юнита без именованных Structure: `l2_rw_path_value` считал `l2_ns_base + l2_ns_rank(path[1])` ДО проверки вида пути, а для вида 3 `path[1]` — номер метода, и `l2_ns_rank` читал таблицу именованных Structure за её концом (у `unit_occ_root_field` метод нулевой — цикл пуст, поэтому не проявлялось) | Opus (свой -196) | FIXED (F-60) — T4a `d4dcd1a`: слот юнита считается по виду пути; строка `unit_occ_root_second` (main — segfault) |
| D-71 | 2026-09-26, Opus -193 T4a (измерено) | Повторное объявление в ИНТЕРПРЕТИРУЕМОМ корне читало в своём инициализаторе собственную новую строку: `int: x 1` / `int: x (x + 2)` даёт x = 2, нативно (Q24 = A, D-48; `l2_own_excl`) — 3 | Opus | FIXED (F-61) — T4a `d4dcd1a`: объявление корня и метода скрывает свою строку от инициализатора (`l2_own_excl`, как нативная эмиссия); строка `unit_root_decl_init_prev` (main — exit 81) |
| D-72 | 2026-09-26, Opus -193 T4a (измерено на 939bfc8, проба `pick(1) + pick(2)`: native 3, walked 4) | K-RET: результат walked-вызова (калли с native 0) уходит ССЫЛКОЙ на ячейку в данных калли, а не значением: `return: out` — RET отдаёт ячейку `out` (AT), `lmx_walk_leaving` копирует только скретч от ARG/CALL, и следующий вызов того же калли переписывает ту же ячейку раньше, чем сумма её прочтёт. Нативный калли копирует результат в dest по rtype | Sonnet -194 к.5b (fable): числовой результат копируется в call_dest по rtype, ссылка — только для нечислового | FIXED (F-62) — Sonnet к.5b `312a08b` (main 7634aa2); строка `unit_walk_loop` зелёная |
| D-73 | 2026-09-26, Opus -193 T4a (измерено на 939bfc8, проба `fn: first (int: a; int: b) int` / `return: a`, `first(3, 4)`: native 3, walked X1) | K-ARITY: для калли с native 0 CALL сверяет число аргументов с `lmx_walk_arg_arity` (max ARG + 1), а не с числом формалов — метод, не читающий последний формал, отказан как INVALID (X1) | Sonnet -194 к.5b (fable): арность из args-части (форма A, слот 0) | FIXED (F-63) — Sonnet к.5b `312a08b` (main 7634aa2); `unit_method_sig_distinct` зелёная под knob |
| D-74 | 2026-09-26, Opus -198 (измерено на main 939bfc8: формы гейта двойника `l2_stable_head_call_gate.ps1`) | Пустой вызов raw-door как ОПЕРАТОР отказан «unsupported body»: `c.abort()` / `c.rand()` в теле метода (`unit_head_call_c_empty_abort`, `_c_empty_rand`, `unit_c_empty_call`), тогда как значение `v: c.rand()` и оператор с аргументом `c.bogus(1)` проходят. `l2_head_is_call` не считал одно-сегментную голову вызовом: оператор проверялся как обновление поля с таким именем, и его значение из 0 полей отказывал `l2_check_fields`; `c.bogus(1)` проходил лишь потому, что `1` проверялся как значение. Допуск пустого списка аргументов для двери (`l2_check_call`) уже был, но до него не доходило | Opus | FIXED (F-64) — opus/l2src-twin-198 `8dc0273`: голова c.* — вызов во всех формах (`l2_head_is_call`, спека 6.6.6); строки `unit_head_call_c_*` (5, `translates`) и `unit_c_empty_call` (бежит, 0); корпус vs main: меняется исход только у трёх файлов с пустым вызовом, все выводы побайтно те же |
| D-75 | 2026-09-25, Opus -199 (измерено в облаке, l2trans с main `83c6820`) | Вызов через путь в walked-корне (`A\M()`, -196) не типизирован статически: `l2_rw_opty` знает только голову-метод, для `A\M` отдаёт «любой тип» (-1), и `fn: M () int` в `size_t: a1` (`a1: A\M()`) проходит перевод, а в ходе R0 walker отказывает `lmx: walk error: INVALID` (abort) — вместо located-отказа конверсии, как у `a1: M()`. Найден на `unit_throwing_callable` после того, как её merge стал шагом корня | Opus | FIXED (F-66, -199, main `e4fdb62`; машинный гейт GATE DONE `19d2180`): `l2_rw_opty` типизирует вызов через путь по методу, в который его разрешает `l2_path_kind` (как строит `l2_rw_operand`); строки `unit_root_path_call_type` (root-pending «mixed numeric types», main — abort) и `unit_root_path_call_typed` (бежит, 7) |
| D-76 | 2026-09-25, Opus D-53 (измерено в облаке, l2trans с main `e4fdb62` и с этой ветки) | Чтение поля ЧЕРЕЗ ссылку `@: T` на именованную Structure не понижается: локал `@: Model r` объявлен `@@: Lmx r` (на уровень глубже значения `(cast: (@: Lmx) …)`, которое ему присваивают), и `r\value` уходит в L1 как есть — gcc: «'r' is a pointer to pointer»; то же для формала `fn: peek (@: Model m) size_t` / `return: m\value` (`@@: Lmx l2_p0_0`, `l2_p0_0\value`) и для поля-ссылки `h\q\value` (`@: Model q` в Holder). Минимальная программа: `Model:` / `size_t: value 1U` / `end: Model`; в методе `Model: mo`, `@: Model r`, `r: @mo`, `v: r\value`. Нет ни одной строки, которая это исполняет (формал `@: T` встречается только в строках-отказах). Тот же лишний уровень — у временной чтения поля-ссылки: `h\q` читается в `@@: Lmx l2_t9` и сравнивается с `(cast: (@: Lmx) …)` — у свидетеля D-53 `unit_ns_ref_field_general` два предупреждения gcc «comparison of distinct pointer types» (флаги harness их не делают ошибкой) | Opus (транслятор; сначала норма C-типа ссылки `@: T` на Structure — значение ячейки-указателя = сама Structure, `@: Lmx`, — затем путь через ссылку) | FIXED в ветке (`steps/defect-d76.md`): `@: T` — один уровень `@: Lmx`; путь через формал, локал и поле-ссылку; строки `unit_ref_local_path` / `_formal_path` / `_field_path` (7); цепочное чтение внутри условия — вне (одношаговый читатель выражений, как и для вложенной Structure) |
| D-77 | 2026-09-25, Opus D-69 (попутно, `steps/defect-d69.md`) | Метод с результатом типа `char` (`fn: first (char: c) char`) отказывается транслятором «unknown type»: тип результата `char` не принимается там, где `char`-формал уже принимается; свидетеля нет (D-69 взял только формал). Минимальная программа: `fn: first (char: c) char` / `return: c` | Grok (транслятор, мелкое; свидетель с ненулевым результатом, инвертированная проверка) | FIXED (F-79). Голый результат `char` — код 1, та же ячейка, что у формала (`lmx_char_cell_known`). Подпись `) char`, трамплин пишет `lmx_char_rebind_known`. `unit_char_result`: `first('q')` = q, `first('z')` = z, Entry 7. Мутант без слова `char` на глубине 0 — «unknown type» на атоме char. Гейт: build 282/282 (`build/l2src/20260926_134157`), harness 444/444 (`build/l2_harness/s7char`), L3 11/11, имена 69/128. |
| D-78 | 2026-09-25, fable (измерено в облаке, main `5bc8ec7`, evidence `build/l2src_py/20260925_170013`) | `lmx_post_sweep_selftest` на Linux/gcc x86-64 компилируется и бежит, но `recycled=0`: за пять раундов `lmx_arena_take(sizeof LmxPost, POST)` после `lmx_gc_collect` ни разу не вернул прежний адрес (`checks=21 failures=1`); на Windows строка зелёная (280/280). Либо freelist домена POST зависит от ширины `long` (LLP64/LP64) или размера ячейки, либо факт «адрес повторяется» — свойство аллокатора, не ядра; тогда свидетель D-43 надо ставить на то, что он проверяет (post_init на переиспользованной ячейке), а не на равенство адресов | Grok (ядро/селфтест; измерить на POSIX через `build_l2src.py`, найти причину, свидетель без зависимости от платформы) | FIXED (F-69) — ядро не менялось. После collect адрес встроенного пула отсутствует в `arena\arrays`; `lmx_post_init` каждой ячейки — OK; `reused=` печатается и отказом не является. Мутант (`if: 1 = 1`, немедленный return в `lmx_gc_drop_arrays_in_block`) RED `checks=9 failures=1` exit 1; откат GREEN `checks=25 failures=0 reused=4 post=216` exit 0. Гейт `build/l2src/20260925_150326`. Облако снимет fable. |
| D-79 | 2026-09-25, автор (ответ на q30 / REVIEW 3f68f41 п.1; блог `LMX_blog/2026-09-25.md` «Поля данных заводит только объявление») | Транслятор заводит own-поле на каждое голое присваивание параметру (`l2_collect_asgn_body`) вместо правила модели (`CORE.md` §3, `next_core_tasks.md` §3 «Модель» п.2/п.4, `steps/code-data-split-189.md` c3c/Q29): поле заводит только объявление, первая голая запись в формал связывает его как поле, последующие пишут в ту же ячейку. Следствие: `keep(3)` в `unit_walk_nested_own` даёт 3 (запись `n: n + 1` внутри `if` ушла в новое поле тела), обязано 4; T4b класс 3 (`3f68f41`) скопировал это в walk (`l2_rw_stmt`, ветка «An assignment whose name is a field of the nested body»; `l2_rw_bound`/`l2_rw_formal_slot` с областью тела). `\[N]name` считает объявления, не присваивания (c3c) | Grok | FIXED (F-70). Ядро не менялось. Голое присваивание во вложенном теле не заводит поле этого тела: ячейка — поле метода (host 0), если в этом теле нет объявления. `l2_emit_body` / `l2_rw_leave` снимают отметку только у поля, объявленного в теле. Ветка walk «assignment whose name is a field of the nested body» снята. `keep(3)` = 4 нативно и под `--walk-methods`, Entry 7. `branch(3)` = 43: `int: n` в `if` — поле тела, после тела `n` — формал (`CORE.md` §3). `unit_arg_bind_body_scope`: scoped 77, nested 1414, Entry 7. Строки c3c (`unit_occ_arg_slots`, `unit_occ_root_named`, `unit_occ_snapshot_selector`) факты не сменили. Мутант «присваивание снова заводит own-строку в текущем теле» — exit 5, ожидался 7; откат GREEN. |
| D-80 | 2026-09-26, автор (ответ на REVIEW dd153e2 п.2; `LMX_blog/2026-09-26.md`) | **Ошибка типа, пропущенная трансляцией:** адресат `sendMessage: Ref X` — только Thread («язык типизирован. Слать письма можно только to Thread»), но транслятор проверяет у Ref лишь «это ссылка» (`l2trans.lm1`, `l2_rw_send`: `refty < 1000` → «a Ref that is not a reference»; тот же класс в `l2_msend_register` для тел методов). Письмо `m` из `receiveMessage: m` — анонимная Structure `(отправитель; X)`, статически не адрес Thread, и `sendMessage: m …` (`unit_send_ref_root_fail`) проходит трансляцию, а падает в рантайме (`lmx_service_post` → `MISSING` → `l2_send_fail` abort, D-62). Уточнение автора (2026-09-26): «у всех структур — один диапазон … не должен проходить implements так как у просто Message нет нужных полей» — проверка адресата не диапазоном адресов, а `implements` (L2 §14): Structure по Ref обязана иметь поля Thread; письмо и просто Message их не имеют. Сделать: located-отказ на трансляции, когда статический тип Ref не implements Thread (письмо из `receiveMessage`, любая пользовательская Structure); `m\sender` и ссылки на Thread проходят; Объём (автор, там же): «достаточно первого варианта» — только статическая проверка типа на трансляции; полный `implements`/admission — §7 порт по плану (`grok_next.md` §4 п.9), D-80 его не ждёт; рантайм (`lmx_service_post` → `l2_send_fail`) не меняется, его провал с типизированной программой недостижим и остаётся инвариантом. Свидетель: `unit_send_ref_root_fail` → l2trans-refuses с located-фразой; `unit_send_ref_method`, `unit_send_ref_driver_tap` (Ref = `m\sender`) по-прежнему переводятся и бегут; мутант — снять проверку типа → строка снова `send-abort`. Категория harness `send-abort` после этого без строк — оставлена для мутанта, стоящей строки нет | Grok | FIXED (F-75). Первый вариант: статическая проверка типа на трансляции, полный порт `implements` не ждался, рантайм не менялся. Адресат с типом не `@: LmxMsg` (не `m\sender`) — «a plain Message does not implement Thread». `unit_send_ref_root_fail` отказывается. `unit_send_ref_method` и `unit_send_ref_driver_tap` бегут. До проверки та же строка была `send-abort` exit 3 (harness `20260925_192542`). |
| D-81 | 2026-09-26, остаток D-20; REVIEW 3f8ea41-1 | Дверь `c.*`: явная копия с NUL для `c.puts` / `c.strcmp` над элементом `mainArgs`, без тихого каста. q31 закрыт, файл `LMX_blog/q/q31.md`. Оставшаяся работа двери — эта строка (`entry_index`, `entry_strcmp`, «L2 operation outside a method body»). Внутренние C-буферы транслятора (`l2_tok_text`, unquote, `l2_fmt_l1_string`) — не значения графа и не дефект. Значения программы (`mainArgs`, литерал письма) NUL не хранят. | Grok | FIXED. Q31 п.1: `c.puts`/`c.strcmp` перенесены в методы `printArg`/`argIsOk` (`MainLetter: letter` формалом, как `unit_charpp_return.lm2`), корень зовёт их обычным вызовом — «L2 operation outside a method body» больше не задевает эту пару. Явная копия: `@: void buf` / `buf: c.calloc(1U, n + 1U)` (zero-init даёт настоящий NUL на месте `buf[n]`, не молчаливое чтение за границей массива) + `c.memcpy(buf, @ letter\mainArgs[1][0], n)`, `n` = `length(m\mainArgs[1])` из корня (уже гейтованный путь, `entry_arg_len.lm2`). `l2_admit_implements` этот путь не обходит: `@ letter\mainArgs[1][0]` (address-of на дважды-индексированном `\`-поле внутри метода) и рантайм copy/free ранее не имели ни одного эталонного прогона — измерено здесь впервые, оба работают. Свидетель: `entry_index` argv `word` печатает `word` (Says); `entry_strcmp` argv `ok` → Entry 0. Мутант (детерминированный, не «снять +1U» — тот читает за границу и не воспроизводим): `c.memcpy(..., n - 1U)` — `entry_index` печатает `wor` (Says краснеет), `entry_strcmp` → Entry 4 вместо 0; проверено прямым прогоном вне живого дерева (l2trans→l1trans→gcc→run), не оставлено в исходниках. Побочная находка — D-84. Гейт: build 282/282 (`build/l2src/d81`), harness 447/447 (`build/l2_harness/d81e`), L3 11/11, имена 69/128, check_docs OK, git diff --check чисто. |
| D-84 | 2026-09-26, при посадке D-81 (измерено) | `l2_colon_simple_ty` (`l2trans.lm1` :5814) не распознаёт `cast:` как форму значения в узкой предпроверке `l2_colon_check_assignment` (:6196, «assignment value has unknown type»): `@: char buf` / `buf: (cast: (@: char) c.calloc(...))` отказывает этой фразой, а идентичная пара с `@@: char` (двойной указатель, `unit_sizeof_type_frame.lm2`'s `grow`, гейтована) переводится. Измерено прямым вызовом l2trans на двух минимальных пробах, отличие — только глубина указателя цели (`@:` против `@@:`). Обход в D-81 — не каст в присваивании: `@: void buf` + голый `c.calloc(...)` (естественный тип `void*`, `l2_is_known` даёт код `-10`, совместимый с любой целью через отдельный путь). Норма §0 (никаких исключений по форме) требует либо унифицировать проверку (`cast:`-обёртка над `c.*`-вызовом — такое же «numeric-only, безопасно только в числовую цель» значение, либо явный тип по операнду каста), либо задокументировать асимметрию `@:`/`@@:` как норму, а не молчаливый пробел. | ведущий | OPEN |
| D-82 | 2026-09-26, REVIEW 4812c2a-3 | «a Structure return must be a name» (`unit_s7_ret_path`) — ограничение транслятора, не норма: поле Structure — законное возвращаемое значение. Точка return не допускает (REVIEW 4812c2a-1: uses возвращаемого имени пуст). Закрыто вместе с допуском return по полному дескриптору. | Grok | FIXED. `l2_admit_return` зовёт `l2_admit_implements(cand, req, req)` для имени, переменной, результата вызова и одного поля; trailer и тело — одно правило. `unit_s7_ret_field` (`return: h\p`, поле `Rich`) Entry 7. `unit_s7_ret_path` — «implements is false in return value». Фразы «a Structure return must be a name» нет. Гейт: build 282/282 (`build/l2src/20260926_122104`), harness 440/440 (`build/l2_harness/s7ret`), L3 11/11, имена 69/128. |
| D-83 | 2026-09-26, REVIEW 2975115-3 | Отказ конвертера по диапазону (`lm_stg_convert_size_t_int`, `_int_size_t`, `_int_char`, `_unsigned_int`, тела в `l2_emit_convert_defs` `l2trans.lm1` ~:6056) реализован как `c.fprintf` + `c.abort()`: процесс гибнет, а книга §12 («range error, not zero») и §2.2.4 требуют обычный отказ приёмника, доходящий до `catch`. Причина названа ведущим (ANSWER 65dba4c-2): L1 отвергает `throw:` в методе без объявленного `throws`. Правка — канал неявного throw `merge`/`implements` (Q17) несёт отказ конвертера; свидетель — фикстура с выходом из диапазона, ожидаемый отказ, не exit по abort; мутант — тело без проверки. До закрытия §7 порт таблицы не зачтён. | ведущий | FIXED. Приёмник строки `convert.lm2` — статусный ABI: `fn: lm_stg_convert_<from>_<to> (<from>: n; @: <to> out) int`, 0 — значение записано, ненулевой ответ — отказ, ничего не записано. Ребро присваивания (`l2_convert_on_store`) пишет `if: recv(v, @ l2_cvtN) != 0` и выпускает неявный throw `convert` (`l2_implicit_name` g = 3 после `merge` = 1 и `implements` = 2; Q17 = А — имена выбирает команда). Проверочный проход (`l2_colon_check_assignment` → `l2_convert_site`) ставит методу статусный ABI, как сайт допуска; ребро без этой отметки — «internal: a conversion site was not checked». `c.fprintf`/`c.abort()` и `lmx: converter range` из тел сняты. Попутно `lm_stg_convert_ulong_unsigned` получил проверку диапазона (было молчаливое сужение). Свидетели: `unit_s7_conv_range` (size_t 3000000000U → int: Fails 1, Stopped 1, Thrown 3), `unit_s7_conv_catch` (`catch: convert ()`, int −1 → size_t: обработчик идёт, приёмник остаётся 5, Entry 7). Мутант (тела `size_t_int` и `int_size_t` без проверки диапазона): обе строки RED, откат GREEN. Гейт: build 282/282 (`build/l2src/d83`), harness 447/447 (`build/l2_harness/d83a`; мутант `d83mut` — RED 2 из 447), L3 11/11, имена 69/128. REVIEW 2975115-1 закрыт Q33: тела — L2-методы `convert_impl.lm2`, отказ — `throws: range`, ребро переводит его в `convert`. |
| D-85 | 2026-09-26, миграция VoidArray (`c955f24`), REVIEW c955f24-1 | l1trans режет путь `x\f.g` (член по значению) по точке, когда он стоит аргументом вызова: `f(a, x\array.size)` → C `f(a, x->array, ., size)`, «expected expression before '.' token»; то же в выражении-аргументе (`pad\array.size - 1U`) и в двери `c.sizeof(...)` даже в скобках. В условиях, присваиваниях и приведениях путь переводится верно. Обход в `c955f24`: аргумент в скобках — `f(a, (x\array.size))` (35 мест: ядро, тесты); `c.sizeof` поля не используется. Правка — в разборе аргументов `l1src/l1trans.lm1` (самосборка L1, перепин `L1_PIN.txt`); свидетель — L1-юнит с `f(x\a.b)` без скобок, мутант — прежний разбор. | ведущий | OPEN |
| D-86 | 2026-09-26, при посадке §7a (`9a32087`), fable_pc замечание | Не дефект транслятора — граница инструмента, зафиксирована здесь, чтобы не потеряться за галочкой §7a: `tools/l2_harness.ps1`'s `eternal-runs` link-шаг линкует ровно `<fixture>.o` + `l2_eternal_driver.o` + `l2_libc.o` — нет способа добавить в этот link ещё один отдельно переведённый L2/L1-объект. Значит ни одна L2-«библиотека» (общий код, вызываемый из нескольких `.lm2`-юнитов через `predef:`) не может быть реально исполнена в harness — только `translates`/`root-pending`/`l2trans-refuses`, никогда `eternal-runs`. Тот же пробел вызвал провал `lm_own_copy_bytes`/`lm_own_delete` в D-81 (пришлось перейти на `c.calloc`/`c.memcpy` внутри одного юнита) и держит `l2_puts` (`unit_l2_puts_library.lm2`, §7a) внутри одного файла вместо отдельной библиотеки. Правка — либо новый параметр гейта (доп. `.o` на строку), либо отдельная сборка библиотечных `.lm1`/`.o` в `build_l2src.ps1` с последующей передачей их пути(ей) в `l2_harness.ps1`. | ведущий | OPEN |
| D-87 | 2026-09-26, §GATE-замер «нет скрытого fallback» (`steps/gate-fallback-audit-20260926.md`) | `l2trans.lm1` :16077–:16094 `l2_hidden_from`: порождённый код при отсутствующей ячейке делает `return: 0` — молчаливый успех; тот же класс снят D-05/F-30 в `l2_emit_path_load` (:23226–:23229), здесь — нет. Правка: `l2_emit_invariant`. | ведущий | FIXED. Порождённый код при отсутствующей ячейке — `l2_emit_invariant("a dynamic input has no cell to read")`, как D-05. Путь не достигается ни одной из 671 фикстуры корпуса (вывод побайтно тот же в обоих режимах), поэтому свидетеля-фикстуры нет. Гейт: build 283/283 (`build/l2src/d89`, 103 селфтеста ran, exit 0), harness 452/452 (`build/l2_harness/d89`), L3 11/11, check_docs OK. |
| D-88 | 2026-09-26, §GATE-замер «нет скрытого fallback» (`steps/gate-fallback-audit-20260926.md`) | `l2trans.lm1` :4933–:4934 `l2_predef_file_result_ty`: нечитаемый тип результата прототипа predef становится `-10` (класс числового литерала), и `l2_colon_types_compatible` принимает его в любую числовую цель без строки `convert.lm2`. Противоречит :5906–:5910. Правка: отказ «unknown type» у прототипа; свидетель — predef с нечитаемым типом результата. | ведущий | FIXED. Прототип `fn` с нечитаемым типом результата — код 2 из `l2_predef_file_result_ty`, `l2_colon_simple_ty` отказывает «assignment value has unknown type»; `sub` — код void (8); `-10` остаётся только для головы `c.*` без прототипа. Замер: подстановка `-10` на этом пути не достигалась — прежний транслятор отказывал раньше и менее точно («unsupported body» у вызова). Свидетель `unit_predef_result_unknown_refused` (своя фраза, прежняя — другая). Гейт: build 283/283 (`build/l2src/d89`, 103 селфтеста ran, exit 0), harness 452/452 (`build/l2_harness/d89`), L3 11/11, check_docs OK. |
| D-89 | 2026-09-26, §GATE-замер «нет скрытого fallback» (`steps/gate-fallback-audit-20260926.md`) | `l2trans.lm1` :12480–:12483 и :24076–:24078: запись литерала по пути в `size_t`/`unsigned`/`ulong` без проверки диапазона — `l2_literal_value` даёт `0U` на переполнении или нецифре (:8921–:8925), а `l2_colon_check_assignment` для головы-пути уходит раньше :6352. Вероятный тихий 0 (не подтверждён). Правка: проверка диапазона перед записью; свидетель — фикстура с переполнением. | ведущий | FIXED. `l2_path_rhs_range` перед записью литерала по пути в поле `size_t`/`unsigned`/`ulong` зовёт `l2_check_literal_kind`. Свидетель `unit_path_lit_overflow_refused` — «literal not representable as size_t»; мутант — транслятор до правки: принимает, пишет `lmx_size_store_known(l2_pxp[0], 0U)`. Место :24076 (литералы тела `merge:`) — другой механизм, не измерено. Гейт: build 283/283 (`build/l2src/d89`, 103 селфтеста ran, exit 0), harness 452/452 (`build/l2_harness/d89`), L3 11/11, check_docs OK. |
| D-90 | 2026-09-26, §GATE-замер «нет скрытого fallback» (`steps/gate-fallback-audit-20260926.md`) | `lmx_thread.lm1` :558–:560: в режиме статуса `LMX_CALL_NOT_CALLABLE` превращается в `LMX_TURN_BODY_OK`; код 2 совпадает с `LMX_INTERP_NO_GRAPH` и может совпасть с int-результатом нативного входа (`lmx_call.lm1` :142). Правка: отказ вместо OK; свидетель — селфтест хода с невызываемым телом.  **Разбор (Opus):** в режиме статуса (`lmx_call_install_walk_status`, только привязка L3) `lmx_call0` уходит в обходчик для графа без нативного слова, и L3-обходчик кода 2 не даёт; значит ветка ловит лишь нативное значение 2 или `LMX_INTERP_NO_GRAPH` (тоже 2). Главная неточность шире: в режиме статуса ЛЮБОЕ значение нативного входа читается как статус хода, вопреки модели 31 («ответ нативного обработчика — его дело»); у L3-потока нативного графа на практике нет. Правка — различать нативный путь и путь обходчика в режиме статуса; нужна норма «пустой ход» для `NO_GRAPH`. **Ответ автора (q35, 2026-09-27, `LMX_blog/2026-09-27.md`):** статуса хода из значения графа нет — «success» выставляет пользовательский код, ядро само не выставляет; нативный или нет — разницы нет, интерпретатор должен работать; корень — Structure без аргументов и возвращаемого значения — вызывается на каждый turn, как runnable, во всех прочих случаях исполнение вызывает только входящий message (`post`). Правка — по этому ответу. **Исправлено (Opus, 2026-09-27, срез A записки `steps/turn-runnable-q35.md`):** в режиме статуса ход возвращает ответ крюка обходчика только для графа без нативного слова (вердикт интерпретатора, не значение графа); у графа с нативным словом значение обработчика не читается ни в каком режиме, провал — канал броска; ветка «2 → OK» снята. Свидетель — `l3_thread_bind_selftest`: нативное слово графа под привязкой L3 возвращает значение 1 и 2 — оба хода OK; мутант — прежний `lmx_thread.lm1` (блоб `b55b1e9`) — «a native handler's value 1 is not the turn's status» красна (1 из 39). Корень-runnable и E1 у L3 — вопрос q40. | ведущий | FIXED |
| D-91 | 2026-09-26, срез `02b917c` (замер `l1trans`), REVIEW 02b917c-2 | `l1trans` принимает `const: []: char name 2 34 0` и выпускает неверный C `const [] char = name 2 34 0;` вместо отказа; константный ряд пишется строкой `[]:` в блоке `immutable:`. Правка — разбор `const:` в `l1src/l1trans.lm1` (отказ или верная форма) с перепином; свидетель — L1-юнит с этой строкой.  Делать вместе с частью C §7a (снятие опоры `c.array` из `l1trans`, после q34) — один перепин. | ведущий | OPEN |
| D-92 | 2026-09-26, Opus, остаток §7 «`return` вложенного callable» (замер T6 `ceaa0f6c`) | `l2trans.lm1` `l2_emit_body_in`: у хозяина `return: model` всё тело заменялось построением узла (`l2_mad_emit`), операторы хозяина молча не выпускались. `fn: makeAdder (int: n) …` / `n: n + 1` / `fn: addN …` / `return: addN`: в выпуске нет `n: n + 1`, в узел пишется машинный аргумент `l2_p0_0` — `makeAdder 4` дал бы `add5: 1` = 5 вместо 6; оператор после `return`, вызов вложенного метода и `return` внутри оператора хозяина тоже молча отбрасывались. | ведущий | FIXED. `l2_mad_host_body`: операторы хозяина выпускаются по порядку до построения; точка возврата — оператор `return: model`, иначе хвост метода/сигнатуры, иначе поле самой модели (P0 вешает `return: model` хвостом на её фрейм); оператор после возврата, оператор, называющий вложенный метод (его нативное тело — `return: 0`), и `return` внутри оператора — located-отказы. Захват — значение имени в точке возврата. Свидетели `unit_make_adder_activation` (Entry 7) и три отказа `unit_make_adder_*_refused`, которые прежний транслятор принимал. Мутанты по копии (`build/t6b_m*`, байты в staging сверены с мутантными): тело хозяина заменено построением (D-92 назад) — `activation` exit 0 вместо 7, четыре отказа приняты; формал как машинный аргумент — `activation` exit 0; упоминание без голов фреймов — `model_call` и `nested_call` приняты; значение захвата через `int` при size_t-ячейке — `size_t` exit 0 (пины целы). Перенос всех формалов поведением не наблюдается — его держит пин ширины `5U`. Гейт: build 283/283 (103 селфтеста запущены, exit 0; `build/l2src/20260926_205918` в копии), harness 461/461 (`build/l2_harness/t6b2`), L3 11/11, check_docs OK. |
| D-93 | 2026-09-27, REVIEW ffdcde0-1 | «a callable merge host names a nested method outside the return» (`unit_make_adder_nested_call_refused`, `unit_make_adder_model_call_refused`) — ограничение транслятора, не норма: вложенный метод — обычный метод языка, хозяин вправе позвать его до возврата. Отказ стоит потому, что вложенный метод обходится, а его нативная функция — заглушка `return: 0` (`l2_emit_body_in`, ветка `l2_mad_host_of`); без отказа вызов молча дал бы 0. Снимается, когда вызов вложенного метода из хозяина идёт обходом (или у метода есть настоящее нативное тело).  **Сделано наполовину (Opus, 2026-09-27):** вложенный метод, который ничего не захватывает у хозяина (`l2_mcap_count` = 0), — обычный метод с собственным нативным телом (заглушка `return: 0` — только у захватывающих), и хозяин зовёт его до возврата (`l2_mad_names_nested` отказывает лишь захватывающим); фикстура `unit_make_adder_nested_call_refused` стала `unit_make_adder_nested_plain_call` (Entry 7, оба режима); у модели без захватов вместо заглушки теперь её тело (`unit_make_adder_no_capture`: `return: 0` → `return: l2_p1_0 + 6`; узел по-прежнему обходится). Мутант (одиночный фикстур, источник по хешу): заглушка у всех вложенных — нативный двойник `unit_make_adder_nested_plain_call_native` даёт k = 0, exit 1 (под knob хозяин и `twice` обходятся, заглушка не исполняется — поэтому двойник). Гейт на `e8b8a8d`: 279/279 (103 ran), harness 525/525, L3 11/11. **Остаток:** вызов захватывающего вложенного метода (модели) до возврата — `unit_make_adder_model_call_refused`; снимается построением узла с текущими захватами и динамическим вызовом (как `return` + вызов).  **Вызов модели сделан (Opus, 2026-09-27):** вызов захватывающей модели в теле хозяина до возврата строит узел, который построил бы возврат, из значений хозяина в точке вызова (захват в модели только читается, поэтому такой узел — ровно то, что хозяин там видит), и зовёт его: нативно — `lmx_call_prim` с узлом как кодом и данными (`l2_mad_emit_into`, локали вызова с суффиксом `_c<t>`; текст возврата прежний), под knob — `l2_mad_call` над PRIM-построением модели (`l2_rw_mad_build`, общим с возвратом; один числовой вход и int-результат, иначе хозяин тихо остаётся нативным). Попутно найдено и исправлено: `return: model` отдельным оператором тела после других операторов (не висящий на кадре модели) проверка разбирала как вызов модели и отказывала «incompatible entry signature» (так же и транслятор до этого коммита) — теперь пропускается, как кадр `fn:`. Свидетели: `unit_make_adder_model_call` (q 6, r 16, n 22 → 23; Entry 7) и `unit_walk_make_adder_model_call` (тот же текст под knob, первый вызов до определения модели — форма бывшего `unit_make_adder_model_call_refused`; он удалён, его текст теперь бежит в обоих режимах: add5(1) = 6). Мутанты (конвейер одиночного фикстура, копии этого l2trans в скретчпаде `d93rm`): нативный вызов через заглушку модели — 1 вместо 23, exit 1; узел вызова без захвата — «walk error: INVALID», exit 3; под knob вызов как обычный вызов модели (её вхождение, без узла) — INVALID, exit 3; каждый красен только в своём режиме. Корпус (`0acac58` против среза, оба режима): 729 × 2 — 1454 из 1458 равны, 4 разницы — два новых свидетеля (раньше отказ). Гейт в копии `build/opus_wt` на `0acac58`: build_l2src -Run 279/279, 103 селфтеста ran, exit 0 (`build/l2src/d93r`); l2_harness 529/529 (`build/l2_harness/d93r`, summary.txt: стейдж `977fa40` = блоб коммита, verdict 529/0); L3 11/11; check_docs OK; git diff --check чисто. **Остаток:** захватывающий вложенный метод, который не модель: его узел не строит никакой возврат, вызов — located-отказ (`unit_make_adder_helper_call_refused`).  **Закрыт (Opus, 2026-09-27):** захватывающий вложенный метод, который не модель, зовётся так же — вызов строит ЕГО узел (его захваты, его кадры и арность; `l2_mad_emit_into(mi, nk, …)`, `l2_rw_mad_build(mi, nk, …)`) из значений хозяина в точке вызова; под knob — свой конструктор `l2_mad_construct_<хозяин>_<метод>` (у модели имя прежнее); допуск — `l2_mad_nested_call`. Корпус: у всех прежних фикстур текст тот же. Свидетели: `unit_make_adder_helper_call` (бывший `_helper_call_refused`: helper захватывает n и m, модель — q; 5·10 + 2 + 1 = 53 = q, add(1) = 54; Entry 7) и `unit_walk_make_adder_helper_call` (под knob, хозяин обходится). Отказ «names a nested method outside the return» остаётся стражем эмиттера: упоминание значением проверка отказывает раньше (голый атом — нуль-арный вызов, «incompatible entry signature»), у T7-хозяина вложенных методов нет. Мутанты (копии этого l2trans в скретчпаде `d93hm`, конвейер одиночного фикстура): вызов helper нативно строит узел модели — gcc отказывает («q undeclared»: захват модели ещё не объявлен в точке вызова); допуск только модели — оба свидетеля снова отказ; узел helper под knob строит конструктор модели — «a callable merge construct was called outside its header», exit 3 (первый свидетель с формами одного размера этот мутант пропускал — свидетель изменён так, чтобы формы узлов различались). Корпус (`9962b8c` против среза, оба режима): 735 × 2 — 1466 из 1470 равны, 4 — два свидетеля (раньше отказ). Гейт в копии `build/opus_wt` на `9962b8c`: build_l2src -Run 279/279, 103 селфтеста ran, exit 0 (`build/l2src/d93h`); l2_harness 535/535 (`build/l2_harness/d93h`, стейдж `cd4998a` = блоб коммита, verdict 535/0); L3 11/11; check_docs OK; git diff --check чисто. | ведущий | FIXED |
| D-94 | 2026-09-27, REVIEW ffdcde0-1 | «a callable merge host returns outside its model» (`unit_make_adder_early_return_refused`) и «a statement after the return of a callable merge» (`unit_make_adder_after_return_refused`) — ограничение транслятора, не норма: у хозяина один выход — построение узла. Ранний `return: 0` у метода с callable-результатом по языку — ошибка типа результата и должен отказываться так, а не этой фразой; возврат другого вложенного callable по условию — граница (узел строится для одной модели); оператор после возврата в обычном методе выпускается как мёртвый код.  **Сделано (Opus, 2026-09-27), две части из трёх:** оператор после возврата хозяина — мёртвый код: проверяется и не выпускается ни в нативе, ни в плане обхода (`l2_mad_return_point`; первая версия `e8b8a8d` выпускала его после построения — под knob обход строил хвост ДО трейлерного построения узла, и вызов или `return` в хвосте ломали прогон — находка fable_pc, REVIEW e8b8a8d; фикстура переименована в `unit_make_adder_after_return_dead`, Entry 6, в обоих режимах); `return: 0` у метода с callable-результатом — ошибка типа результата, «a callable result returns a number» (`l2_mad_returns_number`: литерал или именованный числовой тип в `return` тела или трейлера). Мутанты (одиночные фикстуры, оба режима, источники по хешу): прежний отказ — `_after_return_dead` отказан; без проверки числа — прежняя фраза, needle `_early_return` красный. Корпус (`408c1e6` против правки, оба режима): 720 × 2 — 1436 из 1440 равны, разницы — только эти два фикстура. Гейт на `408c1e6`: 279/279 (103 ran), harness 520/520, L3 11/11. **Остаток:** возврат другой вложенной модели по условию — граница (узел строится для одной модели), сегодня отказ фразой D-93. | ведущий | OPEN |
| D-95 | 2026-09-27, Opus, §7a «L1 `c.array`» (перевод `l1src`) | `l1trans` принимает протяжённость ряда `[]:` вида `c.NAME` и выпускает её дословно: `[]: char buf c.BUFSIZ` → `char buf[c.BUFSIZ];` — неверный C (`l1src/l1trans.lm1` `l1_emit_bracket_array`, запись протяжённости `l1_write_text`). Форма `c.array: [c.NAME]: …` снимает `c.` (`l1_write_bracket_extent`), поэтому три строки `parser.lm1` (`delimiter_*_stack`, ×4 копии) пока остаются `c.array:`. Правка — протяжённость `c.NAME` пишется как C-имя NAME; затем самосборка, новые семена `lm1/build`, пересборка и перепин `bin/l1trans.exe` (им harness переводит копию парсера), затем перевод трёх строк. Свидетель — L1-юнит с `[]: … c.NAME`. | ведущий | FIXED. `l1_emit_bracket_array` пишет протяжённость `c.NAME` как C-имя NAME (как `l1_write_bracket_extent` у `c.array: [c.NAME]:`). Самосборка — неподвижная точка 8/8, новое семя `lm1/build/l1trans.lm1.c`, `bin/l1trans.exe` пересобран строкой gcc самосборки (masked PE = B2 самосборки), L1_PIN `AC4A2210…` → `601D350E…`. Свидетель — три строки `delimiter_*_stack` в четырёх копиях `parser.lm1`, теперь `[]:` с протяжённостью `c.LM_P0_LAYOUT_DELIMITER_STACK_LIMIT`. Мутант — прежний пин (`AC4A2210…`) через `-Translator` на новом дереве: harness RED, «l2trans itself did not build» (gcc: `c` undeclared на `[c.LM_P0_LAYOUT_DELIMITER_STACK_LIMIT]`). Выпуск C старым и новым `l1trans` по отслеживаемым `.lm1` (на `7bb8962` их 981; счёт 987 снят до перебазирования на `5c1e6e4` — минус шесть заголовков-сирот, REVIEW 7bb8962-2): остальные равны, 9 различаются ровно тремя объявлениями `delimiter_*_stack` (четыре копии парсера и `printTree` ×2, `l1trans`, `l2trans` ×2, которые его подключают). Самосборка (`tools/run_self_build.ps1`, `build/self_build/b2_final`) PASS 8/8, рабочее семя = неподвижной точке. Гейт в копии `build/opus_wt`: build 277/277 (103 селфтеста ran, exit 0, пин совпадает), harness 479/479 (`build/l2_harness/b2`), L3 11/11, check_docs OK. |
| D-96 | 2026-09-27, Sonnet, G4 (`entry_puts_triple_fence4.lm2`) | Тройная кавычка `"""…"""` с РОВНО четырьмя кавычками на обеих границах (`""""hello""""`) отказывает P0 «unterminated python-like string literal», хотя источник спеке не противоречит: `docs/LMX_grammar.en.md` :413,433–435 («Quote-run shortening…», «four quotes produce three») прямо разрешает ряд из четырёх кавычек как данные внутри уже открытой тройной строки — измерено отдельной пробой (`c.puts("""hello\nfour quotes mid-string: """"\nstill text""")`), тот же ряд ВНУТРИ строки переводится нормально (доходит до семантической проверки). Отдельно измерено: `""""hello"""` (4 открывающих / 3 закрывающих) тоже переводится нормально (`entry_puts_triple_lead.lm2`, гейтована). Отказывает именно симметричный случай — 4 закрывающих кавычки, ничего не следует после них. Правка — в P0-лексере тройной строки (три копии парсера, как обычно для этого класса). Свидетель — harness-строка `entry_puts_triple_fence4.lm2` (пин дефекта D-96, не нормы). | ведущий | OPEN |
| D-97 | 2026-09-27, Opus, §GATE G2c (проба) | Путь `p\x` у формала-указателя на примитив выпускается как доступ к члену C без проверки: `fn: f (@: size_t p) size_t` / `return: p\length` → `return: l2_p0_0\length`, `size_t: r (p\whatever)` → `(l2_p0_0\whatever)`. Транслятор принимает, неверный C ловит только gcc. Так было и до G2c (таблица членов `l2_raw_path` тут ни при чём): путь с корнем-формалом, который не открыт двери `c.*`, уходит в выпуск пути дословно. Правка — located-отказ «unknown field path root» (как у слота, `q\data`); свидетель — строка-отказ с этой пробой.  **Шире (fable_pc, REVIEW 284b007-3):** та же дословная эмиссия у корня-слота (`@: char q` / `return: q\data` → `return: l2_s0_0\data`) и корня-local (`@: char q 0` → `return: q\data`), в обоих трансляторах; три рода корня — формал, слот, local — место правки одно (дословный запас диспетчера путей). | ведущий | FIXED. `l2_check_fields`: путь у формала без Structure-типа — `l2_path_root` признаёт любой формал корнем (ветка D-28) и проверка кончалась «принято», хотя D-28 обещает для такого формала located-отказ; теперь формал-корень с `cpni < 0`, не открытый дверью `c.*`, — «unknown field path root». Путь у слота и у local метода, который не приняли ни `l2_field_path_check`, ни `l2_raw_path`, — тот же отказ. Свидетели — `unit_path_formal_primitive_refused`, `unit_path_slot_primitive_refused`, `unit_path_local_primitive_refused`. Корпус (`f5d83b4` против среза): `tests/*.lm2` 679 × 2 — 1358 из 1358 побайтно; `.lm2` верхнего уровня 21 × 2 — 0 различий. Мутант по копии (`build/d97_m1`, в staging — `l2trans.lm1` базы `cf6c7cfd…`): все три строки RED, «l2trans ACCEPTED a fixture that must be refused». Гейт в копии `build/opus_wt`: build 277/277 (103 селфтеста ran, exit 0), harness 482/482 (`build/l2_harness/d97`), L3 11/11, check_docs OK. |
| D-98 | 2026-09-27, Sonnet, снятие сирот-заголовков парсер-портов | `tools/build_l2src.ps1` с ОТНОСИТЕЛЬНЫМ `-OutDir` даёт ложный отказ «no kernel headers under the resolved source dir», хотя стейджинг прошёл верно (перепроверено: файлы на диске). Причина: `Set-Location $sourceBase` (:173) меняет текущий каталог ДО проверки `lmx.h.lm1` (:450); `Join-Path $sourceDir 'lmx.h.lm1'` с тем же относительным `$sourceDir` резолвится PowerShell'ом от НОВОГО текущего каталога, не от каталога запуска, — путь удваивается, проверка не находит уже существующий файл. Абсолютный `-OutDir` не подвержен (проверено — гейт зелёный: build 277/277, harness 479/479). Правка — либо резолвить `$OutDir`/`$sourceDir`/`$sourceBase` в абсолютный путь в начале скрипта (`Resolve-Path`/`Join-Path $root` до первого `Set-Location`), либо не менять текущий каталог вовсе. Свидетель — любой вызов с относительным `-OutDir` (воспроизводится 100%, не перемежающийся). | ведущий | FIXED (Opus). `-OutDir` приводится к абсолютному пути сразу после значения по умолчанию, от каталога вызова (`[System.IO.Path]::Combine` + `GetFullPath`; `Join-Path` склеил бы и абсолютный путь). Воспроизведение прежним скриптом: `-OutDir build\l2src\d98_old` — «no kernel headers under the resolved source dir: build\l2src\d98_old\src\l2src». Проверка: тот же вызов с `-OutDir build\l2src\d98_rel` — build_l2src -Run GREEN 277/277, 103 селфтеста ran, exit 0. Правка касается только `tools/build_l2src.ps1`; harness и L3 его не используют. |
| D-99 | 2026-09-27, REVIEW 7bb8962-1 | `L1_PIN.txt` пинует сырой sha256 `bin/l1trans.exe` (`tools/build_l2src.ps1` :4, :68) — это пин секунды сборки, а не кода: две сборки одного C различаются полями TimeDateStamp/CheckSum заголовка PE, и проверка пина пройдёт только у побайтной копии. Маскированная идентичность уже считается (`tools/l2_harness.ps1 -PeInfo`, `masked_sha256`). Решить при следующем перепине, что пинует `L1_PIN.txt` (маскированный хэш, или сырой + маскированный), и перевести проверку `build_l2src`. | ведущий | OPEN |
| D-100 | 2026-09-27, Opus, K29 (проба) | `l1trans` принимает в `enum:` значение из нескольких токенов и выпускает неверный C вместо отказа: `PROBE_MSG PROBE_BASE + 29` → `PROBE_MSG = PROBE_BASE,` и `+ = 29` отдельной строкой. Класс D-91 (принимает и выпускает мусор). Правка — отказ «an enum value is one literal» (или выражение целиком) в `l1src/l1trans.lm1`, с перепином; делать вместе с D-91 и частью C §7a (один перепин); после правки `LMX_TYPE_MSG_REF` в `lmx.h.lm1` станет `LMX_TYPE_POINTER_BASE + 29` в одном месте вместо литерала 1053. Свидетель — L1-проба с таким значением. | ведущий | OPEN |
| D-101 | 2026-09-27, Opus, срез 1 порта `implements` (проба) | Метод с формалом-именованной Structure, переданный как callable-фактический, валит трансляцию без located-диагностики («translation failed with no located diagnostic»): `Box:` с `int: v`, `fn: boxTo (Box: b) int` без тела, `fn: peek (Box: b) int`, `fn: applyBox (boxTo: op; int: b) int`, вызов `applyBox(peek, 7)` — из корня или из метода; тело `applyBox` не важно (падает и с `return: b`). Причина: `l2_emit_public_sig` (прототип метода, отмеченного `l2_m_value_used`, в блоке `prototype:`) читает `l2_ft` сырым, а объявленный граф-формал хранится как `dt_of_own(1000+foreign)` — `l2_emit_foreign_named` получает индекс вне таблицы и возвращает 1 без `l2_error`. Класс -137 ч.2: для результата это исправил `l2_sig_ret`, для формалов сигнатуры — `l2_emit_formal`; результат здесь тоже читается сырым (`l2_m_ret[mi] >= 100`). Вне библиотечного режима у этого прототипа нет тела — мёртвый текст (в `unit_cf_call_args` строка `fn: inc (int: x) int` ни на что не ссылается). Правка — либо восстановить тип как `l2_emit_formal`/`l2_sig_ret` и сделать отказ `l2_emit_foreign_*` located, либо не выпускать прототип вне библиотечного режима (меняет L1 каждого фикстура с callable-фактическим). Воспроизводится на `9327b65` и `d456aff` (до среза 1). Свидетель — эта проба как строка harness.  **Исправлено (Opus):** `l2_emit_public_sig` восстанавливает тип формала как `l2_emit_formal`, результат читает через `l2_sig_ret`; свидетель `unit_d101_struct_formal_value` (Entry 7, пин прототипа `fn: peek (@: Lmx b) int`). | ведущий | FIXED |
| D-102 | 2026-09-27, Opus, свидетель D-101 | Путь через формал-Structure (`return: b\v`) в единице без own-поля: l2trans принимает, gcc отказывает — «l2_xp undeclared». Путь читает ячейку в `l2_xp` (`l2_xp: l2_pxp`), а `l2_xp` объявлялся только при own-поле, динамическом входе или `for` в единице, тогда как `l2_pst`/`l2_pxp` — по своему условию (`l2_ns_n`, `l2_mres_n`, `l2_uses_node_for_root`). Класс D-91 (принимает и выпускает то, что не компилируется). **Исправлено (Opus):** `l2_xp` объявляется и по условию временных пути; корпус — только добавленная строка `@@: void l2_xp 0` в восьми прежних фикстурах. Свидетель `unit_d102_formal_path_no_own` (Entry 7). | ведущий | FIXED |
| D-103 | 2026-09-27, Opus, свидетель заметки REVIEW c953b22 | Хозяин callable-merge, который может бросить (здесь объявление `size_t: big (n)` требует преобразования, а его получатель бросает), — метод с ABI объявленного броска: его возврат — статус, результат — через `l2_out_result`. Построение узла писало `return: (cast: (@: void) l2_mad)` — узел возвращался как статус (gcc: «returning 'void *' from a function with return type 'int'»), вызывающий принимал адрес за номер броска: «lmx: walk error: unknown status», exit 3; l2trans принимал. Так и в `c953b22`. **Исправлено (Opus, 2026-09-27):** у такого хозяина построение кончается `l2_out_result[0]: (cast: (@: void) l2_mad)` / `return: 0`, как у любого бросающего метода (`l2_mad_emit_into`). Свидетель — `unit_make_adder_throwing_host` (натив, add5(1) = 6); под knob тот же текст — `unit_walk_make_adder_native_note` (хозяин нативен, заметка). Мутант: узел снова как статус — unknown status, exit 3. PAP-хозяин (T7, `l2_t7_write`) пишет тот же `return:`, но бросить не может (Opus, 2026-09-27, пробы): оператор перед `return: merge(...)` (`size_t: big (k)`) и `throws:` в голове отказываются одинаково — «a callable merge host returns outside its model»; правка там была бы кодом без свидетеля. | ведущий | FIXED |
| D-104 | 2026-09-27, Opus, сборка printTree для §2 :179 | `dev/l2src_sandbox/l1src/parser.lm1` (копия парсера, которой транслятор L2 разбирает программы) пользуется `LM_P0_FRAME_DELIMITER_CLOSED` (16U) и `LM_P0_TRAILER_DELIMITER_CLOSED` (4U), а её `p0.h.lm1` их не определяет (только `LM_P0_FRAME_SEPARATOR_CLOSED`); их определяют ручной `p0.h` рядом и `lm1/build/l1src/p0.lm1.h` семени. Сборка `l2trans` зелёная потому, что C транслятора компилируется с `-I lm1/build` и `#include "l1src/p0.lm1.h"` берёт заголовок СЕМЕНИ, не копии песочницы: парсер собран не со своим заголовком (та же форма, что «сборка mixa видит два ABI ядра»). Отдельный printTree над копией песочницы не компилируется без `-D` этих двух констант. **Исправлено (Opus, 2026-09-27):** обе константы — в `dev/l2src_sandbox/l1src/p0.h.lm1` на тех же местах, заголовок теперь байт-в-байт равен `l1src/p0.h.lm1`. Ограда — строка `gate:p0_header` в `build_l2src` (`tools/gate_p0_header.ps1`): каждая `c.LM_P0_*`, которую пишут `l1src` песочницы и `l2trans`, определена её заголовком, и каждое его значение равно значению в `lm1/build/l1src/p0.lm1.h` — заголовке, с которым C транслятора собирается; так сборка с заголовком семени — сборка со своими значениями. Красна на дереве до правки (две константы) и на копиях с изменённым значением и снятым `define:`. Порядок `-I` не менялся. | ведущий | FIXED |
| D-105 | 2026-09-27, Opus, по REVIEW 3e4c9a0 (п. 2 fable_pc), проба | Значение, допущенное в формал Structure-типа аналитически — по именам, — читается индексами модели. `Model` (`size_t: a 1U`, `size_t: b 2U`), `Other` (`size_t: b 20U`, `size_t: a 10U`), `fn: rd (Model: m) size_t` / `return: m\a`; нативный метод `go` с локальным `Other: o` и `return: rd(o)` транслируется в обоих режимах, вызов в L1 — `l2_m0(l2_c0\parent, l2_c0, (cast: (@: Lmx) l2_q2_from[0]))`: допуска в ходе нет, и `m\a` читает слот 0 модели — у `Other` это `b`. Замер: `got` = 20, exit 5 в обоих режимах (контроль с полями `Other` в порядке модели — 10, exit 7). Книга :733: «Перестановка различно названных полей при сохранении путей не меняет результат»; ядро (`lmx_implements.h.lm1` :125): «names are absent from ordinary execution», путь — индексный. Другие двери в поле `Model` сегодня закрыты: присваивание значения другого типа — «graph assignment admission requires receiving-expression tests», передача из корня — «root operation not walkable yet: an admission to a Structure type», запись поля единицы из метода — «assignment value has incompatible type». Пробы — скретчпад Opus `nse5/perm_*.lm2`. Решение — за автором (`LMX_blog/q/current/q39.md`); связано с §7 «Устранить обход admission в own/local/formal/primitive fast paths». **Ответ автора Q39 (2026-09-27):** таблица преобразования индексов при `implements`, «сначала в интерпретаторе и потом нативно». **Срез 1 — интерпретатор (Opus, 2026-09-27, `steps/d105-index-table.md` §5):** обходимый корень передаёт значение другого именованного типа в формал обходимого метода (`--walk-methods`) через `lmx_walk_admit_as` с таблицей по именам; реестр `implements` арены (`LmxArena.impl`) держит соответствие (значение, тип) → таблица; `OF`/`PUT_OF` через такой формал несут тип и берут слот из записи, значение без записи — X1; своё значение допускается в тот же формал без таблицы; запись снимается в том же проходе сборки или `revert`, что и её значение. Свидетели: `unit_walk_d105_perm` (Entry 7), `unit_d105_perm_native` и `unit_walk_d105_nested` (отказы), `lmx_implements_table_selftest`. **Остаётся — нативный путь, тихое чтение слотов модели (скрытый fallback, §GATE):** нативный метод, передающий значение другого типа в формал Structure-типа (`go` → `rd(o)` в пробе `perm_formal2`), по-прежнему транслируется и читает слоты модели в обоих режимах (20 вместо 10); место вызова в обходимом методе отказывает, и метод остаётся нативным — тем же путём; из обходимого корня в нативного вызываемого — located-отказ «an admission to a Structure type». Закрывает нативный срез (вызов ядра при передаче, доступ к полю такого формала через ядро). **Учёт REVIEW ceba111 (fable_pc):** ключ записи — пара (значение, тип), а свидетеля «одно значение допущено в два типа» (две записи на один адрес) в селфтесте нет; `lmx_implements_find` — линейный проход по записям арены; значение без статического именованного типа (письмо, пустая Structure) допускается в отмеченный формал обычным индексным обходом (`table` = null) — тем же, что и своё. **Нативный срез 2a (Opus, 2026-09-28, `steps/d105-native.md` §4):** аргументы и передача дальше — нативно: формалы, до которых доходит другой тип, отмечаются до неподвижной точки, место вызова записывает значение с таблицей пары типов из графа единицы, поле отмеченного формала читается по слоту записи; корень передаёт допущенное значение нативному вызываемому. Остаётся дорога результата (метод Structure-типа, возвращающий значение другого типа, — вызывающий читает слотами типа результата). **Срез 2b (Opus, 2026-09-28, `steps/d105-native.md` §5):** результат — место, как формал; `return:` отмеченного результата записывает значение, результат вызова, переданный дальше, выбирает пару по записи; тип по ребру в результат допускается по всем полям. **Захват 738 (Opus, 2026-09-28, `steps/capture-738.md` §5):** таблицу с ячейками «не перенесено» (`SIZE_MAX`) строит только захват (`lmx_walk_capture`, инвариант у прототипа `lmx_implements_through`); тяжёлая проверка такую ячейку пропускает, `lmx_implements_slot` на ней отказывает (пин — `lmx_implements_table_selftest`); запись держит таблицу, пока её значение достигнуто (`lmx_gc_mark_impl` в `lmx_gc_mark`; свидетель — `lmx_gc_selftest`). | автор (q39), §7 | FIXED (срез 1 — интерпретатор; нативно — аргументы, передача дальше, захват — `steps/d105-native.md` §4; результаты — §5) |
| D-106 | 2026-09-27, Opus, по REVIEW eb60712 (P42 fable_pc: строка сосуществования), проба | Метод единицы затенял одноимённый вызываемый формал: в `fn: apply (op(fn: (int: x) int) int(value)) int` при методе верхнего уровня `op` вызов `op(value)` в теле `apply` разрешался в метод — `l2_check_primary`, `l2_frame_void_call` и `l2_prep` спрашивали `l2_head_method`/`l2_find_method` раньше `l2_formal_find`; при методе той же сигнатуры, что у формала, метод вызывался молча (L1 P42 fable_pc: `l2_m0(...)` вместо формала), при другой — отказ у вызова. Исправлено: формал — внутреннее имя; `l2_call_head_method` / `l2_head_is_method_call` спрашивают вызываемый формал метода первым — в проверке, пустом вызове, выпуске, операндах `&&`/`||` и типизации `target: call()`. Свидетель — `unit_callable_anon_named_clash` (`apply(inc 10)` = 11, `op(1 2)` = 103, Entry 7; гейтованный отказывал 16:13). Мутанты: проверка ищет метод первым — отказ 16:13; выпуск — трансляция падает. | — | FIXED |
| D-107 | 2026-09-28, fable_pc (по пробе P44 к REVIEW 59c74b3), Opus | Самопроверка интернера `l2_intern_prove` на первом методе единицы сравнивала его с пробой `l2_intern_pair("a", "b")` (два входа int `a`, `b`, результат int) только по двум именам и типу первого входа: единица, чей первый метод `fn: zz (int: a; int: b) size_t` (или `ulong`, или с другим типом второго входа), отказывалась «intern failed memcmp of equal names». Проверка к тому же имя-специальная на пути трансляции (`"a"`, `"b"`). Исправлено: совпадение с пробой — собственное равенство интернера `l2_intern_eq_mi` (арность, типы входов, результат, броски, имена). Свидетель — `unit_intern_first_size_t` (Entry 7). Мутант: сравнение по именам назад — отказ. | — | FIXED |
| D-108 | 2026-09-28, Opus, замер нативного D-105 (`steps/d105-native.md` §1, проба C2); причина уточнена (REVIEW 9c34b3b) | `l2_check_call` для фактического в формал Structure-типа уходит в допуск (`l2_admit_consumer_ix` / `l2_admit_implements`, `handled: 1`) и само фактическое не проверяет (`l2_check_fields` пропущен). Вложенный вызов в таком фактическом: (1) не даёт ребра замыканию бросков — `fn: mk (int: v) Model` с неявным броском `convert` внутри, `go` — `return: rd(mk(5))`: `go` остаётся небросающим, а L1 зовёт `mk` со статусом, которого у `go` нет, и gcc отказывает `'l2_msg' undeclared`, `'l2_out_throw' undeclared`; (2) не виден статическому правилу §14 — `mk` объявляет `Oops`, `p` — `return: rd(mk())` без catch и throws: только внутренний отказ-страж «1:1: internal: a callee's declared throw is not handled by its caller», тогда как в формал-число то же отказано на месте. Неявный бросок ловить не нужно (Q11), правило §14 не менялось. | Opus | FIXED. Каждое фактическое — через те же ворота после допуска: `if: handled != 0 && … l2_check_fields(a0, actual_span, mi, path, node) != 0` в `l2_check_call`. Свидетели GATED: `unit_d108_nested_throwing` (Entry 7), `unit_d108_nested_declared_refused` (15:12 «unhandled throw: Oops»). Мутант — ворота пропущены для формала Structure-типа (= исходник до правки, разница — ровно этот фрагмент): `_throwing` — gcc `'l2_msg'`/`'l2_out_throw'` undeclared, `_declared_refused` — «1:1: internal: …». Корпус (823 файла × 2 режима, прежний транслятор против нового): 1646 из 1646 тождественны — ни одна фикстура не передавала вложенный вызов в формал Structure-типа. |
| D-109 | 2026-09-28, Opus, при нативном срезе D-105 (`steps/d105-native.md` §4; номер — REVIEW fable_pc) | Связанное имя другого именованного типа (формал, своё поле) в формал Structure-типа не допускалось ничем: `l2_actual_ns` разрешает имя типа или путь и для связанного имени возвращает «не эта форма», а `l2_admit_consumer_uses` ищет атом как имя ТИПА и, не найдя, допускает. Так `o: Lacks` без поля `a` уходил в `rd (Model: m)`, читающий `m\a` в теле, молча. | Opus | FIXED. Проверка потребителя (`l2_admit_consumer_ix` по использованиям формала) — для каждого источника формала в `l2_d105_close`, и для пришедшего по ребру. Свидетель GATED — `unit_d109_uses_refused` (19:13 «implements is false in function argument»; на `2240a3e` переводился и исполнялся молча). Мутанты (`steps/d105-native.md` §4): проверка потребителя снята (n4) — переводится, исполнение останавливает страж дыры; отметка связанного имени снята (n5) — переводится. |
| D-110 | 2026-09-28, Opus, при нативном срезе D-105 (номер — REVIEW fable_pc; класс P0 «return висит хвостом на предыдущем кадре», как D-92/D-104) | Использования потребителя (`l2_uses_walk_frame`) — только тело метода: повисший `return:` (трейлер P0) не обходился. У `rd`, чей единственный доступ — `return: m\a`, использований не было, и допуск по использованиям пропускал любую Structure: `rd(Lacks)` (тип фактическим — допускался по использованиям с первого среза implements) переводился и читал слот, которого у `Lacks` нет. | Opus | FIXED. Обход использований — тело и трейлер (`l2_uses_walk_body`). Свидетель GATED — `unit_d110_return_uses_refused` (16:9 «implements is false in function argument»; на `2240a3e` переводился и исполнялся молча). Мутант — трейлер снова не обходится (n7): переводится, исполнение останавливает страж дыры. Корпус: обход трейлера не отказал ни одной прежней фикстуре. Перепись класса (рекурсивные обходы тела в трансляторе, 24): 15 трейлер не обходят; безопасны по смыслу (в повисшем `return:` — выражение-значение: объявлений, присваиваний и `throw:` там нет) — `l2_ml_collect`, `l2_collect_decls`, `l2_collect_asgn_body`, `l2_colon_decl_room`, `l2_take_ns_body`, `l2_body_throws` (вызовы в `return:` получают рёбра бросков через `l2_check_body`, который трейлер обходит), `l2_body_receives`, четыре `l2_predef_file_*` (C-заголовки), `l2_convert_walk` (таблица); не проверены пробой — `l2_merge_scan` (`merge` внутри повисшего `return:`) и `l2_scan_node`/`l2_scan_body` (свободные имена в `return:`, повисшем на вложенном блоке; собственный `return:` метода сканируется отдельно через `l2_ret_tr`). |
| D-111 | 2026-09-28, Opus, при срезе 2b D-105 (`steps/d105-native.md` §5) | Значение `return:` метода с результатом Structure-типа допускается (`l2_admit_return`) и как значение не проверяется: трейлер возвращает после допуска, тело проверяет поля только для результата-не-Structure. Вызов в таком значении не даёт рёбер — замыкание бросков и D-105 — и не встречает правила §14: `mk` объявляет `Oops`, `p () Model` — `return: mk()` без catch и throws: только внутренний страж «1:1: internal: a callee's declared throw is not handled by its caller»; тот же класс, что D-108 (фактическое в формал Structure-типа). | Opus | FIXED. Значение проверяется, как любое (`l2_check_fields` после допуска, в трейлере и в теле). Свидетель GATED — `unit_d111_return_declared_refused` (14:9 «unhandled throw: Oops»). Мутант r4 (проверка снова только для результата-не-Structure) — `_d111` снова «1:1: internal», `unit_d105r_chain` — 20. Корпус: проверка не отказала ни одной прежней фикстуре. |
| D-112 | 2026-09-28, Opus, замер границы вложенного пути (учёт REVIEW fa47449; `steps/d105-native.md` §5) | Вложенный путь от формала как всё значение `return:` метода с результатом-числом (`fn: rd (Outer: m) size_t` / `    return: m\in\x`) отказывается без места: «translation failed with no located diagnostic» — на `9e0cee2` и на срезе 2b одинаково; то же чтение в присваивание (`v: m\in\x`) переводится и исполняется, в выражении (`m\in\x + m\a`) — located-отказ «unresolved name». | Opus | FIXED. Причина: в позиции значения P0 даёт путь атомами (`m`, `\`, `in`, `\`, `x`), а выражение (`l2_emit_fields` → `l2_field_path_read`) читало один шаг — `m\in`, поле-Structure: проверка шага отвечала «не значение», и чтение возвращало 1 без слова. Путь глубже одного поля — одно значение: `l2_path_chain` собирает цепочку, `l2_path_chain_check` проверяет корень и лист общей прогулкой (`l2_path_kind`), `l2_path_text_read` читает (общий хвост с одношаговым чтением); через отмеченный формал — первый сегмент по записи (D-105). И инвариант класса (по fable_pc): отказ без диагностики — «internal: a refusal said nothing», выход 3 (верхний уровень транслятора; прежде — «translation failed with no located diagnostic», выход 1). Свидетели GATED: `unit_d112_nested_return` (5 + 5 через Outer и Other; до — отказ без места), `unit_d112_nested_leaf_refused` (15:13 «unknown field path segment»; до — «unresolved name»). Мутанты: чтение одним шагом (s2) — «internal: a refusal said nothing», выход 3; цепочка с глубины 3 (s3) — то же. Перепись класса: инструментированный l2trans (метка у каждого голого `return: 1`, 2161 место — большая часть «нет» предикатов) нашёл цепочку `l2_field_path_check` → `l2_emit_fields`; прогон корпуса (843 файла × 2 режима) — на `8cb4870` ровно два молчаливых отказа (этот свидетель, оба режима), после правки — ни одного. |
| D-113 | 2026-09-28, Opus, замер границы вложенного пути (учёт REVIEW fa47449, строка — по fable_pc) | Вложенный путь от формала внутри выражения (`fn: rd (Outer: m) size_t` / `    return: m\in\x + m\a`) отказывается «unresolved name» (13:15) — а имя разрешимо: то же `m\in\x` в присваивании (`v: m\in\x`) переводится и исполняется. Сообщение называет не ту причину: либо форма «путь через поле-Structure формала в выражении» не поддержана и должна отказываться своими словами, либо это дефект разрешения путей в выражениях. Проба — скретчпад Opus `d105n/nested/read_expr_*.lm2`; на `9e0cee2` и на срезе 2b одинаково. | Opus | FIXED тем же механизмом, что D-112: проверка выражения (`l2_check_fields`) берёт путь глубже одного поля целиком (`l2_path_chain_check`), не первый шаг — лист-значение принимается, лист-не-поле — «unknown field path segment», лист-Structure — «a field path must end at a primitive field», на месте. Свидетель GATED — `unit_d113_nested_expr` (`m\in\x + m\a` через Outer и Other: 6 + 15; до — «unresolved name» 17:15). Мутант — проверка одним шагом (s1): снова «unresolved name». |

<a id="unknown-nested-head-definition-internal"></a>
### UNKNOWN-NESTED-HEAD-DEFINITION-INTERNAL — 2026-10-01, deepseek (проба), fable, FIXED срезом K03c (fable, 2026-10-01)

Исправлено (запись — `k03-head-roles-20261001.md`, K03c): вложенная голова внутри определения, которая ни
во что не разрешается (не метод, не поле этой Structure выше, отсутствует на уровне единицы выше её
элемента — `l2_head_absent` по порядку исходника), с хвостом-Structure (включая пустой) — это вложенная
именованная Structure, то же поле kind 2, что объявляет форма `(): name` (`l2_ns_nested_def`,
`l2_take_ns_body`), а не оператор процедуры. Заодно Q58: хвост из одного вызова метода у головы без
привязки — оператор тела определения, не значение головы (`l2_tail_is_structure`). Свидетели:
`unit_q57_nested_unknown` (C: makeA(), D\E\x = 5), `unit_q57_nested_known_arity_refused`,
`unit_q58_batch_retained` (+ walked). Десять строк раздела C миграционной записки сняли маскирующий
корневой `return` и дают свои прежние иглы «unresolved name».

Ниже — исходная запись дефекта.


Форма приёмки K03 (`next_core_tasks_v2.md` §3; `L2_L3_CODING_INSTRUCTION.md` §3.3): `C: makeA()` при обоих
неизвестных именах определяет C с пустой вложенной именованной Structure makeA. Транслятор вместо
определения даёт внутреннюю ошибку — не диагностику языка:

```text
Known:
    size_t: x 1U
end: Known
C: makeA()
fn: main2 () int
return: 7
sendMessage: exit(exit_code: main2(); stdout: ""; stderr: "")
return
```

`l2trans error: p6_def_nested_unknown.lm2:4:4: internal: an own declaration has no physical field` /
`detail: frame=makeA` (`build/fable_k03b/src/p6_def_nested_unknown.lm2`, транслятор гейта
`k03a_full_20261001_01`, байты `l2trans.lm1` = HEAD). Корневые `newthing()` и `Known()` без C тот же
транслятор принимает. Место сообщения — `l2_layout_owns`: для own-строки `makeA` (собранной как
объявление пустой Structure `name()`) `l2_own_mslot(oi) < 0` — у вхождения объявления нет физического
поля в раскладке единицы. Почему вложенное в неизвестную голову C объявление попадает в own-строки
единицы без слота — не исследовано. Это пункт K03 «unknown `C: makeA()` with both names unknown», не K03b;
чинить общим разрешением головы в позиции определения, без ветки по форме скобок.

<a id="capture-carries-the-ordinal-target"></a>
### CAPTURE-CARRIES-THE-ORDINAL-TARGET — 2026-10-01, deepseek, OPEN

`lmx_walk_capture` берёт для каждого используемого поля копии цель **ordinal**-половины
соответствия источника (`lmx_implements_slot(arena, src, req, j)`), а копию регистрирует как
identity-with-holes. Поэтому голое чтение `v\x` внутри вложенного тела, исполняемого над копией,
читает ячейку вхождения r_j источника, а не последнее вхождение имени в значении — то, что
требует K01 для любой другой записи (ребро `slot + width`). На значении, чей макет отличается
(required `Pair{x,x}`, кандидат `Triple{10,20,30}`), копия несёт 20 там, где голое чтение обязано
дать 30. Ячейка для этого случая в копии одна, поэтому различить две записи внутри копии нельзя
без второго слота и явной карты рёбер у записи копии.

Свидетеля нет: ни одна фикстура не исполняет вложенное тело над копией значения, допущенного по
имени и с повторяющимся именем. Пробел записан, а не расширен в текущем срезе: K01a–K01e
сохранили нынешний макет захвата (шаг 1 дефекта [ADMISSION-OCCURRENCE-SELECTOR-COLLAPSE](#admission-occurrence-selector-collapse)
закрыт, захват в него не входил). Закрывать его следует отдельным срезом с парой свидетелей:
копия значения с отличающимся макетом (голое чтение = последнее вхождение) и копия того же типа
(обе записи совпадают), плюс проверка, что копия по-прежнему не наследует token исходной схемы.

<a id="foreign-value-witness-silent"></a>
### FOREIGN-VALUE-WITNESS-SILENT — 2026-10-03, fable, FIXED в sandbox (не выпущено)

Чтение формала чужого C-типа по значению (`c.LmP0NodeKind: kind`, `c.L2DispatchPair: value`)
строило `ARG`, чей witness требует типизированную ячейку. Проход подсчёта это принимал, проход
заполнения возвращал ошибку из `l2_rw_witness` (тип `-1`: «у графа нет ячейки такого типа») без
диагностики: `internal: a refusal said nothing`. Дефект был скрыт более ранними расположенными
отказами в `parser_alloc_port`.

Исправление: witness такого входа остаётся пустым местом — так же, как его место в объявленной
части самого метода, — а тело помечается native-only (`l2_rw_input_witness`,
`l2_foreign_value_ft`). Свидетель: `graph_shape_foreign_value` с фактом `nullpath` и мутантом,
который переносит ординал входа в место witness;
[журнал продолжения](fable-continuation-20261003.md#foreign-value).

<a id="native-raw-index-literal-type"></a>
### NATIVE-RAW-INDEX-LITERAL-TYPE — 2026-10-03, fable, FIXED в sandbox (не выпущено)

`l2_native_span_ty` возвращает `-1` для сырого индекса, тип элемента которого L2 неизвестен
(`stack\columns[idx]` у `c.LmP0IndentStack`). В нативной типизации `-1` означает «литерал без
суффикса», поэтому `l2_native_composite_ty` превращает его в `int`, и `return: stack\columns[idx]`
в методе с результатом `size_t` требует конвертер `lm_stg_convert_int_size_t`, которого в программе
нет. Строка `unit_indent_stack_field_index` из-за этого красная. Значение неизвестного C-типа —
непрозрачное (его проверяет C), а не целочисленный литерал: вернуть «не типизировано» (`-99`),
как для остальных чужих путей. Исправлено так: `l2_native_span_ty` возвращает `-99`; строка
зелёная, полный гейт `fable_full_06` без регрессий
([журнал](fable-continuation-20261003.md#nested-array)).

<a id="machine-local-table-stale"></a>
### MACHINE-LOCAL-TABLE-STALE — 2026-10-03, fable, FIXED в sandbox (не выпущено)

`l2_local_ns_shape` спрашивает `l2_ml_find`, но таблица машинных локалов метода (`l2_ml_*`) не
пересобиралась ни в проходе сбора ролей объявлений (`l2_collect_asgn_binds`), ни в обоих проходах
построения графа (`l2_rw_methods_count`, `l2_rw_methods_emit`): там читалась таблица последнего
проверенного метода либо пустая. Пока объявление `L2TestAllocFn: f av\alloc` отказывало раньше, это
не проявлялось. После появления producer'а объявления оператор `f: n` (вызов через локальный указатель
на функцию) регистрировался как локальное определение именованной Structure `f`: лишняя процедура
`l2_m2`, лишний `l2_nsp[0]` и лишний child метода, которого в исходнике нет.

Исправление: таблица собирается для читаемого метода во всех трёх местах. В раннем проходе читаются
только локалы, классифицируемые по импортированному имени типа (`l2_ml_imported_only`): полное
раннее чтение отказывало `@: Model Model @Other` словами `unknown type`, потому что локальное
определение `Model` ещё не зарегистрировано (два OK→FAIL в промежуточном `fable_full_02`, устранены
до каких-либо утверждений). Свидетель: `graph_shape_machine_local` (ширина метода 9, без лишнего
child) и его три мутанта; запись — [журнал продолжения](fable-continuation-20261003.md#machine-locals).

<a id="merge-decl-in-named-body-internal"></a>
### MERGE-DECL-IN-NAMED-BODY-INTERNAL — 2026-10-03, fable, OPEN

Объявление результата merge внутри тела именованной Structure — unit-уровня или локальной —
даёт внутреннюю ошибку вместо построения:

```text
E: (int: a 7)
Holder:
    kept: merge E
    size_t: mutable_cell 3U
end: Holder
sendMessage: exit(exit_code: 7; stdout: ""; stderr: "")
return
```

`internal: an own declaration has no physical field`, `frame=kept` (то же для
`Holder: (int: c 3; box: merge Point)` внутри метода). Место — `l2_layout_owns`: для процедуры
namespace `l2_own_mslot` сопоставляет own-строку только с NSF-строкой по токену имени, а вычисляемый
результат merge NSF-поля не имеет. Обычные методы дают таким own-строкам упакованный начальный слот,
который затем заменяет source-layout. Чинить общим source-producer'ом вычисляемого выхода в теле
namespace (место — child1 существующего операнда OWN/AT), не веткой по имени и не новым NSF-видом.
Свидетеля в harness пока нет: миграции этого среза намеренно обошли форму вложенными определениями.

<a id="merge-result-reference-field-path"></a>
### MERGE-RESULT-REFERENCE-FIELD-PATH — 2026-10-03, fable, FIXED в sandbox (не выпущено)

Чтение пути через reference-поле результата merge в его pointee не разрешается:

```text
Model: (size_t: value 1U)
Holder:
    @: Model q
end: Holder
fn: check () int
    h: merge Holder
    size_t: v
    v: h\q\value
return: 7
```

`unknown field path segment`, `atom=h`. Запись `h\q: mo` через тот же путь транслируется; тот же
трёхсегментный путь от локального определения `h: (@: Model q)` или от unit-уровня `Holder` читается.
Пробел — проекция схемы результата merge через reference-поле (потребители, считающие каждую схему
именованной моделью; словарь v2 §10). Исправлено: слот результата merge хранит строку поля, из
которого пришёл, и pointee reference-поля берётся из неё (`l2_mrs_ref_pointee`). Свидетель
`unit_mres_ref_field_path` с обходимым двойником
([журнал](fable-continuation-20261003.md#merge-result-reference-field)).

<a id="merge-result-reference-store-unchecked"></a>
### MERGE-RESULT-REFERENCE-STORE-UNCHECKED — 2026-10-04, fable, FIXED в sandbox (не выпущено)

Запись в reference-поле результата merge не допускала значение к модели поля:

```text
Model: (size_t: value 1U)
Other: (int: p 1; int: q 2)
Holder:
    @: Model q
end: Holder
fn: check () int
    h: merge Holder
    o: merge Other
    h\q: o
    return: 7
end: check
```

Программа доходила до 7. Та же запись через объявленную Structure, `Holder\q: o`, отказывает
неявным throw `implements`. Причина та же, что у чтения: модель листа пути спрашивалась у
объявленной Structure, а для слота результата merge оставалась неизвестной, и запись шла без
допуска. Исправлено тем же `l2_mrs_ref_pointee`. Свидетель `unit_mres_ref_field_store_refused`
с обходимым двойником, мутант `fable_mref_mut_noleaf`.

<a id="named-actual-formal-order"></a>
### NAMED-ACTUAL-FORMAL-ORDER — 2026-10-04, fable, FIXED в sandbox (не выпущено)

Именованные фактические аргументы вычислялись в порядке формалов, а не в порядке записи:

```text
int: trace 0
fn: mark (int: v) int
    node\trace: node\trace * 10 + v
    return: v
end: mark
fn: f (int: a; int: b) int
    return: a - b
end: f
int: w f(b: mark(1); a: mark(2))
```

След вызовов был 21, а не 12 — и в native, и в интерпретаторе. Привязка (`l2_bind_call_in`)
переписывала тело вызова в порядок формалов до того, как его читал любой проход; удержанный граф
хранил аргументы на местах формалов, без имён и без порядка записи. Норма: поля графа стоят и
вычисляются в лексическом порядке. Исправлено: привязка сохраняет ранг записи и именующий Frame
каждого формала; native готовит аргументы в порядке записи; в графе именованный аргумент стоит на
своём месте записи как `NAMED [координата, значение]`, интерпретатор вычисляет операнды подряд и
передаёт значение формалу по координате. Свидетели `unit_named_actual_order`,
`unit_named_actual_order_forms` (оба с обходимыми двойниками), `unit_named_actual_order_callable`,
самотест ядра `lmx_walk_named_actual_selftest`
([журнал](fable-continuation-20261003.md#named-actual-order)). Остаток — тело вызова, переписанное
привязкой, — закрыт: [NAMED-ACTUAL-BODY-REWRITTEN](#named-actual-body-rewritten).

<a id="named-actual-body-rewritten"></a>
### NAMED-ACTUAL-BODY-REWRITTEN — 2026-10-04, fable по ответу Codex FABLE-CODEX-20261004-03, FIXED в sandbox (не выпущено)

Привязка (`l2_bind_call_in`) заменяла поля тела вызова списком в порядке формалов: первое и
последнее поле и счётчик P0-тела после неё описывали не то, что написано, а именующие кадры в теле
не оставались. Исходный текст вызова по дереву было не восстановить. Исправлено: тело не трогается;
проекция лежит в записи привязки, и читатель берёт её через `l2_call_actuals` там, где входит в
тело. Попутно найдено, что обходчик, читающий написанное тело, принимает именующий кадр за имя,
объявление или запись вызывающего: скан свободных имён, скан merge и канала throw (кадр
`Model: x` как объявление), скан использования ссылки (кадр `v: v\value` как запись в ссылку).
Все они переведены на проекцию. Память привязки освобождается в конце трансляции. Свидетели —
`unit_named_actual_scope_names`, `_method_names`, `_reference_name`, `_reference_whole`,
`_structure_name` и его библиотечная строка, `_capture`, `_callable_names`, `_facts`, `_forms`,
`_machine`, `_free_name_refused`; контроли по одному читателю и проверка целости тела —
[§43 журнала](fable-continuation-20261003.md#written-body-kept).

<a id="callable-formal-statement-store"></a>
### CALLABLE-FORMAL-STATEMENT-STORE — 2026-10-04, fable по ответу Codex FABLE-CODEX-20261004-06, FIXED в sandbox (не выпущено)

Вызов callable-формала, записанный оператором, принимался за запись в формал:

```text
fn: note (int: a) int ...
fn: colon (note: p; int: x) int
    p: x            # 20:5 assignment value has incompatible type
fn: paren (note: p; int: x) int
    p(x)            # то же дерево, тот же отказ
fn: named (note: p; int: x) int
    p(a: x)         # assignment value has unknown type
```

`p` объявлен сигнатурой метода `note`; каждый оператор — обычный вызов того, что несёт `p`. Тот же
вызов в выражении (`r: p(x)`, `return: p(a: x)`) транслируется и работает. Если в юните есть ещё и
метод с именем `p`, оператор транслируется и вызывает то, что несёт формал, а не метод: выбор между
вызовом и записью зависит от того, есть ли метод с таким именем, хотя вызываемый от этого не
зависит. Решение Codex: это не открытый вопрос автора о роли заголовка (тот — о заголовке без
формала, без видимой привязки и без прежнего чтения), а дефект порядка разрешения. Классификатор
операторов и сборщик присваиваний должны спрашивать общее решение о роли вызова
(`l2_call_head_method`, `l2_head_is_call`) раньше, чем выбирать запись; без исключения по имени, по
форме с двоеточием или только для формалов; категория берётся из объявленного callable-контракта, а
не из указательного транспорта; лексическое затенение сохраняется.

Исправлено: классификатор операторов получил место (`l2_is_asgn(stmt, mi)`) и спрашивает роль
заголовка там же, где её спрашивает заголовок вызова. По тому же решению оператор с заголовком —
удерживаемым callable — его вызов (ответ Codex -08), на корне и в методе. Позитив
`unit_callable_formal_statement` зелёный (добавлен нульарный случай `q()`), контроли
`unit_callable_formal_statement_controls` зелёные; `unit_held_call_statement` — вызов удерживаемого
callable оператором. Строки с callable-формалом нативные: обход методов их исключает
([§47 журнала](fable-continuation-20261003.md#site-role)).

<a id="held-store-shape-replaces-binding"></a>
### HELD-STORE-SHAPE-REPLACES-BINDING — 2026-10-04, fable по ответу Codex FABLE-CODEX-20261004-09, FIXED в sandbox (не выпущено)

Оператор формы «запись callable merge» объявлял заголовок всюду, где стоял:

```text
h2: make2 100
h2: make2 200      # было: вторая строка h2, программа доходила до 200
```

По норме (`#construction`, словарь `#head`) после установленной привязки `h2` второй оператор —
обычное применение этой привязки: его фактические проходят правила вызова, вызов может быть
недопустимым, но не заменяет `h2` молча. Форму принимали за объявление сборщик, проверка, граф,
нативная эмиссия и исключение в классификаторе операторов.

Исправлено: сборщик резервирует строку, только когда у заголовка нет привязки на месте; остальные
проходы спрашивают собственную строку оператора (`l2_mad_declaring`: форма и строка, объявленная
именно этим узлом). Под привязанным заголовком та же форма — использование привязки: удерживаемый
callable применяется, в число записывают. Свидетели — `unit_held_call_reapplied_refused`,
`unit_held_call_reapplied_method_refused`, три `unit_store_callable_over_*_refused`; неизменность
callable после неудавшегося применения — `unit_held_call_failed_application`
([§48 журнала](fable-continuation-20261003.md#site-selection)).

<a id="held-unit-wide-name-scan"></a>
### HELD-UNIT-WIDE-NAME-SCAN — 2026-10-04, fable по ответу Codex FABLE-CODEX-20261004-09, FIXED в sandbox (не выпущено)

Регрессия среза §47 (`af3b907e`). Роль «заголовок — удерживаемый callable» бралась из поиска по
всему юниту (`l2_unit_holds_callable`): любой оператор формы записи под этим именем.

```text
h2: make2 100
int: h2 5
fn: stores () int
    h2: 7          # было: отказ, unknown method; до §47 — запись числа
    return: h2
end: stores
```

Исправлено: поиск по исходнику удалён. Сборщик сначала обходит корни, затем методы, и отвечают
обычные строки. Удерживаемый callable — строка, которую имя выбирает на месте (`l2_own_visible`):
собственная строка места, объявленная последней перед ним, в своём лексическом хозяине; в методе —
поле юнита, видимое из метода, то есть объявленное выше него. Более позднее объявление назад не
действует. Свидетели — `unit_held_call_superseded`, `unit_held_call_superseded_refused`,
`unit_held_call_superseded_caller_refused`, `unit_held_call_block`, `unit_held_call_block_refused`
([§48 журнала](fable-continuation-20261003.md#site-selection)).

<a id="held-callable-root-only"></a>
### HELD-CALLABLE-ROOT-ONLY — 2026-10-04, fable, FIXED в sandbox (не выпущено)

Удерживаемый callable искался только среди полей корня. Локал метода, объявленный записью callable
merge, получал строку, но его вызов отвергался (`unknown method`, в форме оператора — `more arguments
than h has formals`):

```text
fn: a (int: k) int
    h: make2 k
    return: h(1 2)
end: a
```

Исправлено: владелец выбранной строки не важен, важна объявившая её запись. Свидетели —
`unit_held_call_method_local` (по callable на активацию и на ветку), `unit_held_call_other_method_refused`
([§48 журнала](fable-continuation-20261003.md#site-selection)).

<a id="held-call-value-untyped"></a>
### HELD-CALL-VALUE-UNTYPED — 2026-10-04, fable, FIXED в sandbox (не выпущено)

Вызов удерживаемого callable, стоящий один справа от записи, отвергался: `r: h2(1 2)` —
`assignment value has unknown type`. Воспроизводится на всех измеренных трансляторах до
`fable_full_17`. Типизатор одиночного значения знал вызов метода и предопределённой функции, но не
удерживаемого callable.

Исправлено: тип — результат заголовка (`l2_mad_held_value_ty`). Свидетели — `unit_held_call_assigned`
(int и unsigned, корень и метод), `unit_held_call_assigned_type_refused`
([§48 журнала](fable-continuation-20261003.md#site-selection)).

<a id="held-nullary-statement-structure-route"></a>
### HELD-NULLARY-STATEMENT-STRUCTURE-ROUTE — 2026-10-04, fable, FIXED в sandbox (не выпущено)

Оператор `p0()` под нульарным удерживаемым callable уходил в исполнение именованной Structure и
отвергался: `executing a named Structure is not supported yet`. Воспроизводится на всех измеренных
трансляторах до `fable_full_17`. Найдено инвентаризацией вызывающих классификатора без места.

Исправлено: `l2_empty_struct_assign_shape` спрашивает удерживаемый callable места, как спрашивает
его формалы. Свидетель — `unit_held_call_nullary_statement`
([§48 журнала](fable-continuation-20261003.md#site-selection)).

<a id="held-bare-name-statement"></a>
### HELD-BARE-NAME-STATEMENT — 2026-10-04, fable, FIXED в sandbox (не выпущено)

Голое имя нульарного удерживаемого callable как оператор отвергалось:

```text
p0: make0 100
p0                 # отказ: executing a named Structure is not supported yet
```

По норме голое имя — тот же нульарный вход. Маршрут другой, чем у `p0()`: голый атом идёт в
`l2_check_struct_call`, а вызову удерживаемого callable в проверке, графе и нативной эмиссии нужен
был Frame.

Исправлено по ответу Codex FABLE-CODEX-20261004-10 (блокер G5): подпрограммы вызова удерживаемого
callable берут тело вызова из узла (`l2_call_node_body`: тело Frame или ничего для голого имени), а
три маршрута оператора — проверка, нативная эмиссия, граф — спрашивают удерживаемый callable места
для голого имени так же, как спрашивают метод. Свидетель — `unit_held_call_bare_name` (нативно и с
обходом); временная проба удалена
([§49 журнала](fable-continuation-20261003.md#no-forward-lookup)). Позиция значения — отдельный
открытый дефект [HELD-BARE-NAME-RESULT-RECEIPT](#held-bare-name-result-receipt).

<a id="held-bare-name-result-receipt"></a>
### HELD-BARE-NAME-RESULT-RECEIPT — 2026-10-04, fable по ответам Codex FABLE-CODEX-20261004-11 и -12, FIXED в sandbox (не выпущено) для целого значения

Исправлено: место, чей контракт получателя — число, спрашивает одно общее решение
(`l2_held_result_receive`) о целом значении. Если это голое имя удерживаемого callable места,
заголовок которого даёт число, место принимает результат вызова: вызов проверяется проверкой
удерживаемого вызова, узел значения записывается, и типизаторы с обеими эмиссиями читают категорию
места из записи. Спрашивают: общая грань потребляемого значения (инициализатор, фактический
числового формала, возврат, элемент), запись, запись в числовое поле по пути, типизированное место
графа (поле сообщения). Преобразование результата — обычная грань. Места, принимающие ссылку, не
спрашивают: имя остаётся вхождением (`unit_held_call_bare_name_occurrence`). Свидетели —
`unit_held_call_bare_name_result`, `unit_held_call_bare_name_places`,
`unit_held_call_bare_name_message`, `unit_held_call_bare_name_args_refused`
([§52 журнала](fable-continuation-20261003.md#result-receipt)). Операнды — отдельный открытый
дефект [HELD-BARE-NAME-OPERAND-RESULT](#held-bare-name-operand-result). Ниже — запись, как она
стояла.

Голое имя нульарного удерживаемого callable там, где принимается результат, отвергается как ссылка:

```text
p0: make0 7
int: r 0
r: p0              # отказ: assignment value has incompatible type
fn: use () int
    return: p0     # отказ: return value has incompatible type
end: use
fn: id (int: a) int
    return: a
end: id
int: s id(p0)      # отказ: a reference where a number is asked
```

По норме (`#callables`) результат или ссылку выбирает контракт получателя: явно объявленный
callable-формал получает ссылку на вхождение; когда принимается результат, callable, возвращающий
значение, исполняется. Значит, `int`, принимающий `p0`, получает то же, что даёт `p0()`: в записи
`r: p0`, в `return: p0` метода с результатом `int`, в фактическом `int`-формала. Там, где контракт
требует вхождение, callable не исполняется. §49 журнала называл нынешнее поведение правилом; это
исправлено в §50. Обязательный позитив с красной строкой добавляется со следующим гейтом; чинить
через общее решение контракта получателя и категорию места, не исполнением любой ссылки
([§50 журнала](fable-continuation-20261003.md#result-receipt-open)).

<a id="held-bare-name-operand-result"></a>
### HELD-BARE-NAME-OPERAND-RESULT — 2026-10-04, fable по ответу Codex FABLE-CODEX-20261004-12, FIXED в sandbox (не выпущено)

Исправлено: общее решение (`l2_held_result_receive`) читает прогон из нескольких полей как операцию
и записывает каждый операнд — голое имя удерживаемого callable, заголовок которого даёт число.
Спрашивают проверка каждой операции (`l2_check_value_kinds`) и проверка одного значения условия
(`if`, `while`, `for`, `until`). Записанное место считается значением с вызовом, поэтому короткое
замыкание внутри группы остаётся ленивым. Свидетели — `unit_held_call_bare_name_operand`,
`unit_held_call_bare_name_condition`, `unit_held_call_bare_name_message_operand`
([§53 журнала](fable-continuation-20261003.md#operand-receipt)). Ниже — запись, как она стояла.

Операнд арифметики, упорядочивающего сравнения и равенства — место, принимающее результат. Голое
имя удерживаемого callable, возвращающего значение, там исполняется, как исполняется названный так
же метод единицы:

```text
p0: make0 100          # заголовок () int
z0: make0 0
int: a p0 + 1          # отказ сегодня: a reference where a number is asked
if: p0 < 500           # отказ сегодня: a reference compared with a number other than 0
if: z0 = 0             # сегодня сравнивается вхождение (не null), по норме — результат 0
```

Codex: «p0 = 0 and p0 != 0 compare the returned int with numeric zero, just as the corresponding
unit-method expressions do. Do NOT choose occurrence/null comparison merely because the callable is
held in a reference or the other operand happens to be zero.» Сравнение ссылки остаётся под явным
принимающим ссылку контрактом: непрозрачная ссылка, получившая имя (`@: void k p0`), сравнивается
с null без вызова. Обязательный позитив, красный: `unit_held_call_bare_name_operand` — callable с
ненулевым вхождением и нулевым результатом, счётчик вызовов, контроли короткого замыкания, явное
сравнение ссылки. Чинить через общий маршрут выражения и запись категории места, как целое
значение ([§52 журнала](fable-continuation-20261003.md#result-receipt)).

<a id="native-group-call-parentheses"></a>
### NATIVE-GROUP-CALL-PARENTHESES — 2026-10-04, fable, FIXED в sandbox (не выпущено)

Нативная эмиссия группы, в полях которой есть вызов, выдавала текст вычисления группы без скобок:

```text
fn: u () int
    return: 100
end: u
int: x (u() + 1) * 2      # нативно: l2_t1 + 1 * 2 = 102; с обходом: 202
```

Группа без вызовов всегда выдавалась в скобках. Ошибка стояла на закоммиченном трансляторе для
метода единицы, вызванного или названного голым именем, и для удерживаемого вызова; найдена
свидетелем группы-операнда. Исправлено: текст группы выдаётся в скобках на обоих маршрутах
(`l2_prep`). Свидетель — `unit_group_call_parentheses` (нативно и с обходом), мутант без скобок даёт
102. В 66 трансляциях гейта изменились только добавленные скобки
([§53 журнала](fable-continuation-20261003.md#operand-receipt)).

<a id="held-call-from-nested-definition"></a>
### HELD-CALL-FROM-NESTED-DEFINITION — 2026-10-04, fable, FIXED 2026-10-04 для измеренных программ

Определение внутри метода, который его возвращает, вызывает другой удерживаемый callable:

```text
p0: make0 100                      # заголовок () int
fn: makeUse (int: k) fn: () int
    fn: g0 () int
        return: k + p0()
    return: g0
u0: makeUse 5
int: r u0()                        # из корня: отказ
fn: inner () int
    return: u0()                   # из метода: принято, останов при исполнении
end: inner
```

Из корня — отказ `root operation not walkable yet: a caller's binding of a held callable's free
name is of another type`. Если вызов только из метода, программа принимается и останавливается
при исполнении, нативно и с обходом: `lmx: invariant: a callable merge was called outside its
header`. Так на закоммиченном трансляторе с вызовом `p0()`; после среза операндов голое имя в таком
определении при вызове из метода приходит к тому же останову. Найдено пробой условий во вложенном
определении.
Принятая программа, которая аварийно останавливается, хуже отказа.

Решение Codex (FABLE-CODEX-20261004-12, второй ответ): блокер G5; принадлежит общей зависимости
формирования входов фактического вызова и замыкания захватов (K04), чинить не отдельным скрытым
окружением для удерживаемого callable. Захваченный callable — обычная непримитивная ссылка;
скопированное вхождение и нужные лексические зависимости должны пережить композицию, а при вызове
действует обычный приоритет источников вызывающего. Измерено дополнительно: числовое свободное имя
уровня единицы в таком определении читается при вызове (5, затем 7 после записи), ссылка на
Structure (`m\v`) даёт `walk error: INVALID`, удерживаемый callable — останов выше; если вызывающий
метод сам называет `p0`, вызов даёт 105. Обязательные позитивы, красные, отдельно по вызывающему:
`unit_held_call_from_nested_definition_root` и `unit_held_call_from_nested_definition_method`,
каждый нативно и с обходом
([§53](fable-continuation-20261003.md#operand-receipt) и
[§55 журнала](fable-continuation-20261003.md#actual-inputs-ruling)).

**Исправлено 2026-10-04** ограниченным шагом общей зависимости, который разрешил Codex. Скрытый вход
определения, которое метод возвращает, вызывающий мог оставить отсутствующим только для числа: тогда
определение читало лексический источник через запасное чтение `ARG` (`l2_rw_arg_fb`). Теперь так же
читаются ссылки: код удерживаемого callable, который определение вызывает (`l2_rw_mad_call`), и
корень пути через Structure (`l2_rw_path_value`). Корень, чья собственная строка и есть лексический
источник определения, подаёт её как свою привязку (`l2_rw_held_binding`). Обе строки по вызывающему
зелёные, нативно и с обходом; добавлены вызов с аргументом и два удерживаемых в одном выражении,
два уровня вложенности и голое имя, чтение Structure единицы по пути, в том числе после записи в
неё. Контроль рядом: число, у которого это чтение было и раньше. Остаток — запись ниже
([§56 журнала](fable-continuation-20261003.md#nested-references)).

<a id="held-free-reference-other-declaration"></a>
### HELD-FREE-REFERENCE-OTHER-DECLARATION — 2026-10-04, fable, FIXED 2026-10-05

**Исправлено 2026-10-05.** То, что вызывающий метод подаёт под именем, допускается к использованию
определения обычным допуском, как скрытый вход при вызове метода: нативно (`l2_prep_held_call`) и с
обходом (`l2_rw_mad_call`). Ссылка другого объявления — кандидат, а не предел. Программа ниже даёт 45
(`unit_nested_definition_structure_override` и `_walk`). Structure без поля, которое определение
читает, отвергается обычным допуском при трансляции: `implements is false in function argument`
(`unit_nested_definition_structure_other_refused`). Structure другого объявления с полем на другой
позиции читается по своему полю: `unit_held_reference_chain`, 65 через два метода и 75 у самого
удерживаемого вызова. Предел остался только там, где у входа определения нет схемы допуска:
удерживаемый callable под именем
([§68 журнала](fable-continuation-20261003.md#reference-among-free-names)).

Запись до исправления:

Собственная ссылка вызывающего под свободным именем удерживаемого callable подаётся, только когда
она и есть то объявление, которое называет лексический источник определения. Другое объявление того
же имени отвергается на месте:

```text
Model:
    int: v 4
end: Model
m: merge Model
fn: makeUse (int: k) fn: () int
    fn: g0 () int
        return: k + m\v
    return: g0
u0: makeUse 5
fn: inner () int
    m: merge Model
    m\v: 40
    return: u0()                   # по норме 5 + 40: ближайшая привязка вызывающего
end: inner
```

Отказ: `a caller's own reference under a held callable's free name is not admitted to its use
yet`. Это предел реализации, не правило: по норме ближайшая привязка вызывающего идёт первой и для
ссылки, а годность значения решает обычный допуск к использованию. Допуск здесь не построен, поэтому
транслятор пока не отличает годную ссылку от негодной. Свидетель негодной —
`unit_nested_definition_structure_other_refused`: у собственной Structure вызывающего нет поля,
которое определение читает; отказ там верен, а без проверки объявления программа читала чужое поле
(мутант дал 6). Обязательный позитив, красный: `unit_nested_definition_structure_override`, нативно
и с обходом. Чинится общим формированием входов фактического вызова (K04), тем же допуском, что у
скрытых входов прямого вызова
([§56 журнала](fable-continuation-20261003.md#nested-references)).

<a id="held-call-names-not-asked-of-callers"></a>
### HELD-CALL-NAMES-NOT-ASKED-OF-CALLERS — 2026-10-04, fable, FIXED для чисел 2026-10-04

**Исправлено 2026-10-04 для чисел.** Удерживаемый вызов стал обычным местом неподвижной точки скрытых
входов: число, которое нужно определению и которого вызывающий метод не связывает, становится входом
самого метода, и его вызывающие подают имя по цепочке. Программа ниже даёт 36, нативно и с обходом
методов (`unit_held_call_required_input_from_caller`). Захваченное имя метода-фабрики остаётся
свободным именем определения: скопированное значение — его собственный источник, а не замороженная
привязка (`unit_held_call_free_name_chain`, `_working`, `_node`). Ссылка через удерживаемый вызов по
цепочке ещё не спрашивается: это остаётся в
[HELD-FREE-REFERENCE-OTHER-DECLARATION](#held-free-reference-other-declaration). Одно имя, нужное двум
определениям как два типа, — в [HELD-FREE-NAME-OTHER-TYPE](#held-free-name-other-type)
([§60 журнала](fable-continuation-20261003.md#held-chain)).

Имя, которое требуется удерживаемому callable, спрашивается только у метода, делающего вызов. У его
вызывающих оно не спрашивается, хотя по норме скрытый вход идёт по цепочке вызывающих, как у прямого
вызова:

```text
fn: r () int
    return: zz + 1                 # единица zz не объявляет
end: r
fn: mk (int: k) fn: () int
    fn: f () int
        return: k + r()            # f только пересылает zz
    return: f
u0: mk 5
fn: inner () int
    return: u0()                   # у inner нет zz
end: inner
fn: outer () int
    int: zz 30
    return: inner()                # по норме 5 + 31
end: outer
```

Измерено 2026-10-04. Транслятор `5afcb650` принимает программу и даёт неверное значение. Транслятор
`a5171eb3` принимает её и останавливает процесс при исполнении (`a required input arrived absent`),
при обходе методов — `walk error: INVALID`. Теперь вызов в `inner` отвергается при трансляции, на
месте: `a name a held callable requires is not asked of this method's callers yet`. Это предел
реализации, не правило. Из корня тот же вызов недопустим по норме и отвергается обычным отказом
`unbound dynamic input` (`unit_absent_input_unavailable_refused`). Обязательный позитив, красный:
`unit_held_call_required_input_from_caller`. Чинится третьим срезом K04: удерживаемый callable как
вызываемый идёт тем же формированием, что прямой вызов
([§59 журнала](fable-continuation-20261003.md#site-requirements)).

<a id="held-free-name-other-type"></a>
### HELD-FREE-NAME-OTHER-TYPE — 2026-10-04, fable по ответу Codex FABLE-CODEX-20261004-12, FIXED 2026-10-05 (Opus)

Метод передаёт дальше один вход одного имени с одним типом. Если двум удерживаемым определениям одного
метода имя нужно как два числовых типа, то значение вызывающего, присутствующее для одного, для
другого надо преобразовать обычным преобразованием: присутствующий кандидат другого типа — не
отсутствие, и молча взять скопированное значение нельзя. Преобразование здесь не построено. Где вход
метода не может прийти присутствующим — ни у одного вызывающего по цепочке нет значения, — определение
другого типа не получает ничего и читает собственный источник: такая программа работает
(`unit_held_call_arity`). Где может — вызов отвергается на месте: `a caller's binding of a held
callable's free name is of another type`. Это предел реализации, не правило. Обязательный позитив,
красный: `unit_held_call_free_name_converted` (по норме 1001 и 141)
([§60 журнала](fable-continuation-20261003.md#held-chain)).

**Исправлено 2026-10-05 (Opus)** по передаче Codex OPUS-HANDOFF-20261005-103112, пункт 5: «a reached
present value invokes the ordinary converter; absent stays absent without calling it». Привязку другого
числового типа, которая может прийти присутствующей, преобразует вызов, который её подаёт, обычной
строкой `primitive.convert`. Отказ приёмника — неявный `convert` этого метода. Отсутствующая запись
остаётся отсутствующей, приёмник не вызывается, определение читает свою копию. Нативно перед вызовом
стоит проверка присутствия. При обходе — два новых действия ядра, GUARD и GUARDED: источник вычисляется
один раз, продолжение (вызов приёмника) читает его значение и не выполняется, если значения нет. Вход,
который метод только передаёт, больше не берёт тип у удерживаемого определения: его типизируют привязки
вызывающих. Раньше такой метод, вызванный с int, отвергался `incompatible entry signature`, потому что
его единственный потребитель читает size_t. `unit_held_call_free_name_converted` даёт 1001 и 141,
нативно и с обходом. `unit_held_call_free_name_untaken`: непроизошедшее сужение не бросает ни для int
-1, ни для size_t 2^32 + 40; произошедшее — перехватываемый `convert` вызывающего; присутствующий ноль
читается. Собственная привязка корня и метода — `unit_held_call_free_name_own_binding`. Мутанты — в [§87 журнала](fable-continuation-20261003.md#held-conversion). Вызывающие одного
пересылающего метода, давшие имени два типа, остаются пределом:
[FORWARDER-BINDINGS-OF-TWO-TYPES](#forwarder-bindings-of-two-types).

<a id="forwarder-bindings-of-two-types"></a>
### FORWARDER-BINDINGS-OF-TWO-TYPES — 2026-10-05, Opus, OPEN (вопрос Codex, блокер G5)

Метод, который только передаёт имя дальше, имеет для него один тип. Если два его вызывающих связывают
имя двумя типами, второй вызов отвергается: `incompatible entry signature`. По словам Codex («Pure
forwarders must preserve ORIGINAL resolved type + presence losslessly») значение каждого вызывающего
идёт со своим типом, и вызов, который подаёт его определению другого типа, преобразует по типу, с
которым оно пришло. Для этого нужен тип записи при исполнении или трансляция, которая знает его для
каждого вызова. Спрошено у Codex. Обязательный позитив, красный: `unit_held_call_free_name_two_types` —
`small` даёт int 40, `wide` — size_t 7 через один `hop`; по норме 41 и 8
([§87 журнала](fable-continuation-20261003.md#held-conversion)).

<a id="site-reference-not-left-out"></a>
### SITE-REFERENCE-NOT-LEFT-OUT — 2026-10-04, fable по ответу Codex FABLE-CODEX-20261004-12, FIXED 2026-10-05

**Исправлено 2026-10-05.** Ссылка, которая месту не нужна, опускается, как число: вход остаётся
записью среди ссылок вызова и идёт дальше отсутствующим (`l2_dyn_fwd`, `l2_site_needs`). Строки:
`unit_callable_formal_site_names_reference` (10 и 7), `unit_callable_formal_site_reference_forwarded`
(через метод, который только передаёт callable дальше) и
`unit_callable_formal_site_reference_unasked`: у вызывающего под этим именем своя Structure без поля,
которое читает другой callable; он подаёт тот callable, который имя не читает, и его Structure не
спрашивается и ни к чему не допускается. Только третья строка отличает мутант, который формирует
ненужную ссылку
([§68 журнала](fable-continuation-20261003.md#reference-among-free-names)).

Запись до исправления:

Место вызова спрашивает только имена того callable, который оно подаёт, какого бы вида они ни были.
Отсутствующим пока передаётся только число. Ссылка среди имён альтернативы, которую место не подаёт,
отвергается на месте: `an input that is a reference, of a callable this call does not give, is not
left out yet`. Это предел реализации, не правило: нужен ли вход, не зависит от его представления.
Обязательный позитив, красный: `unit_callable_formal_site_names_reference` (по норме 10 и 7). Чинится
третьим срезом K04 вместе с отсутствием ссылки
([§59 журнала](fable-continuation-20261003.md#site-requirements)).

<a id="nested-definition-assigns-host-name"></a>
### NESTED-DEFINITION-ASSIGNS-HOST-NAME — 2026-10-04, fable, FIXED 2026-10-04

Определение внутри метода присваивает имя этого метода — его формал или поле, объявленное на уровне
метода:

```text
fn: mkw (int: n) fn: () int
    fn: w () int
        n: n + 2          # читалось как объявление Structure `n` самого определения
        return: n         # отказ: return value has incompatible type
    return: w
```

Имя разрешается в методе, который держит определение: это свободное имя определения, и оператор
присваивает значение его активации, ничего не объявляя и не записывая в узел (`#dynamic`: аргумент,
явный или скрытый, — значение активации). Классификатор собственной именованной Structure метода
(`l2_local_ns_shape`) не видел имён держащего метода и считал голову неразрешённой. Исправлено там
же. Свидетели, нативно и с обходом методов: `unit_nested_definition_assigns_free_name` (72 и 72; 141
и 141; 7; 75), `unit_held_call_formed_input`
([§62 журнала](fable-continuation-20261003.md#merge-actual)).

<a id="t7-tables-fixed-size"></a>
### T7-TABLES-FIXED-SIZE — 2026-10-04, fable, FIXED 2026-10-04

Таблицы merge транслятора были фиксированного размера: 8 merge на единицу, 16 привязок и 16 записей
объявленных заголовков на все. Девятый merge отвергался словами `out of memory`. Это не правило
языка и не нехватка памяти. Таблицы растут вместе с программой (`l2_t7_reserve`, `l2_t7b_reserve`,
`l2_t7h_reserve`). Свидетель: `unit_t7_many`, 26 merge, 26 привязок, 18 записей заголовков
([§62 журнала](fable-continuation-20261003.md#merge-actual)).

<a id="t7-actual-reference"></a>
### T7-ACTUAL-REFERENCE — 2026-10-04, fable, FIXED 2026-10-05

**Исправлено 2026-10-05.** Узел merge строится, когда merge исполняется, и единица к этому времени
построена целиком. Ячейку, которую единица держит во вложенном теле, узел достигает от единицы по её
собственным рёбрам (`l2_rw_cell`, `l2_emit_graph_unit_place`), как нативное тело. Строка
`unit_t7_actual_reference` зелёная: 9 и 45, нативно и с обходом корня. Держатель другого владельца —
метода или части программы — из узла merge по-прежнему не достигается, это отказ на месте
([§68 журнала](fable-continuation-20261003.md#reference-among-free-names)).

Запись до исправления:

Merge подан callable-формалу, а его модель читает ссылку, допуск которой идёт через Structure,
которую единица держит для результата merge:

```text
m: merge Model
fn: fivev (int: y) int
    return: y + m\v
fn: passed () int
    return: take: merge(y: 5; fivev)     # отказ на месте merge
```

Узел merge строится собственным конструктором, когда merge исполняется. Держатель, выделенный
конструктором единицы, там называется псевдонимом того конструктора, которого у конструктора узла
нет. Раньше такая программа не доходила до этого места (merge как фактическое не прослеживался);
без предела транслятор порождал C, который не компилируется. Отказ: `a callable merge whose body
reads a cell held in a nested body of the unit is not built yet`. Предел реализации, не правило.
Обязательный позитив, красный: `unit_t7_actual_reference` (по норме 9 и 45). То же имя через
удерживаемый merge работает (`unit_t7_reference_held`), типизированная ссылка единицы через формал
работает (`unit_t7_actual_typed_reference`)
([§62 журнала](fable-continuation-20261003.md#merge-actual)).

<a id="t7-host-body"></a>
### T7-HOST-BODY — 2026-10-04, fable, FIXED 2026-10-04; возврат из вложенного тела открыт отдельно

Метод, у которого до `return: merge(...)` есть оператор, отвергается на месте merge:

```text
fn: wrap (int: k) fn: (int: x) int
    int: other 50
    return: merge(y: k; add)      # отказ: assignment value has unknown type
```

Возвращающим merge признаётся только метод, всё тело которого — этот `return`: тогда `return` висит
на сигнатуре, и проверка значения возврата до него не доходит. С телом тот же `return` проверяется
как обычное значение, и выражение merge там не имеет типа. Это предел производителя и
классификации, не правило языка. Codex: «The current inability to put an earlier statement/field before return: merge is
implementation debt, not evidence that both readings are equally valid.» Измерено на `0a52fe7d` пробником вне гейта.
Обязательный позитив появится строкой харнесса вместе с исправлением
([§63 журнала](fable-continuation-20261003.md#twelfth-reply)).

Исправлено шагом четыре третьего среза. Метод, записанный с merge, который он возвращает
(`l2_t7_from_return`), исполняет операторы своего тела и строит узел один раз, там, где тело
кончается, со значением, которое связанное имя имеет в этом месте. Его `return` признаётся
оператором тела по записанному merge (`l2_t7_return_stmt`): проверка его обходит, как обходит
`return: модель`; нативное тело кончается построением; обходимое тело строит узел шагом возврата.
Под `--walk-methods` такой метод теперь обходится, раньше он молча оставался нативным. Строки
`unit_t7_host_body`, `unit_t7_host_bound_field` и их `_walk`: поле, цикл и `if` до возврата,
значение вызывающего раньше значения единицы, поле с именем связанного формала. Возврат merge из
вложенного тела метода остаётся пределом: [T7-HOST-NESTED-RETURN](#t7-host-nested-return)
([§66 журнала](fable-continuation-20261003.md#merge-node-construction)).

<a id="t7-host-nested-return"></a>
### T7-HOST-NESTED-RETURN — 2026-10-04, fable, OPEN (блокер G5)

Метод возвращает merge из вложенного тела и другой в конце:

```text
fn: wrap (int: k) fn: (int: x) int
    if: k > 3
        return: merge(add; y: k)      # отказ на месте merge
    return: merge(add; y: 1)
```

Возвращаемый merge метода строится в одном месте, оператором собственного тела метода. Merge во
вложенном теле отвергается на своём месте словами предела: «a merge returned from a nested body of its method is not built yet».
До шага четыре он отвергался как значение без типа, `assignment value has unknown type`. Это предел
производителя, не правило языка. Обязательный позитив `unit_t7_host_nested_return`, строка красная.
Тот же предел у возвращаемого вложенного определения: `return: модель` из вложенного тела
отвергается словами «a callable merge host names a nested method outside the return»
([§66 журнала](fable-continuation-20261003.md#merge-node-construction)).

<a id="host-builds-in-nested-body"></a>
### HOST-BUILDS-IN-NESTED-BODY — 2026-10-04, fable, FIXED 2026-10-04; было неверное значение без отказа

Метод, возвращающий вложенное определение, строил узел в конце первого вложенного тела своего
тела — цикла, `if` — и возвращал его оттуда. Нативно, без отказа:

```text
fn: makeAdder (int: n) fn: (int: x) int
    int: i 0
    while: i < 3
        n: n + 1
        i: i + 1
    ---
    fn: addN (int: x) int
        return: n + x
    return: addN

add5: makeAdder 5
int: a (add5: 1)          # нативно 7, по норме 9; с обходом метода 9
```

Измерено на `0781bf65` пробником вне гейта. Причина: `l2_emit_body_in` отдавал `l2_mad_host_body`
всякое тело метода-хоста, вложенное тоже, а тот кончается построением узла и возвратом. Цикл строил
узел и возвращал его в конце первого прохода. Гейтованные строки это не ловили: в
`unit_make_adder_char` вложенный `if` стоит последним перед возвратом, и раннее построение давало
то же значение. Найдено при исправлении [T7-HOST-BODY](#t7-host-body): тело до `return: merge`
унаследовало бы дефект.

Исправлено шагом четыре: телом хоста считается собственное тело метода, вложенное тело — его
операторы, как у всякого блока. Строки `unit_nested_definition_host_loop` и `unit_t7_host_body`
нативно, их `_walk` с обходом метода. Мутант с прежней маршрутизацией: обе красные нативно, их
`_walk` зелёные ([§66 журнала](fable-continuation-20261003.md#merge-node-construction)).

<a id="t7-node-lexical-links"></a>
### T7-NODE-LEXICAL-LINKS — 2026-10-04, fable по ответам Codex FABLE-CODEX-20261004-12; автор ответил 2026-10-05: читается копия, место `merge` родителя не задаёт; FIXED 2026-10-05 (Opus) на пути модели — метода единицы; рядом OPEN: T7-MODEL-ONLY-UNIT-METHOD, T7-MODEL-OPERAND-SOURCE

**Решение автора 2026-10-05** ([журнал автора](../LMX_blog/2026-10-05.md#merge-parent), вопрос закрыт:
[копия лексического состояния модели при merge и место нового корня](../LMX_blog/q/merge-lexical-copy-and-root-placement.md)).
`merge` копирует используемую часть дерева и переписывает `parent` внутри копии. Место, где исполнен
`merge`, не задаёт копии лексического родителя и не вызывает разрешения свободных имён в этом месте.
В примере вопроса копия читает 9, а не 50 метода, исполнившего `merge`, и последующего изменения
оригинала не видит. Обычный приоритет динамического входа прежний. Codex: «Do not infer that every
copied node gets parent=0: rewrite the actual source links under the existing source-to-copy
relation, respecting the established qualified immutable/native retention rules.» Чтение «место
выражения» отвергнуто; ниже оно осталось как история вопроса, измерения в силе. Запись остаётся
OPEN до исправления кода и гейта, ответа автора больше не ждёт. Ожидание обеих программ ниже — 9, 9,
9. Свидетель — вторая программа, асимметричная: лексическое `other` модели 9, собственное `other`
метода `make` 50, вызывающий его не подаёт. Копия читает 9 до и после того, как оригинал стал 11, а
чтение оригинала видит 11. Явный `node\other` в теле копии идёт по скопированной лексической связи.
Рядом — общий адресат, цикл, нативно и с обходом, обычный приоритет входа от вызывающего. Строки
появятся вместе с исправлением ([§73 журнала](fable-continuation-20261003.md#author-decisions-20261005)).

Узел, который строит merge, получает родителем `node` метода, давшего merge. Запасной источник
свободного имени модели в теле узла — живая ячейка поля единицы, впечатанная адресом при
построении узла. Копии используемого лексического состояния модели на момент merge нет, и тело
узла видит последующие изменения исходного поля. Это расходится с правилом копирования при любом
чтении: ответ автора на Q42 о копии merge ([журнал 2026-09-27](../LMX_blog/2026-09-27.md)) и его
слова о том, что копирование не создаёт подписку на дальнейшие изменения оригинального состояния
([response48.md](../LMX_blog/q/response48.md), §6).

До ответа автора было так. Что служит запасным источником — скопированное лексическое состояние
модели или поле места, где исполнен merge, — вопрос автору:
[копия лексического состояния модели при merge и место нового корня](../LMX_blog/q/merge-lexical-copy-and-root-placement.md).
`#composition` в одном абзаце требует копии используемых лексических цепочек и называет лексическим
родителем нового корня место выражения merge. Когда модель объявлена не там, где исполняется merge,
книга не говорит, как согласовать эти предложения. До ответа перенос родителя узла и
переразрешение свободных имён копии не реализуются, и ожидания строк в пользу одного чтения не
ставятся.

Отозвано. Первая редакция этой записи (`0781bf65`) называла нормой чтение «одноимённое поле места
построения идёт раньше поля единицы» и говорила, что выбора между чтениями нет. Это было моё
прочтение двенадцатого ответа Codex. Тринадцатый ответ его отменил: «My twelfth reply's demand to use real selected links was
not authorization to rebind all copied-body lexical references by names at the new construction site.»

От ответа не зависит следующее. Путь `node\x` идёт через выбранную Structure узла и предков вместо
неё не просматривает. Имён при исполнении, постоянного побочного графа контекста и новой записи
идентичности нет; копия существующих достижимых Structure источника — обычное копирование графа.
Гейт после ответа разводит значения единицы модели, места построения и скопированного контекста:
без входа от вызывающего, с перекрытием вызывающим, с явным доступом через `node`, с независимостью
от последующих изменений.

Свидетель в одной единице. Переменная видна только вперёд, поэтому вызов из корня выше объявления
`other` не имеет подачи от вызывающего. Поле единицы до того пишет метод явным путём `node\other`.
Программа с формалом `other` у `make`, байт в байт:

```text
int: z0 prep()
w: make 50
int: c1 (plain())
int: z1 bump()
int: c2 (plain())
int: other 9

fn: add () int
    return: other

fn: make (int: other) fn: () int
    return: merge(add)

fn: plain () int
    return: w()
end: plain

fn: prep () int
    node\other: 9
    return: 0
end: prep

fn: bump () int
    node\other: 11
    return: 0
end: bump

int: d (plain())
sendMessage: exit(exit_code: c1 * 10000 + c2 * 100 + d; stdout: ""; stderr: "")
return
```

Сегодня `c1`, `c2`, `d` равны 9, 11, 9. Копия состояния модели дала бы 9, 9, 9; место выражения —
50, 50, 9. Измерено на `0781bf65` пробником вне гейта: нативно, с обходом методов и с обходом
корня; после шага четыре то же. Значение 11 показывает прогоном, что узел читает живую ячейку.

Вариант с собственным полем `make`, измеримый после исправления
[T7-HOST-BODY](#t7-host-body). Формал активации и объявленное поле различаются: формал не становится
полем графа сам собой. Программа байт в байт:

```text
int: z0 prep()
w: make 0
int: c1 (plain())
int: z1 bump()
int: c2 (plain())
int: other 9

fn: add () int
    return: other

fn: make (int: d) fn: () int
    int: other 50
    return: merge(add)

fn: plain () int
    return: w()
end: plain

fn: prep () int
    node\other: 9
    return: 0
end: prep

fn: bump () int
    node\other: 11
    return: 0
end: bump

int: d (plain())
sendMessage: exit(exit_code: c1 * 10000 + c2 * 100 + d; stdout: ""; stderr: "")
return
```

После шага четыре, пробником вне гейта: 9, 11, 9 нативно, с обходом корня и с обходом всех методов,
`make` в том числе. Вызовы идут после возврата из `make`: поле `other` метода `make` в чтении не
участвует, узел живёт в арене программы под единицей. Те же два чтения дали бы 9, 9, 9 и 50, 50, 9.

Что эти прогоны показывают помимо вопроса. Выше объявления ячейка поля единицы существует и держит
0, пока оператор объявления не исполнен: без `prep` первое значение 0. Голое присваивание `other: 11`
в методе, вызванном выше объявления, ячейку единицы не меняет: имя там — вход активации по
значению. Ячейку пишет только явный путь `node\other`. Это две разные операции, и ни одна не меняет
общего правила объявления и присваивания.

Значение 11 — не ожидание. Строками харнесса обе программы станут после ответа автора, с
ожиданием по ответу, нативно и с настоящим обходом; до него ожидание не ставится. Ответ дан
2026-10-05: ожидание 9, 9, 9.

Отозвано вторым разом. Редакция `003c66d5` говорила, что в программе из одной единицы условие
«вызывающий не подаёт имя» не выполняется. Это слишком широко: гейтованная строка
`unit_a3_caller_binding` уже вызывает из корня выше его собственного объявления. Codex,
четырнадцатый ответ: «Do not confuse a materialized graph field with an eligible caller binding at that source position.»
Предел производителя [T7-MODEL-ONLY-UNIT-METHOD](#t7-model-only-unit-method) остаётся отдельным
обязательством ([§65 журнала](fable-continuation-20261003.md#fourteenth-reply)).

**Исправлено 2026-10-05 (Opus)**, по ответу Codex OPUS-CODEX-20261005-01, шаг T7. Конструктор узла
(`l2_t7_make_<site>`) при каждом merge копирует лексическое дерево модели. Модель — метод единицы, и
её дерево — дерево единицы. Копирует его тот же обход, что у merge и создания письма
(`lmx_graph_copy_profiles_owned`): общие адресаты и циклы сохраняют форму, `parent` каждой
скопированной Structure — копия её собственного, у ссылочного поля копируется ячейка, а адресат общий
(k3). Квалифицированные ветви программы удерживаются по точным профилям. Узел висит под копией, а
не под местом merge. Вид тела узла строится над копией: запасной источник свободного имени
(`AT` входной единицы) и `node\x` (родитель узла) читают состояние на момент merge. Операнды-модели
вида — модель переправы пути (`OF`), модель допуска (`ADMIT_AS`), свидетель входа — берутся из
единицы программы (`l2_nst`, `l2_rw_model_own` при `l2_rw_type_base`), а не из копии. Ядро ключует
запись допуска адресом требования: значение, допущенное до merge, записано против Structure
программы, против её копии записи нет. Что Structure программы — верный источник каждого такого
операнда, не показано: [T7-MODEL-OPERAND-SOURCE](#t7-model-operand-source), OPEN.

Свидетели, нативно, с обходом корня и с обходом методов. `unit_t7_copy_lexical_formal`: у `make` свой
формал `other` 50, копия читает 9 до и после того, как `bump` записал в единицу 11, а оригинал `add`
читает 11 — `T7 9 9 9 11`. `unit_t7_copy_lexical_node`: то же через `node\other` — `T7 9 9 11`.
`graph_shape_t7_copy_parent`: пути от ячейки `w` (шаги драйвера `deref`, `up`) находят родителя узла
отдельной копией единицы. В копии `other` и `m` — отдельные объекты, родитель скопированного `m` —
копия, как у оригинала единица. Квалифицированная ветвь `E` — тот же объект. Мутанты: тело над живой
единицей — `T7 9 11 9 11`; узел на месте merge — `T7 9 11 11` и пути копии; без удержания ветвей —
`samepath`. До исправления, на `62ef45df`: `T7 9 11 9 11` и `T7 9 11 11`.

Пределы. Копируется всё лексическое дерево единицы, не только используемое телом; цена merge
растёт с единицей — шаг A ([MERGE-COST-GROWS-WITH-UNIT](#merge-cost-grows-with-unit)). Неудача копии
останавливает программу, как любая другая неудача этого конструктора: бросок `merge` из построения
узла не построен. Записи допуска со скопированными значениями не копируются
([§77 журнала](fable-continuation-20261003.md#t7-copy)).

<a id="t7-data-first-shape"></a>
### T7-DATA-FIRST-SHAPE — 2026-10-04, fable по ответам Codex FABLE-CODEX-20261004-12, OPEN (блокер G5); решения автора не требует

Запись `merge(y: k; add)` в вызываемом месте транслятор читает так же, как `merge(add; y: k)`.
Моделью берётся единственный операнд, называющий метод единицы, на любой позиции (`l2_t7_fill`).
Каждый другой операнд обязан быть кадром `имя: значение`, который связывает int-формал модели
литералом или int-формалом метода, давшего merge. Заголовок принимающего места — результат `fn:`
хоста или контракт callable-формала — задаёт число аргументов узла. Формалы модели, которых в нём
нет, обязаны быть связаны (`l2_t7_header_match`), и связанный формал из интерфейса узла уходит.

Книга ([`#composition`](../docs/LMX_semantics.ru.md#composition)) говорит иначе в трёх местах:

- строка 951: модель результата — первый операнд;
- строка 955: `merge((n: 5); addN)` кладёт метод вложенным полем в Structure с `n`; вызывается он
  как `w\addN(...)`, и вызов самой `w` его не исполняет;
- строка 959: объявленный заголовок — тип принимающего места, не операнд композиции; формал со
  значением по умолчанию остаётся формалом и может быть подан явно.

Измерено на `0781bf65`, транслятор `b450f0c014fde9c2`, пробниками вне гейта:

| Запись | Сегодня |
| --- | --- |
| `return: merge(y: k; add)` и `return: merge(add; y: k)` у `fn: wrap (int: k) fn: (int: x) int`; `w: wrap 5`, затем `(w: 1)` | оба 6; L1 двух программ совпадает байт в байт |
| `take: merge(y: 5; five)` и `take: merge(five; y: 5)` | оба 5; L1 различается только порядком двух операндов в удержанной записи фактического для обхода |
| `(w: 1; y: 25)` после `w: wrap 5`, обе записи | отказ `unknown method` на `y` |
| `add5(1; y: 25)`, где тело `add5` — `merge(add; y: 5)` или `merge(y: 5; add)` | отказ `more arguments than add5 has formals`; иллюстрация книги даёт 26 |
| `q: merge(y: 5; add)`, затем `q\add(1; 2)`; `w: merge((n: 5); addN)`, затем `w\addN(1)` | отказ `unknown field path segment`: обёртки с вложенным методом нет |

Происхождение. T7 ([callable-merge-t7.md](callable-merge-t7.md)) посажен по тогдашнему тексту
книги: «где объявлен callable-тип, Structure с одним callable-вхождением приводится тем же merge,
модель — метод», и записал: «Модель — единственный метод среди операндов, не позиция». Реплики
автора 2026-09-25 ([журнал](../LMX_blog/2026-09-25.md)) называют `merge(y: 5; add)` обёрткой вокруг
`add` и спрашивают, решает ли объявленный тип приведение. Ответ автора на Q48
([response48.md](../LMX_blog/q/response48.md)) сделал заголовок типом принимающего места, не
операндом. Книга с `1460fc3c` и `99cc014f` держит три правила выше. План
[merge-callable-r48.md](merge-callable-r48.md), §4, назначал перевод фикстур на запись с моделью
первой и строку-отказ на запись с данными первыми. Он не исполнен.

Что закреплено строками. Запись с данными первыми стоит в `unit_pap_add5`, `unit_t7_convert`,
`unit_t7_from_int`, `unit_t7_header` и во всех строках `unit_t7_*`, добавленных `0a52fe7d`. Запись
с моделью первой стоит в `unit_pap_add5_method`. Там, где связанный формал не подаётся, значения
записи с моделью первой совпадают с книгой. Расхождение для неё — отказ на явной подаче
связанного формала, не неверное значение.

Что делать, по четырнадцатому ответу Codex: нового решения автора не нужно, действуют нынешние
правила `#composition`.

- `merge((n: 5); addN)` — обычная композиция. Первый операнд — внешняя модель, `addN` остаётся
  вложенным методом. Дефект — код, который берёт единственный метод единицы на любой позиции и
  делает результат его корнем.
- Общего отказа «данные первыми запрещены» не будет: это был бы ещё один особый случай.
  Принимающее вызываемое место применяет обычный допуск к значению, которое действительно
  построено. Если оно не даёт требуемых аргументов и результата, отказ следует из несовпадения
  интерфейса, не из порядка операндов. Обёртка не подменяется вложенным методом ради заголовка.
- Обязательные позитивы: построение обёртки и вызов вложенного метода путём `w\addN(...)`.
  Отказ принимающего контракта — отдельный негатив.
- Фикстуры. Операнды молча не переставляются. Где старая фикстура означала специализацию, она
  переводится на явную запись с моделью первой, с названным изменением исходника и ожидания.
  Прямые строки на запись с данными первыми и её обёртку остаются. Исторические входы остаются
  свидетельством.
- Строки этого среза пишутся записью с моделью первой. Их успех с одними значениями по умолчанию —
  ограниченный случай, не полная поддержка вызываемого merge: связанный формал обязан остаться в
  интерфейсе ([MERGE-KEEPS-MODEL-INTERFACE](#merge-keeps-model-interface)).

Переведена одна фикстура, с названным изменением: `unit_t7_actual_from_root` была написана
`merge(y: 5; five)` и была красной на пределе корня; шагом четыре она записана `merge(five; y: 5)`
и расширена. Остальные строки с данными первыми не тронуты. Производителя обёртки нет: запись
открыта
([§64](fable-continuation-20261003.md#thirteenth-reply) и
[§65 журнала](fable-continuation-20261003.md#fourteenth-reply)).

<a id="merge-keeps-model-interface"></a>
### MERGE-KEEPS-MODEL-INTERFACE — 2026-10-04, fable по ответу Codex FABLE-CODEX-20261004-12, OPEN (блокер G5)

`merge(add; y: 5)` обязан сохранить весь вызываемый интерфейс `add`: формал `y` получает значение по
умолчанию 5 и остаётся формалом. Заголовок принимающего места, требующий `x`, — требование
потребителя; он не стирает `y` и не переопределяет полную арность фактического. Источники:
ответ автора на Q48 ([response48.md](../LMX_blog/q/response48.md), §2.1 и §2.3) и иллюстрация
`#composition`.

Обязательные позитивы: `add5(1; y: 25)` даёт 26, `add5(1; y: 0)` даёт 1, затем `add5(1)` даёт 6.
Сегодня, на `0781bf65`: `add5(1; y: 25)` отвергается, «more arguments than add5 has formals», при
любой из двух записей тела. Узел, который строит merge в возврате метода или в фактическом
callable-формала, оставляет в своём интерфейсе только несвязанные формалы: `(w: 1; y: 25)`
отвергается, «unknown method».

Чинится обычная подготовка входов и значений по умолчанию, с полным контрактом фактического, его
исходным графом и координатами входов. Без неявного merge с заголовком, без постоянного объекта
частичного применения, без сокращения по позиции записи. Неизменённая нативная реализация
сохраняется по действующему правилу: построенный узел не обязан исполняться только обходом
([§65 журнала](fable-continuation-20261003.md#fourteenth-reply)).

<a id="t7-model-only-unit-method"></a>
### T7-MODEL-ONLY-UNIT-METHOD — 2026-10-04, fable, OPEN (блокер G5)

Моделью merge в вызываемом месте может быть только метод единицы. Удерживаемый callable, то есть
узел, построенный при исполнении, моделью не принимается:

```text
g: lib 0                            # g держит возвращённое вложенное определение
fn: make (int: other) fn: () int
    return: merge(g)                # отказ: a callable merge binds a name that is not a formal
```

Операнд, который не называет метод единицы, `l2_t7_fill` читает как связывание формала и отвергает.
Это предел производителя, не правило языка: по `#composition` операндом merge служит любая живая
Structure, прежний результат merge тоже. Предел закрывает и единственный пример, который в одной
единице различает чтения вопроса о лексической копии
([T7-NODE-LEXICAL-LINKS](#t7-node-lexical-links)). Измерено на `0781bf65` пробником вне гейта.
Обязательный позитив появится строкой харнесса вместе с исправлением; оно стоит рядом с полной
копией узла, построенного при исполнении
([RETURNED-NODE-PARTIAL-COPY](#returned-node-partial-copy)).

<a id="t7-trailer-only-model-crash"></a>
### T7-TRAILER-ONLY-MODEL-CRASH — 2026-10-05, Opus, FIXED 2026-10-05 (Opus); было падение транслятора

Метод, у которого нет тела, кроме завершающего `return:`, роняет транслятор как модель callable merge
(SIGSEGV), даже если результат merge никто не вызывает:

```text
int: k 5

fn: r () int
return: k                           # единственная строка r — его завершение

fn: make () fn: () int
    return: merge(r)                # l2trans: Segmentation fault
```

У такого метода нет Structure тела: `l2_m_body[r]` = 0. Проход счёта T7 (`l2_t7_count`) и проход
кадров (`l2_t7_emit_frames`) строят исходный контейнер из `l2_m_body[model]\as\structure` без проверки;
gdb на отладочной сборке останавливается на этой строке `l2_t7_count`. Проход шагов методов
(`l2_rw_methods_count`) и шаги результата merge (`l2_pap_steps`) такой метод принимают: тела нет,
обходится одно завершение. С `return:` в теле, с отступом, та же программа транслируется; без merge
метод `r` транслируется и в этой форме. Падение есть и на `62ef45df`, до копии T7. Измерено
пробником вне гейта ([журнал §77](fable-continuation-20261003.md#t7-copy)). Так же падал дескриптор
без тела и без завершения как модель merge, в обеих записях: `fn: d () int` и `fn: test3 () int` с
`end: test3`.

**Исправлено 2026-10-05 (Opus)**, по ответу Codex OPUS-CODEX-20261005-01. Проходы счёта и кадров T7
берут модель без Structure тела так же, как шаги результата merge (`l2_pap_steps`) и проход шагов
методов (`l2_rw_methods_count`): контейнера исходника нет, шагов тела ноль, обходится одно
написанное завершение. Оба прохода решают по одному условию, `l2_m_body[model]`, и проверка
`l2_t7_steps` сверяет число их шагов. Тело не создаётся, завершение не требуется, запись
исходника не переписывается. Дескриптор без тела и без завершения остаётся без реализации: его
merge отказан на месте merge — «a callable merge needs a walkable body», шагов нет; прямой вызов,
как и прежде, «not callable» (`unit_callable_descriptor_direct_refused`).

Свидетели, нативно, с обходом корня и с обходом методов. `unit_t7_trailer_only_never_invoked` —
программа дефекта: транслируется и идёт. `unit_t7_trailer_only_copy`: у `make` свой `k` 50, копия
читает 9 до и после того, как `bump` записал в единицу 11, оригинал `r` читает 11; вызывающий `k` не
даёт. `unit_t7_trailer_only_copy_indented` — та же программа с `return:` в теле, те же значения.
`unit_t7_trailer_only_formals`: связанный и данный формалы рядом со свободным именем. Отказ
`unit_t7_descriptor_model_refused`: `merge(test3)`, вызванный через `w`, отказан в 9:13. Мутанты:
падение, превращённое в отказ, — три программы с одним завершением отказаны; пустой шаг,
придуманный там, где завершения нет, — `unit_t7_descriptor_model_refused` транслируется и идёт;
проход кадров, пропускающий завершение модели без тела, — «a method's steps changed between the
passes». Повтор 1841 записанной трансляции `opus_full_07` новым транслятором: ни одна не меняется
([журнал §78](fable-continuation-20261003.md#t7-trailer-only)). Гейты на этих байтах: ядро
`opus_kernel_06` GREEN296, 113 исполненных селфтестов; L3 `opus_l3_06` 11 наборов; полный
`opus_full_08` RED40/1851 — против `opus_full_07` FAIL→OK 0, OK→FAIL 0, девять новых строк зелёные.

<a id="t7-model-operand-source"></a>
### T7-MODEL-OPERAND-SOURCE — 2026-10-05, Opus по обзору Codex OPUS-CODEX-20261005-01, OPEN (граница не показана)

В виде узла callable merge операнды-модели берутся из единицы программы, а не из копии, над которой
вид построен:

| Место | Операнд | Откуда берётся |
| --- | --- | --- |
| `l2_rw_path_value` | модель переправы пути (`OF`, ребёнок 3) на каждом пути, читаемом или записываемом через типизированную ссылку | именованная Structure — `l2_nst[req]`; собственная Structure результата merge (K02c) — `l2_rw_model_own`, место от `l2_program_unit` |
| `l2_rw_admit_project` | модель допуска (`ADMIT_AS`, ребёнок 4) | собственная Structure результата merge — `l2_rw_model_own`; именованная — `l2_nst[req]` |
| `l2_rw_input_witness` | свидетель входа | callable — его вхождение из `l2_program_unit`; дескриптор — `l2_nst[model]` |

Основание измерено узко. Три строки, где узел читает ссылку, данную вызывающим
(`unit_t7_reference_held`, `unit_t7_actual_reference`, `unit_t7_actual_typed_reference`), с моделями
из копии стояли на `walk error: INVALID`: `lmx_implements_slot` не нашёл записи значения
вызывающего против копии модели — ядро ключует запись допуска адресом требования. Это довод
реализации, а не правило языка. По L2 (`#copy-merge`, `#type-by-range`, `#lowlevel-address`) имя
модели обозначает обычную Structure, используемую как требование, а не отдельную категорию типов;
`#composition` копирует используемые адресаты и переписывает их связи, общими остаются удерживаемые
нативные реализации и допущенные квалифицированные вечные ветви. Использование как модели
исключением из копии не является. Отсутствие записи у копии — вопрос реализации и доказательства, а
не довод, что копия недопустима или что нужно брать модель источника (Codex). Острее всего вид 2:
контракт K02c читал место модели-результата merge, когда операция исполняется, в единице вида —
теперь это копия, а переключатель читает результат merge программы.

Что показать — по месту на каждый операнд, к какой категории он относится: (a) уже выбранный
свидетель схемы и координат принимающего объявления; (b) значение источника, читаемое из
скопированного лексического графа, в том числе обычная Structure, используемая как требование;
(c) фактический кандидат и его запись — его физическая раскладка не тождество требования. Для
каждого — почему указатель на единицу программы не меняет ни связывания источника, ни наблюдаемого
скопированного состояния; для действительно динамического выражения требования — его верный
физический источник, не единица программы огулом. Парный контроль: скопированное обычное требование
или путь результата merge и типизированный динамический кандидат, с имеющейся записью допуска и без
опоры на прежнюю регистрацию; наблюдать физический источник модели и адресуемое поле кандидата, а
не совпавшее число. Если связывание модели заменяется по её обычному контракту — асимметричная
замена в оригинале и в копии. Обычный допуск устанавливается там, где он нужен, без повторной
проверки на каждом шаге; без имён во время исполнения, реестра имён моделей, новой категории типов и
скрытого графа замыкания ([журнал §78](fable-continuation-20261003.md#t7-trailer-only)).

<a id="held-reference-chain"></a>
### HELD-REFERENCE-NOT-ASKED-ALONG-CHAIN — 2026-10-04, fable, FIXED 2026-10-05; было неверное значение без отказа

**Исправлено 2026-10-05.** Удерживаемый вызов спрашивает ссылки своего определения по цепочке
вызывающих, как числа (`l2_dyn_site_held`): имя, которого вызывающий метод не связывает, становится
его собственным входом, который он только передаёт дальше. Программа ниже даёт 45, нативно, с обходом
корня и с обходом методов (`unit_held_reference_chain` и `_walk`). То же верно для Structure, которую
определение берёт у своего метода-фабрики: раньше она по цепочке не спрашивалась вовсе, и привязка
вызывающего двумя методами выше терялась без отказа. Без привязки имя приходит отсутствующим через
оба метода, и определение читает копию своего узла (`unit_held_capture_chain` и `_walk`: 35, 25, 45).
У входа, объявления которого метод не видит, нет схемы; объявления, которые до него доходят,
записываются, и значение допускается по тому объявлению, которое оно несёт
([§68 журнала](fable-continuation-20261003.md#reference-among-free-names)).

Запись до исправления:

Ссылка, которую читает удерживаемое определение, не спрашивается по цепочке вызывающих. Программа
транслируется и даёт неверное значение, без отказа:

```text
m: merge Model                     # v 4
fn: makeUse (int: k) fn: () int
    fn: g0 () int
        return: k + m\v
    return: g0
u0: makeUse 5
fn: inner () int
    return: u0()
end: inner
fn: outer () int
    m: merge Model
    m\v: 40
    return: inner()                # по норме 45; даёт 9
end: outer
```

`inner` не связывает `m` и для ссылки не получает входа, поэтому определение читает `m` единицы, а
ближайшая привязка вызывающего теряется. Для чисел это исправлено в §60; про ссылку там сказано
словами, что она по цепочке ещё не спрашивается, но измеренного неверного значения в записи не
было. Измерено на `0a52fe7d`, нативно и с обходом методов, пробником вне гейта. Прямой вызов из
метода со своей ссылкой отвергается пределом
([HELD-FREE-REFERENCE-OTHER-DECLARATION](#held-free-reference-other-declaration)); через
callable-формал ссылка идёт верно (`unit_held_actual_reference`). Обязательный позитив появится
строкой харнесса вместе с исправлением, в шаге о ссылке
([§63 журнала](fable-continuation-20261003.md#twelfth-reply)).

<a id="free-reference-no-declaration"></a>
### FREE-REFERENCE-NO-DECLARATION — 2026-10-05, fable, FIXED 2026-10-05

**Исправлено 2026-10-05.** Среди объявлений, которые доходят до такого имени, одно, имеющее все пути
метода, служит координатным пространством этих путей (`l2_anchor_close`). Это не тип имени: Structure
другого объявления допускается к нему только по путям, которые метод использует, обычным допуском.
Какое объявление взято, на результат не влияет. Запись по такому пути ждёт замыкания, как чтение.
Программа ниже даёт 31 нативно и с обходом. Строки: `unit_free_path_read`, `_order`, `_order_swapped`,
`_first_lacks`, `_other_refused`, `_other_chain_refused`, `_write`, `_null`, `_null_read_walk`,
`_none_refused`, `_value_none_refused`, `_write_none_refused`, `_deep_none_refused`, `_letter`,
`_typed_place`, `_two_readers`, `_argument`, `_deep`, с парами `_walk` у позитивов
([§70 журнала](fable-continuation-20261003.md#free-name-path)).

Поправка того же дня по двадцать первому ответу Codex -12. Поиск координатного пространства имел
жёсткие потолки и отвергал программу за ними; они убраны
([ANCHOR-FIXED-CEILINGS](#anchor-fixed-ceilings)). Отказ там, где два объявления дают читаемому полю
разные типы, был записан как правило; это предел, и его программы стали обязательными позитивами
([FIELD-CONSUMPTION-CONVERSION](#field-consumption-conversion)). Остаётся пределом, с отказом на
месте: до имени доходят только значения без раскладки
([§71 журнала](fable-continuation-20261003.md#no-ceiling)).

Запись до исправления:

Метод читает поле по пути через имя, которого в его видимости ничто не объявляет:

```text
Model:
    int: v 4
end: Model
fn: r () int
    return: box\v + 1              # отказ: root operation not walkable yet: a field path
end: r
fn: mid () int
    return: r()
end: mid
fn: has () int
    box: merge Model
    box\v: 30
    return: mid()                  # по общему правилу свободного имени 31
end: has
int: a has()
```

Для числа такое свободное имя работает: его даёт вызывающий по цепочке
(`unit_held_call_required_input_from_caller`). Для ссылки у входа нет схемы, и чтение пути
отвергается на месте. Измерено пробником вне гейта на байтах шага §68, нативно и с обходом методов.
Строка `unit_reference_required_unbound_refused` показывает только отказ там, где цепочка начинается
(`unbound dynamic input box`): её позитивная половина упирается в этот предел
([§68 журнала](fable-continuation-20261003.md#reference-among-free-names)).

Codex, восемнадцатый ответ -12: «Q1: YES, the program is valid when the callers supply an admissible
Structure under box.» И: «#dynamic:702-704 applies to a FREE NAME irrespective of whether its value is
consumed directly or is the root of a structural path.» И: «This does NOT authorize guessing a new
contextual type, adding a hidden interface Structure or finding field names during execution.»
Обязательные строки по ответу: позитив 31 нативно и с обходом, кандидат с другим порядком полей,
отказ при отсутствии поля, контроли порядка объявлений, контроль поданной пустой ссылки. Строки
появятся вместе с исправлением, следующим срезом
([§69 журнала](fable-continuation-20261003.md#dynamic-admission)).

<a id="typed-place-letter-readmission"></a>
### TYPED-PLACE-LETTER-READMISSION — 2026-10-05, fable, FIXED 2026-10-05 (Opus) для допуска по использованию потребителя; приём целиком и по покрытию открыт (блокер G5)

Письмо принято в ссылку своего объявления и подано потребителю другого объявления, который читает
только поле, общее для обоих:

```text
MainLetter:
    char: []: []: mainArgs
end: MainLetter
Long:
    char: []: []: mainArgs
    size_t: size 0U
end: Long
fn: observe (Long: shared) int
    return: 2 + (cast: (int) length(shared\mainArgs))
end: observe
fn: caller () int
    @: MainLetter m
    receiveMessage: m
    return: observe(m)             # отказ при исполнении; по использованию потребителя 2 + число аргументов
end: caller
```

Трансляция проходит: `MainLetter` имеет поле, которое потребитель читает. При исполнении значение не
несёт раскладки: письмо принято в `MainLetter` по позициям, и это свидетельство о тождестве, а не о
раскладке. Допуск к `Long` тогда проверяет письмо по позициям против всей модели `Long` и отказывает.
Соответствие должно идти через объявление места, в котором значение лежит: поля `MainLetter` у
письма на своих позициях, а пара `MainLetter` → `Long` известна при трансляции. То же через свободное
имя и через поле, связанное с письмом (`MainLetter: b raw`). Измерено пробниками вне гейта на
`43140744`: нативно процесс останавливался, с обходом — `implements`; после шага §69 это `implements`
в обоих режимах
([§69 журнала](fable-continuation-20261003.md#dynamic-admission)).

Codex, девятнадцатый ответ -12: «b) TYPED-PLACE-LETTER-READMISSION: YES, the observe(m) program is
valid by the Consumer's use of mainArgs, and this is G5-blocking shared admission/correspondence
debt. Reuse/compose an ACTUALLY ESTABLISHED value->MainLetter correspondence with the
translation-resolved MainLetter->Long used-path mapping. Merely declaring the source place MainLetter
is not such a proof.» И: «Add native/walk positives and a newly requested missing-field negative.»
Запись `MainLetter: b raw` как объявление по этому ответу свидетелем не служит. Чинится следующим срезом
([§70 журнала](fable-continuation-20261003.md#free-name-path)).

**Исправлено 2026-10-05 (Opus) для допуска по использованию потребителя.** Приём письма в место
объявления по позициям (`receiveMessage:` в типизированное место, связывание `m: @raw`, допуск к
формалу своего объявления) оставляет запись (значение, объявление) без кадра, без карты и без дыр.
Где формируется вход, допущенный по использованию потребителя, допуск спрашивает эту запись
(`lmx_implements_identity`) и берёт карту пары «объявление → модель входа», известную при трансляции.
Спросить можно объявление отдающего места и объявления, которые доходят до него по записанным рёбрам
(возможные якоря, `l2_d105a_close`; рёбра через непрозрачный формал записываются отдельно,
`l2_d105x_add`). Объявление предлагается, только если даёт каждый путь, который читает потребитель.
Если отвечает объявление отдающего места, решает оно; иначе ответившие должны совпасть по целям
первых шагов потребителя, а два разных класса дают отказ. Порядок записей и проверка по позициям не
решают. Раскладка значения остаётся неизвестной. Нативный текст и ADMIT_AS выбирают одинаково.
Объявление типизированной ссылки, которая передаёт свободное имя дальше, служит пространством координат
этого имени (двадцать первый ответ, Q3). Строки: `unit_letter_place_other`, `_hidden`, `_forward`,
`_missing_field` (отказ там, где формируется вход, пойман: 42), `_free_name`, `unit_letter_alias_after`,
все с парами `_walk`. Мутанты транслятора `noid`, `noconsumer`, `noanchors`, `noxedge`, `innerkeep`,
`nowitness`, `nos` и мутанты ядра `k_*`
([§72 журнала](fable-continuation-20261003.md#letter-typed-place)).

Открыто: приём целиком и по покрытию (типизированная ссылка другого объявления, возвращаемое значение)
записей тождества не предлагает, и письмо в месте `MainLetter`, связанное ссылкой `Long`, отвергается
как прежде. Письмо, которого ни один приём не записал, —
[UNRECORDED-LETTER-WHOLE-MODEL](#unrecorded-letter-whole-model). Ветвь двух классов не достигается ни
одной программой: единственное значение без своей раскладки сейчас — письмо argv из одного поля. У
ветви walker есть селфтест, у нативной ветви свидетеля нет.

<a id="unrecorded-letter-whole-model"></a>
### UNRECORDED-LETTER-WHOLE-MODEL — 2026-10-05, Opus по ответу Codex на OPUS-HANDOFF-20261005-103112, OPEN (блокер G5)

Письмо подано без типа формалу `Long` раньше, чем какой-либо приём записал его в `MainLetter`:

```text
fn: observe (Long: shared) int
    return: 2 + (cast: (int) length(shared\mainArgs))
end: observe
fn: take () int
    receiveMessage: raw
    int: a observe(raw)            # по использованию потребителя 2 + число аргументов
    @: MainLetter m
    m: @raw
    int: b observe(m)
    ...
end: take
```

`observe` читает только `mainArgs`, и письмо несёт его в своём единственном поле: по использованию
потребителя программа верна при обоих вызовах. У первого допуска нет записи приёма, которую можно
спросить, а значение без своей раскладки по-прежнему проверяется по позициям против всей модели `Long`,
где на поле больше. R0 останавливается непойманным выбросом, код 1, нативно и с обходом. Codex в ответе
на начало шага: «A before case that the implementation cannot yet establish must be labelled an
evidence/coverage limit, not a normative required negative». Обязательный позитив, красный:
`unit_letter_alias_before`. Исправление — допуск значения без своей раскладки по использованию
потребителя, а не по всей модели
([§72 журнала](fable-continuation-20261003.md#letter-typed-place)).

<a id="walked-unknown-actual-double-admission"></a>
### WALKED-UNKNOWN-ACTUAL-DOUBLE-ADMISSION — 2026-10-05, Opus, FIXED 2026-10-05; был отказ только с обходом

Вызов с обходом допускал кандидата, которого трансляция не может назвать, дважды. Сначала шёл допуск
против всей модели по структуре (`l2_rw_struct_arg` → `l2_rw_reference_receive`), затем допуск места
вызова по использованию потребителя, который в нативном тексте единственный. Через непрозрачный формал
первый допуск отказывал там, где второй допускает: письмо в месте `MainLetter`, поданное через
`(@: void p)` формалу `Long`, нативно давало 2 + n, а с обходом методов R0 останавливался. Измерено
на строках `unit_letter_place_forward` и `unit_letter_alias_after` с обходом методов до исправления.

**Исправлено 2026-10-05.** Первый допуск делается только там, где у места вызова нет своего допуска,
и для письма, названного фактическим: такой приём берёт письмо как полезную нагрузку (D-57), так же,
как нативный текст. Первая форма исправления убрала и случай письма, и три строки стали красными с
обходом (`unit_admit_dynamic_actual_catch` и её пара, `unit_site_constructor_reception`); прогон
фокуса поймал это до ворот. Мутант `innerkeep`
([§72 журнала](fable-continuation-20261003.md#letter-typed-place)).

<a id="factory-result-receiver"></a>
### FACTORY-RESULT-RECEIVER — 2026-10-05, Opus по решению автора (Codex, AUTHOR-FACTORY-REF-20261005-114610), FIXED 2026-10-05 (Opus)

Решение автора 2026-10-05 ([журнал автора](../LMX_blog/2026-10-05.md#factory-reference-result), вопрос закрыт:
[запись результата фабрики и определение именованного тела](../LMX_blog/q/held-factory-initialization-versus-body-definition.md)):
результат фабрики принимается явным приёмником `@:`. Пример makeAdder в переписи Codex; это применение
существующих правил, не слова автора:

```text
fn: makeAdder (int: n) fn: (int: x) int
    fn: addN (int: x) int
        return: n + x
    return: addN

@: add5 makeAdder(5)
@: add100 makeAdder(100)

[add5(1); add100(1); add5(1)]    # [6 101 6]
```

Общее правило дремлющего тела (Q58) остаётся. Неизвестная голова, хвост которой начинается именем
известного метода, определяет именованную Structure и ничего не вызывает; короткая, скобочная и
блочная записи этим не различаются. Короткая запись T6 `add5: makeAdder 5` как связывание с
результатом вызова больше не норма. Контракт возвращаемого callable — лексическая копия и динамические
входы — не меняется: решение о том, как принимается результат.

Реализация расходится. Измерено транслятором `f8ef5d8b…`, только трансляция, вне гейта:
`@: add5 makeAdder(5)` отвергается и в корне, и в методе: `unsupported body` (кадр `@`). Короткая
запись по-прежнему транслируется со старым смыслом. `l2_unit_role` считает оператор значением вызова,
когда хвост отсутствующей головы начинается атомом метода единицы (`l2_call_value`), и фабрика
вызывается там, где стоит оператор. На этом построены строки T6 и удерживаемых callable, среди них
`unit_make_adder*`, `unit_held_call_*`, `unit_pap_add5*`, `unit_named_actual_held`. Полный перечень
снимается по классификации самого транслятора в шаге переноса, не поиском по тексту.

Что нужно. Приём результата через `@:` — обычным путём приёмника и понижения выражения, без
исключения по имени фабрики или по записи. Строки, задуманные как инициализация результатом фабрики,
переносятся на `@:`, и у каждой названа миграция. Парные свидетели: обычное именованное тело фабрику
сразу не вызывает, нативно и с обходом
([§73 журнала](fable-continuation-20261003.md#author-decisions-20261005)).

**Исправлено 2026-10-05 (Opus)**, по ответу Codex OPUS-CODEX-20261005-01, шаг FACTORY. Приёмник
`@: h f(a)` — оператор с головой `@`: первое поле — имя `h`, второе — кадр вызова метода
(`l2_receiver_call`). Вызов — обычный кадр: связывание связывает его фактические, именованные тоже;
проверка — `l2_check_call` этого кадра; нативный код — `l2_emit_call` и запись в поле `h`; обход
строит тот же вызов (`l2_rw_mad_store`). Механизм хранения callable-merge, который раньше узнавал
форму `h: f a`, теперь узнаёт приёмник (`l2_mad_store_stmt`, `l2_store_host`, `l2_store_name`).
Поле `h` объявлено через `@`, поэтому это ссылка: в слоте ячейка-указатель (q26), и ячейка держит
callable, который вернул вызов. Унарный `@` не добавляется.

Короткая запись — определение. `l2_call_value` удалён из `l2_unit_role` и `l2_local_ns_shape`:
неизвестная голова, хвост которой начинается именем метода, определяет именованную Structure и
ничего не вызывает (Q58). Голое имя метода в её теле — применение без фактических.

Порядок единицы. Приёмник выше элемента корня объявляет имя для этого элемента (`l2_head_absent`):
`h2: 3 4` ниже приёмника применяет `h2`. Метод выше приёмника привязки `h2` не имеет
(`unit_held_call_above_unknown_head`).

Перенос: 171 фикстура (233 строки гейта, 246 приёмников) переписана с `h: f a` на `@: h f(a)`, и
первая строка каждой называет миграцию. Перечень снят классификацией самого транслятора
(инструментированная сборка), не поиском по тексту. Перепись считала операторы верхнего уровня
единицы и операторы методов. Две фикстуры с записью во вложенном теле корня (`if:`-блок,
`unit_held_call_block` и `unit_held_call_block_refused`) нашло воспроизведение всех 1826 трансляций
`opus_full_04` новым транслятором: вне перечня изменились только их три строки. Иглы с номером
строки сдвинуты на строку заголовка. В `graph_shape_t7_local_definition` физические пути проходят ячейку ссылки явным шагом
драйвера `deref`. Новые строки: `unit_factory_receiver_named` — именованный фактический в приёмнике
метода, `OUTER 101 7`; `unit_factory_short_dormant` — ни `s: shout`, ни `t: shout()` ничего не печатают
нативно, с обходом корня и с обходом методов; `unit_factory_short_args_refused` — голое имя метода с
обязательным аргументом в теле определения отвергается, 11:7
([§76 журнала](fable-continuation-20261003.md#factory-receiver)).

<a id="head-role-unestablished-rows"></a>
### HEAD-ROLE-UNESTABLISHED-ROWS — 2026-10-05, Opus по решению автора (Codex, DOC-BATON-AUTHOR-20261005-115300), FIXED 2026-10-05 (Opus)

Решение автора 2026-10-05 ([журнал автора](../LMX_blog/2026-10-05.md#unknown-head-return), вопрос закрыт:
[роль головы `h: хвост`, когда вход `h` ничем заранее не установлен](../LMX_blog/q/head-role-hidden-input-fixed-point.md)).
В примере вопроса `x: j` при неустановленной привязке определяет именованную Structure `x`, и
`return: x` — ошибка преобразования типа: результата `int` нет. Codex: «later return: x does not
retroactively make x a hidden primitive input.» Уже установленные свободные имена остаются обычными
неявными входами активации. Одного одноимённого значения у вызывающего для смены роли головы мало.

Строки держат отвергнутое чтение «позднее чтение устанавливает вход»: это красные обязательные
позитивы раздела 13 журнала. `unit_free_conv` и `unit_walk_free_conv` имеют форму вопроса (`target`:
`k: j`, затем `return: k`); по решению это отказ при `return: k`. `unit_colon_hidden_update` читает
голову в её собственном хвосте (`hidden: hidden + 1`, затем `return: hidden`); покрывает ли решение
такое чтение, спрошено у Codex до смены ожидания. `unit_asgn_fallback` (ожидает отказ `unbound
dynamic input x`) сверяется с решением в том же шаге. Ожидания меняются шагом, который несёт строки
в гейт ([§73 журнала](fable-continuation-20261003.md#author-decisions-20261005)).

**Исправлено 2026-10-05 (Opus)**, по ответу Codex OPUS-CODEX-20261005-01, шаг HEAD. Codex закрыл
вопрос о самочтении: «Reading hidden in that definition's own tail does not circularly establish a
primitive input». Аудит строк нашёл настоящий дефект транслятора `849ea1b5`. Исполняемое свободное
чтение имени до оператора не устанавливало вход. Объявления единицы собираются
(`l2_collect_asgn_binds`, роль спрашивает `l2_local_ns_shape`) раньше, чем скан свободных имён
(`l2_dyn_local`) создаёт хотя бы один вход. Поэтому голова, прочитанная методом раньше, получала
роль определения, а следующие проходы, которые вход уже видят, отвечали иначе. На этом были красными
`unit_own_dirty_rhs` и `unit_arg_addr_dyn_types` (`more arguments than … has formals`). Метод,
который читает `hidden`, а затем пишет `hidden: hidden + 1`, отвергался при `return`.

Исправление — в общем пути роли. После прежних проверок `l2_local_ns_shape` спрашивает, прочитал ли
метод голову как свободное имя до оператора (`l2_head_read_before`). Ответ даёт сам скан свободных
имён (`l2_scan_body`), запущенный пробой: из собственного окружения метода, с остановкой на
операторе до его хвоста. Проба ничего не создаёт: ни строк, ни отметок, ни захватов, ни входов.
Оператор раньше сохраняет роль, которую ему дал сбор: строку, которую он объявляет. До связывания
вызовов метка именованного аргумента не считается чтением — так её прочтёт связывание
(`l2_scan_actuals`). Ответ для оператора хранится до конца трансляции (`l2_head_read_kept`), и
каждый проход получает тот же.

Перенос строк по решению автора. `unit_colon_hidden_update` — отказ 12:13 `return value has
incompatible type`. `unit_asgn_fallback` — отказ 17:8 `unresolved name`: у `inc` нет входа `x`, а `x`
в теле Structure `x` никто не связывает. В `target` строк `unit_free_conv` и `unit_walk_free_conv`
появилось чтение `k` до записи. Сами строки теперь останавливаются на независимом пределе
[FREE-CONV-U-LITERAL-WALK](#free-conv-u-literal-walk). Новые строки: `unit_head_established_read`,
`unit_head_established_lexical`, `unit_head_block_read`, `unit_head_initializer_read`,
`unit_head_chain_read` с обходимыми двойниками; отказы `unit_head_unestablished_return_refused`,
`unit_head_later_read_refused`, `unit_head_label_refused`, `unit_head_shadow_refused`
([§75 журнала](fable-continuation-20261003.md#head-role-established)).

**Поправка 2026-10-05 (ревью Codex, OPUS-CODEX-20261005-01).** Решение автора задаёт роль головы в
`inc`: у `inc` нет входа `x`. Отказ 17:8 у `x` в теле Structure `x` решением автора не был. Codex:
«the author's return:x answer ALONE does not make unit_asgn_fallback a normative negative». Тело `x`
никто не вызывает, а его `x` — свободный вход этого тела, и его мог бы дать вызывающий `x`. Отказ —
предел реализации [DORMANT-BODY-FREE-INPUT](#dormant-body-free-input). Строка теперь обязательный
позитив с наблюдаемым результатом хоста: `inc` возвращает 7 обоим вызывающим. Она красная до
исправления.

<a id="dormant-body-free-input"></a>
### DORMANT-BODY-FREE-INPUT — 2026-10-05, Opus по ревью Codex (OPUS-CODEX-20261005-01); часть 1 (отказ у вызова) исправлена 2026-10-05, часть 2 (тело, которое никто не вызывает) OPEN (блокер G5)

Codex: «Defining a named body does not execute it; the spec permits unresolved/free names to be
retained and resolves required inputs at actual calls (semantics #construction and #dynamic).» И: «If
it is a potentially supplied free value and only the current translator cannot lower that generic
body, record a located implementation/coverage limit, not an author-approved language prohibition. A
later explicit call without an admissible source is a CALL failure; don't hoist it onto inc's inert
definition.»

Измерено отладочной сборкой транслятора шага FACTORY, по стеку на `l2_error`. Тело именованной
Structure, определённой в методе, получает свою строку вызываемого, после строки корня. Свободное
имя тела — вход этой строки. Тело никто не вызывает, поэтому ни один источник не даёт входу тип. А
замыкание входов (`l2_dyn_close` → `l2_dyn_typed`) требует тип у каждого входа каждой строки. Отсюда
отказ `unresolved name` у свободного имени. `unit_asgn_fallback`: строка 4 из 5 (Structure `x` в
`inc`), вход `x`, 17:8 при `01ecd69b`. `unit_local_ns_stmt_unresolved`: строка 2 из 3 (`S` в `m`),
вход `nosuch`, 7:12. Имя здесь не неразрешено по норме и не указывает на саму Structure. Это
свободный вход вложенного вызываемого, и его мог бы дать вызывающий.

Тем же способом разобраны все 38 строк гейта, которые ожидают `unresolved name`:

- 2 строки — тела никем не вызываемых именованных Structure (выше);
- 4 строки — свободное имя корня: вызывающего нет, отказ по норме;
- 18 строк — вход метода или Structure единицы без типа (`l2_dyn_typed`). Почти везде метод
  вызывается без источника: отказ верен по норме, но стоит у использования имени, а не у вызова, с
  которого начинается цепочка. Две строки отличаются, и не одинаково (поправка по ответу Codex
  ниже): `broken` в `unit_colon_graph_unknown_value_refused` не вызывается вовсе, а `Counter` в
  `unit_named_struct_dead_tail_refused` вызывается, хотя имя читается только после голого `return`;
- 14 строк — сегмент пути, который ничего не называет (`l2_check_fields`, `l2_check_primary`):
  другой механизм.

Что нужно. Тело, которое никто не вызывает, не требует типа своих входов. Вызов без источника
отвергается у вызова, с которого начинается цепочка, как вход, который никто не может дать
(`unit_held_call_required_input_unavailable_refused`). Строки, все красные до исправления:
`unit_asgn_fallback` и `unit_local_ns_stmt_unresolved` — обязательные позитивы (были ожидаемыми
отказами); `unit_dormant_free_body` — `y: z + 1` в `make`, никто не связывает `z`, корень говорит
`MADE 7`; `unit_dormant_free_body_call_refused` — `y()` вызван, источника `z` нет, отказ у вызова
`make()` в корне, 13:10, `unbound dynamic input z`. Сегодня он отвергается у `z`, 8:8
([§76 журнала](fable-continuation-20261003.md#dormant-body-free-input)).

**Ответ Codex 2026-10-05 (OPUS-CODEX-20261005-01, ревью чекпойнта FACTORY).** Правило допуска одно для
входов с типом и без: «A required input with no admissible source makes the CALL inadmissible. A type
learned elsewhere must not decide whether this failing call is reported as an unresolved use or a
missing binding.» Основное место отказа — недопустимый вызов, с которого начинается цепочка, после
того же завершённого замыкания источников и требований, что для входов с типом. Исходное чтение может
быть вторым, поясняющим местом. Комментарий в `l2_dyn_site_callee` о разделении входов с типом и без —
история реализации, не норма. Неразрешимые значения исполняемого корня и сегменты пути остаются
отдельно, как и недопустимые по существу формы в сохранённом теле.

- Строки класса (c) переходят на место вызова вместе с исправлением. Каждая разбирается тогда же:
  отказ по входу вызова идёт к вызову, значение исполняемого корня остаётся где стоит. Нынешние места
  отказов при `1b86feaf` — датированное свидетельство, каждый перенос записывается.
- `unit_colon_graph_unknown_value_refused`: `broken` не вызывается — тот же класс, что тела выше. Строка
  станет обязательным позитивом с наблюдаемым результатом хоста. Рядом встанет отдельный отказ явного
  вызова без источника. Собственные проверки тела `broken` остаются.
- `unit_named_struct_dead_tail_refused` — не этот класс. `Counter` вызывается явно, а `g` в записанном
  теле — часть интерфейса вызываемого (#dynamic). Отбрасывать вход по недостижимости кода спецификация
  не разрешает. Вызов без источника `g` — отказ у вызова `Counter`, не у `g`. Рядом встанут два
  свидетеля. В первом вызывающий даёт `g`: вызов допустим, `return` не даёт хвосту исполниться,
  сохранённый граф хвост содержит. Второй — мёртвый хвост, недопустимый по существу: проверка — не
  исполнение.

**Часть 1 исправлена 2026-10-05 (Opus).** Правило допуска одно. Из корня вход, который никто не может
дать, делает вызов недопустимым у этого вызова, есть у входа тип или нет (`l2_dyn_site_callee`).
Удерживаемый вызов спрашивает у вызывающего каждый вход модели, с типом и без (`l2_dyn_site_held`), а из
корня вход без типа, который никто не может дать, отвергает сам удерживаемый вызов тем же словом, что
`l2_held_unbound` для входа с типом. Повтор 1850 записанных трансляций `opus_full_09`: меняются ровно 17
строк, все — отказы до и после: 15 строк класса (c), `unit_named_struct_dead_tail_refused` (теперь у
вызова `Counter`, 9:1) и `unit_dormant_free_body_call_refused` (13:10, её записанная игла, — зелёная).
Каждая игла перенесена, «было → стало» в
[§80 журнала](fable-continuation-20261003.md#one-admission-rule). Новые строки:
`unit_named_struct_dead_tail_given` с двойником (вызывающий даёт `g`: вызов допущен, хвост не исполнен,
граф его держит), `unit_named_struct_dead_tail_invalid_refused` (мёртвый хвост, недопустимый по
существу: отказ проверки, 7:10), `unit_held_call_untyped_input_refused` и
`unit_held_call_untyped_root_refused` (вход без типа через удерживаемый вызов: отказ у вызова, с которого
начинается цепочка). Мутанты: без обеих частей — 17 строк и обе удерживаемые снова у чтения; без части
удерживаемого вызова — обе удерживаемые. Гейты: ядро `opus_kernel_08` GREEN296, 113 исполненных
селфтестов; L3 `opus_l3_08` 11 наборов; полный `opus_full_10` RED39/1856 — против `opus_full_09`
FAIL→OK 1, OK→FAIL 0, добавлено 5, все зелёные.

Часть 2 открыта. Тело, которое никто не вызывает, не компилируется без типа своего свободного входа:
проба без отказа замыкания останавливается у подписи процедуры («dynamic input type has no formal
spelling»), у оператора тела («assignment value has unknown type»), у вызова в обходе. Во что такое тело
компилируется, спрошено у Codex; четыре позитива (`unit_dormant_free_body`, `unit_asgn_fallback`,
`unit_local_ns_stmt_unresolved`, будущий позитив `unit_colon_graph_unknown_value_refused`) остаются OPEN.

Предостережение Codex к исправлению: не пропускать `l2_dyn_typed` для невызываемых строк и не удалять
их тела. Требования отложенных входов сохраняются обычным адресным механизмом, и поздний вызов без
источника отвергается по правилу выше. Если обобщённого понижения сохранённого тела нет, предел
остаётся OPEN. Угаданный скалярный тип, нулевой вход, таблица имён при исполнении, скрытый граф
контекста и неопределённый нативный ABI недопустимы.

<a id="free-conv-u-literal-walk"></a>
### FREE-CONV-U-LITERAL-WALK — 2026-10-05, Opus, OPEN; обязательные позитивы красные на пределе реализации

`ret_expr` в `unit_free_conv` читает `int` `k` вызывающего там, где нужен `size_t`, и прибавляет
литерал: `return: k + 1U`. Трансляция отвергает его: `root operation not walkable yet: a U literal in
a signed type` (16:17). Это предел производителя сохранённого графа, не правило языка: чтение
свободного имени преобразуется в `size_t` до сложения. Измерено транслятором `849ea1b5` пробником
вне гейта: та же программа без метода `target` отвергается тем же отказом. Раньше его заслонял
отказ в `target`. При `7124005` строка принималась ([журнал ревью](review-log.md)). Этот же предел
стоит в долгах G5 как «два производителя `int`/`1U`». `unit_free_conv` и `unit_walk_free_conv`
остаются красными обязательными позитивами до шага о числовом преобразовании
([§75 журнала](fable-continuation-20261003.md#head-role-established)).

<a id="reception-edge-debts"></a>
### RECEPTION-EDGE-DEBTS — 2026-10-05, fable по ответу Codex FABLE-CODEX-20261004-12; пункты (c)–(f) исправлены 2026-10-05 (Opus); письмо через непрозрачное место — LETTER-THROUGH-OPAQUE-PLACE, OPEN

Четыре отказа при трансляции, измеренные в §69, Codex классифицировал как долги реализации, не
правила языка. Позитивы и контроли появятся вместе с исправлением каждого.

- Результат вызова непрозрачного типа, поданный прямо в Structure-формал, отвергается: `implements is
  false in function argument`. То же значение через локальную ссылку допускается при исполнении.
  Codex, пункт (c): «implementation LIMIT/defect, not a language rule requiring a named result model.
  Ordinary result reception must apply the same conversion/admission, evaluating the producer once.»
  **Исправлено 2026-10-05 (Opus).** Результат вызова непрозрачного типа (`@: void`), как и имя такого
  типа, не считается фактическим параметром Structure по своему типу. Проверка берёт сам вызов,
  кандидат динамический (место результата вызываемого), допуск — там, где формируется вход. Вызов
  вычисляется один раз, в свой временный. Место результата доходит до формала (`l2_d105_note`), и
  формал читает по имени источники, которые дают возвраты вызываемого. Результат другого типа (число,
  ссылка на уровень глубже) отвергается, как прежде. Тем же ребром исправлено приведение указателя,
  поданное прямо
  ([CAST-ACTUAL-READ-BY-POSITION](#cast-actual-read-by-position)). Свидетели и мутанты — в
  [§81 журнала](fable-continuation-20261003.md#inline-opaque-result). Через локальную ссылку
  непрозрачного типа Structure другого объявления остаётся UNKNOWN и отвергается при исполнении: это
  класс OPAQUE-ACTUAL-KNOWN-LAYOUT, он идёт с пунктом (d). Гейты: ядро `opus_kernel_09` GREEN296,
  113 исполненных селфтестов; L3 `opus_l3_09` 11 наборов; полный `opus_full_11` RED39/1864 — против
  `opus_full_10` FAIL→OK 0, OK→FAIL 0, добавлено 8, все зелёные.
- Кандидат, выбранный при исполнении среди двух объявлений, одно из которых не подходит, отвергается
  за саму возможность. Codex: «d) A merely POSSIBLE incompatible dynamic source is not proof that
  every call is incompatible. Keep the actual runtime selection and ordinary admission: the good
  branch succeeds, the incompatible branch fails catchably at the receiving edge.» И: «verify your
  @Good/@Other spelling FIRST: unary @Structure adds a level and addresses its reference cell.» Мой
  пробник писал именно `@ Good`; глубину надо перепроверить до исправления. Тот же класс под
  свободным именем измерен в §70: Structure без поля, поданная через непрозрачный формал в
  типизированную ссылку и дальше под свободным именем, отвергается при трансляции.
  **Исправлено 2026-10-05 (Opus).** Написание проверено: пробы дают Structure как `@: void` по имени
  (`return: good`, `run(good)`), это ссылка глубины один; унарного `@` нет. У входа источник, которого
  Consumer входа не допускает, — возможный кандидат, если каждое ребро, которое его приносит, приносит
  из того же места и кандидата, которого Consumer допускает (`l2_d105_possible`): ни один вызов через
  такое ребро не доказан несовместимым. У возможного кандидата нет таблицы пар, он ничего не помечает,
  и допуски, сформированные во вход, не дают ему альтернативы ни native, ни в обходе
  (`l2_d105_refused`). При исполнении его значение не находит ни записи, ни альтернативы, и допуск
  отказывает: это неявный `implements` формирующего метода (§69). Любой другой недопустимый источник
  определённый и отвергается при трансляции, как прежде: и тот, которого не приносит ни одно ребро,
  и тот, которого ребро приносит без допустимого рядом. Правило — по ребру, не по входу:
  `unit_free_path_other_refused` остаётся отказом у вызова дающего, 25:13. Перенесена одна строка:
  `unit_free_path_other_chain_refused` отвергала при трансляции, 17:13, кандидата, которого ребро от
  `mid` к `r` приносит рядом с Model из `has`. Теперь `has` даёт 31, а вызов `bad` отвергается при
  исполнении, необработанным. Класс §70 исполняется: `unit_free_path_typed_place_thin`. Свидетели,
  мутанты и перенос — в [§82 журнала](fable-continuation-20261003.md#possible-candidate). Гейты: ядро
  `opus_kernel_10` GREEN296, 113 исполненных селфтестов; L3 `opus_l3_10` 11 наборов; полный
  `opus_full_12` RED39/1882 — против `opus_full_11` FAIL→OK 0, OK→FAIL 0, добавлено 18, все зелёные.
- Непрозрачная ссылка вызывающего под свободным именем, которое читатель объявляет типизированной
  ссылкой: `incompatible entry signature`. Codex: «e) An opaque reference supplied as a hidden input
  to a typed reference use has the same receiving-edge conversion/admission as the explicit analogue,
  provided actual reference depth/type is correct.»
  **Исправлено 2026-10-05 (Opus).** У места вызова `@: void` вызывающего принимается против входа,
  который читатель берёт как ссылку графа, только глубины один; `@@: void` отвергается, как прежде.
  Место без схемы, которое держит то, что ему дали (непрозрачная ссылка, непрозрачный формал), с §82
  имеет в записи объявления, которые до него дошли. Его значение допускается по тому из них, которое
  оно несёт, native и в обходе, как у явного аналога; без записи — позиционно, как прежде. Model даёт
  11, Other читается по имени, 9, Thin отвергается при исполнении у формирующего метода, 42
  (`unit_recv_hidden_opaque_typed`). Вместе исправлен край аргумента
  ([ARGUMENT-EDGE-REFERENCE-TYPE](#argument-edge-reference-type)). Свидетели и мутанты — в
  [§83 журнала](fable-continuation-20261003.md#hidden-opaque-typed).
- Письмо, возвращённое через непрозрачный формал как типизированный результат: `implements is false
  in return value`. Codex, пункт (f): «absence of a named source schema is not proved
  implements-false. Classify the premature refusal as implementation debt if the actual value
  satisfies the result's consuming contract and permitted conversion.»
  **Исправлено 2026-10-05 (Opus) для значения непрозрачного типа.** Возвращённое имя `@: void` или
  результат вызова такого типа — динамический кандидат: объявления, которые до него доходят, — источники
  результата, и метод записан как бросающий `implements`. Допуск возврата по всем полям типа результата
  при исполнении отказывает неявным `implements` возвращающего метода — и у возврата хвоста, и у
  оператора `return:` внутри тела (это два эмиттера). У места результата возможный
  кандидат (§82) допускается только из мест непрозрачного типа: лишь их возврат отказывает через
  `implements`. Model даёт 4, Other читается по имени, 9, Thin отвергается при исполнении, 42; результат
  вызова непрозрачного типа — 4 (`unit_recv_opaque_return_typed`). Само письмо из записи теперь
  транслируется, но при исполнении отвергается, как и его явный аналог:
  [LETTER-THROUGH-OPAQUE-PLACE](#letter-through-opaque-place). Свидетели и мутанты — в
  [§84 журнала](fable-continuation-20261003.md#opaque-return).

Отдельно о лишней остановке процесса у кандидата, который не динамический: «remove the duplicate stop
for genuinely compiler-proven static producer/admission cases. But "constructed by this
declaration/merge" is not alone proof that a subsequently READ reference still denotes that origin.»
Пути перепривязки, взятого адреса и утечки ссылки по ответу надо проверить до снятия остановки.
([§70 журнала](fable-continuation-20261003.md#free-name-path)). Перепись и динамическая часть —
[DUPLICATE-ADMISSION-STOP](#duplicate-admission-stop).

<a id="duplicate-admission-stop"></a>
### DUPLICATE-ADMISSION-STOP — 2026-10-05, Opus по ответу Codex FABLE-CODEX-20261004-12; динамическая часть исправлена 2026-10-05, статическая — 2026-10-05 в форме по умолчанию (вопрос Codex)

Остановка процесса «lmx: invariant: an admission by name was refused» в сгенерированном допуске.
Перепись на трансляторе §84 по 1881 записанной трансляции `opus_full_12`: 296 мест в 147 строках.
286 — у статического кандидата (Structure по значению или результат merge, прямое свидетельство
источника), там отказ дублирует доказательство трансляции. Пробы перепривязки (`base: wide`, второе
`o: merge Other`) и взятого адреса места или его ячейки ссылки (`@@: void cell @o`, `@@: Model cell
@o`) все отвергаются при трансляции. 10 — на возврате значения из места, которое держит то, что ему
дали: типизированный формал, место результата вызова, собственная типизированная ссылка. Там
происхождение не доказано.

**Динамическая часть исправлена 2026-10-05 (Opus).** По правилу Codex «If current origin is not
proved, use the common dynamic admission rather than a defensive abort or assumed YES» такой возврат
допускается по всем полям типа результата неявным `implements` возвращающего метода, у возврата
хвоста и у оператора в теле; метод записан как бросающий. В `unit_merge_value_schema` все шесть
остановок были такими; строка закреплена без текста остановки (`Absent`). Мутант без эмиттера
возвращает шесть остановок, мутант без проверки даёт внутреннюю ошибку в трёх строках
([§85 журнала](fable-continuation-20261003.md#duplicate-stop)).

**Статическая часть, 2026-10-05 (Opus), в форме по умолчанию.** Если снять отказ, остаётся запись
допуска (`lmx_implements_register_map`), которая нужна чтениям по имени. Она отвечает не YES лишь при
нарушенном инварианте транслятора или когда таблица записей арены не растёт. Codex спрошен о форме
остатка. По умолчанию, названному в вопросе, у статического места остаются проверка и остановка, но
текст остановки говорит, что отказало: «lmx: invariant: the record of a proved admission was not
kept». Без проверки потерянная запись остановила бы процесс позже, у первого чтения по имени («no
record, or a hole»). Бросок `implements` сделал бы бросающим каждый метод с таким местом из-за памяти,
а не из-за программы. `unit_site_model_shadow` закрепляет новый текст у статического места,
`unit_merge_value_schema` — его отсутствие у динамических возвратов. Три мутанта красны по этим
закреплениям ([§86 журнала](fable-continuation-20261003.md#duplicate-stop-static)). Если Codex выберет
иную форму, меняется одно место эмиттера.

<a id="letter-through-opaque-place"></a>
### LETTER-THROUGH-OPAQUE-PLACE — 2026-10-05, Opus, OPEN (вопрос Codex)

Письмо, переданное через непрозрачное место, не допускается к своему собственному объявлению:

```text
MainLetter:
    char: []: []: mainArgs
end: MainLetter
fn: count (MainLetter: l) int
    return: 1
fn: pass (@: void p) int
    return: count(p)
receiveMessage: m
int: a pass(m)                     # R0 остановлен непойманным выбросом
```

Напрямую `count(m)` допускает письмо по его полезной нагрузке (D-57). Через непрозрачное место значение —
запись письма, и допуск проверяет эту запись против модели. Измерено на трансляторе §80 и на шаге (f).
Форма на возврате — `back (@: void p) MainLetter`, возвращающий письмо, — это программа, которую Codex
отнёс к пункту (f): до шага (f) она отвергалась при трансляции, теперь транслируется и останавливается
так же. Допускается ли непрозрачная ссылка на письмо к объявлению письма по его нагрузке, спрошено у
Codex ([§84 журнала](fable-continuation-20261003.md#opaque-return)).

<a id="opaque-actual-known-layout"></a>
### OPAQUE-ACTUAL-KNOWN-LAYOUT — 2026-10-05, fable; FIXED 2026-10-05 (Opus) пунктом (d) RECEPTION-EDGE-DEBTS; были внутренняя ошибка транслятора, неверное значение без отказа и отказ при исполнении

Structure известного объявления подана через непрозрачный формал в Structure-формал:

```text
Model:
    int: a 1
    int: v 4
end: Model
fn: c (Model: box) int
    return: box\v + 1
end: c
fn: via (@: void p) int
    return: c(p)                   # internal: a pair map of D-105 was asked for after the maps were declared
end: via
m: merge Model
int: a via(m)                      # по общему правилу допуска 5
```

Текст допуска перечисляет объявления, записанные у непрозрачного формала. Замыкание, которое
резервирует соответствия полей, явное фактическое из непрозрачного формала не прослеживает, и пары
нет. С одним письмом в том же формале программа работает: у письма раскладки нет. Измерено
транслятором вне гейта на `bfeef8cc` и на этапах `fable_full_30`, `_36`, `_38`, `_39`, `_40`: ошибка
везде. Ни одна строка харнесса такой формы не имеет. Это тот же край, что пункт (d) выше, и чинится
вместе с ним
([§70 журнала](fable-continuation-20261003.md#free-name-path)).

**Неверное значение без отказа, измерено 2026-10-05 (Opus).** Если объявление с другим порядком
полей подходит, программа той же формы транслируется и читает не то поле:

```text
Model:
    size_t: value 4U
end: Model
Other:
    size_t: pad 1U
    size_t: value 9U
end: Other
fn: get (Model: x) size_t
    return: x\value
fn: run (@: void p) int
    return: (cast: (int) get(p))
int: a run(good)                   # Model: 4
int: b run(wide)                   # Other: 1 вместо 9
```

Измерено на зафиксированном трансляторе `14e8d29f`: native, с обходом корня, с обходом методов —
везде 1. Источники формала `p` (Model, Other) записаны, и допуск в `run` находит раскладку Other и её
таблицу пар. Но ребра от места `p` к формалу `get` нет: `get` не помечен как читающий по имени и
читает по позиции. С Thin (без поля) та же программа даёт внутреннюю ошибку выше: пару, которую нельзя
построить, просят при эмиссии. Причина одна: фактический параметр — имя непрозрачного типа — не
записывает ребро D-105 к формалу. У приведения указателя этот недостаток исправлен шагом (c)
([CAST-ACTUAL-READ-BY-POSITION](#cast-actual-read-by-position)), у имени он чинится с пунктом (d).

**Рядом измерено 2026-10-05 (Opus).** Тот же класс через локальную ссылку. `@: void q same(wide)`,
затем `get(q)` со Structure другого объявления (её `value` — второе поле) отвергается при исполнении
как `implements` формирующего метода: обработчик берёт отказ (42, native и с обходом методов).
При этом `get(same(wide))` в той же программе читает 9. Локальная ссылка не записывает источников
своего инициализатора и не отдаёт их формалу. Допуск встречает раскладку, о которой у трансляции нет
записи (UNKNOWN), и считает её отказом. В §69 программы одной трансляции, доходящей до UNKNOWN, не
нашлось; это она. То же объявление проходит по своей записи построения. Чинится с пунктом (d)
([§81 журнала](fable-continuation-20261003.md#inline-opaque-result)).

**Исправлено 2026-10-05 (Opus), пунктом (d) RECEPTION-EDGE-DEBTS.** Фактический параметр — имя
непрозрачного типа — записывает ребро D-105 к Structure-формалу, как Frame с шага (c): формал получает
источники имени, читает по имени, и пары резервируются при проверках, до объявления таблиц. Непрозрачная
локальная ссылка держит то, что ей дали: источники её инициализатора и присвоенного значения — её
(`l2_check_receiving_value`). Пара, которую нельзя построить, у возможного кандидата не просится: его
значение отвергается при исполнении. Программа этой записи даёт 5 (`unit_opaque_actual_known_layout`),
Other через непрозрачный формал читается по имени, 9 (`unit_recv_opaque_formal_by_name`), через
непрозрачную локальную ссылку — тоже 9 (`unit_recv_opaque_local_by_name`); выбор Model или Thin через
формал — 4 и пойманный `implements`, 42 (`unit_recv_possible_formal_catch`). Мутанты без ребра имени и
без источников локальной ссылки возвращают внутреннюю ошибку, 61 и 62
([§82 журнала](fable-continuation-20261003.md#possible-candidate)).

<a id="cast-actual-read-by-position"></a>
### CAST-ACTUAL-READ-BY-POSITION — 2026-10-05, Opus, FIXED 2026-10-05; был неверный код без отказа транслятора

Приведение указателя, поданное прямо в Structure-формал, читалось по позиции:

```text
fn: get (Model: x) size_t
    return: x\value
fn: run (@: void p) size_t
    return: get((cast: (@: void) p))   # p держит Other: pad, value
```

`run(wide)`, где у Other поле `value` второе, давал 1 — первое поле Other — без отказа. Измерено на
зафиксированном трансляторе `14e8d29f`: native, с обходом корня и с обходом методов. Приведение
сохраняет источники операнда (`l2_reference_source`), но до формала они не доходили, и формал не
читался по имени. Исправлено шагом (c) [RECEPTION-EDGE-DEBTS](#reception-edge-debts): если фактический
параметр — Frame и не Structure по своему типу, место его источника доходит до формала
(`l2_d105_note`). Свидетель — `unit_recv_cast_actual_by_name` с двойником; мутант без ребра даёт 61
во всех режимах ([§81 журнала](fable-continuation-20261003.md#inline-opaque-result)).

<a id="argument-edge-reference-type"></a>
### ARGUMENT-EDGE-REFERENCE-TYPE — 2026-10-05, Opus; FIXED 2026-10-05 (Opus) с пунктом (e) RECEPTION-EDGE-DEBTS; была остановка в сгенерированном коде без отказа транслятора

Край аргумента не проверяет тип ссылки имени, поданного в Structure-формал. Локальная `@@: void` или
`@: char` допускается при трансляции:

```text
fn: deeper (@: void p) @@: void
    return: @ p
@@: void q deeper(base)
size_t: r get(q)                   # get (Model: x): процесс остановлен у чтения
```

Присваивание типизированной ссылке отвергает ту же пару: «assignment value has incompatible type».
Программа с `@@: void` останавливает процесс у чтения: «lmx: invariant: a field path met no
Structure», exit 3. Это остановка в сгенерированном коде там, где нужен отказ трансляции. Результат
вызова того же типа отвергается при трансляции, «implements is false in function argument» (строка
`unit_recv_call_depth_result_refused`). Измерено на зафиксированном трансляторе `14e8d29f`. Codex о
пункте (e) RECEPTION-EDGE-DEBTS: «provided actual reference depth/type is correct». Проверка глубины и
типа ссылки на крае аргумента одна для имени, вызова и скрытого входа; чинится с пунктом (e)
([§81 журнала](fable-continuation-20261003.md#inline-opaque-result)).

**Исправлено 2026-10-05 (Opus), с пунктом (e).** Имя, ссылка которого на уровень глубже формала или
типа, в котором Structure не держится (`@: char`), отвергается там, где оно подано, словами, которые
есть у результата вызова того же типа: «implements is false in function argument». `@: void` и ссылка
графа проходят. Строки `unit_recv_name_depth_refused` (13:11) и `unit_recv_name_char_refused` (13:13);
мутант без проверки их транслирует
([§83 журнала](fable-continuation-20261003.md#hidden-opaque-typed)).

<a id="write-only-path-root"></a>
### WRITE-ONLY-PATH-ROOT — 2026-10-05, fable, FIXED 2026-10-05; был неверный код без отказа транслятора

Метод, который только пишет по пути через имя и ничего через него не читает, не получал это имя от
вызывающего:

```text
box: merge Model
fn: set () int
    box\v: 3                       # корень заголовка не читался как имя
    return: 1
end: set
fn: has () int
    box: merge Model
    return: set()                  # по правилу свободного имени пишется box вызывающего
end: has
```

В позиции значения корень пути — отдельный атом, и обход свободных имён его встречает. Заголовок
оператора — один текст, и его корень читался только в модели callable merge (пункт 738). Для имени,
которое объявляет единица, запись шла в то объявление такого написания, которое нашло разрешение
пути: при вызывающем со своей Structure того же имени разрешение находило поле этого вызывающего,
сгенерированный код называл переменную другой функции, и его отвергал компилятор C (`'l2_gp1'
undeclared` на программе выше, измерено на `bfeef8cc`). Для имени без объявления запись отвергалась:
`unknown field path root`.

**Исправлено 2026-10-05.** Корень заголовка читается так же, как атом в позиции значения
(`l2_scan_head_root`), а запись об имени узнаёт заголовок как место чтения (`l2_source_text`). Строки:
`unit_field_path_write_only`, `unit_free_path_write`, обе с парами `_walk`. Мутанты `nohead` и
`nosource`
([§70 журнала](fable-continuation-20261003.md#free-name-path)).

<a id="held-definition-undeclared-name"></a>
### HELD-DEFINITION-UNDECLARED-NAME — 2026-10-05, fable, OPEN (блокер G5); верность программы подтверждена Codex

Возвращённое определение само читает имя, которого ничто не объявляет:

```text
fn: makeUse (int: k) fn: () int
    fn: g0 () int
        return: k + n              # отказ: a callable merge binds a name that is not a formal
    return: g0
u0: makeUse 5
fn: same () int
    int: n 40
    return: u0()                   # по правилу свободного имени 45
end: same
```

Определение, которое вызывает метод единицы, читающий такое имя, работает
(`unit_held_call_required_input_from_caller`). Когда имя читает само определение, трансляция
отказывает словами, которые читаются как правило о связывании merge. Для ссылки с путём то же.
Измерено транслятором вне гейта на `bfeef8cc`
([§70 журнала](fable-continuation-20261003.md#free-name-path)).

Codex, двадцать первый ответ -12: «Confirm HELD-DEFINITION-UNDECLARED-NAME is a valid OPEN positive and
G5 debt.» И: «same() must return 45: k retains its ordinary captured value, n is a required dynamic
input supplied from the caller's available context.» И: «The old T7 prohibition concerns
unsupported/invalid BINDING operands of a callable specialization; it does not prohibit a model body's
free name.» Чинить по ответу надо обычным замыканием требуемых входов и формированием вызова, не
захватом. Обязательный позитив, красный: `unit_held_definition_free_name` (по норме 45). Вместе с
исправлением нужны строки: число и ссылка с путём, пересылка, поданные ноль и пустая ссылка остаются
присутствующими, отказ при отсутствии источника
([§71 журнала](fable-continuation-20261003.md#no-ceiling)).

<a id="anchor-fixed-ceilings"></a>
### ANCHOR-FIXED-CEILINGS — 2026-10-05, найдено Codex в `752f87c8`, FIXED 2026-10-05

Поиск координатного пространства (§70) держал кандидатов в 64 ячейках, достигнутые места в 256 и
сравнивал шаг пути через копию в 128 байт. Программа за любым из трёх потолков отвергалась словами
предела, называвшими другую причину. Ошибка моя. Codex, двадцать первый ответ -12: «These are precisely
the arbitrary length/count limits the author has already forbidden, including in translation metadata.
They are not justified by being compile-time-only, nor by diagnosing the result as an implementation
limit.»

**Исправлено 2026-10-05.** Блоки поиска имеют размер из самой программы: кандидат — именованное
объявление единицы, место — заданное место или дающий конец записанного ребра. Достигнутые места
служат списком работы, каждое посещается один раз, поэтому цикл методов заканчивается без максимума.
Шаг пути сравнивается на месте по своей длине. Отказ аллокации остаётся отказом аллокации. Строки:
`unit_free_path_many_declarations` (70 объявлений), `unit_free_path_many_places` (262 пересылающих
метода, два в цикле), `unit_free_path_long_step` и `_long_step_other_refused` (имя поля 141 байт), с
парами `_walk` у позитивов
([§71 журнала](fable-continuation-20261003.md#no-ceiling)).

<a id="d105-fixed-ceilings"></a>
### D105-FIXED-CEILINGS — 2026-10-05, fable, FIXED 2026-10-05

Таблицы допуска по имени были блоками постоянного размера: 64 формала, допущенных по имени, 256
источников, 128 рёбер, 64 пары типов, 128 ячеек одного соответствия (объявление не шире 64 полей).
За потолком трансляция отказывала: `too many formals admitted by name`, `too many named types admitted
to Structure formals (D-105)`, `too many formals passed on to Structure formals (D-105)`, `too many
pairs of types admitted by name (D-105)`; для объявления шире 64 полей —
`internal: an admission map has no completed physical schema`. Найдено свидетелями шага §71: каждый из
них, пройдя потолок поиска, упирался в один из этих.

**Исправлено 2026-10-05.** Таблицы растут вместе с программой; ячейки соответствия имеют размер по
ширине требуемого объявления. Строки: `unit_formal_many_admitted` (70 формалов),
`unit_formal_wide_model` (70 полей), и те же `unit_free_path_many_declarations` и `_many_places`
([§71 журнала](fable-continuation-20261003.md#no-ceiling)).

<a id="long-use-left-out"></a>
### LONG-USE-LEFT-OUT — 2026-10-05, fable, FIXED 2026-10-05; был принят неверный кандидат без отказа

Использования метода собирались в 128 байт. Путь, который не помещался, молча опускался: чтение поля с
именем длиннее 127 байт через формал не входило в использования, и кандидат без этого поля допускался.

```text
fn: r (Model: box) int
    return: box\<имя в 141 байт> + 1
end: r
fn: bad () int
    box: merge Near                # у Near такого поля нет
    return: r(box)                 # транслировалось; по норме отказ
end: bad
```

Измерено транслятором `752f87c8`: трансляция проходит, а при исполнении процесс останавливается:
`lmx: invariant: a field of a formal admitted by name is not carried by its value (no record, or a
hole)`, код 3. Ни одна программа гейтов такого имени не имела.

**Исправлено 2026-10-05.** Путь собирается по своей длине (`l2_uses_scan_follow`), и проверка кандидата
сравнивает шаг на месте (`l2_descriptor_used`). Строки: `unit_formal_long_field` (31 и 41) и
`unit_formal_long_field_other_refused` (отказ `implements is false in function argument`). Мутант
`usesdrop`
([§71 журнала](fable-continuation-20261003.md#no-ceiling)).

<a id="field-consumption-conversion"></a>
### FIELD-CONSUMPTION-CONVERSION — 2026-10-05, fable по ответу Codex FABLE-CODEX-20261004-12, OPEN (блокер G5)

Два объявления дают полю, которое метод читает, разные типы: `Model` с `int: v` и `Wide` с
`size_t: v`; метод пишет `int: got box\v`. Под свободным именем путь отвергается на месте одинаково
при любом порядке объявлений. Для объявленного формала кандидат отвергается: `implements is false in
function argument`. Я записал первый отказ как правило. Codex, двадцать первый ответ -12: «Do not
promote the symmetric disagreement refusal into a language rule. Semantics #three-argument-implements
requires leaf_consumption_admitted(actual.p, Consumer, p), not equality of the anchor's primitive
field spelling.» И: «Wide's size_t field must be read at its REAL type/width, then processed by the
existing ordinary size_t -> int converter if the program's supplied primitive.convert context admits
that edge.» И: «YES, the same criterion applies to the DECLARED analogue.» И: «This is NOT a
universal promise that all differing numeric fields are interchangeable.» Адрес поля и запись в поле
по ответу сохраняют настоящий тип поля.

Отказ под свободным именем остаётся пределом и так себя называет: `the declarations reaching a free
name give a field the method uses different types; reading it by conversion is not built yet`.
Обязательные позитивы, красные: `unit_free_path_field_converted`, `_swapped` и
`unit_formal_field_converted` (по норме 31 и 41). Исправление зависит от преобразования на принимающем
крае (двадцатый ответ) и строится вместе с ним. Вместе с ним нужны строки по ответу: пары с обходом,
отказ конвертера и отсутствующий конвертер, отдельно точный адрес и тип указуемого
([§71 журнала](fable-continuation-20261003.md#no-ceiling)).

<a id="merge-cost-grows-with-unit"></a>
### MERGE-COST-GROWS-WITH-UNIT — 2026-10-05, fable, OPEN; причина измерена 2026-10-05 (Opus), связывание исправлено (A1), обход сборщика открыт

Копия именованной Structure в методе стоит тем дороже, чем больше единица. N объявлений и N методов,
каждый копирует одно объявление и читает поле; свободных имён нет.

| Транслятор | N = 8 | N = 12 | N = 16 | N = 20 |
| --- | --- | --- | --- | --- |
| `bfeef8cc`, без свободного имени | 3 с | | 43 с | |
| шаг §71, со свободным именем | 4 с | 20 с | 65 с | больше 120 с |

Время исполнения программы, без трансляции и компиляции. Стек показывает копию графа ядром под
`lmx_merge_profiles_owned`: `lmx_graph_copy_many_profiles_staged`, `lmx_copy_process`,
`lmx_arena_blocks_tail`. Рост близок к четвёртой степени N. Первая форма свидетеля с 70 объявлениями
делала 70 копий и не закончилась за одиннадцать минут. Причину я не искал: это не маршрут этого
шага. Свидетели шага дают вызывающим ссылку на Structure объявления и копий не делают
([§71 журнала](fable-continuation-20261003.md#no-ceiling)).

**Измерено 2026-10-05 (Opus)**, по ответу Codex OPUS-CODEX-20261005-01, шаг A: счётчики в
пробных копиях ядра, факторы раздельно — размер единицы, число merge, размер квалифицированной
ветви, которую копия не должна копировать, число полей. Копия data merge — вся единица вместе с
кадрами кода: 64, 90, 142 и 246 Structure при N = 2, 4, 8 и 16; повторные merge её не растят.
За ход корня ничего не освобождается, и каждый `push` блока обходил весь растущий список: при
N = 16 в копиях 822 млн шагов. Но главная цена — проход сборщика в конце хода: на каждый блок
`lmx_gc_block_live` обходит все массивы и чанки, на каждый снятый блок — `lmx_gc_block_unlink`,
`lmx_gc_drop_arrays_in_block`, `lmx_arena_array_drop`, линейный `lmx_range_drop` и
`lmx_arena_blocks_remove` с обходом до хвоста; при N = 16 около 2,04 млрд шагов. Ещё в копиях:
поиск массива по виду, типу и профилю (46 млн сравнений), обход чанков после бисекции
(19 млн), поиск дубля в списке массивов (15 млн). Квалифицированная ветвь копировалась вместе с
единицей ([DATA-MERGE-COPIES-QUALIFIED-BRANCH](#data-merge-copies-qualified-branch)); каждое её
поле стоило около трёх чанков: массив, сделанный по запросу одной ячейки, растёт чанками той же
ширины, так что каждая ячейка — свой чанк, два блока и интервал; рядом копия имени поля.

**Исправлено (A1).** `lmx_arena_blocks_push` и `lmx_arena_array` связывают за постоянное время,
без обхода списка: каждый рабочий вызывающий отдаёт узел или массив, который только что сделал
или освободил и который не стоит ни в одном списке; удаление, перенос и освобождение по-прежнему
обходят список и отвергают цикл. Ожидания селфтеста «duplicate tail rejected» и «push into cycle
rejected» были только защитными и сняты явно; добавлен свидетель порядка и владения. После: в
копиях 0 шагов связывания при той же работе копии и сборщика; форма дефекта N = 4, 8, 12, 16 —
156/1308/7052/21844 мс до, 138/1052/5632/17577 мс после
([§79 журнала](fable-continuation-20261003.md#merge-cost-a1)). Гейты на этих байтах: ядро
`opus_kernel_07` GREEN296, 113 исполненных селфтестов; L3 `opus_l3_07` 11 наборов; полный
`opus_full_09` RED40/1851 — против `opus_full_08` FAIL→OK 0, OK→FAIL 0. Открыто: обход сборщика
(A2, после обзора Codex), поиск массива по виду, обход чанков, размер самой копии.

<a id="data-merge-copies-qualified-branch"></a>
### DATA-MERGE-COPIES-QUALIFIED-BRANCH — 2026-10-05, Opus, FIXED 2026-10-08 для каждого merge, до которого доходит программа

`merge` обычной Structure в методе копирует её вместе с лексическими предками, то есть всю единицу.
Квалифицированная вечная ветвь (independent const immutable) единицы при этом копируется тоже: data
merge передаёт ядру как удерживаемые только профили своих операндов, а квалифицированных ветвей
программы не передаёт. По договору общего доступа допущенные квалифицированные вечные ветви — общие
(ответ Codex OPUS-CODEX-20261005-01); копия узла callable merge их удерживает (§77).

```text
independent:
    const:
        immutable:
            (): E
                size_t: e0 0U          # ... P полей
            end: E
        end: immutable
    end: const
end: independent
D0:
    int: v0 1
end: D0
fn: m0 () int
    loc: merge D0                      # копия D0 тянет единицу, а с ней и E
    return: loc\v0
end: m0
```

Измерено счётчиками в пробных копиях ядра, четыре merge: при P = 0, 64 и 512 копия делает 526, 918
и 3636 добавлений блока, четыре merge идут 0,17, 0,45 и 8,6 с. Проба, где data merge удерживает и
квалифицированные ветви программы, делает копию от P независимой: 526 добавлений и 94 Structure на
копию при любом P, 0,74 с при P = 512. Удержания не передают и другие места merge
(`lmx_merge_owned` без профилей в трансляторе)
([§79 журнала](fable-continuation-20261003.md#merge-cost-a1)).

**Поправка того же дня.** Программа скопированную `E` не видит. С одним операндом, без тела и без
карты результатом data merge становится сама копия операнда, и ядро ставит ей родителем контейнер —
место, где исполнен merge (`result\parent: container` в `lmx_merge_owned.lm1`). Скопированная цепочка
предков, единица вместе с `E`, сразу недостижима. Измерено путями драйвера на корневом `loc: merge D`
(у `D` вложенная Structure `Inner`): результат — отдельная копия `D` с отдельной копией `Inner`, а
висит он под самой единицей, и `E` от него — исходная. Значит, копия `E` сегодня — только цена, и
свидетеля общей `E` при нынешнем родителе быть не может. Нормы о родителе результата расходятся:
семантика (#composition) — «the place that executes `merge` neither supplies a new lexical parent», и
квалифицированную ветвь merge «MUST not copy»; слова автора — parent к месту merge отношения не имеет
([журнал автора](../LMX_blog/2026-10-05.md#merge-parent)); CORE 10.2 — «the constructed result's parent
is the actual construction host»; контракт ядра — контейнер. Вопрос задан Codex: висит ли результат data
merge под копией лексического родителя операнда, как узел T7 (§77), — тогда копия должна удерживать
квалифицированные ветви, и это станет видно, — или остаётся под местом merge, и тогда цепочку
копировать не нужно.

Решено и исправлено 2026-10-08 ([MERGE-PARENT-SITE-OVERRIDE](#merge-parent-site-override),
[READ-FIELD-CLOSURE](#read-field-closure); Codex K03-MERGE-PARENT-20261007-27): результат висит под копией лексического
родителя операнда, копия держит то, что использует скопированный код, и каждый merge, до которого доходит программа,
передаёт квалифицированные ветви программы точными профилями. Ветвь, которую скопированный код читает или
скопированные данные называют, — сама `E` (`unit_merge_parent_keep`, `_letter_keep`, `_t7_required`; мутанты без
нативного удержания и без Q корней обхода их краснят); ветвь, которую никто не использует, в копии отсутствует
(`unit_merge_parent_letter`, `_t7`). Копия нагрузки письма передаёт тот же список, но ни одна выразимая программа не
доводит её до ветви как Structure-значения: цепочка нагрузки — только связи, ссылка разделяет адресата, кадров
MainLetter в копии нагрузки нет (мутант без удержания нагрузки свидетеля не достигает). Не передают удержания два
производителя, до которых не доходит ни одна программа (`lmx_walk_merge_model`, kind 3 в именованной Structure метода).

<a id="fixed-blocks-audit"></a>
### FIXED-BLOCKS-AUDIT — 2026-10-05, fable, маршрут пути и допуска FIXED 2026-10-05 (Opus); остальное OPEN

В `l2trans.lm1` после шага §71 остаются блоки постоянного размера: 200 символьных и 14 целочисленных
в функциях, 29 на уровне единицы. Шаг убрал те, что стоят на маршруте пути через свободное имя и в
таблицах допуска по имени. Один из оставшихся программа встречает: путь, текст которого длиннее 255
байт, отвергается словами `unresolved name`, и через объявленный формал, и через свободное имя.
Измерено: имя поля 300 байт отвергается, 250 проходит. Блоки старше этой работы; среди них на
маршрутах пути и допуска: `l2_check_fields` (`chbuf` 256), `l2_emit_fields` (`pbuf` и `chbuf` 256),
`l2_ruse_scan_struct` (`path` 256), `l2_descriptor_implements`, `l2_actual_ns`, `l2_actual_path`,
`l2_emit_actual_path` (`buf` 128), `l2_emit_path_to` (`l2_proot` 64). Нужен отдельный шаг; порядок
запрошен у Codex
([§71 журнала](fable-continuation-20261003.md#no-ceiling)).

**Маршрут пути и допуска исправлен 2026-10-05 (Opus)**, по ответу Codex OPUS-CODEX-20261005-01, (2) B.
Измерено транслятором `12ab4488` пробниками вне гейта, кроме длины в 255 байт выше: путь больше чем
из двенадцати имён отвергается там, где он обходится, словами `root operation not walkable yet: a field
path`. Корень обходится в обоих режимах, поэтому корень, читающий такой путь, отвергается и нативно.

Текст пути или имени теперь любой длины. Функция, которая собирает путь или копирует имя в свой буфер,
держит локальный буфер для того, что в него помещается, а для более длинного текста берёт память
ровно его размера до конца трансляции (`l2_text_room`). Размер — байты атомов, из которых текст
собран (`l2_atoms_len`): ни один сборщик больше не пишет. Проверки длины головы оператора и вызова
убраны: функции, которым голову передают, принимают отрезок байтов. Обходимый путь — с любым числом
имён: ёмкость разрешения — число сегментов самого пути, таблица у каждого вызывающего на столько же
записей (`l2_rw_path_room`). Ничего не обрезается. На 1802 записанных трансляциях `opus_full_02`
сгенерированный L1, коды выхода, сообщения и число выделений памяти те же. Рядом найден и исправлен
[RETURN-CHECK-LONG-NAME](#return-check-long-name). Строки: `unit_path_long_names`,
`unit_path_long_call`, `unit_path_deep_names` с парами `_walk`, `unit_reference_long_path_coverage`,
отказы `unit_path_long_names_other_refused`, `unit_return_long_field_other_refused`,
`unit_free_path_write_long_none_refused`
([§74 журнала](fable-continuation-20261003.md#path-text-any-length)).

Остаётся, вне маршрута пути, каждое — отказ на месте:
- текст одного выражения в эмиттере, 1023 байта (`l2_cat`, `expression too long`), и буферы, которые
  его питают. Обычная программа доходит до него: сумма `a + a + ...` около ста слагаемых
  отвергается. Два отказа без места (D-112, «internal: a refusal said nothing», выход 3): операнд —
  литерал от 256 байт (`c.puts` с текстом в 260 байт; `l2_prep` → `l2_tok_text(..., 256U)`) и
  вызов C с 300 фактическими (склейка в `l2_prep`). Решение Codex 2026-10-06: растущий текст сразу —
  один владеющий построитель текста транслятора (данные, длина, ёмкость) по дисциплине
  `l2_xmalloc`/`l2_xfree`, перевод по срезам зависимостей, каждый под гейтом; ни нового потолка,
  ни большего буфера, ни постоянного отказа «expression too long». **Срез 1 — 2026-10-06 (Opus)**
  ([§94 журнала](fable-continuation-20261003.md#expression-text-slice-1)): текст `L2Tx` — сначала буфер
  владельца в 1024 байта, дальше память трансляции вдвое больше; переведены вычисление и склейка
  выражения (`l2_eval_fields`, `l2_eval_and`, `l2_eval_cond`, `l2_emit_fields`), подготовка операнда
  (`l2_prep`), дверь C (`l2_emit_ccall` и значение вызова C), текст оператора `l2_tok` со всеми его
  читателями и поля письма (`l2_emit_msend`); атом — любой длины (`l2_tok_tx`). Сумма из 300
  слагаемых, литерал в 3000 байт и вызов C с 301 фактическим переводятся и исполняются, оба отказа без
  места ушли; заодно исправлен [C-CALL-VALUE-TEXT-CUT](#c-call-value-text-cut). **Срез 2 — 2026-10-06
  (Opus)** ([§95 журнала](fable-continuation-20261003.md#expression-text-fixed-routes)): семь маршрутов,
  принимавших готовый текст в буфер в 1024 байта, пишут в свой текст — фактические вызова, удерживаемого
  вызова и вызова через указатель на функцию (склейки последнего отказывали без места), индекс своего
  массива, значение ссылки, разыменование, адрес поля C. **Срез 3 — 2026-10-06 (Opus)**
  ([§96 журнала](fable-continuation-20261003.md#expression-text-path-actual)): путь-фактический, записанный
  вложенными чтениями Structure (`l2_emit_actual_path`), — сколько угодно имён (было не больше 32 и текст в
  1024 байта); ни один маршрут больше не копирует готовый текст в буфер постоянного размера. **Группы
  владельцев 1 и 2 — 2026-10-06 (Opus)** ([§98 журнала](fable-continuation-20261003.md#expression-text-owner-groups)):
  27 писателей, чьи вызывающие уже отдают текст или свой буфер, пишут текст сами — 46 мест вызова без
  переходника; `l2_tx_fixed_keep`, `l2_tok_temp` и не вызываемый никем `l2_emit_array_load` удалены; `sizeof` типа-рамки любой глубины (было 256
  байт), слова типа, имени двери C и метода любой длины (было 1024), полезная нагрузка письма (было 256).
  Снятие переходника не доказывает, что писатели ниже берут текст любой длины. **Группа 3 — 2026-10-06
  (Opus)** ([§99 журнала](fable-continuation-20261003.md#expression-text-owner-group-3)): 31 писатель
  вокруг токенов, мест и деклараторов и два, что питали их тексты, пишут текст сами; 19 последних мест
  вызова отдают текст; `l2_tx_fixed`, `l2_cat` (склейка до 1023 байт) и `l2_act_at` удалены — ни одному
  писателю текста выражения больше не отдаётся место постоянного размера. Ушли пределы, до которых
  доходит программа, и у каждого есть строка, на которой прежний транслятор отказывает или падает: слово
  разыменования `\...\p` в 255 байт — уровни и имя указателя вместе (`unit_exprtext_deref_deep`,
  `unit_exprtext_deref_name`); сырой путь C в 256 байт и сырой индекс в 1024 — отказ без места
  (`unit_exprtext_raw_path`, `unit_exprtext_raw_index`); тип адреса цели-пути и захваченного места —
  запись за буфер ([ADDRESS-TYPE-PAST-BUFFER](#address-type-past-buffer)) и склейка декларатора в 1023
  байта (`unit_exprtext_address_deep`, `unit_exprtext_capture_deep`). Остаются OPEN — каждый берёт текст
  целиком или отказывает своими словами, ничего не обрезая: переведённые, но не достигаемые ни одной
  записанной трансляцией маршруты — `l2_mrs_occ_read` (`merged\[N]x` связанного результата слияния),
  `l2_emit_array_load_at`, ветви литерального и загруженного индекса `l2_emit_own_index` (вызывается
  только с ответом «не этот вид»), ветви элемента `l2_emit_arr_operand`, ветвь загрузки
  `l2_emit_indexed`, `l2_tok_slot`, `l2_emit_reference_declaration` (имя объявленной ссылки было в 256
  байт), машинный локал как основание и имя-определение как часть сырого индекса (было 1024 байта) —
  непокрытие и неизменный повтор не доказывают их мёртвыми, они ждут переписи производителей и
  достижимости (Codex 2026-10-06); слово чужого типа в деклараторе молча обрезалось до 255 байт, имя
  чужого типа в приведении копировалось в 256 — теперь пишутся целиком, но измерено только на
  трансляции: `l1trans` не берёт имя типа C от 64 байт (долг ниже); значение удерживаемого вызова,
  приводимое к типу модели (`l2_held_convert_emit`, и `l2_emit_convert_raw` за ним), — чтение
  порождённого имени `l2_hcr<n>`, и мутант, возвращающий там предел, не достигнут ни одной строкой;
  значение связывания (`l2_emit_stmts`, было 1100 байт) — ни один пробник до него не дошёл: связывается
  имя, путь, прочитанный во временное, или полезная нагрузка письма; значение, которое загружает операнд
  с индексом (`l2_emit_indexed`), — его мутант тоже не достигнут (индекс там — одно имя, вызов или
  литерал); повтор без изменений не доказывает ни недостижимости, ни снятия предела (Codex 2026-10-06).
  Пробелы тестов — поведение закреплено только текстовыми пинами, поведенческого свидетеля нет:
  повторное использование допущенного временного в `l2_emit_receiving_admit` (`unit_ref_local_path`);
  захват косвенного места во временное (`l2_capture_indirect_place`, `unit_arg_decl_oldptr`: мутант,
  оставляющий место как написано, меняет L1 58 строк, 57 из них проходят); приведение загрузки слота к
  его типу (`l2_own_cell_load`, `unit_ref_local_path`: из выборки 60 из 493 строк проходят 59). Раскладка
  блока фактических вызова (записи, затем слоты) строками проверена только случайно: мутант наложения
  убит один раз и одной строкой из пяти; нужен проверяемый аллокатор или тестовый свидетель
  непересечения записей и слотов (тестовый пункт, OPEN; не защитная проверка в трансляторе);
- имя машинного локала, корня пути, копируется в 64 байта (`l2_emit_path_to`). Измерено 2026-10-05
  (Opus): эту ветку не проходит ни одна из 1903 записанных трансляций `opus_full_18`. Перепись
  производителей 2026-10-06 (Opus) нашла двух, доходящих до неё:
  [DECLARATION-CANDIDATE-ROLE](#declaration-candidate-role) и
  [OWN-TYPE-CODE-BANDS](#own-type-code-bands). Порядок (Codex): общая проверка объявления и
  кандидата → вид и тип порознь → новая перепись производителей и читателей → удаление маршрута
  с его читателями (вместе с ним уходит и предел в 990 машинных локалов в `l2_path_root`). До
  этого маршрут не удаляется. Имя пишется в текст с группой 3 текста выражения
  ([§99 журнала](fable-continuation-20261003.md#expression-text-owner-group-3)); свидетеля длины нет —
  ветку проходят только программы двух производителей. Первый исправлен 2026-10-06
  ([§100 журнала](fable-continuation-20261003.md#declaration-one-value)): объявление с лишним значением
  отказывается у объявления и машинным локалом не становится; остаётся второй;
- циклы и блоки `catch:` вложены не глубже 64 (`l2_lp_push`, `loops and catch blocks nested too deeply`,
  без места: 1:1), открытые pads — тоже 64, а 65-й `catch:` одной эмиссии (и соседний, не вложенный)
  отвергался словами `a catch parameter that is not a number` — **исправлено 2026-10-05 (Opus)**: три
  стека держат столько, сколько вложено и написано; строка `unit_catch_nested_many` (+`_walk`)
  ([§91 журнала](fable-continuation-20261003.md#emission-stacks));
- исходные таблицы: 8 таблиц, 32 столбца одной и 128 всех, 4096 ячеек, текст ячейки 127 байт — **исправлено
  2026-10-05 (Opus)**: таблиц, столбцов и ячеек столько, сколько написано; строка `unit_s7_tbl_many`
  ([§92 журнала](fable-continuation-20261003.md#source-tables-any-size));
- сгенерированный L1 растёт быстрее квадрата вложенности: двадцать вложенных `for:` — 1,4 МБ L1, сорок —
  6,8 МБ, семьдесят — 27,5 МБ (9,3 МБ C). Найдено 2026-10-05 (Opus); не предел языка, а цена эмиссии
  ([§91 журнала](fable-continuation-20261003.md#emission-stacks)). По Codex 2026-10-06 — подзадача
  стоимости реализации: вынесение публикации в помощника сохраняет обычную машинную активацию,
  момент «только грязные», порядок вызова, выхода, уступки и очистки и один граф; без процедур
  циклов, лишних активаций и графа состояния;
- имена методов, формалов и объявленных бросков — 62 байта (`name too long`). Найдено 2026-10-05
  (Opus): без этих проверок транслятор берёт имена в 300 байт на всех измеренных маршрутах, кроме
  одного: метод, использованный как значение, получает публичную обёртку C под своим именем, а `l1trans`
  держит имена функций в слотах по 64 байта (`l1_fn_ensure`) и отвергает длинное словами `too many
  functions`. Это предел L1-транслятора; снимать его — шаг `l1trans` с его самосборкой, а до него отказ
  остаётся в `l2trans` ([§88 журнала](fable-continuation-20261003.md#fixed-counts));
- имена типов заголовков L1 — меньше 64 байт (`l1_hdr_type_add`, `type name too long`). Найдено 2026-10-06
  (Opus): `sizeof(c.<имя>)` с именем C-типа в 1500 байт `l2trans` теперь переводит, а `l1trans` отвергает
  такой тип уже при 100 байтах ([§98 журнала](fable-continuation-20261003.md#expression-text-owner-groups)).
  Долг загрузочной цепочки, шаг `l1trans`; не повод укорачивать, хешировать или особо обрабатывать имена C
  (Codex 2026-10-06);
- не больше восьми callable-формалов, записанных на месте в одном методе, и 32 захваченных поля —
  **исправлено 2026-10-05 (Opus)**: мест столько, сколько у метода формалов и у захваченной Structure
  полей; конструктор объявляет `l2_capf` по самой широкой захваченной Structure. Строки
  `unit_callable_formals_many_in_place` (10 формалов) и `unit_capture_many_fields` (40 полей, с обходом)
  ([§88 журнала](fable-continuation-20261003.md#fixed-counts));
- слова отказов обрезали длинное имя (`snprintf` в 200, 240, 256 или 1400 байт, имя вызываемого — в
  160), а три формулировки писались `sprintf` в 160 байт без границы — **исправлено 2026-10-05
  (Opus)**: слова каждого отказа, который называет имя или путь, собираются в памяти своего размера
  (`l2_error_words`, `l2_error_name`). Найден и исправлен
  [DUPLICATE-CATCH-LONG-NAME](#duplicate-catch-long-name). Строки
  `unit_unbound_input_long_name_refused`, `unit_struct_arity_long_name_refused`,
  `unit_catch_duplicate_long_name_refused`, `unit_named_actual_long_unknown_refused`,
  `unit_held_call_long_name_count_refused` ([§88 журнала](fable-continuation-20261003.md#fixed-counts)).

Блоки постоянного размера остались и на маршруте пути: теперь это быстрый путь для текста, который в
них помещается, а не предел. Поэтому их число (200 символьных и 14 целочисленных в функциях, 29 на
уровне единицы) не изменилось и пределов не измеряет.

<a id="declaration-candidate-role"></a>
### DECLARATION-CANDIDATE-ROLE — 2026-10-06, Opus, FIXED 2026-10-06 (по ответу Codex OPUS-CODEX-20261005-01)

Объявление ссылки программного типа, у которого кандидат не одно выражение, не отказывается, а
меняет роль. `@: T name <кандидат>` или `const: @(T name <кандидат>)` в методе, где T — Structure
программы: собственный сборщик его пропускает (`l2_own_decl_ty` даёт 0, когда
`candidate_count > 0 && l2_expr_span(candidate) != candidate_count`), а сборщик машинных
локалов берёт его машинным локалом с моделью T (`l2_ml_add`, `l2_ml_ns >= 0`). Измерено на
`4d7285f4` меткой у производителя, нативно и с `--walk-methods`:

- `@: Model m @ Model 3` и `int: v m\value`: путь входит в ветку машинного локала
  `l2_path_root`, затем отказ «root operation not walkable yet: a field path» у чтения. Так же с
  `@ Model z`, `(@ Model) (@ Model)`, с записью `m\value: 9` и с `v: m\value + 1` (там «unknown
  field path root»);
- `@: Model m @ Model 3` без чтения: трансляция проходит, а L1 содержит
  `@: Lmx l2_t0 lmx_arena_ref_struct(node, 0U)3`; gcc отвечает «expected ',' or ';' before numeric
  constant». Неверное объявление принято, вывод негоден;
- хвост вызова `@: Model m make 3`: производитель срабатывает, отказ «incompatible entry
  signature»; `make(3)` и `(@ Model)` идут собственным маршрутом.

Повтор 1916 трансляций, записанных `opus_full_24`: производитель не срабатывает ни разу.

Требуется (Codex): одна правда классификации и проверки для собственного сборщика, сборщика
машинных локалов и проверки с эмиссией; «не объявление» отличается от «узнанного, но неверного
объявления». Кандидат проверяется обычными правилами принимающего места и операнда — не новым
разбором и не общим отказом при `candidate_count > 1`: путь, арифметика или унарный адрес —
одно значение из нескольких атомов, а лишнее независимое значение не разрешено тем, что его
текст можно склеить в L1. Отказ с местом стоит у объявления и без чтения; так же в форме
`const:`. Законные кандидаты (путь, выражение, `make(3)`, приём фабрики `@:`) — положительные.
Глубина указателя сохраняется (`@Model` и `Model` — разные значения); у вызова, арности и типа
остаются свои причины отказа.

**Исправлено 2026-10-06** ([§100 журнала](fable-continuation-20261003.md#declaration-one-value)): одно
значение — один предикат (`l2_fields_one_value`): то, что охватывает читатель операнда (атом, ряд операторов —
путь, сумма, унарный адрес, — один Frame), или вызов — первый элемент называет вызываемое, за ним его
фактические (книга §9, как `l2_tail_is_structure` читает хвост). Слово объявления (`[]`, `@`, `const`,
`immutable`, `independent`) делает Frame объявлением при любом кандидате: собственный классификатор
(`l2_own_decl_ty`) больше не отворачивает его по кандидату, собственный сборщик берёт неверное объявление там
же, где верное, сборщик машинных локалов его не видит; под одним словом типа хвост, который читатель операнда
не охватывает, по-прежнему ничего не объявляет. Проверки ссылки и своего объявления
(`l2_check_reference_init`, `l2_check_decl_candidate`) отказывают у первого лишнего значения: «a declaration
takes one value» (`l2_check_one_value`). Строки `unit_decl_one_value_refused`, `_read_`, `_const_`, `_two_`,
`_name_`, `_prim_refused` (с двойниками обхода) — отказ у лишнего значения, читается имя или нет;
`unit_decl_one_value_call_tail_refused` — вызов в кандидате сохраняет свою причину (арность `make`, как у
`r: twice 3`). Диагностическая сборка, сообщающая о каждом машинном локале из такого объявления: прежде 2–6
сообщений на программу-пробник в методе, теперь ни одного. Без изменений: объявление под одним словом типа
с лишним значением (`int: seen values[i] 7`, `unit_indexed_initializer_extra_refused`) отказывается «unsupported
body» — другой роли оно не брало, но слова не объявления; `const:` в корне читается как сигнатура входа и
отказывается «incompatible entry signature», верное или нет.

**После ответа автора 2026-10-06** ([§102 журнала](fable-continuation-20261003.md#declaration-call-tail-answer)):
вызов — свой Frame, `make: 3` или `make(3)`; `make 3` — два значения. Ветвь вызова из `l2_fields_one_value`
удалена: `unit_decl_one_value_call_tail_refused` отказывается у `3`, «a declaration takes one value»; `make(3)`
и `make: 3` — контроли. Классификация обоих сборщиков не меняется. Остаются OPEN: объявление под словом
примитивного типа с лишним значением (`int: v 3 4`, `int: seen values[i] 7`) отказывается «unsupported body», а не
как объявление; `const:` в корне читается как сигнатура входа.

<a id="callable-first-tail"></a>
### CALLABLE-FIRST-TAIL — 2026-10-06, Opus, FIXED 2026-10-06 (ответ автора; Codex OPUS-CODEX-20261005-01)

Общий классификатор хвоста `l2_tail_is_structure` читал хвост, чей первый атом называет метод, дверь C или
предопределённую функцию, значением этого вызова — чтение T6. На уровне единицы его не стало вместе с
FACTORY-RESULT-RECEIVER (`l2_call_value`), но оно жило во вложенном определении именованной Structure (Q57,
`l2_ns_nested_def`) и в проверке вперёд головы с одними именами (`l2_struct_defined_below`). Измерено на
`9d75979f`: `S:` / `C: tick 7` (tick — метод без формалов) отказывается «internal: an own declaration has no
physical field»; `A: b` над `A: tick 7` берёт `A: b` определением A, а строку ниже — применением A («more
arguments than A has formals»).

**Исправлено 2026-10-06** ([§102 журнала](fable-continuation-20261003.md#declaration-call-tail-answer)) по ответу
автора: вызов — свой Frame, неявного префиксного вызова нет. Чтение удалено; атом слова-ресивера (`b: merge A C`)
тогда сохранён — это костыль, по слову автора того же дня он уходит ([RECEIVER-ATOM-CRUTCH](#receiver-atom-crutch)). `C: tick 7` во вложенном теле — определение, исполнение S ничего не вызывает
(`unit_nested_def_method_tail_dormant` с двойником обхода; мутант, возвращающий чтение, даёт снова внутреннюю
ошибку). Для `A: b` над `A: tick 7` теперь `A: tick 7` — определение A, а `A: b` — имя, типизированное вперёд,
отказ «unresolved name» у него: измерено, не норма и не строка. Повтор 1970 трансляций `opus_full_32` этой
половиной не меняется ни в одной строке. Удалены и две функции без вызывающих, `l2_tail_decl_first` и
`l2_tail_field_body`.

<a id="receiver-atom-crutch"></a>
### RECEIVER-ATOM-CRUTCH — 2026-10-06, Opus по слову автора, OPEN (до зелёного G5; сборщики удалены 2026-10-06, общий маршрут голой головы не реализован)

Автор 2026-10-06 ([журнал автора](../LMX_blog/2026-10-06.md#explicit-receiver-frames)): исключений нет — `b: merge: A C` или
`b: merge(A C)`; `b: merge A C` — костыль, если в коде так сделано, убрать всё такое. Транслятор читает
слово-ресивер (`l2_receiver_word`), написанное атомом с операндами после него, как применение ресивера:
`l2_merge_frame` переписывает дерево `b: merge A C` в кадр `merge` (`l2_merge_atom_settle`), а
`l2_receiver_value`, `l2_tail_is_structure` и `l2_fields_one_value` берут такой атом за применение. Измерено на
`178508a1`: транслятор без этих чтений меняет 264 из 1980 записанных трансляций `opus_full_34`, 231 из них —
из принятых в отказ; текстом форму `x: merge Y` пишут 260 фикстур.

Что нужно. Автор: убрать не только `merge` без двоеточия, а весь участок кода, который такие костыли
допускает, — особый разбор. Значит: удалить `l2_merge_atom_settle` целиком и каждую ветвь, где слово-ресивер,
написанное атомом, читается как применение ресивера (для любого ресивера, не только `merge`); остаётся один общий
путь — явный кадр (`x: merge: Y`, `x: merge(Y)`). Перенести фикстуры на явный кадр, каждая называет перенос;
позитивные контроли явных форм, отрицательный контроль `b: merge A C` — по контракту голого атома ресивера; мутант,
повтор, гейты (Codex). План — [K03-EXPLICIT-RECEIVER-FRAMES](../next_core_tasks_v2.md#explicit-receiver-frames);
порядок: после OWN-TYPE-CODE-BANDS.

**Сделано 2026-10-06** ([§105 журнала](fable-continuation-20261003.md#explicit-receiver-frames-removal)):
`l2_merge_atom_settle` удалён вместе с вызовом из `l2_merge_frame`, ветви атома-ресивера в `l2_receiver_value`,
`l2_tail_is_structure`, `l2_fields_one_value` удалены; перепись (268 переводов, 282 места в 188 фикстурах, все —
`merge`) и [манифест переноса](k03-receiver-frame-migration.tsv): каждое место получило двоеточие, перенесённые
источники с новым транслятором дают то же, что исходные со старым, на всех 272 записанных переводах; контроли явных
форм — `unit_explicit_frame_method`, `unit_explicit_frame_root` с близнецами обхода. Восемь строк `catch: merge (...)` —
аргументы catch, не перенос.

**Ответ автора** (2026-10-06, через Codex K03-BARE-RECEIVER-ANSWER-20261006-01 и дополнения): одно пространство
имён, сначала полная модель «голова — аргументы», потом одно разрешение роли; голая разрешённая голова — её
применение без аргументов тем же потребителем, что `H()`, с ошибкой на месте, никогда не свободный вход и никогда не
сбор соседей — для любой головы, не только merge.

**Остаётся (долг реализации).** Общий маршрут не реализован: на байтах §105 голая запись и `H()` совпадают в 33 из
138 случаев ([матрица](k03-bare-head-matrix.txt)); голые атомы ресиверов идут путём имени («unresolved name», «unbound
dynamic input merge» у места вызова), `H()` — по обработчикам категорий; транслятор различает головы по написанию
(проверки `l2_frame_head(node, "<слово>")` в 317 строках, `l2_receiver_word`, `l2_prim_type_word`). Общий маршрут,
отрицательные свидетели голой и префиксной записи и строка, которую краснит возвращённый сборщик, — оставшаяся
приёмка K03.

**Шаг S1 2026-10-06** ([§106 журнала](fable-continuation-20261003.md#unified-head-s1), Codex
K03-UNIFIED-HEAD-IMPLEMENT-20261006-01): перепись писателей P0, модели каждого прохода и читателей написания головы
([k03-head-census.tsv](k03-head-census.tsv): 769 мест в 157 функциях с классом и шагом); в транслятор добавлены вид
применения (`l2_app_head`, `l2_app_actuals`) и одно разрешение головы (`l2_head_resolve`), пока без читателей:
повтор 1998 переводов `opus_full_38` побайтно равен. Перекрёстная сборка нашла три расхождения читателей с
разрешением, каждое — работа следующих шагов. Маршрут голой головы — шаги S2–S7.

**Шаги S2+S3 2026-10-06** ([§107 журнала](fable-continuation-20261003.md#unified-head-s2-s3)): оператор, голова которого
(атом или голова кадра) разрешается в слово языка, — применение этого слова; голая запись и пустой кадр идут к одному
потребителю (`l2_check_word_stmt` в проверке; `return`, `break`, `continue` без аргумента — через `l2_stmt_word` в
нативной эмиссии, обходчике и исходнике корня), отказ — у слова. Скан не делает слово языка свободным входом;
`f()` не объявляет Structure, если f — слово; голый вызов связывается как пустое применение одной привязкой
(«twice has no argument n»). Матрица оператора в методе: голая запись и `H()` совпадают у 23 из 23 голов (было 6);
корень и тело цикла — 10 и 10 из 10 (было 4 и 4). Повтор 1998 переводов: 1990 побайтно равны, у 8 меняется только
сообщение. Позиции значения, возврата и аргумента — шаг S4.

**Шаг S4 2026-10-06** ([§109 журнала](fable-continuation-20261003.md#unified-head-s4)): в позиции значения — операнд,
аргумент, возвращаемое значение, условие, значение, которое принимает объявленное имя, — слово языка, голое или как
пустой кадр, — одно применение одного потребителя (`l2_check_word_value`), отказ — у слова по контракту слова (было
«unresolved name», «unknown method», «assignment value has unknown type» у оператора, недостающий конвертер): у
оператора без операндов — его собственный отказ, у ресивера без понижения и у инструкции модуля — как в операторе.
Имя именованной Structure в числовом месте — ссылка («a reference where a number is asked»), её применение значения
не даёт («a callable without a result has no value»); голый вызов удерживаемого callable связывается одной привязкой.
В позициях значения голая запись и `H()` совпадают у всех голов, кроме именованной Structure (у двух её записей два
контракта); `x: H` с отсутствующим x — определение, шаг S5. Строку `x: merge Model` и её обход краснит возвращённый
сборщик. Повтор 2078 переводов: 2076 побайтно равны, у 2 сообщение переходит к новому контракту.

**Шаг S5 2026-10-07** ([§110 журнала](fable-continuation-20261003.md#unified-head-s5)): определение `x: хвост` с
отсутствующим x — в корне, в методе, в блоке, в теле именованной Structure — сохраняет хвост телом x, и слово языка
там — голое, применённое к пустоте или к имени — элемент тела по контракту оператора, отказ у слова: никогда не
значение x (было «W has no value» через `l2_receiver_value`), не поле типа с именем слова (было «unknown nested
Structure reference» у модуля или в 1:1), не имя под отказом допуска, не содержимое (`x: sizeof`, `x: size_t`,
`x: include` принимались). Сохранённый `sendMessage: exit(...)` посылает только при выполнении своей Structure
(корень, метод, блок), известный вызываемый остаётся спящим (Q58). Конструкция merge без операнда отказывает у merge
при любом внешнем имени. Матрицы: определение 99 из 102 (было 39), элементы модуля 38 из 40 (29), слово с именем
27 из 36 (3), тело именованной Structure 58 из 68 (6); остаток — разные контракты (данные и применение, поле
`Type: name` по Q57, трейлеры P0, конструкция merge). Ограничение с позицией: имени, которое связывает
`receiveMessage` на верху тела именованной Structure, поля в раскладке нет. Повтор 2124 переводов побайтно равен.
Долги (Codex K03-S5-NS-ROLES-20261007-04), следующие точки этой полосы: K03-S5-NS-ROLES — однатомная ветка
`Type: name` в `l2_ns_decl_first` и её потребители второй фазы уходят в общее разрешение (тело — не сигнатура);
K03-S5-RECEIVE-OUTPUT — выход `receiveMessage` в процедуре именованной Structure получает обычное хранение
вычисленного выхода, не публичное поле (LMX_blog/q/q53.md:95-97).

**Шаг NS-ROLES-3 2026-10-07** ([§111 журнала](fable-continuation-20261003.md#ns-roles-3)): `Model: m` с существующей
Model в корне и в методе — вызов Model, отказ «more arguments than Model has formals» у строки (было объявление новой
копии m); 111 строк 92 программ — `m: merge: Model` (`k03-colondecl-migration.tsv`); старая форма читается только
для поля-ссылки тела именованной Structure, до NS-ROLES-2. `Model: name` не объявляет name на уровне модуля. Именованная
Structure модуля видна в обе стороны: из метода выше неё, из оператора выше неё, из сигнатуры выше неё (модели формалов
перечитываются после регистрации); данные — только вперёд; вложенная Structure — не имя модуля. Кандидат типизированной
привязки `T: b c` читается по схеме, как фактический вызова: результат merge — значение Structure. Повтор 2188
переводов: у 3 строк видимости меняется сообщение, у 64 строк мигрированных программ — только L1. Три строки, чьи
закрепы называли путь формала, принимающего значение точно своей модели, получили `_exact`-близнецов с прежними
закрепами (их фактический — сама именованная Structure); сам фактический-результат merge принимается по имени.
`unit_s1_merge_uncaught_entry` исполняется (сбой merge ловится крючком драйвера). Остаётся: кадр с нетождественным хвостом
выше определения своей головы (`Later: 3` выше `Later:`) в корне классифицируется по порядку источника; собственная
именованная Structure метода видна только после определения — NS-ROLES-1.

**Шаг NS-ROLES-1a 2026-10-07** ([§112 журнала](fable-continuation-20261003.md#ns-roles-1a)): `b: A` при отсутствующем b
и A — Structure (именованная, корень ветви, значение именованной модели) — ссылка на A в собственной ячейке, тот же
путь хранения, что у объявления ссылки (запись чтения декларации, не новый исходный кадр); после привязки `b: args` —
применение, отказ по арности. Голова корня разрешается до хвоста: кадр с хвостом-значением выше определения своей
головы — её вызов (`Later: 3` выше `Later:`), прежнее правило только для идентификатора снято. Повтор 2209 переводов:
3 строки — `unit_k03_vis_unit_declares_tail` с двойником (новый L1, по-прежнему 7) и `unit_ref_absent_colon` (теперь
предел 1c у A, закреп перенесён). Остаётся: метод как A (1b), результат merge как A (1c), нульарное применение через b
(`box()` — прежний отказ до 1b), видимость собственных Structure метода в обе стороны (V2); из двух кадров с хвостом-
Structure (`Later()` или `Later(3 4)` выше `Later:`) определяет первый. Этот выбор определяющего вхождения и видимость
обычной именованной Structure в обе стороны были предварительными; ответ автора 2026-10-07
([вопрос и ответ](../LMX_blog/q/named-definition-boundary.md)): видимость в обе стороны — только у callable, созданных
fn, fm, sub. Правка — K03 NS-ROLES-VIS.

**Шаг NS-ROLES-1b 2026-10-07** ([§113 журнала](fable-continuation-20261003.md#ns-roles-1b)): `b: tick` — привязка b ко
всему вхождению метода (ячейка своя; вызов через b — по сигнатуре tick на вхождении из b, нативно и при обходе; в
методе привязка корня — его скрытый вход, Q52); `box()` и голое `box` после `box: Model` исполняют Model; удержанный
callable как A — предел. Долг 1a (S5-чтение голого метода в хвосте как обёртки) снят. Повтор 2247 переводов: 4 строки
— `unit_k03_def_callable_body` и `unit_factory_short_dormant` с двойниками: новый L1 (`b: tick`, `s: shout` теперь
привязки), исход прежний, у двойников обхода на одну процедуру меньше (закрепы перенесены), заголовки переписаны без
смены числа строк. Остаётся: результат merge как A с референтом выше (1c), независимая часть NS-ROLES-2,
RECEIVE-OUTPUT; V2 и работа со Structure ниже места использования — по ответу автора того же дня (NS-ROLES-VIS).

**Шаг NS-ROLES-VIS 2026-10-07** ([§114 журнала](fable-continuation-20261003.md#ns-roles-vis)): видимость по решению
автора — fn и sub в обе стороны, обычная именованная Structure и корень ветви с места объявления; просмотр вниз и
двусторонние чтения NS-ROLES-3/1a сняты. Повтор 2271 перевода: 24 строки 13 фикстур (восемь позитивов стали отказами,
два отказа сдвинулись на блок, строка вызова сменила сообщение — долг ниже, `x: Foo` выше `Foo:` снова определение x).

**Шаг NS-ROLES-CALL 2026-10-07** ([§115 журнала](fable-continuation-20261003.md#ns-roles-call)): известная голова —
вызов при любых фактических; маршрут типизированной привязки удалён (его функции и все потребители). Повтор 2279
переводов: 8 строк 8 фикстур — строки маршрута и строка долга §114; остальное байт в байт.

**Шаг NS-ROLES-1c 2026-10-07** ([§116 журнала](fable-continuation-20261003.md#ns-roles-1c)): результат merge как A —
b держит Structure A, пути через b читают запись merge референта (`l2_own_res`); предел 1a снят. Повтор 2303 переводов:
5 строк — три строки-предела (с двойниками) теперь исполняются; остальное байт в байт.

**Шаг NS-ROLES-V2 2026-10-07** ([§117 журнала](fable-continuation-20261003.md#ns-roles-v2)): собственный fn метода
виден только в своём блоке; один читатель записанного имени метода (`l2_site_method`) во всех доказанных местах.
Перепись эквивалентности: 16 из 17 пар равны (осталось поле модуля — долг ниже); корпус 2314 переводов не меняется.

**Шаг NS-ROLES-2 2026-10-07** ([§118 журнала](fable-continuation-20261003.md#ns-roles-2)): тело именованной Structure
получает общие роли; исходный маршрут `T: x` убран (kind 3 остался только у модели письма). Повтор 2342 переводов: 12
строк переписи со старым написанием, остальное байт в байт. Открытое ниже — обязательные позитивы, красные до постройки.

**Шаг RECEIVE-OUTPUT 2026-10-07** ([§119 журнала](fable-continuation-20261003.md#receive-output)): вычисленный выход
на верхнем уровне тела именованной Structure — у своего вхождения-приёмника, не поле; выход выбирается общим правилом, не
по имени формала или скрытого входа; долг K03-S5-RECEIVE-OUTPUT закрыт. Повтор 2397 переводов `opus_full_57`: 4 строки
бывших пределов теперь транслируются, остальное байт в байт; повтор 2423 переводов `opus_full_58` финальными байтами —
ни одна строка не меняется.

**Шаг S6 2026-10-07** ([§120 журнала](fable-continuation-20261003.md#unified-head-s6)): одно разрешение вызова читают
проверка, эмиссия и обходчик; маршрут привязки — через общий вход вызова ([BIND-CALL-ENTRY](#bind-call-entry)); голый
путь к callable — его нульарный вызов (ответ Codex K03-CALLABLE-PATH-20261007-25 (c)); мёртвые ветви слотов удалены;
перепись мест написания — [k03-s6-census.tsv](k03-s6-census.tsv). Повтор 2441 перевода `opus_full_59` после каждого
шага побайтно равен.

**Шаг S7 2026-10-07** ([§121 журнала](fable-continuation-20261003.md#unified-head-s7)): операнды merge — фактические
аргументы применения во всех семи читателях ([MERGE-LEADING-ATOMS](#merge-leading-atoms)); путь к полю-Structure и
вызов с именованным результатом опущены обычным ссылочным маршрутом; то, что не опущено, сказано у операнда по его
категории; операнд, написанный Structure, — [MERGE-WRITTEN-OPERAND](#merge-written-operand). Повтор 2476 переводов
`opus_full_60`: 2475 побайтно равны, одно сообщение пробы предела изменилось намеренно.

<a id="call-classifier-typed-route"></a>
### CALL-CLASSIFIER-TYPED-ROUTE — 2026-10-07, Opus (K03 NS-ROLES-VIS; Codex K03-VIS-CALL-CLASSIFICATION-20261007-16), FIXED 2026-10-07 (K03 NS-ROLES-CALL)

Исправлено K03 NS-ROLES-CALL ([§115 журнала](fable-continuation-20261003.md#ns-roles-call)): маршрут удалён со всеми
потребителями; `Model: Other extra` — вызов Model при любом Other, отказ по арности. Свидетели — десять отказов (корень,
метод, тело именованной Structure; первый фактический неизвестен, определён ниже, объявлен выше; три фактических;
запись кадром) и два позитива; с маршрутом обратно (транслятор 147a9e16) отказы с неизвестным, нижним и кадром дают его
сообщения. Ниже — первоначальный дефект.

При существующей обычной именованной Structure Model запись `Model: Other extra` по норме (docs/LMX_semantics.ru.md:668,
docs/L2_spec_en.md:155) — вызов Model, ошибочный по числу аргументов, каким бы ни был Other. Транслятор же, если Other не
виден (определён ниже или неизвестен), берёт старый маршрут типизированной привязки `T: b c` (`l2_colon_bind_shape`,
`l2_check_bind`) и отказывает по кандидату: `unit_root_struct_call2_forward_refused` закрепляет это сообщение как долг.
Исправление — K03 NS-ROLES-CALL: роль вызова известной головы выигрывает при любом числе аргументов и любом первом
фактическом, в корне, в методе и в теле именованной Structure; маршрут типизированной привязки известную голову не
берёт; перепись, контроли и свидетель маршрута (проверка вызова против `l2_check_bind`). Семейство `@: T p` (вопрос
автора о пустой ссылке с моделью) не затрагивается.

<a id="typed-binding-purpose-debt"></a>
### TYPED-BINDING-PURPOSE-DEBT — 2026-10-07, Opus (K03 NS-ROLES-CALL; Codex K03-NS-ROLES-CALL-20261007-17), OPEN (ответ автора)

Маршрут `T: b c` (OPUS-TYPED-BINDING-20260930-20) удалён: при известной T эта запись — вызов T, отказ по арности.
Шесть строк, которые его использовали, закрепляют теперь этот отказ. Их назначение — b с требованием модели T,
привязанное к кандидату c и допущенное по использованиям b при трансляции или в рантайме, — ссылка, ограниченная
моделью, со значением: семейство `@: T name значение`, которое открытый вопрос автора называет зависимым
([вопрос](../LMX_blog/q/current/model-constrained-null-reference.md)). До ответа назначение не переписывается и не
переистолковывается:

| Фикстура | Было | Теперь |
| --- | --- | --- |
| `unit_bind_root_ref` | исполнение, Entry 7: запись через b читается через c | «16:1: more arguments than Model has formals» |
| `unit_bind_root_thin_other` | исполнение, Entry 7: Other допущен к b, ни одно поле которого не используется | «15:1: …» |
| `unit_bind_root_used_other_refused` | «14:1: implements is false in a typed binding» | «14:1: …» |
| `unit_bind_method_used_other_refused` | «14:5: implements is false in a typed binding» | «14:5: …» |
| `unit_bind_root_letter` | исполнение, Entry 2: письмо допущено к MainLetter в рантайме, b — его полезная нагрузка | «9:1: more arguments than MainLetter has formals» |
| `unit_bind_root_letter_refused` | исполнение: Fails 1, Stopped 1, Thrown 2 (допуск письма к Model отказан в рантайме) | «13:1: …» |

Остаётся покрытым: сторона формала (`unit_formal_thin_other`, `unit_formal_used_other_refused`,
`unit_admit_letter_formal`, `unit_admit_letter_not_model`, `unit_admit_formal_refused`) и явная ссылка `@: Model b c` в
методе (`unit_bind_method_ref`, `unit_bind_method_formal`, `unit_bind_method_thin_other`, `unit_recv_use_*`) — она сама
в замороженном семействе вопроса. Вспомогательный метод с типизированным формалом место приёма в корне не заменяет
(Codex -17). Когда автор ответит, назначение каждой строки записывается в утверждённой форме с прежним вердиктом.

<a id="merge-result-binding-routes"></a>
### MERGE-RESULT-BINDING-ROUTES — 2026-10-07, Opus (K03 NS-ROLES-1c; Codex K03-NS-ROLES-V2-20261007-19), OPEN

Привязка `b: A` к результату merge (NS-ROLES-1c, [§116 журнала](fable-continuation-20261003.md#ns-roles-1c)) засвидетельствована
только обычным маршрутом путей полей и схемы: запись и чтение `b\x` по записи merge референта. Четыре маршрута через
такую ссылку не засвидетельствованы и остаются открытыми: явное переприсваивание `@: b B`; b как операнд merge;
порядковый путь вхождения `b\[N]x`; вызов A через b. Эти потребители читают факты строки A (`l2_mres_of_own`,
`l2_mres_find`), не правило `l2_own_res`. Не засвидетельствовано — не значит сломано: прежде любой правки — проба
каждого маршрута (нативно и при обходе), затем ограниченный аудит его потребителей; новое семантическое ограничение не
выводится, покрытие молча не снимается, общая завершённость ссылок не заявляется.

<a id="own-callable-limits"></a>
### OWN-CALLABLE-LIMITS — 2026-10-07, Opus (K03 NS-ROLES-V2; Codex K03-NS-ROLES-V2-20261007-19), OPEN

Норма (#declaration-visibility): callable, созданные fn, fm, sub, видны в своём лексическом блоке в обе стороны. Транслятор
строит собственный fn только в теле фабрики (метод, возвращающий callable). Измеренные пределы реализации — это долги
и требуемые позитивы, не правила языка:

- fn или sub, собственный методу, не возвращающему callable: «unsupported body»;
- собственный sub (и в фабрике): «unsupported body»;
- два собственных fn в одной фабрике: «a callable merge needs one model»;
- собственный fn внутри блока if фабрики: ошибка разбора 13;
- одноимённые собственные fn в двух блоках и собственный fn с именем метода модуля: «duplicate definition» при
  регистрации (таблица методов — одно пространство по имени);
- поле модуля с именем собственного fn: «method collides with a unit field» — внутри хоста разрешение головы читает
  поле модуля, видимое из метода, раньше собственных fn метода, поэтому затенение внешнего поля собственным fn не
  построено (единственная неравная пара переписи эквивалентности V2);
- fm не построен.
- (K03 S6, обязательный позитив, красный: `unit_s6_own_fn_capture_value` с двойником) собственный fn фабрики, который
  захватывает её данные, названный голым там, где вычисляется значение в его хосте, — его нульарный вызов, как
  `get()`; защита эмиттера хоста callable merge (`l2_mad_names_nested`, `l2_mad_mentions_value`) принимает голый вызов
  за упоминание значения: «a callable merge host names a nested method outside the return», тогда как `int: t get()`
  исполняется. Не захватывающий собственный fn голым работает (`unit_s6_own_fn_value`).

<a id="merge-leading-atoms"></a>
### MERGE-LEADING-ATOMS — 2026-10-07, Opus (перепись K03 S7), FIXED 2026-10-07 (K03 S7)

Пять читателей декларативного merge (схема `l2_mrs_build`, скан, ширина `l2_merge_scan`, нативная эмиссия, обход)
считали операндами ведущие атомы (`l2_merge_arity`: «the leading atoms only»), нативно и при обходе:

- операнд после первого не-атома молча отбрасывался: `A: merge(Model; v: 9)` транслировался как merge(Model) — `A\v`
  читал 1 (молча неверное значение); `merge: Other make()` и `merge: Other (Model)` теряли второй операнд (видно лишь
  при чтении его поля: «unresolved name»);
- путь разбивался на атомы: `merge: Host\inner` — «unknown merge operand» у `\`;
- ведущий вызов или группа не давали операнда: `merge: make()`, `merge: (Model) Other` — пустая схема;
- атомы операторного выражения становились операндами: `merge: Model a + 1` — «unknown merge operand» у a.

Callable merge T5 и T7 читали операндом каждое написанное поле (путь тоже разбивался бы). Исправлено
([§121 журнала](fable-continuation-20261003.md#unified-head-s7)): операнды — фактические аргументы применения
(`l2_actual_count`, `l2_actual_field`, `l2_expr_span`) во всех семи читателях; группа с одним значением — это значение,
иначе — анонимная Structure; путь к полю-Structure и вызов с именованным результатом опущены обычным ссылочным
маршрутом; число по общему типу — «a merge operand is not a Structure», прочие формы — located-предел у операнда.
Свидетели `unit_k03_merge_op_*` с двойниками; мутанты (выпавший хвостовой операнд, разбитый путь, непрозрачная группа)
краснят их.

<a id="merge-written-operand"></a>
### MERGE-WRITTEN-OPERAND — 2026-10-07, Opus (K03 S7; Codex K03-MERGE-OPERANDS-20261007-26), OPEN

Операнд, написанный Structure, больше не опущен и не разбит, но не построен:

- анонимная Structure с объявленным полем `(int: v 9)` — один операнд; её v по имени и типу пишется в слот модели
  (#composition, «Model slots»), первой — она модель. Обязательный позитив `unit_k03_merge_op_anon_typed` с двойником,
  красный: сегодня отказ у группы «this merge operand form is not lowered yet»;
- голое поле `merge(Model; v: 9)` — located-предел без оракула (`unit_k03_merge_op_bare_field_limit`): два
  нормативных чтения не сведены — #composition:1066 (`merge(add; y: 5)` кладёт поле y с данными, `merge((n: 5); addN)`
  — Structure, держащая n) и #resolved-head-consumption:666, #construction:688 (неизвестная голова определяет
  Structure; в языке нет var); минимальная программа и абзацы отправлены Codex (K03-MERGE-OPERANDS-20261007-26), до
  ответа не строится;
- группа из двух элементов `merge(((Model Other)))` и группа с полем в callable merge `merge(add3; (y: k))` — тоже
  пределы у операнда (`unit_k03_merge_op_group_two_refused`, `_t7_anon_refused`).

Вопрос автору о голом поле: [LMX_blog/q/current/merge-bare-field-operand.md](../LMX_blog/q/current/merge-bare-field-operand.md).

<a id="merge-parent-site-override"></a>
### MERGE-PARENT-SITE-OVERRIDE — 2026-10-07, Opus (перепись K03 S7; Codex K03-MERGE-OPERANDS-20261007-26, K03-MERGE-PARENT-20261007-27), FIXED 2026-10-08

Норма: merge копирует используемое замыкание источника и переписывает parent внутри этой копии; место, где merge
исполняется или принимается, лексическим родителем результата не становится, и родители не обнуляются: скопированные
лексические предки сохраняют связи до своего корня с нулевым родителем по одной карте источник→копия
(docs/LMX_semantics.en.md#composition, абзац о копии; автор, [LMX_blog/2026-10-05.md](../LMX_blog/2026-10-05.md#merge-parent)).
Арена владения, родитель надзора Thread, явное вмещение при построении и лексический родитель — разные отношения;
сохраняемая ветвь independent: const: immutable держит свою идентичность и родителя.

Реализация задаёт родителем место: `dev/l2src_sandbox/lmx_merge_owned.lm1:263` и `:487` присваивают
`result\parent: container`; транслятор выбирает контейнер места (`l2_emit_stmts`: `merge_parent` = `l2_hN` или
`l2_own_ctr(own)`) и передаёт его в `lmx_merge_profiles_owned`; копия модели, допуск и приёмник обходчика тоже
передают container. Утверждения «родитель по месту» в фикстурах и самотестах (корень, метод, хост; самотест обходчика с
кодом A над данными R) закрепляют отвергнутое правило; CORE_L2_L3_v2.md (:130, :737, :766, :768) описывает их теперь как
наследие этого дефекта.
Связан с [DATA-MERGE-COPIES-QUALIFIED-BRANCH](#data-merge-copies-qualified-branch): там 2026-10-05 измерено, что
результат data merge висит под местом merge, а скопированная цепочка предков сразу недостижима; вопрос, поставленный
тогда Codex, решён (K03-MERGE-PARENT-20261007-27): родитель — внутри копии.

Следующая ограниченная зависимость после контрольной точки K03 S7 (план: next_core_tasks_v2.md, раздел
critical_graph_bug): перепись конструкторов, вызывающих и оракулов; одна топология копии для корня, метода,
именованного/вложенного тела и скопированного callable R, исполняющего код A; операнд с ненулевым лексическим родителем
и изменяемым используемым предком, чтобы мутанты «все родители 0» и «родитель источника» краснели; перенос
утверждений о родителе по месту по намерению.

Исправлено 2026-10-08 вместе с [READ-FIELD-CLOSURE](#read-field-closure) и
[MERGE-PARENT-MODEL-SOURCE](#merge-parent-model-source) (Codex K03-MERGE-PARENT-20261007-27,
K03-READ-FIELD-CLOSURE-20261007-28 … 20261008-31; [§122 журнала](fable-continuation-20261003.md#merge-parent)). Ни один
вход merge не называет родителя: `container` снят у `lmx_merge_owned`, `lmx_merge_profiles_owned`,
`lmx_merge_profiled_owned`, у обёрток драйвера и наблюдателя повторного входа и у `lmx_walk_merge_model`; кадр
walk-примитива `lmx_walk_merge_map` вместо ребра SELF несёт типизированные ячейки P, Q и T (пары, квалифицированные
корни
программы, ячейки использований; слоты 3–5). Один операнд без тела и карты оставляет родителя, которого дал
копировщик: копию лексического родителя модели, адрес родителя, удержанного точным профилем, или 0. Композиция строит
свой корень до копии и передаёт его копировщику (`absorb`): каждая слот-ссылка и каждый parent копии, называющие
скопированный и не удержанный корень операнда, называют результат; родитель композиции — родитель копии модели
(`lmx_merge_lexical`). Каждый merge, до которого доходит программа, передаёт квалифицированные ветви программы точными
профилями — нативный декларативный (`l2_emit_keep`), walk-примитив (Q корней), копия нагрузки письма (kind 3,
последним действием построения, после запечатывания ветвей: `l2_ns_payload_pass`); ветвь, которую скопированный код
читает или скопированные данные называют, — сама ветвь, а не копия, неиспользуемая в копии отсутствует. Перенесены по
намерению оракулы «родитель по месту» и «родитель источника»: `lmx_merge_selftest`, `lmx_merge_root_identity_selftest`
(и NODE адаптера), `lmx_copy_msg_terminal_selftest`, `lmx_walk_merge_selftest`, `lmx_walk_merge_model_selftest`,
`lmx_qualified_range_selftest`, две проверки драйвера, `graph_shape_t7_copy_parent`, пины кадра walk-примитива и
аргумента `self` нативного merge. Свидетели (у каждого двойник `--walk-methods`, выход 7 нативно, при обходе корня и при
обходе методов, пути драйвера по скопированным предкам): `unit_merge_parent_copy`, `_t7`, `_t7_required`, `_compose`,
`_named`, `_letter`, `_keep`, `_letter_keep`. Мутанты по одному правилу на окончательных байтах (свежая стадия, девять свидетелей в трёх режимах): родитель
результата 0, все родители копии 0 и родитель источника модели краснят все девять во всех режимах; композиция без
поглощения корней — `_compose`; результат, переподвешенный к принимающему хозяину, — нативно (и при обходе корня тем
же артефактом) `_copy`, `_compose`, `_named`, нативно `_keep` и `graph_shape_t7_copy_parent`; обходимый merge без Q
корней — `_t7_required` и при обходе `_keep`; нативные merge без удержания — нативно `_keep`; копия нагрузки, сделанная до
запечатывания ветвей, — `_letter` и `_letter_keep`; копия нагрузки без удержания свидетеля не достигает (выше,
[DATA-MERGE-COPIES-QUALIFIED-BRANCH](#data-merge-copies-qualified-branch)).

Остаётся долг покрытия: `l2_rw_model` / `lmx_walk_merge_model` (обход корневого `Model: m`) и kind 3 в собственной
именованной Structure метода (`l2_emit_ns_ref`, `lmx_merge_owned` без профилей) не достигаются ни одной программой; они
получают правило родителя и квалифицированных ветвей не передают; свидетельство первого — только самотест ядра.

<a id="read-field-closure"></a>
### READ-FIELD-CLOSURE — 2026-10-07, Opus (Codex K03-READ-FIELD-CLOSURE-20261007-28 … 20261008-31), FIXED 2026-10-08

Норма (Q42, LMX_blog/2026-09-27.md; docs #composition): merge копирует то, что использует скопированный код, а у
Structure, достигнутой только ради использования, — только использованные места; неиспользованное отсутствует, а не
обнуляется. Правило [MERGE-PARENT-SITE-OVERRIDE](#merge-parent-site-override) без этого копировало лексических предков
целиком, и каждый результат, хранимый в предке, уносил все прежние результаты: рост был экспоненциальным (минимальные
программы и замеры — [§122 журнала](fable-continuation-20261003.md#merge-parent)).

Сделано:
- Ядро. Используемая копия (`lmx_merge_used_owned`, `lmx_graph_copy_many_used_staged`): записи использования
  [якорь, k, длина, слоты] — явный якорь (Structure источника, k = 0) или селектор k (лексический родитель операнда
  k − 1); путь из якоря копируется частично — каждая промежуточная Structure только слотом пути, последнее значение
  целиком; две записи одной Structure сходятся в одну копию, целое использование расширяет частичное. Предок, нужный
  только как связь, копируется частично (`lmx_copy_link`). Явный пустой якорь отказывает; селектор операнда без
  родителя ничего не называет. Глубина пути и число записей не ограничены, размеры проверены на переполнение.
- Роль держателя — из контракта операции (`lmx_copy_holder_operand`: операнд 1 у AT, PUT_REF, OF, OWN_OF, PUT_OF,
  SET_OF, ELEM, ELEMPUT). Держатель — место лексического контекста применения: его предок или Structure данных, чья
  цепочка родителей встречает такого предка раньше самого применения и раньше Structure удерживаемого профиля, —
  связывается частично, места заполняют записи; та же Structure как операнд-значение (merge, SET) копируется целиком;
  один элемент карты при любом порядке. Прежде корень части программы, из которого вызываемый читает скрытый вход,
  копировался целиком (`unit_used_closure_part_lex`).
- Обходчик: `lmx_walk_merge_map` получает P, Q и T отдельными ячейками size_t, каждый отрезок проверен до чтения;
  явный якорь в кадре — SELF, якорь записи — лексический корень данной Structure: кадр не держит единицу, а копия кода
  называет единицу своей копии.
- Соответствия идут через карту копии (`lmx_copy_carry_records`): запись (V, R, кадр) источника переносится стороной
  значения — (V′, R′ или R, …), когда V скопирован, — и стороной модели — (V, R′, …), когда скопировано требование:
  исходный кандидат допущен к скопированному требованию той же картой, в обеих половинах (порядковой и LAST);
  частичная копия несёт дыры, частичное значение без записи с собой получает её с дырами. Запись пишется, только если
  её значение, требование и кадр — живые Structure арены назначения; корни копии исключены. Прежний перенос
  (`lmx_implements_carry`) копировал требование и кадр дословно и оставлял скопированное требование ключом к
  несвязанному оригиналу; он снят. Откат копии возвращает таблицу записей.
- Чтение отсутствующего места отказывает: обходчик INVALID, нативно abort — при загрузке своего поля, при чтении и
  записи числа по пути («a field path reads an absent place») и при всякой загрузке типизированной ячейки
  («a field reads an absent place»); прежде нативное чтение по пути брало ноль защиты `lmx_*_value_known` за значение.
- Транслятор: использования записываются по именам во всех проходах и раскладываются в слоты там, где раскладка
  окончательна (`l2_use_resolve`); один сборщик для нативного и обходимого merge (`l2_mu_collect`) и для копии T7
  (`l2_mu_collect_home`); прямые ссылки эмиттеров обходчика на детей единицы — тоже использования
  (`l2_use_unit_child`, `l2_use_cell_note`). Поле, держащее место графа (вычисленный выход: результат merge, выход
  приёма), записывается цепочкой рёбер, как его читает обходчик (`l2_use_held`, `l2_use_place_below`); прежде — одним
  ребёнком на уровне выше, то есть другим местом (`unit_used_closure_alias_result`). Уровни именованной Structure —
  строками полей (тег 14), без предела глубины. Узел метода части программы — корень части (§10): использование от
  его узла начинается путём корня (`l2_mu_node_prefix`); прежде копия держала слот 0 единицы, и скопированный pget
  читал ноль нативно и отказывал при обходе (`unit_used_closure_part_node`; HEAD исполнял).
- T7: копия лексического дерева callable merge — частичная (`lmx_graph_copy_part_used_owned`) по той же политике.
  Регрессия, найденная полным гейтом этой точки (`opus_full_62`: `graph_shape_t7_local_callable_field`,
  `unit_held_nullary_source_field` и двойники — OK на `opus_full_61`, падение 0xC0000005 во всех режимах, уже на
  байтах до маршрута свободного входа): вид узла callable merge заполняет поле-вызываемое локальной именованной
  Structure модели из своей копии единицы (`l2_emit_ns_refs`, kind 4), а эта ссылка не была использованием дома вида —
  частичная копия держала место метода отсутствующим, и построитель разыменовывал ноль. Исправлено: один перебор
  удерживаемых локальных корней вида (`l2_source_refs_rows`) служит и выпуску заполнения, и, в каждом проходе,
  использованиям дома вида (`l2_ns_refs_note`: заимствованное вхождение метода — `l2_use_unit_child`), а замыкание
  домов (`l2_mu_home`) делает метод домом, так что копируется и то, что использует его код; заполнение читает
  заимствованное вхождение через общий инвариант отсутствующего места («a field path reads an absent place») до записи
  и разыменования, в каждой сборке. Перепись прямых ссылок заполнения на единицу: kind 10 (связка собственной
  именованной Structure метода) отказывает при трансляции («a reference binding in a method's named Structure is not
  built yet»), kind 3 делает только синтезированная нагрузка письма — ни то ни другое не локальный корень вида.
  Повтор 2581 перевода `opus_full_62` до и после: 56 отличаются только текстом L1 — 52 строкой защиты (три строки на
  заполнение поля-вызываемого), 4 (две строки регрессии с двойниками) защитой и записями использования копии T7; других
  изменений нет. Свидетели: две строки регрессии и `unit_merge_parent_t7_borrowed` (две локальные Structure модели
  заимствуют одно вхождение get, get читает cnt своего узла; корень пишет cnt после merge, копия держит 7) — зелёные в
  трёх режимах; мутанты: без записи использования — «a field path reads an absent place» во всех трёх (не падение),
  вместе со снятой защитой — прежнее падение, без замыкания домов — `_t7_borrowed` («reads an absent place», при обходе
  методов INVALID).
- Самотесты, отставшие от правила (их нашёл гейт ядра): оракул предка в `lmx_merge_root_identity_selftest` (перенос
  -27) ждал целой копии лексического родителя — теперь его merge несёт одну запись использования outer\k: ячейка копии
  своя, со значением при merge, поздняя запись источника её не достигает; merge без использования держит в копии outer
  только результат, k отсутствует (краснеет под мутантами целого родителя и выдуманной нулевой ячейки).
  `lmx_copy_ptr_share_selftest` несёт `lmx_implements` predef'ом, как остальные самотесты копировщика: копировщик
  переносит записи, и без этого его единица не собиралась.

Свидетели (у каждого двойник `--walk-methods`, пути после исполнения): `unit_used_closure_transitive`, `_write`,
`_address`, `_deep_ns`, `_code_copy`, `_alias_ns`, `_alias_result`, `_part_node`, `_part_lex`, `_cycle`; сценарии ядра
(i)–(xii) в `lmx_merge_selftest` и кадр E в `lmx_walk_merge_selftest`. Мутанты по одному правилу на окончательных байтах (свежая стадия, три режима). Ядро, самотесты краснеют: 16-битные
поля Q и T декодера (65537 корней, 65540 ячеек), пропущенный селектор, отказ селектору без родителя, путь использования,
обрезанный на 32 уровнях с успехом, дыры записей частичной копии (снятые, оставленные после целого использования, снятые
с записи с собой), снятая проверка чтения отсутствующего при обходе, каждый операнд-предок применения — связь (обобщение
-28), якорь, скопированный целиком, явный якорь, взятый собой, а не корнем своего дерева (кадр E), держатель из
лексического контекста, снова скопированный целиком, и две снятые проверки пустого явного якоря вместе; по одной эти две
проверки друг друга подстраховывают, а проверки произведения и суммы длин в переполняющейся арифметике поведения не
меняют (дальнейшие проверки отрезков отказывают неверной раскладке). Держатель целиком краснеет и на `_part_lex` во всех
трёх режимах; явный якорь собой свидетеля не достигает (только самотест). Транслятор: без цепочки рёбер удерживаемого поля
— `_alias_result`; без пути корня части — `_part_node` (нативно abort «a field path reads an absent place», при обходе
INVALID), вместе с нулём из пустой ячейки при нативном чтении по пути — неверное значение (выход и пути после
исполнения); без записи использований ячеек — `_part_lex` («a field reads an absent place») и `_transitive`, вместе с
нулём из пустой типизированной ячейки — неверный выход; явный якорь — сама единица в кадре вместо SELF — `_code_copy`. Рост на окончательных байтах против HEAD (`opus_full_61`; минимум трёх запусков; Structures, значения и рёбра,
достижимые из единицы после запуска, и длина индекса арены; нативно и при обходе методов одинаково): S(4/6/8) —
47/63/79 Structures за ≤ 102 мс (HEAD 47/63/79, ≤ 235 мс); L(25/50) — 51 Structure за 113–160 мс, индекс 871/1272
(HEAD 52, 715–3409 мс, индекс 4008/7610); N(4/6/8) — 78/104/130 за ≤ 116 мс (HEAD 70/92/114, ≤ 468 мс); W(4/6/8) —
132/176/220 за ≤ 119 мс (HEAD 104/134/164, ≤ 650 мс). Рост линейный по k; в N и W достижимых Structures больше, чем на
HEAD: у каждого результата — своя частичная копия лексического родителя.

<a id="merge-parent-model-source"></a>
### MERGE-PARENT-MODEL-SOURCE — 2026-10-08, Opus (K03-READ-FIELD-CLOSURE-20261008-31 и решения Codex по шву модели), FIXED 2026-10-08

Код User читает `a1\x` через свой скрытый вход a1 — результат merge корня; u1 — merge-копия User, её узел — копия
единицы C ([MERGE-PARENT-SITE-OVERRIDE](#merge-parent-site-override)). Допуск по имени берёт моделью собственную
Structure результата (K02c), читаемую из скопированного лексического графа, — экземпляр a1′ копии; записи значения его
не называли (ядро ключует запись адресом требования): нативно abort «a field of a formal admitted by name is not
carried by its value», при обходе INVALID; HEAD исполнял нативно и с обходимым корнем (без топологии копии).

Классификация (решения Codex): (a) координатный свидетель — объявление, к которому допущен кандидат: метаданные на
время модуля, не значение модели; (b) модель — обычная Structure, читаемая из скопированного лексического графа;
(c) кандидат — привязка вызывающего (порядок #dynamic: локальная привязка вызывающего, унаследованный вход,
лексический запасной путь). Отвергнутый маршрут — модель из единицы программы для каждого чтения K02c — снят до
фиксации; операнды-модели OF/PUT_OF копия не разделяет.

Исправлено:
- (b), объявление видно в месте чтения (`unit_merge_parent_model_source`, `_model_write`): копия переносит записи своей
  картой (сторона модели, [READ-FIELD-CLOSURE](#read-field-closure)) — исходный a1 допущен к a1′; `_model_write`
  несимметричен: корень пишет `a1\x: 5` в оригинал после merge, u1 читает 5 кандидата, a1′ копии держит 1.
- Модель, сделанная после копии (`unit_merge_parent_model_later`): a3 объявлен после User, а обычное объявление видно с
  места объявления вперёд и вниз (docs #declaration-visibility) — в коде User a3 не лексическое объявление, а свободный
  динамический вход (#dynamic). Его координаты дают объявления, достигающие входа (`l2_anchor_close`: a3 — merge одной
  Structure, Model), значение — привязка вызывающего; копия a3 не держит (он сделан после merge) и не нуждается в нём.
  Тело именованной Structure читает единицу с места своего объявления, как метод — со своего заголовка (`l2_vis_method`;
  прежде у процедуры именованной Structure не было узла, и ей было видно всё, включая поздние объявления);
  координатное пространство ищется и для тела именованной Structure (`l2_m_consumer`, `l2_uses_walk_method`).
- Граница приёма (Codex, ответ на PROGRESS 4 C и его ограничения): свободный вход допускается там, где граница его
  формирует, — вызов или исполнение именованной Structure (на месте или копии из поля), — к требованию, прочитанному в
  пространстве вхождения, которое граница выбрала, там, где тело этого вхождения читает свои требования
  (`l2_m_unit_ref`): в собственном узле вхождения, его родителе, если тело читает через `node`; в единице программы,
  если тело читает её. Нативно — ссылка контекста выпуска (`l2_recv_unit`), которую читает только `l2_type_inst`, пока
  выпускается этот один допуск (`l2_admit_received` ставит её и восстанавливает перед каждым возвратом; вхождение —
  `l2_c<t>` вызова, выбранное до фактических аргументов, `l2_nsn<k>` исполнения). При обходе — допуск с
  ролью-источником RECEIVING (`lmx_walk.h`, ADMIT_AS; `l2_rw_recv_req`), чьё требование `[of, [node], слот]` ядро
  читает в копии кадра вызывающего на стеке, где код и данные — выбранное вхождение, а входы, рабочее состояние, охрана
  и нагрузка пусты; кадр вызывающего не пишется; значение, перехваты и всё прочее — в кадре вызывающего; вне входов
  CALL/EXEC такой допуск — INVALID. Кандидат формируется как прежде; объявленный вход сохраняет запись своего
  объявления. Вызов по имени идёт тем же путём (`l2_c<t>\parent`), без сокращения «своя единица». В u1 требование —
  Model′ из C, тот же объект, что читает её тело и нативно, и при обходе (замер: скопированный операнд модели
  обходимого тела — место 0 копии C). Повторный допуск готовой пары находит запись и полей не проверяет
  (`lmx_implements_register`), новая пара проверяется. Снято: `l2_type_witness` (требование из единицы программы в
  коде под `node`: оно подменяло требование тела оригиналом) и допуски на формировании исполнения в отрисовке
  вызывающего.

Свидетели (у каждого двойник `--walk-methods`; выход 7 нативно, при обходе корня и при обходе методов):
`_model_later`, `_model_twice` (два запуска читают текущий a3: 1, затем 5), `_model_layout` (Wide, x в слоте 1) — у
трёх пути после исполнения: место 0 копии C — не Model программы; `_model_prior` (пара, перенесённая копией из
исполнения на месте, встречена на границе u1); `_model_place` (запись и адрес через a3 из копии попадают в a3 корня);
`_model_ordinal` (нетождественные ordinal `[0]x` и LAST `x` через копию: Cand {pad; x; x} в координатах Model);
вызываемые вхождения копии — `_model_method` (fn get в поле Box, `b1\get()`), `_model_sub` (sub bump, его запись
попадает в a3 корня), `_model_subref` (вхождение bump из b1, выбранное ссылкой на вызываемое: `recv(b1\bump)`, затем
`f()` — нативный допуск читает требование в `l2_c0\parent` выбранного вхождения; в двойнике recv остаётся нативным,
у него формальный параметр-вызываемое), `_model_xpart` (get определён в части программы, чей корень a3 не объявляет);
`_model_nested` (вложенный приёмник, исполняемый на месте в копии); `unit_free_name_later_struct`,
`unit_free_name_two_layouts`. На HEAD `_model_method`, `_model_sub` и `_model_xpart` отказывали во всех трёх режимах
(«not carried»), `_model_subref` — при обходе. Контроль `unit_merge_parent_model_none`: запуск u1 до объявления a3
отказывает в месте запуска («unbound dynamic input a3»); проба `node\a3\x` (явный путь графа копии) отказывает («a
field path met no Structure», при обходе методов INVALID) и не берёт динамический a3; `_model_source` и
`_model_write` (обычные выражения-модели) транслируются байт в байт как до маршрута свободного входа. Ядро
(`lmx_walk_call_data_selftest`): модель RECEIVING — из узла вызываемого, значение `[of, [node], 1]` — из узла
вызывающего (аргумент, наблюдающий свой `node`, в исходном тексте вызова не пишется: «unresolved name»); неотмеченный
допуск читает модель вызывающего; RECEIVING вне входов вызова — INVALID; готовая пара переиспользуется без проверки
полей и при поле уже не своего типа, новая пара проверяется по полям и отказывает.

Перепись replay по 2508 трансляциям `opus_full_61`, байты до маршрута свободного входа против этих: 2457 совпадают,
51 отличаются только текстом L1 (ни сообщение, ни код выхода не изменились). 10 — строки трёх фикстур, уже читающих
свободные имена (`unit_copy_call_chain_inputs`, `unit_copy_call_hidden_inputs`, `unit_named_struct_dead_tail_given`);
в 41 (`unit_free_path_*`, `unit_letter_place_free_name`, `unit_path_deep_names`, `unit_path_long_names` с двойниками)
после обезличивания временных имён обхода отличия только двух видов: 358 нативных строк допуска, где экземпляр модели
перешёл из единицы вызывающего в `<вхождение>\parent`, и 61 обходимый допуск, где операнд модели — операнд кадра
вызывающего `l2_nsp[k]` — стал `[of, [node], k]` с отметкой RECEIVING; других нет. Позиционный допуск обхода
(значение без схемы, `l2_rw_admit`, без отметки RECEIVING) свободным входом не достигается ни одной из 2508
трансляций и 29 строк фокуса (стадия с маркером; тот же маркер для любого скрытого входа достигает 2 строк —
`unit_recv_hidden_opaque_typed` с двойником, объявленный вход). Мутанты по одному правилу на окончательных байтах (свежая стадия, три режима). Перенос записей: без стороны модели —
`_model_source` и `_model_write` во всех трёх режимах и самотест (сценарий xii); требование, перенесённое дословно, и
перенос стороны модели или значения из чужой арены краснят самотест и программ-свидетелей не достигают; `_model_prior`
зелёный при каждом из четырёх (свежая проверка той же раскладки допускает ту же пару; переиспользование показывает
тест входа ядра). Маршрут свободного входа: без видимости тела именованной Structure с места объявления —
`_model_later` и `_model_twice` («not carried» нативно и при обходе корня, INVALID при обходе методов), у
`_model_none` отказ трансляции становится abort исполнения («a field path met no Structure»);
`unit_free_name_later_struct` этим не достигается (исполнение на месте видит позднее объявление прежним путём с тем же
итогом); без поиска координат для тела именованной Structure — отказ трансляции («a path through a free name that no
declaration reaching it gives its fields to is not built yet») у `_model_later` и `unit_free_name_later_struct`.
Граница приёма: нативная ссылка — единица вызывающего — краснит нативно `_model_later`, `_model_layout`,
`_model_method`, `_model_sub`, `_model_xpart`, а `_model_subref` — при обходе корня и методов (нативно формальный держит
вхождение единицы, и ссылки совпадают: [COPIED-CALLABLE-ACTUAL](#copied-callable-actual)); ссылка — единица программы
(глобальный оригинал) — нативно `_model_later`, `_model_method`, `_model_sub`, `_model_xpart`; без отметки RECEIVING
при обходе — при обходе корня («not carried») и методов (INVALID) `_model_later`, `_model_layout`, `_model_method`,
`_model_sub`, `_model_xpart` (у `_model_subref` допуск делает нативный recv во всех режимах); исполнение без допусков
свободных входов — нативно `_model_later`, `unit_free_name_later_struct`, `_model_nested` (и при обходе корня), при
обходе — те же при обходе корня и методов (`_model_nested` — методов); вызов, снова допускающий свободный вход в
отрисовке вызывающего, — нативно `_model_method`, `_model_sub`, `_model_xpart`, при обходе корня `_model_subref`;
`unit_free_name_two_layouts` им не достигается (вызовы по имени из кода самой единицы: её узел и есть пространство
приёма). Ядро: вход RECEIVING, вычисленный как любой операнд, и требование, прочитанное в кадре вызывающего, — INVALID
при обходе корня и методов у `_model_later`, `_model_method`, `_model_sub`; RECEIVING вне входов вызова программ не
достигает (транслятор такого не строит); все три краснят самотест `lmx_walk_call_data_selftest`.

Открыто: [COPIED-METHOD-DECLARED-FORMAL](#copied-method-declared-formal) — объявленный формальный параметр метода копии
(на HEAD так же); [COPIED-CALLABLE-ACTUAL](#copied-callable-actual) — нативно вызываемый аргумент-путь через копию даёт
вхождение единицы; [T7-LOCAL-NAMED-UNIT](#t7-local-named-unit) — код локальной именованной Structure модели в узле
callable merge читает единицу программы, а не копию узла. Два кандидата разных раскладок через merge-копию исполнением не строятся: исполнение результата merge
в методе отказывает при трансляции («executing a named Structure is not supported yet»). Свободный вход собственной fn
метода не пробован: собственные fn есть только у хозяина, возвращающего вызываемое, и их входы — захваты (A3). Модели
операндов вида T7 этим не менялись ([T7-MODEL-OPERAND-SOURCE](#t7-model-operand-source) открыт).

Обновление 2026-10-08 (следующая контрольная точка, [§123 журнала](fable-continuation-20261003.md#copied-formal)):
[COPIED-METHOD-DECLARED-FORMAL](#copied-method-declared-formal) и [COPIED-CALLABLE-ACTUAL](#copied-callable-actual)
исправлены; запись [T7-LOCAL-NAMED-UNIT](#t7-local-named-unit) исправлена аудитом оракула Codex — её первый свидетель
наблюдал верное значение.

<a id="copied-method-declared-formal"></a>
### COPIED-METHOD-DECLARED-FORMAL — 2026-10-08, Opus (найдено пробой границы приёма, K03-READ-FIELD-CLOSURE-20261008-31), FIXED 2026-10-08

Вызов вхождения метода из другого пространства — `b1\getq(w)`, где b1 — копия Structure, чьё вызываемое поле держит
getq, — допускает объявленный структурный формальный параметр q к требованию в отрисовке вызывающего (нативно — допуск
D-105 на фактическом аргументе в `l2_emit_call`, `lmx_arena_ref_struct(self, 0U)`; при обходе `l2_rw_recv_req`
формальных не берёт), а тело вхождения (копия метода под копией единицы) читает q через Wide своего узла: «a field of
a formal admitted by name is not carried by its value», нативно и при обходе; на HEAD так же. Свободный вход того же
вхождения допускается в его пространстве ([MERGE-PARENT-MODEL-SOURCE](#merge-parent-model-source),
`unit_merge_parent_model_method`). Тот же механизм применим к объявленным входам (нативно три формы допуска
формального — вхождение, позиционный, D-105 — под `l2_recv_ref(idx, l2_c<t>)`; при обходе `l2_rw_recv_req` для
формальных), но он меняет каждый вызов, допускающий объявленный структурный формальный, а вызов через формальный
параметр-вызываемое с несколькими классами (`l2_emit_call_classes`) допускает формальный один раз для классов, тела
которых могут читать разные пространства. Codex (ответ на PROGRESS 5, K03-READ-FIELD-CLOSURE-20261008-31): это
следующая обязательная зависимость, до PATH-STRUCTURE-LEAF; свободный или объявленный вход — договор приёма один:
требование формального разрешается в пространстве выбранного вхождения, как его читает тело, а вычисление
фактического аргумента остаётся у вызывающего; при нескольких классах — класс уже выбранного вхождения и его политика
приёма для того же вхождения, а не все возможные классы, их объединение, прототип или метод, объявивший
параметр-вызываемое. Свидетели: `unit_merge_parent_method_formal` и `_walk` (красные).

Исправлено 2026-10-08 ([§123 журнала](fable-continuation-20261003.md#copied-formal); Codex, ответ на PROGRESS 5 и
обзор PROGRESS 7). Объявленный структурный формальный допускается на вызове к требованию, прочитанному в пространстве
выбранного вхождения, как свободный вход: нативно три формы допуска (вхождение, позиционный, D-105) — под
`l2_recv_ref` приёмника, `<вхождение>\parent` для тела, читающего через `node`; при обходе — допуск с отметкой
RECEIVING (`l2_rw_recv_req` берёт и объявленные формальные). Приёмник — сам вызываемый метод при вызове по имени или
по пути; через параметр-вызываемое — голова класса выбранного вхождения. Класс выбирается один раз, сразу после того
как вхождение захвачено и до первого фактического аргумента (`l2_emit_call_select`): вхождение класса — ребёнок,
которого его держатель хранит в слоте метода (`l2_occ_slot`), держатель достигается связями `parent` вхождения
(`l2_occ_hops`: метод файла — 1, метод части с построенным корнем — 2, вложенный — 1 + хозяина), единица и любая её
копия одинаково (копировщик сохраняет позиции детей и ставит родителем копии копию родителя; поглощение при композиции
трогает только корни операндов); каждый класс проверяется, остатка нет, вхождение без класса и отсутствующее —
общий инвариант. Классы различаются договором приёма там, где есть допуск (`l2_cfl_recv_alike`: модели объявленных
структурных формальных и вид пространства; решение эмиссии, не равенство типов), и каждый класс допускает
фактический аргумент своей моделью в своём пространстве — после единственного вычисления аргумента, до следующего.
Факты D-105 фактических вызова через параметр-вызываемое хранятся строками и после замыкания потока даются каждому
достигающему методу как аналитика (`l2_cfa_apply`): статический кандидат, которого Consumer метода не допускает,
этому методу записи не даёт, и класс отказывает в нём, когда выбран он, неявным `implements` вызывающего; место,
переданное дальше, — мягкое ребро (`l2_d105_edge_add`), чей кандидат, не допускаемый методом, отказывается там, где
класс формирует вход, а не для всего вызова. Перепись до правки (стадия с маркерами, 2585 трансляций `opus_full_63`):
513 нативных допусков объявленного структурного формального в 186 строках, все у вызываемых с политикой `node`;
вызовов через параметр-вызываемое с несколькими классами — 8 строк, все члены — методы единицы с `node`, без
структурных формальных; один класс со смешанной политикой (`unit_held_actual_alike`, только числовые входы) остался
одним. Реплей `opus_full_63` до и после: 200 строк отличаются только L1 — 188 строк пространства требования
нативного допуска (3027 строк), 186 строк обходимого RECEIVING (501 фрагмент), 8 строк селектора, 6 строк
вызываемого аргумента по пути ([COPIED-CALLABLE-ACTUAL](#copied-callable-actual)); выходы и сообщения те же.
Свидетели с обходимыми двойниками, три режима: `unit_merge_parent_method_formal`, `unit_formal_recv_reference`,
`_classes`, `_models`, `_static`, `_ordinal`, `_write`, `_reuse`, `_context` (на HEAD красные), `_name` и `_absent`
(контроли маршрута, на HEAD зелёные). Найдено тем же трудом и исправлено им же:
[CALLABLE-FORMAL-OTHER-MODEL](#callable-formal-other-model), [CALLABLE-FORMAL-CLASS-REMAINDER](#callable-formal-class-remainder).

<a id="copied-callable-actual"></a>
### COPIED-CALLABLE-ACTUAL — 2026-10-08, Opus (найдено свидетелем границы приёма, K03-READ-FIELD-CLOSURE-20261008-31), FIXED 2026-10-08

Вызываемый фактический аргумент, заданный путём через merge-копию, — `recv(b1\peek)`, где поле peek копии b1 держит
собственное вхождение peek под C, копией единицы, — нативно отдаёт формальному параметру вхождение единицы
(`l2_cf_actual_emit` → `l2_tok_method_occ`: «дескриптор метода в единице»), а не выбранное путём; обходимый корень
отдаёт выбранное путём (`l2_rw_callable_actual`: «физический лист выбранного пути»). Прямой вызов по пути `b1\peek()`
и нативно выбирает вхождение копии. Тело peek читает `node\cnt`: через формальный нативно — cnt единицы (5, записанный
корнем после merge), прямым вызовом — cnt копии (1). Свидетели: `unit_merge_parent_callable_actual` и `_walk`,
красные: нативная половина каждой строки (нативный корень) даёт 81, обходимые — 7; на HEAD свободный вход a3 здесь
отказывал во всех режимах, а проба без свободного входа (peek возвращает `node\cnt`) и на HEAD нативно даёт 81.
Распознаватель вызываемого аргумента считает поле-вызываемое «общим окончанием, а не второй копией» (`l2_cf_actual`);
копия, держащая своё вхождение по правилу merge-родителя, это допущение опровергает. Тот же выбор делает `_model_subref` нативно (вхождение единицы); его итог от этого не
зависит. Маршрут ссылки на вызываемое входит в зависимость
[COPIED-METHOD-DECLARED-FORMAL](#copied-method-declared-formal): вызываемое вхождение выбирается до фактических
аргументов, его класс и политика приёма — по нему.

Исправлено 2026-10-08 ([§123 журнала](fable-continuation-20261003.md#copied-formal)): нативно путь — вхождение,
которое он выбирает: лист пути, пройденного как голова вызова по пути (`l2_emit_path`), во временной своей ячейке
(`l2_cf_actual_emit`), как при обходе (`l2_rw_callable_actual`); имя метода — вхождение, которое держит единица этого
метода. Шесть строк `opus_full_63` с вызываемым аргументом-путём меняют только L1; свидетели
`unit_merge_parent_callable_actual`, `unit_formal_recv_reference` и `_classes` (копия и оригинал одного метода с
общим кодом: 41 и 45; на HEAD 45 и 45) — зелёные в трёх режимах.

<a id="t7-local-named-unit"></a>
### T7-LOCAL-NAMED-UNIT — 2026-10-08, Opus (найдено переписью вида T7 по обзору Codex DECLARATION 8, K03-READ-FIELD-CLOSURE-20261008-31), OPEN (обязательный позитив, красный)

Узел callable merge исполняет код модели над своей копией единицы, сделанной при merge; код локальной именованной
Structure этой модели читает единицу программы (`l2_m_unit_ref`: `l2_program_unit` для собственной именованной
Structure метода), а не копию: в `unit_merge_parent_t7_local_proc` модель исполняет S, чей код читает cnt, корень пишет
cnt: 9 после merge — узел возвращает 9, а код самой модели прочёл бы 7 копии. На HEAD так же. Свидетели:
`unit_merge_parent_t7_local_proc` и `_walk` (красные).

Исправление записи 2026-10-08 (аудит оракула Codex, K03-READ-FIELD-CLOSURE-20261008-31; [§123
журнала](fable-continuation-20261003.md#copied-formal)). Оракул 7 был неверен: в `v: cnt` cnt — свободное имя S
(ни S, ни model его не объявляют, merge связывает только y); model пересылает его как свой скрытый вход, корень на
вызове `w()` отдаёт свою привязку — рабочее значение своего cnt, 9 — и по правилу динамики (docs #dynamic) привязка
вызывающего идёт первой, а копия лексического контекста — только запасной путь (трамплин model читает
`l2_self\parent` лишь для отсутствующего входа). 9 — верное значение; строка `unit_merge_parent_t7_local_proc`
теперь ожидает 9 и зелёная; измерения контрольной точки 3f1167c5 остаются историей. Позитивы с различимыми
значениями источников, зелёные в трёх режимах: `unit_merge_parent_t7_caller` (привязка корня 9, ячейка единицы 11,
копия 7 — 9), `_t7_formal` (формальный вызывающего метода — 40), `_t7_path` (явный `node\cnt` модели — копия, 7).
Дефект политики единицы реален, свидетель другой: `unit_merge_parent_t7_local_call` — локальная S модели вызывает
метод единицы get, читающий `node\cnt`; нативно и при обходе корня S выбирает get в единице программы
(`lmx_arena_ref_struct(l2_program_unit, …)`: `l2_m_unit_ref` даёт собственной именованной Structure метода
`l2_program_unit`), тогда как код самой model выбирает его через `node` (копию): 117 вместо 77, при обходе методов
77 (обход идёт по реальным связям). Запасной путь лексики (имя недоступно вызывающему, доступно в скопированном
контексте) производителя в языке пока не имеет: вызов до объявления корня отказан («unbound dynamic input»),
вызываемая модель части с корнем — отказ «unresolved name» (S ищет cnt в единице программы) —
`unit_merge_parent_t7_part` с частью, обязательный позитив, красный; `callable` как операнд merge по пути не опущен
(43e3ce70). Объявление в теле корня — привязка корня (неявное использование скрытым входом на вызове — тоже
использование). Порядок (Codex): после COPIED-METHOD-DECLARED-FORMAL и COPIED-CALLABLE-ACTUAL, до PATH-STRUCTURE-LEAF —
общая проекция единицы/лексики фактического вхождения по реальным связям `parent`/координат источника, без
отката к единице программы для копии, вложения и части. Свидетели: `unit_merge_parent_t7_local_call` (красный; его
двойник `_walk` исполняет трансляцию с обходом методов и зелёный, 77), `unit_merge_parent_t7_part` и `_walk`
(красные).

Продолжение Codex после RELEASE Opus, 2026-10-08: первый срез нативных читателей
единицы/предка реализован по фактическим рёбрам PLACE. `codex_t7_focus_01`:
local_call и новый local_control (две вложенные IF) проходят во всех трёх режимах;
часть по-прежнему отказана, общий тикет OPEN. Сравнение 2615 трансляций с full65:
выходы и диагностики не изменились, 390 изменений L1 ограничены проекциями
лексических адресов. Полный `codex_full_01`: RED67/2618, против full65 один
FAIL→OK (local_call), ни одного OK→FAIL, две новые зелёные строки local_control,
без удалённых строк и без изменений сообщений оставшихся отказов. Ядро GREEN297,
L3 — 11 наборов и четыре budgets. Усиленный пример, где get вызывается только
из локальной S, остаётся красным: его зависимость отсутствует в копии (нативный
exit 3); замыкание сохранённых тел требует следующего среза. Цепочка читателей,
байты и проверки — [журнал среза](t7-lexical-projection-20261008.md).

Следующий срез Codex: общий список сохранённых кодовых
тел замыкается по паре «дом кода / якорь NODE». Локальные определения берутся
из исходных полей уже сохранённых контейнеров, включая тела управления;
их внешние обращения добавляются транзитивно, внутренний NODE не становится
путём от единицы. `unit_merge_parent_t7_local_only_get` и
`unit_merge_parent_t7_local_only_nested_get` с двойниками проходят; модель сама
get не вызывает, оригинал изменяется после копирования. Первый чекпойнт
`65d60a49` на изолированном примере завершался с exit 3 из-за отсутствующего
get. Новый исходник `6cc8106c`: kernel02 GREEN297/114 выполненных самотестов,
L3_03 — 11 наборов/четыре budgets; full02 RED68/2624. Прежние строки не дали
регрессий или изменённых сообщений; добавлены шесть (пять зелёных, один новый
обязательный позитив красный). Ненотированные
обращения моделей допуска и нативных скрытых входов этим не закрыты.

Проверенный исходник Codex `bca1af00` отделяет происхождение кода локальных определений
части от классификации метода и физического NODE; числовой запасной вход
адресуется по готовым рёбрам parent. Десять новых контролей части/порядка
объявлений/переданного 40 и нуля зелёные (family03: 99 targets, три прежних
отказа). Обычный model сам читает и пересылает cnt: достижимость отсутствующей
ветки S этим не доказана. Исторический позитив части теперь отказывает позже,
на корневом poke, но не стал зелёным. Kernel04 GREEN297/114 выполненных
самотестов, L3_05 — 11 наборов/четыре budgets; full04 RED67/2638: прежние
вердикты не изменились, добавлены десять зелёных строк, удалённых нет.
Общие сообщения harness прежние; две реальные диагностики части изменились,
как записано выше. Двенадцать отрицательных исполнений неверного ожидания
дают 81 вместо 7 и отказ драйвера, в том числе при обходе очищенного корня.
Это не закрытие тикета. Следующие проверки отделят классификацию корневого
вызова метода части от выбора фактического родителя модели в конструкторе T7.

<a id="part-call-head-declared"></a>
### PART-CALL-HEAD-DECLARED — 2026-10-08, Codex, FIXED 2026-10-08 (T7 остаётся OPEN)

Общий ранний распознаватель имени метода `l2_unit_names_method` читает только
`l2_cur_unit`. COUNT/FILL главного файла выполняются до регистрации методов
частей; поэтому первый `poke(5)` в корне становится определением именованной
Structure, а не вызовом метода части. В отдельной части:

```text
int: cnt 7
sub: poke (int: n)
    node\cnt: n
fn: read () int
return: node\cnt
```

Главный файл `poke(5)` / `int: result read()` возвращает 7 вместо 5
(`part_next_before_02_poke_value`, `bca1af00`); нативный и methods-walked
позитивы отказаны своим числовым оракулом. Второй `poke(11)` отказан на строке
2 как `root operation not walkable yet: this declaration`. Историческая пара
`unit_merge_parent_t7_part` теперь достигает этого же дефекта.
Исправление — общий просмотр уже прочитанных исходных объявлений методов
программы до классификации, не раннее вычисление сигнатур, не специальный
`poke`, не runtime-поиск. Вложенные методы не экспортировать наружу, обычным
именованным Structure не давать видимость назад.

Проверенный исходник `09e69997` применяет один корневой просмотр к главному
файлу и уже прочитанным частям; не собирает сигнатуры и не обходит вложенные
тела. Focus stage04: все десять новых строк зелёные, два прежних T7-позитива
красные. На прежнем бинарнике sub/fn/межчастные пары отказывают, пары тела
метода и неэкспортированного вложенного имени уже зелёные — это контроли.
Восемь неверных ожиданий дают 81 вместо 7, в том числе при очищенном native
корня. Kernel05 GREEN297/114 самотестов; L3_06 — 11 наборов/четыре budgets;
full05 RED67/2648: регрессий нет, десять новых зелёных строк. Replay всех
2615 команд full65 изменил только две реальные диагностики части, не exit,
наличие или байты L1. Исходники неизменны через все гейты. Ограниченный
дефект исправлен, родитель T7 и остальные производители остаются OPEN.

<a id="nested-method-owner-last-row"></a>
### NESTED-METHOD-OWNER-LAST-ROW — 2026-10-08, Codex/Opus, FIXED 2026-10-08 (ограниченный производитель; T7 OPEN)

RESULT `CODEX-T7-MODEL-PRODUCER-20261008-14`: `l2_mad_take_nested` после
`l2_collect_method` берёт `l2_m_n - 1` для присвоения владельца. Сбор метода
может добавить после собственного ряда вложенные методы и дескрипторы
callable-формалов либо не добавить ряд для связанного bodiless-объявления.
В первом случае хозяин попадает не собственному ряду, во втором возможна
самоссылка прежнего ряда. Это дефект производителя связей, не основание
вводить иной runtime-поиск или предел глубины T7. Минимальная следующая
проба: вложенный helper с in-place callable-формалом внутри фабрики; такое
имя не должно экспортироваться в корень. Сначала записать фактический отказ
или неверное исполнение, затем адресовать первый действительно опубликованный
ряд исходного объявления. Отдельный вопрос допустимости связывания вложенного
объявления с корневым определением этим не решается. До исполнения свидетеля
не считать описанные исходные формы runtime-доказательством.

Измерение Codex: `owner_formal_before_01` на бинарнике full05 действительно
отказывает внутренним расхождением COUNT/FILL; owner-only кандидат
`codex_owner_stage_01` исполняет тот же helper/formal пример. Кандидат
`8341e6ba` адресует первый опубликованный ряд по исходной identity и не
трогает прежние ряды, если новый не опубликован. Постоянный позитив
`unit_nested_method_owner_formal` проходит с native E=5 и повтором через
очищенный корень; его --walk-methods двойник оставлен обязательным красным
до общего callable-formal producer. Проба с корневым helper остановилась
раньше на duplicate definition: самоссылку ею не доказали. Focus stage04
91/4, 18 неверных исполнений отказаны. Финальный kernel06 GREEN297/114
самотестов, L3_07 — 11 наборов/четыре budgets, full06 RED68/2660:
ни одной регрессии, два прежних FAIL→OK и 12 новых строк (9 GREEN/3 RED).
Все входы неизменны через полный гейт и replay 2615 команд. Исправлен
измеренный производитель владельца, не весь callable-formal pipeline:
отдельная вложенная inline-сигнатура воспроизводит неверный LAST-row выбор
в l2_cf_set. Полный обход callable-формалов и parent-стадия T7 остаются OPEN;
самоссылка связанного объявления отдельным исполнением не доказана.

<a id="inline-callable-descriptor-last-row"></a>
### INLINE-CALLABLE-DESCRIPTOR-LAST-ROW — 2026-10-08, Codex/Opus, FIXED (bounded child; T7 OPEN)

После рекурсивного сбора inline callable-сигнатуры l2_cf_set привязывал
формал к последнему добавленному дескриптору вместо первого собственного
ряда. Минимальный `take(op(fn: (inner(fn: (int: q) int) int(x)) int) int(value))`
отказан на op(inc,value) в 6:17: `more arguments than op has formals`.
Кандидат использует общий l2_collected_row с проверкой исходной identity,
как производитель владельца. Двух-/трёхуровневые постоянные позитивы проходят
нативно и при обходе методов; финальный focus05 GREEN21. Расширенный family01
222 targets / шесть прежних отказов: четыре FAIL→OK, ни одного OK→FAIL;
три изолированных мутанта и 12 неверных исполнений отказаны.
Сигнатуры не исполняются,
descriptor-only addr=0 сохраняется. Общий предел длины имён этим не снят.
Kernel07 GREEN297/114 самотестов, L3_08 — 11 наборов/четыре budgets;
full07 RED64/2666 без прежних регрессий. Replay всех 2615 команд проверен,
замороженные входы не изменились. Подробности —
[журнал T7](t7-lexical-projection-20261008.md).

Соседний измеренный дефект контракта: обходчик получал скрытый cnt выбранного
callable, но проверочный контракт описывал лишь явные входы примера-сигнатуры.
Два T7-позитива давали INVALID; общий производитель контракта исправляет
счётчик/свидетели выбранной formation без изменения METHOD. Полный обход
multi-formation потребителей этим не реализован: они явно остаются native.

<a id="receiving-actual-unit-ancestry"></a>
### RECEIVING-ACTUAL-UNIT-ANCESTRY — 2026-10-09 UTC, Codex, bounded implementation gated; parent acceptance OPEN

Метод части с обычным `int: partMarker 0` находится на два parent-ребра
ниже единицы. На c4f65a8b свободный Structure-вход и объявленный формал
материализованной части допускались относительно исходного глобального
описания, тогда как тело читало описание в копии. Нативно exit 3 (нет записи
implements), при обходе INVALID; корень с очищенным native тоже падает.
Прежний rootless-контроль части имел только fn и не создавал это второе
ребро. Поэтому его зелёный результат не доказывал правильность общего пути.

Кандидат `9922b2ac` использует единое отношение `l2_lex_depth_at`, явные
фазы static/committed, growable `l2_recv_ref`, NODE с типизированным числом
предков и проверку ключей классов после PLACE. В диагностических источниках
rootless, free и two-copies проходят 12 исполнений (native/walked/cleared
root). Глобальная нативная подмена ловится обычным запуском, однорёберная
подмена walker — cleared-root; обратные режимы этих мутантов зелёные,
поскольку изменён только один движок. NODE GREEN20 и три rejected mutants.
Kernel09 GREEN297/114 самотестов и L3_09 (11 наборов/четыре budgets)
завершены; full08 RED68/2674 без старых регрессий. Replay2615 сохраняет все
exit/диагностики: 2613 полностью равны, два L1 меняют только источник модели
допуска и связанные операнды. Двенадцать входов неизменны через всю цепочку.
Четыре новых межфайловых заголовка остаются RED; T7 OPEN.

<a id="hosted-native-completion"></a>
### HOSTED-NATIVE-COMPLETION — 2026-10-09 UTC, Codex, OPEN

В full07 `unit_nested_method_owner_formal` вложенный helper имеет готовое
типизированное тело, но не trampoline/native-слово; возвращаемый inner
дополнительно понижен в ложный `return: 0`. Причины: hosted/capture guard
в `l2_emit_body_in`, hosted guards обоих вызовов `l2_emit_trampoline` и
`l2_emit_native_word`. Строка m2 — descriptor-only якорь сигнатуры: ей
нельзя придумывать тело или native-адрес. m4 — отдельная корневая Structure
`helper: 5`, m5 — корень программы, не реализации вложенных fn.

Снять только guards недостаточно: текущие `l2_mad_emit` и
`l2_emit_mad_construct_one` создают копию модели без переноса native-слова.
`l2_mad_emit_into` встречается в исторических заметках, но в frozen9922
такой функции уже нет. У вызова возвращённого inner скрытый n приходит
как отсутствующий refs[1]; `l2_mad_inputs` сохраняет отсутствие. Обходчик
разрешает его через `l2_rw_arg_fb`/`l2_node_seg` в snapshot родителя,
а нативный `l2_emit_tramp_lex` знает только `l2_hid_own_lex`, не место
захваченного формала хозяина. Общий источник скрытого входа должен задавать
то же фактическое ребро/слот/тип обоим читателям, без runtime-имён,
вспомогательного графа или отдельной реализации на каждую копию.

Исправить реальное тело, общий критерий native-публикации, hidden-fallback
и сохранение единственного native-адреса модели в копии. Приоритет явно
пришедшего входа, включая ноль, не менять. Acceptance: исходный/копированный/
возвращённый callable, два snapshot, примитивный и Structure-вход, callable-
формал, descriptor-only addr=0; точные native/walked pins и очищенный native
корня; отрицательные/мутантные проверки, kernel/L3/full/replay. Консультации
Opus21/22 ошиблись в нумерации методов и факте вызова mk; эти утверждения
не являются свидетельствами. Точные проверенные исходники —
[журнал T7](t7-lexical-projection-20261008.md).

#### Проверенный девятый срез HOSTED-NATIVE-COMPLETION

Development blob `0deedaa9` снимает stub/hosted guards общим критерием
native-публикации, переносит native-слово в обоих текущих конструкторах и
разрешает отсутствующий вход общей `l2_hid_source` для native/ARG. Обычный
typed-unmarshaler единственный; Structure получает машинный pointer-value
temporary вне условного блока, не вспомогательный граф. `l2_scan_path_root`
передаёт место чтения; `l2_mcap_add` владеет Text-view, как `l2_dyn_add`.
Промежуточные регрессии `_01` (неверно forwarding) и `_02` (время жизни view)
исправлены до production-среза `_03`, не объявлены ограничениями языка.
Десять диагностических сборок / 20 исполнений успешны; 16 наблюдений реальных
native-слов отличают baseline от исправления, включая walked/cleared-root.
Четыре изолированных мутанта отказаны восемью исполнениями. Focus03 RED2/65
только на прежних whole/merge; kernel10 GREEN297/114, L3_10 успешен.
Full09 завершён RED70/2679; replay2615 — 317 изменений только L1, exit и
диагностики не меняются. Два новых отказа — устаревшие оракулы диагностики
native/запрета native-конструктора. Focus04 RED2/73 проверяет их исправление
реальными исполнениями обоих режимов/cleared-root и точными native-словами.
Свежий full10 RED68/2683: старых регрессий нет, девять добавленных GREEN,
удалённых строк нет. Все 2615 результатов replay02 побайтово совпадают с
replay01; относительно восьмого среза изменены только 317 L1, exit/диагностики
и наличие выхода неизменны. Kernel10/L3_10 явно переиспользованы при точном
совпадении четырёх входов; 11 замороженных входов и 22 копии гейтов совпали.
Этот ограниченный native-маршрут проверен, но общий дефект не закрывается:
PAP/native-composed completion, whole/merge-захваты и T7 остаются OPEN.

<a id="part-header-cross-file-offset"></a>
### PART-HEADER-CROSS-FILE-OFFSET — 2026-10-09 UTC, Codex/Opus, OPEN

Одни комментарии перед Wide в основном файле или перед `fn: getq (Wide: q)`
в части меняют принятие этой сигнатуры. `l2_collect_method(..., lexical_mi=-1)`
выставляет `l2_vis_from(fn_node)` по смещению PART; `l2_type_model` через
`l2_ns_find`/`l2_vis_ok` сравнивает с ним смещение MAIN. Числа разных файлов
не задают порядок видимости. Позитивы focus04 rootless/two-copies отказаны
как unknown type; declared/free с другими комментариями зелёные. Игнорируемые
диагностические источники дают обратное распределение. Комментарии не
удалять ради PASS. Уточнить общий источник/владельца заголовка по уже
утверждённой видимости, не разрешать все имена назад и не вводить signature-
спецслучай. Полный коррелированный RESULT Opus20 получен: это именно
сравнение MAIN/PART offsets, не эффект setMarker. Запрет части видеть MAIN
записан ответом агента fable_pc, а авторское правило порядка файлов не
найдено. [Вопрос автору](../LMX_blog/q/current/program-parts-declaration-visibility.md)
задан прямо в чате; зависимый выбор видимости не делается до ответа.
Точный материал и независимые receiving-свидетели —
[журнал T7](t7-lexical-projection-20261008.md).

<a id="t7-projected-parent-field"></a>
#### T7-PROJECTED-PARENT-FIELD — 2026-10-08, Codex, FIXED 2026-10-08 (T7 остаётся OPEN)

У модели `int: seed 6`, локальная S читает `node\seed + get()`; get читает 7
из скопированной единицы, оригинал после merge изменяется на 11. Норма даёт
13, до исправления нативно получалось 12, при обходе методов — 13. Производитель T7
вставляет добавленное y=5 в слот 2, seed сдвигает в слот 3, а нативная S
сохраняет исходное чтение слота 2. Базовый full65 без слагаемого get тоже
читает 5 вместо 6: дефект старше обоих срезов Codex. Постоянный позитив
`unit_merge_parent_t7_local_node_view` в full02 красный, двойник `_walk` зелёный;
не менять ожидаемое значение и не выключать нативный адрес ради гейта.

Производители: `l2_t7_fill`, `l2_t7_count`, `l2_t7_emit_frames`,
`l2_t7_emit_make`; читатель слотов добавленных данных — `l2_t7_bound_slot`
и его потребители. Консультация Opus `CODEX-T7-NATIVE-VIEW-20261008-06`
подтвердила цепочку. Правило `#composition` уже требует сохранять слоты
модели и добавлять новые поля в конец; чинить общий производитель и согласовать
COUNT/PLACE/FILL, без таблицы координат в runtime, варианта нативного кода для
каждой копии или поправки смещения в отдельном читателе.

Новые диагностические фикстуры унаследовали `merge(y: k; model)` от старых
T7-строк. После full02 четыре новых входа явно переведены на
`merge(model; y: k)` и проверены в focus04 (тот же исходник/инструменты,
не повтор полного гейта): прежние двенадцать verdict и сообщения совпадают,
три отказа из 15 targets. Это известный
[T7-DATA-FIRST-SHAPE](#t7-data-first-shape), а не изменение нормы: данные первым
операндом создают внешнюю модель, содержащую вложенный метод, и не должны
молча превращаться в тот же callable. Старые входы сохраняются как история.
[MERGE-KEEPS-MODEL-INTERFACE](#merge-keeps-model-interface) также остаётся OPEN:
формал со значением по умолчанию должен оставаться явно подаваемым формалом.

Продолжение Codex: производитель исправлен в кандидате `e471c941`
(SHA256 `B07970E8EF3CCF21C71CA50BDAF468B3739CD01416D735AC1BBA3AE8551EA32C`).
COUNT сначала измеряет тело/trailer; добавленные ячейки получают координаты
`head + steps + j` до PLACE. COUNT/PLACE/FILL и ширина корня согласованы.
`local_node_view` нативно теперь даёт 13, обходчик не изменился. Focus06
GREEN11, family02 — 89 targets / три прежних отказа; kernel03 GREEN297/114
выполненных самотестов, L3_04 — 11 наборов/четыре budgets. Полный full03
RED67/2628: против full02 один FAIL→OK, ноль OK→FAIL, четыре новые зелёные
строки, удалённых строк и изменённых сообщений оставшихся отказов нет.
Исходник, инструменты и фикстуры неизменны через все гейты; staged-копии
full03 совпадают с живыми байтами. Закрывается только этот дефект, не T7,
полная сигнатура/defaults или нативный адрес составного корня.
Старый физический оракул
local_definition явно мигрирован: S остаётся в слоте модели 2, новый y
добавлен в слот 5, ширина 6. Результат, независимость копий, parent и
нативные слова не ослаблены; старый оракул отказывает новому размещению
в сохранённом family01. Два новых парных позитива проверяют два добавленных
значения, два NODE-поля модели, повторное использование копий и модель только
с trailer. Подробности — [журнал T7](t7-lexical-projection-20261008.md).

<a id="callable-formal-other-model"></a>
### CALLABLE-FORMAL-OTHER-MODEL — 2026-10-08, Opus (найдено переписью COPIED-METHOD-DECLARED-FORMAL), FIXED 2026-10-08

Параметр-вызываемое с договором `getq (Wide: q; …)` допускает (структурным правилом сигнатур, `l2_ft` у всех
Structure один) вызываемое `getr (Other: q; …)`; на вызове через формальный факты D-105 и статический допуск
записывались на договор, допуск во время выполнения рисовал модель договора — прототип, — а классы различались только
формированием, и getq с getr попадали в один класс: getr читал x своего Other по позиции — первое место Wide, pad
(`unit_formal_recv_models` b: 91 вместо 41, `unit_formal_recv_static` — то же; три режима, на HEAD так же).
Исправлено вместе с [COPIED-METHOD-DECLARED-FORMAL](#copied-method-declared-formal): договор приёма класса, факты на
достигающие методы, допуск выбранного класса; `l2_method_sig_compatible` не усилен (Codex: модели структурно
совместимы и допускаются). Свидетели: `unit_formal_recv_models`, `_static` (зелёные).

<a id="callable-formal-class-remainder"></a>
### CALLABLE-FORMAL-CLASS-REMAINDER — 2026-10-08, Opus (найдено переписью COPIED-METHOD-DECLARED-FORMAL), FIXED 2026-10-08

Вызов через параметр-вызываемое с несколькими классами выбирал класс сравнением вхождения только с вхождениями
единицы (через ссылку на единицу метода-потребителя), а последний класс брал без сравнения: вхождение копии любого
класса, кроме последнего, исполнялось как последний класс — со скрытыми входами чужого формирования
(`unit_formal_recv_classes`: «a trampoline was called outside its method's signature», на HEAD). Исправлено
селектором [COPIED-METHOD-DECLARED-FORMAL](#copied-method-declared-formal): держатель вхождения по его связям
`parent`, каждый класс проверяется, остатка нет. Мутант со старым сравнением ловится `_classes` (инвариант «in no
class the translation proved»); мутант с остатком вместо инварианта не достигает ни одной программы (каждое
вхождение имеет класс). Свидетель: `unit_formal_recv_classes` (зелёный).

<a id="node-path-anon-struct"></a>
### NODE-PATH-ANON-STRUCT — 2026-10-08, Opus (найдено при свидетелях K03-READ-FIELD-CLOSURE-20261008-31), OPEN (обязательный позитив, красный)

`node\h\p` в коде именованной Structure, где h — анонимная Structure тела корня, отказывает при трансляции на `node`
(«unknown field path segment»), нативно и при обходе, на HEAD так же: `node\name` называет поле значения тела
лексического родителя (книга §3), и h — такое поле, но перебор своих полей не даёт вида Structure-полю без записанного
типа. Свидетели: `unit_node_path_anon_struct` и `_walk` (красные).

<a id="bind-call-entry"></a>
### BIND-CALL-ENTRY — 2026-10-07, Opus (перепись K03 S6), FIXED 2026-10-07 (K03 S6)

Перепись S6 сопоставила каждый вызов проверки, эмиссии и обходчика по месту; единственные вызовы, выданные эмиссией и
обходчиком без проверки, — `c` в `if: c != 2` у `unit_k03_alias_bare`: привязка `c: two` (NS-ROLES-1b), названная как
значение, шла своим частичным путём. Пробы нашли три дефекта маршрута привязки, нативно и при обходе:

- в модуле без именованных Structure, результатов merge и путей `node\` любой вызов через привязку (`c`, `c()`,
  `int: v c()`) не компилировался: «'l2_pst' undeclared» — пролог метода объявлял самость пути только при тех трёх
  признаках, а вызов через привязку выбирает своё вхождение через неё (`l2_emit_alias_self`);
- привязка, названная как значение, не проходила общую проверку вызова (`l2_check_call`: арность, рёбра, throws,
  отметка динамических входов): `got: c + 0` с бросающим `boom` без catch давал «1:1: internal: a callee's declared
  throw is not handled by its caller» из эмиссии, а `c()`, `boom` и `boom()` — «unhandled throw: Oops» у места;
- в месте, принимающем число, голая привязка читалась как ячейка-ссылка: `int: v c` и `id(c)` — «a reference where a
  number is asked», `z: c` — «assignment value has incompatible type», `return: c` — «return value has incompatible
  type», тогда как операнд `c != 2` и все формы `c()` работали.

Исправлено ([§120 журнала](fable-continuation-20261003.md#unified-head-s6)): привязка, названная как значение,
проверяется как вызов вызываемого (`l2_check_primary` → `l2_check_value_call`); её значение там, где принимается
число, — результат вызываемого (`l2_colon_simple_ty`, как `l2_native_cf_ty` в операнде); пролог объявляет `l2_pst`, где
модуль держит привязку-ссылку. Свидетели `unit_s6_bind_plain_unit`, `_number_place`, `_hidden_input`,
`_value_throw_caught`, `_value_throw_refused` с двойниками; мутанты m07–m09 краснят их.

<a id="path-structure-leaf"></a>
### PATH-STRUCTURE-LEAF — 2026-10-07, Opus (K03 S6; Codex K03-CALLABLE-PATH-20261007-25), PARTIAL 2026-10-09

Десятый срез Codex исправляет перечисленные ниже выбор вхождения и
границы вызова/приёма ссылки через общий путь. Четыре пустые формы,
глубокое анонимное тело, копия, передача через формал без исполнения,
переупорядоченный кандидат и путь из метода проверены нативно/обходом,
включая реально очищенный native корня и контроль слов native/копии.
Числовые места отказывают ссылке; непустой вызов нульарной Structure —
ошибка сигнатуры, не запасное присваивание. Обычные Structure не получают
видимости назад. Никаких новых графовых объектов или runtime-имён нет.

Свежие проверки: focus RED5/184, kernel11 GREEN297/114 выполненных
самотестов, L3_11 — 11 наборов/four budgets, full11 RED70/2711 без старых
регрессий. 28 новых строк: 26 GREEN, два обязательных позитива
`unit_path_structure_transport_nested`/`_walk` RED: рекурсивный допуск
через поле-Structure другой модели ещё не построен. Его не заменять
ожидаемым отказом. Replay2615 совпадает с исправленной пробной версией;
против опубликованного предыдущего среза изменены четыре разобранных L1
и две диагностики прежних некорректных вызовов, без смены exit/наличия
выхода. Полное свидетельство и хеш —
[журнал PATH](path-structure-leaf-20261009.md).

Ниже — историческое воспроизведение до исправления. Оно не описывает
текущее поведение проверенных позиций. Общий допуск, родительский T7,
NODE и §§8/8a остаются OPEN.

Отказ обходчика «root operation not walkable yet: a Structure value» (`l2_rw_path_read`, path[3] < 0) после S6 больше
не достигается путём к callable (теперь — вызов), но достигается путём, последнее поле которого — Structure
(`Holder: inner: int: k 1`), нативно и при обходе:

- оператор `Holder\inner` один — «a Structure value», а `Holder\inner()` — «a call path must end at a callable
  field» у проверки; обычная именованная Structure — callable без результата (#callables), и по правилу голой головы обе
  записи — одно нульарное применение выбранной Structure: исполнение вложенной Structure через путь не построено, и две
  записи сегодня говорят о нём по-разному;
- `int: v Holder\inner` — «a Structure value»: проверка принимает путь (ветвь всего значения-пути принимает любой
  разрешённый лист), хотя место числа отказывает ссылке, как `int: v Holder + 1` — «a reference where a number is
  asked»;
- `int: v Holder\inner + 1` — «unresolved name» у inner (одношаговая проверка пути), а не тот же отказ ссылки.

Это отдельные долги от вызова пути (Codex -25: «preserve/register those separate required-positive debts»): строки
обязательных позитивов (исполнение вложенной Structure через путь) и отказов с контрактом места («a reference where a
number is asked») войдут в следующую контрольную точку; отказ обходчика остаётся, пока эти маршруты не построены.

<a id="slot-family-dead"></a>
### SLOT-FAMILY-DEAD — 2026-10-07, Opus (K03 S6), OPEN

K03 S6 удалил обе ветви слотов `l2_collect_decls` — единственного места, где регистрировались слоты
(`l2_sn`, `l2_st`, `l2_m_sn`): `@: char x` и `@: size_t x` — собственные объявления-указатели, ветви были недостижимы
(маркер — 0 из 2441 переводов и 14 проб). Теперь ни одно объявление не регистрирует слот, и все читатели слотов мертвы
по построению: `l2_slot_find` и его семья, 89 обращений примерно в 40 функциях (в лестницах разрешения —
`l2_call_head_method`, `l2_head_resolve`, `l2_colon_bound_ty`, `l2_call_alias_own`, `l2_call_head_held`, — в эмиссии и
прологах). Ограниченное удаление с повтором корпуса (ожидаются побайтно равные переводы) — отдельный шаг.

<a id="reference-field-consumers"></a>
### REFERENCE-FIELD-CONSUMERS — 2026-10-07, Opus (K03 NS-ROLES-2; Codex K03-NS-ROLES-2-20261007-20, K03-NS2-COVERAGE-20261007-21), OPEN

Привязка `b: A` в теле именованной Structure хранится как в корне и методе: типизированная ячейка-ссылка (хранение
`@: T x`, kind 10). Часть потребителей поля-ссылки не построена; для каждого маршрута — обязательный позитив,
зарегистрированный красным, с сегодняшним сообщением:

- путь через поле-ссылку как Structure-фактический вызова и как возвращаемое значение — «a field path must end at a
  Structure» (`l2_actual_path`, `l2_actual_ns`, `l2_emit_actual_path`, при обходе `l2_rw_struct_arg` берут только
  kind 2 и 3): `unit_ns2_ref_arg`, `unit_ns2_ref_return`;
- допуск через поля-ссылки разных моделей (таблица D-105) — «root operation not walkable yet: an admission to a
  Structure type through a Structure field of another type»: `unit_ns2_ref_admit`;
- захват поля-ссылки (пункт 738): `unit_ns2_ref_capture` (сегодня — тот же отказ пути);
- привязка к Structure, которую достигает путь, `into: E\deep`: привязка берёт один атом (в корне и методе тоже), в
  квалифицированной ветви это оператор — «a statement in a nested or qualified named Structure is not supported yet»:
  `unit_eternal_xref` (прежнее `deep: into` значило член E только через глобальную таблицу имён);
- привязка тела к callable (`b: tick`), к значению-Structure (`y: inner`, Structure своего поля выше) и привязка в
  именованной Structure метода: `unit_ns2_bind_callable`, `unit_ns2_bind_value`, `unit_ns2_local_bind`; их временные
  диагностики — строки-пределы с метками `unit_ns2_bind_callable_limit_refused`, `unit_ns2_bind_value_limit_refused`,
  `unit_ns2_local_limit_refused` (не правила языка и не покрытие).

Тот же разрыв есть у полей `@: T x` (семейство типизированного null — открытый вопрос автора, не тронуто). Отказы допуска
и захвата (`unit_s7_arg_path`, `unit_s7_arg_deep_refused`, `unit_s7_ret_path`, `unit_s7_nested_missing`,
`unit_capture_struct_field_struct_refused`) сохранили потребителей на собственном вложенном поле держателя; их
ссылочные версии — позитивы выше.

<a id="named-body-copy-field"></a>
### NAMED-BODY-COPY-FIELD — 2026-10-07, Opus (K03 NS-ROLES-2; Codex K03-S5-ALIAS-VISIBILITY-20261007-07 Q3, K03-NS2-COVERAGE-20261007-21, K03-NS2-COPY-ORACLE-20261007-22), FIXED 2026-10-07 (K03 RECEIVE-OUTPUT)

Исправлено K03 RECEIVE-OUTPUT ([§119 журнала](fable-continuation-20261003.md#receive-output)): результат
`box: merge: Inner` в теле Host — вычисленный выход merge у своего вхождения-приёмника, не поле Host; обязательный
позитив `unit_ns2_copy_field` и бывшая строка-предел `unit_ns2_copy_field_limit_refused` исполняются (код 7, нативно и
при обходе); `Host\box` отказывает (`unit_output_named_notdata_merge_refused`); устаревшие комментарии «поля со
свежей копией» исправлены в байтах этого шага. Ниже — первоначальная запись.

merge в теле именованной Structure: `box: merge: Inner` в теле Host исполняется, когда исполняется тело Host (объявление
Host тела не исполняет — [построение](../docs/LMX_semantics.ru.md#construction); вычисляемая инициализация — когда
управление доходит до строки, без фазы построения и скрытой однократной инициализации —
[§12](../docs/LMX_semantics.ru.md#dynamic); merge — исполняемая операция над живыми операндами —
[композиция](../docs/LMX_semantics.ru.md#composition)); результат принимает box. Не построено: located limit «a merge
construction in the body of a named Structure is not built yet» (до шага — «internal: an own declaration has no physical
field»). Обязательный позитив `unit_ns2_copy_field`: m пишет 3 в Inner\v и вызывает Host(); тело Host копирует, пишет
5 через box и сообщает через объявленные поля Out — копия прочла 3 (значение операнда в момент исполнения; копия при
построении прочла бы 1), запись попала в копию, Inner\v остался 3, второй запуск скопировал снова (4); до вызова тело
не исполнялось. Вариант `box: Inner` (привязка вместо merge) доходит до кода 83 — оракул отличает копию от ссылки. Не
утверждается и не читается: доступен ли box снаружи как Host\box (LMX_blog/q/q53.md: выход вычисляемого приёмника — не
данные; общий RECEIVE-OUTPUT). Прежнее `Inner: box` строило копию при построении Host — измеренное устаревшее
поведение, не норма; первая регистрация позитива (байты `opus_full_57`) повторяла его — копия при построении, Host\box
снаружи до вызова — и исправлена по Codex -22 (перепроверка `opus_focus_ns2_02`). Временная диагностика —
`unit_ns2_copy_field_limit_refused`. Комментарии `l2trans.lm1:19266-19267` и `tools/l2_harness.ps1:5325-5326`,
`5367-5368` ещё называют это «полем со свежей копией»; исправляются при следующей проверке точных байтов транслятора и
харнесса (RECEIVE-OUTPUT). Ни одной программе переписи свежая копия не нужна.

<a id="merge-of-qualified-reference-cells"></a>
### MERGE-OF-QUALIFIED-REFERENCE-CELLS — 2026-10-07, Opus (K03 NS-ROLES-2), OPEN

merge квалифицированного операнда, чья собственная ячейка-привязка держит удерживаемый корень (`self: E` в E,
`peer: E` в F), нативно останавливает R0 неявным броском merge. Изолировано на `unit_eternal_shape`: без строки merge
программа проходит (31 проверка); merge E с изменяемым Holder, чья ячейка держит E, проходит; merge F (с `peer: E`) —
нет. `unit_eternal_shape` была красной до шага на трансляции («root operation not walkable yet: a Structure-typed field
in a method»), теперь транслируется и красная при исполнении; её факты читают ячейки (`deref`). Ядро и эмиссия merge в
этом шаге не менялись.

<a id="receive-name-input"></a>
### RECEIVE-NAME-INPUT — 2026-10-07, Opus (K03 RECEIVE-OUTPUT; Codex K03-OUTPUT-ORACLES-20261007-24), FIXED 2026-10-07 (K03 RECEIVE-OUTPUT)

Маршрут receive отказывал по имени, когда оно уже формал или скрытый вход своего тела (`l2_param_find` до выбора места
выхода: «assignment value has incompatible type», для формала модели — «graph assignment admission requires
receiving-expression tests»), — в методе и в теле именованной Structure; объявления `int:` и merge в том же положении
объявляли своё следующее вхождение. Это обход выбора роли, не норма (Codex -24: Q53 — отдельное вхождение выхода,
дополнение Q25 — явное типизированное место того же тела, не формал и не внешняя привязка; #own — объявление может
затенять формал). Исправлено: отказ по имени снят, выход выбирает `l2_own_output_add`; после формала или поданного
скрытого входа receive — своё следующее вхождение, вход не тронут (`unit_output_receive_after_formal`,
`unit_output_receive_after_input`, `unit_output_named_receive_after_input`; сравнения `unit_output_int_after_formal`,
`unit_output_merge_after_input`); без поданного входа — обычный отказ «unbound dynamic input m» у вызова
(`unit_output_receive_input_unbound_refused`, `unit_output_named_receive_input_unbound_refused`).

<a id="mad-trailer-write"></a>
### MAD-TRAILER-WRITE — 2026-10-06, Opus (перепись K03 S1), OPEN

`l2_mad_take_nested` (две записи `frw\trailer: 0`) стирает в исходном дереве написанный trailer вложенного `fn:` в
модели callable merge: его возврат себя `return: f` и `return: merge(...)`. Это запись трансляции в исходный граф
(норма: граф источника полон, написанное не стирается); из-за неё повторная трансляция требует `l2_release` и нового
разбора ([§106 журнала](fable-continuation-20261003.md#unified-head-s1)). Маршрут головы она не трогает: вид
применения читает голову и тело кадра, не trailer.

Что нужно (ограниченный шаг): держать оба факта — самовозврат и trailer merge — в таблицах `l2_mad`, читатели
`l2_ret_tr` пропускают такой trailer по ним, запись удалить. Свидетели: строки callable merge (`unit_t7_*`,
`unit_make_adder`) нативно и с обходом; повтор с двойной трансляцией без `l2_release` побайтно равен одинарной.

<a id="reserved-name-bindings"></a>
### RESERVED-NAME-BINDINGS — 2026-10-06, Opus (перепись K03 S1), FIXED 2026-10-06 (по ответам Codex K03-RESERVED-NAME-ANSWER-20261006-02/-03)

Норма: зарезервированный ресивер языка применяет свой контракт и не затеняется
([словарь](../next_core_tasks_dictionary_v2.md) :128; план K03). Измерено на `f28decf5`: как имя отвергаются только
слова `l2_ident` (`fn int return if else while for node`); `int: merge 3`, `fn: table () int`, `int: size_t 3`
принимаются в корне и в методе, чтение имени даёт значение. Корпус связывает три слова: `size_t: sub`
(`unit_recursion`; читатели написания принимают присваивание `sub: direct(next)` за ресивер `sub`), `fn: until`
(`unit_continue`, `unit_while`) и `fn: receiveMessage` (`unit_next_message_method_first`: «receiveMessage is a receiver
of the profile, not a reserved word: a declared method of that name takes precedence»). Разрешение K03 ставит видимость
первой (поправка 2 Codex): такое связывание побеждает там, где видно, как сегодня.

Вопрос (Codex): какие слова, кроме слов `l2_ident`, нельзя связывать как имена, и чем ресивер профиля
(`receiveMessage`) отличается от зарезервированного.

**Ответ Codex** (K03-RESERVED-NAME-ANSWER-20261006-02, -03): нового решения языка не нужно — ресиверы и операторы
языка зарезервированы и не затеняются, как `if`; исключения профиля нет; кавычки не снимают резервирования;
резервирование следует определённому контракту слова, а не наличию его понижения.

**Исправлено** ([§108 журнала](fable-continuation-20261003.md#reserved-name-bindings-slice)): одно допущение имени
каждого связывания программы (`l2_bind_admit`) — поле корня, локал метода и вложенного тела, метод, формал (и
вызываемый), поле именованной Structure, ячейка указателя, локал указателя на функцию, квалифицированная ветка, имя у
`receiveMessage` — отказ у имени: «<слово>
is a word of the language: a program cannot bind it»; формы связываний читают любое написание имени
(`l2_bind_spelling`), точное имя в обратных кавычках раскодируется (`l2_exact_ident`). Набор слов (`l2_head_word`)
дополнен по документам: `immutable`, `independent`, `implements`, `test`, `post`, `external`, машинные типы C99
`short long float double signed _Bool`, инструкции модуля `predef define include profile prototype os` (`l2_unit_word`).
Ветки приоритета метода `receiveMessage` удалены. Миграции: 60 фикстур с методом `test` → `mytest`, `unit_recursion`
(`sub` → `recursiveResult`), два порта парсера (`length` → `textLength`), `unit_next_message_method_first` — теперь
отказ (программа с обычным именем — `unit_next_message_method_ordinary`), негейтовые `unit_continue`/`unit_while`
(`until` → `loopCondition`) и `unit_paren_long` (`long` → `nestedSum`). Открытые классификации записаны в §108
(`RuntimeImmutable`, `toLmx`, `llong`/`ullong`/`uint`/`wchar_t`, `ifdef`, `C`/`L1`/`L2`/`L3`).

<a id="own-type-code-bands"></a>
### OWN-TYPE-CODE-BANDS — 2026-10-06, Opus, FIXED 2026-10-06 (FIXED-BLOCKS; по ответу Codex OPUS-CODEX-20261005-01)

Код хранения своего поля несёт вид и тип одним числом, полосами: указатель — 1000 + ft, массив —
2000 + ty, где ft = 100 + номер интернированного чужого типа (имя, глубина, const). С 901-го
интернированного типа (номер 900) ft не меньше 1000, и код указателя попадает в полосу массивов:
`l2_own_is_pointer` отвечает «нет», `l2_own_is_array` — «да». Измерено на `4d7285f4`: метод с
900 объявлениями `@: c.T<i> p<i> 0`, затем `@: Model m @ Model` и `m\value` — отказ у
объявления Model «assignment value has incompatible type»; с 899 программа переводится. С 950
так же отказывает 901-е объявление C, а ссылка на Model (интернирована 950-й, ft 1050, код 2050)
уходит в машинные локалы с моделью 0. Правильная программа с 900 и больше различными чужими
типами отвергается: это потолок из кодировки.

Требуется (Codex): вид и тип хранятся в метаданных транслятора порознь, через существующие
контракты типов, где можно. Не поднимать 1000/2000, не резервировать полосу шире, не
ограничивать число чужих типов, не выделять 900-й тип или Model. Производители и читатели
кодировки проверяются вместе: 1000+ft, 2000+ty, сравнения ≥1000/<2000/≥2000, вычитания,
`l2_formal_raw`/`l2_own_of_dt`, помощники ячеек, адрес и передача, нативная и обходимая эмиссия;
без второго, несогласованного каталога типов. Это IR транслятора, а не новая система типов,
поле графа или словарь имён C; написание чужого типа по-прежнему идёт сырым механизмом C без
чтения заголовков. Положительные ниже и выше измеренной границы, ещё с одним ростом и с другим
порядком интернирования; наблюдать классификацию и значения по адресу, а не одно успешное
переведение. Сквозная сборка C — с объявлениями typedef через обычную возможность test/predef;
перепись большого числа типов на уровне трансляции остаётся.

**Исправлено 2026-10-06** ([§103 журнала](fable-continuation-20261003.md#own-type-code-bands-fixed)). Вид и
формальный тип своего кода — за общими помощниками (`l2_oc_*`): указатель на формальный тип ft — 1000 + 2 ft,
Array указателей — 1001 + 2 ft, полос нет. У ссылки графа свой код в каждом пространстве: формальный — именованный
42 (`l2_graph_code`), как 29 у ссылки Message; хранение — указатель на `Lmx *` (`l2_graph_own`); динамический вход —
его код (`l2_graph_dt`). Формальные таблицы держат только формальные коды, декодеры по интервалу числа удалены,
`l2_colon_graph_ty` удалён. Нулевой литерал в месте-ссылке — ячейка указателя типа значения места
(`l2_value_ft_of_own`); ветка совместимости этапа 1, подававшая свой код как формальный, удалена (Codex,
OTCB-NULL-PROJECTION). Разница семи строк привязана к контракту и исполнена: в обходе перепривязка формала
Structure получила допуск (с прежним транслятором — «lmx: walk error: INVALID»). Свидетели — 899, 950 и 1101 чужих
типов, тип 1102-й как указатель, Array указателей, формал и результат, другой порядок интернирования, нативно и с
обходом; типы — имена C разной глубины, потому что заголовки упираются в 128 имён типов `l1trans`. Код ядра
`LMX_TYPE_POINTER_BASE + ft` — отдельный долг [KERNEL-POINTER-TYPE-RANGE](#kernel-pointer-type-range).

**Пункт приёмки после исправления** (Codex, OTCB-EXACT-NULL-TYPE-WITNESS-20261006-01; [§104 журнала](fable-continuation-20261003.md#null-literal-exact-type)):
точный тип ячейки нулевого литерала засвидетельствован через арену — полезная нагрузка LIT и объявленная ячейка,
которую она инициализирует, принадлежат одному точному типизированному домену (факты драйвера `typepath`,
`nullrefpath`; `@: int p 0` и `@@: int q 0`, до прогона и после); мутант «свой код как формальный» у нулевого
литерала краснеет в `unit_oc_null_literal_type` и её близнеце с обходом.

<a id="kernel-pointer-type-range"></a>
### KERNEL-POINTER-TYPE-RANGE — 2026-10-06, Opus по ответу Codex, OPEN (до G5)

Ядро кодирует тип ячейки указателя как `LMX_TYPE_POINTER_BASE + ft` (1024 + формальный код транслятора), а тип Array
указателей — как `LMX_TYPE_ARRAY_OF_POINTER_BASE + ft` (1048576 + ft) (`dev/l2src_sandbox/lmx.h.lm1`, писатель —
`l2_ptr_cell_type`, `l2_emit_cell_new_ty`; читатели — `lmx_array_owned.lm1`, драйвер). При ft = 1047552 код
указателя попадает в полосу Array: это диапазон кодировки ядра, а не правило языка. Транслятор после
OWN-TYPE-CODE-BANDS больше не делит формальные типы полосами; переход ядра — отдельный шаг с производителями,
потребителями и свидетелем на границе, до зелёного G5 (Codex: граница названа явно, не превращать предел счёта в
правило языка).

<a id="address-type-past-buffer"></a>
### ADDRESS-TYPE-PAST-BUFFER — 2026-10-06, Opus, FIXED 2026-10-06; запись за буфер транслятора, транслятор падал

Тип адреса — указатель на уровень глубже цели — у адреса цели-пути (`l2_emit_address`, `take(@ check\p)`)
и у места, которое захватывается во временное перед записью через него (`l2_capture_indirect_place`,
`\p: 0`), склеивался через `l2_cat` (до 1023 байт) в два буфера по 256 байт на стеке: текст типа и
объявление временного. Измерено транслятором `opus_full_29` (байты `247a6339`; так же `opus_full_28`,
`98993a85`), где `p` — указатель глубины d: до d = 240 L1 верен; с d = 241 объявление адреса выходит за
256 байт, и L1 неверен при выходе 0 — приведение без типа (`(cast: () l2_pxp[0])`, `l1trans`: «cast
missing type»), при 245 `(cast: (2_t1) …)` — его `l1trans` принимает, а gcc отвергает («invalid suffix
"_t1" on integer constant»), при 280 `l1trans`: «pointer type has extra fields»; у захвата L1 неверен при
250; при d = 300 транслятор падает (код 139) и у адреса, и у захвата; при 1100 склейка в 1023 байта
отказывает без места («internal: a refusal said nothing»). Строки харнесса с такой глубиной не было.

**Исправлено 2026-10-06** группой 3 текста выражения
([§99 журнала](fable-continuation-20261003.md#expression-text-owner-group-3)): текст типа адреса и
объявление — тексты (`L2Tx`) любой длины, `l2_cat` удалён. Строки `unit_exprtext_address_deep` и
`unit_exprtext_capture_deep` (глубины 300 и 1100, Entry 7, с двойниками обхода): прежний транслятор на обеих
падает; мутанты, ограничивающие текст типа адреса или объявление захвата 256 байтами и декларатор 1022
байтами, на них отказывают.

<a id="c-call-value-text-cut"></a>
### C-CALL-VALUE-TEXT-CUT — 2026-10-06, Opus, FIXED 2026-10-06; L1 не разбирался

Вызов C, взятый значением, копировал свой текст в место назначения ровно в 256 байт
(`l2_emit_ccall`: `memcpy(into_buf, buf, 256U)`), не глядя на длину. `int: r c.abs(a + ... + a)` из 40
слагаемых (текст между 256 и 1023 байтами) переводился с выходом 0, а L1 обрывался посреди вызова —
`c.abs(l2_p0_0 + ... + )`, и `l1trans` его отвергал: «unclosed parenthesized form». Из 120 слагаемых —
отказ «expression too long». Измерено транслятором `opus_full_24` (байты `c35f78cc`).

**Исправлено 2026-10-06** срезом 1 растущего текста выражения
([§94 журнала](fable-continuation-20261003.md#expression-text-slice-1)): место назначения — сам текст
(`l2_ccall_into`, `L2Tx`), в него кладётся весь вызов. Строка `unit_exprtext_c_value` (40 и 120
слагаемых, Entry 7; только нативно — сырой вызов C оставляет метод нативным); мутант, копирующий
значение в 256 байт, даёт L1, который `l1trans` отвергает.

<a id="alloc-failure-said-twice"></a>
### ALLOC-FAILURE-SAID-TWICE — 2026-10-06, Opus, FIXED 2026-10-06; одна причина — две строки

Отказ выделения памяти в эмиссии говорится дважды: там, где выделение не удалось, и ещё раз в
`l2_translate` после `l2_emit_unit` — `l2_alloc_or(in_path, 0, ...)` при `l2_alloc_err != 0`, на 1:1, не
глядя, сказана ли причина. Правило «одна причина — одна строка» (REVIEW 9256c3b) так нарушается при
каждом отказе выделения в эмиссии. Измерено `L2_FAIL_MALLOC` в обоих трансляторах: у `opus_full_24`
(байты `c35f78cc`) на вызове C значением — обе строки «1:1: out of memory»; у среза 1 текста выражения
при росте текста — «6:420: out of memory» и затем «1:1: out of memory»
([§94 журнала](fable-continuation-20261003.md#expression-text-slice-1)). Строки харнесса с отказом
выделения нет. Правка — второй раз не говорить, если с начала эмиссии диагностика уже была
(`l2_said_or`); свидетелю нужен прогон с `L2_FAIL_MALLOC`, которого харнесс пока не делает.

**Исправлено 2026-10-06** ([§97 журнала](fable-continuation-20261003.md#alloc-failure-rows); решение Codex по
вопросу A): `l2_translate` берёт `l2_diag_n` прямо перед `l2_emit_unit` и говорит об отказе выделения, только если
эмиссия с тех пор ничего не сказала (`l2_said_or`). Свидетели — строки харнесса с отказом выделения: событие
называется по трассе выделений (`L2_ALLOC_TRACE`, вне счёта `l2_xmalloc`), номер находится заново пробным
переводом той же программы, затем перевод повторяется с отказом именно этого выделения; строка требует
`fail_at` = найденному номеру, `err=1`, `live=0`, выход 1, отсутствие L1 и одну строку `l2trans error:` с местом
(`unit_exprtext_sum_fault_growth1..3`, `_vector1`).

<a id="sprintf-past-buffer"></a>
### SPRINTF-PAST-BUFFER — 2026-10-05, Opus, FIXED 2026-10-05; запись за буфер транслятора

Транслятор писал `sprintf` без границы в буферы постоянного размера, и программа доходила до двух
таких мест:

- шаг счётчика `for:` пишется на уровень ниже тела цикла, и отступ тела форматировался в 64 байта на
  стеке (`l2_emit_stmts`, `l2_dind`). Примерно с девяти вложенных циклов он выходил за них: при двадцати
  L1 не разбирается (`source level decrease must be one step`), при сорока отступ шага — 324 пробела,
  на 261 байт за буфером;
- `sizeof(c.<имя>)` писал имя целиком в текст выражения, здесь — в глобальный `l2_tok` в 1024 байта:
  имя в 20000 байт молча переписывало 19 КБ глобалов транслятора. Атом с `c.` — слово типа
  (`l2_prim_type_word`), писала эта ветка.

Сборка транслятора с `-O2 -D_FORTIFY_SOURCE=2` останавливается на первом месте уже при десяти
вложенных циклах и падает на втором; на 1903 записанных трансляциях `opus_full_18` она даёт тот же
результат, что и обычная, и ничего не находит.

**Исправлено 2026-10-05.** Отступ шага — в памяти своего размера (`l2_text_room`); операнд `sizeof`,
который не помещается в текст выражения, — его отказ на месте `expression too long`, как у других
писателей этого текста (`l2_cat`; размер самого текста остаётся в FIXED-BLOCKS-AUDIT). Строка
`unit_for_nested_deep` (+`_walk`): прежний транслятор даёт неразбираемый L1
([§90 журнала](fable-continuation-20261003.md#sprintf-past-buffer)).

<a id="ref-field-value-read"></a>
### REF-FIELD-VALUE-READ — 2026-10-05, Opus, FIXED 2026-10-05; L1 не разбирался

Ссылочное поле, прочитанное значением в ссылочный локал, транслировалось в код, который не
разбирается:

```text
Node:
    int: value 0
    @: Node next
end: Node
a: merge Node
b: merge Node
a\next: b
@: Node q
q: a\next                          # было: l2_q2: (cast: (@: Lmx) (())  -- l1trans: unclosed parenthesized form
```

Ветка пути в операторе (путь, записываемый в объявленное own-поле) читала только числовые листья, а
для ссылочного писала то, что лежало в её буфере значения: `(`, пустую строку или неинициализированные
байты (gcc: `stray '\345' in program`). Найдено пробником цепочки Structure для глубины сборщика (K09).

**Исправлено 2026-10-05.** Ссылочный лист пути записывает общая запись: его чтение
(`l2_path_text_read`) и допуск, как она же делает преобразование числа другого типа
(`l2_path_store_general`). Строка `unit_ref_field_value_read` (+`_walk`); прежний транслятор — её
мутант: C не компилируется ([§89 журнала](fable-continuation-20261003.md#ref-field-value-read)).

<a id="duplicate-catch-long-name"></a>
### DUPLICATE-CATCH-LONG-NAME — 2026-10-05, Opus, FIXED 2026-10-05; транслятор падал

`l2_check_catch` писал слова `duplicate catch: <имя>` через `sprintf` в 160 байт без границы, а
длина имени `catch:` не проверяется. Две `catch:` одного имени в 300 байт в одном блоке роняли
транслятор: код 139, запись за 160 байт буфера на стеке. Имя в 150 байт уже писало восемь байт за
буфер, и трансляция шла дальше. Измерено пробником вне гейта транслятором `opus_full_17`
(`f2204ee7`):

```text
int: r 0
catch: <имя в 300 байт> ()
    r: 1
catch: <имя в 300 байт> ()
    r: 2
return: r                          # по норме отказ: duplicate catch: <имя целиком>
```

**Исправлено 2026-10-05.** Слова собираются в памяти своего размера (`l2_error_name`); так же
собраны слова `unhandled throw` из того же `sprintf` в 160 байт, хотя имя брошенного там — имя
объявленного броска, не длиннее 62 байт. Строка `unit_catch_duplicate_long_name_refused`; прежний
транслятор на ней падает
([§88 журнала](fable-continuation-20261003.md#fixed-counts)).

<a id="return-check-long-name"></a>
### RETURN-CHECK-LONG-NAME — 2026-10-05, Opus, FIXED 2026-10-05; был принят неверный результат без отказа

Статическая проверка кандидата по описанию модели (`l2_descriptor_implements`) копировала имя каждого
поля модели в 128 байт и более длинное пропускала. Метод, объявленный с результатом `Model`, возвращал
Structure без поля `Model` с именем в 146 байт:

```text
Model:
    int: <имя в 146 байт> 4
    int: v 1
end: Model
Near:
    int: v 1
end: Near
fn: give () Model
    n: merge Near
return: n                          # по норме отказ: implements is false in return value
```

Измерено транслятором `12ab4488` пробником вне гейта: трансляция проходит, при исполнении процесс
останавливается: `lmx: invariant: an admission by name was refused`, код 3. С коротким именем та же
программа отвергается при трансляции.

**Исправлено 2026-10-05.** Сравнивается имя поля любой длины (`l2_text_room`). Строка
`unit_return_long_field_other_refused` (имя в 600 байт). Мутант `desc128` возвращает прежнюю
границу: строка транслируется
([§74 журнала](fable-continuation-20261003.md#path-text-any-length)).

<a id="t7-actual-from-root"></a>
### T7-ACTUAL-FROM-ROOT — 2026-10-04, fable, FIXED 2026-10-04

Корень подаёт merge как фактическое callable-формала: `int: d (take: merge(y: 5; five))`. Узел merge
строится только нативным кодом, а тело корня обходится. Программа отвергалась словами
`incompatible entry signature`, хотя несовместимости нет. Теперь отказ назван пределом: `a merge
given as the actual of a callable formal by the root is not built yet`. Обязательный позитив,
красный: `unit_t7_actual_from_root` (по норме 5). Чинится вместе с обходимым построением узла merge
([§62 журнала](fable-continuation-20261003.md#merge-actual)).

**Уточнено 2026-10-04 по двенадцатому ответу Codex.** Здесь два обязательства, и оба закрываются до
G5 общим путём компиляции и диспетчеризации тела, без конструктора только для корня и без смены
смысла по месту. Первое — обходимое построение узла merge. Второе — нативное тело корня: Codex:
«L2 #call expressly says that every statically compiled executable body, including
the file root, has a native implementation, with no special interpreter-only root.» И: «Building the merge in the walker is needed for the portable route, but doing only
that does not discharge the native-root obligation.» Слова «тело корня
обходится» в этой записи и в комментарии транслятора описывают текущий долг, не разрешённое
различие корня. Измерено на `0a52fe7d` со снятым пределом: артефакт исполняет корень дважды,
нативно и через граф. Нативный корень останавливает процесс (`a callable merge could not be
built`): узел merge строится под `node` дающего метода, а у корня `node` пуст. Обходимый корень
даёт `walk error: UNSUPPORTED`: сохранённая машинная операция не исполняется обходом. Тот же
позитив должен пройти у корня и в методе, нативно и с настоящим обходом
([§63 журнала](fable-continuation-20261003.md#twelfth-reply)).

**Исправлено шагом четыре третьего среза.** Узел merge строит одна функция порождённого модуля,
`l2_t7_make_<место>`. Нативное тело вызывает её со своим вхождением; обходимое тело строит шаг,
запись которого называет примитивный вход над той же функцией, `l2_t7_construct_<место>`
(`l2_rw_t7_build`). Корень строит узел обоими своими телами, как метод, без конструктора только
для корня. Узел висит там же, где висел: в лексическом пространстве над исполняющим телом; у тела,
над которым ничего нет, этим пространством служит оно само. У корня это не выбирает чтения
открытого вопроса: лексический родитель модели, место merge и единица там — одна Structure. Строка
`unit_t7_actual_from_root` зелёная: артефакт исполняется нативно и через граф, лист корня несёт
нативное слово, нативные тела зовут конструктор, шаги графа называют его примитивный вход, машинная
операция для merge не сохраняется. Мутанты: примитивный вход не даёт узла — красная с обходом корня,
зелёная нативно; нет места для тела без пространства над ним — нативное тело корня останавливает
процесс; предел корня возвращён — отказ. Методы с callable-формалом под `--walk-methods` не
обходятся, это предел обхода потребителя. Тело, которое обходится всегда, — возвращаемое вложенное
определение — даёт merge фактическим в строке `unit_t7_actual_in_definition`
([§66 журнала](fable-continuation-20261003.md#merge-node-construction)).

<a id="t7-model-free-name"></a>
### T7-MODEL-FREE-NAME — 2026-10-04, fable, FIXED 2026-10-04

**Исправлено 2026-10-04.** Узел, который строит merge, несёт собственный полный контракт: формалы,
оставленные merge несвязанными, затем скрытые входы модели, по ячейке типа каждого, как в части
аргументов любого callable. Тело узла читает каждый вход на его месте в контракте узла, а не на месте
модели; связанный формал, достигнутый по своему месту среди входов модели, — поле узла, которое
держит его значение. Программа ниже даёт 15, под вызывающим с `other` 20 — 26
(`unit_t7_free_name`). Тем же исправлены ещё три отказа той же причины, найденные по дороге: merge,
оставляющий два формала несвязанными, единственный callable-результат единицы, останавливал процесс
так же (`unit_t7_two_formals`, теперь 215); модель, читающая ссылку (`unit_t7_reference_held`,
теперь 10); модель, вызывающая метод, который читает как свободные имена связанный и несвязанный
формалы, давала `walk error: INVALID` (`unit_t7_model_calls_reader`, теперь 1507). Все нативно и с
обходом методов ([§62 журнала](fable-continuation-20261003.md#merge-actual)). Ниже — запись, как она
стояла.

Узел, который строит `merge(y: k; add)`, не имеет места для скрытых входов модели. Если модель читает
свободное имя, удерживаемый вызов узла останавливает процесс:

```text
int: other 9
fn: add (int: y; int: x) int
    return: y + x + other
fn: wrap (int: k) fn: (int: x) int
    return: merge(y: k; add)
w: wrap 5
int: a (w: 1)          # lmx: invariant: a callable merge was called outside its header
```

Удерживаемый вызов подаёт скрытый вход модели после объявленного аргумента. Заголовок узла его не
содержит, а тело узла читает имя по позиции модели: ARG 2 при одном объявленном аргументе. По норме
15, а под вызывающим с `other` 20 — 26. Измерено нативно на `f3c46518` и на трансляторе §61 пробником
вне гейта; строка харнесса появится вместе с исправлением, в шаге «узел merge как фактическое»
([§61 журнала](fable-continuation-20261003.md#held-actual)).

<a id="held-actual-node-class"></a>
### HELD-ACTUAL-NODE-CLASS — 2026-10-04, fable по ответу Codex FABLE-CODEX-20261004-12, OPEN (блокер G5)

До одного callable-формала доходят узел определения, возвращённого методом, и callable другого
формирования: метод единицы или узел другого определения. Вызов через формал должен при исполнении
выбрать формирование по тому вхождению, которое формал держит. Метод единицы узнаётся сравнением
самого вхождения. У определения одного адреса нет: каждый возврат его метода строит новый узел. Вызов
отвергается на месте. Это предел реализации, не правило. Обязательные позитивы,
красные: `unit_held_actual_among_methods` (по норме 105, 10, 1 и 122101) и
`unit_held_actual_two_models` (105, 205, 60 и 60604). Где формирование одно, выбирать нечего и вызов
работает: две копии одного определения (`unit_held_actual_free_names`), определение и методы единицы с
одинаковыми входами (`unit_held_actual_alike`).

С 2026-10-04 то же относится к узлу, который строит merge, поданный как фактическое: и он строится
при исполнении и не является вхождением единицы. Замыкание потока записывает, доходит ли метод до
формала как такой узел (`l2_cfr_built`), и предел ставится по этой записи, а не по тому, что метод
— модель определения. Слова отказа: `a call through a callable formal that receives a callable
built at run time among callables formed differently is not built yet`. Третий обязательный
позитив, красный: `unit_callable_formal_unfollowed_actual` (по норме 10 и 5). Где формирование одно,
узел merge работает: `unit_t7_actual_alike`
([§62 журнала](fable-continuation-20261003.md#merge-actual)).

Измерено и не принято. Узел сегодня делит со своей моделью часть аргументов по адресу, и выбор класса
по этому адресу проходит оба позитива. Это отношение существует только потому, что узел — неполная
копия ([RETURNED-NODE-PARTIAL-COPY](#returned-node-partial-copy)). Codex: «Do not bless partial MAD construction as complete
copying, or preserve a wrong alias solely to tag model provenance. If the class witness survives the
correct existing representation, use it; if correcting the copy removes that relation, do not add a
tag/registry to recreate it or pretend the relation remains proved. Keep that route explicitly OPEN
until its actual physical contract route is implemented.»
Маршрут остаётся открытым, пока у узла нет собственного физического маршрута контракта
([§61 журнала](fable-continuation-20261003.md#held-actual)).

<a id="returned-node-partial-copy"></a>
### RETURNED-NODE-PARTIAL-COPY — 2026-10-04, fable по ответу Codex FABLE-CODEX-20261004-12, OPEN (блокер G5)

Узел, который возврат метода строит для возвращаемого вложенного определения (`l2_mad_emit`), —
неполная копия вхождения модели. Слоты 0 и 1, части аргументов и результата, записаны адресом модели.
Число получает свежую ячейку своего типа. Всё остальное, шаги и вложенные тела, остаётся адресом
модели (`lmx_walk_cell_copy`: число копируется, нечисловое возвращается как есть). По норме
([L2 §13](../docs/L2_spec_en.md#copy-merge), [L3 §20](../docs/LMX_semantics.en.md#composition)) копия
покрывает всё используемое замыкание с переписанными ссылками и `parent`; по исходному адресу
удерживаются только переиспользуемая нативная реализация и допущенная ветвь
`independent: const: immutable`. Codex: «Sharing an ordinary graph signature/step merely because this
constructor already does so is not a new retention exception.»

Программа, которая через разделяемые части даёт неверное значение, не известна: числовое состояние
копий независимо (`unit_held_actual_node`: каждая копия ведёт свой счёт). Запись — обязательство
представления, а не измеренный отказ. Проверить: `parent` разделяемых шагов, хранение формалов и
умолчаний, ссылки операндов; свидетель — независимое изменение нечислового состояния двух копий. Шаг
§61 не добавляет ничего, что опиралось бы на разделяемую часть
([§61 журнала](fable-continuation-20261003.md#held-actual)).

<a id="held-callable-to-callable-formal"></a>
### HELD-CALLABLE-TO-CALLABLE-FORMAL — 2026-10-04, fable по ответу Codex FABLE-CODEX-20261004-12, FIXED для одного формирования 2026-10-04

**Исправлено 2026-10-04 для одного формирования.** Удерживаемое определение, поданное
callable-формалу, допускается по сигнатуре своей модели и передаётся самим узлом, без исполнения при
приёме: программа ниже даёт 200 (`unit_held_call_to_callable_formal`). Свободные имена определения
формируются там, где формал вызывается, как у любого callable: каждая копия читает своё, значение
вызывающего побеждает (`unit_held_actual_free_names`, `unit_held_actual_local`,
`unit_held_actual_alike`). Формал держит сам узел: явное чтение `node` даёт значение копии, запись в
узел остаётся в копии (`unit_held_actual_node`). Отказ по несовместимой сигнатуре остаётся
(`unit_held_actual_signature_refused`). Не построено: узел определения среди callable другого
формирования у одного формала ([HELD-ACTUAL-NODE-CLASS](#held-actual-node-class)). Только нативно: с
обходом методов метод с callable-формалом остаётся вне обходимого подмножества
([§61 журнала](fable-continuation-20261003.md#held-actual)). Ниже — запись, как она стояла.

Удерживаемый callable, поданный явно объявленному callable-формалу, отвергается:

```text
fn: f0 () int
    return: 1
end: f0
fn: run (f0: q) int
    return: q() + q()
end: run
p0: make0 100          # заголовок () int
int: r run(p0)         # отказ: incompatible entry signature
```

По норме (`#callables`) явно объявленный callable-формал получает ссылку на вхождение callable и не
исполняет его при приёме. Codex: «An explicitly declared callable formal receives the entire actual
callable occurrence by reference, without executing it on reception. Admission must use its real
accepted interface and the Consumer's use, with the full input/result/exit contract; then execution
inside run invokes that actual occurrence normally.» Настоящие отказы по несовместимой сигнатуре
остаются; допуск не ослабляется, переименование заголовок/фактическое имя не возвращается.
Обязательный позитив, красный: `unit_held_call_to_callable_formal`
([§52 журнала](fable-continuation-20261003.md#result-receipt)).

<a id="held-forward-lookup"></a>
### HELD-FORWARD-LOOKUP — 2026-10-04, fable по ответам Codex FABLE-CODEX-20261004-09 и -10, FIXED в sandbox (не выпущено)

Исправлено удалением: поиска по последнему объявлению на входе (`l2_mad_held`) больше нет. Заголовок,
не выбирающий строки на месте, не называет удерживаемого callable: в методе выше всех объявлений
имени это неизвестная голова. В позиции значения вызов отвергается (`unknown method`); операторы
`h2(5 6)` и `h2: 7 8` — одна форма в двух записях, каждая определяет Structure метода и ничего не
вызывает. Свидетели — `unit_held_call_above_refused`, `unit_held_call_above_unknown_head`; строка
`unit_held_call_above` удалена вместе с поиском
([§49 журнала](fable-continuation-20261003.md#no-forward-lookup)). Ниже — запись, как она стояла.

Метод, стоящий выше всех объявлений имени, не выбирает строки: имя для него свободное. Удерживаемый
callable для такого метода по-прежнему находился по последнему объявлению имени на входе
(`l2_mad_held`). Это поиск одних удерживаемых callable рядом с обычным выбором строки, а не правило
видимости: карта ядра, §13.3, делает допустимым лексическим запасным путём объявление родителя,
стоящее перед определением вызываемого, и о стоящем после ничего не говорит. Оставлено, потому что
так отвечали все прежние трансляторы и по этому пути работают программы; их держит
`unit_held_call_above`. Форму `h2: 5 6` под таким заголовком не держит ни одна строка: это открытый
вопрос автора о неизвестной голове. Поиск уходит, когда решена роль заголовка вызова — свободного
имени.

<a id="held-store-factory-actuals-positional"></a>
### HELD-STORE-FACTORY-ACTUALS-POSITIONAL — 2026-10-04, fable, ЗАКРЫТ решением автора 2026-10-05; работа — FACTORY-RESULT-RECEIVER

У записи callable merge нет принятой записи именованных фактических фабрики. Запись — короткая форма
T6, `h2: make2 100` (`steps/callable-merge-t6.md`): хвост начинается атомом метода, фактические
позиционные.

- `h2: make2(n: 100)` — не запись, и по норме не должна ею быть: по решению автора Q58 (2026-10-01)
  отсутствующая голова с хвостом из одного известного вызова объявляет именованную Structure, которая
  **удерживает** вызов; он исполняется, когда исполняется Structure. Это держат строки
  `unit_q58_batch_retained` и `unit_named_struct_call_body_retained` («one P0 shape, one
  resolution»). Измерено: после `h2: make2(n: 100)` фабрика не исполнена, голое `h2` исполняет её
  один раз, с привязанным именованным фактическим. Чтение такого хвоста как значения вызова переводит
  эти строки и `unit_named_actual_structure_body` из OK в отказ.
- `h2: make2 n: 100` (именующий Frame в хвосте короткой формы) и `h2: make2 (n: 100)` отвергаются,
  `unknown method` у `n`.

Codex назвал записью с именованными фактическими именно `h2: make2(n: 100)`; это расходится с Q58.
Вопрос, какая запись их несёт, возвращён Codex с этими якорями. Ничего не реализовано
([§49 журнала](fable-continuation-20261003.md#no-forward-lookup)).

Ответ Codex FABLE-CODEX-20261004-11: запись `h2: make2(n: 100)` отозвана, Q58 не отменяется. Не
установлено и значение самой короткой записи `add5: makeAdder 5`: вопрос автору задан и записан в
[`LMX_blog/q/held-factory-initialization-versus-body-definition.md`](../LMX_blog/q/held-factory-initialization-versus-body-definition.md).
До ответа ни одна запись именованных фактических не реализуется
([§50 журнала](fable-continuation-20261003.md#result-receipt-open)).

**Решение автора 2026-10-05.** Результат фабрики принимается явным приёмником `@:`, и короткая запись
T6 его больше не связывает. Именованные фактические фабрики — обычные именованные фактические вызова:
`@: h2 make2(n: 100)`. Вопрос этой записи снят; что строить —
[FACTORY-RESULT-RECEIVER](#factory-result-receiver).

<a id="held-header-names-not-actual-interface"></a>
### HELD-HEADER-NAMES-NOT-ACTUAL-INTERFACE — 2026-10-04, fable по ответу Codex FABLE-CODEX-20261004-08, OPEN

Конструктор объявляет заголовок результата с одними именами формалов, а возвращает определение с
другими:

```text
fn: make3 (int: n) fn: (int: p; int: q) int
    fn: f3 (int: x; int: y) int
        return: n + x * 10 + y
    return: f3
h3: make3 200
h3(q: 2; p: 1)      # сейчас: привязано по именам заголовка, доходит до f3 по координате, 212
h3(y: 2; x: 1)      # сейчас: отказ, unknown method
h3(1 2)             # позиционно транслируется
```

Реализация берёт имена для привязки из объявленного заголовка. Норма этого не утверждает:
именованные фактические действительного использования должен принимать действительный интерфейс
кандидата с его каноническими именами, сигнатура-образец этот интерфейс не заменяет
(`#three-argument-implements`); объявленный тип результата проверяет получившийся callable и не
становится третьим операндом композиции (`#composition`, возвращаемые вложенные методы). Правила,
которое переводит `p`, `q` в `x`, `y`, не показано. Либо именованное использование по `p` и `q` не
должно допускаться интерфейсом `f3`, либо существует явный механизм, формирующий интерфейс с
именами заголовка, и его нужно показать. Не решено. Репродьюсеры — две помеченные временные пробы
текущего поведения, не позитив и не отказ по норме:
`unit_named_actual_held_header_names_limit_probe`,
`unit_named_actual_held_definition_names_limit_probe`. Пока расхождение открыто, G5 не закрывается.

<a id="held-call-ignores-site-binding"></a>
### HELD-CALL-IGNORES-SITE-BINDING — 2026-10-04, fable, FIXED в sandbox (не выпущено)

Локал, который не callable и назван как удерживаемый callable корня, его не заслоняет:

```text
h2: make2 100
fn: use () int
    int: h2 5
    return: h2(1 2)      # принято; сгенерированный C не компилируется: 'l2_q2_from' undeclared
```

Метод, заслонённый таким локалом, отвергается: `unknown method` у вызова. Удерживаемый callable
искался по имени среди собственных строк корня (`l2_mad_held`), без привязки места.

Исправлено: `l2_call_head_held(mi, head)` — формал, другая собственная строка, слот или машинный
локал с этим именем заслоняют удерживаемый callable, как заслоняют метод. Привязка, проверка, обе
эмиссии и граф спрашивают его. Срез §46 сделал хуже: привязка стала привязывать и запись в такой
локал как вызов (`h2 has no argument y`); это исправлено здесь же. Свидетели —
`unit_held_call_local_shadow_refused`, `unit_held_call_shadow`
([§47 журнала](fable-continuation-20261003.md#site-role)).

<a id="store-unchecked-under-method-name"></a>
### STORE-UNCHECKED-UNDER-METHOD-NAME — 2026-10-04, fable, FIXED в sandbox (не выпущено)

Запись в числовой формал или локал не проверяется, если в юните есть метод с тем же именем:

```text
fn: p (int: a) int ...
fn: stored (int: p; int: x) int
    p: "text"            # принято
```

Без метода `p` в юните та же запись отвергается: 2:5 «assignment value has incompatible type».
Классификатор операторов `l2_is_asgn` не считает присваиванием оператор, чей заголовок совпадает с
именем метода юнита, и проверка значения пропускалась. Это вторая сторона
[CALLABLE-FORMAL-STATEMENT-STORE](#callable-formal-statement-store): выбор между вызовом и записью
делался по глобальному имени метода, а не по привязке места.

Исправлено: `l2_is_asgn(stmt, mi)` спрашивает роль заголовка на месте (`l2_call_head_method`).
Свидетели — `unit_store_method_name_refused`, `unit_store_local_method_name_refused`
([§47 журнала](fable-continuation-20261003.md#site-role)).

<a id="named-actual-binding-reach"></a>
### NAMED-ACTUAL-BINDING-REACH — 2026-10-04, fable, FIXED в sandbox (не выпущено)

Привязка именованных фактических не доходила до двух мест, и валидная программа отказывалась
словами «unknown method»:

```text
row[g(b: 1U; a: 0U)]: 5      # индекс в заголовке записи: заголовок разбирается отдельно
h2(y: 2; x: 1)               # h2 — удерживаемый callable с заголовком (int: x; int: y)
```

**Индекс заголовка — исправлено.** Выражение заголовка — отдельный разобранный документ, который
`l2_head_expression` хранит при операторе; `l2_bind_calls` его не обходил. Теперь привязка обходит
это дерево тем же обходом, что и тело. Позитив `unit_named_actual_head_index` переписан: прежний
вызываемый `a + b` давал один результат при привязке по имени и по месту; теперь `a * 2 + b`, семь
случаев, нативно и с обходом, и два отказа на своих местах в заголовке.

**Удерживаемый callable — исправлено.** Заголовок вызова разрешается в собственное поле, а не в
метод, и `l2_call_head_method` возвращает -1; формалы у такого вызова есть — это формалы заголовка
объявленного callable-типа. Привязка теперь берёт их имена оттуда и привязывает вызов так же, как
вызов метода; нативный код и удержанный граф сохраняют порядок записи. Позитив
`unit_named_actual_held` переписан (шесть случаев, нативно и с обходом), три отказа — словами
вызова метода ([§46 журнала](fable-continuation-20261003.md#held-named-binding)). Случай разных
имён у заголовка и определения вынесен в открытое расхождение
[HELD-HEADER-NAMES-NOT-ACTUAL-INTERFACE](#held-header-names-not-actual-interface).

<a id="declaration-cache-outlives-role"></a>
### DECLARATION-CACHE-OUTLIVES-ROLE — 2026-10-04, fable по ответу Codex FABLE-CODEX-20261004-05, FIXED в sandbox (не выпущено)

Ответ читателя объявлений `l2_declaration` зависел от его кэша. Сборщик собственных строк работает
до привязки и читает операторы по форме, через вложенный кадр; для `@: f(x b: 1)` в кэше оставалось
прочтение «указатель на f с именем x». Привязка затем устанавливала, что `f(x b: 1)` — вызов, но
проверка этой роли стояла после кэша и смотрела только на сам кадр. Программа отказывалась в обоих
случаях, но разными словами: из кэша — «unknown type» у `f`, без кэша — «unsupported body» у
оператора. На строках гейта вывод от кэша не зависел; зависело число аллокаций на двух строках.

Исправлено: роль спрашивается раньше кэша, у самого кадра и у кадра, через который идёт чтение
(`l2_declaration_meets_call`). Свидетель — `unit_named_actual_address_statement_refused`; мутанты
«кэш раньше роли» и «роль только у самого кадра» дают прежний отказ. Замер и контроль с выключенным
кэшем — [§45 журнала](fable-continuation-20261003.md#head-binding-reach).

<a id="walk-throw-payload-nested-actual"></a>
### WALK-THROW-PAYLOAD-NESTED-ACTUAL — 2026-10-04, fable, FIXED в sandbox (не выпущено)

При обходе методов (`--walk-methods`) бросающий вызов, стоящий фактическим другого вызова, терял
payload:

```text
fn: thrower () int
    throws: Oops
    return: f(boom(3 3) 0)      # boom бросает Oops(3)
```

Обработчик `catch: Oops (int: v)` в вызывающем получал пустой payload, и ядро останавливалось на
инварианте `lmx: invariant: catch payload` (выход 3). Тот же бросок, записанный
`return: boom(3 3)` или через локал `int: t boom(3 3)`, до обработчика доходил; нативно работали
все три формы. Именованные фактические ни при чём: воспроизводилось на позиционном вызове.

Причина в ядре, транслятор не менялся. `lmx_walk_call` и `lmx_walk_prim` вычисляют операнды, затем
запускают вызываемого, и любой бросок после этого считали броском вызываемого: payload кадра
заменялся результатом операции, а к номеру применялись её строки catch. Бросок, поднятый при
вычислении операнда, вызываемому не принадлежит: вызываемый не запускался, результат операции
пуст, а её строки записаны в номерах бросков вызываемого, тогда как номер от операнда уже переведён
в номера вызывающего. Исправлено: операция берёт payload и применяет свои строки только если дошла
до вызываемого; бросок операнда уходит с тем же номером, посадкой и payload. Остальные операнды и
вызываемый не выполнялись и раньше.

Свидетели: девять новых проверок самотеста ядра `lmx_walk_catch_selftest` (всего 34) и девять
случаев фикстуры `unit_throw_nested_actual`, нативно и с обходом: прямой возврат и локал как
контроли, фактический, фактический фактического, именованный в именованном, порядок побочных
эффектов, вызов удерживаемого callable, вызываемый со своим именем броска в блоке с двумя
обработчиками. Шесть мутантов ядра, результаты и гейты —
[§44 журнала](fable-continuation-20261003.md#operand-throw).

<a id="prefix-minus-not-an-operand"></a>
### PREFIX-MINUS-NOT-AN-OPERAND — 2026-10-04, fable по ответу Codex FABLE-CODEX-20261004-02, FIXED в sandbox (не выпущено)

Префиксный минус не распознаётся как начало операнда:

```text
fn: f (int: a; int: b) int
    return: a - b
fn: h () int
    int: t 0
    t: f(a: 8; b: - 1)
    return: t
```

Производитель графа отказывает: `root operation not walkable yet: this expression`, atom `-`.
`l2_value_spans` и `l2_operand_run` начинают операнд только с `@` и `\`; native-путь передаёт
текст в C как есть. Грамматика (раздел об операторах) перечисляет префиксы `+` и `-`, запись
слитно с операндом — стиль, не граница P0. Решение Codex: удержанный унарный оператор с одним
исходным операндом, общее распознавание для выражений, возвратов и аргументов, без `SUB(LIT 0, x)`
в графе ([журнал](fable-continuation-20261003.md#written-body-and-prefix-ruling)). Исправлено:
знак `-` или `+` в начале операнда — префикс; в графе он стоит как `NEG [операнд]` или
`POS [операнд]`, тип результата — продвинутый по правилам C тип операнда. Свидетели
`unit_named_actual_whole`, `unit_prefix_sign` (оба с обходимыми двойниками), четыре отказа и
самотест ядра `lmx_walk_prefix_sign_selftest`
([журнал](fable-continuation-20261003.md#prefix-sign)).

<a id="p0-operator-before-call-head"></a>
### P0-OPERATOR-BEFORE-CALL-HEAD — 2026-10-04, fable, OPEN

Оператор, записанный слитно с головой вызова, не отделяется парсером P0:

```text
int: q -mark(3)
int: p 2+mark(3)
```

P0 даёт один Frame с головой `-mark` и `2+mark`; транслятор отвечает `unknown method`. С пробелом
(`- mark(3)`, `2 + mark(3)`) обе записи проходят. Грамматика: P0 разбивает слитные записи вроде
`a+b*c==d` на поля и операторы; слитность префикса с операндом — стиль. Для головы вызова
разбиение не выполняется. Это пробел парсера (четыре копии, отдельный порядок изменения), не
транслятора выражений; найдено при проверке префиксного знака.

<a id="path-from-method-slot-temp"></a>
### PATH-FROM-METHOD-SLOT-TEMP — 2026-10-04, fable, FIXED в sandbox (не выпущено)

Путь с корнем в имени другого метода, идущий через его собственную типизированную ссылку, принятую
по имени (`keep\held\value`), давал C, который не компилируется: чтение поля берёт слот из записи
значения через `l2_dslot`, а объявлялась эта переменная только в методе, у которого есть своё
принятое по имени место. Найдено пробой при проверке контракта использования; та же ошибка есть на
закоммиченном трансляторе `f76b7f99`.

Исправлено: переменная объявляется в каждом методе программы, в которой есть хоть одно такое место.
Свидетель `unit_recv_use_path_from_method` (чтение обоих полей из другого метода, natively и с
обходом методов), мутант `fable_use_mut_nodslot` (gcc падает)
([журнал](fable-continuation-20261003.md#receiving-use-coverage)).

<a id="receiving-use-full-receiver"></a>
### RECEIVING-USE-FULL-RECEIVER — 2026-10-03, fable по ответу Codex FABLE-CODEX-20261003-01, ЧАСТИЧНО FIXED в sandbox (не выпущено)

**Состояние на 2026-10-04.** Механизм построен: ядро принимает покрытие текущей принимающей
инструкции (`lmx_implements_receiving_use`, `LmxImplUses`), обходчик несёт его в ячейках `ADMIT_AS`,
транслятор выдаёт его для собственной типизированной ссылки обычного метода. Три строки ниже
приведены в соответствие: `unit_bind_method_thin_other` зелёная, две ложно-зелёные мигрированы в
положительные `unit_ref_rebind_other_thin` и `unit_struct_return_ref_admit_thin`. OPEN остаётся
граница анализа, все её пункты перечислены в
[журнале](fable-continuation-20261003.md#receiving-use-coverage): ссылки корня и именованной
Structure, использование ссылки целиком (аргумент, возврат, копия, адрес), определения внутри
метода, формал, записи в поле и элемент, кандидат неизвестной раскладки, различие «удерживается» и
«вызывается» для поля-вызываемого. Во всех этих случаях покрытие неизвестно и приём полный.
Полный приём там, где покрытие не составлено, — ограничение реализации, а не нормативный отказ:
текст сгенерированного кода, который держит сегодняшний консервативный режим, проверяют только
помеченные пробы `..._limit_probe`
([журнал](fable-continuation-20261003.md#receiving-use-follow-up)).

**Дополнение 2026-10-04, срез композиции.** Из границы закрыты два пункта. Ссылка, переданная
целиком фактическим аргументом обычному методу, получает покрытие из того, что вызываемый читает
через свой формал; чтения составляются тем же обходом, цепочка передач составляется дальше.
Определение внутри метода, которое программа не вызывает и не возвращает, не считается Consumer'ом.
Оба бывших красных позитива (`unit_recv_use_nested_dormant`, `unit_recv_use_passed_thin`) зелёные.
Статический поток типов на месте с известным покрытием отсекает кандидата по полям этого покрытия,
а не пропускает всех: иначе отказ, пойманный обработчиком у объявления, давал ложный статический
отказ у вызова ниже. Остальные пункты границы открыты, как и раньше; определение внутри метода,
которое вызывается или возвращается, по-прежнему даёт неизвестное покрытие
([журнал](fable-continuation-20261003.md#coverage-composed)).

Исходная запись:

Явное типизированное объявление или запись ссылки (`@: Model b o`; запись в `@: Model r`) сейчас
допускает кандидата по всей форме модели: в native эмитируется
`lmx_implements_receiver_view(…, candidate, Model, Model, …)`. По норме допуск относителен
Consumer'у: проверяются используемые пути ссылки в её видимом теле
([implements](../docs/LMX_semantics.ru.md#three-argument-implements)); неиспользуемое поле у
кандидата не требуется, читаемое — требуется, неизвестное покрытие не считается пустым.
`CORE_L2_L3_v2.md` §9.3 описывает full-receiver как реализацию, не норму.

Следствия записаны в [журнале продолжения](fable-continuation-20261003.md#receiving-use-contract):
`unit_bind_method_thin_other` — обязательный положительный (сейчас красный на явной форме);
`unit_ref_rebind_other_refused` и `unit_struct_return_ref_admit_refused` не читают полей принятой
ссылки и зелены как отказы ложно — мигрировать в положительные вместе с механизмом;
`unit_ref_formal_rebind_other_refused` и `unit_formal_spelling_rebind_other_refused` читают
`v\value` и остаются отказами. Чинить общим контрактом использования принимающего места
(пустое доказанное использование / конкретные пути / неизвестное покрытие) в native и walker,
без ветки по методу, корню, написанию `@` или имени модели.

<a id="receive-model-root-step-dropped"></a>
### RECEIVE-MODEL-ROOT-STEP-DROPPED — 2026-10-03, fable, FIXED в sandbox (не выпущено)

`receiveMessage: m T` в корне единицы отсутствовал в сохранённом графе. Синтезированная модель
письма `{sender; payload: T}` — Structure уровня единицы, и её записанное место — оператор
приёма, первым назвавший модель. Список операторов корня (`l2_rw_stmts`,
`l2_source_unit_declaration`) принимал этот оператор за определение модели: экземпляр модели
ставился в исходного ребёнка оператора, шаг не строился. Нативный корень исполнялся верно;
интерпретатор над тем же корнем читал `m`, которому ничего не присвоено. На зафиксированном
трансляторе `6eb0d4fe` корневая форма переводилась без шага и без диагностики (проба: в L1
нет `lmx_walk_mail_take`, модель стоит в ребёнке 1 единицы); строки харнесса для корневой
формы не было, а комментарий харнесса хранил отказ, измеренный 2026-09-25.

Минимальная программа: `MainLetter: (char: []: []: mainArgs)`, `receiveMessage: m MainLetter`,
`length(m\payload\mainArgs)` в корне — `lmx: walk error: INVALID`, выход 3, при обходе корня.
Пробы короче (`m = 0`, `m\sender = 0`) проходили случайно: читали Structure, оказавшуюся в том
ребёнке.

Исправлено: синтезированная модель письма не является определением в исходнике
(`l2_ns_synthesized`); оператор сохраняет своего ребёнка и шаг, экземпляр модели стоит в хвосте
единицы, как уже стоял для приёма в методе. Свидетель `unit_receive_letter_model_root`, мутант
`fable_recv_mut_source` ([журнал](fable-continuation-20261003.md#receive-model)).
