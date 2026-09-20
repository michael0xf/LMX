package graph;

/**
 * Binary/in-memory L3 program fixture for the first printer slice.
 * Not source text; not Translator-L1. Roles are physical singletons.
 */
public final class L3SmokeFixture {
    private L3SmokeFixture() {}

    public static L3Node program() {
        return L3Node.of(
                L3Role.PROGRAM,
                L3Node.ofInt(L3Role.CHECK_INT, 42),
                L3Node.of(L3Role.CHECK_VOID_STEP),
                L3Node.of(L3Role.CHECK_INDEPENDENT),
                L3Node.of(L3Role.CHECK_NESTED),
                L3Node.of(L3Role.CHECK_BOUNDS),
                L3Node.of(L3Role.CHECK_FIELD_FOLLOW),
                L3Node.of(L3Role.CHECK_MERGE));
    }
}
