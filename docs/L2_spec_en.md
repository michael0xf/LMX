# L2 specification

L2 is LMX with special low-level operations. This specification describes these operations and their semantics. The semantics of pure, hermetic LMX (L3) are defined in the [main specification](LMX_semantics.en.md), and the common grammar is defined in the [LMX grammar specification](LMX_grammar.en.md).

The precise core implementation, including data representation, memory placement, access from threads, and execution of operations through L1 and C99, is defined in the [L1 specification](L1_spec_en.md). The semantics of L2 operations and the corresponding L1 implementation rules jointly define the behavior of the core.
