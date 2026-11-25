/* MIT-licensed upstream APIs, namespaced for the LMX collection.
 * Original notices and sources are retained under vendor/. */
#ifndef LMX_SOBOL_H
#define LMX_SOBOL_H
#ifdef __cplusplus
extern "C" {
#endif
int lmx_sobol_i4_bit_hi1 ( int n );
int lmx_sobol_i4_bit_lo0 ( int n );
void lmx_sobol_i4_sobol ( int dim_num, int *seed, float quasi[ ] );
float *lmx_sobol_i4_sobol_generate ( int m, int n, int skip );
int lmx_sobol_i4_uniform ( int b, int c, int *seed );

int lmx_sobol_i8_bit_hi1 ( long long int n );
int lmx_sobol_i8_bit_lo0 ( long long int n );
long long int lmx_sobol_i8_max ( long long int i1, long long int i2 );
long long int lmx_sobol_i8_min ( long long int i1, long long int i2 );
void lmx_sobol_i8_sobol ( int dim_num, long long int *seed, double quasi[ ] );
double *lmx_sobol_i8_sobol_generate ( int m, int n, int skip );
long long int lmx_sobol_i8_uniform ( long long int b, long long int c, int *seed );

int lmx_sobol_r4_nint ( float x );
float lmx_sobol_r4_uniform_01 ( int *seed );

int lmx_sobol_r8_nint ( double x );
double lmx_sobol_r8_uniform_01 ( int *seed );

void lmx_sobol_r8mat_write ( const char *output_filename, int m, int n, double table[] );

int lmx_sobol_tau_sobol ( int dim_num );
#ifdef __cplusplus
}
#endif
#endif
