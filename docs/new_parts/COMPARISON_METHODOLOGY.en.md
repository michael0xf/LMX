# Methodology for the additional LMX comparisons

Edition: 21 November 2026.

## Comparison unit

Each entry defines a shared concrete scenario, expected observations, three listings and their responsibility boundaries. LMX is compared with two representative languages selected for that group. All 85 supplied IDs remain; additions use 86–90. A short architectural example illustrates dependencies or a protocol participant rather than a complete deployment. Closely related patterns retain separate entries and distinct responsibilities.

## Scope

- **core:** the scenario algorithm, with stated inputs and dependencies; not necessarily a standalone program.
- **protocol:** a handler or protocol participant with explicit host, scheduling, database, queue, codec or deployment contracts.
- **executable:** intended standalone scope in the stated profile; this does not itself claim an execution test.

Ports must state inputs, outputs and effects. A compareAndSet port is one atomic UPDATE, not separate read/check/write calls. The storage engine implements the stated transaction, while the example determines the operations it covers. Using an existing library and implementing that library have different scope; this is documented without inflating the other language’s code.

## LMX model

The current newdocs packet and the author’s 21 November clarification govern. An executable method is an ordinary Structure whose DATA is its actual parent. fn describes a signature. Locals do not publish back into the source graph. Explicit paths select graph cells, and blank lines close syntax blocks to the current document root.

copy/merge emit fields. A group collects a distinct container and does not become the copied method’s lexical owner. Persistent method state uses the actual owner. Ordinary single-Structure W/E selection applies; explicit named supply passes a whole value where required.

## Message and HTTP

Concurrent LMX cases use executable Messages with separate arenas and serial execution lanes. A name ending in Message does not launch a thread: the host profile explicitly creates it and supplies its dependencies. A letter does not automatically become a Thread.

The existing HTTP profile includes endpoint plus route, application/lmx, decoding and admission, receiver execution, and synchronous replies or asynchronous replyTo/correlation. Admission is not application success. See MESSAGE_HTTP_PROFILE.md for the examples’ host boundary.

Serial ownership does not automatically provide transaction rollback, duplicate suppression, distributed consensus or parallel reads. An owner-message implementation may satisfy the application observation of a shared-memory pattern through a different access model. Message-local data is not OS-thread-local storage when the Message migrates between workers at turn boundaries.

## Metrics

patterns.json is the authoritative editable source for each added group. Markdown, separate source files, CSV, XLSX and PDF derive from it. Non-whitespace characters count Unicode characters for which Python str.isspace() is false, including comments and excluding whitespace even inside string literals. Nonblank lines count lines with nonempty strip(). The shown declarations, imports and helper functions are included. External fixtures and hosts are excluded. A client excludes the supplied component; its adjacent implementation case includes the complete shown component code.

Excel’s ratio is LMX characters divided by control-listing characters. Greater than one means a longer LMX listing. It does not measure runtime, engineering quality or a full production system. Cross-group language rankings are not aggregated. Run `python tools/recount_patterns.py` to verify IDs, language coverage, listing identity and counts. Published CSV/XLSX/PDF are edition snapshots; Excel totals and ratios recalculate when their numeric inputs change.

## Sources and validation

Primary sources substantiate pattern definitions and language/library contracts. SOURCE_INDEX.md lists them; each case cites its own sources. Examples are authored for the shared scenarios, with the supplied H03 technique identified in currying. Counts concern these listings, not the cited websites.

No LMX runtime was supplied or executed. VALIDATION.md records actual control-language and artifact checks. Expected observations remain acceptance criteria unless a separate execution check states otherwise. Historical receipts in the original GoF collection retain their original scope.

## Library use and implementation

All original 90 pattern IDs remain. Additional IDs above 90 identify implementations of imported components, not new pattern claims. Guides and tables place each implementation beside its primary client; one component may serve several clients.

The same boundary applies in all three languages. A client receives the ready library but retains application data, stages, predicates, settings and observable behavior. The complete library implementation is counted in the adjacent case. A smaller client is not a claim that the client plus library is smaller. Excel keeps main-example and library-implementation totals separate.

LIBRARY_COMPONENTS.md lists the components. OPERAND_LIBRARY_REVIEW.md records decisions for all 90 original cases. OPERAND_USAGE_PROFILE.md documents the supplied header, prepared callable values, priorities and explicit arity/iteration contracts.
