# Обзор матричных операций LMX — 28 ноября 2026

## Результат

Матричная часть проверена и исправлена по документации и фактическим
исходникам существующих библиотек. Дополнены математические договоры,
общие модели данных, реальные LMX-тела и описание подключения конкретных
C API. Каталог сохраняет **529 идентификаторов** в прежнем порядке.
Новый набор глобальных операторов ради расширения списка не вводился:
основные пробелы были в точности договоров и в выборе пригодной реализации.

Неизменённые файлы исходного документационного дерева сохранены.
Удаление неизменённых файлов и создание итогового архива в этой работе
**не выполнялись**; они требуют отдельной команды пользователя.

## 1. Какие исходники использованы

| Источник | Проверенный состав |
| --- | --- |
| `28-Nov-2026.tar.gz` | 2 723 исходных файла, корень `doc/`; это база всех документационных изменений. |
| `third_party.tar.gz`, ранее загруженный пользователем 26 ноября | 180 компонентов по реальному `SOURCES.json`; архив восстановлен и распакован отдельно для чтения. |
| Pinned upstream | Использован для сверки нетривиальных API и алгоритмов; локальный экземпляр архива дополнительно проверен непосредственно. |

SHA-256 документационного архива:
`dc8c24b36236beb4f6d9193839647fb41ba5ad31e8c554921500a252e5b73995`.

SHA-256 `third_party.tar.gz`:
`c73028f3aadacd6ed93d4537ca91f4d3a3159467468c89d6ba31e88daf077457`.

Побайтовая сверка **13 771** regular files восстановленного third_party
с архивом не обнаружила изменений или лишних файлов:
[результат сверки](spec/validation/matrix_vendor_unchanged_20261128.json).
Все временные build views, исполняемые проверки и логи создавались вне
этого дерева.

## 2. Исправления математического договора

### Численная корректность и ускорение

Для приближённых solve/inverse, факторизаций, спектральных методов и
матричных функций определён начальный договор конечных входов. Он
отделён от обычной IEEE-арифметики по элементам и от точной алгебры:
нового запрета NaN/Inf для всех числовых операций не введено.

Вычисление порога численного ранга `atol + rtol * sigmaMax` теперь требует
проверки промежуточного результата. Конечные аргументы сами по себе не
исключают переполнение. Бесконечный или NaN-порог не разрешает молча
возвратить ранг ноль.

Строгая последовательная свёртка с установленными типами, округлениями
и запретом FMA не заменяется произвольным GEMM по совпадению формулы.
Backend должен сохранять этот договор либо работать под явно выбранным
численным профилем. Воспроизводимость одного backend и побитовое
совпадение с конкретным последовательным алгоритмом различаются.

### `slogdet` и повторные решения

Завершён уже существующий договор **M026 `slogdet`**:

- `sign` — знак для real либо комплексная фаза;
- `logAbsDet` — логарифм модуля определителя;
- сингулярный результат — `(0, -∞)`;
- для `0×0` — `(1, 0)`;
- вычисление идёт по факторам без предварительного получения потенциально
  переполняющегося обычного determinant.

Статус M026 стал S — нормативный договор определён. Это не означает
готовый численный backend.

Описан обычный `solve` в Structure результата LU/Cholesky. Несколько RHS
могут использовать одни удержанные факторы. Заданы владение, правила
изменения, перестановки, формы RHS и различие transpose/adjoint.
Скрытый кеш изменяемой входной матрицы не добавлен.

Полная норма: [TENSOR_EXPRESSIONS](spec/TENSOR_EXPRESSIONS.md), особенно
§7.13, §7.41–7.43 и §11. Согласованные краткие главы:
[ARRAY_EXPRESSIONS.ru](spec/ARRAY_EXPRESSIONS.ru.md) и
[ARRAY_EXPRESSIONS.en](spec/ARRAY_EXPRESSIONS.en.md).

## 3. Альтернативы среди существующих библиотек

| Задача | Реальный кандидат | Условие подключения |
| --- | --- | --- |
| Dense real/complex matmul | liquid-dsp | Точный scalar/complex ABI, row-major, размеры, alias, численный профиль. |
| Dense float matmul | Mint, Utensil | Поддержанные rank/shape, native int widths; в данном комплекте Utensil CPU-only. |
| Малые фиксированные float-матрицы | linmath, cglm | Фиксированный размер, column-major/alignment и ограничения конкретного alias. |
| Прямоугольный real QR | CMINPACK `qrfac`/`qform` | Double, column-major, compact factors; явный перевод 1-based pivot indices. |
| Fixed-point матрицы | libfixmatrix | Явный Q16.16-профиль, ограниченная ёмкость, flags и реальные требования QR/solve. |
| Symmetric real eig | klib `ke_eigen_sd` | Double symmetric input, scratch, eps/iteration, convergence и residual. |
| Sparse float matvec/matmul | liquid `smatrixf` | Создание native resource, конверсия CSR/CSC, ограничения индексов и owner lifetime. |

Проверены настоящие CMake targets, compile-time defines, списки исходников
и header ownership. Наличие внешних опций `MT_USE_BLAS` или `USE_LAPACK`
не объявлено наличием подключённого BLAS/LAPACK.

В проверенных интерфейсах не подтверждён готовый общий договор
SVD/Schur/pinv/nullspace, general complex eig и matrix exp/log/sqrt.
Unpivoted LU, graphics inverse и scalar/NN/ODE API не названы
эквивалентными заменами. Для full-column-rank real least squares описан
путь через QR; он не выдаётся за SVD minimum-norm для rank-deficient входа.

Подробное сравнение, точные entry IDs и первичные ссылки находятся в
[матрице backend](core_catalog/matrix/README.ru.md). Добавлены
**23 LMX-профиля** с реальными ссылками на существующие C99Calls и
catalog entry:
[backend_profiles.lmx](core_catalog/matrix/backend_profiles.lmx).
Общий LMX-вызов находится в
[calls.lmx](core_catalog/matrix/calls.lmx);
[ports.lmx](core_catalog/matrix/ports.lmx) объявляет необходимые типизированные
`prepare`/`finish`, которые остаются незаполненными до настоящей интеграции.
Имена методов не превращаются в строковый dispatcher, общий C lowering
не дублируется.

## 4. Подтверждённые ошибки и ограничения liquid-dsp

Проверенные native тела и отдельные исполняемые случаи показали:

- `matrixcf_trans` выполняет **conjugate transpose**;
- `matrixcf_hermitian` выполняет **обычный transpose**;
- `matrixf_div(X,Y)` фактически считает `X * inverse(Y)`, хотя HTML-документация
  указывает противоположный порядок;
- `matrixf_inv` может вернуть внешний success после внутренней singular
  diagnostic; статус одного внешнего вызова недостаточен;
- Crout/Doolittle LU не выполняют pivoting, а `P` остаётся identity;
- для обратимой матрицы с нулевым первым pivot подтверждены nonfinite
  факторы при внешнем success;
- Gram–Schmidt QR принимает только square matrix;
- binary sparse `smatrixb` использует GF(2), а не булеву OR/AND-алгебру.

Поэтому сопоставление с LMX задано по реальному действию, а не по похожести
имён. Проверка ошибок, finite/postconditions и публикация результата
остаются частью адаптера.

[Native report](core_catalog/matrix/validation_report.json) сохраняет
ожидания, наблюдения, source hashes, command argv и границы подтверждения.
В случаях с известным дефектом PASS означает воспроизведённый контрпример,
а не корректность общего LMX solve.

## 5. Общие математические типы

Вместо прежних 37 моделей и 26 converter contracts теперь **38 и 30**.

| Изменение | Что исправляет |
| --- | --- |
| `Tensor.strides: []i64` | Представляет reverse views; проверяются минимальный и максимальный достижимые адреса, units и narrowing. |
| Общий signed `tensorLayout` отдельно от `nonnegativeTensorExtent` | Старый C99 helper с unsigned strides больше не выдаётся за проверку произвольного signed View. |
| Одна `SparseMatrix` для CSR/CSC | Общие shape, values, indices, pointers; явные nnz, дубликаты, сохранённые нули и native index widths. |
| Уточнённый `ComplexBuffer` | Interleaved/planar component axis, единый scalar profile, отдельный допуск C complex/split ABI. |
| `fixedPoint` и `binaryFloatFormat` | Q-форматы отделены от IEEE/ARM binary16 и SoftFloat; saturation конверсии не обещает насыщение арифметики backend. |

Права доступа, логическая область непосредственного источника, владельцы,
lifetime, backing и alias не выводятся из строкового названия layout.
Эти модели служат bridge-контексту: обязательные поля обычного Array header
и тождество TypeRef не расширены.

Исходники и полный договор: [types/README.ru.md](core_catalog/types/README.ru.md).
[Точечная scope-проверка](core_catalog/validation/matrix_types_scope_20261128.json)
подтвердила 180 backend/component IDs, 1 035 model references,
912 converter references и 27 обязательных проверок.

Отдельно сохранено прежнее замечание вне матричной области:
`geospatial:h3` ссылается на не объявленный среди BridgeData `GeoCell`
в `primaryModel`. Этот неизменённый участок не исправлялся путём
изобретения геотипа; весь namespace package `primaryModel` не объявлен
прошедшим проверку.

## 6. Настоящие LMX-тела и отсутствие псевдокода

В существующий
[array_expression_ops.lmx](spec/patterns/LMX_Fn_Receivers/src/array_expression_ops.lmx)
добавлен один `FxMatrixPower\power`. Он вызывает реальные переданные
identity/copyValue/solve/multiply method references через общий `FxApply`:

- ноль даёт identity объявленного результата;
- единица даёт fresh copy;
- отрицательный показатель сначала выполняет одно решение `A X = I`;
- знаковый остаток и деление с усечением к нулю обходят опасный `abs(MIN_INT)`;
- отсутствуют лишнее `I*A` и последний неиспользуемый квадрат;
- источники сохраняются по общему provider contract.

Примеры целой степени, пустой матрицы, reverse Tensor, planar complex и CSR
написаны на LMX и зарегистрированы в
[Array examples](spec/examples/array_expressions/README.md).
Количество canonical исходников этой группы — 8; source, README,
doc_examples и SHA-256 согласованы.

Архитектурные листинги в Expression, bracket parser, slices, fusion и
сигнатурной части заменены точными фазовыми договорами и вызовами
существующих LMX-тел. Единственный основной парсер с делегирующим `[]`
и единый механизм группировки сохранены; второй parser/evaluator
для примеров не появился.

В нормативной матричной главе все code fences имеют язык LMX.
Вспомогательные Python/C99 программы сохранены именно как **инструменты
проверки**. Они не представлены как LMX, не заменяют отсутствующие
production providers и не являются псевдокодом.

Согласованы
[план реализации](TENSOR_IMPLEMENTATION_PLAN.md) и
[сопроводительная интеграция](ARRAY_EXPRESSION_INTEGRATION.md).
Сохранены приоритет степени 131 и правая ассоциативность, различие
поэлементного `*` и целостного `[*]`, а также depth вместо rank для
стандартного обхода.

## 7. Что проверено и что означает результат

| Проверка | Результат | Что она подтверждает |
| --- | --- | --- |
| 529 catalog IDs | Состав, уникальность и порядок сохранены | Целостность нормативного реестра. |
| Static LMX/layout и новые ссылки | Ошибок не обнаружено | Ограниченный исходный subset и согласованность документации, без type checking. |
| Backend CODE/entry references | 23/23 разрешены | Реальные ссылки на существующие wrappers и каталожные записи. |
| Native selected-source probe | 12/12, 28 C translation units | Различающие примеры поведения или ограничений выбранных библиотек. |
| Native definitions | 14 наблюдений в probe binary | Определения выбранного executable, не всей библиотеки и не ABI всех API. |
| Integer power oracle | 20 037 случаев, 0 failures, UBSan | Знаковая управляющая арифметика, MIN/MAX, порядок/число действий. |
| FP16 native header probe | 9 случаев, 0 failures, UBSan | Различие IEEE/ARM encodings и специальные floating значения. |
| Независимые арифметические проверки | 11 случаев | Ожидаемые результаты новых документальных примеров и контрпримеров. |
| Metadata/doc_examples | Повторная проверка не требует обновлений | Актуальные source hashes, строки и зеркала примеров. |
| Исходный third_party | 13 771/13 771 файлов без изменений | Native-проверки не изменили пользовательские библиотеки. |

Воспроизводимый native инструмент:
[validation/README.ru.md](core_catalog/matrix/validation/README.ru.md).
Отдельные [type probes](core_catalog/matrix/validation/type_probe_report.json)
сохраняют фактические compile argv и результаты;
[semantic report](spec/validation/matrix_semantic_review_20261128.json)
— проверенные примеры и нормативные hashes.

**Production LMX parser, type checker, translator и runtime, полный
LMX→C-shim bridge, целая CMake/CTest-сборка коллекции, GPU и внешние
BLAS/LAPACK не запускались.** В комплекте нет утверждения, что они прошли
приёмку. Статусы `NOT_RUN` и `REQUIRE_IMPLEMENTATION` оставлены там, где
интеграция ещё требуется. Старые receipts не переименованы в свежие PASS.

Полный отчёт текущей документационной сверки:
[matrix_review_20261128.json](spec/validation/matrix_review_20261128.json).
