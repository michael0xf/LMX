# L1 specification

This specification covers the L1 language, its translation to C99, and the precise implementation of the L2 core in L1 and C. Data representation, memory placement, access from threads, and execution mechanisms are part of this specification, including details on which preservation of the language model depends.

The semantics of pure, hermetic LMX (L3) are defined in the [main specification](LMX_semantics.en.md). Special low-level operations and the core structure at the L2 level are described in the [L2 specification](L2_spec_en.md). The corresponding sections of this specification define their implementation in L1 and C.

<a id="atomic-handshake-flags"></a>

## Atomic handshake flags

Atomic handshake flags reside in the parent's arena. Multiple threads may access these flags, including modifying them, without synchronization. Multiple threads may also access immutable constant branches; unlike these branches, the flags are mutable.

Corresponding L2 core description: [atomic handshake flags](L2_spec_en.md#atomic-handshake-flags).
