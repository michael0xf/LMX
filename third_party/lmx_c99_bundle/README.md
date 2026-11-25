# LMX C99 / POSIX static library collection

See [README_RU.md](README_RU.md) for the complete composition, CMake targets,
examples, C99 adaptations, licenses, and platform limitations.

Network: **CivetWeb 1.16 + curl 8.23.0 + shared Mbed TLS 3.6.7 + zlib 1.4**.
Runtime/containers: stb, klib, STC 5.0, decNumber 3.68, libsodium, and SLJIT.
Database: SQLite 3.54.1, the unchanged official `sqlite3.c` and `sqlite3.h`.
It is enabled by default (`LMX_WITH_SQLITE3=ON`) as static target `LMX::sqlite3`.
Mathematics: linmath, KissFFT 131.1.0, TinySpline 0.6.0, Wavelib, Cephes,
CMPFIT 1.5, explicit-state xoshiro/SplitMix, LibTomMath 1.3.0, MPDecimal 4.0.1,
and the separately documented quadrature group.

The collection does not include GNU GSL, GMP, MPFR, OpenSSL, Mongoose, or
Cubature. `c99_gsl_lite` is a convenient aggregation target, not GSL API/ABI
compatibility. MPDecimal supplies decimal rather than binary arbitrary
precision arithmetic.

```sh
cmake --preset posix-release
cmake --build --preset posix-release --parallel 4
ctest --preset posix-release
```

Or use CMake 3.20+ with an explicit build directory and Ninja/Unix Makefiles.
All dependency source files are vendored; configure/build never downloads.
Use `add_subdirectory(...)` and link `LMX::all`, `LMX::math`/`c99_gsl_lite`, or
individual component targets. See `examples/consumer/CMakeLists.txt`.

If `vendor/` is absent, first run `python3 scripts/restore_vendor.py` using the
saved original archives and loose inputs. It restores the complete sources
offline and verifies every file. See `docs/SOURCE_RESTORATION_RU.md`.
The combined collection archive includes the complete ready-to-build `vendor/`
tree as well as these original reconstruction inputs.

The strict profile uses C99 with extensions disabled and GCC/Clang
`-pedantic-errors`. POSIX APIs and explicitly documented compiler/CPU facilities
are allowed. The complete native POSIX adapter does not claim tested native
Windows, cross, or Apple universal builds.

Original upstream settings, examples, and notices are retained. Narrow C99
compatibility views are generated in the build tree, not edited into vendor
sources. Exact versions, hashes, and adaptations are in `provenance/` and
`docs/`. Current validation is in `docs/validation/README_RU.md`; historic logs
are labeled separately and do not establish results for the current revision.

Stop all CivetWeb servers and other TLS consumers before calling
`curl_global_cleanup()`, which can release shared Mbed TLS PSA state.
