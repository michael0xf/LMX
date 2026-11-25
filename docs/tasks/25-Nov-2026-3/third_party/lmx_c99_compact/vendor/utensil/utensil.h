#ifndef UTENSIL_H
#define UTENSIL_H

#include <float.h>
#include <math.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#define UT_MAX_DIMS 4

typedef enum { UT_CPU, UT_METAL } ut_dev;

typedef struct ut_shape {
  int ndim;                 // number of dimensions
  int nelem;                // total number of elements
  int shape[UT_MAX_DIMS];   // size of each dimension
  int stride[UT_MAX_DIMS];  // stride for each dimension
} ut_shape;

typedef struct ut_tensor {
  ut_shape shape;           // shape of the tensor
  float* data;              // pointer to the data buffer
  void* gpu_buf;            // MTLBuffer
  int rc;                   // reference count for memory management
  struct ut_tensor* owner;  // if this is a view, points to the owner tensor
  ut_dev dev;               // device where the tensor is allocated
  bool dirty_cpu;           // GPU is newer than CPU mirror
  bool dirty_gpu;           // CPU is newer than GPU buffer
} ut_tensor;

typedef struct ut_linear {
  ut_tensor* weight;  // [in, out]
  ut_tensor* bias;    // [out]
  int nin, nout;
} ut_linear;

typedef struct ut_layernorm {
  ut_tensor* weight;  // [d] gain
  ut_tensor* bias;    // [d] shift
  int d;              // last dimension
  float eps;
} ut_layernorm;

typedef struct ut_layernorm_cache {
  ut_tensor* xnorm;  // normalised x before affine
  ut_tensor* mean;   // per-row mean
  ut_tensor* rstd;   // per-row reciprocal std-dev
} ut_layernorm_cache;

typedef struct ut_conv1d {
  ut_tensor* weight;  // [out_c, in_c, kw]
  ut_tensor* bias;    // [out_c]
  int in_c, out_c, kw, stride, pad;
} ut_conv1d;

typedef struct ut_conv1d_cache {
  ut_tensor* input;
  ut_tensor* col;
} ut_conv1d_cache;

typedef struct ut_lstm {
  ut_tensor* W_ih;  // [in, 4*hidden] gate order: i, f, g, o
  ut_tensor* W_hh;  // [hidden, 4*hidden]
  ut_tensor* bias;  // [4*hidden]
  int in, hidden;
} ut_lstm;

// One timestep's worth of state, retained for that step's backward pass.
// Gate math always runs on CPU (see ut_lstm_step), so these are CPU tensors.
typedef struct ut_lstm_cache {
  ut_tensor *x, *h_prev, *c_prev;  // retained inputs to this step
  ut_tensor *i, *f, *g, *o, *c;    // gate activations and new cell state
} ut_lstm_cache;

typedef struct ut_lstm_seq_cache {
  ut_lstm_cache* steps;  // [t]
  int t;
} ut_lstm_seq_cache;

typedef struct ut_conv2d {
  ut_tensor* weight;  // [out_c, in_c, kh, kw]
  ut_tensor* bias;    // [out_c]
  int in_c, out_c, kh, kw, stride, pad;
  void* _mpsg;  // cached MPSGraph (forward + backward), lazily built; see _ut_conv2d_graph_t
} ut_conv2d;

typedef struct ut_conv2d_cache {
  ut_tensor* input;
  ut_tensor* col;
} ut_conv2d_cache;

typedef struct ut_dwconv2d {
  ut_tensor* weight;  // [C, kh, kw] — one filter per channel, no cross-channel mixing
  ut_tensor* bias;    // [C]
  int c, kh, kw, stride, pad;
} ut_dwconv2d;

typedef struct ut_dwconv2d_cache {
  ut_tensor* input;
} ut_dwconv2d_cache;

typedef struct ut_batchnorm2d {
  ut_tensor* weight;        // [C] gain
  ut_tensor* bias;          // [C] shift
  ut_tensor* running_mean;  // [C] EMA of batch mean, used at inference
  ut_tensor* running_var;   // [C] EMA of batch (unbiased) var, used at inference
  int c;                    // channel count
  float eps, momentum;      // momentum: EMA weight given to each new batch stat
} ut_batchnorm2d;

typedef struct ut_batchnorm2d_cache {
  ut_tensor* xnorm;  // normalised x before affine
  ut_tensor* rstd;   // per-channel reciprocal std-dev
} ut_batchnorm2d_cache;

typedef struct ut_maxpool2d_cache {
  int* argmax;     // flat input index of the max, per output element (plain array — CPU-only
                   // bookkeeping, never touches the GPU)
  int n, c, h, w;  // input shape, needed to size dx in backward
} ut_maxpool2d_cache;

typedef struct ut_sgd {
  ut_tensor** params;    // pointers to model parameters (not owned)
  ut_tensor** grads;     // gradient accumulators (owned)
  ut_tensor** velocity;  // momentum buffers (owned, NULL if mom==0)
  int nparams;
  float lr, momentum;
} ut_sgd;

typedef struct ut_adam {
  ut_tensor** params;
  ut_tensor** grads;
  ut_tensor** m;  // 1st moment
  ut_tensor** v;  // 2nd moment
  int nparams;
  float lr, beta1, beta2, eps, wd;  // wd: weight decay (AdamW)
  int step;
} ut_adam;

// =========================================================
// Metal context management
// =========================================================
#ifdef __APPLE__
#include <Accelerate/Accelerate.h>
#include <objc/message.h>
#include <objc/runtime.h>
// Type-safe objc_msgSend wrappers
static inline void* _m0(void* o, const char* s) {
  return ((id (*)(id, SEL))objc_msgSend)((id)o, sel_getUid(s));
}
static inline void* _m1(void* o, const char* s, void* a) {
  return ((id (*)(id, SEL, id))objc_msgSend)((id)o, sel_getUid(s), (id)a);
}
static inline void* _m1s(void* o, const char* s, const char* a) {
  return ((id (*)(id, SEL, const char*))objc_msgSend)((id)o, sel_getUid(s), a);
}
static inline void* _m2ll(void* o, const char* s, long a, long b) {
  return ((id (*)(id, SEL, long, long))objc_msgSend)((id)o, sel_getUid(s), a, b);
}
static inline void* _m4l(void* o, const char* s, long a, long b, long c, long d) {
  return ((id (*)(id, SEL, long, long, long, long))objc_msgSend)((id)o, sel_getUid(s), a, b, c, d);
}
static inline void _v0(void* o, const char* s) {
  ((void (*)(id, SEL))objc_msgSend)((id)o, sel_getUid(s));
}
static inline void _v1(void* o, const char* s, void* a) {
  ((void (*)(id, SEL, id))objc_msgSend)((id)o, sel_getUid(s), (id)a);
}
static inline void* _p0(void* o, const char* s) {
  return ((void* (*)(id, SEL))objc_msgSend)((id)o, sel_getUid(s));
}
static inline unsigned long _l0(void* o, const char* s) {
  return ((unsigned long (*)(id, SEL))objc_msgSend)((id)o, sel_getUid(s));
}
static inline const char* _c0(void* o, const char* s) {
  return ((const char* (*)(id, SEL))objc_msgSend)((id)o, sel_getUid(s));
}

static const char* _mtl_src =
    "#include <metal_stdlib>\nusing namespace metal;\n"
    // unary
    "kernel void uneg(device const float*i,device float*o,constant int&n,"
    "uint idx[[thread_position_in_grid]]){o[idx]=-i[idx];}\n"
    "kernel void urelu(device const float*i,device float*o,constant int&n,"
    "uint idx[[thread_position_in_grid]]){if((int)idx<n)o[idx]=max(i[idx],0.f);}\n"
    "kernel void usig(device const float*i,device float*o,constant int&n,"
    "uint idx[[thread_position_in_grid]]){if((int)idx<n)o[idx]=1.f/(1.f+exp(-i[idx]));}\n"
    "kernel void utanh(device const float*i,device float*o,constant int&n,"
    "uint idx[[thread_position_in_grid]]){if((int)idx<n)o[idx]=tanh(i[idx]);}\n"
    "kernel void uexp(device const float*i,device float*o,constant int&n,"
    "uint idx[[thread_position_in_grid]]){if((int)idx<n)o[idx]=exp(i[idx]);}\n"
    "kernel void urelu6(device const float*i,device float*o,constant int&n,"
    "uint idx[[thread_position_in_grid]]){if((int)idx<n)o[idx]=min(max(i[idx],0.f),6.f);}\n"
    "kernel void uhsig(device const float*i,device float*o,constant int&n,"
    "uint idx[[thread_position_in_grid]]){if((int)idx<n)o[idx]=min(max(i[idx]+3.f,0.f),6.f)/6.f;}\n"
    "kernel void uhswish(device const float*i,device float*o,constant int&n,"
    "uint idx[[thread_position_in_grid]]){if((int)idx<n){float t=i[idx];"
    "o[idx]=t*min(max(t+3.f,0.f),6.f)/6.f;}}\n"

    // binary
    "kernel void badd(device const float*a,device const float*b,device float*o,"
    "constant int&n,uint idx[[thread_position_in_grid]]){if((int)idx<n)o[idx]=a[idx]+b[idx];}\n"
    "kernel void bsub(device const float*a,device const float*b,device float*o,"
    "constant int&n,uint idx[[thread_position_in_grid]]){if((int)idx<n)o[idx]=a[idx]-b[idx];}\n"
    "kernel void bmul(device const float*a,device const float*b,device float*o,"
    "constant int&n,uint idx[[thread_position_in_grid]]){if((int)idx<n)o[idx]=a[idx]*b[idx];}\n"
    "kernel void bdiv(device const float*a,device const float*b,device float*o,"
    "constant int&n,uint idx[[thread_position_in_grid]]){if((int)idx<n)o[idx]=a[idx]/b[idx];}\n"

    // scalar multiply: args = {float s, int n} packed as 8 bytes
    "struct ScaleArgs{ float s; int n; };\n"
    "kernel void bscale(device const float*a,device float*o,"
    "constant ScaleArgs&args,uint idx[[thread_position_in_grid]])"
    "{if((int)idx<args.n)o[idx]=a[idx]*args.s;}\n"
    // batched matmul: c[b,m,n] = sum_k a[b,m,k]*b[b,k,n]
    // p = {B,M,N,K}, dispatch B*M*N threads (flat 1D)
    "kernel void bmatmul(device const float*a,device const float*b_,device float*c,"
    "constant int*p,uint idx[[thread_position_in_grid]]){"
    "int M=p[1],N=p[2],K=p[3];"
    "int tot=p[0]*M*N;if((int)idx>=tot)return;"
    "int n=(int)idx%N,t=(int)idx/N,m=t%M,bat=t/M;"
    "float s=0;int ao=bat*M*K+m*K,bo=bat*K*N+n;"
    "for(int k=0;k<K;k++)s+=a[ao+k]*b_[bo+k*N];"
    "c[idx]=s;}\n"
    // bias_add: p={N,C,HW}
    "kernel void bias_add(device float*out,device const float*bias,"
    "constant int*p,uint idx[[thread_position_in_grid]]){"
    "int tot=p[0]*p[1]*p[2];"
    "if((int)idx>=tot)return;"
    "int c=((int)idx/p[2])%p[1];"
    "out[idx]+=bias[c];}"
    // relu_bwd
    "kernel void relu_bwd(device const float*go,device const float*fwd,"
    "device float*gi,constant int&n,"
    "uint idx[[thread_position_in_grid]]){if((int)idx<n)gi[idx]=fwd[idx]>0.f?go[idx]:0.f;}"
    "kernel void relu6_bwd(device const float*go,device const float*fwd,"
    "device float*gi,constant int&n,"
    "uint idx[[thread_position_in_grid]]){if((int)idx<n)"
    "gi[idx]=(fwd[idx]>0.f&&fwd[idx]<6.f)?go[idx]:0.f;}"
    // transpose dims 0<->1: p={A,B,inner}
    "kernel void transpose_01("
    "device const float*in,device float*out,constant int*p,"
    "uint idx[[thread_position_in_grid]]){"
    "int A=p[0],B=p[1],inner=p[2];"
    "if((int)idx>=A*B*inner)return;"
    "int k=(int)idx%inner,t=(int)idx/inner;"
    "int a=t%A,b=t/A;"
    "out[idx]=in[(a*B+b)*inner+k];}"
    // transpose dims 1<->2: p={A,B,C,D}
    "kernel void transpose_12(device const float*i,device float*o,"
    "constant int*p,uint idx[[thread_position_in_grid]]){"
    "int A=p[0],B=p[1],C=p[2],D=p[3];"
    "int n=A*B*C*D;if((int)idx>=n)return;"
    "int d_=idx%D,t=idx/D,c=t%C,t2=t/C,b=t2%B,a=t2/B;"
    "o[a*C*B*D+c*B*D+b*D+d_]=i[a*B*C*D+b*C*D+c*D+d_];}"
    // row_softmax: one workgroup per row; local sh[] passed as last arg
    // p={outer,C}  global=outer*tgsize  local=tgsize
    "kernel void row_softmax("
    "device const float*x,device float*o,constant int*p,"
    "uint gid[[threadgroup_position_in_grid]],"
    "uint lid[[thread_position_in_threadgroup]],"
    "uint tgs[[threads_per_threadgroup]]){"
    "int C=p[1];"
    "device const float*row=x+gid*C;"
    "device float*orow=o+gid*C;"
    "threadgroup float shmem[1024];"
    // phase 1: max reduce
    "float mx=-1e38f;"
    "for(int i=(int)lid;i<C;i+=(int)tgs){"
    "float v=row[i];if(v>mx)mx=v;}"
    "shmem[lid]=mx;threadgroup_barrier(mem_flags::mem_threadgroup);"
    "for(uint s=tgs/2;s>0;s>>=1){"
    "if(lid<s&&shmem[lid+s]>shmem[lid])shmem[lid]=shmem[lid+s];"
    "threadgroup_barrier(mem_flags::mem_threadgroup);}"
    "float gmx=shmem[0];"
    // phase 2: sum of exp
    "float loc_sum=0;"
    "for(int i=(int)lid;i<C;i+=(int)tgs){float e=exp(row[i]-gmx);orow[i]=e;loc_sum+=e;}"
    "shmem[lid]=loc_sum;threadgroup_barrier(mem_flags::mem_threadgroup);"
    "for(uint s=tgs/2;s>0;s>>=1){"
    "if(lid<s)shmem[lid]+=shmem[lid+s];"
    "threadgroup_barrier(mem_flags::mem_threadgroup);}"
    "float gsum=shmem[0];"
    // phase 3: divide
    "for(int i=(int)lid;i<C;i+=(int)tgs)orow[i]/=gsum;}"
    // layernorm forward: x[rows, d] -> out[rows, d]
    // also writes xnorm[rows,d], rstd[rows] for backward.
    // one threadgroup per row.  p = {rows, d}.
    "kernel void ln_fwd("
    "device const float*x,device const float*w,device const float*b,"
    "device float*out,device float*xn,device float*rstd,"
    "constant int*p,"
    "uint gid[[threadgroup_position_in_grid]],"
    "uint lid[[thread_position_in_threadgroup]],"
    "uint tgs[[threads_per_threadgroup]]){"
    "int d=p[1];"
    "device const float*row=x+gid*d;"
    "device float*orow=out+gid*d;device float*xnrow=xn+gid*d;"
    "threadgroup float sh[1024];"
    // mean
    "float ls=0;for(int i=(int)lid;i<d;i+=(int)tgs)ls+=row[i];"
    "sh[lid]=ls;threadgroup_barrier(mem_flags::mem_threadgroup);"
    "for(uint "
    "s=tgs/"
    "2;s>0;s>>=1){if(lid<s)sh[lid]+=sh[lid+s];threadgroup_barrier(mem_flags::mem_threadgroup);}"
    "float mu=sh[0]/(float)d;"
    // var
    "ls=0;for(int i=(int)lid;i<d;i+=(int)tgs){float v=row[i]-mu;ls+=v*v;}"
    "sh[lid]=ls;threadgroup_barrier(mem_flags::mem_threadgroup);"
    "for(uint "
    "s=tgs/"
    "2;s>0;s>>=1){if(lid<s)sh[lid]+=sh[lid+s];threadgroup_barrier(mem_flags::mem_threadgroup);}"
    "float rs=rsqrt(sh[0]/(float)d+1e-5f);"
    "if(lid==0)rstd[gid]=rs;"
    // output
    "for(int i=(int)lid;i<d;i+=(int)tgs){"
    "float xni=(row[i]-mu)*rs;"
    "xnrow[i]=xni;"
    "orow[i]=w[i]*xni+b[i];}}"
    // layernorm backward: given grad_out[rows,d], xnorm[rows,d], rstd[rows],
    // weight[d] → dx[rows,d].  dW[d] and db[d] accumulated separately on CPU
    // (only dx needs to be GPU-fast for the training loop hot path).
    // one threadgroup per row.  p = {rows, d}.
    "kernel void ln_bwd("
    "device const float*go,device const float*xn,device const float*rs_,"
    "device const float*w,device float*dx,"
    "constant int*p,"
    "uint gid[[threadgroup_position_in_grid]],"
    "uint lid[[thread_position_in_threadgroup]],"
    "uint tgs[[threads_per_threadgroup]]){"
    "int d=p[1];"
    "device const float*gorow=go+gid*d;device const float*xnrow=xn+gid*d;"
    "device float*dxrow=dx+gid*d;"
    "float rs=rs_[gid];"
    "threadgroup float sh[1024];"
    // sum(go*w)
    "float s1=0;for(int i=(int)lid;i<d;i+=(int)tgs)s1+=gorow[i]*w[i];"
    "sh[lid]=s1;threadgroup_barrier(mem_flags::mem_threadgroup);"
    "for(uint "
    "s=tgs/"
    "2;s>0;s>>=1){if(lid<s)sh[lid]+=sh[lid+s];threadgroup_barrier(mem_flags::mem_threadgroup);}"
    "float sum_go_w=sh[0];"
    // sum(go*w*xn)
    "s1=0;for(int i=(int)lid;i<d;i+=(int)tgs)s1+=gorow[i]*w[i]*xnrow[i];"
    "sh[lid]=s1;threadgroup_barrier(mem_flags::mem_threadgroup);"
    "for(uint "
    "s=tgs/"
    "2;s>0;s>>=1){if(lid<s)sh[lid]+=sh[lid+s];threadgroup_barrier(mem_flags::mem_threadgroup);}"
    "float sum_go_w_xn=sh[0];"
    // dx
    "for(int i=(int)lid;i<d;i+=(int)tgs)"
    "dxrow[i]=rs*(w[i]*gorow[i]-(sum_go_w+xnrow[i]*sum_go_w_xn)/(float)d);}"
    "struct BNParams{int N,C,HW;float eps,mom;};\n"
    // batchnorm2d forward (training): x[N,C,H,W] -> out[N,C,H,W], one threadgroup
    // per channel, reducing over N*HW elements. Writes xn (pre-affine) and rstd
    // for backward, and updates running_mean/running_var in place (unbiased var).
    "kernel void bn2d_fwd_train("
    "device const float*x,device const float*w,device const float*b,"
    "device float*rm,device float*rv,"
    "device float*out,device float*xn,device float*rstd,"
    "constant BNParams&p,"
    "uint gid[[threadgroup_position_in_grid]],"
    "uint lid[[thread_position_in_threadgroup]],"
    "uint tgs[[threads_per_threadgroup]]){"
    "int C=p.C,HW=p.HW,M=p.N*HW,c=(int)gid;"
    "threadgroup float sh[1024];"
    "float ls=0;for(int i=(int)lid;i<M;i+=(int)tgs){int n=i/HW,hw=i%HW;ls+=x[(n*C+c)*HW+hw];}"
    "sh[lid]=ls;threadgroup_barrier(mem_flags::mem_threadgroup);"
    "for(uint "
    "s=tgs/"
    "2;s>0;s>>=1){if(lid<s)sh[lid]+=sh[lid+s];threadgroup_barrier(mem_flags::mem_threadgroup);}"
    "float mu=sh[0]/(float)M;"
    "ls=0;for(int i=(int)lid;i<M;i+=(int)tgs){int n=i/HW,hw=i%HW;float "
    "v=x[(n*C+c)*HW+hw]-mu;ls+=v*v;}"
    "sh[lid]=ls;threadgroup_barrier(mem_flags::mem_threadgroup);"
    "for(uint "
    "s=tgs/"
    "2;s>0;s>>=1){if(lid<s)sh[lid]+=sh[lid+s];threadgroup_barrier(mem_flags::mem_threadgroup);}"
    "float var=sh[0]/(float)M;float rs=rsqrt(var+p.eps);"
    "if(lid==0){"
    "rstd[c]=rs;"
    "float vu=M>1?var*(float)M/(float)(M-1):var;"
    "rm[c]=(1.f-p.mom)*rm[c]+p.mom*mu;"
    "rv[c]=(1.f-p.mom)*rv[c]+p.mom*vu;}"
    "float wc=w[c],bc=b[c];"
    "for(int i=(int)lid;i<M;i+=(int)tgs){"
    "int n=i/HW,hw=i%HW,idx=(n*C+c)*HW+hw;"
    "float xni=(x[idx]-mu)*rs;xn[idx]=xni;out[idx]=wc*xni+bc;}}\n"
    // batchnorm2d forward (eval): elementwise using the running stats, no reduction
    "kernel void bn2d_fwd_eval("
    "device const float*x,device const float*w,device const float*b,"
    "device const float*rm,device const float*rv,device float*out,"
    "constant BNParams&p,uint idx[[thread_position_in_grid]]){"
    "int C=p.C,HW=p.HW,tot=p.N*C*HW;if((int)idx>=tot)return;"
    "int c=((int)idx/HW)%C;float rs=rsqrt(rv[c]+p.eps);"
    "out[idx]=w[c]*(x[idx]-rm[c])*rs+b[c];}\n"
    // batchnorm2d backward: dx only (dW/db stay CPU-accumulated, like LayerNorm's
    // ln_bwd). One threadgroup per channel, reducing over N*HW elements.
    // also emits dW_partial[C]/db_partial[C] (this channel's contribution to
    // this batch) so the caller only has to sync [C] floats back to CPU for
    // the dW/db accumulation, instead of the full [N,C,H,W] go/xn tensors.
    "kernel void bn2d_bwd("
    "device const float*go,device const float*xn,device const float*rs_,"
    "device const float*w,device float*dx,device float*dwp,device float*dbp,"
    "constant BNParams&p,"
    "uint gid[[threadgroup_position_in_grid]],"
    "uint lid[[thread_position_in_threadgroup]],"
    "uint tgs[[threads_per_threadgroup]]){"
    "int C=p.C,HW=p.HW,M=p.N*HW,c=(int)gid;"
    "threadgroup float sh[1024];"
    "float ls=0;for(int i=(int)lid;i<M;i+=(int)tgs){int n=i/HW,hw=i%HW;ls+=go[(n*C+c)*HW+hw];}"
    "sh[lid]=ls;threadgroup_barrier(mem_flags::mem_threadgroup);"
    "for(uint "
    "s=tgs/"
    "2;s>0;s>>=1){if(lid<s)sh[lid]+=sh[lid+s];threadgroup_barrier(mem_flags::mem_threadgroup);}"
    "float sum_go=sh[0];"
    "ls=0;for(int i=(int)lid;i<M;i+=(int)tgs){int "
    "n=i/HW,hw=i%HW,idx=(n*C+c)*HW+hw;ls+=go[idx]*xn[idx];}"
    "sh[lid]=ls;threadgroup_barrier(mem_flags::mem_threadgroup);"
    "for(uint "
    "s=tgs/"
    "2;s>0;s>>=1){if(lid<s)sh[lid]+=sh[lid+s];threadgroup_barrier(mem_flags::mem_threadgroup);}"
    "float sum_go_xn=sh[0];"
    "if(lid==0){dwp[c]=sum_go_xn;dbp[c]=sum_go;}"
    "float rs=rs_[c],wc=w[c];"
    "for(int i=(int)lid;i<M;i+=(int)tgs){"
    "int n=i/HW,hw=i%HW,idx=(n*C+c)*HW+hw;"
    "dx[idx]=rs*wc*(go[idx]-(sum_go+xn[idx]*sum_go_xn)/(float)M);}}\n"
    // global avgpool forward: x[N,C,H,W] -> out[N,C], one threadgroup per (n,c)
    // pair reducing a contiguous HW-sized block (rows = N*C)
    "kernel void gap_fwd(device const float*x,device float*out,constant int&HW,"
    "uint gid[[threadgroup_position_in_grid]],"
    "uint lid[[thread_position_in_threadgroup]],"
    "uint tgs[[threads_per_threadgroup]]){"
    "device const float*row=x+gid*HW;"
    "threadgroup float sh[1024];"
    "float ls=0;for(int i=(int)lid;i<HW;i+=(int)tgs)ls+=row[i];"
    "sh[lid]=ls;threadgroup_barrier(mem_flags::mem_threadgroup);"
    "for(uint s=tgs/2;s>0;s>>=1){if(lid<s)sh[lid]+=sh[lid+s];"
    "threadgroup_barrier(mem_flags::mem_threadgroup);}"
    "if(lid==0)out[gid]=sh[0]/(float)HW;}\n"
    // global avgpool backward: broadcast go[N,C]/HW back to dx[N,C,H,W]
    "struct GAPParams{int HW,tot;};\n"
    "kernel void gap_bwd(device const float*go,device float*dx,constant GAPParams&p,"
    "uint idx[[thread_position_in_grid]]){"
    "if((int)idx>=p.tot)return;"
    "dx[idx]=go[(int)idx/p.HW]/(float)p.HW;}\n"
    // col2im (gather, no atomics): col[C*kh*kw,N*Ho*Wo] -> dx[N,C,H,W]
    // p = {N,C,H,W,kh,kw,stride,pad,Ho,Wo}
    "kernel void col2im_k("
    "device const float*col,device float*dx,constant int*p,"
    "uint idx[[thread_position_in_grid]]){"
    "int N=p[0],C=p[1],H=p[2],W=p[3],kh=p[4],kw=p[5],s=p[6],pad=p[7],Ho=p[8],Wo=p[9];"
    "if((int)idx>=N*C*H*W)return;"
    "int t=(int)idx,iw=t%W;t/=W;int ih=t%H;t/=H;int c=t%C;t/=C;int n=t;"
    "float sum=0;"
    "for(int khh=0;khh<kh;khh++)for(int kww=0;kww<kw;kww++){"
    "int oh_n=ih+pad-khh,ow_n=iw+pad-kww;"
    "if(oh_n%s!=0||ow_n%s!=0)continue;"
    "int oh=oh_n/s,ow=ow_n/s;"
    "if(oh<0||oh>=Ho||ow<0||ow>=Wo)continue;"
    "sum+=col[(c*kh*kw+khh*kw+kww)*(N*Ho*Wo)+n*Ho*Wo+oh*Wo+ow];}"
    "dx[idx]=sum;}\n"
    // im2col: x[N,C,H,W] → col[C*kh*kw, N*Ho*Wo]
    // p = {N,C,H,W,kh,kw,stride,pad,Ho,Wo}
    "kernel void im2col_k("
    "device const float*x,device float*col,constant int*p,"
    "uint idx[[thread_position_in_grid]]){"
    "int N=p[0],C=p[1],H=p[2],W=p[3],kh=p[4],kw=p[5],s=p[6],pad=p[7],Ho=p[8],Wo=p[9];"
    "int tot=C*kh*kw*N*Ho*Wo;if((int)idx>=(int)tot)return;"
    "int t=(int)idx,ow=t%Wo;t/=Wo;int oh=t%Ho;t/=Ho;"
    "int kww=t%kw;t/=kw;int khh=t%kh;t/=kh;"
    "int c=t%C;t/=C;int n=t;"
    "int ih=oh*s-pad+khh,iw=ow*s-pad+kww;"
    "float v=0;if(ih>=0&&ih<H&&iw>=0&&iw<W)v=x[((n*C+c)*H+ih)*W+iw];"
    "col[(c*kh*kw+khh*kw+kww)*N*Ho*Wo+n*Ho*Wo+oh*Wo+ow]=v;}\n"
    // depthwise conv2d: each channel convolved independently with its own
    // kh x kw filter, no cross-channel mixing -- im2col+matmul can't express
    // this (it always contracts over all channels), so it's a direct kernel.
    // p = {N,C,H,W,kh,kw,stride,pad,Ho,Wo}, weight is [C,kh,kw]
    "kernel void dwconv2d_fwd(device const float*x,device const float*w,device float*out,"
    "constant int*p,uint idx[[thread_position_in_grid]]){"
    "int C=p[1],H=p[2],W=p[3],kh=p[4],kw=p[5],s=p[6],pad=p[7],Ho=p[8],Wo=p[9];"
    "int tot=p[0]*C*Ho*Wo;if((int)idx>=tot)return;"
    "int t=(int)idx,ow=t%Wo;t/=Wo;int oh=t%Ho;t/=Ho;int c=t%C;t/=C;int n=t;"
    "float sum=0;"
    "for(int khh=0;khh<kh;khh++)for(int kww=0;kww<kw;kww++){"
    "int ih=oh*s-pad+khh,iw=ow*s-pad+kww;"
    "if(ih<0||ih>=H||iw<0||iw>=W)continue;"
    "sum+=x[((n*C+c)*H+ih)*W+iw]*w[(c*kh+khh)*kw+kww];}"
    "out[idx]=sum;}\n"
    // depthwise conv2d backward, dx (gather, no atomics — mirrors col2im_k)
    "kernel void dwconv2d_bwd_dx(device const float*go,device const float*w,device float*dx,"
    "constant int*p,uint idx[[thread_position_in_grid]]){"
    "int C=p[1],H=p[2],W=p[3],kh=p[4],kw=p[5],s=p[6],pad=p[7],Ho=p[8],Wo=p[9];"
    "int tot=p[0]*C*H*W;if((int)idx>=tot)return;"
    "int t=(int)idx,iw=t%W;t/=W;int ih=t%H;t/=H;int c=t%C;t/=C;int n=t;"
    "float sum=0;"
    "for(int khh=0;khh<kh;khh++)for(int kww=0;kww<kw;kww++){"
    "int oh_n=ih+pad-khh,ow_n=iw+pad-kww;"
    "if(oh_n%s!=0||ow_n%s!=0)continue;"
    "int oh=oh_n/s,ow=ow_n/s;"
    "if(oh<0||oh>=Ho||ow<0||ow>=Wo)continue;"
    "sum+=go[((n*C+c)*Ho+oh)*Wo+ow]*w[(c*kh+khh)*kw+kww];}"
    "dx[idx]=sum;}\n"
    // depthwise conv2d backward, dW: one threadgroup per (c,khh,kww), reducing
    // over N*Ho*Wo. Writes dW_partial[C*kh*kw] (caller adds it into the real
    // accumulator) so only that tiny buffer needs to come back to CPU.
    "kernel void dwconv2d_bwd_dw(device const float*go,device const float*x,device float*dwp,"
    "constant int*p,"
    "uint gid[[threadgroup_position_in_grid]],"
    "uint lid[[thread_position_in_threadgroup]],"
    "uint tgs[[threads_per_threadgroup]]){"
    "int C=p[1],H=p[2],W=p[3],kh=p[4],kw=p[5],s=p[6],pad=p[7],Ho=p[8],Wo=p[9];"
    "int kww=(int)gid%kw,t0=(int)gid/kw,khh=t0%kh,c=t0/kh;"
    "int M=p[0]*Ho*Wo;"
    "threadgroup float sh[1024];"
    "float ls=0;"
    "for(int i=(int)lid;i<M;i+=(int)tgs){"
    "int t=i,ow=t%Wo;t/=Wo;int oh=t%Ho;t/=Ho;int n=t;"
    "int ih=oh*s-pad+khh,iw=ow*s-pad+kww;"
    "if(ih<0||ih>=H||iw<0||iw>=W)continue;"
    "ls+=go[((n*C+c)*Ho+oh)*Wo+ow]*x[((n*C+c)*H+ih)*W+iw];}"
    "sh[lid]=ls;threadgroup_barrier(mem_flags::mem_threadgroup);"
    "for(uint ss=tgs/2;ss>0;ss>>=1){if(lid<ss)sh[lid]+=sh[lid+ss];"
    "threadgroup_barrier(mem_flags::mem_threadgroup);}"
    "if(lid==0)dwp[gid]=sh[0];}\n"
    // depthwise conv2d backward, db: one threadgroup per channel, reducing go
    // over N*Ho*Wo (same reduction shape as bn2d_bwd's sum_go)
    "kernel void dwconv2d_bwd_db(device const float*go,device float*dbp,"
    "constant int*p,"
    "uint gid[[threadgroup_position_in_grid]],"
    "uint lid[[thread_position_in_threadgroup]],"
    "uint tgs[[threads_per_threadgroup]]){"
    "int C=p[1],HW=p[8]*p[9],c=(int)gid,M=p[0]*HW;"
    "threadgroup float sh[1024];"
    "float ls=0;for(int i=(int)lid;i<M;i+=(int)tgs){int n=i/HW,hw=i%HW;ls+=go[(n*C+c)*HW+hw];}"
    "sh[lid]=ls;threadgroup_barrier(mem_flags::mem_threadgroup);"
    "for(uint ss=tgs/2;ss>0;ss>>=1){if(lid<ss)sh[lid]+=sh[lid+ss];"
    "threadgroup_barrier(mem_flags::mem_threadgroup);}"
    "if(lid==0)dbp[c]=sh[0];}\n"
    "";

#define _MTL_MAX_PL 32  // maximum number of pipeline states
typedef struct {
  void *device, *queue, *library, *pl[_MTL_MAX_PL];
  const char* pl_name[_MTL_MAX_PL];
  int pl_count;
  void* pending_cmd;  // open command buffer for batching; NULL if none
} _mtl_ctx_t;

typedef struct {
  unsigned long w, h, d;
} _msize_t;

static void* _mtl_init(void) {
  _mtl_ctx_t* c = calloc(1, sizeof(_mtl_ctx_t));
  extern id MTLCreateSystemDefaultDevice(void);
  c->device = MTLCreateSystemDefaultDevice();
  if (!c->device) {
    free(c);
    return NULL;
  }
  c->queue = _m0(c->device, "newCommandQueue");
  void* src = _m1s(objc_getClass("NSString"), "stringWithUTF8String:", _mtl_src);
  void* opts = _m0(objc_getClass("MTLCompileOptions"), "new");
  void* lib = ((id (*)(id, SEL, id, id, void*))objc_msgSend)(
      (id)c->device, sel_getUid("newLibraryWithSource:options:error:"), (id)src, (id)opts, NULL);
  _v0(opts, "release");
  if (!lib) {
    fprintf(stderr, "utensil: failed to compile Metal library\n");
    _v0(c->queue, "release");
    _v0(c->device, "release");
    free(c);
    return NULL;
  }
  c->library = lib;
  return c;
}

static void _mtl_free(void* ctx) {
  if (!ctx) return;
  _mtl_ctx_t* c = (_mtl_ctx_t*)ctx;
  for (int i = 0; i < c->pl_count; i++) _v0(c->pl[i], "release");
  _v0(c->library, "release");
  _v0(c->queue, "release");
  _v0(c->device, "release");
  free(c);
}

static void _mtl_flush(_mtl_ctx_t* c) {
  if (!c->pending_cmd) return;
  _v0(c->pending_cmd, "commit");
  _v0(c->pending_cmd, "waitUntilCompleted");
  _v0(c->pending_cmd, "release");
  c->pending_cmd = NULL;
}

static void* _mtl_get_pl(_mtl_ctx_t* c, const char* name) {
  for (int i = 0; i < c->pl_count; i++)
    if (c->pl_name[i] && !strcmp(c->pl_name[i], name)) return c->pl[i];
  void* fn =
      _m1(c->library,
          "newFunctionWithName:", _m1s(objc_getClass("NSString"), "stringWithUTF8String:", name));
  if (!fn) {
    fprintf(stderr, "utensil: Metal fn '%s' not found\n", name);
    return NULL;
  }
  void* ps = ((id (*)(id, SEL, id, void*))objc_msgSend)(
      (id)c->device, sel_getUid("newComputePipelineStateWithFunction:error:"), (id)fn, NULL);
  _v0(fn, "release");
  if (c->pl_count < _MTL_MAX_PL) {
    c->pl[c->pl_count] = ps;
    c->pl_name[c->pl_count] = name;
    c->pl_count++;
  }
  return ps;
}

// get or create the batched command buffer
static void* _mtl_get_cmd(_mtl_ctx_t* c) {
  if (!c->pending_cmd) {
    void* cb = _m0(c->queue, "commandBuffer");
    c->pending_cmd = ((id (*)(id, SEL))objc_msgSend)((id)cb, sel_getUid("retain"));
  }
  return c->pending_cmd;
}

static void _mtl_dispatch(_mtl_ctx_t* c, const char* kern, void** bufs, int nbufs,
                          const void* bytes, int blen, int n) {
  void* cb = _mtl_get_cmd(c);
  void* enc = _m0(cb, "computeCommandEncoder");
  void* ps = _mtl_get_pl(c, kern);
  if (!ps) {
    _v0(enc, "endEncoding");
    return;
  }
  _v1(enc, "setComputePipelineState:", ps);
  for (int i = 0; i < nbufs; i++)
    ((void (*)(id, SEL, id, long, long))objc_msgSend)(
        (id)enc, sel_getUid("setBuffer:offset:atIndex:"), (id)bufs[i], 0L, (long)i);
  if (bytes)
    ((void (*)(id, SEL, const void*, long, long))objc_msgSend)(
        (id)enc, sel_getUid("setBytes:length:atIndex:"), bytes, (long)blen, (long)nbufs);
  unsigned long tg = _l0(ps, "maxTotalThreadsPerThreadgroup");
  unsigned long tgs = ((unsigned long)n + tg - 1) / tg;
  _msize_t grp = {tgs, 1, 1}, thr = {tg, 1, 1};
  ((void (*)(id, SEL, _msize_t, _msize_t))objc_msgSend)(
      (id)enc, sel_getUid("dispatchThreadgroups:threadsPerThreadgroup:"), grp, thr);
  _v0(enc, "endEncoding");
}

// dispatch a kernel that processes rows of a 2D tensor, with one threadgroup per row
static void _mtl_dispatch_rows(_mtl_ctx_t* c, const char* kern, void** bufs, int nbufs,
                               const void* bytes, int blen, int rows, int tgsize) {
  void* cb = _mtl_get_cmd(c);
  void* enc = _m0(cb, "computeCommandEncoder");
  void* ps = _mtl_get_pl(c, kern);
  if (!ps) {
    _v0(enc, "endEncoding");
    return;
  }
  _v1(enc, "setComputePipelineState:", ps);
  for (int i = 0; i < nbufs; i++)
    ((void (*)(id, SEL, id, long, long))objc_msgSend)(
        (id)enc, sel_getUid("setBuffer:offset:atIndex:"), (id)bufs[i], 0L, (long)i);
  if (bytes)
    ((void (*)(id, SEL, const void*, long, long))objc_msgSend)(
        (id)enc, sel_getUid("setBytes:length:atIndex:"), bytes, (long)blen, (long)nbufs);
  _msize_t grp = {(unsigned long)rows, 1, 1};
  _msize_t thr = {(unsigned long)tgsize, 1, 1};
  ((void (*)(id, SEL, _msize_t, _msize_t))objc_msgSend)(
      (id)enc, sel_getUid("dispatchThreadgroups:threadsPerThreadgroup:"), grp, thr);
  _v0(enc, "endEncoding");
}

static void _mtl_matmul(_mtl_ctx_t* ctx, void* a, void* b, void* res, int m, int n, int k, bool ta,
                        bool tb) {
  int ra = ta ? k : m, ca = ta ? m : k;
  int rb = tb ? n : k, cb = tb ? k : n;
  long s = (long)sizeof(float);
  unsigned long mpsf32 = 0x10000020UL;  // MPSDataTypeFloat32
  void* dA =
      _m4l(objc_getClass("MPSMatrixDescriptor"),
           "matrixDescriptorWithRows:columns:rowBytes:dataType:", ra, ca, ca * s, (long)mpsf32);
  void* dB =
      _m4l(objc_getClass("MPSMatrixDescriptor"),
           "matrixDescriptorWithRows:columns:rowBytes:dataType:", rb, cb, cb * s, (long)mpsf32);
  void* dC = _m4l(objc_getClass("MPSMatrixDescriptor"),
                  "matrixDescriptorWithRows:columns:rowBytes:dataType:", m, n, n * s, (long)mpsf32);
  void* mA = ((id (*)(id, SEL, id, id))objc_msgSend)(
      ((id (*)(id, SEL))objc_msgSend)((id)objc_getClass("MPSMatrix"), sel_getUid("alloc")),
      sel_getUid("initWithBuffer:descriptor:"), (id)a, (id)dA);
  void* mB = ((id (*)(id, SEL, id, id))objc_msgSend)(
      ((id (*)(id, SEL))objc_msgSend)((id)objc_getClass("MPSMatrix"), sel_getUid("alloc")),
      sel_getUid("initWithBuffer:descriptor:"), (id)b, (id)dB);
  void* mC = ((id (*)(id, SEL, id, id))objc_msgSend)(
      ((id (*)(id, SEL))objc_msgSend)((id)objc_getClass("MPSMatrix"), sel_getUid("alloc")),
      sel_getUid("initWithBuffer:descriptor:"), (id)res, (id)dC);
  void* mm = ((id (*)(id, SEL, id, bool, bool, unsigned long, unsigned long, unsigned long, double,
                      double))objc_msgSend)(
      ((id (*)(id, SEL))objc_msgSend)((id)objc_getClass("MPSMatrixMultiplication"),
                                      sel_getUid("alloc")),
      sel_getUid("initWithDevice:transposeLeft:transposeRight:"
                 "resultRows:resultColumns:interiorColumns:alpha:beta:"),
      (id)ctx->device, ta, tb, (unsigned long)m, (unsigned long)n, (unsigned long)k, 1.0, 0.0);
  void* cmd = _mtl_get_cmd(ctx);
  ((void (*)(id, SEL, id, id, id, id))objc_msgSend)(
      (id)mm, sel_getUid("encodeToCommandBuffer:leftMatrix:rightMatrix:resultMatrix:"), (id)cmd,
      (id)mA, (id)mB, (id)mC);
  // no commit — work is batched into pending_cmd
  if (mm) _v0(mm, "release");
  if (mA) _v0(mA, "release");
  if (mB) _v0(mB, "release");
  if (mC) _v0(mC, "release");
}

static void* _mtl_buf_alloc(_mtl_ctx_t* c, size_t bytes) {
  return _m2ll(c->device, "newBufferWithLength:options:", (long)bytes, 0L);
}
static void _mtl_buf_free(void* b) { _v0(b, "release"); }
static void _mtl_buf_write(void* b, const float* src, size_t n) {
  memcpy(_p0(b, "contents"), src, n * sizeof(float));
}
static void _mtl_buf_read(void* b, float* dst, size_t n) {
  memcpy(dst, _p0(b, "contents"), n * sizeof(float));
}

// =========================================================
// MPSGraph conv2d (native Winograd/im2col-free conv, replaces the manual
// im2col->MPSMatrix-matmul->col2im pipeline, which profiled ~10x slower)
// =========================================================
#define _MPS_F32 0x10000020UL

static inline void* _mns(long v) {  // [NSNumber numberWithLong:v]
  return ((id (*)(id, SEL, long))objc_msgSend)((id)objc_getClass("NSNumber"),
                                                sel_getUid("numberWithLong:"), v);
}
static void* _nsarr(void** objs, int n) {
  return ((id (*)(id, SEL, const void*, unsigned long))objc_msgSend)(
      (id)objc_getClass("NSArray"), sel_getUid("arrayWithObjects:count:"), objs, (unsigned long)n);
}
static void* _nsdict(void** objs, void** keys, int n) {
  return ((id (*)(id, SEL, const void*, const void*, unsigned long))objc_msgSend)(
      (id)objc_getClass("NSDictionary"), sel_getUid("dictionaryWithObjects:forKeys:count:"), objs,
      keys, (unsigned long)n);
}
static void* _mps_shape4(int a, int b, int c, int d) {
  return _nsarr((void*[]){_mns(a), _mns(b), _mns(c), _mns(d)}, 4);
}
static void* _mps_ph(void* graph, void* shape) {
  return ((id (*)(id, SEL, id, unsigned long, id))objc_msgSend)(
      (id)graph, sel_getUid("placeholderWithShape:dataType:name:"), (id)shape,
      (unsigned long)_MPS_F32, (id)NULL);
}
// wrap a raw MTLBuffer as MPSGraphTensorData for feeding/reading a graph run
static void* _mps_tdata(void* buf, void* shape) {
  void* d = ((id (*)(id, SEL))objc_msgSend)((id)objc_getClass("MPSGraphTensorData"),
                                            sel_getUid("alloc"));
  return ((id (*)(id, SEL, id, id, unsigned long))objc_msgSend)(
      (id)d, sel_getUid("initWithMTLBuffer:shape:dataType:"), (id)buf, (id)shape,
      (unsigned long)_MPS_F32);
}
// run a graph, writing results directly into caller-owned MTLBuffers (no CPU round trip).
// Builds and releases all the per-call ObjC wrapper objects (MPSGraphTensorData,
// NSDictionary) itself, AND wraps the whole call in an autorelease pool.
// This program never pushes a pool anywhere else, so without one here, every
// object MPSGraph autoreleases internally while building/running the graph
// (temporary NDArrays, encoder helpers, etc.) never gets drained -- it just
// accumulates for the life of the process. That's invisible in host RSS (much
// of it is GPU-backed) but very real: a few hundred batches of a many-layer
// network (mobilenetv1) reliably got SIGKILLed by the OS before this fix, and
// even the lighter resnet8 died a couple hundred batches into its 2nd epoch.
static void _mps_run(_mtl_ctx_t* ctx, void* graph, void** feed_keys, void** feed_bufs,
                     void** feed_shapes, int nfeeds, void** res_keys, void** res_bufs,
                     void** res_shapes, int nres) {
  extern void* objc_autoreleasePoolPush(void);
  extern void objc_autoreleasePoolPop(void* ctx);
  void* pool = objc_autoreleasePoolPush();

  void* feed_objs[4];
  void* res_objs[4];
  for (int i = 0; i < nfeeds; i++) feed_objs[i] = _mps_tdata(feed_bufs[i], feed_shapes[i]);
  for (int i = 0; i < nres; i++) res_objs[i] = _mps_tdata(res_bufs[i], res_shapes[i]);
  void* feeds = _nsdict(feed_objs, feed_keys, nfeeds);
  void* results = _nsdict(res_objs, res_keys, nres);
  _mtl_flush(ctx);  // ensure any pending raw-kernel dispatches complete before/order vs the graph
  ((void (*)(id, SEL, id, id, id, id))objc_msgSend)(
      (id)graph, sel_getUid("runWithMTLCommandQueue:feeds:targetOperations:resultsDictionary:"),
      (id)ctx->queue, (id)feeds, (id)NULL, (id)results);
  // feeds/results are autoreleased (NSDictionary factory ctor) -- the pool below
  // owns releasing them now that one actually exists; only release the objects
  // we explicitly alloc+init'd ourselves (MPSGraphTensorData), which the pool
  // never touches.
  for (int i = 0; i < nfeeds; i++) _v0(feed_objs[i], "release");
  for (int i = 0; i < nres; i++) _v0(res_objs[i], "release");

  objc_autoreleasePoolPop(pool);
}

// one compiled graph per ut_conv2d layer instance, holding forward conv +
// both backward gradients (data, weights) so all three share placeholders;
// rebuilt only if the batch shape (N) changes (e.g. last partial batch).
typedef struct {
  void* graph;
  void* xph;
  void* wph;
  void* goph;
  void* fwd_t;
  void* dx_t;
  void* dw_t;
  void* xshape;
  void* wshape;
  void* oshape;
  int N, C, H, W, Cout, KH, KW, stride, pad;
} _ut_conv2d_graph_t;

static _ut_conv2d_graph_t* _ut_conv2d_graph_build(int N, int C, int H, int W, int Cout, int KH,
                                                  int KW, int stride, int pad) {
  _ut_conv2d_graph_t* g = (_ut_conv2d_graph_t*)calloc(1, sizeof(*g));
  g->N = N, g->C = C, g->H = H, g->W = W, g->Cout = Cout, g->KH = KH, g->KW = KW,
  g->stride = stride, g->pad = pad;
  int Ho = (H + 2 * pad - KH) / stride + 1, Wo = (W + 2 * pad - KW) / stride + 1;

  void* a = ((id (*)(id, SEL))objc_msgSend)((id)objc_getClass("MPSGraph"), sel_getUid("alloc"));
  g->graph = _m0(a, "init");

  g->xshape = _mps_shape4(N, C, H, W);
  g->wshape = _mps_shape4(Cout, C, KH, KW);
  g->oshape = _mps_shape4(N, Cout, Ho, Wo);
  g->xph = _mps_ph(g->graph, g->xshape);
  g->wph = _mps_ph(g->graph, g->wshape);
  g->goph = _mps_ph(g->graph, g->oshape);

  // descriptorWithStrideInX:strideInY:dilationRateInX:dilationRateInY:groups:
  //  paddingLeft:paddingRight:paddingTop:paddingBottom:paddingStyle:dataLayout:weightsLayout:
  // paddingStyle=Explicit(0), dataLayout=NCHW(0), weightsLayout=OIHW(2)
  void* desc = ((id (*)(id, SEL, unsigned long, unsigned long, unsigned long, unsigned long,
                        unsigned long, unsigned long, unsigned long, unsigned long, unsigned long,
                        unsigned long, unsigned long, unsigned long))objc_msgSend)(
      (id)objc_getClass("MPSGraphConvolution2DOpDescriptor"),
      sel_getUid("descriptorWithStrideInX:strideInY:dilationRateInX:dilationRateInY:groups:"
                 "paddingLeft:paddingRight:paddingTop:paddingBottom:paddingStyle:dataLayout:"
                 "weightsLayout:"),
      (unsigned long)stride, (unsigned long)stride, 1UL, 1UL, 1UL, (unsigned long)pad,
      (unsigned long)pad, (unsigned long)pad, (unsigned long)pad, 0UL, 0UL, 2UL);

  g->fwd_t = ((id (*)(id, SEL, id, id, id, id))objc_msgSend)(
      (id)g->graph, sel_getUid("convolution2DWithSourceTensor:weightsTensor:descriptor:name:"),
      (id)g->xph, (id)g->wph, (id)desc, (id)NULL);
  g->dx_t = ((id (*)(id, SEL, id, id, id, id, id))objc_msgSend)(
      (id)g->graph,
      sel_getUid("convolution2DDataGradientWithIncomingGradientTensor:weightsTensor:outputShape:"
                 "forwardConvolutionDescriptor:name:"),
      (id)g->goph, (id)g->wph, (id)g->xshape, (id)desc, (id)NULL);
  g->dw_t = ((id (*)(id, SEL, id, id, id, id, id))objc_msgSend)(
      (id)g->graph,
      sel_getUid("convolution2DWeightsGradientWithIncomingGradientTensor:sourceTensor:"
                 "outputShape:forwardConvolutionDescriptor:name:"),
      (id)g->goph, (id)g->xph, (id)g->wshape, (id)desc, (id)NULL);
  return g;
}

static void _ut_conv2d_graph_free(_ut_conv2d_graph_t* g) {
  if (!g) return;
  _v0(g->graph, "release");
  free(g);
}

// lazily (re)build the cached graph for l, keyed on the current batch shape
static _ut_conv2d_graph_t* _ut_conv2d_graph_get(void** slot, int N, int C, int H, int W, int Cout,
                                                int KH, int KW, int stride, int pad) {
  _ut_conv2d_graph_t* g = (_ut_conv2d_graph_t*)*slot;
  if (g && g->N == N && g->C == C && g->H == H && g->W == W && g->Cout == Cout && g->KH == KH &&
      g->KW == KW && g->stride == stride && g->pad == pad)
    return g;
  _ut_conv2d_graph_free(g);
  g = _ut_conv2d_graph_build(N, C, H, W, Cout, KH, KW, stride, pad);
  *slot = g;
  return g;
}

static void* _g_metal = NULL;
static int _g_metal_init = 0;

void* ut_metal_ctx(void) {
  if (!_g_metal_init) _g_metal_init = 1, _g_metal = _mtl_init();
  return _g_metal;
}

#if defined(__GNUC__)
__attribute__((destructor)) static void _ut_metal_cleanup(void) {
  if (_g_metal) {
    _mtl_free(_g_metal);
    _g_metal = NULL;
  }
}
#endif

#else  // !__APPLE__: no GPU backend, everything below always sees a NULL context

typedef struct { int _unused; } _mtl_ctx_t;
void* ut_metal_ctx(void) { return NULL; }
static void _mtl_flush(_mtl_ctx_t* c) { (void)c; }
static void* _mtl_buf_alloc(_mtl_ctx_t* c, size_t bytes) {
  (void)c, (void)bytes;
  return NULL;
}
static void _mtl_buf_free(void* b) { (void)b; }
static void _mtl_buf_write(void* b, const float* src, size_t n) { (void)b, (void)src, (void)n; }
static void _mtl_buf_read(void* b, float* dst, size_t n) { (void)b, (void)dst, (void)n; }
static void _mtl_dispatch(_mtl_ctx_t* c, const char* kern, void** bufs, int nbufs,
                         const void* bytes, int blen, int n) {
  (void)c, (void)kern, (void)bufs, (void)nbufs, (void)bytes, (void)blen, (void)n;
}
static void _mtl_dispatch_rows(_mtl_ctx_t* c, const char* kern, void** bufs, int nbufs,
                               const void* bytes, int blen, int rows, int tgsize) {
  (void)c, (void)kern, (void)bufs, (void)nbufs, (void)bytes, (void)blen, (void)rows, (void)tgsize;
}
static void _mtl_matmul(_mtl_ctx_t* ctx, void* a, void* b, void* res, int m, int n, int k, bool ta,
                        bool tb) {
  (void)ctx, (void)a, (void)b, (void)res, (void)m, (void)n, (void)k, (void)ta, (void)tb;
}

#endif  // __APPLE__

// =========================================================
// Allocation and lifetime management
// =========================================================

ut_shape ut_shape_new(int ndim, const int* dim) {
  ut_shape s = {.ndim = ndim, .nelem = 1};
  for (int i = 0; i < ndim; i++) s.shape[i] = dim[i], s.nelem *= dim[i];
  return s;
}

int ut_index(ut_shape s, const int* idx) {
  int flat = 0, stride = 1;
  for (int i = s.ndim - 1; i >= 0; i--) flat += idx[i] * stride, stride *= s.shape[i];
  return flat;
}

void ut_sync_cpu(ut_tensor* t) {
  if (t->owner) {  // Delegate to owner
    ut_sync_cpu(t->owner);
    t->data = t->owner->data;
    return;
  }
  if (!t->dirty_cpu) return;
  // flush any pending GPU work before reading back to CPU
  _mtl_ctx_t* _mc_s = (_mtl_ctx_t*)ut_metal_ctx();
  if (_mc_s) _mtl_flush(_mc_s);
  if (!t->data) t->data = malloc((size_t)t->shape.nelem * sizeof(float));
  _mtl_buf_read(t->gpu_buf, t->data, (size_t)t->shape.nelem);
  t->dirty_cpu = false;
}

void ut_sync_gpu(ut_tensor* t) {
  if (!t->dirty_gpu || !t->gpu_buf) return;
  _mtl_buf_write(t->gpu_buf, t->data, (size_t)t->shape.nelem);
  t->dirty_gpu = false;
}

void ut_to_device(ut_tensor* t, ut_dev dev) {
  if (t->owner) {  // Delegate device move to owner; update our alias pointers
    ut_to_device(t->owner, dev);
    t->data = t->owner->data;
    t->gpu_buf = t->owner->gpu_buf;
    t->dev = t->owner->dev;
    return;
  }
  if (t->dev == dev) {
    dev == UT_CPU ? ut_sync_cpu(t) : ut_sync_gpu(t);
    return;
  }
  if (dev == UT_METAL) {
    _mtl_ctx_t* mc = (_mtl_ctx_t*)ut_metal_ctx();
    if (!mc) return;
    if (!t->gpu_buf) t->gpu_buf = _mtl_buf_alloc(mc, (size_t)t->shape.nelem * sizeof(float));
    _mtl_buf_write(t->gpu_buf, t->data, (size_t)t->shape.nelem);
    t->dev = UT_METAL;
    t->dirty_cpu = t->dirty_gpu = false;
  } else {
    ut_sync_cpu(t);
    _mtl_buf_free(t->gpu_buf);
    t->gpu_buf = NULL;
    t->dev = UT_CPU;
    t->dirty_gpu = false;
  }
}

ut_tensor* ut_alloc(int ndim, const int* dim, ut_dev dev) {
  ut_tensor* t = (ut_tensor*)malloc(sizeof(ut_tensor));
  *t = (struct ut_tensor){.shape = ut_shape_new(ndim, dim), .dev = dev, .owner = NULL, .rc = 1};
  t->data = (float*)calloc(1, t->shape.nelem * sizeof(float));
  if (dev == UT_METAL) {
    _mtl_ctx_t* mc = (_mtl_ctx_t*)ut_metal_ctx();
    if (mc)
      t->gpu_buf = _mtl_buf_alloc(mc, (size_t)t->shape.nelem * sizeof(float));
    else
      t->dev = UT_CPU;
  }
  return t;
}

ut_tensor* ut_randn(int ndim, int* dim, float mean, float stddev, ut_dev dev) {
  ut_tensor* t = ut_alloc(ndim, dim, UT_CPU);
  for (int i = 0; i < t->shape.nelem; i++) {
    // Box-Muller transform to generate normally distributed random numbers
    float u1 = (float)rand() / (float)RAND_MAX;
    float u2 = (float)rand() / (float)RAND_MAX;
    float z0 = sqrtf(-2.0f * logf(u1)) * cosf(6.28f * u2);
    t->data[i] = z0 * stddev + mean;
  }
  if (dev == UT_METAL) ut_to_device(t, UT_METAL);
  return t;
}

ut_tensor* ut_from_data(int ndim, const int* dim, const float* data, ut_dev dev) {
  ut_tensor* t = ut_alloc(ndim, dim, UT_CPU);
  memcpy(t->data, data, (size_t)t->shape.nelem * sizeof(float));
  if (dev == UT_METAL) ut_to_device(t, UT_METAL);
  return t;
}

ut_tensor* ut_clone(ut_tensor* t) {
  ut_sync_cpu(t);
  ut_tensor* c = ut_alloc(t->shape.ndim, t->shape.shape, UT_CPU);
  memcpy(c->data, t->data, (size_t)t->shape.nelem * sizeof(float));
  if (t->dev == UT_METAL) ut_to_device(c, UT_METAL);
  return c;
}

void ut_free(ut_tensor* t) {
  if (!t || --t->rc > 0) return;
  if (t->owner)
    ut_free(t->owner);
  else {
    free(t->data);
    if (t->gpu_buf) _mtl_buf_free(t->gpu_buf);
  }
  free(t);
}

#define ut_free_all(...)                                                         \
  do {                                                                           \
    ut_tensor* _ts[] = {__VA_ARGS__};                                            \
    for (size_t _i = 0; _i < sizeof(_ts) / sizeof(*_ts); _i++) ut_free(_ts[_i]); \
  } while (0)

ut_tensor* ut_retain(ut_tensor* t) { return t->rc++, t; }

ut_tensor* ut_view(ut_tensor* t, int ndim, const int* dim) {
  ut_sync_cpu(t->owner ? t->owner : t);
  ut_shape ns = ut_shape_new(ndim, dim);
  ut_tensor* v = (ut_tensor*)malloc(sizeof(ut_tensor));
  *v = (struct ut_tensor){.shape = ns,
                          .data = t->data,
                          .gpu_buf = t->gpu_buf,
                          .rc = 1,
                          .dev = t->dev,
                          .owner = ut_retain(t)};
  return v;
}

void ut_reshape(ut_tensor* t, int ndim, const int* dims) {
  ut_shape ns = ut_shape_new(ndim, dims);
  assert(ns.nelem == t->shape.nelem);
  t->shape = ns;
}

ut_tensor* ut_transpose(ut_tensor* t, int dim0, int dim1) {
  int new_shape[UT_MAX_DIMS];
  memcpy(new_shape, t->shape.shape, (size_t)t->shape.ndim * sizeof(int));
  int tmp = new_shape[dim0];
  new_shape[dim0] = new_shape[dim1];
  new_shape[dim1] = tmp;

  // GPU fast-path for 0<->1 dims
  _mtl_ctx_t* _mc_t = (_mtl_ctx_t*)ut_metal_ctx();
  if (_mc_t && t->dev == UT_METAL && (dim0 == 0 || dim1 == 0) && (dim0 == 1 || dim1 == 1)) {
    ut_to_device(t, UT_METAL);
    ut_tensor* out_g = ut_alloc(t->shape.ndim, new_shape, UT_METAL);
    int A = t->shape.shape[0], B = t->shape.shape[1];
    int inner = t->shape.nelem / (A * B);
    int _tp[3] = {A, B, inner};
    _mtl_dispatch(_mc_t, "transpose_01", (void*[]){t->gpu_buf, out_g->gpu_buf}, 2, _tp,
                  (int)sizeof(_tp), t->shape.nelem);
    out_g->dirty_cpu = true;
    return out_g;
  }

  // GPU fast-path for 1<->2 dims
  if (_mc_t && t->dev == UT_METAL && t->shape.ndim >= 3 &&
      ((dim0 == 1 && dim1 == 2) || (dim0 == 2 && dim1 == 1))) {
    ut_to_device(t, UT_METAL);
    ut_tensor* out_g = ut_alloc(t->shape.ndim, new_shape, UT_METAL);
    int A = t->shape.shape[0], B = t->shape.shape[1], C = t->shape.shape[2],
        D = t->shape.ndim >= 4 ? t->shape.shape[3] : 1;
    int _tp[4] = {A, B, C, D};
    _mtl_dispatch(_mc_t, "transpose_12", (void*[]){t->gpu_buf, out_g->gpu_buf}, 2, _tp,
                  (int)sizeof(_tp), t->shape.nelem);
    out_g->dirty_cpu = true;
    return out_g;
  }

  ut_sync_cpu(t);
  ut_tensor* out = ut_alloc(t->shape.ndim, new_shape, UT_CPU);
  int nd = t->shape.ndim;
  for (int i = 0; i < t->shape.nelem; i++) {
    int idx_s[UT_MAX_DIMS] = {0};
    int rem = i;
    for (int d = nd - 1; d >= 0; d--) {
      idx_s[d] = rem % t->shape.shape[d];
      rem /= t->shape.shape[d];
    }
    int idx_d[UT_MAX_DIMS];
    memcpy(idx_d, idx_s, sizeof(idx_d));
    int sw = idx_d[dim0];
    idx_d[dim0] = idx_d[dim1];
    idx_d[dim1] = sw;
    out->data[ut_index(out->shape, idx_d)] = t->data[i];
  }
  return out;
}

// =========================================================
// Elementwise operations
// =========================================================
static void ew_neg(float* out, const float* a, int n) {
  for (int i = 0; i < n; i++) out[i] = -a[i];
}
static void ew_exp(float* out, const float* a, int n) {
  for (int i = 0; i < n; i++) out[i] = expf(a[i]);
}
static void ew_sigmoid(float* out, const float* a, int n) {
  for (int i = 0; i < n; i++) out[i] = 1.f / (1.f + expf(-a[i]));
}
static void ew_tanh(float* out, const float* a, int n) {
  for (int i = 0; i < n; i++) out[i] = tanhf(a[i]);
}
static void ew_relu(float* out, const float* a, int n) {
  for (int i = 0; i < n; i++) out[i] = fmaxf(0.f, a[i]);
}
static void ew_relu6(float* out, const float* a, int n) {
  for (int i = 0; i < n; i++) out[i] = fminf(fmaxf(a[i], 0.f), 6.f);
}
static void ew_hardsigmoid(float* out, const float* a, int n) {
  for (int i = 0; i < n; i++) out[i] = fminf(fmaxf(a[i] + 3.f, 0.f), 6.f) / 6.f;
}
static void ew_hardswish(float* out, const float* a, int n) {
  for (int i = 0; i < n; i++) out[i] = a[i] * fminf(fmaxf(a[i] + 3.f, 0.f), 6.f) / 6.f;
}
static void ew_add(float* out, const float* a, const float* b, int n) {
  for (int i = 0; i < n; i++) out[i] = a[i] + b[i];
}
static void ew_sub(float* out, const float* a, const float* b, int n) {
  for (int i = 0; i < n; i++) out[i] = a[i] - b[i];
}
static void ew_mul(float* out, const float* a, const float* b, int n) {
  for (int i = 0; i < n; i++) out[i] = a[i] * b[i];
}
static void ew_div(float* out, const float* a, const float* b, int n) {
  for (int i = 0; i < n; i++) out[i] = a[i] / b[i];
}
static ut_tensor* ew_unary(ut_tensor* a, const char* kern, void (*fn)(float*, const float*, int)) {
  _mtl_ctx_t* mc = (_mtl_ctx_t*)ut_metal_ctx();
  ut_tensor* out = ut_alloc(a->shape.ndim, a->shape.shape, a->dev);
  if (a->dev == UT_METAL && mc) {
    ut_sync_gpu(a);
    int n = a->shape.nelem;
    _mtl_dispatch(mc, kern, (void*[]){a->gpu_buf, out->gpu_buf}, 2, &n, sizeof(int), n);
    out->dirty_cpu = true;

  } else {
    ut_sync_cpu(a);
    fn(out->data, a->data, a->shape.nelem);
  }
  return out;
}
static ut_tensor* ew_binary(ut_tensor* a, ut_tensor* b, const char* kern,
                            void (*fn)(float*, const float*, const float*, int)) {
  ut_dev dev = (a->dev == UT_METAL || b->dev == UT_METAL) ? UT_METAL : UT_CPU;
  ut_to_device(a, dev);
  ut_to_device(b, dev);
  _mtl_ctx_t* mc = (_mtl_ctx_t*)ut_metal_ctx();
  ut_tensor* out = ut_alloc(a->shape.ndim, a->shape.shape, dev);
  if (dev == UT_METAL && mc) {
    int n = a->shape.nelem;
    _mtl_dispatch(mc, kern, (void*[]){a->gpu_buf, b->gpu_buf, out->gpu_buf}, 3, &n, sizeof(int), n);
    out->dirty_cpu = true;
  } else {
    ut_sync_cpu(a);
    ut_sync_cpu(b);
    fn(out->data, a->data, b->data, a->shape.nelem);
  }
  return out;
}

ut_tensor* ut_neg(ut_tensor* a) { return ew_unary(a, "uneg", ew_neg); }
ut_tensor* ut_exp(ut_tensor* a) { return ew_unary(a, "uexp", ew_exp); }
ut_tensor* ut_sigmoid(ut_tensor* a) { return ew_unary(a, "usig", ew_sigmoid); }
ut_tensor* ut_tanh(ut_tensor* a) { return ew_unary(a, "utanh", ew_tanh); }
ut_tensor* ut_relu(ut_tensor* a) { return ew_unary(a, "urelu", ew_relu); }
ut_tensor* ut_relu6(ut_tensor* a) { return ew_unary(a, "urelu6", ew_relu6); }
ut_tensor* ut_hardsigmoid(ut_tensor* a) { return ew_unary(a, "uhsig", ew_hardsigmoid); }
ut_tensor* ut_hardswish(ut_tensor* a) { return ew_unary(a, "uhswish", ew_hardswish); }
ut_tensor* ut_add(ut_tensor* a, ut_tensor* b) { return ew_binary(a, b, "badd", ew_add); }
ut_tensor* ut_sub(ut_tensor* a, ut_tensor* b) { return ew_binary(a, b, "bsub", ew_sub); }
ut_tensor* ut_mul(ut_tensor* a, ut_tensor* b) { return ew_binary(a, b, "bmul", ew_mul); }
ut_tensor* ut_div(ut_tensor* a, ut_tensor* b) { return ew_binary(a, b, "bdiv", ew_div); }
ut_tensor* ut_scale(ut_tensor* a, float s) {
  _mtl_ctx_t* mc = (_mtl_ctx_t*)ut_metal_ctx();
  ut_tensor* out = ut_alloc(a->shape.ndim, a->shape.shape, a->dev);
  if (a->dev == UT_METAL && mc) {
    ut_sync_gpu(a);
    struct {
      float s;
      int n;
    } args = {s, a->shape.nelem};
    _mtl_dispatch(mc, "bscale", (void*[]){a->gpu_buf, out->gpu_buf}, 2, &args, (int)sizeof(args),
                  a->shape.nelem);
    out->dirty_cpu = true;
  } else {
    ut_sync_cpu(a);
    for (int i = 0; i < a->shape.nelem; i++) out->data[i] = a->data[i] * s;
  }
  return out;
}

// =========================================================
// Matmul
// =========================================================
static void gemm(const float* a, const float* b, float* c, int m, int n, int k, bool ta, bool tb) {
#ifdef __APPLE__
  cblas_sgemm(CblasRowMajor, ta ? CblasTrans : CblasNoTrans, tb ? CblasTrans : CblasNoTrans, m, n,
              k, 1.0f, a, ta ? m : k, b, tb ? k : n, 0.0f, c, n);
#else
  for (int i = 0; i < m; i++)
    for (int j = 0; j < n; j++) {
      float sum = 0;
      for (int l = 0; l < k; l++)
        sum += (ta ? a[l * m + i] : a[i * k + l]) * (tb ? b[j * k + l] : b[l * n + j]);
      c[i * n + j] = sum;
    }
#endif
}

ut_tensor* ut_matmul(ut_tensor* a, ut_tensor* b) {
  // 2Dx2D: MPS path
  if (a->shape.ndim == 2 && b->shape.ndim == 2) {
    int m = a->shape.shape[0], k = a->shape.shape[1], n = b->shape.shape[1];
    if (b->shape.shape[0] != k) return NULL;
    ut_dev dev = (a->dev == UT_METAL || b->dev == UT_METAL) ? UT_METAL : UT_CPU;
    ut_to_device(a, dev);
    ut_to_device(b, dev);
    ut_tensor* c = ut_alloc(2, (int[]){m, n}, dev);
    _mtl_ctx_t* mc = (_mtl_ctx_t*)ut_metal_ctx();
    if (dev == UT_METAL && mc) {
      ut_sync_gpu(a);
      ut_sync_gpu(b);
      _mtl_matmul(mc, a->gpu_buf, b->gpu_buf, c->gpu_buf, m, n, k, false, false);
      c->dirty_cpu = true;
    } else {
      ut_sync_cpu(a);
      ut_sync_cpu(b);
      gemm(a->data, b->data, c->data, m, n, k, false, false);
    }
    return c;
  }
  // batched [B,M,K] x [B,K,N]: GPU via bmatmul kernel, CPU fallback
  if (a->shape.ndim == 3 && b->shape.ndim == 3) {
    int B = a->shape.shape[0], m = a->shape.shape[1], k = a->shape.shape[2];
    if (b->shape.shape[0] != B || b->shape.shape[1] != k) return NULL;
    int n = b->shape.shape[2];
    int cd[3] = {B, m, n};
    ut_dev dev = (a->dev == UT_METAL || b->dev == UT_METAL) ? UT_METAL : UT_CPU;
    _mtl_ctx_t* mc = (_mtl_ctx_t*)ut_metal_ctx();
    if (dev == UT_METAL && mc) {
      ut_to_device(a, dev);
      ut_to_device(b, dev);
      ut_tensor* c = ut_alloc(3, cd, UT_METAL);
      int p[4] = {B, m, n, k};
      // dispatch B*M*N threads via a 3D grid encoded as 1D
      _mtl_dispatch(mc, "bmatmul", (void*[]){a->gpu_buf, b->gpu_buf, c->gpu_buf}, 3, p,
                    (int)sizeof(p), B * m * n);
      c->dirty_cpu = true;
      return c;
    }
    ut_sync_cpu(a);
    ut_sync_cpu(b);
    ut_tensor* c = ut_alloc(3, cd, UT_CPU);
    for (int bi = 0; bi < B; bi++)
      gemm(a->data + bi * m * k, b->data + bi * k * n, c->data + bi * m * n, m, n, k, false, false);
    return c;
  }
  return NULL;
}

static ut_tensor* ut_matmul_t(ut_tensor* a, ut_tensor* b, bool ta, bool tb) {
  int ra = a->shape.shape[0], ca = a->shape.shape[1];
  int rb = b->shape.shape[0], cb = b->shape.shape[1];
  int m = ta ? ca : ra;
  int k = ta ? ra : ca;
  int n = tb ? rb : cb;
  int kb = tb ? cb : rb;
  if (k != kb) return NULL;
  ut_dev dev = (a->dev == UT_METAL || b->dev == UT_METAL) ? UT_METAL : UT_CPU;
  ut_to_device(a, dev);
  ut_to_device(b, dev);
  ut_tensor* c = ut_alloc(2, (int[]){m, n}, dev);
  _mtl_ctx_t* mc = (_mtl_ctx_t*)ut_metal_ctx();
  if (dev == UT_METAL && mc) {
    ut_sync_gpu(a);
    ut_sync_gpu(b);
    _mtl_matmul(mc, a->gpu_buf, b->gpu_buf, c->gpu_buf, m, n, k, ta, tb);
    c->dirty_cpu = true;
  } else {
    ut_sync_cpu(a);
    ut_sync_cpu(b);
    gemm(a->data, b->data, c->data, m, n, k, ta, tb);
  }
  return c;
}

// =========================================================
// Linear layer
// =========================================================
ut_linear ut_linear_alloc(int in, int out, bool bias, ut_dev dev) {
  ut_linear l = {.nin = in, .nout = out};
  l.weight = ut_randn(2, (int[]){in, out}, 0.f, sqrtf(2.f / (float)in), dev);
  if (bias) l.bias = ut_alloc(1, (int[]){out}, dev);
  return l;
}

// out = x @ W + bias
// x:[B,in], W:[in,out] → out:[B,out]
ut_tensor* ut_linear_forward(ut_linear* l, ut_tensor* x) {
  ut_tensor* out = ut_matmul(x, l->weight);
  if (l->bias) {
    _mtl_ctx_t* mc = (_mtl_ctx_t*)ut_metal_ctx();
    if (out->dev == UT_METAL && mc) {
      ut_sync_gpu(out);
      ut_to_device(l->bias, UT_METAL);
      int B = out->shape.shape[0];
      int params[3] = {B, l->nout, 1};
      _mtl_dispatch(mc, "bias_add", (void*[]){out->gpu_buf, l->bias->gpu_buf}, 2, params,
                    (int)sizeof(params), B * l->nout);
      out->dirty_cpu = true;
    } else {
      ut_sync_cpu(out);
      ut_sync_cpu(l->bias);
      int B = out->shape.shape[0];
      for (int b = 0; b < B; b++)
        for (int j = 0; j < l->nout; j++) out->data[b * l->nout + j] += l->bias->data[j];
    }
  }
  return out;
}

ut_tensor* ut_linear_backward(ut_linear* l, ut_tensor* x, ut_tensor* grad_out, ut_tensor* dW,
                              ut_tensor* db) {
  int B = x->shape.shape[0];

  // dW += x^T @ grad_out  — ta=true: x treated as [in, B]
  ut_tensor* dWb = ut_matmul_t(x, grad_out, true, false);
  ut_sync_cpu(dWb);
  ut_sync_cpu(dW);
  for (int i = 0; i < dW->shape.nelem; i++) dW->data[i] += dWb->data[i];
  ut_free(dWb);

  // db += sum(grad_out, axis=0)
  if (l->bias && db) {
    ut_sync_cpu(grad_out);
    ut_sync_cpu(db);
    for (int b = 0; b < B; b++)
      for (int j = 0; j < l->nout; j++) db->data[j] += grad_out->data[b * l->nout + j];
  }

  // dx = grad_out @ W^T  — tb=true: weight treated as [in, out] → [out, in]^T
  return ut_matmul_t(grad_out, l->weight, false, true);
}

void ut_linear_free(ut_linear* l) {
  ut_free_all(l->weight, l->bias);
  l->weight = l->bias = NULL;
}

ut_tensor* ut_relu_backward(ut_tensor* grad_out, ut_tensor* fwd_input) {
  _mtl_ctx_t* mc = (_mtl_ctx_t*)ut_metal_ctx();
  ut_tensor* gi = ut_alloc(grad_out->shape.ndim, grad_out->shape.shape, grad_out->dev);
  if (grad_out->dev == UT_METAL && mc) {
    ut_sync_gpu(grad_out);
    ut_to_device(fwd_input, UT_METAL);
    int n = grad_out->shape.nelem;
    _mtl_dispatch(mc, "relu_bwd", (void*[]){grad_out->gpu_buf, fwd_input->gpu_buf, gi->gpu_buf}, 3,
                  &n, sizeof(int), n);
    gi->dirty_cpu = true;
  } else {
    ut_sync_cpu(grad_out);
    ut_sync_cpu(fwd_input);
    for (int i = 0; i < grad_out->shape.nelem; i++)
      gi->data[i] = fwd_input->data[i] > 0 ? grad_out->data[i] : 0.f;
  }
  return gi;
}

ut_tensor* ut_relu6_backward(ut_tensor* grad_out, ut_tensor* fwd_input) {
  _mtl_ctx_t* mc = (_mtl_ctx_t*)ut_metal_ctx();
  ut_tensor* gi = ut_alloc(grad_out->shape.ndim, grad_out->shape.shape, grad_out->dev);
  if (grad_out->dev == UT_METAL && mc) {
    ut_sync_gpu(grad_out);
    ut_to_device(fwd_input, UT_METAL);
    int n = grad_out->shape.nelem;
    _mtl_dispatch(mc, "relu6_bwd", (void*[]){grad_out->gpu_buf, fwd_input->gpu_buf, gi->gpu_buf}, 3,
                  &n, sizeof(int), n);
    gi->dirty_cpu = true;
  } else {
    ut_sync_cpu(grad_out);
    ut_sync_cpu(fwd_input);
    for (int i = 0; i < grad_out->shape.nelem; i++)
      gi->data[i] = (fwd_input->data[i] > 0 && fwd_input->data[i] < 6) ? grad_out->data[i] : 0.f;
  }
  return gi;
}
// =========================================================
// LayerNorm
// =========================================================
ut_layernorm ut_layernorm_alloc(int d, ut_dev dev) {
  ut_layernorm l = {0};
  l.d = d;
  l.eps = 1e-5f;
  int wd[1] = {d};
  l.weight = ut_alloc(1, wd, UT_CPU);
  l.bias = ut_alloc(1, wd, UT_CPU);
  for (int i = 0; i < d; i++) l.weight->data[i] = 1.f;
  if (dev == UT_METAL) {
    ut_to_device(l.weight, UT_METAL);
    ut_to_device(l.bias, UT_METAL);
  }
  return l;
}

// x: [..., d]  — normalises the last dimension
ut_tensor* ut_layernorm_forward(ut_layernorm* l, ut_tensor* x, ut_layernorm_cache* cache) {
  int d = l->d;
  int rows = x->shape.nelem / d;

  // GPU fast-path
  _mtl_ctx_t* _mc_ln = (_mtl_ctx_t*)ut_metal_ctx();
  if (_mc_ln) {
    ut_to_device(x, UT_METAL);
    ut_to_device(l->weight, UT_METAL);
    ut_to_device(l->bias, UT_METAL);

    ut_tensor* out = ut_alloc(x->shape.ndim, x->shape.shape, UT_METAL);
    int rd[1] = {rows};
    ut_tensor* xnorm_t = ut_alloc(x->shape.ndim, x->shape.shape, UT_METAL);
    ut_tensor* rstd_t = ut_alloc(1, rd, UT_METAL);

    int tgsize = d < 64 ? 32 : (d < 256 ? 64 : (d < 512 ? 128 : 256));
    if (tgsize > 1024) tgsize = 1024;
    int p2[2] = {rows, d};
    _mtl_dispatch_rows(_mc_ln, "ln_fwd",
                       (void*[]){x->gpu_buf, l->weight->gpu_buf, l->bias->gpu_buf, out->gpu_buf,
                                 xnorm_t->gpu_buf, rstd_t->gpu_buf},
                       6, p2, (int)sizeof(p2), rows, tgsize);
    out->dirty_cpu = true;
    xnorm_t->dirty_cpu = true;
    rstd_t->dirty_cpu = true;

    if (cache) {
      cache->xnorm = xnorm_t;
      cache->rstd = rstd_t;
      // allocate a dummy mean (not used by GPU backward but kept in struct)
      cache->mean = ut_alloc(1, rd, UT_CPU);
    } else {
      ut_free(xnorm_t);
      ut_free(rstd_t);
    }
    return out;
  }

  // CPU fallback
  ut_sync_cpu(x);
  ut_sync_cpu(l->weight);
  ut_sync_cpu(l->bias);
  ut_tensor* out = ut_alloc(x->shape.ndim, x->shape.shape, UT_CPU);
  int rd[1] = {rows};
  ut_tensor* mean_t = ut_alloc(1, rd, UT_CPU);
  ut_tensor* rstd_t = ut_alloc(1, rd, UT_CPU);
  ut_tensor* xnorm_t = ut_alloc(x->shape.ndim, x->shape.shape, UT_CPU);
  for (int r = 0; r < rows; r++) {
    const float* row = x->data + r * d;
    float mu = 0;
    for (int i = 0; i < d; i++) mu += row[i];
    mu /= d;
    float var = 0;
    for (int i = 0; i < d; i++) {
      float v = row[i] - mu;
      var += v * v;
    }
    var /= d;
    float rs = 1.f / sqrtf(var + l->eps);
    mean_t->data[r] = mu;
    rstd_t->data[r] = rs;
    for (int i = 0; i < d; i++) {
      float xn = (row[i] - mu) * rs;
      xnorm_t->data[r * d + i] = xn;
      out->data[r * d + i] = l->weight->data[i] * xn + l->bias->data[i];
    }
  }
  if (cache) {
    cache->xnorm = xnorm_t;
    cache->mean = mean_t;
    cache->rstd = rstd_t;
  } else {
    ut_free(xnorm_t);
    ut_free(mean_t);
    ut_free(rstd_t);
  }
  return out;
}

ut_tensor* ut_layernorm_backward(ut_layernorm* l, ut_layernorm_cache* cache, ut_tensor* grad_out,
                                 ut_tensor* dW, ut_tensor* db) {
  int d = l->d, rows = grad_out->shape.nelem / d;

  // dW and db are always accumulated on CPU (small [d] vectors)
  ut_sync_cpu(grad_out);
  ut_sync_cpu(cache->xnorm);
  ut_sync_cpu(dW);
  ut_sync_cpu(db);
  for (int r = 0; r < rows; r++) {
    const float* go = grad_out->data + r * d;
    const float* xn = cache->xnorm->data + r * d;
    for (int i = 0; i < d; i++) {
      dW->data[i] += go[i] * xn[i];
      db->data[i] += go[i];
    }
  }
  dW->dirty_gpu = true;
  db->dirty_gpu = true;

  // GPU fast-path for dx
  _mtl_ctx_t* _mc_lnb = (_mtl_ctx_t*)ut_metal_ctx();
  if (_mc_lnb) {
    ut_to_device(grad_out, UT_METAL);
    ut_to_device(cache->xnorm, UT_METAL);
    ut_to_device(cache->rstd, UT_METAL);
    ut_to_device(l->weight, UT_METAL);
    ut_tensor* dx = ut_alloc(grad_out->shape.ndim, grad_out->shape.shape, UT_METAL);
    int tgsize = d < 64 ? 32 : (d < 256 ? 64 : (d < 512 ? 128 : 256));
    if (tgsize > 1024) tgsize = 1024;
    int p2[2] = {rows, d};
    _mtl_dispatch_rows(_mc_lnb, "ln_bwd",
                       (void*[]){grad_out->gpu_buf, cache->xnorm->gpu_buf, cache->rstd->gpu_buf,
                                 l->weight->gpu_buf, dx->gpu_buf},
                       5, p2, (int)sizeof(p2), rows, tgsize);
    dx->dirty_cpu = true;
    return dx;
  }

  // CPU fallback
  ut_sync_cpu(cache->rstd);
  ut_sync_cpu(l->weight);
  ut_tensor* dx = ut_alloc(grad_out->shape.ndim, grad_out->shape.shape, UT_CPU);
  for (int r = 0; r < rows; r++) {
    const float* go = grad_out->data + r * d;
    const float* xn = cache->xnorm->data + r * d;
    float rs = cache->rstd->data[r];
    float sum_go_xn = 0, sum_go = 0;
    for (int i = 0; i < d; i++) {
      sum_go_xn += go[i] * l->weight->data[i] * xn[i];
      sum_go += go[i] * l->weight->data[i];
    }
    float* dxr = dx->data + r * d;
    for (int i = 0; i < d; i++)
      dxr[i] = rs * (l->weight->data[i] * go[i] - (sum_go + xn[i] * sum_go_xn) / (float)d);
  }
  return dx;
}

void ut_layernorm_cache_free(ut_layernorm_cache* c) {
  ut_free_all(c->xnorm, c->mean, c->rstd);
  c->xnorm = c->mean = c->rstd = NULL;
}
void ut_layernorm_free(ut_layernorm* l) {
  ut_free_all(l->weight, l->bias);
  l->weight = l->bias = NULL;
}

// =========================================================
// im2col / col2im
// =========================================================

ut_tensor* ut_im2col(ut_tensor* x, int kh, int kw, int stride, int pad) {
  int N = x->shape.shape[0], C = x->shape.shape[1];
  int H = x->shape.shape[2], W = x->shape.shape[3];
  int Ho = (H + 2 * pad - kh) / stride + 1;
  int Wo = (W + 2 * pad - kw) / stride + 1;
  int col_dims[2] = {C * kh * kw, N * Ho * Wo};

  _mtl_ctx_t* mc = (_mtl_ctx_t*)ut_metal_ctx();
  if (mc && x->dev == UT_METAL) {
    ut_tensor* col = ut_alloc(2, col_dims, UT_METAL);
    int params[10] = {N, C, H, W, kh, kw, stride, pad, Ho, Wo};
    _mtl_dispatch(mc, "im2col_k", (void*[]){x->gpu_buf, col->gpu_buf}, 2, params,
                  (int)sizeof(params), C * kh * kw * N * Ho * Wo);
    col->dirty_cpu = true;
    return col;
  }

  // CPU path
  ut_sync_cpu(x);
  ut_tensor* col = ut_alloc(2, col_dims, UT_CPU);
  for (int n = 0; n < N; n++)
    for (int c = 0; c < C; c++)
      for (int hh = 0; hh < kh; hh++)
        for (int ww = 0; ww < kw; ww++) {
          int row = c * kh * kw + hh * kw + ww;
          for (int oh = 0; oh < Ho; oh++)
            for (int ow = 0; ow < Wo; ow++) {
              int ih = oh * stride - pad + hh;
              int iw = ow * stride - pad + ww;
              float v = 0;
              if (ih >= 0 && ih < H && iw >= 0 && iw < W)
                v = x->data[((n * C + c) * H + ih) * W + iw];
              col->data[row * (N * Ho * Wo) + n * Ho * Wo + oh * Wo + ow] = v;
            }
        }
  return col;
}

ut_tensor* ut_col2im(ut_tensor* col, int N, int C, int H, int W, int kh, int kw, int stride,
                     int pad) {
  int Ho = (H + 2 * pad - kh) / stride + 1;
  int Wo = (W + 2 * pad - kw) / stride + 1;
  int dims[4] = {N, C, H, W};

  _mtl_ctx_t* _mc_c = (_mtl_ctx_t*)ut_metal_ctx();
  if (_mc_c && col->gpu_buf) {
    ut_to_device(col, UT_METAL);
    ut_tensor* out = ut_alloc(4, dims, UT_METAL);
    int _cp[10] = {N, C, H, W, kh, kw, stride, pad, Ho, Wo};
    _mtl_dispatch(_mc_c, "col2im_k", (void*[]){col->gpu_buf, out->gpu_buf}, 2, _cp,
                  (int)sizeof(_cp), N * C * H * W);
    out->dirty_cpu = true;
    return out;
  }

  ut_sync_cpu(col);
  ut_tensor* out = ut_alloc(4, dims, UT_CPU);
  for (int n = 0; n < N; n++)
    for (int c = 0; c < C; c++)
      for (int hh = 0; hh < kh; hh++)
        for (int ww = 0; ww < kw; ww++) {
          int row = c * kh * kw + hh * kw + ww;
          for (int oh = 0; oh < Ho; oh++)
            for (int ow = 0; ow < Wo; ow++) {
              int ih = oh * stride - pad + hh;
              int iw = ow * stride - pad + ww;
              if (ih >= 0 && ih < H && iw >= 0 && iw < W)
                out->data[((n * C + c) * H + ih) * W + iw] +=
                    col->data[row * (N * Ho * Wo) + n * Ho * Wo + oh * Wo + ow];
            }
        }
  return out;
}

// =========================================================
// Conv1D
// =========================================================

ut_conv1d ut_conv1d_alloc(int in_c, int out_c, int kw, int stride, int pad, bool bias, ut_dev dev) {
  ut_conv1d l = {.in_c = in_c, .out_c = out_c, .kw = kw, .stride = stride, .pad = pad};
  float std = sqrtf(2.f / (float)(in_c * kw));
  l.weight = ut_randn(3, (int[]){out_c, in_c, kw}, 0.f, std, dev);
  if (bias) l.bias = ut_alloc(1, (int[]){out_c}, dev);
  return l;
}

// x: [N, C, L] — treat as [N, C, 1, L] for conv2d im2col
ut_tensor* ut_conv1d_forward(ut_conv1d* l, ut_tensor* x, ut_conv1d_cache* cache) {
  int N = x->shape.shape[0], L = x->shape.shape[2];
  int Lo = (L + 2 * l->pad - l->kw) / l->stride + 1;
  // expand x to [N, C, 1, L]
  ut_reshape(x, 4, (int[]){N, l->in_c, 1, L});  // temporarily treat as [N, in_c, 1, L]

  // Use im2col with kh=1, stride_h=1, pad_h=0
  ut_tensor* col = ut_im2col(x, 1, l->kw, l->stride, l->pad);

  ut_tensor w_view = *l->weight;
  w_view.shape = ut_shape_new(2, (int[]){l->out_c, l->in_c * l->kw});
  w_view.rc = 0x7fffffff;

  ut_tensor* out2 = ut_matmul(&w_view, col);  // [out_c, N*Lo]
  ut_sync_cpu(out2);
  // out2 is [out_c, N*Lo] — reshape to [out_c, N, Lo] then transpose(0,1)
  ut_reshape(out2, 3, (int[]){l->out_c, N, Lo});
  ut_tensor* out = ut_transpose(out2, 0, 1);  // [N, out_c, Lo]
  ut_free(out2);

  if (l->bias) {
    ut_sync_cpu(out);
    ut_sync_cpu(l->bias);
    for (int n = 0; n < N; n++)
      for (int oc = 0; oc < l->out_c; oc++)
        for (int lp = 0; lp < Lo; lp++)
          out->data[(n * l->out_c + oc) * Lo + lp] += l->bias->data[oc];
  }
  // restore x to original 3D shape before cache retain
  ut_reshape(x, 3, (int[]){N, l->in_c, L});
  if (cache) {
    cache->input = ut_retain(x);
    cache->col = ut_retain(col);
  }
  ut_free(col);
  return out;
}

ut_tensor* ut_conv1d_backward(ut_conv1d* l, ut_conv1d_cache* cache, ut_tensor* grad_out,
                              ut_tensor* dW, ut_tensor* db) {
  ut_tensor* col = cache->col;
  int N = cache->input->shape.shape[0];
  int L = cache->input->shape.shape[2];
  int Lo = (L + 2 * l->pad - l->kw) / l->stride + 1;
  ut_sync_cpu(grad_out);
  ut_sync_cpu(col);
  ut_sync_cpu(dW);

  // go_2d: [out_c, N*Lo] — transpose + reshape grad_out [N,out_c,Lo]
  ut_tensor* go_t = ut_transpose(grad_out, 0, 1);  // [out_c, N, Lo]
  ut_reshape(go_t, 2, (int[]){l->out_c, N * Lo});  // [out_c, N*Lo]

  _mtl_ctx_t* _mc = (_mtl_ctx_t*)ut_metal_ctx();
  if (_mc) ut_to_device(go_t, UT_METAL);

  ut_tensor* dWb = ut_matmul_t(go_t, col, false, true);
  ut_sync_cpu(dWb);
  ut_sync_cpu(dW);
  for (int i = 0; i < dW->shape.nelem; i++) dW->data[i] += dWb->data[i];
  ut_free(dWb);

  if (l->bias && db) {
    ut_sync_cpu(db);
    ut_sync_cpu(grad_out);
    for (int n = 0; n < N; n++)
      for (int oc = 0; oc < l->out_c; oc++)
        for (int lp = 0; lp < Lo; lp++)
          db->data[oc] += grad_out->data[(n * l->out_c + oc) * Lo + lp];
  }

  ut_tensor w_view = *l->weight;
  w_view.shape = ut_shape_new(2, (int[]){l->out_c, l->in_c * l->kw});
  w_view.rc = 0x7fffffff;
  ut_tensor* dcol = ut_matmul_t(&w_view, go_t, true, false);
  ut_free(go_t);

  // col2im back to [N, C, 1, L] then squeeze to [N, C, L]
  ut_tensor* dx4 = ut_col2im(dcol, N, l->in_c, 1, L, 1, l->kw, l->stride, l->pad);
  ut_free(dcol);
  ut_reshape(dx4, 3, (int[]){N, l->in_c, L});
  return dx4;
}

void ut_conv1d_cache_free(ut_conv1d_cache* c) {
  ut_free_all(c->input, c->col);
  c->input = c->col = NULL;
}
void ut_conv1d_free(ut_conv1d* l) {
  ut_free_all(l->weight, l->bias);
  l->weight = l->bias = NULL;
}

// =========================================================
// LSTM
// =========================================================
// Vanilla single-layer LSTM. The two big matmuls per step (x@W_ih, h@W_hh)
// go through ut_matmul, so they run on whichever device the weights/inputs
// are on; the gating nonlinearities and state update are a plain CPU loop,
// the same way conv1d/conv2d finish their bias-add and layernorm/batchnorm2d
// compute their statistics. Stacking layers or running bidirectionally is
// left to the caller — wire two ut_lstm instances together.

ut_lstm ut_lstm_alloc(int in, int hidden, ut_dev dev) {
  ut_lstm l = {.in = in, .hidden = hidden};
  float std = sqrtf(1.f / (float)hidden);
  l.W_ih = ut_randn(2, (int[]){in, 4 * hidden}, 0.f, std, dev);
  l.W_hh = ut_randn(2, (int[]){hidden, 4 * hidden}, 0.f, std, dev);
  l.bias = ut_alloc(1, (int[]){4 * hidden}, dev);
  // forget-gate bias = 1 (Jozefowicz et al. 2015) so early training doesn't
  // forget everything by default
  ut_sync_cpu(l.bias);
  for (int j = 0; j < hidden; j++) l.bias->data[hidden + j] = 1.f;
  l.bias->dirty_gpu = true;
  return l;
}

// x:[B,in], h_prev/c_prev:[B,hidden] -> returns h:[B,hidden], writes new cell
// state into *c_out:[B,hidden] (required; caller owns the returned tensor and
// typically feeds it back in as c_prev on the next step).
ut_tensor* ut_lstm_step(ut_lstm* l, ut_tensor* x, ut_tensor* h_prev, ut_tensor* c_prev,
                        ut_tensor** c_out, ut_lstm_cache* cache) {
  int B = x->shape.shape[0], H = l->hidden;

  ut_tensor* zx = ut_matmul(x, l->W_ih);       // [B,4H]
  ut_tensor* zh = ut_matmul(h_prev, l->W_hh);  // [B,4H]
  ut_tensor* z = ut_add(zx, zh);
  ut_free_all(zx, zh);
  ut_sync_cpu(z);
  ut_sync_cpu(l->bias);
  ut_sync_cpu(c_prev);

  ut_tensor* gi = ut_alloc(2, (int[]){B, H}, UT_CPU);
  ut_tensor* gf = ut_alloc(2, (int[]){B, H}, UT_CPU);
  ut_tensor* gg = ut_alloc(2, (int[]){B, H}, UT_CPU);
  ut_tensor* go = ut_alloc(2, (int[]){B, H}, UT_CPU);
  ut_tensor* c = ut_alloc(2, (int[]){B, H}, UT_CPU);
  ut_tensor* h = ut_alloc(2, (int[]){B, H}, UT_CPU);

  for (int b = 0; b < B; b++) {
    const float* zb = z->data + b * 4 * H;
    const float* bb = l->bias->data;
    const float* cp = c_prev->data + b * H;
    for (int j = 0; j < H; j++) {
      float ig = 1.f / (1.f + expf(-(zb[j] + bb[j])));
      float fg = 1.f / (1.f + expf(-(zb[H + j] + bb[H + j])));
      float cg = tanhf(zb[2 * H + j] + bb[2 * H + j]);
      float og = 1.f / (1.f + expf(-(zb[3 * H + j] + bb[3 * H + j])));
      float cc = fg * cp[j] + ig * cg;
      gi->data[b * H + j] = ig;
      gf->data[b * H + j] = fg;
      gg->data[b * H + j] = cg;
      go->data[b * H + j] = og;
      c->data[b * H + j] = cc;
      h->data[b * H + j] = og * tanhf(cc);
    }
  }
  ut_free(z);

  if (cache) {
    cache->x = ut_retain(x);
    cache->h_prev = ut_retain(h_prev);
    cache->c_prev = ut_retain(c_prev);
    cache->i = gi;
    cache->f = gf;
    cache->g = gg;
    cache->o = go;
    cache->c = ut_retain(c);
  } else {
    ut_free_all(gi, gf, gg, go);
  }
  *c_out = c;
  return h;
}

// dh: gradient w.r.t. this step's h (recurrent + any direct consumer).
// dc: gradient w.r.t. this step's c flowing in from the next step (pass a
// zeroed [B,hidden] tensor at the last step of a sequence).
// Accumulates into dW_ih/dW_hh/db (caller-owned accumulators, like every
// other _backward in this file); writes fresh *dx/*dh_prev/*dc_prev.
void ut_lstm_backward(ut_lstm* l, ut_lstm_cache* c, ut_tensor* dh, ut_tensor* dc, ut_tensor* dW_ih,
                      ut_tensor* dW_hh, ut_tensor* db, ut_tensor** dx, ut_tensor** dh_prev,
                      ut_tensor** dc_prev) {
  int B = c->x->shape.shape[0], H = l->hidden;
  ut_sync_cpu(dh);
  ut_sync_cpu(dc);
  ut_sync_cpu(c->i);
  ut_sync_cpu(c->f);
  ut_sync_cpu(c->g);
  ut_sync_cpu(c->o);
  ut_sync_cpu(c->c);
  ut_sync_cpu(c->c_prev);

  ut_tensor* dz = ut_alloc(2, (int[]){B, 4 * H}, UT_CPU);
  ut_tensor* dcp = ut_alloc(2, (int[]){B, H}, UT_CPU);

  for (int b = 0; b < B; b++) {
    const float* dhb = dh->data + b * H;
    const float* dcb = dc->data + b * H;
    const float* ib = c->i->data + b * H;
    const float* fb = c->f->data + b * H;
    const float* gb = c->g->data + b * H;
    const float* ob = c->o->data + b * H;
    const float* cb = c->c->data + b * H;
    const float* cpb = c->c_prev->data + b * H;
    float* dzb = dz->data + b * 4 * H;
    float* dcpb = dcp->data + b * H;
    for (int j = 0; j < H; j++) {
      float tc = tanhf(cb[j]);
      float dov = dhb[j] * tc;
      float dctot = dcb[j] + dhb[j] * ob[j] * (1.f - tc * tc);
      float dfv = dctot * cpb[j];
      float div = dctot * gb[j];
      float dgv = dctot * ib[j];
      dcpb[j] = dctot * fb[j];
      dzb[j] = div * ib[j] * (1.f - ib[j]);
      dzb[H + j] = dfv * fb[j] * (1.f - fb[j]);
      dzb[2 * H + j] = dgv * (1.f - gb[j] * gb[j]);
      dzb[3 * H + j] = dov * ob[j] * (1.f - ob[j]);
    }
  }

  ut_tensor* dWx = ut_matmul_t(c->x, dz, true, false);
  ut_sync_cpu(dWx);
  ut_sync_cpu(dW_ih);
  for (int k = 0; k < dW_ih->shape.nelem; k++) dW_ih->data[k] += dWx->data[k];
  ut_free(dWx);

  ut_tensor* dWh = ut_matmul_t(c->h_prev, dz, true, false);
  ut_sync_cpu(dWh);
  ut_sync_cpu(dW_hh);
  for (int k = 0; k < dW_hh->shape.nelem; k++) dW_hh->data[k] += dWh->data[k];
  ut_free(dWh);

  if (db) {
    ut_sync_cpu(db);
    for (int b = 0; b < B; b++)
      for (int k = 0; k < 4 * H; k++) db->data[k] += dz->data[b * 4 * H + k];
  }

  *dx = ut_matmul_t(dz, l->W_ih, false, true);
  *dh_prev = ut_matmul_t(dz, l->W_hh, false, true);
  *dc_prev = dcp;

  ut_free(dz);
}

void ut_lstm_cache_free(ut_lstm_cache* c) {
  ut_free_all(c->x, c->h_prev, c->c_prev, c->i, c->f, c->g, c->o, c->c);
  memset(c, 0, sizeof(*c));
}

void ut_lstm_free(ut_lstm* l) {
  ut_free_all(l->W_ih, l->W_hh, l->bias);
  l->W_ih = l->W_hh = l->bias = NULL;
}

// x_seq: [T,B,in]. h0/c0: [B,hidden], or NULL for a zero initial state.
// cache may be NULL for an inference-only pass (no per-step gate state is
// kept, same as passing NULL to any other layer's _forward in this file).
// Returns h_seq [T,B,hidden]; writes the final state into *h_n/*c_n if given
// (both freshly owned tensors the caller must free).
ut_tensor* ut_lstm_forward_seq(ut_lstm* l, ut_tensor* x_seq, ut_tensor* h0, ut_tensor* c0,
                               ut_lstm_seq_cache* cache, ut_tensor** h_n, ut_tensor** c_n) {
  int T = x_seq->shape.shape[0], B = x_seq->shape.shape[1], IN = x_seq->shape.shape[2];
  int H = l->hidden;
  ut_sync_cpu(x_seq);

  ut_tensor* h_seq = ut_alloc(3, (int[]){T, B, H}, UT_CPU);
  if (cache) {
    cache->steps = malloc((size_t)T * sizeof(ut_lstm_cache));
    cache->t = T;
  }

  ut_tensor* h = h0 ? ut_retain(h0) : ut_alloc(2, (int[]){B, H}, UT_CPU);
  ut_tensor* c = c0 ? ut_retain(c0) : ut_alloc(2, (int[]){B, H}, UT_CPU);

  for (int t = 0; t < T; t++) {
    ut_tensor* xt = ut_from_data(2, (int[]){B, IN}, x_seq->data + (size_t)t * B * IN, UT_CPU);
    ut_tensor *c_next, *h_next =
        ut_lstm_step(l, xt, h, c, &c_next, cache ? &cache->steps[t] : NULL);
    memcpy(h_seq->data + (size_t)t * B * H, h_next->data, (size_t)B * H * sizeof(float));
    ut_free_all(xt, h, c);
    h = h_next;
    c = c_next;
  }
  if (h_n)
    *h_n = h;
  else
    ut_free(h);
  if (c_n)
    *c_n = c;
  else
    ut_free(c);
  return h_seq;
}

// grad_h_seq: [T,B,hidden], the external gradient contribution to h at each
// timestep (zero everywhere except where h_t is actually consumed — e.g. only
// the last slice populated for a many-to-one classifier that reads h_n).
// Accumulates into dW_ih/dW_hh/db; returns dx_seq [T,B,in].
ut_tensor* ut_lstm_backward_seq(ut_lstm* l, ut_lstm_seq_cache* cache, ut_tensor* grad_h_seq,
                                ut_tensor* dW_ih, ut_tensor* dW_hh, ut_tensor* db) {
  int T = cache->t;
  int B = cache->steps[0].x->shape.shape[0];
  int IN = l->in, H = l->hidden;
  ut_sync_cpu(grad_h_seq);

  ut_tensor* dx_seq = ut_alloc(3, (int[]){T, B, IN}, UT_CPU);
  ut_tensor* dh_next = ut_alloc(2, (int[]){B, H}, UT_CPU);
  ut_tensor* dc_next = ut_alloc(2, (int[]){B, H}, UT_CPU);

  for (int t = T - 1; t >= 0; t--) {
    ut_tensor* dh = ut_alloc(2, (int[]){B, H}, UT_CPU);
    for (int k = 0; k < B * H; k++)
      dh->data[k] = grad_h_seq->data[(size_t)t * B * H + k] + dh_next->data[k];

    ut_tensor *dx, *dh_prev, *dc_prev;
    ut_lstm_backward(l, &cache->steps[t], dh, dc_next, dW_ih, dW_hh, db, &dx, &dh_prev, &dc_prev);

    memcpy(dx_seq->data + (size_t)t * B * IN, dx->data, (size_t)B * IN * sizeof(float));
    ut_free_all(dh, dx, dh_next, dc_next);
    dh_next = dh_prev;
    dc_next = dc_prev;
  }
  ut_free_all(dh_next, dc_next);
  return dx_seq;
}

void ut_lstm_seq_cache_free(ut_lstm_seq_cache* c) {
  for (int t = 0; t < c->t; t++) ut_lstm_cache_free(&c->steps[t]);
  free(c->steps);
  c->steps = NULL;
  c->t = 0;
}

// =========================================================
// Conv2D
// =========================================================
ut_conv2d ut_conv2d_alloc(int in_c, int out_c, int kh, int kw, int stride, int pad, bool bias,
                          ut_dev dev) {
  ut_conv2d l = {.in_c = in_c, .out_c = out_c, .kh = kh, .kw = kw, .stride = stride, .pad = pad};
  float std = sqrtf(2.f / (float)(in_c * kh * kw));
  l.weight = ut_randn(4, (int[]){out_c, in_c, kh, kw}, 0.f, std, dev);
  if (bias) l.bias = ut_alloc(1, (int[]){out_c}, dev);
  return l;
}

// x: [N, in_c, H, W]
ut_tensor* ut_conv2d_forward(ut_conv2d* l, ut_tensor* x, ut_conv2d_cache* cache) {
  int N = x->shape.shape[0], H = x->shape.shape[2], W = x->shape.shape[3];
  int Ho = (H + 2 * l->pad - l->kh) / l->stride + 1;
  int Wo = (W + 2 * l->pad - l->kw) / l->stride + 1;

#ifdef __APPLE__
  // MPSGraph path: native convolution kernel (Winograd/implicit-GEMM, picked
  // internally by MPS) instead of im2col+matmul -- ~10x faster in practice,
  // see PERF.md. Falls through to the im2col path below for CPU tensors.
  _mtl_ctx_t* mc0 = (_mtl_ctx_t*)ut_metal_ctx();
  if (mc0 && x->dev == UT_METAL) {
    ut_sync_gpu(x);
    ut_to_device(l->weight, UT_METAL);
    _ut_conv2d_graph_t* g = _ut_conv2d_graph_get(&l->_mpsg, N, l->in_c, H, W, l->out_c, l->kh,
                                                 l->kw, l->stride, l->pad);
    ut_tensor* out = ut_alloc(4, (int[]){N, l->out_c, Ho, Wo}, UT_METAL);
    _mps_run(mc0, g->graph, (void*[]){g->xph, g->wph},
             (void*[]){x->gpu_buf, l->weight->gpu_buf}, (void*[]){g->xshape, g->wshape}, 2,
             (void*[]){g->fwd_t}, (void*[]){out->gpu_buf}, (void*[]){g->oshape}, 1);
    out->dirty_cpu = true;

    if (l->bias) {
      ut_to_device(l->bias, UT_METAL);
      int params[3] = {N, l->out_c, Ho * Wo};
      _mtl_dispatch(mc0, "bias_add", (void*[]){out->gpu_buf, l->bias->gpu_buf}, 2, params,
                    (int)sizeof(params), N * l->out_c * Ho * Wo);
      out->dirty_cpu = true;
    }

    if (cache) {
      cache->input = ut_retain(x);
      cache->col = NULL;  // no im2col buffer on this path -- signals backward to use MPSGraph too
    }
    return out;
  }
#endif

  ut_tensor* col = ut_im2col(x, l->kh, l->kw, l->stride, l->pad);

  ut_tensor w_view = *l->weight;
  w_view.shape = ut_shape_new(2, (int[]){l->out_c, l->in_c * l->kh * l->kw});
  w_view.rc = 0x7fffffff;

  ut_tensor* out2 = ut_matmul(&w_view, col);  // [out_c, N*Ho*Wo]
  // reshape to [out_c, N, Ho, Wo] then transpose(0,1) -> NCHW
  ut_reshape(out2, 4, (int[]){l->out_c, N, Ho, Wo});
  ut_tensor* out = ut_transpose(out2, 0, 1);  // [N, out_c, Ho, Wo]
  ut_free(out2);

  if (l->bias) {
    _mtl_ctx_t* mc = (_mtl_ctx_t*)ut_metal_ctx();
    if (out->dev == UT_METAL && mc) {
      ut_sync_gpu(out);
      ut_to_device(l->bias, UT_METAL);
      int params[3] = {N, l->out_c, Ho * Wo};
      _mtl_dispatch(mc, "bias_add", (void*[]){out->gpu_buf, l->bias->gpu_buf}, 2, params,
                    (int)sizeof(params), N * l->out_c * Ho * Wo);
      out->dirty_cpu = true;
    } else {
      ut_sync_cpu(out);
      ut_sync_cpu(l->bias);
      for (int n = 0; n < N; n++)
        for (int oc = 0; oc < l->out_c; oc++)
          for (int h = 0; h < Ho; h++)
            for (int w = 0; w < Wo; w++)
              out->data[((n * l->out_c + oc) * Ho + h) * Wo + w] += l->bias->data[oc];
    }
  }

  if (cache) {
    cache->input = ut_retain(x);
    cache->col = ut_retain(col);
  }
  ut_free(col);
  return out;
}

ut_tensor* ut_conv2d_backward(ut_conv2d* l, ut_conv2d_cache* cache, ut_tensor* grad_out,
                              ut_tensor* dW, ut_tensor* db) {
  ut_tensor* col = cache->col;
  int N = cache->input->shape.shape[0];
  int H = cache->input->shape.shape[2], W = cache->input->shape.shape[3];
  int Ho = (H + 2 * l->pad - l->kh) / l->stride + 1;
  int Wo = (W + 2 * l->pad - l->kw) / l->stride + 1;

  if (l->bias && db) {
    _mtl_ctx_t* mc = (_mtl_ctx_t*)ut_metal_ctx();
    if (mc && grad_out->dev == UT_METAL) {
      // reuse dwconv2d_bwd_db's per-channel reduction over [N,C,Ho,Wo] -- only
      // reads p[0]=N, p[1]=C, p[8]=Ho, p[9]=Wo, so it applies unchanged here
      ut_sync_gpu(grad_out);
      int params[10] = {N, l->out_c, H, W, l->kh, l->kw, l->stride, l->pad, Ho, Wo};
      int M = N * Ho * Wo;
      int tgsize = M < 64 ? 32 : (M < 256 ? 64 : (M < 512 ? 128 : 256));
      if (tgsize > 1024) tgsize = 1024;
      ut_tensor* dbp = ut_alloc(1, (int[]){l->out_c}, UT_METAL);
      _mtl_dispatch_rows(mc, "dwconv2d_bwd_db", (void*[]){grad_out->gpu_buf, dbp->gpu_buf}, 2,
                         params, (int)sizeof(params), l->out_c, tgsize);
      dbp->dirty_cpu = true;
      ut_sync_cpu(dbp);
      ut_sync_cpu(db);
      for (int c = 0; c < l->out_c; c++) db->data[c] += dbp->data[c];
      db->dirty_gpu = true;
      ut_free(dbp);
    } else {
      ut_sync_cpu(grad_out);
      ut_sync_cpu(db);
      for (int n = 0; n < N; n++)
        for (int oc = 0; oc < l->out_c; oc++)
          for (int h = 0; h < Ho; h++)
            for (int w = 0; w < Wo; w++)
              db->data[oc] += grad_out->data[((n * l->out_c + oc) * Ho + h) * Wo + w];
    }
  }

#ifdef __APPLE__
  // MPSGraph path -- mirrors the forward path above; col is NULL exactly when
  // forward used MPSGraph (see ut_conv2d_forward), so that flag also selects
  // the matching backward here.
  _mtl_ctx_t* mc1 = (_mtl_ctx_t*)ut_metal_ctx();
  if (mc1 && grad_out->dev == UT_METAL && col == NULL) {
    ut_tensor* x = cache->input;
    ut_sync_gpu(grad_out);
    ut_to_device(x, UT_METAL);
    ut_to_device(l->weight, UT_METAL);
    _ut_conv2d_graph_t* g = _ut_conv2d_graph_get(&l->_mpsg, N, l->in_c, H, W, l->out_c, l->kh,
                                                 l->kw, l->stride, l->pad);
    ut_tensor* dx = ut_alloc(4, (int[]){N, l->in_c, H, W}, UT_METAL);
    ut_tensor* dWb = ut_alloc(l->weight->shape.ndim, l->weight->shape.shape, UT_METAL);
    _mps_run(mc1, g->graph, (void*[]){g->xph, g->wph, g->goph},
             (void*[]){x->gpu_buf, l->weight->gpu_buf, grad_out->gpu_buf},
             (void*[]){g->xshape, g->wshape, g->oshape}, 3, (void*[]){g->dx_t, g->dw_t},
             (void*[]){dx->gpu_buf, dWb->gpu_buf}, (void*[]){g->xshape, g->wshape}, 2);
    dx->dirty_cpu = dWb->dirty_cpu = true;
    ut_sync_cpu(dWb);
    ut_sync_cpu(dW);
    for (int i = 0; i < dW->shape.nelem; i++) dW->data[i] += dWb->data[i];
    ut_free(dWb);
    return dx;
  }
#endif

  // go_2d: [out_c, N*Ho*Wo] — transpose + reshape grad_out [N,out_c,Ho,Wo]
  ut_tensor* go_t = ut_transpose(grad_out, 0, 1);       // [out_c, N, Ho, Wo]
  ut_reshape(go_t, 2, (int[]){l->out_c, N * Ho * Wo});  // [out_c, N*Ho*Wo]

  ut_tensor* dWb = ut_matmul_t(go_t, col, false, true);
  ut_sync_cpu(dWb);
  ut_sync_cpu(dW);
  for (int i = 0; i < dW->shape.nelem; i++) dW->data[i] += dWb->data[i];
  ut_free(dWb);

  ut_tensor w_view = *l->weight;
  w_view.shape = ut_shape_new(2, (int[]){l->out_c, l->in_c * l->kh * l->kw});
  w_view.rc = 0x7fffffff;
  ut_tensor* dcol = ut_matmul_t(&w_view, go_t, true, false);
  ut_free(go_t);

  ut_tensor* dx = ut_col2im(dcol, N, l->in_c, H, W, l->kh, l->kw, l->stride, l->pad);
  ut_free(dcol);
  return dx;
}

void ut_conv2d_cache_free(ut_conv2d_cache* c) {
  ut_free_all(c->input, c->col);
  c->input = c->col = NULL;
}

void ut_conv2d_free(ut_conv2d* l) {
  ut_free_all(l->weight, l->bias);
  l->weight = l->bias = NULL;
#ifdef __APPLE__
  _ut_conv2d_graph_free((_ut_conv2d_graph_t*)l->_mpsg);
#endif
  l->_mpsg = NULL;
}

// =========================================================
// Depthwise Conv2D
// =========================================================
ut_dwconv2d ut_dwconv2d_alloc(int c, int kh, int kw, int stride, int pad, bool bias, ut_dev dev) {
  ut_dwconv2d l = {.c = c, .kh = kh, .kw = kw, .stride = stride, .pad = pad};
  float std = sqrtf(2.f / (float)(kh * kw));
  l.weight = ut_randn(3, (int[]){c, kh, kw}, 0.f, std, dev);
  if (bias) l.bias = ut_alloc(1, (int[]){c}, dev);
  return l;
}

// x: [N,C,H,W] -> [N,C,Ho,Wo], each channel convolved with its own kh x kw
// filter (no cross-channel mixing) -- the depthwise half of a depthwise-
// separable conv; follow with a 1x1 ut_conv2d for the pointwise half.
ut_tensor* ut_dwconv2d_forward(ut_dwconv2d* l, ut_tensor* x, ut_dwconv2d_cache* cache) {
  int N = x->shape.shape[0], C = l->c, H = x->shape.shape[2], W = x->shape.shape[3];
  int Ho = (H + 2 * l->pad - l->kh) / l->stride + 1;
  int Wo = (W + 2 * l->pad - l->kw) / l->stride + 1;
  int params[10] = {N, C, H, W, l->kh, l->kw, l->stride, l->pad, Ho, Wo};

  _mtl_ctx_t* mc = (_mtl_ctx_t*)ut_metal_ctx();
  ut_tensor* out;
  if (mc && x->dev == UT_METAL) {
    ut_sync_gpu(x);
    ut_to_device(l->weight, UT_METAL);
    out = ut_alloc(4, (int[]){N, C, Ho, Wo}, UT_METAL);
    _mtl_dispatch(mc, "dwconv2d_fwd", (void*[]){x->gpu_buf, l->weight->gpu_buf, out->gpu_buf}, 3,
                  params, (int)sizeof(params), N * C * Ho * Wo);
    out->dirty_cpu = true;
  } else {
    ut_sync_cpu(x);
    ut_sync_cpu(l->weight);
    out = ut_alloc(4, (int[]){N, C, Ho, Wo}, UT_CPU);
    for (int n = 0; n < N; n++)
      for (int c = 0; c < C; c++)
        for (int oh = 0; oh < Ho; oh++)
          for (int ow = 0; ow < Wo; ow++) {
            float sum = 0;
            for (int khh = 0; khh < l->kh; khh++)
              for (int kww = 0; kww < l->kw; kww++) {
                int ih = oh * l->stride - l->pad + khh, iw = ow * l->stride - l->pad + kww;
                if (ih < 0 || ih >= H || iw < 0 || iw >= W) continue;
                sum += x->data[((n * C + c) * H + ih) * W + iw] *
                       l->weight->data[(c * l->kh + khh) * l->kw + kww];
              }
            out->data[((n * C + c) * Ho + oh) * Wo + ow] = sum;
          }
    out->dirty_gpu = true;
  }

  if (l->bias) {
    if (out->dev == UT_METAL && mc) {
      ut_sync_gpu(out);
      ut_to_device(l->bias, UT_METAL);
      int bparams[3] = {N, C, Ho * Wo};
      _mtl_dispatch(mc, "bias_add", (void*[]){out->gpu_buf, l->bias->gpu_buf}, 2, bparams,
                    (int)sizeof(bparams), N * C * Ho * Wo);
      out->dirty_cpu = true;
    } else {
      ut_sync_cpu(out);
      ut_sync_cpu(l->bias);
      for (int n = 0; n < N; n++)
        for (int c = 0; c < C; c++)
          for (int h = 0; h < Ho; h++)
            for (int w = 0; w < Wo; w++)
              out->data[((n * C + c) * Ho + h) * Wo + w] += l->bias->data[c];
    }
  }

  if (cache) cache->input = ut_retain(x);
  return out;
}

ut_tensor* ut_dwconv2d_backward(ut_dwconv2d* l, ut_dwconv2d_cache* cache, ut_tensor* grad_out,
                                ut_tensor* dW, ut_tensor* db) {
  ut_tensor* x = cache->input;
  int N = x->shape.shape[0], C = l->c, H = x->shape.shape[2], W = x->shape.shape[3];
  int Ho = (H + 2 * l->pad - l->kh) / l->stride + 1;
  int Wo = (W + 2 * l->pad - l->kw) / l->stride + 1;
  int params[10] = {N, C, H, W, l->kh, l->kw, l->stride, l->pad, Ho, Wo};

  _mtl_ctx_t* mc = (_mtl_ctx_t*)ut_metal_ctx();
  if (mc && grad_out->dev == UT_METAL) {
    ut_sync_gpu(grad_out);
    ut_to_device(x, UT_METAL);
    ut_to_device(l->weight, UT_METAL);

    int M = N * Ho * Wo;
    int tgsize = M < 64 ? 32 : (M < 256 ? 64 : (M < 512 ? 128 : 256));
    if (tgsize > 1024) tgsize = 1024;

    ut_tensor* dwp = ut_alloc(1, (int[]){C * l->kh * l->kw}, UT_METAL);
    _mtl_dispatch_rows(mc, "dwconv2d_bwd_dw", (void*[]){grad_out->gpu_buf, x->gpu_buf, dwp->gpu_buf},
                       3, params, (int)sizeof(params), C * l->kh * l->kw, tgsize);
    dwp->dirty_cpu = true;
    ut_sync_cpu(dwp);
    ut_sync_cpu(dW);
    for (int i = 0; i < C * l->kh * l->kw; i++) dW->data[i] += dwp->data[i];
    dW->dirty_gpu = true;
    ut_free(dwp);

    if (l->bias && db) {
      ut_tensor* dbp = ut_alloc(1, (int[]){C}, UT_METAL);
      _mtl_dispatch_rows(mc, "dwconv2d_bwd_db", (void*[]){grad_out->gpu_buf, dbp->gpu_buf}, 2, params,
                         (int)sizeof(params), C, tgsize);
      dbp->dirty_cpu = true;
      ut_sync_cpu(dbp);
      ut_sync_cpu(db);
      for (int c = 0; c < C; c++) db->data[c] += dbp->data[c];
      db->dirty_gpu = true;
      ut_free(dbp);
    }

    ut_tensor* dx = ut_alloc(4, (int[]){N, C, H, W}, UT_METAL);
    _mtl_dispatch(mc, "dwconv2d_bwd_dx",
                  (void*[]){grad_out->gpu_buf, l->weight->gpu_buf, dx->gpu_buf}, 3, params,
                  (int)sizeof(params), N * C * H * W);
    dx->dirty_cpu = true;
    return dx;
  }

  // CPU fallback: scatter-add dx and dW/db together in one pass
  ut_sync_cpu(grad_out);
  ut_sync_cpu(x);
  ut_sync_cpu(l->weight);
  ut_sync_cpu(dW);
  if (l->bias && db) ut_sync_cpu(db);
  ut_tensor* dx = ut_alloc(4, (int[]){N, C, H, W}, UT_CPU);
  memset(dx->data, 0, (size_t)dx->shape.nelem * sizeof(float));
  for (int n = 0; n < N; n++)
    for (int c = 0; c < C; c++)
      for (int oh = 0; oh < Ho; oh++)
        for (int ow = 0; ow < Wo; ow++) {
          float go = grad_out->data[((n * C + c) * Ho + oh) * Wo + ow];
          if (l->bias && db) db->data[c] += go;
          for (int khh = 0; khh < l->kh; khh++)
            for (int kww = 0; kww < l->kw; kww++) {
              int ih = oh * l->stride - l->pad + khh, iw = ow * l->stride - l->pad + kww;
              if (ih < 0 || ih >= H || iw < 0 || iw >= W) continue;
              dW->data[(c * l->kh + khh) * l->kw + kww] +=
                  go * x->data[((n * C + c) * H + ih) * W + iw];
              dx->data[((n * C + c) * H + ih) * W + iw] +=
                  go * l->weight->data[(c * l->kh + khh) * l->kw + kww];
            }
        }
  dW->dirty_gpu = true;
  if (l->bias && db) db->dirty_gpu = true;
  dx->dirty_gpu = true;
  return dx;
}

void ut_dwconv2d_cache_free(ut_dwconv2d_cache* c) {
  ut_free(c->input);
  c->input = NULL;
}
void ut_dwconv2d_free(ut_dwconv2d* l) {
  ut_free_all(l->weight, l->bias);
  l->weight = l->bias = NULL;
}

// =========================================================
// BatchNorm2d
// =========================================================
ut_batchnorm2d ut_batchnorm2d_alloc(int c, ut_dev dev) {
  ut_batchnorm2d l = {.c = c, .eps = 1e-5f, .momentum = 0.1f};
  l.weight = ut_alloc(1, (int[]){c}, UT_CPU);
  l.bias = ut_alloc(1, (int[]){c}, UT_CPU);
  l.running_mean = ut_alloc(1, (int[]){c}, UT_CPU);
  l.running_var = ut_alloc(1, (int[]){c}, UT_CPU);
  for (int i = 0; i < c; i++) l.weight->data[i] = l.running_var->data[i] = 1.f;
  if (dev == UT_METAL) {
    ut_to_device(l.weight, UT_METAL);
    ut_to_device(l.bias, UT_METAL);
    ut_to_device(l.running_mean, UT_METAL);
    ut_to_device(l.running_var, UT_METAL);
  }
  return l;
}

// x: [N,C,H,W] — normalises each channel over N,H,W. training=true uses batch
// stats and updates running_mean/running_var (EMA); training=false normalises
// with the running stats instead (eval/inference), matching nn.BatchNorm2d.
ut_tensor* ut_batchnorm2d_forward(ut_batchnorm2d* l, ut_tensor* x, bool training,
                                  ut_batchnorm2d_cache* cache) {
  int N = x->shape.shape[0], C = l->c, H = x->shape.shape[2], W = x->shape.shape[3];
  int HW = H * W, M = N * HW;

  // GPU fast-path
  _mtl_ctx_t* mc = (_mtl_ctx_t*)ut_metal_ctx();
  if (mc && x->dev == UT_METAL) {
    ut_sync_gpu(x);
    ut_to_device(l->weight, UT_METAL);
    ut_to_device(l->bias, UT_METAL);
    ut_to_device(l->running_mean, UT_METAL);
    ut_to_device(l->running_var, UT_METAL);
    ut_tensor* out = ut_alloc(4, x->shape.shape, UT_METAL);
    struct {
      int N, C, HW;
      float eps, mom;
    } params = {N, C, HW, l->eps, l->momentum};

    if (training) {
      ut_tensor* xnorm_t = ut_alloc(4, x->shape.shape, UT_METAL);
      ut_tensor* rstd_t = ut_alloc(1, (int[]){C}, UT_METAL);
      int tgsize = M < 64 ? 32 : (M < 256 ? 64 : (M < 512 ? 128 : 256));
      if (tgsize > 1024) tgsize = 1024;
      _mtl_dispatch_rows(
          mc, "bn2d_fwd_train",
          (void*[]){x->gpu_buf, l->weight->gpu_buf, l->bias->gpu_buf, l->running_mean->gpu_buf,
                    l->running_var->gpu_buf, out->gpu_buf, xnorm_t->gpu_buf, rstd_t->gpu_buf},
          8, &params, (int)sizeof(params), C, tgsize);
      out->dirty_cpu = true;
      l->running_mean->dirty_cpu = true;
      l->running_var->dirty_cpu = true;
      xnorm_t->dirty_cpu = true;
      rstd_t->dirty_cpu = true;
      if (cache) {
        cache->xnorm = xnorm_t;
        cache->rstd = rstd_t;
      } else {
        ut_free_all(xnorm_t, rstd_t);
      }
    } else {
      _mtl_dispatch(mc, "bn2d_fwd_eval",
                    (void*[]){x->gpu_buf, l->weight->gpu_buf, l->bias->gpu_buf,
                              l->running_mean->gpu_buf, l->running_var->gpu_buf, out->gpu_buf},
                    6, &params, (int)sizeof(params), N * C * HW);
      out->dirty_cpu = true;
    }
    return out;
  }

  // CPU fallback
  ut_sync_cpu(x);
  ut_sync_cpu(l->weight);
  ut_sync_cpu(l->bias);
  ut_sync_cpu(l->running_mean);
  ut_sync_cpu(l->running_var);

  ut_tensor* out = ut_alloc(4, x->shape.shape, x->dev);
  ut_tensor* xnorm_t = cache ? ut_alloc(4, x->shape.shape, UT_CPU) : NULL;
  ut_tensor* rstd_t = cache ? ut_alloc(1, (int[]){C}, UT_CPU) : NULL;

  for (int c = 0; c < C; c++) {
    float mu, rs;
    if (training) {
      float sum = 0;
      for (int n = 0; n < N; n++)
        for (int hw = 0; hw < HW; hw++) sum += x->data[(n * C + c) * HW + hw];
      mu = sum / (float)M;
      float var = 0;
      for (int n = 0; n < N; n++)
        for (int hw = 0; hw < HW; hw++) {
          float diff = x->data[(n * C + c) * HW + hw] - mu;
          var += diff * diff;
        }
      var /= (float)M;
      rs = 1.f / sqrtf(var + l->eps);
      float var_unbiased = M > 1 ? var * (float)M / (float)(M - 1) : var;
      l->running_mean->data[c] = (1.f - l->momentum) * l->running_mean->data[c] + l->momentum * mu;
      l->running_var->data[c] =
          (1.f - l->momentum) * l->running_var->data[c] + l->momentum * var_unbiased;
    } else {
      mu = l->running_mean->data[c];
      rs = 1.f / sqrtf(l->running_var->data[c] + l->eps);
    }
    for (int n = 0; n < N; n++)
      for (int hw = 0; hw < HW; hw++) {
        int idx = (n * C + c) * HW + hw;
        float xn = (x->data[idx] - mu) * rs;
        out->data[idx] = l->weight->data[c] * xn + l->bias->data[c];
        if (cache) xnorm_t->data[idx] = xn;
      }
    if (cache) rstd_t->data[c] = rs;
  }
  out->dirty_gpu = true;
  if (training) {
    l->running_mean->dirty_gpu = true;
    l->running_var->dirty_gpu = true;
  }
  if (cache) {
    cache->xnorm = xnorm_t;
    cache->rstd = rstd_t;
  }
  return out;
}

ut_tensor* ut_batchnorm2d_backward(ut_batchnorm2d* l, ut_batchnorm2d_cache* cache,
                                   ut_tensor* grad_out, ut_tensor* dW, ut_tensor* db) {
  int N = grad_out->shape.shape[0], C = l->c, H = grad_out->shape.shape[2],
      W = grad_out->shape.shape[3];
  int HW = H * W, M = N * HW;

  // GPU fast-path
  _mtl_ctx_t* mc = (_mtl_ctx_t*)ut_metal_ctx();
  if (mc && grad_out->dev == UT_METAL) {
    ut_sync_gpu(grad_out);
    ut_to_device(cache->xnorm, UT_METAL);
    ut_to_device(cache->rstd, UT_METAL);
    ut_to_device(l->weight, UT_METAL);
    ut_tensor* dx = ut_alloc(4, grad_out->shape.shape, UT_METAL);
    ut_tensor* dwp = ut_alloc(1, (int[]){C}, UT_METAL);
    ut_tensor* dbp = ut_alloc(1, (int[]){C}, UT_METAL);
    struct {
      int N, C, HW;
      float eps, mom;
    } params = {N, C, HW, l->eps, l->momentum};
    int tgsize = M < 64 ? 32 : (M < 256 ? 64 : (M < 512 ? 128 : 256));
    if (tgsize > 1024) tgsize = 1024;
    _mtl_dispatch_rows(mc, "bn2d_bwd",
                       (void*[]){grad_out->gpu_buf, cache->xnorm->gpu_buf, cache->rstd->gpu_buf,
                                 l->weight->gpu_buf, dx->gpu_buf, dwp->gpu_buf, dbp->gpu_buf},
                       7, &params, (int)sizeof(params), C, tgsize);
    dx->dirty_cpu = true;
    dwp->dirty_cpu = true;
    dbp->dirty_cpu = true;

    ut_sync_cpu(dwp);
    ut_sync_cpu(dbp);
    ut_sync_cpu(dW);
    ut_sync_cpu(db);
    for (int c = 0; c < C; c++) {
      dW->data[c] += dwp->data[c];
      db->data[c] += dbp->data[c];
    }
    dW->dirty_gpu = true;
    db->dirty_gpu = true;
    ut_free_all(dwp, dbp);
    return dx;
  }

  // CPU fallback (dW/db and dx together, same as before)
  ut_sync_cpu(grad_out);
  ut_sync_cpu(cache->xnorm);
  ut_sync_cpu(cache->rstd);
  ut_sync_cpu(l->weight);
  ut_sync_cpu(dW);
  ut_sync_cpu(db);
  ut_tensor* dx = ut_alloc(4, grad_out->shape.shape, UT_CPU);
  for (int c = 0; c < C; c++) {
    float sum_go = 0, sum_go_xn = 0;
    for (int n = 0; n < N; n++)
      for (int hw = 0; hw < HW; hw++) {
        int idx = (n * C + c) * HW + hw;
        sum_go += grad_out->data[idx];
        sum_go_xn += grad_out->data[idx] * cache->xnorm->data[idx];
      }
    dW->data[c] += sum_go_xn;
    db->data[c] += sum_go;
    float rs = cache->rstd->data[c], wgt = l->weight->data[c];
    for (int n = 0; n < N; n++)
      for (int hw = 0; hw < HW; hw++) {
        int idx = (n * C + c) * HW + hw;
        float go = grad_out->data[idx], xn = cache->xnorm->data[idx];
        dx->data[idx] = rs * wgt * (go - (sum_go + xn * sum_go_xn) / (float)M);
      }
  }
  dW->dirty_gpu = true;
  db->dirty_gpu = true;
  dx->dirty_gpu = true;
  return dx;
}

void ut_batchnorm2d_cache_free(ut_batchnorm2d_cache* c) {
  ut_free_all(c->xnorm, c->rstd);
  c->xnorm = c->rstd = NULL;
}
void ut_batchnorm2d_free(ut_batchnorm2d* l) {
  ut_free_all(l->weight, l->bias, l->running_mean, l->running_var);
  l->weight = l->bias = l->running_mean = l->running_var = NULL;
}

// =========================================================
// Pooling
// =========================================================

// x: [N,C,H,W] -> [N,C], averaging each channel over H,W. No cache: backward
// only needs H,W, which the caller already has from x's own shape.
ut_tensor* ut_global_avgpool2d(ut_tensor* x) {
  int N = x->shape.shape[0], C = x->shape.shape[1], HW = x->shape.shape[2] * x->shape.shape[3];

  _mtl_ctx_t* mc = (_mtl_ctx_t*)ut_metal_ctx();
  if (mc && x->dev == UT_METAL) {
    ut_sync_gpu(x);
    ut_tensor* out = ut_alloc(2, (int[]){N, C}, UT_METAL);
    int tgsize = HW < 64 ? 32 : (HW < 256 ? 64 : (HW < 512 ? 128 : 256));
    if (tgsize > 1024) tgsize = 1024;
    _mtl_dispatch_rows(mc, "gap_fwd", (void*[]){x->gpu_buf, out->gpu_buf}, 2, &HW, sizeof(int),
                       N * C, tgsize);
    out->dirty_cpu = true;
    return out;
  }

  ut_sync_cpu(x);
  ut_tensor* out = ut_alloc(2, (int[]){N, C}, x->dev);
  for (int n = 0; n < N; n++)
    for (int c = 0; c < C; c++) {
      float sum = 0;
      for (int i = 0; i < HW; i++) sum += x->data[(n * C + c) * HW + i];
      out->data[n * C + c] = sum / (float)HW;
    }
  out->dirty_gpu = true;
  return out;
}

ut_tensor* ut_global_avgpool2d_backward(ut_tensor* grad_out, int H, int W) {
  int N = grad_out->shape.shape[0], C = grad_out->shape.shape[1], HW = H * W;

  _mtl_ctx_t* mc = (_mtl_ctx_t*)ut_metal_ctx();
  if (mc && grad_out->dev == UT_METAL) {
    ut_sync_gpu(grad_out);
    ut_tensor* dx = ut_alloc(4, (int[]){N, C, H, W}, UT_METAL);
    struct {
      int HW, tot;
    } params = {HW, N * C * HW};
    _mtl_dispatch(mc, "gap_bwd", (void*[]){grad_out->gpu_buf, dx->gpu_buf}, 2, &params,
                  (int)sizeof(params), params.tot);
    dx->dirty_cpu = true;
    return dx;
  }

  ut_sync_cpu(grad_out);
  ut_tensor* dx = ut_alloc(4, (int[]){N, C, H, W}, grad_out->dev);
  for (int n = 0; n < N; n++)
    for (int c = 0; c < C; c++) {
      float g = grad_out->data[n * C + c] / (float)HW;
      for (int i = 0; i < HW; i++) dx->data[(n * C + c) * HW + i] = g;
    }
  dx->dirty_gpu = true;
  return dx;
}

// x: [N,C,H,W] -> [N,C,Ho,Wo], max over each kh x kw window per channel
ut_tensor* ut_maxpool2d(ut_tensor* x, int kh, int kw, int stride, int pad,
                        ut_maxpool2d_cache* cache) {
  int N = x->shape.shape[0], C = x->shape.shape[1], H = x->shape.shape[2], W = x->shape.shape[3];
  int Ho = (H + 2 * pad - kh) / stride + 1, Wo = (W + 2 * pad - kw) / stride + 1;
  ut_sync_cpu(x);
  ut_tensor* out = ut_alloc(4, (int[]){N, C, Ho, Wo}, x->dev);
  int* argmax = cache ? malloc((size_t)N * C * Ho * Wo * sizeof(int)) : NULL;
  for (int n = 0; n < N; n++)
    for (int c = 0; c < C; c++)
      for (int oh = 0; oh < Ho; oh++)
        for (int ow = 0; ow < Wo; ow++) {
          float best = -FLT_MAX;
          int best_idx = -1;
          for (int hh = 0; hh < kh; hh++)
            for (int ww = 0; ww < kw; ww++) {
              int ih = oh * stride - pad + hh, iw = ow * stride - pad + ww;
              if (ih < 0 || ih >= H || iw < 0 || iw >= W) continue;
              int idx = ((n * C + c) * H + ih) * W + iw;
              if (x->data[idx] > best) best = x->data[idx], best_idx = idx;
            }
          int oidx = ((n * C + c) * Ho + oh) * Wo + ow;
          out->data[oidx] = best;
          if (cache) argmax[oidx] = best_idx;
        }
  out->dirty_gpu = true;
  if (cache) {
    cache->argmax = argmax;
    cache->n = N, cache->c = C, cache->h = H, cache->w = W;
  }
  return out;
}

ut_tensor* ut_maxpool2d_backward(ut_maxpool2d_cache* cache, ut_tensor* grad_out) {
  ut_sync_cpu(grad_out);
  ut_tensor* dx = ut_alloc(4, (int[]){cache->n, cache->c, cache->h, cache->w}, grad_out->dev);
  memset(dx->data, 0, (size_t)dx->shape.nelem * sizeof(float));
  for (int i = 0; i < grad_out->shape.nelem; i++) dx->data[cache->argmax[i]] += grad_out->data[i];
  dx->dirty_gpu = true;
  return dx;
}

void ut_maxpool2d_cache_free(ut_maxpool2d_cache* c) {
  free(c->argmax);
  c->argmax = NULL;
}

// x: [N,C,H,W] -> [N,C,Ho,Wo], mean over each kh x kw window per channel
// (padding counts as zero, matching PyTorch's count_include_pad=True default)
ut_tensor* ut_avgpool2d(ut_tensor* x, int kh, int kw, int stride, int pad) {
  int N = x->shape.shape[0], C = x->shape.shape[1], H = x->shape.shape[2], W = x->shape.shape[3];
  int Ho = (H + 2 * pad - kh) / stride + 1, Wo = (W + 2 * pad - kw) / stride + 1;
  ut_sync_cpu(x);
  ut_tensor* out = ut_alloc(4, (int[]){N, C, Ho, Wo}, x->dev);
  for (int n = 0; n < N; n++)
    for (int c = 0; c < C; c++)
      for (int oh = 0; oh < Ho; oh++)
        for (int ow = 0; ow < Wo; ow++) {
          float sum = 0;
          for (int hh = 0; hh < kh; hh++)
            for (int ww = 0; ww < kw; ww++) {
              int ih = oh * stride - pad + hh, iw = ow * stride - pad + ww;
              if (ih >= 0 && ih < H && iw >= 0 && iw < W)
                sum += x->data[((n * C + c) * H + ih) * W + iw];
            }
          out->data[((n * C + c) * Ho + oh) * Wo + ow] = sum / (float)(kh * kw);
        }
  out->dirty_gpu = true;
  return out;
}

ut_tensor* ut_avgpool2d_backward(ut_tensor* grad_out, int N, int C, int H, int W, int kh, int kw,
                                 int stride, int pad) {
  int Ho = (H + 2 * pad - kh) / stride + 1, Wo = (W + 2 * pad - kw) / stride + 1;
  ut_sync_cpu(grad_out);
  ut_tensor* dx = ut_alloc(4, (int[]){N, C, H, W}, grad_out->dev);
  memset(dx->data, 0, (size_t)dx->shape.nelem * sizeof(float));
  float scale = 1.f / (float)(kh * kw);
  for (int n = 0; n < N; n++)
    for (int c = 0; c < C; c++)
      for (int oh = 0; oh < Ho; oh++)
        for (int ow = 0; ow < Wo; ow++) {
          float g = grad_out->data[((n * C + c) * Ho + oh) * Wo + ow] * scale;
          for (int hh = 0; hh < kh; hh++)
            for (int ww = 0; ww < kw; ww++) {
              int ih = oh * stride - pad + hh, iw = ow * stride - pad + ww;
              if (ih >= 0 && ih < H && iw >= 0 && iw < W)
                dx->data[((n * C + c) * H + ih) * W + iw] += g;
            }
        }
  dx->dirty_gpu = true;
  return dx;
}

// =========================================================
// Softmax
// =========================================================
ut_tensor* ut_softmax(ut_tensor* t, int dim) {
  int nd = t->shape.ndim, k = t->shape.shape[dim];
  int outer = 1;
  for (int i = 0; i < dim; i++) outer *= t->shape.shape[i];
  int inner = 1;
  for (int i = dim + 1; i < nd; i++) inner *= t->shape.shape[i];

  // GPU fast-path: only when dim is last (inner==1)
  _mtl_ctx_t* _mc_sm = (_mtl_ctx_t*)ut_metal_ctx();
  if (_mc_sm && inner == 1) {
    ut_to_device(t, UT_METAL);
    ut_tensor* out = ut_alloc(nd, t->shape.shape, UT_METAL);
    int tgsize = k < 64 ? 32 : (k < 256 ? 64 : (k < 512 ? 128 : 256));
    if (tgsize > 1024) tgsize = 1024;
    int p2[2] = {outer, k};
    _mtl_dispatch_rows(_mc_sm, "row_softmax", (void*[]){t->gpu_buf, out->gpu_buf}, 2, p2,
                       (int)sizeof(p2), outer, tgsize);
    out->dirty_cpu = true;
    return out;
  }

  // CPU fallback (also handles non-last-dim softmax)
  ut_sync_cpu(t);
  ut_tensor* out = ut_alloc(nd, t->shape.shape, UT_CPU);
  for (int o = 0; o < outer; o++)
    for (int in = 0; in < inner; in++) {
      float mx = -FLT_MAX;
      for (int d = 0; d < k; d++) {
        float v = t->data[o * k * inner + d * inner + in];
        if (v > mx) mx = v;
      }
      float sum = 0;
      for (int d = 0; d < k; d++) {
        float e = expf(t->data[o * k * inner + d * inner + in] - mx);
        out->data[o * k * inner + d * inner + in] = e;
        sum += e;
      }
      for (int d = 0; d < k; d++) out->data[o * k * inner + d * inner + in] /= sum;
    }
  return out;
}

// =========================================================
// Loss
// =========================================================
float ut_cross_entropy(ut_tensor* logits, const int* labels, ut_tensor* grad_in) {
  ut_sync_cpu(logits);
  int B = logits->shape.shape[0], C = logits->shape.shape[1];
  if (grad_in) { ut_sync_cpu(grad_in); }
  float loss = 0;
  for (int b = 0; b < B; b++) {
    const float* row = logits->data + b * C;
    float mx = row[0];
    for (int c = 1; c < C; c++)
      if (row[c] > mx) mx = row[c];
    float sum = 0;
    for (int c = 0; c < C; c++) sum += expf(row[c] - mx);
    float log_sum = logf(sum) + mx;
    loss += log_sum - row[labels[b]];
    if (grad_in) {
      float* g = grad_in->data + b * C;
      for (int c = 0; c < C; c++) g[c] = expf(row[c] - log_sum) / (float)B;
      g[labels[b]] -= 1.f / (float)B;
    }
  }
  if (grad_in) grad_in->dirty_gpu = true;
  return loss / (float)B;
}

float ut_mse(ut_tensor* pred, ut_tensor* target, ut_tensor* grad_in) {
  ut_sync_cpu(pred);
  ut_sync_cpu(target);
  int n = pred->shape.nelem;
  if (grad_in) { ut_sync_cpu(grad_in); }
  float loss = 0;
  for (int i = 0; i < n; i++) {
    float d = pred->data[i] - target->data[i];
    loss += d * d;
    if (grad_in) grad_in->data[i] = 2.f * d / (float)n;
  }
  if (grad_in) grad_in->dirty_gpu = true;
  return loss / (float)n;
}

// =========================================================
// Optimisers
// =========================================================
ut_sgd ut_sgd_alloc(ut_tensor** params, int n, float lr, float mom) {
  ut_sgd o = {0};
  o.nparams = n;
  o.lr = lr;
  o.momentum = mom;
  o.params = malloc((size_t)n * sizeof(ut_tensor*));
  o.grads = malloc((size_t)n * sizeof(ut_tensor*));
  memcpy(o.params, params, (size_t)n * sizeof(ut_tensor*));
  for (int i = 0; i < n; i++)
    o.grads[i] = ut_alloc(params[i]->shape.ndim, params[i]->shape.shape, UT_CPU);
  if (mom > 0) {
    o.velocity = malloc((size_t)n * sizeof(ut_tensor*));
    for (int i = 0; i < n; i++)
      o.velocity[i] = ut_alloc(params[i]->shape.ndim, params[i]->shape.shape, UT_CPU);
  }
  return o;
}

void ut_sgd_zero(ut_sgd* o) {
  for (int i = 0; i < o->nparams; i++)
    memset(o->grads[i]->data, 0, (size_t)o->grads[i]->shape.nelem * sizeof(float));
}

void ut_sgd_step(ut_sgd* o, float clip) {
  for (int i = 0; i < o->nparams; i++) {
    ut_tensor *p = o->params[i], *g = o->grads[i];
    ut_sync_cpu(p);
    for (int j = 0; j < p->shape.nelem; j++) {
      float gr = g->data[j];
      if (gr > clip) gr = clip;
      if (gr < -clip) gr = -clip;
      if (o->momentum > 0) {
        o->velocity[i]->data[j] = o->momentum * o->velocity[i]->data[j] - o->lr * gr;
        p->data[j] += o->velocity[i]->data[j];
      } else {
        p->data[j] -= o->lr * gr;
      }
    }
    p->dirty_gpu = true;
    memset(g->data, 0, (size_t)g->shape.nelem * sizeof(float));
  }
}

void ut_sgd_free(ut_sgd* o) {
  for (int i = 0; i < o->nparams; i++) ut_free(o->grads[i]);
  if (o->velocity) {
    for (int i = 0; i < o->nparams; i++) ut_free(o->velocity[i]);
    free(o->velocity);
  }
  free(o->params);
  free(o->grads);
}

ut_adam ut_adam_alloc(ut_tensor** params, int n, float lr, float beta1, float beta2, float eps,
                      float wd) {
  ut_adam o = {.nparams = n, .lr = lr, .wd = wd};
  o.beta1 = beta1 > 0 ? beta1 : 0.9f;
  o.beta2 = beta2 > 0 ? beta2 : 0.999f;
  o.eps = eps > 0 ? eps : 1e-8f;
  o.params = malloc((size_t)n * sizeof(ut_tensor*));
  o.grads = malloc((size_t)n * sizeof(ut_tensor*));
  o.m = malloc((size_t)n * sizeof(ut_tensor*));
  o.v = malloc((size_t)n * sizeof(ut_tensor*));
  memcpy(o.params, params, (size_t)n * sizeof(ut_tensor*));
  for (int i = 0; i < n; i++) {
    o.grads[i] = ut_alloc(params[i]->shape.ndim, params[i]->shape.shape, UT_CPU);
    o.m[i] = ut_alloc(params[i]->shape.ndim, params[i]->shape.shape, UT_CPU);
    o.v[i] = ut_alloc(params[i]->shape.ndim, params[i]->shape.shape, UT_CPU);
  }
  return o;
}

void ut_adam_step(ut_adam* o, float clip) {
  o->step++;
  float b1t = 1.f - powf(o->beta1, (float)o->step);
  float b2t_sqrt = sqrtf(1.f - powf(o->beta2, (float)o->step));
  float step_size = o->lr / b1t;
  for (int i = 0; i < o->nparams; i++) {
    ut_tensor *p = o->params[i], *g = o->grads[i];
    ut_sync_cpu(p);
    for (int j = 0; j < p->shape.nelem; j++) {
      float gr = g->data[j];
      if (clip > 0) {
        if (gr > clip) gr = clip;
        if (gr < -clip) gr = -clip;
      }
      o->m[i]->data[j] = o->beta1 * o->m[i]->data[j] + (1.f - o->beta1) * gr;
      o->v[i]->data[j] = o->beta2 * o->v[i]->data[j] + (1.f - o->beta2) * gr * gr;
      float denom = sqrtf(o->v[i]->data[j]) / b2t_sqrt + o->eps;
      float update = step_size * o->m[i]->data[j] / denom;
      if (o->wd > 0) update += o->lr * o->wd * p->data[j];
      p->data[j] -= update;
    }
    p->dirty_gpu = true;
    memset(g->data, 0, (size_t)g->shape.nelem * sizeof(float));
  }
}

void ut_adam_free(ut_adam* o) {
  for (int i = 0; i < o->nparams; i++) ut_free_all(o->grads[i], o->m[i], o->v[i]);
  free(o->params);
  free(o->grads);
  free(o->m);
  free(o->v);
}

#endif  // UTENSIL_H
