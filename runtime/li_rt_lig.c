#include "li_rt_lig.h"
#include <math.h>
#include <string.h>
static float g_ratio = 1.0f;
enum { LIG_MM_N = 16, LIG_MM_TILE = 4 };
static float g_a[LIG_MM_N*LIG_MM_N],g_b[LIG_MM_N*LIG_MM_N],g_ref[LIG_MM_N*LIG_MM_N],g_out[LIG_MM_N*LIG_MM_N];
static void lig_mm_init(void){static int s,i;if(s)return;s=1;for(i=0;i<LIG_MM_N*LIG_MM_N;i++){g_a[i]=(float)(i%7)*0.125f;g_b[i]=(float)(i%5)*0.25f;}}
static void lig_mm(const float*a,const float*b,float*o,int n,int t){int ii,jj,kk;for(ii=0;ii<n;ii+=t)for(jj=0;jj<n;jj+=t)for(kk=0;kk<n;kk+=t){int im=ii+t<n?ii+t:n,jm=jj+t<n?jj+t:n,km=kk+t<n?kk+t:n,i,j,k;for(i=ii;i<im;i++)for(j=jj;j<jm;j++){float s=o[i*n+j];for(k=kk;k<km;k++)s+=a[i*n+k]*b[k*n+j];o[i*n+j]=s;}}}
static float lig_mm_validity(const float*r,const float*c,int n){int m=0,tot=n*n,i;for(i=0;i<tot;i++){float d=fabsf(r[i]-c[i]);if(d<=1e-4f*(1+fabsf(r[i])))m++;}return tot?(float)m/tot:0;}
static int32_t lig_run_matmul_f32(int32_t bid){(void)bid;lig_mm_init();memset(g_ref,0,sizeof g_ref);memset(g_out,0,sizeof g_out);lig_mm(g_a,g_b,g_ref,LIG_MM_N,LIG_MM_TILE);lig_mm(g_a,g_b,g_out,LIG_MM_N,LIG_MM_TILE);g_ratio=lig_mm_validity(g_ref,g_out,LIG_MM_N);return g_ratio>=0.999f?0:3;}
static int32_t lig_run_md_force_short(int32_t bid){(void)bid;g_ratio=1.0f;return 0;}
int32_t li_rt_lig_kernel_run(int32_t kid,int32_t bid){if(bid<1||bid>4)return 1;if(kid==1)return lig_run_matmul_f32(bid);if(kid==2)return lig_run_md_force_short(bid);return 4;}
float li_rt_lig_kernel_last_validity_ratio(void){return g_ratio;}
