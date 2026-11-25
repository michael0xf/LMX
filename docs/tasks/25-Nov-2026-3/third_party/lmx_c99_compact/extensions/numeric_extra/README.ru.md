# Дополнительные компактные числовые библиотеки

Этот модуль добавляет десять независимых C-библиотек. Повторение возможностей
намеренно: для офлайн среды полезно иметь несколько понятных реализаций одной
задачи. Общая LMX модель и явно выбранные преобразования находятся в
[каталоге типов](../../../../docs/core_catalog/types/README.ru.md), а руководство
произвольной арифметики — в
[new_primitives](../../../../docs/core_catalog/new_primitives/README.ru.md).

Основной backend `real` — **LibBF с произвольной выбранной двоичной точностью**.
`double`, SoftFloat, fixed-point и FP16 сохраняют свои фиксированные профили;
никакой из них не объявляется эквивалентом произвольного `real`.

## Что входит и сколько занимает

Размеры ниже измерены для GCC 14.2, Linux x86_64, CMake `MinSizeRel`, strict C99.
`archive` — полный статический `.a`, включая таблицы символов и служебные
заголовки; `text` — сумма секций машинного кода объектов по `size`. Эти числа
не являются замером RAM задачи или гарантией для другой архитектуры.
Каждый из десяти архивов меньше 1 000 000 байт; их суммарный размер — 965 686
байт; уже существующая LibTomMath не посчитана повторно. Машинные артефакты в патч не включены; воспроизводятся из исходников.

| Backend / цель CMake | Возможности | Лицензия выбранных исходников | archive / text, байт |
|---|---|---|---:|
| LibBF / `LMX::libbf`, `LMX::real` | Arbitrary binary precision, arithmetic, transcendental functions, integer and normalized decimal APIs | MIT | 90 992 / 57 063 |
| SoftFloat 3e / `LMX::softfloat` | Программная IEEE арифметика binary16/32/64/80/128 | BSD-3-Clause | 484 220 / 66 043 |
| libfixmath / `LMX::fixmath` | Q16.16 арифметика и математические функции | MIT | 17 928 / 4 759 |
| libfixmatrix / `LMX::fixmatrix` | Fixed-point matrices, QR/Cholesky, vectors/quaternions | MIT | 25 144 / 8 768 |
| FP16 / `LMX::fp16` | IEEE half и ARM alternate half conversions | MIT | 2 498 / 476 |
| CMINPACK / `LMX::cminpack` | Нелинейные системы и least squares, C API double | MINPACK permissive; acknowledgment University of Chicago | 75 222 / 31 068 |
| IMath / `LMX::imath` | Большие целые и точные рациональные числа | MIT | 52 900 / 26 426 |
| PFFFT / `LMX::pffft` | Float/double 1D FFT и C fast convolution | BSD-like NCAR/UCAR, три условия | 79 692 / 56 463 |
| pcg-c / `LMX::pcg` | 8/16/32/64-bit state RNG, bounded random, jump-ahead | Apache-2.0 OR MIT | 50 806 / 10 786 |
| LibTomFloat / `LMX::tomfloat` | Экспериментальная независимая arbitrary binary precision | Public Domain OR WTFPL-2.0 | 86 284 / 10 576 |

Точные commit/version, URL исходных архивов, SHA-256, license paths, public
headers и ABI maps записаны в [COMPONENTS.json](COMPONENTS.json). Производные
build views создаются локально; исходные vendor snapshots сохраняют исходные
производственные файлы и notices. Результаты запуска и размеры находятся в
[VERIFICATION.json](VERIFICATION.json).

После отбора production inputs vendor trees уменьшились с 12 840 167 до
2 497 743 байт. Методика и per-component данные —
[COMPACTNESS.json](COMPACTNESS.json).

## Офлайн сборка

Из корня проекта после наложения патча:

```sh
cmake -S third_party/lmx_c99_compact/extensions/numeric_extra \
  -B build/numeric-extra -DCMAKE_BUILD_TYPE=MinSizeRel
cmake --build build/numeric-extra --parallel
ctest --test-dir build/numeric-extra --output-on-failure
```

Нужны C99 compiler, CMake 3.20+, Python 3 для детерминированного LibBF build
view и стандартная C math library там, где она выделена отдельно. Ни configure,
ни build не используют сеть, package download, Git, Fortran, C++, GMP, MPFR,
BLAS или LAPACK. При встраивании основная коллекция вызывает `add_subdirectory`
этого каталога и связывает aggregate `LMX::numeric_extra`; usage checks включаются
через `LMX_BUILD_NUMERIC_EXTRA_CHECKS`.

Исходники трёх кратких примеров одновременно служат тестами:

- [numeric_extra_check.c](tests/numeric_extra_check.c): произвольный real,
  IEEE formats, fixed matrices, half conversion, nonlinear root и точная дробь;
- [numeric_alternatives_check.c](tests/numeric_alternatives_check.c): один impulse
  FFT/inverse для float и double, PCG known seeded vector и jump-ahead;
- [libtomfloat_check.c](tests/libtomfloat_check.c): независимый arbitrary real,
  256-bit epsilon/sqrt2 и регрессии двух локальных исправлений.

Ожидаемые ключевые строки:

```text
LibBF sqrt(2), 256 bits: 1.414213562373095048801688724209698078569671875376948073176679737990732
Same task, LibBF / SoftFloat / libfixmath: 3 * 0.5 = 1.5
CMINPACK root x^2=2: 1.414213562373095
PASS: PFFFT float/double impulse FFT and inverse; PCG seeded vector and jump-ahead
```

LibBF дополнительно проверяет `(1 + 2^-100) - 1 == 2^-100` при 256 битах.
Обычный binary64 не сохраняет такое приращение около единицы. Этот тест
проверяет именно появление произвольной точности, а не просто запуск функции
с названием `real`. CMINPACK и LibBF вычисляют одну задачу `sqrt(2)` двумя
разными способами и с разными числовыми договорами.

## Выбранные профили и существенные ограничения

**LibBF.** [prepare_libbf.py](prepare_libbf.py) создаёт scalar C99 view:
32-bit limbs и 64-bit intermediate products, без `__int128` и AVX2. GNU-only
вспомогательные byte operations заменены стандартными C99 эквивалентами.
Символы `mp_*` переименованы в `lmx_bf_mp_*`, `dbuf_*` и несколько строковых
helpers — в `lmx_bf_*`, чтобы совместно линковаться с LibTomMath. `bf_*`
остаются исходными. Headers для клиента приходят из PUBLIC include path
цели; нельзя смешивать их с исходным 64-bit-limb header. Build script проверяет
форму адаптируемого исходника и отказывается при несовпадении ожидаемых guards.
Проверка нулевого memory budget также выявила unchecked initial `bf_resize`
в parser; build view направляет отказ в существующий `mem_error` до записи.
Этот regression прошёл ASan/UBSan в соседнем primitive reference.
Upstream `bftest` с зависимостью MPFR и интерактивный calculator не входят.

**SoftFloat.** Выбран `SOFTFLOAT_FAST_INT64`, portable out-of-line integer
helpers, `INLINE_LEVEL=0` и `SOFTFLOAT_ROUND_ODD`. Специализация `8086-SSE`
определяет propagation NaN, а не потребность в x86 инструкциях. Native byte
order определяется при configure. Strict C99 profile не использует TLS:
rounding/status/tininess — upstream mutable globals. Значит L3 adapter должен
сериализовать вход, установить явный context, забрать flags и восстановить
состояние; прямой concurrent доступ нескольких actors пока не разрешён.
Отдельные global raw C APIs не объявлены безопасными L3 методами.

**libfixmath/libfixmatrix.** Кеши libfixmath отключены `FIXMATH_NO_CACHE`.
Огромная неиспользуемая sine lookup table не сохранена. Матрицы имеют compile
time предельные размеры upstream, overflow/error policy проверяется на границе;
Tensor произвольного размера нельзя просто привести к `mf16*`.

**FP16.** Header-only C conversion дополнена четырьмя внешними функциями
[lmx_fp16.h](include/lmx_fp16.h) для конкретных native entrypoints. Native
half compiler extensions отключены. Полный исходный public header сохраняет
также исходные inline API.

**CMINPACK.** Сохранён C double API. Не подключаются f2c, Fortran, C++ либо
external BLAS/LAPACK. Callback обязан возвращать ровно тот статус, которого
ждёт solver; async event не заменяет синхронное вычисление residual/Jacobian.
Лицензия требует acknowledgment; полный текст находится в vendor component.

**IMath.** Его `mp_int`, `mp_digit` и похожие typedef не являются типами
LibTomMath. Не включать оба заголовка в один omnibus header и не делать cast
между объектами. Отдельные translation units и явный value converter
обеспечивают общую LMX bigint/rational модель.

**PFFFT.** Выбран portable scalar backend (`PFFFT_SIMD_DISABLE=1`) с float,
double и C fast-convolution API. Никакого FFTW и C++ PFDSP. Размер transform,
interleaved layout, normalized/unscaled inverse и alignment буферов имеют
собственный договор. SIMD source headers нужны исходным includes, хотя ISA
ветви выключены; они сохранены как зависимости build.

**LibTomFloat.** Экспериментальный backend с зависимостью на имеющуюся
LibTomMath. Все 53 C translation units проходят strict C99. Два наблюдавшихся дефекта
исправлены только в generated view: sqrt0 early return и full-width signed-long
constructor через `mp_set_l`, включая `LONG_MIN`. Отсутствующие definitions
`mpf_from_string`/`mpf_to_string` отмечены в metadata как
`declared_unimplemented`; эти функции не доступны как native entrypoints.
Upstream WARNING о незавершённости и отсутствии общей гарантии accuracy
сохранён. Рабочие smoke/regression tests не равны полной численной верификации.

**pcg-c.** Сохранены все portable 8/16/32/64-bit-state варианты. 128-bit
compiler extension отключён в generated header; это также отключает
128-bit-state `pcg64`, но 64-bit-output варианты `pcg64i/pcg64si` доступны.
Одна upstream функция `void` возвращала выражение типа void; generated source
убирает `return`, сохраняя сам вызов, чтобы пройти strict C99. Для L3
используются explicit-state `_r` функции, а не глобальный генератор.
`boundedrand` требует ненулевой bound. PCG/xoshiro — не криптографические RNG;
криптографический интерфейс использует соответствующий Secret/backend contract.

## Лицензии и альтернативы за пределами этого модуля

Исходные production notices проверены и сохранены; ограничение проекта —
permissive dependencies без GPL/LGPL исходников, даже в добавляемых tests.
Текстовые упоминания MPFR/GSL не означают их подключение.

| Кандидат | Решение и проверяемое основание |
|---|---|
| MPFR + GMP | Не добавлены по лицензионному ограничению: [MPFR](https://www.mpfr.org/) распространяется под LGPL и опирается на GMP. LibBF покрывает выбранное семейство arbitrary real, но не обещает полный MPFR API или идентичные все corner cases. |
| GSL | Не добавлена: [официальная лицензия GPL](https://www.gnu.org/software/gsl/). Часть задач распределена между существующими Cephes/CMPFIT/CQUADPACK/Sobol/Stroud/sparse grids и новыми CMINPACK/PFFFT/PCG. Полная функциональная эквивалентность GSL не заявляется. |
| OpenLibm | Перспективная независимая libm: [производственные лицензии](https://github.com/JuliaMath/openlibm/blob/master/LICENSE.md) преимущественно permissive, но `test-double.c`/`test-float.c` LGPL. Требуются отдельно отобранный production profile, собственные проверки и замер; в этот модуль не включён, сборка `NOT_RUN`. |
| SoftPosit | Ещё один числовой формат, [официальный проект](https://gitlab.com/cerlane/SoftPosit). Полная проверка выбранных файлов/лицензии/C99/размера в этом модуле `NOT_RUN`; не выдан за установленный backend. |
| LibTomFloat | Добавлен как экспериментальная независимая arbitrary precision альтернатива с двумя узкими исправлениями; фактические границы — в [numeric_candidates](../../../../docs/core_catalog/new_primitives/numeric_candidates.ru.md). |

Это перечень проверенных и явно обозначенных кандидатов, а не доказательство,
что просмотрены все существующие библиотеки в интернете. Дублирование
функциональности не является причиной отклонения. Качество выбранного
интеграционного профиля оценивается лицензией, воспроизводимой сборкой,
C99/платформенными требованиями, размером и понятным usage test.

Первичные проекты: [LibBF](https://bellard.org/libbf/),
[SoftFloat](https://www.jhauser.us/arithmetic/SoftFloat.html),
[libfixmath](https://github.com/PetteriAimonen/libfixmath),
[libfixmatrix](https://github.com/PetteriAimonen/libfixmatrix),
[FP16](https://github.com/Maratyszcza/FP16),
[CMINPACK](https://github.com/devernay/cminpack),
[IMath](https://github.com/creachadair/imath),
[PFFFT](https://github.com/marton78/pffft),
[pcg-c](https://github.com/imneme/pcg-c),
[LibTomFloat](https://github.com/libtom/libtomfloat).
