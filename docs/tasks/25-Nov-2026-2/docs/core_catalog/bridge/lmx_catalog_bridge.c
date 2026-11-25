#include "lmx_catalog_bridge.h"
#include <string.h>

static int fail(lmx_catalog_frame *f, int status)
{
    if (f != NULL) f->status = status;
    return status;
}

int lmx_catalog_check(void *opaque, size_t arity)
{
    lmx_catalog_frame *f = (lmx_catalog_frame *)opaque;
    if (f == NULL) return LMXC_BAD_FRAME;
    /* The caller supplies a real live C frame; arbitrary addresses are never
     * accepted from L3. A magic/version cannot make an arbitrary pointer safe. */
    if (f->abi_version != 1 || f->owner == NULL ||
        (f->argument_count != 0 && f->arguments == NULL))
        return fail(f, LMXC_BAD_FRAME);
    memset(&f->result, 0, sizeof f->result);
    f->status = LMXC_OK;
    f->diagnostic_symbol = NULL;
    if (f->argument_count != arity) return fail(f, LMXC_ARITY);
    return LMXC_OK;
}

int lmx_catalog_review_required(void *opaque, const char *symbol)
{
    lmx_catalog_frame *f = (lmx_catalog_frame *)opaque;
    if (f == NULL) return LMXC_BAD_FRAME;
    f->diagnostic_symbol = symbol;
    memset(&f->result, 0, sizeof f->result);
    return fail(f, LMXC_REVIEW_REQUIRED);
}

static const lmx_catalog_slot *slot(lmx_catalog_frame *f, size_t i)
{
    if (f == NULL || f->abi_version != 1 || f->owner == NULL ||
        f->arguments == NULL) {
        fail(f, LMXC_BAD_FRAME); return NULL;
    }
    if (i >= f->argument_count) { fail(f, LMXC_ARITY); return NULL; }
    return &f->arguments[i];
}

int lmx_catalog_read_i64(lmx_catalog_frame *f, size_t i,
                         int64_t low, int64_t high, int64_t *out)
{
    const lmx_catalog_slot *s = slot(f, i);
    int64_t value;
    if (s == NULL) return f == NULL ? LMXC_BAD_FRAME : f->status;
    if (out == NULL || low > high) return fail(f, LMXC_BAD_FRAME);
    if (s->kind == LMXC_SIGNED) value = s->signed_value;
    else if (s->kind == LMXC_UNSIGNED) {
        if (s->unsigned_value > (uint64_t)INT64_MAX) return fail(f, LMXC_RANGE);
        value = (int64_t)s->unsigned_value;
    } else return fail(f, LMXC_TYPE);
    if (value < low || value > high) return fail(f, LMXC_RANGE);
    *out = value; return LMXC_OK;
}

int lmx_catalog_read_u64(lmx_catalog_frame *f, size_t i,
                         uint64_t high, uint64_t *out)
{
    const lmx_catalog_slot *s = slot(f, i);
    uint64_t value;
    if (s == NULL) return f == NULL ? LMXC_BAD_FRAME : f->status;
    if (out == NULL) return fail(f, LMXC_BAD_FRAME);
    if (s->kind == LMXC_UNSIGNED) value = s->unsigned_value;
    else if (s->kind == LMXC_SIGNED) {
        if (s->signed_value < 0) return fail(f, LMXC_RANGE);
        value = (uint64_t)s->signed_value;
    } else return fail(f, LMXC_TYPE);
    if (value > high) return fail(f, LMXC_RANGE);
    *out = value; return LMXC_OK;
}

int lmx_catalog_read_int(lmx_catalog_frame *f, size_t i, int *out)
{
    int64_t x; int rc;
    if (out == NULL) return fail(f, LMXC_BAD_FRAME);
    rc = lmx_catalog_read_i64(f, i, INT_MIN, INT_MAX, &x);
    if (rc == LMXC_OK) *out = (int)x;
    return rc;
}

int lmx_catalog_read_uint(lmx_catalog_frame *f, size_t i, unsigned int *out)
{
    uint64_t x; int rc;
    if (out == NULL) return fail(f, LMXC_BAD_FRAME);
    rc = lmx_catalog_read_u64(f, i, UINT_MAX, &x);
    if (rc == LMXC_OK) *out = (unsigned int)x;
    return rc;
}

int lmx_catalog_read_ulong(lmx_catalog_frame *f, size_t i, unsigned long *out)
{
    uint64_t x; int rc;
    if (out == NULL) return fail(f, LMXC_BAD_FRAME);
    rc = lmx_catalog_read_u64(f, i, ULONG_MAX, &x);
    if (rc == LMXC_OK) *out = (unsigned long)x;
    return rc;
}

int lmx_catalog_read_size(lmx_catalog_frame *f, size_t i, size_t *out)
{
    uint64_t x; int rc;
    if (out == NULL) return fail(f, LMXC_BAD_FRAME);
    rc = lmx_catalog_read_u64(f, i, SIZE_MAX, &x);
    if (rc == LMXC_OK) *out = (size_t)x;
    return rc;
}

int lmx_catalog_read_double(lmx_catalog_frame *f, size_t i, double *out)
{
    const lmx_catalog_slot *s = slot(f, i);
    if (s == NULL) return f == NULL ? LMXC_BAD_FRAME : f->status;
    if (out == NULL) return fail(f, LMXC_BAD_FRAME);
    if (s->kind != LMXC_REAL) return fail(f, LMXC_TYPE);
    /* NaN/infinity/domain/rounding are per-operation policy, not hidden here. */
    *out = s->real_value; return LMXC_OK;
}

static int lease(lmx_catalog_frame *f, const void *owner,
                 const uint64_t *live, uint64_t borrowed)
{
    if (owner != f->owner) return fail(f, LMXC_OWNER);
    if (live == NULL || *live != borrowed) return fail(f, LMXC_EXPIRED);
    return LMXC_OK;
}

int lmx_catalog_read_span(lmx_catalog_frame *f, size_t i, size_t needed,
                          size_t align, int write, void **out)
{
    const lmx_catalog_slot *s = slot(f, i);
    const lmx_catalog_span *p; int rc;
    if (s == NULL) return f == NULL ? LMXC_BAD_FRAME : f->status;
    if (out == NULL || align == 0) return fail(f, LMXC_BAD_FRAME);
    if (s->kind != LMXC_SPAN) return fail(f, LMXC_TYPE);
    p = &s->span;
    rc = lease(f, p->owner, p->live_generation, p->borrowed_generation);
    if (rc != LMXC_OK) return rc;
    if (needed > p->length_bytes || (p->length_bytes != 0 && p->bytes == NULL))
        return fail(f, LMXC_LENGTH);
    if (write && !p->writable) return fail(f, LMXC_READ_ONLY);
    if (p->alignment < align || (p->bytes != NULL && (uintptr_t)p->bytes % align))
        return fail(f, LMXC_ALIGNMENT);
    *out = p->bytes; return LMXC_OK;
}

int lmx_catalog_read_cstring(lmx_catalog_frame *f, size_t i, const char **out)
{
    const lmx_catalog_slot *s; void *p; int rc;
    if (out == NULL) return fail(f, LMXC_BAD_FRAME);
    rc = lmx_catalog_read_span(f, i, 1, 1, 0, &p);
    if (rc != LMXC_OK) return rc;
    s = &f->arguments[i];
    if (((const char *)p)[s->span.length_bytes - 1] != '\0') return fail(f, LMXC_LENGTH);
    if (memchr(p, '\0', s->span.length_bytes - 1) != NULL)
        return fail(f, LMXC_EMBEDDED_NUL);
    *out = (const char *)p; return LMXC_OK;
}

int lmx_catalog_read_resource(lmx_catalog_frame *f, size_t i,
                              const char *native_type, void **out)
{
    const lmx_catalog_slot *s = slot(f, i); int rc;
    if (s == NULL) return f == NULL ? LMXC_BAD_FRAME : f->status;
    if (native_type == NULL || out == NULL) return fail(f, LMXC_BAD_FRAME);
    if (s->kind != LMXC_RESOURCE) return fail(f, LMXC_TYPE);
    rc = lease(f, s->resource.owner, s->resource.live_generation,
               s->resource.borrowed_generation);
    if (rc != LMXC_OK) return rc;
    if (s->resource.native_type == NULL || strcmp(s->resource.native_type, native_type))
        return fail(f, LMXC_TYPE);
    if (s->resource.native == NULL) return fail(f, LMXC_EXPIRED);
    *out = s->resource.native; return LMXC_OK;
}

int lmx_catalog_write_i64(lmx_catalog_frame *f, int64_t x)
{
    if (f == NULL) return LMXC_BAD_FRAME;
    memset(&f->result, 0, sizeof f->result);
    f->result.kind = LMXC_SIGNED; f->result.signed_value = x;
    return fail(f, LMXC_OK);
}
int lmx_catalog_write_u64(lmx_catalog_frame *f, uint64_t x)
{
    if (f == NULL) return LMXC_BAD_FRAME;
    memset(&f->result, 0, sizeof f->result);
    f->result.kind = LMXC_UNSIGNED; f->result.unsigned_value = x;
    return fail(f, LMXC_OK);
}
int lmx_catalog_write_real(lmx_catalog_frame *f, double x)
{
    if (f == NULL) return LMXC_BAD_FRAME;
    memset(&f->result, 0, sizeof f->result);
    f->result.kind = LMXC_REAL; f->result.real_value = x;
    return fail(f, LMXC_OK);
}
int lmx_catalog_write_none(lmx_catalog_frame *f)
{
    if (f == NULL) return LMXC_BAD_FRAME;
    memset(&f->result, 0, sizeof f->result);
    return fail(f, LMXC_OK);
}
