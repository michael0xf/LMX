# PDFio 1.6.6: encrypted CreationDate

**Status: KNOWN_FAIL / encrypted-date correctness NOT_CLAIMED.**
The retained vendor source is unchanged. The C99 array-pointer cast in the
generated build view is unrelated to this defect.

`tests/repro_encrypted_date.c` creates a PDF 1.7 file with an empty page,
AES-128 encryption, the reader password `test-reader` and a UTC creation time
of 1700000000. It closes the file, reopens it with that password and calls
`pdfioFileGetCreationDate`:

```text
KNOWN FAILURE: encrypted CreationDate got 0, expected 1700000000
exit status: 1
```

Reproduce after the normal group build:

```sh
build/pdf-extra/lmx_pdf_repro_encrypted_date build/pdf-extra/date-repro.pdf
```

Alternatively configure `-DLMX_PDFIO_RUN_KNOWN_FAILURE=ON` to add the failing
case to CTest. It remains a failing test, with no `WILL_FAIL` property. Normal
CTest intentionally covers the supported ordinary-PDF case and explicitly
scoped encrypted pages/strings/streams; it does not convert this failure into
a green result.

Source inspection explains the observed mismatch: `_pdfioValueWrite` writes an
encrypted date as a hexadecimal PDF string. The binary branch of
`_pdfioValueDecrypt` decrypts its bytes but retains the binary value type.
`pdfioDictGetDate` accepts only a `PDFIO_VALTYPE_DATE` and therefore returns 0.
The ordinary unencrypted date path does convert its textual date and passes
the exact UTC roundtrip. This diagnosis does not claim to cover every date
representation or encrypted PDF produced by other tools.

The tested encrypted-file subset successfully reads title/author, restores page
text and the 512-byte binary Flate payload, copies a page and rejects the wrong
password. AES-256 is an upstream TODO in this release, and is not claimed.
The existing entropy fallback/legacy PDF encryption code is retained for format
compatibility; no cryptographic security audit or operational secrecy claim is
made by these functional tests.

Versioned primary implementation:

- <https://github.com/michaelrsweet/pdfio/blob/fb05e16bb2ae8cf1b1101669b236401dcb36c906/pdfio-value.c>
- <https://github.com/michaelrsweet/pdfio/blob/fb05e16bb2ae8cf1b1101669b236401dcb36c906/pdfio-dict.c>
- <https://github.com/michaelrsweet/pdfio/blob/fb05e16bb2ae8cf1b1101669b236401dcb36c906/pdfio-crypto.c>
