# L2 specification

L2 is LMX with special low-level operations. This specification describes these operations, their semantics, and the precise core structure at the L2 level, including data representation, memory placement, and access from threads. The semantics of pure, hermetic LMX (L3) are defined in the [main specification](LMX_semantics.en.md), and the common grammar is defined in the [LMX grammar specification](LMX_grammar.en.md).

Each description of a core mechanism has a corresponding section in the [L1 specification](L1_spec_en.md) defining its implementation in L1 and C99. Both descriptions define the same mechanism at their respective levels; translation from L2 to L1 to C99 preserves its behavior.
