# Лицензии выбранной коллекции

Эта редакция исключает GSL, GMP, MPFR, Mongoose, OpenSSL и Cubature.
Лицензии относятся к конкретным сохранённым исходникам и к фактически
подключённым компонентам. Название алгоритма само по себе не определяет
лицензию его реализации.

## Основные компоненты

| Компонент | Лицензия / разрешение | Первичный текст в наборе |
|---|---|---|
| CivetWeb 1.16 | MIT | `vendor/civetweb/LICENSE.md` |
| curl | curl license, разрешительная | `vendor/curl/COPYING` |
| mbedTLS 3.6.7 | Apache-2.0 OR GPL-2.0-or-later; для этого набора выбран Apache-2.0 | `vendor/mbedtls/LICENSE`, сохранённые тексты лицензий и notices |
| zlib | zlib | `vendor/zlib/LICENSE` |
| SQLite 3.54.1 | Public domain | Уведомления в начале `vendor/sqlite3/sqlite3.c` и `sqlite3.h`; <https://www.sqlite.org/copyright.html> |
| stb | MIT либо public-domain dedication; сохранены оба варианта | `vendor/stb/LICENSE` и уведомления в отдельных заголовках |
| klib | MIT | `vendor/klib/LICENSE.txt` и уведомления отдельных файлов |
| STC 5.0 | MIT, включая отдельное уведомление Plan 9 regex | `vendor/stc/LICENSE`, `vendor/stc/include/stc/priv/cregex_prv.c` |
| decNumber | ICU license | `vendor/decnumber/ICU-license.html` |
| libsodium | ISC | `vendor/libsodium/LICENSE` |
| SLJIT | BSD-2-Clause | `vendor/sljit/LICENSE` |
| linmath.h | WTFPL v2 | `vendor/linmath/LICENCE` |
| KissFFT 131.1.0 | BSD-3-Clause | `vendor/kissfft/COPYING`, `LICENSES/BSD-3-Clause` |
| TinySpline 0.6.0 | MIT | `vendor/tinyspline/LICENSE` |
| Wavelib | BSD-3-Clause и сохранённые уведомления происхождения CWT | `vendor/wavelib/COPYRIGHT`, `src/cwt.c` |
| Cephes | Собственное разрешение автора Netlib на свободное использование | `vendor/cephes/readme`, copyright в исходниках |
| CMPFIT 1.5 | Разрешение Markwardt плюс условия MINPACK / University of Chicago | `vendor/cmpfit/DISCLAIMER` |
| xoshiro256**, SplitMix64, f2x | Public-domain dedication плюс разрешение использовать, копировать, менять и распространять | Начало каждого `vendor/xoshiro/*.c` |
| LibTomMath 1.3.0 | Unlicense | `vendor/libtommath/LICENSE` |
| MPDecimal 4.0.1 | BSD-2-Clause | `vendor/mpdecimal/COPYRIGHT.txt` |
| CQUADPACK 1.1.1 | MIT | `vendor/cquadpack/LICENSE` |
| Stroud / stroud_rule | MIT в текущих авторских исходниках | `vendor/stroud_rule/stroud_rule.c` и сохранённая авторская страница |
| Sparse Grid HW | MIT в текущих авторских исходниках | `vendor/sparse_grid_hw/sparse_grid_hw.c` и авторская страница |
| Sobol | MIT в текущих авторских исходниках; сохранена при адаптации C99 | `vendor/sobol/sobol.cpp`, `src/quadrature/sobol_c99.c` |

Лицензии квадратурной группы также зафиксированы в `docs/QUADRATURE.md` и её
`provenance/*.json`: текущие MIT-исходники Stroud/Sparse Grid HW/Sobol
не следует смешивать со старыми LGPL-копиями с другого сайта.

## Встроенные части

TinySpline использует собственную копию **Parson** с MIT-уведомлением в
`vendor/tinyspline/src/parson.c` и `parson.h`. Отдельного скачивания JSON
не требуется, но уведомление Parson остаётся частью распространяемых notices.

Выбранная STC включает **Plan 9 regular expression library**. В
`vendor/stc/include/stc/priv/cregex_prv.c` сохранены отдельные MIT-уведомления
`Copyright © 2021 Plan 9 Foundation` и `Copyright © 2023 Tyge Løvset, for additions.`
При распространении бинарника с этой реализацией regex включайте их вместе
с полным MIT-текстом; одного корневого `vendor/stc/LICENSE` недостаточно.

В официальном mbedTLS сохранены **framework**, **Everest/HACL*** и **p256-m**
с их лицензиями. Для dual-license файлов этого профиля выбран Apache-2.0.
Подробный состав реально включённых реализаций описан в `docs/MBEDTLS.md`.
Полные деревья CivetWeb, curl и других библиотек содержат также необязательные
примеры и компоненты с собственными уведомлениями. Они не включаются в
бинарник автоматически только из-за присутствия исходника на диске.

## Статическая поставка закрытого приложения

У перечисленных разрешительных лицензий нет механизма LGPL, требующего
предоставлять объектные файлы закрытого приложения для перелинковки.
Сохраняются требования конкретной лицензии: copyright и текст лицензии,
disclaimer, необходимые attribution/NOTICE и отметки об изменениях, когда
они предусмотрены. Например:

- Для MIT/ISC/BSD включаются требуемые copyright, условия и disclaimer.
- Для Apache-2.0 сохраняются лицензия и применимые notices; изменённые файлы
  должны быть отмечены. Выбор Apache-2.0 у dual-license mbedTLS фиксирован.
- У zlib нельзя искажать происхождение; изменённые исходники отмечаются.
- **CMPFIT нельзя обозначить просто Public Domain.** Его `DISCLAIMER`
  включает условия MINPACK и acknowledgement University of Chicago /
  Argonne National Laboratory для пользовательской документации либо
  обычного места сторонних acknowledgements в приложении.
- **Cephes нельзя переименовать в MIT или BSD.** Сохранено собственное
  краткое авторское разрешение Netlib и copyright исходников. Набор не
  расширяет и не заменяет это разрешение новой лицензией.

`LICENSE.integration` — отдельная 0BSD-лицензия новых CMake-файлов,
самостоятельных обёрток, тестов и документации. Производные файлы,
содержащие адаптированный код поставщиков, сохраняют исходные уведомления;
0BSD не отменяет их условия.

## Первичные источники

- CivetWeb: <https://github.com/civetweb/civetweb/blob/v1.16/LICENSE.md>
- curl: <https://curl.se/docs/copyright.html>
- mbedTLS: <https://github.com/Mbed-TLS/mbedtls/blob/mbedtls-3.6.7/LICENSE>
- zlib: <https://www.zlib.net/zlib_license.html>
- SQLite: <https://www.sqlite.org/copyright.html>
- stb: <https://github.com/nothings/stb>
- klib: <https://github.com/attractivechaos/klib>
- STC: <https://github.com/stclib/STC/tree/v5.0>
- decNumber: <https://speleotrove.com/decimal/decnumber.html>
- libsodium: <https://github.com/jedisct1/libsodium>
- SLJIT: <https://github.com/zherczeg/sljit>
- linmath: <https://github.com/datenwolf/linmath.h>
- KissFFT: <https://github.com/mborgerding/kissfft/tree/131.1.0>
- TinySpline: <https://github.com/msteinbeck/tinyspline/tree/v0.6.0>
- Wavelib: <https://github.com/rafat/wavelib>
- Cephes: <https://netlib.org/cephes/readme>
- CMPFIT: <https://pages.physics.wisc.edu/~craigm/idl/cmpfit.html>
- Авторские RNG: <https://prng.di.unimi.it/>
- LibTomMath: <https://github.com/libtom/libtommath/tree/v1.3.0>
- MPDecimal: <https://www.bytereef.org/mpdecimal/download.html>
- CQUADPACK: <https://github.com/ESSS/cquadpack/tree/v1.1.1>
- Stroud: <https://people.sc.fsu.edu/~jburkardt/c_src/stroud_rule/stroud_rule.html>
- Sparse Grid HW: <https://people.sc.fsu.edu/~jburkardt/c_src/sparse_grid_hw/sparse_grid_hw.html>
- Sobol: <https://people.sc.fsu.edu/~jburkardt/cpp_src/sobol/sobol.html>

Полные тексты в исходниках и `provenance/` относятся к закреплённым версиям;
ссылка на живую ветку upstream может со временем измениться.
