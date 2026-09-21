/* Path A executable harness for tracked seed lm1/build/parser.lm1.c
 * Does not modify or regenerate the seed. Links the seed's real implementation.
 * Compile: -I. -Ilm1/build  (resolves #include "l1src/p0.lm1.h")
 * plus lm1/build/parser.lm1.c on the same command line.
 *
 * Inputs chosen from tracked fixtures / tests (not invented grammar):
 *   minimal valid: "value\n"  — tests/parser/imported/01-old-worked/.../trans_parser_managed_abi.lm2
 *   nested short:  C_nested_short_ok.lmx body —
 *       tests/parser/imported/02-lingvamyxa/tests/p0_tree_contract/C_nested_short_ok.lmx
 *   invalid:       invalid_eq_unclosed.lmx —
 *       .../p0_tree_contract/invalid_eq_unclosed.lmx  (meta: REJECT code=20)
 */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "l1src/p0.lm1.h"

extern int lm_p0_parse_string(const char *source, LmP0Document **out_document);
extern void lm_p0_document_destroy(LmP0Document *document);
extern const LmP0Node *lm_p0_document_root(const LmP0Document *document);
extern const LmP0Diagnostic *lm_p0_document_diagnostic(const LmP0Document *document);
extern char *lm_p0_dump_alloc(const LmP0Document *document);
extern void lm_p0_free(void *ptr);

static int g_checks;
static int g_fails;

static void expect(int ok, const char *label)
{
    g_checks += 1;
    if (!ok) {
        g_fails += 1;
        fprintf(stderr, "VM_PARSER_FAIL %s\n", label);
    }
}

static void destroy_doc(LmP0Document *document)
{
    if (document != 0) {
        lm_p0_document_destroy(document);
    }
}

int main(void)
{
    LmP0Document *document;
    const LmP0Node *root;
    const LmP0Diagnostic *diag;
    char *dump;
    int status;

    /* Exact bodies from tracked fixtures (LF newlines). */
    static const char k_minimal[] = "value\n";
    static const char k_nested[] =
        "ShortForm1: 1\n"
        ". ShortForm2: 2\n"
        ". . ShortForm2_arg2\n"
        ". ShortForm1_arg3\n";
    static const char k_invalid[] =
        "doc:\n"
        "===\n"
        "alpha\n"
        "end: doc\n";

    g_checks = 0;
    g_fails = 0;

    /* --- 1) minimal valid document --- */
    document = 0;
    status = lm_p0_parse_string(k_minimal, &document);
    expect(status == 0, "minimal_parse_ok");
    expect(document != 0, "minimal_document");
    root = lm_p0_document_root(document);
    expect(root != 0, "minimal_root");
    dump = lm_p0_dump_alloc(document);
    expect(dump != 0, "minimal_dump_alloc");
    expect(dump != 0 && strstr(dump, "value") != 0, "minimal_dump_has_value");
    if (dump != 0) {
        lm_p0_free(dump);
    }
    destroy_doc(document);

    /* --- 2) nested / short-form receiver-shaped sample (C_nested_short_ok.lmx) --- */
    document = 0;
    status = lm_p0_parse_string(k_nested, &document);
    expect(status == 0, "nested_parse_ok");
    expect(document != 0, "nested_document");
    root = lm_p0_document_root(document);
    expect(root != 0, "nested_root");
    dump = lm_p0_dump_alloc(document);
    expect(dump != 0, "nested_dump_alloc");
    expect(dump != 0 && strstr(dump, "ShortForm1") != 0, "nested_dump_ShortForm1");
    expect(dump != 0 && strstr(dump, "ShortForm2") != 0, "nested_dump_ShortForm2");
    expect(dump != 0 && strstr(dump, "ShortForm2_arg2") != 0, "nested_dump_inner_arg");
    if (dump != 0) {
        lm_p0_free(dump);
    }
    destroy_doc(document);

    /* --- 3) deliberately invalid (invalid_eq_unclosed.lmx; meta REJECT code=20) --- */
    document = 0;
    status = lm_p0_parse_string(k_invalid, &document);
    expect(status != 0, "invalid_parse_nonzero");
    expect(document != 0, "invalid_document_still");
    diag = lm_p0_document_diagnostic(document);
    expect(diag != 0, "invalid_diagnostic");
    expect(diag != 0 && diag->code == 20, "invalid_diagnostic_code_20");
    destroy_doc(document);

    if (g_fails != 0) {
        fprintf(stderr, "VM_PARSER_FAIL checks=%d fails=%d\n", g_checks, g_fails);
        return 1;
    }
    printf("VM_PARSER_OK checks=%d\n", g_checks);
    return 0;
}
