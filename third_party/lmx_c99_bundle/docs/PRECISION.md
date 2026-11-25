# Arbitrary precision libraries

This profile contains **LibTomMath 1.3.0** and **MPDecimal 4.0.1**. Their complete
upstream source archives, configuration scripts, documentation sources, and
examples remain under `vendor/libtommath` and `vendor/mpdecimal`. CMake builds
the C libraries as static targets, without downloading anything during configure
or build. C++ wrappers, assembly files, benchmark programs, and other native
build configurations are retained as upstream reference material.

## Versions, origins, licenses

| Library | Selection | Original source | License |
|---|---|---|---|
| LibTomMath | User-pinned `v1.3.0` | <https://github.com/libtom/libtommath/tree/v1.3.0> | Unlicense; full text in `vendor/libtommath/LICENSE` |
| MPDecimal/libmpdec | Official stable 4.0.1, released 2025-05-05 | <https://www.bytereef.org/mpdecimal/download.html> | BSD-2-Clause; full text in `vendor/mpdecimal/COPYRIGHT.txt` |

The MPDecimal archive SHA-256 matches the publisher's download page:
`96d33abb4bb0070c7be0fed4246cd38416188325f820468214471938545b1ac8`.
LibTomMath archive SHA-256 is locally recorded as
`6d099e93ff00fa9b18346f4bcd97dcc48c3e91286f7e16c4ac5515a7171c3149`.
The per-file hashes and exact download URLs are recorded in the two corresponding
`provenance/*.json` files. Upstream source files are not modified in place.

## Public CMake targets

```cmake
target_link_libraries(my_app PRIVATE LMX::tommath)   # tommath.h
target_link_libraries(my_app PRIVATE LMX::mpdec)     # generated mpdecimal.h
target_link_libraries(my_app PRIVATE LMX::precision) # both
```

Link the targets instead of copying include paths or defining implementation
macros in application headers. The targets propagate the required public ABI
configuration and generated header directory. Both libraries can coexist with
decNumber: they use distinct symbols and distinct number/context types. Objects
from these APIs must not be reinterpreted as each other; explicit decimal strings
are one available interchange representation.

On POSIX the only link dependency of this group is the system math library.
LibTomMath retains its platform entropy implementation for its random-number API:
for example, Linux `getrandom` and the `/dev/urandom` fallback. This is not an extra
third-party library. Applications may supply a source with `mp_rand_source`.

## C99 profile and the generated MPDecimal header

LibTomMath is compiled with **`MP_32BIT`**, exported to its consumers. This selects
28 significant bits in each `uint32_t` digit and a `uint64_t` intermediate word.
The upstream automatic 64-bit digit mode relies on a compiler-specific 128-bit
type. The selected mode preserves the portable integer implementation on both
32-bit and 64-bit targets. It is an ABI choice: do not compile a consumer with a
conflicting `MP_64BIT` setting or mix a separately built LibTomMath ABI with it.

MPDecimal's own 32-bit versus 64-bit ABI follows **`sizeof(size_t)`**, checked by
CMake. `mpdecimal.h` is generated from the original `mpdecimal.h.in`, with the
appropriate `MPD_CONFIG_32` or `MPD_CONFIG_64` definition. The private library
definitions are `CONFIG_32`/`CONFIG_64` and `ANSI`. They are not published as global
application macros. There is no assembly, x87, or 128-bit compiler arithmetic in
the selected implementation.

The 4.0.1 source contains three conversion guards that select `__uint128_t`
automatically even with `ANSI`. `cmake/Precision.cmake` generates
`build/generated/mpdecimal/mpdecimal_portable.c`, replacing the three
`defined(__SIZEOF_INT128__)` guards with `defined(HAVE_UINT128_T)`. The latter is
not enabled in this profile, so the existing upstream C99 conversion alternatives
are used. CMake checks that exactly three guards were found, preventing a future
source update from silently applying an out-of-date adaptation. The original
`vendor/mpdecimal/libmpdec/mpdecimal.c` remains intact.

The source list comes from the upstream library Makefile. In particular,
`fnt.c` is portable C implementing a number-theoretic transform and is required
for large multiplication; it is not an assembly optimization to exclude.

## What these libraries replace

LibTomMath supplies multiple-precision integer arithmetic. Its API differs from
GMP; applications must use `mp_int` and the LibTomMath functions explicitly.

MPDecimal supplies correctly rounded arbitrary-precision **decimal** floating
point, including arithmetic, square root, exponentials, and logarithms. Its
precision is counted in decimal digits. It is not an API-compatible or complete
functional replacement for MPFR's arbitrary-precision binary arithmetic and
special-function coverage. The choice is appropriate when LMX wants decimal
semantics; it does not make a floating-point bit pattern or rounding contract
identical to an existing MPFR computation.

The retained decNumber library also uses decimal arithmetic but has its own
formats and APIs. Keeping both is an explicit composition decision, not a need
for MPDecimal to link against decNumber.

## Expanded example and validation

`examples/precision/main.c` implements the user's example with error checks:

1. Initialize three LibTomMath numbers and parse the two long integer strings.
2. Multiply them exactly, query the required output capacity using
   `mp_radix_size`, allocate a real buffer, and check `mp_to_decimal`.
3. Create an explicit MPDecimal context with 50 decimal digits and half-even
   rounding, evaluate `sqrt(2)`, and report the expected Inexact/Rounded flags.
4. Release a string returned by MPDecimal through `mpd_free`, so custom
   allocators remain supported.

The example uses the quiet `mpd_q*` API and checks its status bitset. An inexact
irrational square root is expected; allocation errors, invalid values, and other
unwanted status flags are handled separately.

Standalone build from the bundle root:

```sh
cmake -S examples/precision -B build-precision -DCMAKE_BUILD_TYPE=Release
cmake --build build-precision --parallel
ctest --test-dir build-precision --output-on-failure
./build-precision/lmx_example_precision
```

Expected example output:

```text
BigInt product: 121932631137021795226185032733622923332237463801111263526900
sqrt(2), 50 decimal digits: 1.4142135623730950488016887242096980785696718753769
Rounding status: Inexact Rounded
```

The integration tests cover exact integer multiplication/division, undersized
output buffers, a 1000-digit integer square/root, a known 50-digit square root,
exact decimal `0.1 + 0.2`, half-even quantization, the portable 128-bit triple
conversion, a 1000-digit decimal square, and invalid input. The complete
upstream LibTomMath unit-test executable is also registered with CTest.
MPDecimal's original test machinery is retained, but its separately downloaded
large test-data distribution is not represented as having been executed.

The isolated integration run on Linux x86_64 with GCC 14.2.0 passed all four
CTest entries; the upstream LibTomMath executable reported 42 passing cases,
zero skipped cases, and zero failures. All 174 recorded translation units used
`-std=c99 -pedantic-errors`. The standalone example CMake entry point also
configured successfully. Logs and machine-readable details are under
`docs/validation/precision_2026_11_25/`. This run does not establish execution
results for macOS, Windows, or a 32-bit target.

Sources for the public API behavior:
<https://www.bytereef.org/mpdecimal/doc/libmpdec/>,
<https://www.bytereef.org/mpdecimal/doc/libmpdec/memory.html>, and the pinned
`tommath.h`/`mpdecimal.h.in` declarations.
