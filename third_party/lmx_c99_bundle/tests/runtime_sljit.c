/* Native execution and same-build serializer test; not a portable file format test. */
#include "sljitLir.h"
#include <stdio.h>
#include <string.h>

#define CHECK(c) do { if (!(c)) { \
    fprintf(stderr, "%s:%d: %s\n", __FILE__, __LINE__, #c); return 1; \
} } while (0)

typedef sljit_sw (SLJIT_FUNC *lmx_jit_function)(sljit_sw);

static int run_generated(struct sljit_compiler *compiler) {
    void *code = sljit_generate_code(compiler, 0, NULL);
    lmx_jit_function fn;
    CHECK(code != NULL);
    CHECK(sljit_get_generated_code_size(compiler) > 0);
    /* The supported JIT ABI has same-size data/code pointer representations.
       memcpy avoids an ISO C diagnostic for a direct object/function cast;
       executable-memory conversion remains a platform ABI requirement. */
    CHECK(sizeof(fn) == sizeof(code));
    memcpy(&fn, &code, sizeof(fn));
    CHECK(fn(35) == 42);
    CHECK(fn(-12) == -5);
    sljit_free_code(code, NULL);
    return 0;
}

int main(void) {
    struct sljit_compiler *compiler = sljit_create_compiler(NULL);
    struct sljit_compiler *restored;
    sljit_uw serialized_size = 0;
    sljit_uw *serialized;
    CHECK(compiler != NULL);
    CHECK(sljit_emit_enter(compiler, 0, SLJIT_ARGS1(W, W), 1, 1, 0) == SLJIT_SUCCESS);
    CHECK(sljit_emit_op2(compiler, SLJIT_ADD, SLJIT_R0, 0,
                         SLJIT_S0, 0, SLJIT_IMM, 7) == SLJIT_SUCCESS);
    CHECK(sljit_emit_return(compiler, SLJIT_MOV, SLJIT_R0, 0) == SLJIT_SUCCESS);
    serialized = sljit_serialize_compiler(compiler, 0, &serialized_size);
    CHECK(serialized != NULL && serialized_size > 0);
    restored = sljit_deserialize_compiler(serialized, serialized_size, 0, NULL);
    CHECK(restored != NULL);
    SLJIT_FREE(serialized, sljit_get_allocator_data(compiler));
    CHECK(run_generated(compiler) == 0);
    CHECK(run_generated(restored) == 0);
    sljit_free_compiler(compiler);
    sljit_free_compiler(restored);
    return 0;
}
