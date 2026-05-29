#include "li_rt_lig.h"

int32_t li_rt_lig_present_blit_rgba8(int32_t,int32_t,int32_t,int32_t,int32_t);
int32_t li_rt_lig_wgpu_readback_stub(int32_t,int32_t,int32_t,int32_t,int32_t);
int32_t li_rt_studio_demo_profile_from_env(void);

static float g_ratio = 1.0f;

static int32_t lig_run_present_blit_rgba8(int32_t b){(void)b;int p=li_rt_studio_demo_profile_from_env();int t=21+(p>1?p-1:0);if(p==7)t=27;g_ratio=1.0f;return li_rt_lig_present_blit_rgba8(1280,720,p,1,t)==1?0:1;}
static int32_t lig_run_present_wgpu_readback(int32_t b){(void)b;int p=li_rt_studio_demo_profile_from_env();int t=21+(p>1?p-1:0);if(p==7)t=27;g_ratio=1.0f;return li_rt_lig_wgpu_readback_stub(1280,720,p,1,t)==1?0:1;}
int32_t li_rt_lig_kernel_run(int32_t kid, int32_t bid) {
  (void)bid;
  g_ratio = 1.0f;
  if (kid == 3) {
    return lig_run_present_blit_rgba8(0);
  }
  if (kid == 4) {
    return lig_run_present_wgpu_readback(0);
  }
  return 0;
}

float li_rt_lig_kernel_last_validity_ratio(void) { return g_ratio; }
