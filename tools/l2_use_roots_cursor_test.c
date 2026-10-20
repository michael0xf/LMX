/* Actual frontend39, bound-root and common step-cursor walk; no replacement resolver. */
#ifndef L2_FRONTEND_SOURCE
#define L2_FRONTEND_SOURCE "l2trans.c"
#endif
#define main l2_step_cursor_test_frontend_main
#include L2_FRONTEND_SOURCE
#undef main

static int checks, failures;
static void expect(int good, const char *what)
{
    ++checks;
    if (!good) { ++failures; fprintf(stderr, "FAIL %s\n", what); }
}

int main(void)
{
    LmP0Text a = {0}, b = {0}, other_b = {0}, x = {0};
    LmP0Text *inputs[] = { &a, &b }, *field_names[] = { &x };
    void *input_rows[] = { inputs };
    int arity[] = {2}, dynamic[] = {0}, ns_negative[] = {-1};
    int owner[] = {0}, kind[] = {7}, ref[] = {-1};
    int formal_mi[] = {0,0}, formal_k[] = {0,1}, formal_model[] = {0,0};
    int admit_mi[] = {0}, admit_k[] = {1};
    LmP0Node *empty_nodes[] = {0};
    LmP0Text *empty_names[] = {0};
    L2SourceSite site = {0};
    L2PathFact fact = {0};
    L2PathStep step;
    L2Path out;
    int live = l2_alloc_live, status;
    a.data = "a"; a.length = 1;
    b.data = "b"; b.length = 1;
    other_b.data = "b"; other_b.length = 1;
    x.data = "x"; x.length = 1;
    l2_m_n = 1; l2_e = 0; l2_cur_mi = 0;
    l2_m_arity = arity; l2_m_dyn = dynamic; l2_m_fn = input_rows;
    l2_m_node = empty_nodes; l2_m_body = empty_nodes;
    l2_ns_name = empty_names; l2_m_name = empty_names;
    l2_ns_n = 1; l2_ns_eternal = ns_negative; l2_ns_proc = ns_negative;
    l2_nsf_n = 1; l2_nsf_owner = owner; l2_nsf_kind = kind;
    l2_nsf_ref = ref; l2_nsf_fname = field_names; l2_nsf_source = empty_nodes;
    l2_nsty_n = 2; l2_nsty_mi = formal_mi;
    l2_nsty_k = formal_k; l2_nsty_ni = formal_model;
    fact.method = 0; fact.source_use = 1; fact.input_symbol = &b;
    fact.use_site = &site;
    site.method = site.source_method = site.current_method = 0;
    site.excluded = -1;
    l2_path_init("b\\x", 3, &fact.resolved);
    l2_path_step_clear(&step); step.off = 2; step.len = 1;
    fact.resolved.steps = &step;
    fact.resolved.n = fact.resolved.cap = fact.resolved.names = 1;
    fact.resolved.run_count = fact.resolved.names_run = 3;
    fact.resolved.fi = 0; /* b preceded later insertion of a. */
    l2_path_fail_seg = 73; l2_path_fail_why = 19;
    l2_uses_node_for_root = 21;
    status = l2_source_use_resolve(&fact, &out);
    expect(!status && out.fi == 1 && out.oi == -1,
           "canonical b row, not its old fi0, selects current input1");
    expect(out.leaf_kind == 7 && out.steps[0].locus == 1 && out.steps[0].row == 0,
           "the common semantic walk resolves the actual scalar field");
    expect(out.n == fact.resolved.n && out.names == fact.resolved.names &&
           out.run_count == fact.resolved.run_count && out.steps != fact.resolved.steps,
           "source counters stay together and result steps are independently owned");
    expect(fact.resolved.fi == 0 && fact.resolved.steps[0].kind == -1,
           "resolving does not rewrite the saved binding or grammar");
    expect(l2_path_fail_seg == 73 && l2_path_fail_why == 19 &&
           l2_uses_node_for_root == 21 && l2_cur_mi == 0,
           "caller diagnostics and namespace are restored");
    l2_path_release(&out);
    expect(l2_alloc_live == live, "source result storage released");

    fact.resolved.text = "z\\x"; /* Deliberately unbound spelling, same step geometry. */
    status = l2_source_use_resolve(&fact, &out);
    expect(!status && out.fi == 1 && out.leaf_kind == 7,
           "a saved canonical binding is not reparsed or looked up by root spelling");
    l2_path_release(&out);
    l2_d105_n = 1; l2_d105_mi = admit_mi; l2_d105_k = admit_k;
    status = l2_source_use_resolve(&fact, &out);
    expect(!status && out.steps[0].view_model == 0 && out.steps[0].model_context == -3,
           "the same root-contract walk carries its receiving map and source context");
    l2_path_release(&out);
    l2_d105_n = 0;

    inputs[0] = &b; inputs[1] = &a;
    status = l2_source_use_resolve(&fact, &out);
    expect(!status && out.fi == 0 && out.leaf_kind == 7,
           "another input permutation preserves binding identity");
    l2_path_release(&out);
    fact.input_symbol = &other_b;
    expect(l2_source_use_resolve(&fact, &out) == 2 && !out.steps && !out.n,
           "equal spelling at another address is invalid inventory, not a fallback binding");
    fact.input_symbol = &b;
    fact.source_use = 2;
    expect(l2_source_use_resolve(&fact, &out) == 2 && !out.steps && !out.n,
           "a whole-value observation is not a fabricated path");
    fact.source_use = 1;
    l2_fail_left = 1;
    expect(l2_source_use_resolve(&fact, &out) == 3 && l2_alloc_err == 1,
           "allocation failure is fatal rather than empty consumption");
    l2_path_release(&out); l2_fail_left = 0; l2_alloc_err = 0;
    expect(l2_alloc_live == live, "failed resolution leaks no tracked storage");
    expect(!l2_formal_decl_at(0, 2) && !l2_formal_decl_at(-1, 0) &&
           !l2_formal_decl_at(1, 0), "invalid formal coordinates never start a name lookup");

    {
        L2PathFact nested = fact;
        L2PathStep nested_steps[2];
        l2_path_init("node\\m\\x", 8, &nested.resolved);
        l2_path_step_clear(&nested_steps[0]);
        l2_path_step_clear(&nested_steps[1]);
        nested_steps[0].off = 5; nested_steps[0].len = 1;
        nested_steps[1].off = 7; nested_steps[1].len = 1;
        nested.resolved.steps = nested_steps;
        nested.resolved.n = nested.resolved.cap = nested.resolved.names = 2;
        nested.resolved.run_count = nested.resolved.names_run = 5;
        status = l2_uses_project_from(&nested, 1, 0, &out);
        expect(!status && out.leaf_kind == 7 && out.steps[1].row == 0,
               "projection starts below the already selected place, with the common semantic fold");
        expect(out.n == 2 && out.names == 2 && !out.indexed &&
               out.run_count == 5 && out.names_run == 5 &&
               out.text == nested.resolved.text && !out.owned,
               "nonzero cursor does not slice, rebase or desynchronize the source record");
        expect(out.steps[0].kind == -1 && out.steps[1].kind == 7 &&
               out.steps[1].off == 7 && nested_steps[1].kind == -1,
               "only the requested suffix has a verdict and its source coordinates are unchanged");
        l2_path_release(&out);
        status = l2_uses_project(&nested, 0, &out);
        expect(status == 1 && out.fail_seg == 1 && out.fail_why == 2,
               "ordinary begin0 projection still refuses the genuinely absent first field");
        l2_path_release(&out);
        expect(l2_uses_project_from(&nested, -1, 0, &out) == 2 &&
               !out.steps && !out.n, "negative projection cursor refuses empty metadata");
        expect(l2_uses_project_from(&nested, 2, 0, &out) == 2 &&
               !out.steps && !out.n, "cursor past the last step is not empty consumption");
    }
    {
        enum { depth = 1031 };
        L2PathFact deep = fact;
        L2PathStep *steps = calloc(depth, sizeof(*steps));
        char *text = calloc(5 + 2 * depth, 1);
        int k;
        if (!steps || !text) return 2;
        memcpy(text, "node", 4);
        for (k = 0; k < depth; ++k) {
            text[4 + 2*k] = '\\';
            text[5 + 2*k] = k + 1 == depth ? 'x' : 'm';
            l2_path_step_clear(&steps[k]);
            steps[k].off = 5 + 2*k; steps[k].len = 1;
        }
        l2_path_init(text, 4 + 2*depth, &deep.resolved);
        deep.resolved.steps = steps;
        deep.resolved.n = deep.resolved.cap = deep.resolved.names = depth;
        deep.resolved.run_count = deep.resolved.names_run = 1 + 2*depth;
        status = l2_uses_project_from(&deep, depth - 1, 0, &out);
        expect(!status && out.n == depth && out.leaf_kind == 7 &&
               out.steps[depth-1].row == 0 && out.steps[depth-1].off == 5 + 2*(depth-1),
               "deep cursor has no one/two-level or 1024-step spelling limit");
        l2_path_release(&out);
        free(text); free(steps);
    }

    {
        L2Path indexed;
        L2PathStep index_steps[2];
        L2TypeContract array = {0}, element = {0};
        LmP0Text int_word = {0}, zero_word = {0};
        LmP0Node zero = {0};
        LmP0NodeAs zero_as = {0};
        LmP0Field zero_field = {0};
        int_word.data = "int"; int_word.length = 3;
        zero_word.data = "0"; zero_word.length = 1;
        zero.kind = LM_P0_NODE_ATOM; zero.as = &zero_as;
        zero_as.atom = &zero_word; zero_field.value = &zero;
        array.kind = 1; array.operand = &element;
        element.word = &int_word;
        l2_path_init("node\\m", 6, &indexed);
        l2_path_step_clear(&index_steps[0]); l2_path_step_clear(&index_steps[1]);
        index_steps[0].off = 5; index_steps[0].len = 1;
        index_steps[1].locus = 7;
        index_steps[1].index.first = &zero_field;
        index_steps[1].index.count = 1; index_steps[1].index.node = &zero;
        indexed.n = indexed.cap = 2; indexed.names = indexed.indexed = 1;
        indexed.run_count = 4; indexed.names_run = 3; indexed.steps = index_steps;
        status = l2_path_prepared_view(&indexed, &out);
        if (!status)
            status = l2_path_walk_steps_from(&out, 1, -1, -1, 0, -1, -1, -1, 0, 0, &array);
        expect(!status && out.leaf_kind == 13 && out.leaf_ty >= 0 &&
               out.leaf_ty == out.steps[1].elem_ty && out.steps[1].level == &array,
               "a cursor starting at INDEX uses the provided receiving Array contract");
        expect(out.n == 2 && out.names == 1 && out.indexed == 1 &&
               out.run_count == 4 && out.names_run == 3 &&
               out.steps[1].index.first == &zero_field && out.steps[1].index.count == 1 &&
               out.steps[1].index.node == &zero && out.steps[1].model_step == -1,
               "INDEX AST, full counters and selected-root contract origin stay aligned");
        l2_path_release(&out);
        status = l2_path_prepared_view(&indexed, &out);
        if (!status)
            status = l2_path_walk_steps_from(&out, 1, -1, -1, 0, -1, -1, -1, 0, 0, 0);
        expect(status == -1 && out.fail_seg == 2 && out.fail_why == 5 &&
               out.leaf_kind == -1 && out.n == 2 && out.indexed == 1,
               "missing Array contract is the ordinary type refusal at the original step");
        l2_path_release(&out);
    }

    expect(l2_alloc_live == live, "all cursor projection storage released");


    {
        L2Path selected;
        L2PathStep member;
        L2ReferenceSource source = {0};
        int proc[] = {4}, cf_mi[] = {0}, cf_input[] = {1}, cf_req[] = {5};
        l2_path_init("any\\place", 9, &selected);
        l2_path_step_clear(&member);
        selected.steps = &member; selected.n = selected.cap = selected.names = 1;
        selected.leaf_kind = 2; selected.leaf_model = 0;
        member.formal = 1; member.node_host = 0;
        l2_ns_proc = proc; l2_cf_n = 0;
        expect(l2_path_callee_rec(&selected) == -1,
               "a selected ordinary input cannot inherit its Model procedure");
        expect(!l2_reference_source_of_path(&selected, &source) &&
               source.schema == 0 && source.layout == -1 &&
               source.method == 0 && source.place == 1,
               "selected input and root input share the same source coordinate");
        l2_cf_n = 1; l2_cf_omi = cf_mi; l2_cf_fk = cf_input; l2_cf_req = cf_req;
        expect(l2_path_callee_rec(&selected) == l2_cf_get(0, 1) &&
               l2_path_callee_rec(&selected) == 5,
               "a callable selected input uses its input contract, not Model proc4");
        member.formal = member.node_host = -1;
        expect(l2_path_callee_rec(&selected) == 4,
               "a real declared Structure still selects its own procedure");
        selected.leaf_kind = 4; selected.leaf_mi = 6;
        expect(l2_path_callee_rec(&selected) == 6,
               "a selected method definition retains its callable source");
        selected.leaf_kind = 10;
        expect(l2_path_callee_rec(&selected) == -1,
               "an unclassified stored pointer is not invented as a method");
        selected.fail_why = 2;
        expect(l2_path_callee_rec(&selected) == -1,
               "a failed record never selects any callable");
        l2_cf_n = 0; l2_ns_proc = ns_negative;
    }

    fprintf(stderr, "bound source roots/cursors: %d checks, %d failures\n", checks, failures);
    return failures != 0;
}
