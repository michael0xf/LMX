# Матричные операции: существующие backends, точное подключение и альтернативы

Редакция **2026-11-28**. Нормативная семантика — [TENSOR_EXPRESSIONS.md](../../spec/TENSOR_EXPRESSIONS.md), особенно §7.7, §7.41 и §11.5. Общие модели — [types/README.ru.md](../types/README.ru.md); единственный C bridge — [CATALOG_FORMAT.ru.md](../CATALOG_FORMAT.ru.md) и [BridgeLower](../bridge/lowering_contract.lmx).

## 1. Что подтверждено и что ещё нужно реализовать

Архив документации содержит канонические C-каталоги и LMX-тела вызовов. Для этой проверки дополнительно восстановлен предоставленный пользователем **`third_party.tar.gz` от 26-Nov** с теми же 180 компонентами (SHA-256 `c73028f3aadacd6ed93d4537ca91f4d3a3159467468c89d6ba31e88daf077457`). Его vendor-дерево использовалось только для чтения. Перечень проверен по [catalog_summary.json](../catalog_summary.json), полному [индексу символов](../catalog_index.json.gz) и фактическому `third_party/lmx_c99_compact/SOURCES.json`. Существенные upstream-файлы прочитаны на **commit каталога** и сверены с локальными исходниками: различий в рассмотренных алгоритмах не найдено. Проверены также CMake-adapters/build views. Выполнен ограниченный native C probe (§7); это отдельно от ещё не выполненного LMX bridge.

Различаются четыре состояния:

| Слой | Подтверждение в этом комплекте |
|---|---|
| Библиотечный API | Конкретные `capi_*`, сигнатуры, pinned local/upstream sources; фактический CMake target/profile |
| LMX-вызов C API | Конкретное тело в `bindings/*.lm3`: `BridgeLower\open`, один `c.lmx_bridge_*`, `finish`, `finally/release` |
| Отображение математики на C | Здесь описаны допуски и добавлены LMX-связи; `prepare`, `finish`, pack/unpack и реальное связывание `BridgeLower` ещё требуются |
| Native probe / весь путь `[op] → backend` | Ограниченные C-пробы **PASS, 12 случаев**, проверены 14 symbols в probe. Production parser, C-shim bridge и LMX runtime **NOT_RUN** |

`UPSTREAM_REVIEWED_BRIDGE_UNBOUND` в [backend_profiles.lmx](backend_profiles.lmx) означает проверенный кандидат с незавершённым bridge. `LIMITED_BRIDGE_UNBOUND` дополнительно подчёркивает узкую область метода. Оба состояния **не означают** готовую реализацию общего оператора.

### 1.1. Как эти реализации уже подключены в архиве third_party

Пути ниже относительны `third_party/lmx_c99_compact`. Это фактические объявления сборки; заготовка матричного LMX adapter не добавляет вторую копию библиотеки.

| Target | Существующий build adapter | Выбранный профиль / связь |
|---|---|---|
| `LMX::liquid_dsp` | `extensions/acoustic/CMakeLists.txt`, `cmake/build_views.py` внутри acoustic | STATIC, 22 official modules/157 C translation units; включает все четыре dense matrix families и smatrixb/f/i; scalar configuration, internal FFT; `LMX::correct_fec`, Threads, libm |
| `LMX::linmath` | `cmake/Scientific.cmake` | INTERFACE; generated C99 header убирает несовместимую до C23 array-qualifier форму, vendor header сохраняется; libm |
| `LMX::cglm` | `extensions/extras/CMakeLists.txt` | STATIC, перечислены все Call API units; `CGLM_STATIC`, `CGLM_USE_ANONYMOUS_STRUCT=0`; также сохранены inline headers |
| `LMX::fixmatrix` | `extensions/numeric_extra/CMakeLists.txt` | STATIC из libfixmatrix sources; зависит от `LMX::fixmath` с `FIXMATH_NO_CACHE`; размер mf16 по default 8, если весь согласованный профиль явно не переопределён |
| `LMX::cminpack` | тот же numeric_extra adapter | STATIC из `src/*.c`, `CMINPACK_NO_DLL`; default double, `USE_LAPACK`/внешний BLAS этим adapter не включены |
| `LMX::mint` | `extensions/tensors/CMakeLists.txt`, `scripts/mint_view.py` | INTERFACE, reviewed generated header, `LMX_MINT_TENSORS_ONLY=1`; CPU tensor subset включает matmul, исключает model loader/runner и отдельный adaptive pooling helper |
| `LMX::utensil` | tensors adapter, `cmake/UtensilView.cmake` | INTERFACE, generated header, **`LMX_UTENSIL_CPU_ONLY=1`**. Внешне связанные функции header включаются ровно в одну translation unit либо через отдельный declaration facade; это не пустая `.a` |
| `LMX::klib` | `cmake/KLIB.cmake` | STATIC, в списке явно есть `keigen.c`; eigen не зависит от optional POSIX-категорий klib |

Следовательно, source catalogue шире некоторых выбранных build surfaces: Mint model API и Utensil Metal нельзя объявить подключёнными лишь по наличию upstream declarations. Сопоставление заголовка generated view, compile definitions и конкретной C entry сохраняется при генерации shim. Хеши прочитанных build files и исходников находятся в [validation_report.json](validation_report.json).

## 2. Выбор альтернатив внутри имеющегося набора

«Пригодный кандидат» ниже означает соответствие математической задаче после перечисленных проверок; ни одна строка не обходит общий числовой и ABI-допуск.

| Задача | Пригодный кандидат из описанного third_party | Ограниченные альтернативы / пробел |
|---|---|---|
| Плотное `A [*] B`, rank-2 real | `liquid`: `matrixf_mul`/`matrix_mul`; для float также Mint `mt_matmul`, Utensil `ut_matmul` | `linmath`/`cglm` для фиксированных малых форм; libfixmatrix только явно выбранный Q16.16 |
| Плотное комплексное произведение | `liquid`: `matrixcf_mul`/`matrixc_mul` | Проверяется actual complex ABI; float-пакеты не принимают complex через reinterpret-cast |
| Пакетное произведение | Utensil: ровно `(B,M,K) × (B,K,N)` | Общий broadcast, rank-1 promotion и несколько batch-осей нормализует единый LMX-план, затем вызывает rank-2 kernels. Native Utensil не реализует весь auto-matmul |
| Транспонирование / adjoint | Общая геометрия LMX; materialized-кандидаты liquid, linmath, cglm | У liquid нетривиальное соответствие имён, см. §3.1; у linmath transpose нельзя выполнять in-place |
| Sparse matvec / sparse matmul | `liquid smatrixf_vmul` / `smatrixf_mul` после конверсии CSR/CSC в native handle | Нет прямого CSR/CSC ABI. Native координаты `unsigned short`; sparse double/complex в этом API не подтверждены |
| QR real, прямоугольная матрица | `cminpack qrfac` + преобразование компактных факторов; `qform` при необходимости явного Q | Профиль double, native `int`, column-major; не готовый многокомпонентный LMX-результат. libfixmatrix — малый Q16.16/full-column-rank. liquid QR — только square |
| Линейные least squares, full-column-rank real | Сборка адаптера из CMINPACK QR, применения Q и треугольного решения | `qrsolv` — отдельный алгоритм с диагональной регуляризацией. libfixmatrix QR+solve — bounded fixed-point. SVD-пороговый minimum-norm договор этим не закрыт |
| Квадратное `[\]`/`[/]`, real/complex | Возможен адаптер на существующих примитивах, но общий готовый корректно диагностирующий backend здесь не подтверждён | liquid `linsolve`/`inv` теряют внутренний status; libfixmatrix требует ранее вычисленных Q,R и явной fixed-point политики. Нельзя заменить solve на inverse без согласования |
| Pivoted LU, надёжная общая determinant/inverse | **Пробел в проверенных интерфейсах** | liquid Crout/Doolittle возвращают `P=I`; это unpivoted LU. Малые graphics inverse не заменяют общий численный профиль |
| Cholesky | liquid real/complex; libfixmatrix Q16.16 | Проверка полной symmetry/Hermitian/SPD, положительного диагонального фактора, status и невязки — часть адаптера. См. ограничения §3.1/§3.3 |
| `eig` real symmetric | `klib ke_eigen_sd` | Только real `double`; разрушается рабочая A, явные eps/iterations. Это не complex Hermitian, general eig, generalized eig или Schur |
| Общие SVD/Schur/pinv/nullspace, matrix exp/log/sqrt | **Нет подтверждённого исполнителя полного договора** | Не объявлять поддержку через имя нейросетевого/ODE/scalar пакета. Нужен отдельный алгоритм или новая явно подключаемая библиотека |
| Точные rational / arbitrary-precision матрицы | Общий LMX-обход с подходящим скалярным профилем уже описанных imath/libtommath/libbf/mpdecimal и др. | Это направление реализации, не имеющийся native GEMM/LU. Нельзя молча сужать к float/double |
| Норма вектора / scalar math | `cminpack enorm`; существующие scalar providers | Euclidean vector norm не matrix operator 2-norm; Cephes complex scalar API не комплексный matrix solver |

Среди самостоятельных компонентов каталога нет BLAS, LAPACK или SuiteSparse. `MT_USE_BLAS` у Mint и `USE_LAPACK` у CMINPACK — **опции внешней сборки**, а не доказательство вложенного backend. Их активация требует отдельной зависимости, конфигурации, проверки ABI и фактических symbols. KANN строит вычислительный граф нейросети; NNoM предлагает embedded/quantized NN-профили; liblsoda — ODE solver, cmpfit/liblbfgs — нелинейная оптимизация. Их публичный каталог не даёт права автоматически объявлять общий linear solve/SVD. `base:sparse_grid_hw` — квадратуры на разреженных сетках, не CSR-алгебра.

## 3. Контракты конкретных библиотек

<a id="liquid"></a>
### 3.1. liquid-dsp: наиболее широкое покрытие, но важны реальные тела

[Каталог](../catalog/acoustic_liquid_dsp.lmx), [LMX-тела](../bindings/acoustic_liquid_dsp.lm3), target `LMX::liquid_dsp`, commit `10041f70cebbe3b97887e75bb41e48b73dda1b23`.

Семейства `matrixf`, `matrix`, `matrixcf`, `matrixc` используют соответственно `float`, `double`, `float complex`, `double complex`. Матрицы — плоские row-major массивы; размеры передаются отдельно как `unsigned int`, arbitrary strides/offset API не принимает. Shape, products и byte lengths проверяются до narrowing. Исходные данные заимствуются только при доказанном layout/ABI; иначе используется управляемая упаковка.

**Имена и действие pinned math-файла:**

| Native API | Реальное математическое действие | LMX-назначение |
|---|---|---|
| `matrixcf_hermitian` | Перестановка осей без conjugation | `transpose` |
| `matrixcf_trans` | Перестановка осей с conjugation | `adjoint` |
| `*_mul_transpose`, `*_transpose_mul` | `X Xᴴ`, `Xᴴ X` | Только соответствующий Gram-профиль |
| `*_mul_hermitian`, `*_hermitian_mul` | `X Xᵀ`, `Xᵀ X` | Билинейный профиль без conjugation |
| `*_div(X,Y,Z,n)` | `X inv(Y)` | Порядок совпадает с `[/]`, но алгоритм и ошибки требуют отдельного допуска |

В [HTML-руководстве](https://liquidsdr.org/doc/matrix/) для `div` написан обратный порядок `inv(Y) X`. Здесь основанием служит [pinned `matrix.math.proto.c`](https://github.com/jgaeddert/liquid-dsp/blob/10041f70cebbe3b97887e75bb41e48b73dda1b23/src/matrix/src/matrix.math.proto.c). При обновлении commit соответствие перепроверяется. `*_mul` пишет в выход по мере вычисления: перекрытие выхода с входом не допускается. `_trans`/`_hermitian` изменяют переданный scratch и требуют отражения переставленной shape. Gram-варианты с `conjf` не принимаются за гарантированный double-complex профиль без проверки промежуточной точности.

Проверка factorization/solver-файлов выявила ограничения, которые нельзя исправить переименованием wrapper:

- [`matrix.inv.proto.c`](https://github.com/jgaeddert/liquid-dsp/blob/10041f70cebbe3b97887e75bb41e48b73dda1b23/src/matrix/src/matrix.inv.proto.c): `inv` игнорирует результат `gjelim`; pivot magnitude хранится во `float` даже для double family. Внешний `LIQUID_OK` не доказывает невырожденность.
- [`matrix.linsolve.proto.c`](https://github.com/jgaeddert/liquid-dsp/blob/10041f70cebbe3b97887e75bb41e48b73dda1b23/src/matrix/src/matrix.linsolve.proto.c): один RHS-vector, `_opts` игнорируется; status `gjelim` также не передаётся наружу.
- [`matrix.ludecomp.proto.c`](https://github.com/jgaeddert/liquid-dsp/blob/10041f70cebbe3b97887e75bb41e48b73dda1b23/src/matrix/src/matrix.ludecomp.proto.c): Crout/Doolittle не выбирают pivot, выходная P — identity. Матрица с нулевым ведущим pivot может быть обратимой; следовательно, «det=0 / inverse failed» из такого пути не является доказательством singularity.
- [`matrix.qrdecomp.proto.c`](https://github.com/jgaeddert/liquid-dsp/blob/10041f70cebbe3b97887e75bb41e48b73dda1b23/src/matrix/src/matrix.qrdecomp.proto.c): принимается только квадратная матрица; Gram–Schmidt, без рангового cutoff, нормировка через `float ek`/`sqrtf`. Это не rectangular/pivoted QR и не полный double-precision QR.
- [`matrix.chol.proto.c`](https://github.com/jgaeddert/liquid-dsp/blob/10041f70cebbe3b97887e75bb41e48b73dda1b23/src/matrix/src/matrix.chol.proto.c): используется нижний треугольник, полной проверки Hermitian нет; нулевой pivot не исключается строгой положительностью. Адаптер требует отдельной проверки входа и результата.
- Несколько методов создают временные VLA на C stack. Проверка произведений размеров и предела scratch/stack обязательна; обычного ограничения размера выходного Array недостаточно.

До исправления/обхода этих ограничений `inv`, `linsolve`, `div`, общий pivoted `lu`, generic `det` **не включаются автоматически** в стандартный solver-профиль. Для `[/]` допускается решение транспонированной системы с явно согласованной ориентацией; заменять transpose на adjoint при complex нельзя.

**Sparse-кандидат.** [`smatrix.proto.c`](https://github.com/jgaeddert/liquid-dsp/blob/10041f70cebbe3b97887e75bb41e48b73dda1b23/src/matrix/src/smatrix.proto.c) хранит собственные списки по строкам и столбцам, не CSR/CSC. Последовательность подключения: проверить SparseMatrix → создать handle → перенести уникальные координаты → вызвать операцию → извлечь результат → уничтожить/передать управляемого owner. `set` заменяет повторную координату; duplicate folding заранее задаётся политикой. Shape положительная, coordinate index должен помещаться в `unsigned short`, sizes — также в native `unsigned`. `mul` очищает output до чтения; output должен отличаться от обоих inputs. `vmul` обнуляет y, поэтому x/y не перекрываются. `smatrixb` считает по модулю 2: это GF(2), не обычный Boolean OR/AND. `smatrixi` использует short; точную целочисленную семантику без анализа переполнений ему приписывать нельзя. Пустые формы обрабатываются общим LMX-планом до native create.

<a id="small-float"></a>
### 3.2. linmath и cglm: малые матрицы с layout-контрактом

[linmath-каталог](../catalog/base_linmath.lmx), [тела](../bindings/base_linmath.lm3), target `LMX::linmath`; [pinned header](https://github.com/datenwolf/linmath.h/blob/3eef82841046507e16a0f6194a61cee2eadd34b3/linmath.h).

`mat4x4` — `float`, четыре столбца `vec4`. `mat4x4_mul` использует временную матрицу, поэтому точное alias выхода со входом допустимо внутри native API. `mat4x4_transpose` прямо требует раздельных буферов. `mat4x4_mul_vec4` нельзя автоматически считать безопасным при перекрытии v/result. `mat4x4_invert` не возвращает singular status. `mat4x4_from_vec3_mul_outer` строит специальную 4×4 форму из vec3: это не общий `[* ()]` с результатом `(m,n)`.

[cglm-каталог](../catalog/extras_cglm.lmx), [тела](../bindings/extras_cglm.lm3), target `LMX::cglm`; pinned [types.h](https://github.com/recp/cglm/blob/888aca08d5bdf38e873ec23d6cac42d7f23a669c/include/cglm/types.h) и [mat4.h](https://github.com/recp/cglm/blob/888aca08d5bdf38e873ec23d6cac42d7f23a669c/include/cglm/mat4.h).

cglm предлагает float-векторы, mat2/mat3/mat4 и некоторые несquare формы. Индексация column-major; имя `mat4x3` означает четыре столбца и три строки. Inline `glm_*`, linked `glmc_*` и struct API — разные ABI-поверхности. Выравнивание выбирается actual сборкой (`mat4`: обычно 16, при AVX 32 bytes; возможен согласованный unaligned-profile). Строка `layout` не подтверждает адресное выравнивание. Для общего adapter безопасный default — отдельный выход; native in-place разрешается только по конкретной функции. Graphics `inv` без диагностического результата не закрывает общий `solve`.

<a id="fixed"></a>
### 3.3. libfixmatrix: осмысленная fixed-point альтернатива

[Каталог](../catalog/numeric_extra_libfixmatrix.lmx), [тела](../bindings/numeric_extra_libfixmatrix.lm3), target `LMX::fixmatrix`; [header](https://github.com/PetteriAimonen/libfixmatrix/blob/a8d583e4fe1fa27ba2e0ec55970f73a1b1e6928b/fixmatrix.h) и [implementation](https://github.com/PetteriAimonen/libfixmatrix/blob/a8d583e4fe1fa27ba2e0ec55970f73a1b1e6928b/fixmatrix.c).

Это Q16.16, положительные dimensions до build-specific `FIXMATRIX_MAX_SIZE` (**default 8**), внутри полный padded row-major блок. `rows`/`columns` — `uint8_t`; профиль должен согласовать макрос размера и ABI. Произвольный `Tensor` сначала проходит `fixedPoint` с явным rounding/range/saturation договором.

Арифметика самой библиотеки **не saturating**. Флаги `OVERFLOW`, `DIMERR`, `USEERR`, `SINGULAR`, `NEGATIVE` читаются из фактических выходных структур; C `void` не означает успех. Входные errors не очищаются ради получения красивого результата. `mf16_mul` использует native temp при точном alias; частичное перекрытие не выводится из этого разрешения.

QR — modified Gram–Schmidt с явным `reorthogonalize`, economy при `m≥n`, только full-column-rank. Проверяются Q и R. `mf16_solve(dest,q,r,B)` принимает **готовые Q,R**, поддерживает несколько RHS и допускает alias с B/Q, но не R. Cholesky читает нижний треугольник без проверки symmetry и при некоторых отрицательных промежуточных значениях округляет к нулю; нулевой диагональный фактор не становится SPD-успехом. Это отдельный fixed-point профиль, не fallback для `double`/exact rational.

<a id="dense-tensors"></a>
### 3.4. Mint и Utensil: dense float kernels без общего tensor-контракта LMX

Mint: [каталог](../catalog/tensors_mint.lmx), [тела](../bindings/tensors_mint.lm3), `LMX::mint`, [pinned mint.h](https://github.com/ariaghora/mint/blob/8002e1adf8cfbe3b1886b8b69b924a768e3a9705/mint.h).

`mt_tensor` содержит `data`, `ndim`, фиксированный shape-массив; native stride-поля нет. Для `mt_matmul` здесь принимается только rank2×rank2 с dense row-major storage и проверенными `int`-размерами/произведениями. Ветви rank1 в pinned коде не совпадают со всеми LMX vector-promotion случаями; они не используются для автоматического matvec. Default `mt_float=float`; изменение typedef/macro само по себе не доказывает корректность всех SGEMM/SIMD-путей. `mt__*` — внутренние helpers, не публичный контракт вместо `mt_matmul`. Результат владеет native data и освобождается `mt_tensor_free`; wrapper не должен освобождать таким способом заимствованный LMX buffer. Assertions и непроверенные allocation paths upstream требуют реального bridge-допуска; запись `NOT_RUN` не снимается одной конверсией типов.

Utensil: [каталог](../catalog/tensors_utensil.lmx), [тела](../bindings/tensors_utensil.lm3), `LMX::utensil`, [pinned utensil.h](https://github.com/zserge/utensil/blob/e6e77dd4eef2c5e9df336c2aa629096dc3ffa143/utensil.h).

`float`, максимум четыре shape-оси, `int` dimensions/nelem. Публичный `ut_matmul` принимает rank2 и equal-batch rank3; результат новый, mismatch — `NULL`. Generic stride/broadcast не следует из наличия stride-массива: конкретный matmul индексирует плотные блоки. `ut_matmul_t` — `static` helper, а не обещание стабильного внешнего transpose API. Native `ut_retain`/`ut_free` и `owner` удерживают views; это отдельный lifetime от LMX ссылки. `ut_transpose` материализует результат. CPU/Metal выбор и синхронизация являются частью профиля; Текущий adapter прямо выбирает `LMX_UTENSIL_CPU_ONLY=1`; Metal этим target не предоставляется. Shared native refcount/device-state не объявляются thread-safe без проверки.

<a id="cminpack"></a>
### 3.5. CMINPACK: альтернатива QR, а не универсальная LAPACK

[Каталог](../catalog/numeric_extra_cminpack.lmx), [тела](../bindings/numeric_extra_cminpack.lm3), `LMX::cminpack`, commit `49a7ea4e6edf5c7cd4850a163d8530c3f7d8638c`. Точная [C-поверхность](https://github.com/devernay/cminpack/blob/49a7ea4e6edf5c7cd4850a163d8530c3f7d8638c/include/cminpack.h) в каталоге раскрыта как double-profile; другие macro-precision builds требуют отдельной проверки.

[`qrfac`](https://github.com/devernay/cminpack/blob/49a7ea4e6edf5c7cd4850a163d8530c3f7d8638c/src/qrfac.c) поддерживает rectangular Householder QR и optional column pivoting. A хранится column-major с `lda≥m`, изменяется на компактный набор отражений и часть R; диагональ R возвращается отдельно. `ipvt` **1-based**, так что перенос в обычную нулевую `Permutation` явный и проверяемый. `m,n,lda,lipvt` — C `int`; никакого implicit `size_t*→int*`. Для явного Q вызывается `qform` с достаточной ёмкостью полного/выбранного результата; нельзя считать исходный compact A готовым Q.

[`qrsolv`](https://github.com/devernay/cminpack/blob/49a7ea4e6edf5c7cd4850a163d8530c3f7d8638c/src/qrsolv.c) решает least-squares задачу по уже подготовленным `R`, перестановке, первым n компонентам `Qᵀb` и диагональному штрафу D. Он изменяет нижний треугольник R. Это полезный строительный блок regularized LS, но не вызов `leastSquares(A,B)` и не гарантия SVD minimum-norm для rank-deficient A. `lmdif`/`lmder` решают нелинейные callback-задачи и не подменяют линейный профиль.

`enorm` — кандидат для Euclidean vector norm. Work arrays, изменяемые buffers и callback return codes проверяются по каждой entry. Если реально включён `USE_LAPACK`, нужно отдельно подтвердить LP64/ILP64 integers, precision, symbols и совпадение caller/callee ABI; наличие macro в исходнике не меняет каталожную сигнатуру LMX.

<a id="klib"></a>
### 3.6. klib: узкая спектральная альтернатива

[Каталог](../catalog/base_klib.lmx), [тела](../bindings/base_klib.lm3), `LMX::klib`; pinned [keigen.h](https://github.com/attractivechaos/klib/blob/97a0fcb790b43b9e5da8994f4671021fec036f19/keigen.h) и [keigen.c](https://github.com/attractivechaos/klib/blob/97a0fcb790b43b9e5da8994f4671021fec036f19/keigen.c).

`ke_eigen_sd(n,a,v,cal_ev,eps,max_iter)` принимает dense real symmetric `double`, row-major scratch `a`, отдельный vector собственных значений `v`. При `cal_ev` eigenvectors размещаются в a по столбцам; исходная A теряется. Требуются `n>0`, checked native `int`/`n*n`, symmetry/finite policy и неперекрывающиеся outputs. `0` означает завершение, `KE_EXCESS_ITER=-1` — незавершение, которое не публикуется как полный eig. Upstream default eps/iteration нельзя молча выдавать за выбранную точность LMX. Требуемые ordering, нормировка, residual и привязка eigenvectors к values проверяются адаптером. General complex/generalized eigenproblem, Hermitian complex и Schur этим API не покрыты; пустой случай решается до C-вызова.

## 4. Общий допуск backend: один путь от `[op]` до C

Парсер и подпарсер `[]` уже сформировали обычный граф и один нормализованный индексный план. Этот слой не разбирает строку оператора повторно и не вводит отдельный механизм группировки.

Перед native вызовом общий код должен установить:

1. **Математику.** Точный op/arity, сторона solve, transpose/adjoint, contraction/reducer, batch и выходной порядок. General semiring/custom scalar не перенаправляется в обычный float multiply.
2. **Числовой профиль.** Actual dtype и accumulator type, преобразования, rounding, nonfinite/traps, exactness, reorder/FMA допуск. Строгий lexicographic/no-FMA договор из §7.7/§11.5 не доказан похожей формулой C: compiler flags, SIMD и внутренние редукции тоже проверяются. Без допуска сохраняется общий исполнитель или возвращается неподдерживаемый профиль.
3. **Форму и адреса.** Общий `Tensor`, signed `strides`, offset, owner-relative reachable bounds; empty axes до адресации. Native packing не меняет shape/broadcast смысл. Преобразования используют `tensorLayout`, `tensorBackend`, `numericNarrow`, а по необходимости `fixedPoint`, `complexBackend`, `sparseMatrixBackend`.
4. **Запись и lifetime.** Фактические права LMX refs, допустимый alias для конкретной entry, отдельный scratch при разрушительном C API, корректный native destructor. `layout`/`dtype` строки не являются доказательством. Sparse/complex не reinterpret-cast из обычных Structures.
5. **Размеры ресурсов.** Все dimension/product/byte/leading-dimension/workspace вычисления с checked arithmetic; реальные пределы C int/unsigned/ushort, выравнивание, stack/scratch. Для foreign memory определяется owner, thread/device confinement и период удержания.
6. **Результат.** Native status, flags, optional scalar diagnostics и postconditions читаются до публикации. Finite-only default приближённых solvers/factorizations/eig, symmetry/SPD, residual и convergence не выводятся из одного `return 0`. Review-required, unsupported и numerical failure остаются различимыми.

Преобразование правого solve проверяется на некоммутирующих матрицах; transpose/adjoint — на ненулевой мнимой части. Оптимизация не меняет вычислимость, порядок востребования пользовательских выражений и число их вызовов.

## 5. Добавленные LMX-связи

- [ports.lmx](ports.lmx): именованные сигнатуры и **незаполненные** typed slots `prepare`/`finish`. Они требуют настоящих реализаций; тела, возвращающего фиктивный успех, нет.
- [backend_profiles.lmx](backend_profiles.lmx): обычные DATA-описания **23** узких профилей, каждый с реальной ссылкой на существующий `C99Calls_…\capi_…`, каталог и entry. Строки описывают контракт и не служат runtime-dispatch ключом.
- [calls.lmx](calls.lmx): реальное LMX-тело `MatrixBackendCall\run` вызывает допущенный CODE и передаёт фактический результат на проверку. Также показаны конкретные named native calls для multiplication, transpose/adjoint, fixed-point и Householder QR.

`prepare` возвращает обычный `MatrixPreparedCall`: уже выбранный CODE, managed `CallRequest`, profile/context. Native frame не удерживается между этапами. Единственный его владелец — существующий `BridgeLower`, чьё `finally/release` действует при любом выходе. `finish` сохраняет native failure и проверяет фактические outputs; нет второго native bridge и нет копирования каталога на каждый вызов.

Например, соответствие трёх готовых записей видно напрямую:

| Профиль | Существующий native entry | Конкретный LMX CODE |
|---|---|---|
| `liquidFloatMul` | `matrixf_mul` | `C99Calls_acoustic_liquid_dsp\capi_87521c170ed40a54` |
| `liquidComplexFloatTranspose` | `matrixcf_hermitian` | `C99Calls_acoustic_liquid_dsp\capi_d8dd7fe3c46e2d91` |
| `liquidComplexFloatAdjoint` | `matrixcf_trans` | `C99Calls_acoustic_liquid_dsp\capi_e7fb3578f2bf1f43` |

Типы actual аргументов C и их порядок берутся из конкретной canonical entry, не из этой обзорной таблицы. Нельзя запускать `MatrixNativePrepared` с произвольным request только потому, что он структурно похож на `CallRequest`.

## 6. Следующий проверяемый шаг интеграции

Сначала реализуются общие admission/converters и один rank-2 dense путь; затем добавляются остальные ограниченные профили без дублирования алгоритма осей. Для каждой реально включаемой entry нужно сгенерировать единственный C shim из актуального каталога, заполнить TYPE/READ/CHECK/SAVE по договору, собрать его с **той же** pinned library/config и выполнить направленные проверки.

Минимальные различающие случаи: несимметричное complex transpose против adjoint; некоммутирующий right solve; shape mismatch/zero axes; signed-stride pack; output/input overlap; fixed-point overflow/negative Cholesky pivot; singular и zero-leading-pivot invertible matrix; rank-deficient QR; 1-based permutation; sparse duplicate coordinates и граница ushort; native allocation/cleanup failure; solver iteration limit. Это план проверок полного будущего bridge; реально выполненные ограниченные native-проверки отдельно перечислены в §7.

Текущая проверка подтверждает существование выбранных canonical entries, согласование ссылок на LMX CODE, чтение pinned local/upstream contracts и результаты узкого native probe. **Production-LMX parsing, C-shim bridge и LMX numerical execution: NOT_RUN.** Изменения vendored C, подключение новой внешней зависимости и публикация runtime этой редакцией не выполнены.

## 7. Что проверено на восстановленных исходниках

[Машинный отчёт](validation_report.json) содержит provenance, точный compiler argv, source/build/harness SHA-256, ожидаемые и наблюдённые результаты. [Воспроизводимый runner и C99-проверки](validation/README.ru.md) выделены в проверочный инструмент; это не LMX implementation/example. Скомпилированы **28 выбранных C translation units**, затем связаны с libm в один host executable: `cc`, C99, `-pedantic-errors`, `-O0`, `-ffp-contract=off`. Использованы существующие acoustic/Mint generation scripts; для Utensil воспроизведены ровно две header-замены из его существующего CMake-view. Vendor-файлы не менялись.

| Проверка | Наблюдение |
|---|---|
| liquid `div` на некоммутирующих 2×2 | Получено `X inv(Y)`; отличено от `inv(Y) X` |
| complex `trans` и `hermitian` | Два отдельных случая подтвердили conjugation только у `trans` |
| liquid inverse сингулярной A | Внутренняя диагностика singular; наружный return всё равно `0` — **воспроизведён дефект передачи status** |
| liquid LU для `[[0,1],[1,0]]` | Return `0`, P=I, есть nonfinite факторы — **воспроизведено ограничение unpivoted LU** |
| liquid QR на 3×2 | Отказ с кодом неверной формы |
| CMINPACK pivoted QR на 3×2 | `ipvt=[2,1]`; после qform проверено `A P=Q R`, residual этого случая 0 |
| libfixmatrix overflow | Умножение Q16.16 `30000×2` установило `FIXMATRIX_OVERFLOW=1` |
| liquid sparse binary | `[1 1] × [1;1]` дало 0 по GF(2) |
| klib symmetric eig 2×2 | Return `0`; проверено `A V=V diag(λ)`, residual этого случая 0 |
| Mint dense rank2 | Проверены четыре элемента результата 2×3 на 3×2 |
| Utensil equal-batch rank3 | Проверены два независимых batch-продукта |

Итого **12/12 проверок** подтвердили ожидаемое поведение или контрпример; это не «12 доказательств математической корректности библиотек». `nm` подтвердил 14 используемых definitions в собранном probe, включая static `mt_matmul`; это не проверка всех 54 тысяч записей каталога и не наличие готовой vendor `.a`.

CMake executable в окружении не обнаружен: сборка штатных CMake-targets целиком **NOT_RUN**. Прямой selected-source build и его выполнение состоялись. Не запускались полный collection/CTest, GPU, external BLAS/LAPACK LP64/ILP64, production LMX parser/runtime и массовые stability/performance tests. Эти границы не снимаются успешными маленькими host-примерами.
