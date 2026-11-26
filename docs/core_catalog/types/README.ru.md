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
| `Tensor` | Один Array, `shape`, `strides` в элементах, offset, layout | Ранг равен длине shape/strides; максимальный адрес в Array; тип и размер элемента; ограничения конкретного backend. |
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
| `ComplexBuffer` | Tensor компонентов + layout/profile | Interleaved/planar и scalar precision явны. `kiss_fft_cpx`, C complex и пары LibBF требуют pack/unpack по реальному ABI. |
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

Матрицы и тензоры остаются `Array + shape/strides`. Новая неявная broadcasting
семантика не вводится. Нулевой stride допустим только для явно выбранного
описания вида; запись в перекрывающиеся элементы требует отдельного договора.
Пустой Tensor может иметь нулевой логический размер; это не разрешает получить
адрес несуществующего элемента. Базовые [Array operations](../../spec/LMX_semantics.en.md#array-operations)
сохраняют собственный договор равенства длин.

## Числа и форматы

Канонический произвольно-точный `real` использует LibBF и отдельный
`RealContext` с точностью в битах. Он не равен `double`: работающий
[real_provider.c](../new_primitives/real_provider.c) хранит `1+2^-100` при
256 битах и отказывает в сужении до binary64, если требуется точность.
`double` сохраняет свой машинный договор. Fixed-point, SoftFloat и FP16 —
другие вычислительные/форматные профили с теми же явными конвертерами.

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
`DbValue` и `Resource`. Идентификатор набора данных не является самим массивом:
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
расположение элементов в памяти LMX. Эти пространства не смешиваются.
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
