# Первичные источники платформ и Python

Проверены 28 ноября 2026. Это источники фактических API/ограничений; устройство прямого перехода и ресиверов управления сессией — проектные решения этого черновика. Номера patch releases здесь не фиксируются: конкретные распространяемые bytes/version/ABI закрепляет release lock.

## Runtime distribution и package ecosystem

- [python-build-standalone: описание](https://docs.astral.sh/python-build-standalone/) — CPython distributions с bundled dependencies.
- [Distribution archives](https://docs.astral.sh/python-build-standalone/distributions/) — full/install-only, `PYTHON.json`, shared library и ABI metadata.
- [Running distributions](https://docs.astral.sh/python-build-standalone/running/) и [его первичный исходник running.rst](https://github.com/astral-sh/python-build-standalone/blob/main/docs/running.rst) — runtime requirements. В разделе Linux для riscv64-unknown-linux-gnu явно указан minimum glibc 2.28; конкретный artifact всё равно проверяется по lock/metadata.
- [Behavior quirks](https://docs.astral.sh/python-build-standalone/quirks/) — Windows pip entry, static/dynamic profiles и packaging limits.
- [Python на Android](https://docs.python.org/3.14/using/android.html) — embedded libpython, app assets, wheels.
- [Android releases](https://www.python.org/downloads/android/) — реальные официальные embeddable packages.
- [PEP 738](https://peps.python.org/pep-0738/) — Android/bionic ABI, первоначальные target decisions и linkage.
- [Chaquopy FAQ](https://chaquo.com/chaquopy/doc/current/faq.html) и [versions](https://chaquo.com/chaquopy/doc/current/versions.html) — пакетная совместимость/версионные ограничения рассмотренного SDK.
- [Pyodide deployment](https://pyodide.org/en/stable/usage/downloading-and-deploying.html), [packages](https://pyodide.org/en/stable/usage/loading-packages.html), [FAQ](https://pyodide.org/en/stable/usage/faq.html).

## Python API

- [Initialization configuration](https://docs.python.org/3/c-api/init_config.html).
- [Thread states / GIL](https://docs.python.org/3.14/c-api/threads.html).
- [Call protocol](https://docs.python.org/3/c-api/call.html).
- [Exception handling](https://docs.python.org/3/c-api/exceptions.html).
- [Reference counting](https://docs.python.org/3/c-api/refcounting.html).
- [Buffer protocol](https://docs.python.org/3/c-api/buffer.html).
- [Availability by platform](https://docs.python.org/3.14/library/intro.html), [subprocess](https://docs.python.org/3/library/subprocess.html), [multiprocessing](https://docs.python.org/3.14/library/multiprocessing.html).
- [Pyodide JavaScript API](https://pyodide.org/en/stable/usage/api/js-api.html), [type translations](https://pyodide.org/en/stable/usage/type-conversions.html).

## Native hosts

- [Windows DLL search](https://learn.microsoft.com/en-us/windows/win32/dlls/dynamic-link-library-search-order).
- [macOS Hardened Runtime](https://developer.apple.com/documentation/security/hardened-runtime), [library validation](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.security.cs.disable-library-validation).
- [Android ABI](https://developer.android.com/ndk/guides/abis), [SDK versions](https://developer.android.com/ndk/guides/sdk-versions), [public native APIs](https://developer.android.com/ndk/guides/stable_apis).
- [16-KB page sizes](https://developer.android.com/guide/practices/page-sizes).
- [Android 10 executable-memory/process changes](https://developer.android.com/about/versions/10/behavior-changes-10).
- [Android dynamic code loading](https://developer.android.com/privacy-and-security/risks/dynamic-code-loading).
- [Google Play executable-code delivery policy](https://support.google.com/googleplay/android-developer/answer/16559646) — относится только к соответствующему каналу распространения.

## L1 targets

- [MIR.md и C API](https://github.com/vnmakarov/mir/blob/master/MIR.md).
- [W3C WebAssembly Core](https://www.w3.org/TR/wasm-core-2/), [current core](https://webassembly.github.io/spec/core/), [binary format](https://webassembly.github.io/spec/core/binary/index.html).
- [RISC-V unprivileged ISA](https://docs.riscv.org/reference/isa/unpriv/unpriv-index.html), [ELF psABI](https://riscv-non-isa.github.io/riscv-elf-psabi-doc/).

## Локальная норма LMX

- [Grammar](../docs/spec/LMX_grammar.en.md), [semantics](../docs/spec/LMX_semantics.en.md), [L2 ABI](../docs/spec/L2_spec_en.md).
- [Объекты и композиция](../docs/spec/patterns/08_objects_and_composition/README.md).
- [Message patterns](../docs/spec/patterns/06_async_and_messages/README.md), [coordination](../docs/spec/patterns/07_state_coordination/README.md).
- [Реальные LMX примеры](../docs/spec/examples/), [parser vs runtime tests](../tests/parser/README.en.md).

Снимок `selfbuild` использован только как справка по реально исполнявшимся C-door/host путям. Его устаревшие формы не копируются вместо актуальной грамматики. Ни первичный источник, ни написанная спецификация не заменяют receipt конкретной платформенной сборки.
