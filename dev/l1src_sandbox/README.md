# Dev P0 parser

> Superseded semantic target (author correction 2026-09-23): the implementation and measurements below describe the earlier P0 tree, not the accepted normal form. `f()`, `f: ()`, and explicitly closed `f:` + `---` must yield one empty Frame-body in P0. The sole anonymous whole-list Structure is normalized in P0 also when nonempty. Bare `f:` remains invalid. See `next_parser_fix.md`.

`parser.lm1` is a development copy of the stable `l1src/parser.lm1`, whose initial SHA-256 was `431fa51e26502c38f25bdc043ae1478e35ab236a40df65171170a3e7990eea65`. Stable sources and Grok's `dev/l2src_sandbox` are not modified by this change.

## Empty vertical argument

When a source-level delimiter closes an empty colon body, `lm_p0_stream_resolve_pending_delimiter` appends one empty Structure argument **before** discarding the body's stack owner. This covers ordinary Frames and colon trailers. It does not remove the subsequent missing-argument validator or manufacture arguments for a bare colon at EOF or before a semicolon/closing parenthesis.

Both forms have the same P0 tree:

```text
receiver:
---
receiver: ()
```

```text
structure fields=2
  frame head="receiver" body=structure fields=1
    structure fields=0
  frame head="receiver" body=structure fields=1
    structure fields=0
```

## Build and verify

Run from the LMX repository root, supplying an existing L1 translator and GCC on PATH:

```text
python tools/build_parser_dev.py --translator C:/Nyasha_Planet/L1/bin/l1trans.exe
python tools/run_parser.py --parser dev/l1src_sandbox/build/printTree.exe --profile current --output dev/l1src_sandbox/build/current
python tools/run_parser.py --parser dev/l1src_sandbox/build/printTree.exe --profile previous-l1 --output dev/l1src_sandbox/build/previous-l1
```

`printTree.lm1` explicitly imports this dev parser. L1 `predef` embeds source dependencies into generated C; compiling the stable `l1src/printTree.lm1` would silently embed the stable parser instead, regardless of an adjacent generated parser C file. The dev driver is therefore part of the build, not interchangeable with the stable one.

The builder generates the header and native C, records source/translator hashes in `build/build.json`, then compiles using C99 with pointer/type/declaration hard-error flags. Existing unused-parameter warnings are not hidden. It does not install a compiler, replace stable executables or update the unfinished L2 parser port. Consumers must select the dev parser source or this dev `printTree` explicitly.

Verified 2026-09-23: **27/27 current cases** (P0 sole-container / nextMessage / mystruct parity fixtures included, renamed `receiveMessage` by Sonnet -166); **previous-l1: 131 passed (9 diverged as recorded), 0 failed** — 122 byte matches to imported goldens plus 9 explicit divergences under `tests/parser/previous-l1/`. Before the fix, the two initial current cases gave 1 pass / 1 failure. Imported goldens were not changed. Reports and stdout/stderr are under the ignored `build/` directory.
