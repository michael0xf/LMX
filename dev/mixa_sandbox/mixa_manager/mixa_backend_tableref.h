#ifndef MIXA_BACKEND_TABLEREF_H
#define MIXA_BACKEND_TABLEREF_H
/* Conscious C remnant (L1 open point 10.13): const-qualified pointer alias.
 * Forward-declare the vtable tag so this header can be #include'd from the
 * generated mixa_backend.lm1.h BEFORE the struct body is emitted (l1trans
 * emits include: lines before struct: bodies).
 */
typedef struct MixaBackendVTable MixaBackendVTable;
typedef const MixaBackendVTable *MixaBackendTableRef;
#endif