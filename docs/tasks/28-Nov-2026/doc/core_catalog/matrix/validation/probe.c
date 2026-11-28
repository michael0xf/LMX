#include <stdio.h>
#include <math.h>
#include <string.h>
#include <complex.h>
#include <liquid.h>
#include <fixmatrix.h>
#include <cminpack.h>
#include <keigen.h>
int mint_probe(void);
int utensil_probe(void);
static int report(const char *id, int pass, double value) {
    printf("{\"case\":\"%s\",\"pass\":%s,\"value\":%.17g}\n",id,pass?"true":"false",value);
    return !pass;
}
int main(void) {
    int failed=0,i,j,k;
    float a[4]={1,2,0,1},b[4]={1,0,3,1},z[4]={0};
    int status=matrixf_div(a,b,z,2);
    failed+=report("liquid_div_right_order",status==0&&z[0]==-5&&z[1]==2&&z[2]==-3&&z[3]==1,z[0]);
    {
        float complex x[2]={1+2*I,3+4*I},y[2]={1+2*I,3+4*I};
        int t=matrixcf_trans(x,1,2),h=matrixcf_hermitian(y,1,2);
        failed+=report("liquid_trans_is_adjoint",t==0&&cimagf(x[0])==-2&&cimagf(x[1])==-4,cimagf(x[1]));
        failed+=report("liquid_hermitian_is_transpose",h==0&&cimagf(y[0])==2&&cimagf(y[1])==4,cimagf(y[1]));
    }
    {
        float singular[4]={1,2,2,4};
        status=matrixf_inv(singular,2,2);
        // Counterexample: top-level OK hides an elimination failure.
        failed+=report("liquid_singular_inverse_lost_status",status==0,status);
    }
    {
        float swap[4]={0,1,1,0},l[4],u[4],p[4];
        status=matrixf_ludecomp_doolittle(swap,2,2,l,u,p);
        int bad=0;for(i=0;i<4;i++)bad+=!isfinite(l[i])||!isfinite(u[i]);
        failed+=report("liquid_unpivoted_lu_counterexample",status==0&&bad>0&&p[0]==1&&p[3]==1,bad);
    }
    {
        float rectangular[6]={1,0,0,1,0,0},q[6],r[4];
        status=matrixf_qrdecomp_gramschmidt(rectangular,3,2,q,r);
        failed+=report("liquid_qr_rejects_rectangular",status!=0,status);
    }
    {
        double original[6]={1,0,0,0,2,0},qr[6],q[9]={0},diag[2],norms[2],wa[3];
        int ipvt[2];double maxerr=0;
        memcpy(qr,original,sizeof(qr));
        qrfac(3,2,qr,3,1,ipvt,2,diag,norms,wa);
        memcpy(q,qr,sizeof(qr));qform(3,2,q,3,wa);
        for(j=0;j<2;j++)for(i=0;i<3;i++){
            double val=0;
            for(k=0;k<2;k++){double r=(k==j)?diag[k]:((k<j)?qr[k+j*3]:0);val+=q[i+k*3]*r;}
            double err=fabs(val-original[i+(ipvt[j]-1)*3]);if(err>maxerr)maxerr=err;
        }
        failed+=report("cminpack_rectangular_pivoted_qr",ipvt[0]==2&&ipvt[1]==1&&maxerr<1e-12,maxerr);
    }
    {
        mf16 x={0},y={0},out={0};
        x.rows=x.columns=y.rows=y.columns=1;
        x.data[0][0]=fix16_from_int(30000);y.data[0][0]=fix16_from_int(2);
        mf16_mul(&out,&x,&y);
        failed+=report("fixmatrix_overflow_flag",FIXMATRIX_MAX_SIZE==8&&(out.errors&FIXMATRIX_OVERFLOW)!=0,out.errors);
    }
    {
        smatrixb x=smatrixb_create(1,2),y=smatrixb_create(2,1),out=smatrixb_create(1,1);
        smatrixb_set(x,0,0,1);smatrixb_set(x,0,1,1);smatrixb_set(y,0,0,1);smatrixb_set(y,1,0,1);
        status=smatrixb_mul(x,y,out);int value=smatrixb_get(out,0,0);
        failed+=report("liquid_sparse_binary_is_gf2",status==0&&value==0,value);
        smatrixb_destroy(x);smatrixb_destroy(y);smatrixb_destroy(out);
    }
    {
        double a[4]={2,1,1,2},v[2],maxerr=0;
        status=ke_eigen_sd(2,a,v,1,1e-12,100);
        for(j=0;j<2;j++)for(i=0;i<2;i++){
            double val=2*a[i*2+j]+a[(1-i)*2+j];
            double err=fabs(val-v[j]*a[i*2+j]);if(err>maxerr)maxerr=err;
        }
        failed+=report("klib_symmetric_eigen",status==0&&maxerr<1e-12,maxerr);
    }
    failed+=mint_probe();failed+=utensil_probe();
    return failed?1:0;
}
