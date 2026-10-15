/* graph_p0_method_order_oracle.c -- standalone C99 helper: P0 structural-event oracle.
 *
 * Parses ONE source file with the CURRENT P0 API (lm_p0_parse_file(path, &document); no thread
 * argument; NOT the archived 620 ABI) and emits deterministic, length-prefixed, source-order
 * structural events for the whole P0 tree:
 *   - every field slot of every Structure, in chain order, including null slots;
 *   - every Structure node, named or anonymous (a parenthesised expression such as `(2 + 2)`
 *     is an anonymous Structure field and is emitted like any other field);
 *   - every Frame node: head spelling, frame flags, body fields, the body's own trailer, then
 *     the Frame's trailer;
 *   - every atom and disabled atom with its spelling;
 *   - every trailer (`return`, `end:`, `until:`, dash cutters ...) with its flags and its body,
 *     so the tail that P0 stores after a `return` trailer is emitted as trailer-body fields.
 * Nothing is dropped, merged, reordered, interpreted or matched against fixture-specific words.
 * The source is never replayed by lines: only P0-owned spellings (frame heads, atom texts,
 * trailer spellings) appear, each next to its P0 span.
 *
 * SCOPE NOTE: this helper only reports what the P0 tree holds.  Mapping these P0 events to the
 * materialized Lmx graph (the harness graph rows) is a later, separate step.  This file alone
 * does not complete G1.
 *
 * Usage:   graph_p0_method_order_oracle <source-file> [output-file]
 *   Output goes to stdout, or to <output-file> opened in binary mode ("wb") for exact bytes.
 *   On a Windows text-mode stdout the C runtime turns "\n" into "\r\n"; record lengths never
 *   count the line terminator, so a consumer may strip "\r".
 * Exit:    0 accepted and dumped;  1 the parser rejected the input (a `reject` record is
 *          emitted);  2 usage error or output failure.
 *
 * Record format: one record per line,
 *     <N>:<payload>\n
 * where N is the decimal byte length of <payload> (terminator excluded).  Inside a payload a
 * text item is written as <len>=<escaped>, where len is the byte length of the P0 text and
 * <escaped> keeps bytes 0x20..0x7E as themselves except '\' which becomes "\\"; every other
 * byte becomes "\xHH" (uppercase).  A null text pointer is written "null".  A text item is
 * always the LAST item of its record, so a consumer may read it either by decoding len bytes
 * or by taking the rest of the record.  Numbers are decimal; flags are 0x-prefixed uppercase
 * hex.  depth = nesting depth (root node 0); index = 0-based position among sibling fields.
 *
 * Records:
 *   p0-events 1
 *   document source_length=<n> root=<kind|null>
 *   structure depth=<d> index=<i> flags=<hex> span=<line>:<column>+<offset>:<length>
 *             fields=<field_count> trailer=<0|1>
 *   end-structure depth=<d> index=<i> walked=<n>
 *   frame depth=<d> index=<i> flags=<hex> frame_flags=<hex> colon=<0|1> span=...
 *         body=<0|1> body_fields=<n> body_trailer=<0|1> trailer=<0|1> head=<text>
 *   end-frame depth=<d> index=<i> walked=<n>
 *   atom depth=<d> index=<i> flags=<hex> span=... text=<text>
 *   disabled depth=<d> index=<i> flags=<hex> span=... text=<text>
 *   null-field depth=<d> index=<i>
 *   node depth=<d> index=<i> kind=<name> kind_code=<n> flags=<hex> span=... as=null | unknown
 *   trailer depth=<d> of=<structure|frame-body|frame|trailer-body> flags=<hex> colon=<0|1>
 *           body=<0|1> body_fields=<n> body_trailer=<0|1> spelling=<text>
 *   end-trailer depth=<d> of=<owner> walked=<n>
 *   end-document
 *   reject code=<n> line=<n> column=<n> message=<text>
 *   reject code=<n> document=null
 * `walked` is the number of field slots actually visited in the chain; `fields` is the stored
 * field_count.  The helper reports both and decides nothing.  `span=null` marks a null span.
 * A Structure or Frame node whose typed pointer is missing ends its record with
 * `structure=null` or `frame=null` and has no children.
 *
 * Compile/link (from the repository root; current ABI; no external libraries):
 *   gcc -std=c99 -Wall -Wextra -I lm1/build -o <out>
 *       dev/l2src_sandbox/tests/graph_p0_method_order_oracle.c lm1/build/parser.lm1.c
 * lm1/build/parser.lm1.c is the l1trans output that already contains own; do not also link
 * own.lm1.c.  "l1src/p0.lm1.h" is the l1trans output of l1src/p0.h.lm1, the same header that
 * parser.lm1.c itself includes, so both translation units see one struct layout.  Struct members
 * read directly here because no accessor exists for them: LmP0Structure.first_field /
 * .field_count, LmP0Field.value / .next, LmP0Node.kind / .flags / .span / .as (null check
 * only), LmP0Span.*, LmP0Text.data / .length, LmP0Frame.flags, LmP0Trailer.flags,
 * LmP0Document.source_length, LmP0Diagnostic.*.  Everything else goes through lm_p0_* accessors.
 * Recursion depth equals the P0 nesting depth of the input.
 */
#include "l1src/p0.lm1.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static const char HEX_DIGITS[] = "0123456789ABCDEF";

/* ---- growable record buffer ---------------------------------------------------------- */

typedef struct Buf {
    char *data;
    size_t length;
    size_t capacity;
    int failed;
} Buf;

static void buf_reserve(Buf *b, size_t extra)
{
    size_t need;
    size_t cap;
    char *grown;
    if (b->failed) {
        return;
    }
    if (b->length >= (size_t)-1 || extra > (size_t)-1 - b->length - 1U) {
        b->failed = 1;
        return;
    }
    need = b->length + extra + 1U;
    if (need <= b->capacity) {
        return;
    }
    cap = b->capacity != 0U ? b->capacity : 256U;
    while (cap < need) {
        if (cap > (size_t)-1 / 2U) {
            cap = need;
            break;
        }
        cap = cap * 2U;
    }
    grown = (char *)realloc(b->data, cap);
    if (grown == 0) {
        b->failed = 1;
        return;
    }
    b->data = grown;
    b->capacity = cap;
}

static void buf_putc(Buf *b, char c)
{
    buf_reserve(b, 1U);
    if (b->failed) {
        return;
    }
    b->data[b->length] = c;
    b->length = b->length + 1U;
}

static void buf_puts(Buf *b, const char *s)
{
    size_t n = strlen(s);
    buf_reserve(b, n);
    if (b->failed) {
        return;
    }
    memcpy(b->data + b->length, s, n);
    b->length = b->length + n;
}

/* Decimal digits of v into dst (no terminator); returns the digit count.  dst needs 21 bytes. */
static size_t format_uint(char *dst, unsigned long long v)
{
    char tmp[32];
    size_t n = 0U;
    size_t i;
    do {
        tmp[n] = (char)('0' + (int)(v % 10U));
        n = n + 1U;
        v = v / 10U;
    } while (v != 0U);
    for (i = 0U; i < n; i++) {
        dst[i] = tmp[n - 1U - i];
    }
    return n;
}

static void buf_put_uint(Buf *b, unsigned long long v)
{
    char digits[32];
    size_t n = format_uint(digits, v);
    size_t i;
    for (i = 0U; i < n; i++) {
        buf_putc(b, digits[i]);
    }
}

static void buf_put_hex(Buf *b, unsigned v)
{
    char tmp[16];
    size_t n = 0U;
    do {
        tmp[n] = HEX_DIGITS[v & 15U];
        n = n + 1U;
        v = v >> 4;
    } while (v != 0U);
    buf_puts(b, "0x");
    while (n > 0U) {
        n = n - 1U;
        buf_putc(b, tmp[n]);
    }
}

static void buf_put_key_uint(Buf *b, const char *key, unsigned long long v)
{
    buf_putc(b, ' ');
    buf_puts(b, key);
    buf_putc(b, '=');
    buf_put_uint(b, v);
}

static void buf_put_key_hex(Buf *b, const char *key, unsigned v)
{
    buf_putc(b, ' ');
    buf_puts(b, key);
    buf_putc(b, '=');
    buf_put_hex(b, v);
}

static void buf_put_key_str(Buf *b, const char *key, const char *value)
{
    buf_putc(b, ' ');
    buf_puts(b, key);
    buf_putc(b, '=');
    buf_puts(b, value);
}

/* <len>=<escaped> or null.  Must be the last item of its record. */
static void buf_put_key_text(Buf *b, const char *key, const LmP0Text *t)
{
    size_t i;
    buf_putc(b, ' ');
    buf_puts(b, key);
    buf_putc(b, '=');
    if (t == 0 || t->data == 0) {
        buf_puts(b, "null");
        return;
    }
    buf_put_uint(b, (unsigned long long)t->length);
    buf_putc(b, '=');
    for (i = 0U; i < t->length; i++) {
        unsigned char c = (unsigned char)t->data[i];
        if (c == (unsigned char)'\\') {
            buf_puts(b, "\\\\");
        } else if (c >= 0x20 && c <= 0x7E) {
            buf_putc(b, (char)c);
        } else {
            buf_puts(b, "\\x");
            buf_putc(b, HEX_DIGITS[(c >> 4) & 15U]);
            buf_putc(b, HEX_DIGITS[c & 15U]);
        }
    }
}

static void buf_put_span(Buf *b, const LmP0Span *s)
{
    buf_puts(b, " span=");
    if (s == 0) {
        buf_puts(b, "null");
        return;
    }
    buf_put_uint(b, (unsigned long long)s->line);
    buf_putc(b, ':');
    buf_put_uint(b, (unsigned long long)s->column);
    buf_putc(b, '+');
    buf_put_uint(b, (unsigned long long)s->offset);
    buf_putc(b, ':');
    buf_put_uint(b, (unsigned long long)s->length);
}

/* ---- record emitter ------------------------------------------------------------------ */

typedef struct Emitter {
    FILE *out;
    Buf rec;
    int failed;
} Emitter;

static void rec_begin(Emitter *e, const char *tag)
{
    e->rec.length = 0U;
    buf_puts(&e->rec, tag);
}

static void rec_end(Emitter *e)
{
    char prefix[32];
    size_t n;
    if (e->failed) {
        return;
    }
    if (e->rec.failed) {
        e->failed = 1;
        return;
    }
    n = format_uint(prefix, (unsigned long long)e->rec.length);
    prefix[n] = ':';
    n = n + 1U;
    if (fwrite(prefix, 1U, n, e->out) != n) {
        e->failed = 1;
        return;
    }
    if (e->rec.length != 0U && fwrite(e->rec.data, 1U, e->rec.length, e->out) != e->rec.length) {
        e->failed = 1;
        return;
    }
    if (fputc('\n', e->out) == EOF) {
        e->failed = 1;
    }
}

static void rec_place(Emitter *e, size_t depth, size_t index)
{
    buf_put_key_uint(&e->rec, "depth", (unsigned long long)depth);
    buf_put_key_uint(&e->rec, "index", (unsigned long long)index);
}

/* ---- tree walk ----------------------------------------------------------------------- */

static void emit_node(Emitter *e, const LmP0Node *node, size_t depth, size_t index);
static size_t emit_structure_contents(Emitter *e, const LmP0Structure *st, size_t depth, const char *owner);

static void emit_trailer(Emitter *e, const LmP0Trailer *tr, size_t depth, const char *owner)
{
    const LmP0Structure *body = lm_p0_trailer_body(tr);
    size_t walked = 0U;
    rec_begin(e, "trailer");
    buf_put_key_uint(&e->rec, "depth", (unsigned long long)depth);
    buf_put_key_str(&e->rec, "of", owner);
    buf_put_key_hex(&e->rec, "flags", tr->flags);
    buf_put_key_uint(&e->rec, "colon", (tr->flags & LM_P0_TRAILER_COLON) != 0U ? 1U : 0U);
    buf_put_key_uint(&e->rec, "body", body != 0 ? 1U : 0U);
    buf_put_key_uint(&e->rec, "body_fields", body != 0 ? (unsigned long long)body->field_count : 0U);
    buf_put_key_uint(&e->rec, "body_trailer", (body != 0 && lm_p0_structure_trailer(body) != 0) ? 1U : 0U);
    buf_put_key_text(&e->rec, "spelling", lm_p0_trailer_spelling(tr));
    rec_end(e);
    if (body != 0) {
        walked = emit_structure_contents(e, body, depth + 1U, "trailer-body");
    }
    rec_begin(e, "end-trailer");
    buf_put_key_uint(&e->rec, "depth", (unsigned long long)depth);
    buf_put_key_str(&e->rec, "of", owner);
    buf_put_key_uint(&e->rec, "walked", (unsigned long long)walked);
    rec_end(e);
}

/* Fields in chain order, then the Structure's own trailer.  Returns the number of slots visited. */
static size_t emit_structure_contents(Emitter *e, const LmP0Structure *st, size_t depth, const char *owner)
{
    const LmP0Field *f = st->first_field;
    const LmP0Trailer *tr;
    size_t i = 0U;
    while (f != 0) {
        emit_node(e, f->value, depth, i);
        f = f->next;
        i = i + 1U;
    }
    tr = lm_p0_structure_trailer(st);
    if (tr != 0) {
        emit_trailer(e, tr, depth, owner);
    }
    return i;
}

static void emit_node(Emitter *e, const LmP0Node *node, size_t depth, size_t index)
{
    const char *name;
    if (node == 0) {
        rec_begin(e, "null-field");
        rec_place(e, depth, index);
        rec_end(e);
        return;
    }
    name = lm_p0_node_kind_class_name(node->kind);
    if (node->as == 0) {
        rec_begin(e, "node");
        rec_place(e, depth, index);
        buf_put_key_str(&e->rec, "kind", name);
        buf_put_key_uint(&e->rec, "kind_code", (unsigned long long)node->kind);
        buf_put_key_hex(&e->rec, "flags", node->flags);
        buf_put_span(&e->rec, node->span);
        buf_put_key_str(&e->rec, "as", "null");
        rec_end(e);
        return;
    }
    if (node->kind == LM_P0_NODE_STRUCTURE) {
        const LmP0Structure *st = lm_p0_node_structure(node);
        size_t walked = 0U;
        rec_begin(e, "structure");
        rec_place(e, depth, index);
        buf_put_key_hex(&e->rec, "flags", node->flags);
        buf_put_span(&e->rec, node->span);
        if (st == 0) {
            buf_put_key_str(&e->rec, "structure", "null");
            rec_end(e);
            return;
        }
        buf_put_key_uint(&e->rec, "fields", (unsigned long long)st->field_count);
        buf_put_key_uint(&e->rec, "trailer", lm_p0_structure_trailer(st) != 0 ? 1U : 0U);
        rec_end(e);
        walked = emit_structure_contents(e, st, depth + 1U, "structure");
        rec_begin(e, "end-structure");
        rec_place(e, depth, index);
        buf_put_key_uint(&e->rec, "walked", (unsigned long long)walked);
        rec_end(e);
        return;
    }
    if (node->kind == LM_P0_NODE_FRAME) {
        const LmP0Frame *fr = lm_p0_node_frame(node);
        const LmP0Structure *body;
        const LmP0Trailer *tr;
        size_t walked = 0U;
        rec_begin(e, "frame");
        rec_place(e, depth, index);
        buf_put_key_hex(&e->rec, "flags", node->flags);
        if (fr == 0) {
            buf_put_span(&e->rec, node->span);
            buf_put_key_str(&e->rec, "frame", "null");
            rec_end(e);
            return;
        }
        body = lm_p0_frame_body(fr);
        tr = lm_p0_frame_trailer(fr);
        buf_put_key_hex(&e->rec, "frame_flags", fr->flags);
        buf_put_key_uint(&e->rec, "colon", (fr->flags & LM_P0_FRAME_COLON) != 0U ? 1U : 0U);
        buf_put_span(&e->rec, node->span);
        buf_put_key_uint(&e->rec, "body", body != 0 ? 1U : 0U);
        buf_put_key_uint(&e->rec, "body_fields", body != 0 ? (unsigned long long)body->field_count : 0U);
        buf_put_key_uint(&e->rec, "body_trailer", (body != 0 && lm_p0_structure_trailer(body) != 0) ? 1U : 0U);
        buf_put_key_uint(&e->rec, "trailer", tr != 0 ? 1U : 0U);
        buf_put_key_text(&e->rec, "head", lm_p0_frame_head(fr));
        rec_end(e);
        if (body != 0) {
            walked = emit_structure_contents(e, body, depth + 1U, "frame-body");
        }
        if (tr != 0) {
            emit_trailer(e, tr, depth + 1U, "frame");
        }
        rec_begin(e, "end-frame");
        rec_place(e, depth, index);
        buf_put_key_uint(&e->rec, "walked", (unsigned long long)walked);
        rec_end(e);
        return;
    }
    if (node->kind == LM_P0_NODE_ATOM || node->kind == LM_P0_NODE_DISABLED) {
        rec_begin(e, name);
        rec_place(e, depth, index);
        buf_put_key_hex(&e->rec, "flags", node->flags);
        buf_put_span(&e->rec, node->span);
        buf_put_key_text(&e->rec, "text", lm_p0_node_atom(node));
        rec_end(e);
        return;
    }
    rec_begin(e, "node");
    rec_place(e, depth, index);
    buf_put_key_str(&e->rec, "kind", name);
    buf_put_key_uint(&e->rec, "kind_code", (unsigned long long)node->kind);
    buf_put_key_hex(&e->rec, "flags", node->flags);
    buf_put_span(&e->rec, node->span);
    rec_end(e);
}

/* ---- driver -------------------------------------------------------------------------- */

static void emit_reject(Emitter *e, int status, const LmP0Diagnostic *diag)
{
    rec_begin(e, "reject");
    if (diag == 0) {
        buf_put_key_uint(&e->rec, "code", (unsigned long long)status);
        buf_put_key_str(&e->rec, "document", "null");
        rec_end(e);
        return;
    }
    {
        LmP0Text message;
        size_t n = 0U;
        while (n < sizeof(diag->message) && diag->message[n] != '\0') {
            n = n + 1U;
        }
        message.data = diag->message;
        message.length = n;
        buf_put_key_uint(&e->rec, "code", (unsigned long long)diag->code);
        buf_put_key_uint(&e->rec, "line", (unsigned long long)diag->line);
        buf_put_key_uint(&e->rec, "column", (unsigned long long)diag->column);
        buf_put_key_text(&e->rec, "message", &message);
    }
    rec_end(e);
}

int main(int argc, char **argv)
{
    Emitter e;
    LmP0Document *doc = 0;
    int status;
    int rc;
    if (argc != 2 && argc != 3) {
        fputs("usage: graph_p0_method_order_oracle <source-file> [output-file]\n", stderr);
        return 2;
    }
    memset(&e, 0, sizeof(e));
    e.out = stdout;
    if (argc == 3) {
        e.out = fopen(argv[2], "wb");
        if (e.out == 0) {
            fputs("graph_p0_method_order_oracle: cannot open output file\n", stderr);
            return 2;
        }
    }
    status = lm_p0_parse_file(argv[1], &doc);
    rec_begin(&e, "p0-events 1");
    rec_end(&e);
    if (status != 0) {
        emit_reject(&e, status, lm_p0_document_diagnostic(doc));
        rc = 1;
    } else {
        const LmP0Node *root = lm_p0_document_root(doc);
        rec_begin(&e, "document");
        buf_put_key_uint(&e.rec, "source_length", doc != 0 ? (unsigned long long)doc->source_length : 0U);
        buf_put_key_str(&e.rec, "root", root != 0 ? lm_p0_node_kind_class_name(root->kind) : "null");
        rec_end(&e);
        if (root != 0) {
            emit_node(&e, root, 0U, 0U);
        }
        rec_begin(&e, "end-document");
        rec_end(&e);
        rc = 0;
    }
    if (doc != 0) {
        lm_p0_document_destroy(doc);
    }
    if (e.out != stdout) {
        if (fclose(e.out) != 0) {
            e.failed = 1;
        }
    } else if (fflush(stdout) != 0) {
        e.failed = 1;
    }
    free(e.rec.data);
    if (e.failed) {
        fputs("graph_p0_method_order_oracle: output failed\n", stderr);
        return 2;
    }
    return rc;
}
