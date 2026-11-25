# C99/POSIX quadrature collection

`c99_quad_lite`, also available as `LMX::quadrature`, combines CQUADPACK, Stroud
rules, Heiss-Winschel sparse grids, and Sobol sequences. All sources are present
in the bundle. Configuration and compilation require no downloads, Fortran
compiler, C++ compiler, or third-party numerical runtime. The link dependencies
are the system math library and POSIX threads.

## Exact source selection

| Requested component | Selected source | License | Target |
|---|---|---|---|
| QUADPACK | ESSS **CQUADPACK 1.1.1**, tag `v1.1.1`, 2016-12-14 | MIT | `LMX::quadpack` |
| Stroud | Current official Burkardt **stroud_rule** C snapshot, retrieved 2026-11-25 | MIT | `LMX::stroud` |
| sparse_grid_hw | Current official Burkardt C snapshot, retrieved 2026-11-25 | MIT | `LMX::sparse_grid_hw` |
| Sobol | Current official Burkardt C++ snapshot, retained unchanged, with an explicit C99 adaptation | MIT | `LMX::sobol` |

The incomplete `https://sc.edu` download base from the draft is not a usable
source URL. Current Stroud is named `stroud_rule`, and Burkardt's site does not
provide the proposed `c_src/quadpack/quadpack.c` or `c_src/sobol/sobol.c` files.
QUADPACK uses the established CQUADPACK port; Sobol uses the retained Burkardt
implementation adapted to C99. This distinction is recorded in provenance.

CQUADPACK's latest published release tag resolves to commit
`e6cb66a29dd89b4dc00b42577ec9dab61938b1f0`. Its source archive SHA-256 is
`e193023a33b6b6d86d92935ddce4f1b7efe35e259e06c88bd45e20d7e896ae38`.
The Burkardt modules have no numbered stable releases: their exact source
snapshots are identified by the per-file hashes in `provenance/stroud_rule.json`,
`provenance/sparse_grid_hw.json`, and `provenance/sobol.json`.

The current downloaded **code**, not only its HTML pages, explicitly carries
MIT licensing statements: 270 routine notices in Stroud, 59 in sparse_grid_hw,
and 18 in Sobol. Older SC mirrors with LGPL notices are not used. Upstream author
attributions, original compile scripts, source headers, example/test programs,
and their published output files remain under each `vendor/` directory.

Primary sources:

- <https://github.com/ESSS/cquadpack/tree/v1.1.1>
- <https://people.sc.fsu.edu/~jburkardt/c_src/stroud_rule/stroud_rule.html>
- <https://people.sc.fsu.edu/~jburkardt/c_src/sparse_grid_hw/sparse_grid_hw.html>
- <https://people.sc.fsu.edu/~jburkardt/cpp_src/sobol/sobol.html>

## Connecting the collection

```cmake
target_link_libraries(my_app PRIVATE c99_quad_lite)
# Equivalent:
target_link_libraries(my_app PRIVATE LMX::quadrature)
```

```c
#include "c99_quad.h"
```

The aggregate header includes `lmx_quadpack.h`, `lmx_stroud.h`,
`lmx_sparse_grid_hw.h`, and `lmx_sobol.h`. Each original API uses a separate
prefix. Shared helper names such as `r8_uniform_01`, `i4_max`, and `r8mat_write`
would otherwise collide when these independent libraries are statically linked.
There are no global aliases that expose those ambiguous helper names.

| API family | Examples |
|---|---|
| Native CQUADPACK | `lmx_quadpack_dqags`, `lmx_quadpack_dqagi`, `lmx_quadpack_G_K21` |
| Native Stroud rules | `lmx_stroud_cn_leg_03_1`, `lmx_stroud_cube_unit_3d` |
| Native sparse grids | `lmx_sparse_nwspgr_size`, `lmx_sparse_nwspgr`, `lmx_sparse_gqu` |
| Adapted Sobol | `lmx_sobol_i8_sobol`, `lmx_sobol_i8_sobol_generate` |
| Convenient integration wrappers | `c99_quad_dqags`, `c99_quad_dqagi`, `c99_quad_dqk21`, `c99_quad_qmc_sobol` |

The native Burkardt routines keep their individual input-domain contracts and
memory ownership rules. Some report invalid inputs by printing an error and
terminating the process, as in the originals. The convenience wrappers validate
their own arguments and return `NAN` on invalid input instead.

## One-dimensional integration

The proposed simple callback `double f(double x)` is supported by
`c99_quad_dqags`:

```c
double error;
int evaluations, status;
double integral = c99_quad_dqags(f, 0.0, 10.0, 1e-10, 1e-10,
                                &error, &evaluations, &status);
```

`status == 0` indicates successful convergence. The native CQUADPACK function
adds a user-data argument and calls a function with signature
`double f(double x, void *userdata)`:

```c
double integral = lmx_quadpack_dqags(f_with_data, a, b, epsabs, epsrel,
                                    &error, &evaluations, &status, &parameters);
```

The simple wrapper stores its callback in a stack context and forwards it through
this native interface; it does not use a global callback variable.

`c99_quad_dqagi` handles infinite domains. Its `inf` parameter is `1` for
`[bound,+infinity)`, `-1` for `(-infinity,bound]`, or `2` for the entire real line.
`c99_quad_dqk21` is the nonadaptive 21-point Gauss-Kronrod rule. CQUADPACK calls
the underlying routine **`G_K21`**, rather than `dqk21`; the adapter makes this
naming difference explicit.

The integration wrapper checks callback/output pointers, finite endpoints and
tolerances, and the infinite-domain selector. Invalid arguments produce `NAN`,
`ier=6`, and zero evaluations when the corresponding output pointers exist.
This validation does not establish that an arbitrary integrand is integrable or
that every numerical status returned by native QUADPACK is successful.

The full CQUADPACK source set is compiled, including its weighted and oscillatory
integrators. The unused `G_B15` declaration in the original header has no
implementation in the selected release and is intentionally absent from the
public adapted header. Its original declaration is retained in `vendor/`.
Implementation-only macros such as `min`, `max`, `LIMIT`, and `Pi` do not leak
from the public header into application code.

## Multidimensional rules and domains

Stroud exposes fixed quadrature rules for multiple geometric regions. Rule names
and documentation specify their domain and weight. For example,
`cn_leg_03_1` uses the cube `[-1,1]^n`, whose volume is `2^n`; it is not the
unit cube `[0,1]^n` used by the example Sobol wrapper.

The sparse-grid workflow first calls `lmx_sparse_nwspgr_size` to determine
capacity, allocates `dim * capacity` coordinates and `capacity` weights, then
calls `lmx_sparse_nwspgr`. Its returned count can be smaller after duplicate
nodes are merged. Coordinates use `nodes[coordinate + point * dim]`.
The `gqu`/`kpu` rule families integrate over `[0,1]` with unit weight; the
`gqn`/`kpn` families use the standard normal weight on the real line. Choose a
family whose measure matches the requested integral.

These routines complement one another. They do not implement the removed
Cubature library's `hcubature`/`pcubature` API, nor do fixed rules and the simple
Sobol average provide that library's adaptive multidimensional error control.

## Corrected Stroud odd-dimensional rule

An analytical integration check exposed an error in the retained upstream
`cn_leg_03_1` and `cn_leg_03_xiu` routines. For odd dimensions greater than one,
their final coordinate has magnitude `sqrt(2/3)` instead of `sqrt(1/3)`.
The weights sum to the volume, so that coordinate's second moment is twice the
required value.

The independent formula for the cube `[-1,1]^n` is:

```text
integral(1)       = 2^n
integral(x_i^2)   = 2^n / 3
integral(monomial)= 0 whenever any exponent is odd
```

For `x^2+y^2+z^2` in three dimensions, the original result is `32/3`, whereas
the integral is `8`. The CMake adapter corrects exactly the two final-coordinate
scale factors in a **generated build-directory copy**. All original source files
remain unchanged. CMake checks that exactly two matching factors exist before
applying the correction.

`quadrature.stroud_moments` verifies every monomial of total degree at most three,
including constants, cross terms, and odd terms, for both corrected rules and
dimensions one through seven. The oracle is the elementary product-integral
formula above, independent of the implementation's helper functions.

## Sobol C99 adaptation and QMC wrapper

The upstream Sobol implementation is C++. The retained C99 adaptation changes
the language support layer: C standard headers, `bool`, integer min/max helpers,
`malloc` instead of `new[]`, and stdio instead of C++ streams. The direction
tables and sequence recurrence are unchanged. Array generators check dimensions,
allocation size, and allocation failure, and their arrays are released with
`free`. The file-writing helper accepts `const char *` instead of `std::string`.

The original sequence routines cache mutable state. The public C99 sequence and
bulk-generation functions serialize access through a POSIX mutex. This adds no
third-party dependency and permits different callers to interleave valid seed
requests safely. Direct access to those internal caches is not exported.

The convenient wrapper has the requested callback and call shape:

```c
typedef double (*c99_quad_nd_func)(int dim, const double *x, void *userdata);
double c99_quad_qmc_sobol(c99_quad_nd_func func, int dim,
                        int num_samples, void *userdata);
```

It stores coordinates in **`double point[40]`**, validates a non-null callback,
positive sample count, and dimensions 1 through 40, then uses compensated
summation. The underlying native generator still supports 1111 dimensions;
the 40-dimensional limit applies only to this small convenience wrapper.

The sequence starts at the all-zero point, as in the draft. Samples are
deterministic and belong to `[0,1)^dim`. This wrapper returns an average over the
unit cube and does not supply a statistical confidence interval or a guaranteed
error estimate. A function singular at the first point needs a different
sampling/domain treatment. Nonfinite callback results return `NAN`.

The C99 port was compared against the **unmodified upstream C++ source** compiled
as a separate, temporary oracle. All 16,198 checked float/double coordinate
values were bit-identical across dimensions 1, 3, 40, 1111, and 2 and sequence
indices 0, 1, 2, 7, 37, 1024, and 4095. C++ was used only for this development
check; ordinary bundle builds and CTest do not require it.

`tools/prepare_quadrature.py` reproduces the retained namespace headers and Sobol
C99 source from verified vendor inputs. It is not executed during CMake builds.

## Build and examples

From the bundle root:

```sh
cmake -S examples/quadrature -B build-quadrature -DCMAKE_BUILD_TYPE=Release
cmake --build build-quadrature --parallel
ctest --test-dir build-quadrature --output-on-failure
./build-quadrature/lmx_quadrature_example
```

`examples/quadrature/main.c` fixes both array mistakes in the draft: Sobol gets
a coordinate array, and the 3D integrand sums `x[i] * x[i]` over coordinates.
It also checks the adaptive integrator's status.

Observed example output on Linux x86_64:

```text
Integral sin(x)/x [0,10]: 1.6583475942188743; estimated error 2.86e-14; evaluations 21
Sobol integral x^2+y^2+z^2 [0,1]^3: 0.99997711193282157; exact integral 1
```

Five integration tests cover finite and infinite integrals, an endpoint
singularity, the 21-point rule, callback user data, Stroud and sparse-grid domain
normalization, polynomial exactness, Sobol's known prefix and maximum dimension,
concurrent Sobol calls, invalid arguments, and the example program. Validation
details are under `docs/validation/quadrature_2026_11_25/`. The recorded execution
environment is GCC 14.2.0 on Linux x86_64; other platforms have not been executed.
