/* chunks.h -- 64 KB-aligned chunks with a header, a hash set of chunk bases, slab allocation.
 * Used by every representation except cur_range (rep_cur_chunkhdr, rep_tv_*).
 *
 * A chunk is a run of 1 or more 64 KB blocks; the first 64 bytes of its first block are the header (struct Chunk),
 * the issued cells follow.  An address that is KNOWN to be a cell of a normal (single-block) chunk finds its header by
 * masking: (Chunk *)((uintptr_t)p & CHUNK_MASK).  An ARBITRARY address first goes through the hash set of block bases
 * (every block base of every chunk, including the later blocks of an oversized chunk, maps to the chunk's header).
 */
#ifndef TV_CHUNKS_H
#define TV_CHUNKS_H

#include "common.h"

#define CHUNK_SHIFT 16
#define CHUNK_BYTES ((size_t)1 << CHUNK_SHIFT)
#define CHUNK_HDR ((size_t)64)
#define CHUNK_MASK (~(uintptr_t)(CHUNK_BYTES - 1))
#define SLAB_BLOCKS 64 /* 4 MB slabs of single blocks */

enum { CK_CELLS = 1, CK_RECORDS = 2, CK_RAW = 3, CK_STREAM = 4 }; /* CK_STREAM: records and raw blocks interleaved (tv_word) */

typedef struct Chunk {
    int kind;       /* CK_CELLS (typed cells), CK_RECORDS (tagged records), CK_RAW (dense run), CK_STREAM (mixed bump stream) */
    int type;       /* element type for CK_CELLS / CK_RAW, 0 for CK_RECORDS */
    size_t stride;  /* cell / record / element size in bytes */
    size_t used;    /* cells issued */
    size_t cap;     /* cells that fit */
    char *data;     /* first cell */
    uint64_t *mark; /* per-cell mark bits, allocated by gc_mark only */
    size_t nblocks; /* 64 KB blocks of this chunk */
    size_t hdr;     /* bytes before the first cell: the header, plus a record-start bitmap in rep_tv_packed */
} Chunk;

typedef char chunk_header_fits_64_bytes[(sizeof(Chunk) <= CHUNK_HDR) ? 1 : -1];

typedef struct ChunkSet {
    PtrMap bases;          /* block base -> Chunk * */
    void **raw;            /* malloc'd areas, freed with the set */
    size_t nraw;
    size_t capraw;
    char *slab;            /* next free aligned block of the current slab */
    size_t slab_left;
    Chunk **all;           /* every chunk, creation order */
    size_t nall;
    size_t capall;
} ChunkSet;

static inline void cs_init(ChunkSet *cs)
{
    memset(cs, 0, sizeof(*cs));
    map_init(&cs->bases, 64);
}

static inline void cs_keep(ChunkSet *cs, void *raw)
{
    if (cs->nraw == cs->capraw) {
        cs->capraw = cs->capraw ? cs->capraw * 2 : 16;
        cs->raw = (void **)xrealloc(cs->raw, cs->capraw * sizeof(void *));
    }
    cs->raw[cs->nraw++] = raw;
}

static inline void cs_free(ChunkSet *cs)
{
    size_t i;
    for (i = 0; i < cs->nraw; i++) {
        free(cs->raw[i]);
    }
    free(cs->raw);
    free(cs->all);
    map_free(&cs->bases);
    memset(cs, 0, sizeof(*cs));
}

/* nblocks consecutive 64 KB-aligned blocks */
static inline char *cs_blocks(ChunkSet *cs, size_t nblocks)
{
    char *raw;
    char *p;
    if (nblocks == 1) {
        if (cs->slab_left == 0) {
            raw = (char *)xmalloc((SLAB_BLOCKS + 1) * CHUNK_BYTES);
            cs_keep(cs, raw);
            cs->slab = (char *)(((uintptr_t)raw + CHUNK_BYTES - 1) & CHUNK_MASK);
            cs->slab_left = SLAB_BLOCKS;
        }
        p = cs->slab;
        cs->slab += CHUNK_BYTES;
        cs->slab_left--;
        return p;
    }
    raw = (char *)xmalloc((nblocks + 1) * CHUNK_BYTES);
    cs_keep(cs, raw);
    return (char *)(((uintptr_t)raw + CHUNK_BYTES - 1) & CHUNK_MASK);
}

/* a new chunk with room for at least min_cells cells (0: one normal block); hdr_bytes >= CHUNK_HDR before the first cell */
static inline Chunk *cs_new_chunk_hdr(ChunkSet *cs, int kind, int type, size_t stride, size_t min_cells, size_t hdr_bytes)
{
    size_t need = hdr_bytes + min_cells * stride;
    size_t nb = (need + CHUNK_BYTES - 1) >> CHUNK_SHIFT;
    char *blk;
    Chunk *c;
    size_t i;
    if (nb < 1) {
        nb = 1;
    }
    blk = cs_blocks(cs, nb);
    c = (Chunk *)blk;
    c->kind = kind;
    c->type = type;
    c->stride = stride;
    c->used = 0;
    c->cap = (nb * CHUNK_BYTES - hdr_bytes) / stride;
    c->data = blk + hdr_bytes;
    c->hdr = hdr_bytes;
    c->mark = NULL;
    c->nblocks = nb;
    for (i = 0; i < nb; i++) {
        map_put(&cs->bases, blk + i * CHUNK_BYTES, c);
    }
    if (cs->nall == cs->capall) {
        cs->capall = cs->capall ? cs->capall * 2 : 64;
        cs->all = (Chunk **)xrealloc(cs->all, cs->capall * sizeof(Chunk *));
    }
    cs->all[cs->nall++] = c;
    return c;
}

static inline Chunk *cs_new_chunk(ChunkSet *cs, int kind, int type, size_t stride, size_t min_cells)
{
    return cs_new_chunk_hdr(cs, kind, type, stride, min_cells, CHUNK_HDR);
}

/* header of a cell known to lie in the FIRST block of its chunk (every record and every typed cell does) */
static inline Chunk *cs_chunk_of(const void *p)
{
    return (Chunk *)((uintptr_t)p & CHUNK_MASK);
}

/* header of an arbitrary address: membership by the hash set of block bases, else NULL */
static inline Chunk *cs_lookup(const ChunkSet *cs, const void *p)
{
    return (Chunk *)map_get(&cs->bases, (const void *)((uintptr_t)p & CHUNK_MASK));
}

/* a pool issues cells of one kind/type/stride from a current chunk */
typedef struct CPool {
    int kind;
    int type;
    size_t stride;
    Chunk *cur;
} CPool;

static inline void cpool_init(CPool *p, int kind, int type, size_t stride)
{
    p->kind = kind;
    p->type = type;
    p->stride = stride;
    p->cur = NULL;
}

/* count consecutive cells; a run too long for a normal chunk gets a dedicated oversized chunk */
static inline void *cpool_take(ChunkSet *cs, CPool *p, size_t count)
{
    Chunk *c = p->cur;
    void *r;
    if (c == NULL || c->cap - c->used < count) {
        size_t normal = (CHUNK_BYTES - CHUNK_HDR) / p->stride;
        if (count > normal) {
            Chunk *d = cs_new_chunk(cs, p->kind, p->type, p->stride, count);
            d->used = count;
            return d->data;
        }
        c = cs_new_chunk(cs, p->kind, p->type, p->stride, 0);
        p->cur = c;
    }
    r = c->data + c->used * p->stride;
    c->used += count;
    return r;
}

/* Alignment of dense storage (slot arrays, Array data) in every tv_* representation: a cache line by default.  -DTV_RAW_ALIGN=8
 * (or -DTW_RAW_ALIGN / -DTA_RAW_ALIGN for the stream representations) gives the earlier, denser placement. */
#ifndef TV_RAW_ALIGN
#define TV_RAW_ALIGN 64
#endif

/* like cpool_take, but the run starts on a multiple of align_bytes (a multiple of the stride; chunk data is 64-aligned) */
static inline void *cpool_take_al(ChunkSet *cs, CPool *p, size_t count, size_t align_bytes)
{
    Chunk *c = p->cur;
    size_t pad = 0;
    void *r;
    if (c != NULL && align_bytes > p->stride) {
        pad = ((align_bytes - ((c->used * p->stride) % align_bytes)) % align_bytes) / p->stride;
    }
    if (c == NULL || c->cap - c->used < pad + count) {
        size_t normal = (CHUNK_BYTES - CHUNK_HDR) / p->stride;
        if (count > normal) {
            Chunk *d = cs_new_chunk(cs, p->kind, p->type, p->stride, count);
            d->used = count;
            return d->data;
        }
        c = cs_new_chunk(cs, p->kind, p->type, p->stride, 0);
        p->cur = c;
        pad = 0;
    }
    c->used += pad;
    r = c->data + c->used * p->stride;
    c->used += count;
    return r;
}

/* bit-per-cell mark maps for gc_mark (cells and records only; dense runs are marked through their descriptor) */
static inline void cs_gc_begin(ChunkSet *cs)
{
    size_t i;
    for (i = 0; i < cs->nall; i++) {
        Chunk *c = cs->all[i];
        if (c->kind != CK_RAW) {
            c->mark = (uint64_t *)xcalloc((c->used + 63) / 64 + 1, sizeof(uint64_t));
        }
    }
}

static inline void cs_gc_end(ChunkSet *cs)
{
    size_t i;
    for (i = 0; i < cs->nall; i++) {
        free(cs->all[i]->mark);
        cs->all[i]->mark = NULL;
    }
}

/* full live bytes of the chunked store: issued cells, chunk headers, the base hash set, the chunk list */
static inline size_t cs_bytes(const ChunkSet *cs)
{
    size_t i;
    size_t total = sizeof(*cs) + map_bytes(&cs->bases) + cs->capall * sizeof(Chunk *);
    for (i = 0; i < cs->nall; i++) {
        total += cs->all[i]->hdr + cs->all[i]->used * cs->all[i]->stride;
    }
    return total;
}

/* offset of p inside the issued cells of c, or (size_t)-1 when p is outside them */
static inline size_t chunk_offset(const Chunk *c, const void *p)
{
    uintptr_t a = (uintptr_t)p;
    uintptr_t lo = (uintptr_t)c->data;
    if (a < lo || a - lo >= c->used * c->stride) {
        return (size_t)-1;
    }
    return (size_t)(a - lo);
}

#endif /* TV_CHUNKS_H */
