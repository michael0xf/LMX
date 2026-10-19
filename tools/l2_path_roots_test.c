/* Internal compiler test, not a language fixture or a new compiler flag.
   Build with the tested generation directory first on the include path,
   or define L2_FRONTEND_SOURCE as the exact generated frontend C file.
   Fabricated collected metadata checks root category/index independence;
   it does not assert that today's source collector reaches every category.
   In particular graph-typed machine locals can be a legacy source route. */
#ifndef L2_FRONTEND_SOURCE
#define L2_FRONTEND_SOURCE "l2trans.c"
#endif
#define main l2_root_test_frontend_main
#include L2_FRONTEND_SOURCE
#undef main

static int l2_root_test_expect(const char *text, int kind, int index, int model)
{
    L2Path path;
    int status;
    l2_path_init(text, strlen(text), &path);
    status = l2_path_root_resolve(&path);
    if (status || path.root_kind != kind || path.root != index || path.ni != model) {
        fprintf(stderr, "root %s: status=%d kind=%d index=%d model=%d; expected %d/%d/%d\n",
                text, status, path.root_kind, path.root, path.ni, kind, index, model);
        return 1;
    }
    return 0;
}

int main(void)
{
    enum { count = 1031 };
    static LmP0Text *names[count];
    static int models[count], zeros[count], parents[count];
    static LmP0Node *nodes[count];
    LmP0Text local = {0}, method = {0}, control = {0};
    LmP0Node frame = {0};
    LmP0NodeAs as = {0};
    LmP0Frame body = {0};
    int indices[] = {0, 989, 990, 996, 997, 999, 1000, 1024, 1030};
    size_t i;
    int k, failures = 0;
    local.data = "held"; local.length = 4;
    method.data = "callee"; method.length = 6;
    control.data = "if"; control.length = 2;
    l2_m_arity = zeros;
    l2_m_dyn = zeros;
    l2_cur_mi = 0;
    l2_e = 0;
    l2_ml_nm = names;
    l2_ml_ns = models;
    for (k = 0; k < count; ++k) models[k] = -1;
    for (i = 0; i < sizeof(indices) / sizeof(*indices); ++i) {
        k = indices[i];
        names[k] = &local;
        models[k] = 7;
        l2_ml_n = k + 1;
        failures += l2_root_test_expect("held\\field", 4, k, 7);
        names[k] = 0;
        models[k] = -1;
    }
    l2_ml_n = 0;
    l2_m_name = names;
    for (i = 0; i < sizeof(indices) / sizeof(*indices); ++i) {
        k = indices[i];
        names[k] = &method;
        l2_m_n = k + 1;
        failures += l2_root_test_expect("callee\\field", 3, k, -1);
        names[k] = 0;
    }
    l2_m_n = 0;
    l2_cur_mi = 1;
    failures += l2_root_test_expect("node\\field", 1, -1, -1);
    l2_cur_mi = 0;
    frame.kind = LM_P0_NODE_FRAME;
    frame.as = &as;
    as.frame = &body;
    body.head = &control;
    l2_for_stmt = nodes;
    l2_for_node = nodes;
    l2_for_parent = parents;
    l2_for_mi = zeros;
    for (k = 0; k < count; ++k) parents[k] = -1;
    for (i = 0; i < sizeof(indices) / sizeof(*indices); ++i) {
        k = indices[i];
        nodes[k] = &frame;
        l2_for_n = k + 1;
        failures += l2_root_test_expect("if\\field", 2, k, -1);
        nodes[k] = 0;
    }
    fprintf(stderr, "root categories: %d failures, 28 selections\n", failures);
    return failures != 0;
}
