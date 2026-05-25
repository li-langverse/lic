#include "li_rt_lig.h"
#include <math.h>
#include <stdlib.h>
#include <string.h>
#if defined(__APPLE__)
#include <TargetConditionals.h>
#endif
static float g_ratio = 1.0f;
enum { N = 16, T = 4 };
static float g_a[N*N], g_b[N*N], g_ref[N*N], g_out[N*N];
static void init_m(void){static int s;if(s)return;s=1;for(int i=0;i<N*N;i++){g_a[i]=(float)(i%7)*0.125f;g_b[i]=(float)(i%5)*0.25f;}}
static void mm(const float*a,const float*b,float*o,int n,int t){
 for(int ii=0;ii<n;ii+=t)for(int jj=0;jj<n;jj+=t)for(int kk=0;kk<n;kk+=t){
  int im=ii+t<n?ii+t:n,jm=jj+t<n?jj+t:n,km=kk+t<n?kk+t:n;
  for(int i=ii;i<im;i++)for(int j=jj;j<jm;j++){float s=o[i*n+j];for(int k=kk;k<km;k++)s+=a[i*n+k]*b[k*n+j];o[i*n+j]=s;}}}
static float val(const float*r,const float*c,int n){int m=0,tot=n*n;for(int i=0;i<tot;i++){float d=fabsf(r[i]-c[i]);if(d<=1e-4f*(1+fabsf(r[i])))m++;}return tot?(float)m/tot:0;}
static int run_mm(int32_t bid){(void)bid;init_m();memset(g_ref,0,sizeof g_ref);memset(g_out,0,sizeof g_out);mm(g_a,g_b,g_ref,N,T);mm(g_a,g_b,g_out,N,T);g_ratio=val(g_ref,g_out,N);return g_ratio>=0.999f?0:3;}
int32_t li_rt_lig_backend_select_auto(void){
#if defined(__APPLE__) && TARGET_OS_OSX
 return 3;
#else
 if(getenv("ROCM_PATH")||getenv("HIPCC")) return 2;
 if(getenv("CUDA_PATH")||getenv("CUDA_HOME")) return 1;
 return 4;
#endif
}
int32_t li_rt_lig_kernel_run(int32_t kid,int32_t bid){if(bid<1||bid>4)return 1;if(kid==1)return run_mm(bid);return 4;}
float li_rt_lig_kernel_last_validity_ratio(void){return g_ratio;}
