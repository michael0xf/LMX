# Methodology for the additional LMX comparisons

Edition: 23 November 2026. This revision is based on the uploaded `spec.tar.gz`.

## Comparison unit

Each entry defines a shared concrete scenario, expected observations and the responsibility boundaries of its complete listings. Functional clients publish both procedural and functional LMX forms; a shared library implementation remains one separate body. LMX is compared with two representative languages selected for that group. All 85 supplied IDs remain; additions use 86–90. A short architectural example illustrates dependencies or a protocol participant rather than a complete deployment. Closely related patterns retain separate entries and distinct responsibilities.

## Scope

- **core:** the scenario algorithm, with stated inputs and dependencies; not necessarily a standalone program.
- **protocol:** a handler or protocol participant with explicit host, scheduling, database, queue, codec or deployment contracts.
- **executable:** intended standalone scope in the stated profile; this does not itself claim an execution test.

Ports must state inputs, outputs and effects. A compareAndSet port is one atomic UPDATE, not separate read/check/write calls. The storage engine implements the stated transaction, while the example determines the operations it covers. Using an existing library and implementing that library have different scope; this is documented without inflating the other language’s code.

## LMX model

The current uploaded specifications govern. An executable method is an ordinary Structure whose DATA is its actual parent. `Name :: DATA` declares a named signature; `to` constructs its type-token counterpart. Locals do not publish back into the source graph. Explicit paths select graph cells, and blank lines close syntax blocks to the current document root. A declaration actual is an ordinary DATA Structure and is not executed or mapped by its internal name during transfer.

copy/merge emit fields. A group collects a distinct container and does not become the copied method’s lexical owner. Persistent method state uses the actual owner. Ordinary single-Structure W/E selection applies; explicit named supply passes a whole value where required.

## Message and HTTP

Concurrent LMX cases use executable Messages with separate arenas and serial execution lanes. A name ending in Message does not launch a thread: the host profile explicitly creates it and supplies its dependencies. A letter does not automatically become a Thread.

The existing HTTP profile includes endpoint plus route, application/lmx, decoding and admission, receiver execution, and synchronous replies or asynchronous replyTo/correlation. Admission is not application success. See MESSAGE_HTTP_PROFILE.md for the examples’ host boundary.

Serial ownership does not automatically provide transaction rollback, duplicate suppression, distributed consensus or parallel reads. An owner-message implementation may satisfy the application observation of a shared-memory pattern through a different access model. Message-local data is not OS-thread-local storage when the Message migrates between workers at turn boundaries.

## Metrics

The package has 100 client contracts with two complete LMX styles: 96 scenarios in the four examples suites and clients 082–085. Each style is counted independently; a documented same_minimal_form has one source and Markdown block with two equal metric records.

patterns.json is the authoritative editable source for each added group; examples.json or comparison_index.json serves the individual suites. lmx_variants stores both styles, while the legacy lmx field is a functional compatibility mirror. Markdown, separate source files, CSV, XLSX and PDF derive from it. Non-whitespace characters count Unicode characters for which Python str.isspace() is false, including comments and excluding whitespace even inside string literals. Nonblank lines count lines with nonempty strip(). The shown declarations, imports and helper functions are included. External fixtures and hosts are excluded. A client excludes the supplied component; its adjacent implementation case includes the complete shown component code.

Excel’s ratio is LMX characters divided by control-listing characters. Greater than one means a longer LMX listing. It does not measure runtime, engineering quality or a full production system. Cross-group language rankings are not aggregated. Run `python tools/recount_patterns.py` to verify IDs, language coverage, listing identity and counts. Published CSV/XLSX/PDF are edition snapshots; Excel totals and ratios recalculate when their numeric inputs change.

## Sources and validation

Primary sources substantiate pattern definitions and language/library contracts. SOURCE_INDEX.md lists them; each case cites its own sources. Examples are authored for the shared scenarios, with the supplied H03 technique identified in currying. Counts concern these listings, not the cited websites.

No LMX runtime was supplied or executed. VALIDATION.md records actual control-language and artifact checks. Expected observations remain acceptance criteria unless a separate execution check states otherwise. Historical receipts in the original GoF collection retain their original scope.

## Library use and implementation

All original 90 pattern IDs remain. Additional IDs above 90 identify independent implementations of corresponding core/library operations, not new pattern claims. Guides and tables place each implementation beside its primary client; one component may serve several clients.

The same boundary applies in all three languages. LMX clients use direct current-core functions. Control-language clients use the actual standard or explicitly named established library, or their native language mechanism. They do not import our educational implementation from the adjacent comparison. All application data, stages, predicates, settings and observable behavior remain in the client. Implementations stay available as separate LMX/control-language comparisons with a complete stated contract, including errors and asynchronous ownership when relevant. A smaller client is not a claim that client plus implementation is smaller. Excel keeps usage and implementation totals separate.

The [common core-function inventory](../CORE_FUNCTIONS.md) connects public lowerCamelCase names, signatures, algorithm sources and integration obligations. Message-based algorithms use the existing transport, including HTTP, rather than a second scheduler. A synchronous helper may need no asynchronous extension when the whole owning method is already executed through `post`; that boundary is stated explicitly and does not turn timeout into cancellation.

The required procedural and functional forms both retain their complete code even when one is longer. Additional material outside that pair retains full code when it demonstrates a different approach or contract; one-line spelling differences are described in notes. Removed duplicate files are recorded in the Fable change manifest against the exact uploaded baseline. Their removal does not remove a pattern, a scenario or a language from the comparison.

LIBRARY_COMPONENTS.md lists the components. OPERAND_LIBRARY_REVIEW.md records decisions for all 90 original cases. OPERAND_USAGE_PROFILE.md documents the supplied header, prepared callable values, priorities and explicit arity/iteration contracts.

## Full error contracts and minimum formatting

Every declaration, helper, handler, failure name and complete `copy(target\throws)` reference counts. The copied contract belongs to the selected method or an explicitly stated finite union of applicable branches. Throws is not shortened for statistics. PDF/XLSX mark every tied minimum full count in a comparable row with green text and an underline; incomplete analogies receive no winner. Shared implementation bodies are counted once, independently of the two client styles.

## Root startup and ordinary scenario calls

Program startup always starts **R0**, an ordinary L3 Thread beneath the stub parent, without DATA or user actuals. Absence of DATA skips only input reception; local variables, ordinary calls, dispatch, and exits remain available. A named scenario is called normally by the already running root or a handler and never replaces root startup.

Each fragment states its receiving context and ordinary scenario call. A DATA description obtains that role only through an existing receiving operation's contract; it does not turn root CODE into DATA or establish a DATA-load/Main selection profile. The stub parent may send its own values to the running root in an ordinary message; internal Thread launch parameters are not user actuals. See [root startup](../LMX_semantics.en.md#root-entry).
