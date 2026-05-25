#pragma once

#ifdef __cplusplus
extern "C" {
#endif

void li_pde_cfl_timestep_kernel(void);
double li_pde_cfl_timestep_checksum(void);

#ifdef __cplusplus
}
#endif
