# Общие данные и конвертеры границы L3/L2

Первичный источник этого раздела — [common_models.lmx](common_models.lmx),
[converters.lmx](converters.lmx) и [backend_models.lmx](backend_models.lmx).
Здесь объясняется, как агенту использовать эти данные при подготовке каждой
обёртки. Модели являются **предложенными обычными LMX Structures**; наличие
описания не означает, что проверки уже встроены в текущее ядро.

## Одно представление на один смысл

LMX Array уже несёт фактический тип элемента и длину, а Structure является
общим `[]@`. Поэтому `Buffer` хранит ссылку на существующий Array и диапазон,
а не ещё одну копию указателя/длины и не упаковывает каждый числовой элемент
в отдельный объект. Строка остаётся точным `[]char` без NUL. Основание:
[semantics §2](../../spec/LMX_semantics.en.md#values),
[L2 §3](../../spec/L2_spec_en.md#value-record),
[L2 §5](../../spec/L2_spec_en.md#method-array).

Названия форматов и C-библиотек не вводят новые фундаментальные виды значений
([semantics, строка 275](../../spec/LMX_semantics.en.md)). `Image`, `Tensor`,
`Audio`, `DbRow` и остальные описания — модели поверх существующих данных.
Модель или формат сами по себе не меняют тип значения: готовое значение
принимается направленным `satisfies` без смены его TypeRef ([L2 §3](../../spec/L2_spec_en.md#value-record)).
Числовые расширения вынесены отдельно в [new_primitives](../new_primitives/README.ru.md).

| Модель | Канонические данные | Обязательные условия при приёме |
|---|---|---|
| `ScalarCell` | Ссылка на существующее scalar-место и writable | Native out/inout использует typed temporary и явный commit. Это не C pointer в L3; проверяются реальный тип, диапазон и право записи. |
| `Buffer` | `array`, смещение/число элементов, разрешение записи | Фактический element type; диапазон через `count <= length-offset`; переполнение размера; живой владелец. `writable=1` само по себе права не даёт. |
| `Tensor` | Один Array, `shape:[]size_t`, `strides:[]i64` в элементах, `offset:size_t`, layout | Ненулевой ранг равен длине shape/strides; проверяются нижняя и верхняя достижимые границы, исходный View, фактический TypeRef и native width. Подробнее ниже. |
| `SparseMatrix` | CSR/CSC, shape из двух осей, values, indices и pointers | Нулевая база индексов; согласованный nnz; монотонные pointers; границы внутренних индексов; порядок, дубликаты и явно хранимые нули не меняются скрыто. |
| `Hyperslab` | Векторы `start`, `count`, `stride`, `block` одинакового ранга | Выборка в хранимом массиве. Проверяются границы, произведения размеров и число элементов; block=1 задаётся явно для backend без блочного hyperslab. Пустая выборка сохраняет свой договор. |
| `Image` | Tensor + channels/colorSpace/alphaMode/origin | Порядок и число каналов, bit depth, row stride, ориентация и premultiplied/straight alpha явно согласованы. |
| `Audio` | Tensor + sampleRate/channelLayout/sampleFormat | Frames/channels различаются; planar/interleaved явно указаны; PCM scale, clipping и rounding выбраны. |
| `Encoded` | Buffer + mediaType | Содержит кодированные байты, а не уже декодированное изображение/звук. |
| `NetworkAddress` / `Uri` | Точные адресные bytes/family/port/scope либо компоненты URI | IPv4/IPv6/local отличаются; port хранится как число, host/network byte order преобразуется явно. DNS имя не готовый socket address; percent encoding и IDN policy не угадываются. |
| `Duration` | Нормализованные seconds/nanoseconds | Интервал отличается от instant/epoch; native timeout sentinel трактуется только по договору API. |
| `Time` / `CivilTime` | i64 seconds + наносекунды + scale либо календарные поля | `scale` включает договор эпохи; UTC, TAI, GPS и monotonic не смешиваются. Наносекунды в `[0,10^9)`. Часовой пояс не берётся из скрытой настройки процесса. |
| `Resource` | owner/state/kind | `state` — ссылка на состояние ресурса в его владельце, а не произвольный C-адрес. Проверяется точный backend, lifecycle и реальная власть владельца; строка kind не является доказательством. |
| `MpiContext` | Ссылки на runtime, communicator и hints, threadSupport и collectiveMode | Точный MPI backend/ABI, состояние runtime, членство коммуникатора и разрешённый поток. Поля являются договором адаптера; свободно записанная строка не предоставляет права. |
| `Callback` | Callable, DATA context, owner, delivery, lifetime | Точная C-сигнатура, поток исполнения, длительность удержания и процедура unregister/quiescence. |
| `DbValue` / `DbRow` / `DbRows` | Явный вид значения, сами значения и имена | SQL NULL, BSON null, отсутствующее поле и пустые строка/Buffer различаются. Драйвер не округляет decimal через double молча. |
| `ParseNode` | Вид, значение, дети, begin/end | Интервалы относятся к выбранной кодировке/единице смещения; источник сохраняется для borrowed views. Не создаёт второго графа исполнения. |
| `GeoPoint` | longitude/latitude в градусах, height, referenceSystem | Геодезический профиль определяет высоту/датум. H3 требует явного degree→radian адаптера. |
| `Vector3` / `OrbitState` | Числа + unit/referenceFrame + time | Ось, km/m и TEME/ECEF/иные frame не угадываются по длине массива. |
| `Secret` | Buffer + owner/purpose | Размер ключа/nonce/tag определяется выбранным алгоритмом; секретные буферы имеют отдельный договор уничтожения. |
| `ComplexBuffer` | Tensor компонентов + layout/profile | `interleaved`: последняя ось длины 2; `planar`: первая ось длины 2; порядок real, imaginary. Тип обеих частей один, логическая complex-форма исключает эту ось. Native ABI требует отдельного допуска/pack. |
| `RealContext` / `DecimalContext` | Точность, округление, exponent profile, traps и exactRequired | Передаются как обычные достижимые данные. Никакой скрытый глобальный контекст не определяет результат. |
| `Complex` / `Rational` | Обычные Structures над выбранным scalar/bigint | У комплексных частей общий scalar profile; denominator рационального числа ненулевой, нормализация явна. |
| `Error` / `CallResult` | Состояние технического вызова и данные ошибки | Внутреннее представление адаптера; публичный метод сохраняет собственные return/throws и не обязан возвращать универсальную коробку. |
| `CallRequest` | `arguments:[]@`, явный context | Служебная DATA-модель конкретной обёртки. Она не разрешает универсальный вызов C по строковому имени и не заменяет типизированную сигнатуру. |

Имена `i64`, `size_t`, `double` и `unsigned` опираются на существующий
[primitive profile](../../../selfbuild/src/l2src/primitive.lm2), строки 19–50.
Здесь не вводится отсутствующее имя `longlong`.

## Где нужен конвертер, а где достаточно заимствования

На время синхронного вызова можно дать C библиотеке typed pointer в существующий
Array, когда совпадают тип, выравнивание, layout и ограничения aliasing; весь
вызов владелец и Array остаются живы, storage не меняется. Такой pointer не
сохраняется ни в результате L3, ни библиотекой после возвращения. Функция,
удерживающая указатель, получает отдельное принадлежащее ей хранилище либо
реализованную привязку lifetime. Сам факт `const T*` не доказывает, что C ничего
не удерживает. Правила следуют из [numeric/machine boundary](../../spec/LMX_semantics.en.md#mathematics)
и [L2 addresses](../../spec/L2_spec_en.md#lowlevel-address).

Когда данные расходятся по представлению, нужен явный pack/unpack. Например:

- cglm/linmath float matrices и обычный double Tensor требуют численного
  преобразования и согласования порядка элементов; `float*` не получается
  приведением `double*`.
- [Mint mt_tensor](../../../third_party/lmx_c99_compact/vendor/mint/mint.h),
  строки 461–466, содержит массив фиксированного предельного ранга и `mt_float*`;
  [Utensil ut_tensor](../../../third_party/lmx_c99_compact/vendor/utensil/utensil.h),
  строки 14–30, дополнительно имеет strides, owner, refcount и состояние CPU/GPU.
  Один `BridgeData\Tensor` подходит обеим библиотекам, но их native structs
  не взаимозаменяемы. GPU-состояние не объявляется CPU-совместимым лишь из-за
  наличия поля `data`.
- [Embeddings table](../../../third_party/lmx_c99_compact/extensions/embeddings/include/lmx_static_embeddings.h)
  использует row-major float32 и отдельные token IDs; размер, повторение IDs,
  nonfinite и запрет overlap берутся из его действующего договора, строки 13–50.
- NNoM q7/q15 требует отдельного `Quantization`: scale/zeroPoint, rounding и
  saturation. Уменьшение разрядности не является обычным копированием Tensor.
- Картинка RGBA8 может использовать тот же Buffer в нескольких codecs,
  однако channel order, gamma, alpha и row stride переводятся явно. Результат
  C-декодера освобождается его родным release/free после переноса в LMX Array.

## Плотный вид: signed strides, границы и права

`Tensor` описывает один существующий Array или View. `shape` содержит число
элементов по осям, `strides:[]i64` — **знаковые шаги в элементах**,
`offset:size_t` — смещение логического нуля в допущенном backing. `i64` здесь
является явным ограничением bridge-профиля, не синонимом любого native
`ptrdiff_t`. Адаптер проверяет каждое преобразование ширины: размеры, leading
dimensions, шаги, число элементов и число байт могут иметь разные типы C.
Скаляр иностранного rank-0 профиля преобразуется как скаляр; новый Array
нулевого ранга не вводится.

Тип элемента, его размер, фактический owner и доступный исходный регион
получаются из реального Array/TypeRef и binding. Строка `layout` не доказывает
contiguity, alignment или право записи. Тот же `Tensor` обслуживает row-major,
column-major, transposed, reverse и явно заданный broadcast View; для
неподдержанного видом backend требуется явный pack либо отказ до вызова.
Transpose меняет координатный доступ. Adjoint дополнительно сопрягает
значения и остаётся операцией выбранного scalar-профиля, а не флагом,
меняющим фактический тип Array.

Для непустой формы математические границы задаются так:

\[
t_k=(shape_k-1)\,strides_k,\qquad
lo=offset+\sum_k\min(0,t_k),\qquad
hi=offset+\sum_k\max(0,t_k).
\]

Обе границы должны лежать в допущенном backing. Вычисление выполняется
проверенной арифметикой, включая произведения формы, шагов и размера
элемента. Нельзя вычислять `abs(MIN_i64)`, сначала переполнять signed sum или
смешивать отрицательный stride с unsigned offset, а затем проверять итог.
Размеры length-1 и outer+1 также проверяются до вычисления. Формула является
математическим договором, а не фрагментом исполняемого кода.

Проверка bounding range необходима, но недостаточна для вложенного View:
его координатный план сначала допускается к **логической области
непосредственного источника**, затем композиция — к владельцу. Вид не
получает доступ к соседним элементам только потому, что они находятся в той
же allocation. Нулевой stride допускается только явным профилем вида;
overlap, включая более общие совпадающие координаты, требует отдельного
договора записи. `restrict`/no-alias C API не получает пересекающиеся input и
output без scratch. По умолчанию матричный VALUE-результат свежий; commit в
переданное назначение выполняется после допуска и успешного вычисления.

Пустая ось обнаруживается **до умножения размеров**. Такой Tensor имеет
ноль логических элементов, не вычисляет адрес элемента и не требует
существования последнего элемента. Остальные shape/stride метаданные и
правила пустого buffer выбранного ABI всё равно проверяются. Длина backing,
offset и byte capacity проверяются отдельно; пустота не легализует
неверный owner или переполнение native-параметра. Новая неявная broadcasting
семантика не вводится: [обычные Array operations](../../spec/LMX_semantics.en.md#array-operations)
сохраняют собственный договор формы.

В каталоге отделены две проверки. `tensorLayout` — общий signed-view договор
со статусом `REQUIRE_IMPLEMENTATION`. `nonnegativeTensorExtent` ссылается на
существующий [C99 reference](../new_primitives/conversion_bridge.c), принимающий
`size_t` strides. Этот reference проверяет только свой неотрицательный
подпрофиль; он не является реализацией signed View, допуска исходной
логической области или управления lifetime.

## Разреженные и комплексные значения без параллельных Tensor

`SparseMatrix.format` имеет значения `"csr"` или `"csc"`; `shape:[2]size_t`
хранит `(rows, columns)`. Для CSR внешняя ось — rows, внутренняя — columns;
для CSC наоборот. `indices` и `pointers` — обычные `[]size_t` с **нулевой**
базой. Адаптер другой базы изменяет индексы явно с проверкой арифметики,
не записывает второй флаг, противоречащий самим данным.

`values` ссылается на один из двух допущенных descriptors:

- `BridgeData\Buffer` с `count=nnz` для выбранного scalar-типа;
- `BridgeData\ComplexBuffer` с логической формой `(nnz)` и одним scalar
  profile для real/imaginary. Его Tensor компонентов имеет форму `(nnz,2)`
  либо `(2,nnz)` по выбранному layout.

`length(indices)=nnz`, `length(pointers)=outer+1`, первый pointer равен нулю,
последний равен nnz, промежуточные значения монотонны. Каждый внутренний
индекс меньше inner. При outer=0 pointers содержит единственный 0; при
inner=0 nnz=0. Проверяются границы Buffer, products и native index widths.
Разреженная матрица нулевой формы и непустая по форме матрица с nnz=0
различаются. При импорте [MAT sparse](../reference/knowledge_extra_matio.md)
конечный `jc[ncols]` задаёт активный nnz и допускается по `nir`, `ndata` и
реальному storage; `nzmax` — capacity, а не ещё одна логическая длина.
Native `mat_uint32_t` поля проверяются отдельно от LMX `size_t`. Расход
памяти opaque sparse backend может зависеть от rows/columns, а не только
nnz, поэтому shape и оценка allocation также входят в ресурсный допуск.

Порядок entries, повторные координаты и явно сохранённые нули сохраняются
при переносе. Простая модель хранения не задаёт математический reducer для
дубликатов. Если операция или native API требует unique/sorted coordinates,
нужен явный normalize с выбранным reducer/порядком либо отказ. Молча
сортировать, складывать дубликаты, удалять нули или создавать dense Array
нельзя: это меняет численную семантику, порядок эффектов или стоимость.

`Complex` хранит две части одного scalar-типа и контекста.
`ComplexBuffer.layout="interleaved"` добавляет последнюю компонентную ось
длины 2, `"planar"` — первую; индекс 0 означает real, 1 — imaginary.
Логическая complex-форма получается удалением этой оси, поэтому даже
пустой complex-вектор сохраняет различимые формы `(0,2)` и `(2,0)`.
Поле `profile` выбирает только допустимый числовой договор и сверяется с
фактическими типами; оно не переименовывает double в float или real.

Native split pointers, `kiss_fft_cpx`, C complex и обычная LMX Structure
не считаются ABI-совместимыми по одному числу компонентов. Конвертер
`complexBackend` выполняет проверенный borrow либо настоящий pack/unpack;
для двух отдельных native allocations требуется перенос в выбранный общий
layout с соблюдением их release. Конвертер `sparseMatrixBackend` повторно
использует проверку values/complex и native widths. Если библиотека
принимает opaque sparse object, адаптер создаёт его, заполняет допущенными
entries и связывает с реальным owner/release. Это не reinterpret-cast CSR.
Например, проверенный профиль liquid-dsp обязан учитывать native ширину
координат, замену повторной координаты при set/insert и запрет alias output
при multiply. Его бинарный sparse product использует GF(2), что не совпадает
с OR/AND Boolean product. Общего sparse GEMM или factorization backend эти
DATA-модели не обещают. Конкретные выбранные
численные возможности и незаполненные интеграционные пункты перечислены в
[матричном каталоге](../matrix/README.ru.md).

## Числа и форматы

Канонический произвольно-точный `real` использует LibBF и отдельный
`RealContext` с точностью в битах. Он не равен `double`: работающий
[real_provider.c](../new_primitives/real_provider.c) хранит `1+2^-100` при
256 битах и отказывает в сужении до binary64, если требуется точность.
`double` сохраняет свой машинный договор. Fixed-point, SoftFloat и FP16 —
разные вычислительные/форматные профили с явными конвертерами.

`fixedPoint` преобразует Q16.16/Q7/Q15 по `Quantization`: положительный
конечный scale, zeroPoint, rounding и saturation/error. Saturation при
конверсии не обещает saturating arithmetic внутри матричного backend:
[libfixmatrix](../reference/numeric_extra_libfixmatrix.md) вычисляет с flags
overflow/domain, а выбранный метод обязан интерпретировать их до публикации
результата. Если его арифметика не удовлетворяет выбранному профилю, нужен
другой допущенный путь.

`binaryFloatFormat` преобразует IEEE floating encodings и явно выбранный
ARM alternative half. Здесь нет scale/zeroPoint от Quantization: поле
экспоненты, subnormals, signed zero и доступность NaN/Inf относятся к
другому договору. Один word `0x7c00` означает infinity в IEEE binary16 и
65536 в ARM alternative half; это не взаимозаменяемые профили
[FP16](../reference/numeric_extra_fp16.md). Адаптер выбирает реальную функцию
семейства ieee/alt, проверяет её rounding и exactness; отсутствие
произвольного rounding нельзя замаскировать полем `RealContext`.

[SoftFloat](../reference/numeric_extra_softfloat.md) использует те же
правила floating-формата, а его global/thread-local rounding, tininess и
exception flags оборачиваются owner-side save/map/restore. Наличие context
в LMX не делает библиотеку автоматически reentrant. Ни один из этих
конвертеров не превращает произвольный real/decimal в double промежуточно
или не обещает, что матричные routines умеют арифметику binary16.

Основной `decimal` опирается на MPDecimal; decNumber, decimal32/64/128 и
decSingle/Double/Quad остаются alternate representations либо wire formats.
LibBF `bfdec_t` добавляет ещё один backend. Их названия не становятся
параллельными публичными decimal-типами. Несколько библиотек с одинаковыми
задачами намеренно сохраняются как независимые реализации: объединяются
LMX-данные и интерфейсы, а не сами библиотеки. Конвертер
переносит значение и выбранный контекст; enum rounding и status bits сопоставляет
по смыслу, не числовым cast. Десятичное значение не проходит через `double`.
Работающий C99 пример MPDecimal↔decNumber —
[numeric_provider.c](../new_primitives/numeric_provider.c). Конвертеры
LibBF-decimal и IMath пока помечены `REQUIRE_IMPLEMENTATION`; обычное
приведение `mp_int*` между LibTomMath и IMath запрещено, несмотря на сходные
имена typedef. Нормализованное `bfdec_t` не обязано сохранять decimal quantum,
поэтому нужный scale/quantization переносится явно либо конверсия отказывается.

JSON/XML/YAML/TOML/BSON/MessagePack/protobuf — внешние форматы. Общие ParseNode,
DbValue или собственный LMX graph служат обмену; это не делает JSON обязательной
частью языка и не заменяет собственные LMX механизмы копирования/сериализации.
В каталоге сохранены все API подключённых библиотек независимо от того,
понадобится ли конкретный внешний формат приложению.

## Научные массивы и локальная распределённая работа

HDF5, netCDF, MAT и PnetCDF используют общие `Tensor`, `Hyperslab`, `Buffer`,
`DbValue` и `Resource`; sparse/complex MAT использует также `SparseMatrix`
и `ComplexBuffer` с отдельными проверенными конвертерами. Идентификатор набора данных не является самим массивом:
файл, datatype, dataspace, property list, variable и группа имеют разные виды
ресурсов и правила закрытия. Новые числовые примитивы для этих форматов не
нужны. Численный тип, размерность, порядок байтов, compound layout, sparse
representation и точность проверяются при чтении и записи. HDF5 datatype ID
не заменяет фактический тип элемента LMX Array.

Даже C-параметр вида `int ncid` является здесь ресурсным идентификатором,
а не свободным LMX `int`. Для netCDF/PnetCDF файлы и группы получают
owner-bound `Resource`; output ID после успешного создания регистрируется
у владельца. Variable/dimension/type IDs проверяются в области этого
файла/группы. Поэтому научные backend не используют direct-scalar путь
генератора даже для внешне простой сигнатуры `nc_close(int ncid)`.

`Hyperslab` описывает координаты в хранимом массиве, а `Tensor.strides` —
расположение элементов в памяти LMX. Unsigned file-selection stride не
переименовывается в signed memory stride; допустимый знак/шаг определяется
конкретным native API. Эти пространства не смешиваются.
Адаптер проверяет совпадение числа выбранных элементов, преобразует ширину
native count/offset и сохраняет отдельные sentinel/empty-selection правила
каждого API. Для нерегулярного списка точек нужен явный Tensor координат;
он не маскируется под непрерывный блок. Фильтры, компрессия, unlimited
dimensions и async/parallel операции доступны только в реально выбранном
профиле backend. Контракт находится в `scientificSelection` из
[converters.lmx](converters.lmx).

`MPI_Comm`, `MPI_Info`, `MPI_Datatype` и `MPI_Request` представлены точными
видами `Resource`, связанными с конкретным MPI runtime. Это не новые
математические integers и не переносимые куски bytes. `MpiContext` объединяет
runtime, communicator, hints и проверяемые правила исполнения. В одном
процессе допустимы ссылки нескольких акторов на один ресурс, если соблюдены
владелец, сериализация и уровень MPI thread support. Общее immutable
определение LMX-пакета по-прежнему удерживается ссылкой; оно не размножает MPI
communicator и не даёт каждому актору собственного runtime.
Реально предоставленный уровень thread support определяется результатом
[MPI_Init_thread](https://www.mpi-forum.org/docs/mpi-5.0/mpi50-report/node269.htm),
а не только запрошенной настройкой.

Raw MPI handle нельзя отправить на другой процесс или узел как
самодостаточное значение. Там требуется создание либо коллективное
согласование ресурса в соответствующем runtime. `MPI_Comm_dup` сам является
коллективной операцией; его нельзя молча вызывать из обычного копирования
LMX-графа. Адаптер PnetCDF различает коллективный и независимый I/O, порядок
участия ranks и завершение неблокирующих запросов. До завершения request
удерживает все buffers и datatypes; закрытие файла или финализация runtime
не может освобождать их преждевременно. `MPI_Offset` и `MPI_Count`
преобразуются с проверкой native width. Отдельный договор `mpiResource`
сохраняет эти условия независимо от численного ABI конкретной MPI-сборки.
Исходные договоры: [MPI communicator constructors](https://www.mpi-forum.org/docs/mpi-5.0/mpi50-report/node190.htm)
и [PnetCDF nonblocking I/O](https://parallel-netcdf.github.io/wiki/CombiningOperations.html).
Buffered `bput` допускает раннее освобождение пользовательского буфера только
после успешного копирования в принадлежащий PnetCDF буфер; обычные `iput/iget`
такого разрешения не дают ([PnetCDF FAQ](https://parallel-netcdf.github.io/doc/faq.html)).

## Ресурсы, actor copy и callbacks

Bootstrap передаёт ссылки на выбранные `independent: immutable:` определения.
Сами объекты, CODE и неизменяемые DATA не копируются; их фактический владелец
удерживает их в своей арене. Общие модели и определения конвертеров могут
использоваться всеми акторами через эти ссылки. `Message` не наследует весь
R0 автоматически. Mutable invocation DATA, нативные workspaces и состояния
ресурсов принадлежат конкретному владельцу; sharing определения не открывает
новый сокет и не копирует чужой live handle.
Вызов-конструктор создаёт внешний ресурс в контексте конкретного владельца.
`copy` ресурса должен либо явно отказать, либо использовать определённое
дублирование/reopen; `memcpy(C_pointer)` между аренами не является реализацией.
Текстовая сериализация может содержать рецепт повторного открытия, если это
разрешено контрактом, но не живой адрес и не обещание восстановить ту же сессию.

Синхронный callback на том же потоке вызывает обычный LMX callable с его
реальными DATA/parent. Callback внешнего потока помещает событие в допустимую
очередь/Message и не обращается напрямую к чужой mutable arena. C API, которому
нужен немедленный ответ из callback, требует owner-side исполнения или другого
явно реализованного договора; нельзя подменить такой callback асинхронным
событием и заявить эквивалентность. До unregister и завершения всех callback
объекты callable/context остаются живы. Переход ошибки через C ABI определяется
протоколом C: статус/return/buffer, а не произвольный longjmp сквозь frames.

Это следует из [single-arena ownership](../../spec/L2_spec_en.md#arena),
[graph copying](../../spec/LMX_semantics.en.md#composition) и
[обычного binding](../../spec/LMX_semantics.en.md#binding-places).

## Применение к конкретной функции

Для каждой C-сигнатуры агент фиксирует направление каждого параметра, его
модель, optional/null policy, единицу длины, aliasing, mutation, retention,
результат и ошибки. Затем выбирает запись из [converters.lmx](converters.lmx)
либо добавляет узкий конвертер при реальном различии договора. Объединяются
данные и алгоритмы преобразования, а не несовместимые смысловые операции.

Запись `IMPLEMENTED_REFERENCE` означает, что соответствующая C-функция есть в
поставленном руководстве и прошла указанные [проверки](../new_primitives/VERIFICATION.json).
`REQUIRE_IMPLEMENTATION` означает закрытый интеграционный пункт. Нельзя
автоматически публиковать в L3 все функции такой строки. Общая модель не
доказывает проверенность каждого API, не заменяет его throws и не превращает
непроверенный C backend в защищённый интерпретируемый LMX-код.
