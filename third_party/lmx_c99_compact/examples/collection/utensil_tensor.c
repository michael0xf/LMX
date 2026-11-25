/* One implementation-bearing translation unit per program: see REPORT_RU.md. */
#ifdef NDEBUG
#undef NDEBUG
#endif
#include <utensil.h>
#include <stdio.h>

static void expect_close(float actual, float expected, float tolerance)
{
    assert(isfinite(actual));
    assert(fabsf(actual - expected) <= tolerance);
}

int main(void)
{
    const float expected[] = {58.f, 64.f, 139.f, 154.f};
    const float adata[] = {1.f, 2.f, 3.f, 4.f, 5.f, 6.f};
    const float bdata[] = {7.f, 8.f, 9.f, 10.f, 11.f, 12.f};
    ut_tensor *a = ut_from_data(2, (int[]){2, 3}, adata, UT_CPU);
    ut_tensor *b = ut_from_data(2, (int[]){3, 2}, bdata, UT_CPU);
    ut_tensor *product = ut_matmul(a, b);
    ut_tensor *probability = ut_softmax(product, 1);
    ut_tensor *target = ut_from_data(2, (int[]){2, 2}, expected, UT_CPU);
    ut_tensor *gradient = ut_alloc(2, (int[]){2, 2}, UT_CPU);
    ut_tensor *view;
    int i;

    assert(product->dev == UT_CPU && product->shape.nelem == 4);
    for(i = 0; i < 4; ++i) {
        expect_close(product->data[i], expected[i], 0.00001f);
        assert(isfinite(probability->data[i]));
        assert(probability->data[i] >= 0.f && probability->data[i] <= 1.f);
    }
    expect_close(probability->data[0] + probability->data[1], 1.f, 0.00001f);
    expect_close(probability->data[2] + probability->data[3], 1.f, 0.00001f);
    expect_close(ut_mse(product, target, gradient), 0.f, 0.00001f);
    for(i = 0; i < 4; ++i) expect_close(gradient->data[i], 0.f, 0.00001f);

    /* A view keeps the original storage alive until the last reference. */
    view = ut_view(product, 1, (int[]){4});
    ut_free(product);
    expect_close(view->data[3], 154.f, 0.00001f);
    ut_free_all(view, gradient, target, probability, b, a);
    puts("utensil CPU: matrix product, softmax, MSE gradient and view lifetime passed");
    return 0;
}
