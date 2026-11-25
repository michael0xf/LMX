# Числовые кандидаты и реально выбранные профили

Канонические LMX данные описаны в [profiles.lmx](profiles.lmx),
[common_models.lmx](../types/common_models.lmx) и
[converters.lmx](../types/converters.lmx). Библиотеки могут повторять
возможности: это намеренная независимость реализаций. Объединяется интерфейс
данных, а не все алгоритмы в единственную C библиотеку.

В исходных 112 компонентах уже были LibTomMath, MPDecimal, decNumber, Cephes,
CMPFIT, CQUADPACK, KissFFT, Wavelib, Sobol, Stroud rule, sparse grids, xoshiro,
linmath и другие числовые средства. Источник —
[SOURCES.json](../../../third_party/lmx_c99_compact/SOURCES.json) и реальные
vendor headers/build modules. Они сохраняют собственные альтернативные API.
Наличие в спецификации слова MPFR не означало, что эта библиотека была в архиве.

## Добавленные библиотеки

| Задача | Выбранные реализации | Общая LMX форма | Граница совместимости |
|---|---|---|---|
| Произвольная двоичная точность | LibBF; экспериментальная LibTomFloat | `real` + `RealContext` | LibTomFloat не обещает точные LibBF rounding/status/exponent guarantees. Только явно принятый профиль. |
| Большие целые | Уже существующая LibTomMath; добавленная IMath; integer API LibBF | `bigint` | Native `mp_int` двух библиотек несовместим. Копируется значение, не C struct. |
| Десятичная арифметика | Уже существующие MPDecimal/decNumber; decimal API LibBF | `decimal` + `DecimalContext` | Сохранение quantum/NaN payload требует отдельной проверки; нормализованный bfdec не эквивалентен любому decimal encoding. |
| Точные дроби | IMath; возможная пара LibTomMath integers | `Rational` | Явная нормализация numerator/denominator. |
| Фиксированная IEEE арифметика | SoftFloat, FP16 conversion, существующая native arithmetic | Fixed-format слова/Tensor | Точность конечна и фиксирована; не заменяет arbitrary real. |
| Fixed-point и малая линейная алгебра | libfixmath, libfixmatrix | `Quantization`, `Tensor`, `Vector3` | Q16.16 range, rounding, sentinel и размер матрицы заданы профилем. |
| Нелинейные уравнения/подгонка | CMINPACK, существующая CMPFIT | `Tensor`, синхронный `Callback` | Solver status, work-array size и callback ABI отличаются. |
| FFT/convolution | PFFFT, существующие KissFFT/Wavelib/liquid-dsp | `ComplexBuffer`, `Tensor`, `Audio` | Нормировка inverse, допустимый N, alignment и упаковка комплексных данных объявлены явно. |
| Псевдослучайные потоки | pcg-c, существующий xoshiro | `RandomState` | Алгоритм/версия/state/seed/sequence входят в договор воспроизводимости. Не криптографические RNG. |

Все десять новых выбранных C99 targets собраны и исполнили краткие usage tests;
точные результаты и размеры —
[VERIFICATION.json](../../../third_party/lmx_c99_compact/extensions/numeric_extra/VERIFICATION.json).
Их десять статических архивов вместе занимают 965 686 байт на проверенной
Linux x86_64 конфигурации; LibTomFloat использует уже имеющуюся зависимость
LibTomMath, которая не включена повторно в эту сумму. Каждый новый archive
меньше 1 MB. Это измерение данной конфигурации, не обещание о любом ABI/compiler.

Полные распакованные upstream trees занимали 12 840 167 байт; оставленные
vendor inputs — 2 497 743 байта. Числа учитывают исходники/headers, notices и
короткие README, без shared integration module; per-component счётчики и
методика находятся в
[COMPACTNESS.json](../../../third_party/lmx_c99_compact/extensions/numeric_extra/COMPACTNESS.json).
Оставлены только входы выбранной сборки, лицензии, краткие пояснения и исходники
самостоятельных usage tests. Архивы загрузок, PDF manuals, build trees и
готовые `.a` остаются за пределами поставки.

## Почему основной real — LibBF

[LibBF](https://bellard.org/libbf/) предоставляет arbitrary binary precision,
явные rounding/status, основные арифметические и transcendental операции под
MIT. В выбранной поставке он собирается portable C99 с 32-bit limbs и
64-bit products. Это ограничивает профиль реализации, но не сводит точность
к binary64. Работающий [real_provider.c](real_provider.c) проверяет 256 бит,
самостоятельный контекст принимающего actor и сохранение `1+2^-100`.

MPFR остаётся сильным кандидатом по возможностям, однако
[официальный проект](https://www.mpfr.org/) указывает LGPL и зависимость GMP.
Он не соответствует заданному permissive-only составу этой поставки.
LibBF не выдается за ABI-совместимую или полную функциональную замену MPFR:
его реальные функции и ограничения перечислены отдельно в API каталоге.

## LibTomFloat: сохранённая экспериментальная альтернатива

Зафиксирован upstream commit `e7812b59bbe10030f27e721c295535278dd09335`, версия
0.02, [официальный repository](https://github.com/libtom/libtomfloat).
Лицензия — dual Public Domain / WTFPL-2.0; выбранные production source notices
сохранены. Все 53 translation units собираются strict C99 с имеющейся LibTomMath.
Возраст проекта сам по себе не был причиной отказа от независимого backend.

Проверка исходной версии обнаружила конкретные проблемы: `sqrt(0)` возвращал
`MP_VAL`; `mpf_const_d(4294967297L)` на LP64 давал 1; отрицание `LONG_MIN`
в исходном конструкторе недопустимо. В
[prepare_libtomfloat.py](../../../third_party/lmx_c99_compact/extensions/numeric_extra/prepare_libtomfloat.py)
два узких исправления создаются в build view: ранний нулевой результат sqrt
и конструктор через текущий `mp_set_l`. Исходные vendor файлы не переписываются.

[libtomfloat_check.c](../../../third_party/lmx_c99_compact/extensions/numeric_extra/tests/libtomfloat_check.c)
проверяет `3*0.5=1.5`, 256-bit epsilon, sqrt2 residual, sqrt0, широкий signed long
и `LONG_MIN`. Все проверки выбранной сборки прошли. Они не доказывают
корректность всех transcendental функций или совпадение rounding contracts.
Upstream [WARNING](../../../third_party/lmx_c99_compact/vendor/libtomfloat/WARNING)
прямо характеризует пакет как незавершённый и не гарантирует числовую точность;
это ограничение сохранено в описании experimental profile.

`mpf_from_string` и `mpf_to_string` объявлены в header, но definitions отсутствуют.
Они получают статус **declared_unimplemented**, а не рабочие c.* entrypoints.
Конвертер canonical real↔LibTomFloat ещё требует реализации через проверенное
значение мантиссы/экспоненты. Отсутствующую строковую функцию нельзя использовать
в автоматически сгенерированном исполняемом мосте.

## Отдельно обозначенные кандидаты

| Проект | Что установлено | Состояние в этой поставке |
|---|---|---|
| [GSL](https://www.gnu.org/software/gsl/) | GPL; широкий C toolbox | Не добавлена по условию лицензии. Набор отдельных permissive backends закрывает часть областей, полная эквивалентность не заявляется. |
| [OpenLibm](https://github.com/JuliaMath/openlibm) | Производственная libm использует permissive licenses; отдельные test-double/test-float LGPL по [license](https://github.com/JuliaMath/openlibm/blob/master/LICENSE.md) | Требует отдельного production-only C99/size profile и собственных тестов. Здесь `NOT_RUN`, не установленный backend. |
| [SoftPosit](https://gitlab.com/cerlane/SoftPosit) | Найден официальный C-проект posit arithmetic | Полный source/license/build/size audit здесь `NOT_RUN`; никаких заявлений о готовой интеграции. |

Это проверяемая граница завершённой работы. Она не означает, что перечислены
все когда-либо написанные малые C библиотеки. Следующий кандидат проходит те
же проверки исходного архива, лицензии, выбранных C99 inputs, native execution
и размера; повторение уже доступных функций разрешено и полезно.
