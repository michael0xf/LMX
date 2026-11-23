# LMX: Domain model and persistence

Python contributes compact functions, dataclasses and explicit adapters; C# contributes records, interfaces and conventional application persistence boundaries. LMX is compared without forcing class hierarchies.

All original patterns 16–34 remain separate. Each triplet shows the same bounded task. External database and collection contracts are explicit ports, not zero-cost builtins. Database transactions differ from serial Message turns. LMX has an HTTP profile; transport does not create storage guarantees. All listings are newly written; sources establish pattern definitions. The LMX fixture installs dependencies and initial state in the actual owner DATA before calls; potentially ambiguous actual positions are named explicitly, for example account\debit(amount := 30). Applicable control baselines are Python 3.10+, C# 12, Java 17 and Go 1.18+.

## Files

- [Markdown](LMX_Comparison_03_domain_and_persistence.md)
- [Excel](LMX_Comparison_03_domain_and_persistence.xlsx)
- [PDF](LMX_Comparison_03_domain_and_persistence.pdf)
- [CSV](LMX_Comparison_03_domain_and_persistence.csv)

## Catalog

### 016. [Repository](016_repository_comparision.md)

Domain collection access hides retrieval details.

**Separate implementation comparison:** [094. FindById — implementation](094_find_by_id_implementation_comparision.md)

**Scenario:** Use two materialized accounts (7,100) and (9,250); find 9 and then missing 10.

**Observation:** Return the existing account 9, then absence; do not create a second instance.

The finite 22-Nov contract and short LMX client are restored. Controls retain the natural standard facilities from 23-Nov. The narrow LMX implementation is shown separately; the wider 23-Nov algorithm has its own contract. The LMX implementation is shared and generic; the foreign client retains its stated application profile. The source comparison does not equate the complete general-purpose library coverage.

### 094. [FindById — implementation](094_find_by_id_implementation_comparision.md)

Generic findFirst returns Maybe of the first element accepted by the supplied predicate.

**Usage examples:** [016. Repository](016_repository_comparision.md)

**Scenario:** Scan an ordered record sequence and return the first matching id or absence.

**Observation:** Id 7 returns its original record; duplicate ids return the first; unknown ids and empty sequences return absence.

All implementations explicitly show their own loop, id comparison, early return, and absence branch. Python next/filter and C# FirstOrDefault are not used to implement the helper. LMX/Python require id structurally; C# exposes that required access through IIdentified. The wider 23-Nov contract remains in a separate comparison and does not replace this finite task.

### 017. [Unit of Work](017_unit_of_work_comparision.md)

Accumulate changes and flush them in one transaction.

**Scenario:** Mark account 7 as 120 then 130, mark account 9 as 200, then flush. Repeated IDs replace their pending value.

**Observation:** No writes before flush. A successful transaction writes (7,130),(9,200) and clears dirty; failure rolls back and retains dirty.

Python dict, C# Dictionary and an LMX map serve the same job. All three depend on the same transaction contract.

### 018. [Data Mapper](018_data_mapper_comparision.md)

Map stored rows to a persistence-independent domain representation.

**Scenario:** Load row [7,1250], then save a domain account with cents=1300.

**Observation:** load yields id=7,cents=1250; save writes [7,1300]. The domain object holds no database reference.

Every version separates mapping from the domain object. Records/dataclasses correspond to the ordinary LMX Structure.

### 019. [Active Record](019_active_record_comparision.md)

A row object owns data, domain behavior and persistence.

**Scenario:** Account 7 starts with 100 cents: debit 30, save, then try to debit 80.

**Observation:** 70 is persisted; the invalid second debit leaves 70 unchanged and performs no write.

Unlike Data Mapper, the domain object knows its storage port.

### 020. [Table Data Gateway](020_table_data_gateway_comparision.md)

One gateway serves every row in a table.

**Scenario:** Read account 7; update account 9 to 200 cents. Keep SQL and parameters in the gateway.

**Observation:** Run a parameterized SELECT for 7 and UPDATE for (200,9); do not concatenate values into SQL.

An LMX Structure or a Python/C# class groups table-wide operations; this is not one object per row.

### 021. [Row Data Gateway](021_row_data_gateway_comparision.md)

A gateway for one row stores its key and values, without domain rules.

**Scenario:** For row 7, set cents to 150 and call update.

**Observation:** UPDATE receives (150,7); there is no balance validation or debit rule.

One gateway per row distinguishes this from Table Data Gateway; the absence of business operations distinguishes it from Active Record.

### 022. [DAO — Data Access Object](022_dao_comparision.md)

Application code depends on access operations rather than storage details.

**Scenario:** Call the same service with a database DAO returning 100 and a test DAO returning 25.

**Observation:** The service returns 100 and 25 without modification.

LMX structural compatibility, Python duck typing and a C# interface express the boundary. This scalar DAO differs from a domain collection Repository.

### 023. [DTO — Data Transfer Object](023_dto_comparision.md)

Project allowed fields into one transport value.

**Scenario:** Account 7 has 1250 cents and a secret token. Export only id and cents.

**Observation:** The result contains exactly id=7 and cents=1250; neither token nor domain methods is included.

All three projections are explicit. A serializer does not make whole-domain-graph export an appropriate DTO.

### 024. [Domain Model](024_domain_model_comparision.md)

Keep a business invariant with domain state.

**Scenario:** An account starts at 100; debit 30, then attempt 80. Only nonnegative amounts within the balance are valid.

**Observation:** The first debit returns 70; the second raises Funds/an exception and leaves 70 unchanged.

Every version combines data and the invariant without a persistence dependency.

### 025. [Transaction Script](025_transaction_script_comparision.md)

One procedure handles one application request.

**Scenario:** Transfer 30 from account 1 (100) to account 2 (20), then attempt 200 in a separate transaction.

**Observation:** The first request atomically produces 70 and 50; the second raises Funds and changes neither balance.

Each language places the request rule and database sequence in one procedure; a rich domain object hierarchy is unnecessary.

### 026. [Table Module](026_table_module_comparision.md)

One module applies business logic to a complete row set.

**Scenario:** Rows (quantity=2,price=10) and (quantity=3,price=7) form an order.

**Observation:** Total is 41; input rows remain unchanged.

All versions perform the same multiply-and-sum loop; organization, not collection syntax, defines the pattern.

### 027. [Service Layer](027_service_layer_comparision.md)

Expose the same application operation to multiple interfaces.

**Scenario:** CLI and HTTP both invoke checkout(7,30). Load a fresh domain copy, debit it, then save in one transaction.

**Observation:** Both entrances use load → debit → save. Insufficient funds skip save and roll back the database.

Transport adapters stay thin. The service coordinates the domain and infrastructure; unlike Transaction Script, debit rules live in the domain object.

### 028. [Identity Map](028_identity_map_comparision.md)

One session returns one object identity per key.

**Scenario:** Call get(7), get(7), get(9). The loader creates a fresh object on each real read.

**Observation:** The loader runs twice. Both results for 7 are the same object; the result for 9 differs.

Each implementation stores references. Copying on every get would violate the identity requirement.

### 029. [Lazy Load](029_lazy_load_comparision.md)

Load on first use and retain a successful value.

**Scenario:** Read twice when load returns zero. Separately test a failing first load followed by a successful zero.

**Observation:** The successful scenario loads once. A failed attempt leaves loaded false and can be retried.

All versions compute first, store the result, then publish the loaded flag.

### 030. [Query Object](030_query_object_comparision.md)

Represent a query as data and translate it to parameterized SQL.

**Scenario:** A range query [100,200] filters balances inclusively.

**Observation:** The driver receives two placeholders and parameters (100,200); values 99,100,200,201 yield two rows.

Every implementation keeps parameters separate from SQL text.

### 031. [Specification](031_specification_comparision.md)

Compose predicates independently of their candidate values.

**Separate implementation comparison:** [095. Specification combinator — implementation](095_specification_combinator_implementation_comparision.md)

**Scenario:** Combine nonnegative and below100 with AND; test -1,50,100.

**Observation:** Results are false,true,false; the right predicate is skipped when the left is false.

The finite 22-Nov contract and short LMX client are restored. Controls retain the natural standard facilities from 23-Nov. The narrow LMX implementation is shown separately; the wider 23-Nov algorithm has its own contract. The LMX implementation is shared and generic; the foreign client retains its stated application profile. The source comparison does not equate the complete general-purpose library coverage.

### 095. [Specification combinator — implementation](095_specification_combinator_implementation_comparision.md)

Generic allOf builds a short-circuit callable with the actual compatible signature.

**Usage examples:** [031. Specification](031_specification_comparision.md)

**Scenario:** Retain two callable references and return a new int predicate. At each invocation evaluate the left side, then the right side only after true.

**Observation:** nonnegative both below100 yields false,true,false for -1,50,100. A false left result does not increment a right-call counter. Repeated calls reuse the retained references.

LMX explicitly constructs the retained graph and selects its owner; Python closures and C# lambdas retain references through language facilities. All three implement their own AND using &&/and, without calling a ready both. No SQL expression builder or hidden AST evaluator is used. The wider 23-Nov contract remains in a separate comparison and does not replace this finite task.

### 032. [Value Object](032_value_object_comparision.md)

Equality follows component values rather than object identity.

**Separate implementation comparison:** [096. Money value equality — implementation](096_money_value_equality_implementation_comparision.md)

**Scenario:** Compare distinct Money(100,840) values, then compare with Money(100,978). Currency is an integer code.

**Observation:** The first pair is equal and the third value differs. demo encodes the two checks as 10; equality does not require object identity.

The finite 22-Nov contract and short LMX client are restored. Controls retain the natural standard facilities from 23-Nov. The narrow LMX implementation is shown separately; the wider 23-Nov algorithm has its own contract. The LMX implementation is shared and generic; the foreign client retains its stated application profile. The source comparison does not equate the complete general-purpose library coverage.

### 096. [Money value equality — implementation](096_money_value_equality_implementation_comparision.md)

Generic equals applies an explicit projection and the shared equality dispatch.

**Usage examples:** [032. Value Object](032_value_object_comparision.md)

**Scenario:** Store read-only cents/currency and compare both components in order. Defaults are 100/840, with alternative currency 978.

**Observation:** Two independently constructed Money(100,840) values compare true; Money(100,978) compares false. Direct component mutation is not an admitted operation.

Python uses a basic immutable tuple, removes the instance dictionary with __slots__, and exposes read-only properties; same is explicit. C# uses a readonly struct/get-only properties and explicit Same. LMX uses ready immutable primitive records and an explicit operand. No ready equality helper is imported by its own implementation; dataclass/record equality does not replace the shown algorithm. The wider 23-Nov contract remains in a separate comparison and does not replace this finite task.

### 033. [Optimistic Offline Lock](033_optimistic_offline_lock_comparision.md)

Atomically check the observed version and increment it when saving.

**Scenario:** Two sessions read account 7 at version 4. Save 120, then try 150 with the stale version.

**Observation:** The first update affects one row and sets version 5; the second affects zero rows and raises Conflict. 120 remains.

The same database primitive provides correctness in every language. A local check before an unguarded UPDATE would race.

### 034. [Pessimistic Offline Lock](034_pessimistic_offline_lock_comparision.md)

Reserve a row for a business session without holding one SQL transaction open.

**Scenario:** A acquires token 41 for row 7; B is refused. After A ends, a new session gets 42; a delayed write with 41 is rejected.

**Observation:** Only the current owner can save. Expired tokens never regain authority.

All variants carry the token to the protected write. A process-local guard does not protect editing across HTTP requests.
