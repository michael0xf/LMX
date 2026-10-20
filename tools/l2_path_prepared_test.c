/* Include the actual tested frontend, not a second parser/resolver. */
#ifndef L2_FRONTEND_SOURCE
#define L2_FRONTEND_SOURCE "l2trans.c"
#endif
#define main l2_prepared_test_frontend_main
#include L2_FRONTEND_SOURCE
#undef main

static int failures, checks;
static void expect(int good, const char *what)
{
    ++checks;
    if (!good) { ++failures; fprintf(stderr, "FAIL %s\n", what); }
}

int main(void)
{
    const char *texts[] = {
        "values[choose()]\\leaf\\value", "holder\\items[index]",
        "values[i][j]", "values[i]\\[j]\\tail", "values[i] + 1U",
        "factory()[i]", "values\\field", "values"
    };
    LmP0Text heads[8] = {{0}};
    LmP0Node nodes[8] = {{0}};
    LmP0NodeAs variants[8] = {{0}};
    LmP0Frame frames[8] = {{0}};
    LmP0Span origins[8] = {{0}};
    L2HeadExpression *expressions[8] = {0};
    size_t i;
    int status;
    int live_before = l2_alloc_live;
    for (i = 0; i < 8; ++i) {
        heads[i].data = (char *)texts[i]; heads[i].length = strlen(texts[i]);
        origins[i].line = 10 + i; origins[i].column = 5; origins[i].offset = 100 * i;
        nodes[i].kind = LM_P0_NODE_FRAME; nodes[i].as = &variants[i]; nodes[i].span = &origins[i];
        variants[i].frame = &frames[i]; frames[i].head = &heads[i];
        expressions[i] = l2_head_expression(&nodes[i], &status);
        if (i == 7) {
            expect(!expressions[i] && status == 1, "bare root is not a path head");
            continue;
        }
        expect(expressions[i] && status == 0, "compact head parsed");
        if (!expressions[i]) continue;
        expect(l2_head_expression(&nodes[i], &status) == expressions[i] && status == 0,
               "same source borrows the same retained expression");
        if (i == 5) {
            expect(expressions[i]->path_status == 2, "computed-root grammar miss retained, not reparsed");
            continue;
        }
        {
            L2Path a = {0}, b = {0};
            L2Path *prepared = &expressions[i]->prepared;
            int n = prepared->n, k;
            expect(expressions[i]->path_status == 0, "prepared path verdict");
            status = l2_path_prepared_view(prepared, &a);
            if (!status) status = l2_path_prepared_view(prepared, &b);
            expect(!status, "two independent grammar views");
            if (status) { l2_path_release(&a); l2_path_release(&b); continue; }
            expect(a.steps != b.steps && a.steps != prepared->steps &&
                   a.text == prepared->text && !a.owned && !b.owned, "steps owned, source text borrowed");
            expect(a.n == prepared->n && a.names == prepared->names && a.indexed == prepared->indexed &&
                   a.run_count == prepared->run_count && a.names_run == prepared->names_run && a.flat == prepared->flat,
                   "all grammar counters/spans copied together");
            for (k = 0; k < n; ++k) {
                expect(a.steps[k].node == prepared->steps[k].node &&
                       a.steps[k].kind == -1 && a.steps[k].view_model == -1 && a.steps[k].level == 0,
                       "source node retained, semantic step verdict empty");
                if (prepared->steps[k].locus == 7)
                    expect(a.steps[k].index.first == prepared->steps[k].index.first &&
                           a.steps[k].index.count == prepared->steps[k].index.count,
                           "index expression span retained");
            }
            if (i == 0) {
                expect(prepared->n == 3 && prepared->names == 0 && prepared->indexed == 1,
                       "field names after an index are grammar steps");
                expect(a.steps[0].index.first->value->kind == LM_P0_NODE_FRAME,
                       "computed index keeps its original Frame");
                expect(prepared->steps[1].node->span->line == origins[i].line,
                       "retained source location rebased once");
            }
            if (i == 1) {
                L2Path prefix = {0};
                expect(!l2_path_prepared_view(prepared, &prefix), "prefix starts from the same grammar result");
                expect(!l2_path_names_only(&prefix) && prefix.n == prefix.names && !prefix.indexed &&
                       prefix.run_count == prefix.names_run && !prefix.flat,
                       "prefix view cuts counters/span/flat together");
                expect(prepared->n == n && prepared->indexed == 1, "prefix view does not cut the retained source");
                l2_path_release(&prefix);
            }
            if (i == 2) expect(a.flat != 0, "flat second bracket retained as the distinct form");
            if (i == 3) expect(a.n == 3 && a.indexed == 2, "linked indices and following name retained");
            if (i == 6) expect(a.n == 1 && a.names == 1 && a.indexed == 0 &&
                               a.steps[0].locus != 7 && a.run_count == 3,
                               "nonindexed path uses the same complete prepared grammar");
            if (i == 4) expect(a.run_count < l2_count_active(expressions[i]->body),
                               "whole P0 expression is not silently cut to its path prefix");
            a.steps[0].off = 12345;
            a.n = 0;
            l2_path_release(&a);
            expect(prepared->n == n && b.n == n && prepared->steps[0].off != 12345,
                   "releasing/mutating one view leaves source and sibling unchanged");
            l2_path_release(&b);
        }
    }
    if (expressions[0]) {
        L2Path view;
        L2Path *source = &expressions[0]->prepared;
        {
            LmP0Field written = {0};
            LmP0Structure original_body = {0};
            LmP0Node *index_call = source->steps[0].index.first->value;
            LmP0Node *found;
            written.value = &nodes[0]; original_body.first_field = &written;
            found = l2_node_of_text(&original_body, index_call->as->frame->head);
            expect(found == index_call, "source-use lookup includes the retained head expression");
            expect(l2_head_source_node(found) == &nodes[0], "retained read belongs to its original written Frame");
        }
        source->leaf_kind = 99; source->leaf_model = 17; source->fail_why = 3;
        source->root_kind = 4; source->root = 1024; source->ni = 9;
        source->steps[0].view_model = 9; source->steps[0].elem_ty = 7;
        source->steps[0].level = (L2TypeContract *)source;
        expect(!l2_path_prepared_view(source, &view), "view can discard a prior semantic verdict");
        expect(view.leaf_kind == -1 && view.leaf_model == -1 && !view.fail_why &&
               !view.root_kind && view.root == -1 && view.ni == -1 &&
               view.steps[0].view_model == -1 && view.steps[0].elem_ty == -1 && !view.steps[0].level,
               "no stale root/type/map survives the new grammar view");
        l2_path_release(&view);
        {
            int original_n = source->n;
            source->n = source->cap + 1;
            expect(l2_path_prepared_view(source, &view) == 2 && !view.steps && !view.n,
                   "malformed counter/capacity refuses without exposing a partial view");
            source->n = original_n;
        }
        {
            L2Path invalid;
            int which;
            for (which = 0; which < 8; ++which) {
                invalid = *source;
                switch (which) {
                case 0: invalid.n = 0; break;
                case 1: invalid.names = -1; break;
                case 2: invalid.names = invalid.n + 1; break;
                case 3: invalid.indexed = -1; break;
                case 4: invalid.indexed = invalid.n - invalid.names + 1; break;
                case 5: invalid.run_count = -1; break;
                case 6: invalid.names_run = -1; break;
                case 7: invalid.names_run = invalid.run_count + 1; break;
                }
                expect(l2_path_prepared_view(&invalid, &view) == 2 &&
                       !view.steps && !view.n && !view.text && !view.cap,
                       "inconsistent grammar counters refuse an empty view");
            }
        }
        {
            int live = l2_alloc_live;
            l2_fail_left = 1;
            expect(l2_path_prepared_view(source, &view) == 3 &&
                   !view.steps && !view.n && !view.text && !view.cap && l2_alloc_err == 1,
                   "view allocation failure exposes no partial result");
            expect(l2_alloc_live == live && source->steps && source->n == 3,
                   "failed view leaves its owner and allocation balance unchanged");
            l2_fail_left = 0; l2_alloc_err = 0;
            expect(!l2_path_prepared_view(source, &view), "fresh view after allocation failure");
            l2_path_release(&view);
            expect(l2_alloc_live == live, "retry view releases all of its own storage");
        }
        {
            expect(!l2_path_prepared_view(source, &view), "fatal-path test owns an independent grammar view");
            view.leaf_kind = 7; view.leaf_mi = 3; view.leaf_model = 9;
            view.leaf_ty = 7; view.array_leaf = 1; view.leaf_level = (L2TypeContract *)source;
            l2_alloc_err = 1;
            expect(l2_path_fail(&view, 1, 4) == -1 && view.fail_why == 7 &&
                   view.leaf_kind == -1 && view.leaf_mi == -1 && view.leaf_model == -1 &&
                   view.leaf_ty == -1 && !view.array_leaf && !view.leaf_level &&
                   view.n == source->n && view.steps && view.text == source->text,
                   "fatal allocation clears every leaf verdict but retains source grammar for refusal");
            l2_alloc_err = 0;
            l2_path_release(&view);
        }
        {
            int saved_mi = l2_cur_mi;
            l2_cur_mi = -1;
            /* No collected binding exists in this synthetic test. The shared
               resolver conservatively reports an effect; a last-byte ']'
               recognizer incorrectly skips the entire field-after-index head. */
            expect(l2_head_path_effect(&nodes[0], -1) == 1,
                   "effects consume prepared field-after-index grammar");
            expect(l2_head_path_effect(&nodes[6], -1) == 1 &&
                   l2_head_expression(&nodes[6], &status) == expressions[6],
                   "effects consume nonindexed prepared grammar without a fallback parse");
            expect(l2_head_path_effect(&nodes[5], -1) == 0 &&
                   l2_head_expression(&nodes[5], &status) == expressions[5],
                   "effects retain a non-path verdict without a fallback parse");
            expect(source->n == 3 && source->steps[0].view_model == 9,
                   "effect resolution does not overwrite the prepared owner");
            l2_cur_mi = saved_mi;
        }
    }
    while (l2_head_expressions) {
        L2HeadExpression *expression = l2_head_expressions;
        l2_head_expressions = expression->allocated_next;
        l2_head_expression_dispose(expression);
    }
    expect(l2_alloc_live == live_before, "all prepared owners and views released");
    fprintf(stderr, "prepared head paths: %d checks, %d failures\n", checks, failures);
    return failures != 0;
}
