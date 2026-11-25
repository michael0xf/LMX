# Compact PDF reader/writer

`LMX::pdfio` contains PDFio **1.6.6**, pinned to
`fb05e16bb2ae8cf1b1101669b236401dcb36c906`.
`LMX::pdf_extra` is the group interface target. It reads and writes PDF files,
exposes objects and page streams, copies pages, embeds fonts/images and handles
document metadata. It does **not** render PDF pages to pixels.

The selected static library is **275,664 bytes** on Linux x86_64 with GCC 14.2,
`-Os -DNDEBUG -std=c99 -pedantic-errors`. GNU `size` reports 105,599 text bytes,
15,792 data bytes and 0 BSS bytes. These are build measurements, not peak RAM
limits. The existing shared-in-the-build `LMX::zlib` dependency is separate;
there is no second vendor copy of zlib.

## Offline build

From the compact collection root, where `vendor/zlib` already exists:

```sh
cmake -S extensions/pdf_extra -B build/pdf-extra -G Ninja \
  -DCMAKE_BUILD_TYPE=MinSizeRel -DLMX_PDF_EXTRA_BUILD_TESTS=ON
cmake --build build/pdf-extra
ctest --test-dir build/pdf-extra --output-on-failure
```

The full collection can instead call `add_subdirectory(extensions/pdf_extra)`
and link `LMX::pdf_extra`. The dependency fallback is only used when the parent
has not already defined `LMX::zlib`. `LMX_PDF_DEPENDENCY_VENDOR` can point to an
existing compact vendor directory for an isolated group build. No configure or
build step downloads anything. No command-line conversion tool is a dependency.

The profile uses zlib and the system math library on Unix; on Windows it links
`advapi32` for the retained upstream random-number API. The optional libpng
integration is disabled (`HAVE_LIBPNG` is undefined); PDFio's own PNG path is
retained. JPEG embedding uses its own header reader and compressed-data
passthrough, without libjpeg. These paths do not amount to a general raster
decoder or renderer.

## C99 and platform scope

All 17 production translation units compile in strict C99 mode. The upstream
source has one implicit qualification conversion between pointers to
multidimensional arrays that ISO C before C23 rejects. `prepare_pdfio.cmake`
verifies the source hash and emits a build-directory copy of `pdfio-content.c`
with one explicit `(const double (*)[3])` cast. There are no changes to the
retained vendor files, the public ABI or the color calculation. The exact
source/build-view hashes are in `COMPONENTS.json`.

This is hosted C99: file descriptors, the allocator, time/locale services and OS
entropy are used. Unix feature macros and time-function probes are local to the
target; all upstream Windows/macOS/Unix source branches remain. Only Linux
x86_64 was built and executed here. Windows/macOS builds and resource-limited
hardware are **NOT_RUN**.

Treat each open PDF, its objects and its streams as one ownership domain;
serialize access to that file, including reads that update buffers and caches.
Avoid changing the process locale concurrently. Cross-file/thread safety was
not tested. Read-only sharing of code is not a claim that library or libc state
is immutable.

## Verification and the known limitation

The original downloaded source tree and the trimmed retained tree were built
with the same C99 integration. The resulting `.a` archives are byte-identical.
The three default checks pass in both builds and in an AddressSanitizer plus
UndefinedBehaviorSanitizer build (leak checking disabled in this environment):

- Ordinary PDF: two pages, title/author, exact UTC creation date, page boxes and
  decoded text; 512 binary bytes through a Flate stream; copy one page into a
  second file and reopen it.
- Invalid input: non-PDF text and a truncated catalog object are rejected.
- Limited encrypted-file check: AES-128 page/content/string/binary-stream
  roundtrip, page copy and wrong-password rejection. **Encrypted dates are
  excluded from this passing claim because they have a separately reproduced
  defect.**

`tests/repro_encrypted_date.c` is retained and built as
`lmx_pdf_repro_encrypted_date`. It currently returns **1**: a creation date of
1700000000 is read back as 0. It is not marked `WILL_FAIL` and is not counted as
a passing test. See [KNOWN_LIMITATIONS.md](KNOWN_LIMITATIONS.md) for the exact
reproducer and scope. This collection does not claim a fully verified
encrypted-PDF profile or a security audit.

Upstream `testpdfio.c`, `testttf.c`, their shared test header and useful example
sources remain, but their complete original data/font corpus was trimmed; the
full upstream harness is **NOT_RUN**. Rendering, complex external corpus
interoperability, all fonts/images/filters, and exhaustive malformed-input
testing are also not claimed. `VERIFICATION.json` records the precise results.

## Retention, provenance and licenses

The vendor tree shrank from **9,539,962 bytes / 179 files** to
**1,070,108 bytes / 44 files**. Production C/headers and platform branches,
the Windows export list, source tests/examples, the compact Markdown manual,
licenses/notices and source links remain. Distribution/build outputs, duplicated
HTML/man documentation, images, PDF/font corpora and upstream build generators
were removed; the delivered CMake supplies the build. The optional Code128
example and its **GPL-2.0 font** were excluded together. That font is not part of
PDFio's library or any delivered target. `COMPACTNESS.json` records the inventory.

PDFio and the embedded TTF helper use Apache-2.0. Retain `LICENSE` and `NOTICE`;
the notice's additional optional linking exceptions do not impose GPL terms.
The MD5 source carries a zlib-style permissive notice and SHA-256 carries an
IETF BSD-3-Clause notice. The built-in CGATS ICC profile is CC0; its source
notice and compiled C array remain. The example Markdown helper is Apache-2.0.
See `COMPONENTS.json` for every retained notice path and exact source archive.

Primary sources:

- <https://www.msweet.org/pdfio/>
- <https://github.com/michaelrsweet/pdfio/releases/tag/v1.6.6>
- <https://github.com/michaelrsweet/pdfio/tree/fb05e16bb2ae8cf1b1101669b236401dcb36c906>
- <https://github.com/saucecontrol/Compact-ICC-Profiles>
