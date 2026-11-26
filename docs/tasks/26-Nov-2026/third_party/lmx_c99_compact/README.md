# LMX: compact C99 library collection

[Русский](README_RU.md) · Edition of **26 November 2026**

This README is intended for the root of `lmx_c99_compact`, next to [CMakeLists.txt](CMakeLists.txt). The collection contains the component entries listed in **SOURCES.json**, with every library group enabled by default. It provides sources, CMake targets, adapters, examples, and tests for use with LMX or another application. The LMX compiler, its FFI, and its graphical Manager are not included.


## Update: complete collection and LMX catalogue

The current collection has **180 components**. The primary API inventory and proposed LMX packages are in [docs/core_catalog](../../docs/core_catalog/README.ru.md). The [26 November verification](../../docs/c99_archive/VERIFICATION_2026-11-26.json) records the full retained-source build and **138/138 passing checks**.

| Added group | Contents | Targets |
|---|---|---|
| Platform | APR 1.7.6, APR-Util 1.6.6, SDL 3.4.20 | `LMX::platform_extra` |
| Compact bundles | gb; eight selected cute modules; permissive Embedded Artistry libc subset with prefixed symbols | `LMX::bundles_extra` |
| NetSurf libraries | libwapcaplet, libparserutils, libhubbub, libdom, libcss, libsvgtiny, libnsbmp, libnsgif | `LMX::netsurf_extra` |
| Scientific formats | HDF5 2.3.0 core + HL, PnetCDF 1.15.1, netCDF-C 4.10.1, libxml2 2.15.4 | `LMX::scientific_hdf5`, `LMX::scientific_pnetcdf`, `LMX::scientific_netcdf` |

Existing matio 1.6.0 now includes MAT7.3 through HDF5. **netCDF-5 / CDF-5** is explicitly catalogued and tested in both netCDF-C and PnetCDF. C99Containers is represented by the existing STC lineage. Full collection means retaining the accepted libraries and their documented source profiles; it does not turn on every optional backend or establish runtime support on every OS.

The scientific adapters require an **MPI C SDK**; PnetCDF requires POSIX shell, make and m4. MPI itself is external. C99 is verified on Linux/GCC for this edition. The one-rank MPI I/O checks are real; two-rank checks remain available but could not run under this host IPC restrictions. HDF5 HL calls need serialization, as documented in its adapter.

## Start here

- [Complete C99 capability catalog](../../docs/c99_archive/CATALOG.ru.md) — component role, version, license and source.
- [External format capabilities](../../docs/c99_archive/FORMAT_GUIDE.ru.md) — readers, writers and selected profile limits.
- [Current verification](../../docs/c99_archive/VERIFICATION.json) and [sizes](../../docs/c99_archive/SIZES.json).
- [SOURCES.json](SOURCES.json) — the complete component list, pinned versions/commits, source URLs, and license paths.
- [Examples and run commands](examples/README_RU.md) — 26 complete demonstration programs; guide in Russian.
- [Upstream example index](examples/UPSTREAM_INDEX_RU.md) and [detailed provenance index](examples/UPSTREAM_SOURCES.json).
- [Check index](examples/checks/INDEX_RU.md) — selected unit/integration tests.
- [Short guide to calling C from actors](examples/reference/C_FFI_QUICK_RU.md).

All links below are relative to the root of this compact distribution. Historical report directories and complete upstream distributions are not needed to use this guide.

## 1. Contents and file layout

| Path | Purpose |
|---|---|
| [vendor/](vendor/) | Selected library sources and required build inputs, including applicable platform implementations, templates, and licenses |
| [cmake/](cmake/) | Build rules for the base components and Windows runtime copying |
| [extensions/](extensions/) | Adapters for additional groups, integration sources, and some prepared build inputs; this directory is required |
| [include/](include/) and [src/](src/) | Shared headers and collection integration code |
| [examples/collection/](examples/collection/) | Complete programs using the libraries |
| [examples/upstream/](examples/upstream/) | Selected additional upstream examples and short references |
| [examples/checks/](examples/checks/) | Standalone checks of library APIs and interactions between components |
| [prebuilt/](prebuilt/) | Matching Windows runtime and its provenance |
| [extensions/postgresql/prebuilt/](extensions/postgresql/prebuilt/) | Windows x64 `libpq.dll`, matching headers, import library, and manifest |
| [SOURCES.json](SOURCES.json) | Each component's source, version, and notices |

The compact tree contains no `source_archives/` directory or copies of complete repositories. `llhttp` is in [vendor/llhttp/](vendor/llhttp/); CivetWeb is excluded. Do not remove `extensions/`: it is an active part of the integration, not a duplicate of `vendor/`.

Sources were selected file by file from the full collection, then checked through configuration, compilation, and linking. Required files for the libraries' platform branches were retained, not just the files used on the validated Linux host. Small C99 adaptations usually produce separate build copies; original vendored inputs remain separate from those copies. This is a prepared collection for this CMake project: not every retained upstream build script can build the reduced tree independently.

### Library groups

| Group | Main contents | Public targets / rules |
|---|---|---|
| HTTP, TLS, compression | curl 8.23.0, llhttp 9.4.4, mbedTLS 3.6.7, zlib 1.4 | `LMX::curl`, `LMX::llhttp`, `LMX::http_parser`, `LMX::mbedtls`, `LMX::zlib`; [networking](cmake/CURL_ZLIB.cmake), [parser](extensions/http_parser/CMakeLists.txt) |
| Containers and base core | Selected stb, klib, STC components; decNumber, libsodium, SLJIT; SQLite | `LMX::stb`, `LMX::klib`, `LMX::stc`, `LMX::decnumber`, `LMX::sodium`, `LMX::sljit`, `LMX::sqlite3` |
| Scientific mathematics | linmath, KissFFT, TinySpline, Wavelib, Cephes, CMPFIT, xoshiro | `LMX::math`, `c99_gsl_lite`; [rules](cmake/Scientific.cmake) |
| Precision arithmetic and integration | LibTomMath, MPDecimal; CQUADPACK, Stroud, Sparse Grid HW, Sobol | [Precision arithmetic](cmake/Precision.cmake), [quadrature](cmake/Quadrature.cmake); shared `LMX::math` |
| Networking and system utilities | dyad, ENet, libssh2, Monocypher, miniz, LZ4, microtar, jsmn, cJSON, tinydir, TinyCThread, libvterm | `LMX::systems`; [rules](extensions/systems/CMakeLists.txt) |
| Graphics and images | Sokol renderer, Nuklear, microui, Olive.c; QOI, LodePNG, libspng, tPNG, TJpgDec, NanoJPEG, gifdec, msf_gif | `LMX::graphics`, `LMX::sokol`; [rules](extensions/graphics/CMakeLists.txt) |
| Audio and video | miniaudio, dr_wav/dr_mp3/dr_flac, minimp3, jo_mp1, TinySoundFont, pl_mpeg, jo_mpeg, jo_gif, minih264, nestegg, h264bsd, libwebp with mux/demux | `LMX::media`; [rules](extensions/media/CMakeLists.txt) |
| Documents and models | PDFGen, md4c, Gumbo, yxml, ezXML, tomlc99, libyaml, cgltf, fast_obj | `LMX::documents`; [rules](extensions/documents/CMakeLists.txt) |
| Archives and binary formats | kuba zip, Zstandard, LZMA SDK C decoders, CMP, MPack, nanopb runtime | `LMX::archives`; [rules](extensions/archives/CMakeLists.txt) |
| XLSX | xlsxio, Expat, classic MiniZip from zlib | `LMX::xlsxio`; [rules](extensions/xlsxio/CMakeLists.txt) |
| External databases | hiredis, libbson/libmongoc, libpq 18.7 | `LMX::databases`, `LMX::pq`; [drivers](extensions/databases/CMakeLists.txt), [PostgreSQL](extensions/postgresql/CMakeLists.txt) |
| Vector search | sqlite-vec for the included SQLite | `LMX::sqlite_vec`; [rules](extensions/sqlite_vec/CMakeLists.txt) |
| Additional utilities | tinyfiledialogs, whereami, cglm, quirc, QR-Code-generator, tiny-regex-c | `LMX::extras`; [rules](extensions/extras/CMakeLists.txt) |
| Geodesy and spatial indexes | GeographicLib-C geodesic, H3, tidwall rtree, Shapelib, minmea | `LMX::geospatial`; [rules](extensions/geospatial/CMakeLists.txt) |
| Tensors | CPU tensor subset of mint and CPU implementation of utensil | `LMX::tensors`, `LMX::mint`, `LMX::utensil`; [rules](extensions/tensors/CMakeLists.txt) |
| Paths and UTF-8 | cwalk, utf8.h | `LMX::text_paths`; [rules](extensions/text_paths/CMakeLists.txt) |
| Number conversion and memory | Complete Ryu float/double C portion; TLSF | `LMX::core_helpers`; [rules](extensions/core_helpers/CMakeLists.txt) |
| Static embeddings | Averaging float vectors by token IDs, with optional L2 normalization | `LMX::embeddings`, `LMX::static_embeddings`; [API](extensions/embeddings/include/lmx_static_embeddings.h) |
| Error correction | libcorrect: Reed–Solomon, convolutional codes/Viterbi; fec shim | `LMX::channel_codes`, `LMX::correct`; [rules](extensions/channel_codes/CMakeLists.txt) |
| DSP and acoustic modem | Liquid-DSP with internal FFT, libquiet, Jansson | `LMX::acoustic`, `LMX::liquid_dsp`, `LMX::quiet`; [rules](extensions/acoustic/CMakeLists.txt) |
| Satellite orbits | C SGP4/TLE implementation from aholinch/sgp4 | `LMX::orbits`, `LMX::sgp4`; [rules](extensions/orbits/CMakeLists.txt) |
| CPU neural networks | Genann, KANN with autodiff and reader, Tinn, afan Neural-Network | `LMX::genann`, `LMX::kann`, `LMX::kann_data`, `LMX::tinn`, `LMX::afan_neural_network` |
| Quantized inference | NNoM scalar core, q7/q15 | `LMX::mlp_nnom`, `LMX::nnom`; [rules](extensions/nnom/CMakeLists.txt) |

Component entries, CMake targets, and static archives are different counting units. Shared dependencies, including zlib, cglm, and KissFFT, are not added as independent copies of the same implementation. The exact contents are pinned in [SOURCES.json](SOURCES.json).

### Additional capability groups

The numeric, text/hash and networking additions are retained. New groups
provide media/filesystem formats and CBOR (`storage_extra`), sensing/control
and device protocols (`control_extra`), TIFF/XLS/MAT, Data Matrix, regex and
optimization (`knowledge_extra`), ODE and astronomical calculations
(`science_extra`), and PDF object/page/stream I/O (`pdf_extra`).

Every accepted group participates in `LMX::all`. Use
`-DLMX_ARCHIVE_VERIFY=ON` for the current examples and CTest suite.
Exact profiles and metadata are local to the extension directories.

## 2. Build requirements

- **CMake 3.26+**, a C99 compiler, linker/archiver, and system C headers. GCC and Clang have been checked. The root project uses only `LANGUAGES C`, `C_STANDARD=99`, `C_STANDARD_REQUIRED=ON`, and `C_EXTENSIONS=OFF`; strict mode adds `-pedantic-errors` for GCC/Clang.
- **Python 3.8+** for adapters; **POSIX/MSYS2 `sh` and GNU Make** for libsodium and source builds of libpq. Use a single-config generator: **Ninja** or **Unix Makefiles**. These two adapters do not support multi-config generators.
- **Building libpq from source** requires Bison, Flex, Perl, GNU m4, and `nm`; the Windows source branch also needs `windres`. A compatible prebuilt Windows x64/MSVCRT DLL is selected before PostgreSQL-specific host tools are searched for. The generated `configure` is retained; Autoconf/Automake do not need to be rerun.
- Graphics needs the SDK for the selected backend: OpenGL, OpenGL ES 3, or Vulkan. The validated Linux configuration uses the system `OpenGL::OpenGL`; Android GLES3 uses NDK `GLESv3` and `log`.

No dependencies are downloaded during configuration or building. Compilers, SDKs, and the listed tools must be installed beforehand. The selected library implementations do not require C++/Fortran compilers, OpenSSL, or a separately installed mbedTLS. X11/GLX, GTK, and AppIndicator are not part of the required build dependency chain.

Windows support is based on **MinGW-w64/MSYS2 with pthreads**; native MSVC is neither validated nor claimed. Retaining an OS-specific source branch does not mean the whole collection has been built and run on that OS.

## 3. Building the libraries

Run all commands below from the collection root:

```sh
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel 4
```

If Ninja is not installed, replace `-G Ninja` with `-G "Unix Makefiles"` in a suitable POSIX/MSYS2 environment. Use a new build directory when changing the toolchain or generator.

All `LMX_WITH_*` variables in the [root CMakeLists.txt](CMakeLists.txt) are ordinary `set(... ON)` assignments. This is a fixed set of accepted components: `-DLMX_WITH_...=OFF` does not disable a group. Changes to the composition must be made manually, taking dependencies into account.

The root project builds libraries. Its historical `BUILD_TESTING` and `LMX_BUILD_EXAMPLES` settings are `OFF`, because the former full fixtures are not included in the compact distribution. The newly selected programs and checks have separate CMake entry points, described below. This archive has no `CMakePresets.json`: use explicit commands rather than the former `posix-release` preset.

### Examples and tests

```sh
cmake -S examples -B build-examples -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build-examples --parallel 4
ctest --test-dir build-examples --output-on-failure
```

This project builds the libraries, 26 demonstration programs, and the selected checks. Programs are placed in `build-examples/bin/`:

```sh
./build-examples/bin/lmx_example_sqlite_memory
./build-examples/bin/lmx_example_qr_image qr.pgm "Lingvamyxa"
./build-examples/bin/lmx_example_xlsx_roundtrip table.xlsx
./build-examples/bin/lmx_example_http_parser
```

On Windows, executable filenames have an additional `.exe` suffix. Output files are created in the current working directory; names and arguments for the other demonstrations are listed in the [example guide](examples/README_RU.md).

Checks only:

```sh
cmake -S examples/checks -B build-checks -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build-checks --target lmx_usage_checks --parallel 4
ctest --test-dir build-checks -L lmx_usage_checks --output-on-failure
```

Tests keep `assert` enabled in Release. Scenarios have separate working directories and timeouts; they need no external database servers, certificates, media archives, or datasets. These are selected checks of APIs, numerical results, and interactions between libraries, not complete upstream suites.

## 4. Adding the collection to an application

If the collection is located at `third_party/lmx_c99_compact`:

```cmake
cmake_minimum_required(VERSION 3.26)
project(MyApplication LANGUAGES C)
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

add_subdirectory(third_party/lmx_c99_compact)
add_executable(my_lmx main.c)
target_link_libraries(my_lmx PRIVATE LMX::all)
lmx_copy_runtime(my_lmx)
```

`LMX::all` is an INTERFACE dependency aggregate. It propagates libraries, include paths, definitions, and system dependencies. Ordinary static linking extracts the required object files; it does not necessarily place all code from every archive in the executable.

For an existing Qt/C++ application, specify `C CXX` in your own `project`; the C dependencies retain their own standard settings. Qt is not a dependency of the collection.

You can link individual public targets while keeping the full set of libraries in the build:

```cmake
target_link_libraries(my_app PRIVATE
    LMX::curl LMX::llhttp LMX::sqlite3 LMX::sqlite_vec
    LMX::qrcodegen LMX::quirc LMX::static_embeddings)
lmx_copy_runtime(my_app)
```

Use the target settings. Copying a single `.a` manually does not carry over ABI definitions, include paths, or dependencies. Most included header implementations are split among separate adapters: combining all `*_IMPLEMENTATION` definitions into one C file can cause collisions between private names and macros.

`LMX::mint` and `LMX::utensil` are INTERFACE targets; the application supplies their implementations. For Mint, define `MT_IMPLEMENTATION` before including `<mint.h>` in exactly one translation unit, as shown in [mint_tensor.c](examples/collection/mint_tensor.c). The Utensil header itself contains external definitions: include it in exactly one translation unit, or provide your own declarations facade; see [utensil_tensor.c](examples/collection/utensil_tensor.c). Linking `LMX::all` alone does not create these two implementations.

### Windows DLLs

[lmx_copy_runtime](cmake/WindowsRuntime.cmake) copies the applicable `libpq.dll` and `libwinpthread-1.dll` next to the executable; on POSIX it does nothing. For winpthreads, the active compiler's runtime is preferred. The supplied fallback is allowed only for the validated ABI and is checked by SHA-256.

- [libpq manifest](extensions/postgresql/prebuilt/windows-x86_64/manifest.json): a prebuilt Windows x64/MSVCRT DLL of **401 267 bytes**, with matching headers/import library. The [PostgreSQL adapter](extensions/postgresql/CMakeLists.txt) checks compatibility; another supported MinGW configuration uses a source build. A preinstalled libpq is not assumed.
- [winpthreads manifest](prebuilt/windows-x86_64/runtime/manifest.json): the supplied runtime is **325 114 bytes**. Other components in the combined build need it; the prebuilt libpq DLL itself imports only system Windows DLLs.

The two DLLs total **726 381 bytes**. Application code and additional dependencies may require other runtime files. Architecture and CRT must match the application; the x64 DLL is not intended for a 32-bit process.

## 5. Important component details

### Networking and databases

curl and libssh2 share the mbedTLS/mbedcrypto configuration. curl provides SCP/SFTP through libssh2. The coordinated settings are in the [curl rules](cmake/CURL_ZLIB.cmake), [TLS rules](cmake/MbedTLS.cmake), and [systems group](extensions/systems/CMakeLists.txt).

`LMX::llhttp` / `LMX::http_parser` provide a streaming HTTP parser. The application manages sockets, TLS transport, connections, routing, and the HTTP server lifecycle. llhttp does not include a complete server; curl handles outgoing HTTPS requests.

A shared mbedTLS does not automatically enable TLS in every database driver. In this distribution, hiredis is built without its OpenSSL adapter; libpq has no TLS but supports SCRAM-SHA-256; libmongoc has neither TLS nor a crypto backend for SCRAM, and no SASL/Kerberos/AWS/CSE. The [database rules](extensions/databases/CMakeLists.txt) and [libpq rules](extensions/postgresql/CMakeLists.txt) define these choices. URI/protocol checks without a server do not validate a connection to a real database.

### Graphics, audio, and video

In the [graphics group](extensions/graphics/CMakeLists.txt), `LMX_GRAPHICS_SOKOL_BACKEND` selects `GLCORE`, `GLES3`, or `VULKAN`. The desktop default is GLCORE; Android/Emscripten/iOS default to GLES3. The application supplies the window, current GL/GLES context or Vulkan device/queue, and presentation. Windowing `sokol_app`/glue and Sokol audio-device support are not part of the target. The Vulkan backend is experimental in the pinned upstream version; its API and feature requirements still apply. Android validation covered GLES3.

RGFW and tray are excluded. Nuklear and microui need the application's renderer for output; the separate miniaudio library provides audio devices. On UNIX, tinyfiledialogs builds without GTK/X11 headers, but at runtime it may invoke installed `zenity`/`kdialog` programs or use a console fallback; this does not guarantee a GUI in a headless environment. See the [tinyfiledialogs header](vendor/tinyfiledialogs/tinyfiledialogs.h) for details.

`jo_mp1` decodes MP1. `minih264` is an encoder; h264bsd is the included H.264 Baseline decoder. Nestegg parses WebM containers. libwebp mux/demux does not promise to avoid frame buffering. No audio device or actual graphical window was used when validating the compact distribution.

### Mathematics, tensors, and machine learning

[c99_gsl.h](include/c99_gsl.h) and [c99_quad.h](include/c99_quad.h) provide shared entry points. The name `c99_gsl_lite` does not imply compatibility with the full GSL API/ABI. MPDecimal performs decimal arithmetic, not MPFR-style binary arithmetic; linmath/cglm focus on small graphics matrices.

Mint is included as a validated CPU tensor subset; a complete model runtime is not claimed. EmbeddedLapack was excluded after reproducible memory errors. No combination with it is presented as a ready-made NumPy/MATLAB module.

The [static embeddings module](extensions/embeddings/include/lmx_static_embeddings.h) accepts prepared token IDs and float vectors. It includes no tokenizer, GGUF/safetensors loader, or model weights.

NNoM performs quantized inference, not training. Its q7/q15 scalar core is retained; CMake applies small validated fixes in a build copy. The caller must keep buffers/descriptors alive; optimized dense processing for groups of four outputs requires upstream x4-packed weights. Dense/Conv2D and memory-lifetime checks do not validate every mode of every layer. See the [adapter](extensions/nnom/CMakeLists.txt) and [check scenarios](examples/checks/INDEX_RU.md).

TinyCThread provides part of the C11 threading API; it does not emulate the C11 language, `_Atomic`, `_Generic`, or other compilers' requirements. ggml, dav1d/libavif, edge264, and Box2D v3 are not part of the accepted collection.

### DSP, error correction, and orbits

Liquid-DSP uses its internal FFT: the integration neither searches for nor links FFTW. libquiet exchanges PCM buffers and can be connected to miniaudio without PortAudio/libsndfile. This alone does not provide a complete file-transfer protocol with retries and authentication. The [acoustic_loopback.c](examples/collection/acoustic_loopback.c) example runs without an audio device.

libcorrect's convolutional API uses bit lengths, while RS uses byte lengths; an error-correcting code does not guarantee detection of every corruption beyond its capabilities. SGP4 computes position and velocity in TEME; azimuth and Doppler require additional observer geometry. In the adapted C implementation, Unix timestamps in milliseconds use `int64_t`; relative time in minutes and Julian dates remain `double`.

## 6. Examples, references, and validation scope

The original 26 usage demonstrations, upstream examples and 51 API scenarios
are retained. New groups add focused tests and a combined corrupted-file
recovery example. Counts, C99 flags, actual platform and limitations are in
the [current report](../../docs/c99_archive/VERIFICATION.json).

The new native verification is Linux x86_64. Historical Windows/Android
results from the supplied baseline are not attributed to the new additions.
Retained platform sources support future builds; they are not a claim of a
completed hardware/OS matrix. [Size records](../../docs/c99_archive/SIZES.json)
distinguish source payloads, archives and binaries; they are not a measured
final LMX runtime. Our build products are excluded from the source archive.

## 7. Licenses and further integration

Exact details and paths to license texts are in [SOURCES.json](SOURCES.json). Applicable LICENSE/COPYING/NOTICE files and additional notices are retained. Mint and afan Neural-Network remain explicitly marked **NOASSERTION**: this means no license has been established, not that they are MIT-licensed or Public Domain.

The collection's own integration is covered by [LICENSE.integration](LICENSE.integration), unless a file states otherwise; the static embeddings module has a [separate MIT license](extensions/embeddings/LICENSE). Derived adaptations retain the terms of their respective upstream sources. Licenses for the prebuilt runtime and its exceptions are retained alongside the [Windows files](prebuilt/windows-x86_64/licenses/).

To connect `c.*` to an existing actor model, use the [FFI quick reference](examples/reference/C_FFI_QUICK_RU.md): allocator hooks, object ownership, normal cleanup, and the boundary at which native execution has finished. This is groundwork for integration, not an already implemented LMX execution mechanism. Memory belonging to a native call must not be freed while its code or callbacks can still use it.

The indexes, build rules, and examples referenced in this edition open directly from the compact tree. Historical reports, separate idea documents, and the original full archive are not needed to resolve its links.
