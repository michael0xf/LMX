# Shared Trace in both LMX styles

The [procedural source](../examples/lmx/procedural/084_execute_around.lm3) includes the complete local Around helper. The [functional source](../examples/lmx/084_execute_around.lm3) calls the shared bracket implementation. Both sources reuse one Trace\eval and one Trace\code, preserve dynamic binding, and are fully included in their separate comparison columns.

The success/action-failure/acquisition-failure observations remain42123/−123/−1. No source is discarded by choosing the shorter style. The comparison does not add a second implementation of the kernel; the procedural helper is the complete direct client approach and the shared generic implementation stays in098. Runtime LMX: NOT_RUN.
