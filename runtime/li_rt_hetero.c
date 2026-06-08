#include "li_rt_hetero.h"

#include "li_rt.h"

#include <stdio.h>
#include <string.h>

int32_t li_rt_hetero_probe_gpu(void) {
  const int32_t kind = li_rt_lig_device_kind();
  if (kind < 1 || kind > 4) {
    return 1;
  }
  if (li_rt_lig_backend_available(kind) != 1) {
    return 1;
  }
  const int32_t auto_id = li_rt_lig_backend_select_auto();
  if (li_rt_lig_backend_available(auto_id) != 1) {
    return 1;
  }
  const char* cap = li_rt_lig_capability_json();
  if (cap == NULL || cap[0] == '\0') {
    return 1;
  }
  return 0;
}

int32_t li_rt_hetero_probe_tpu(void) {
  const int32_t kind = li_rt_litpu_device_kind();
  if (kind < 1 || kind > 3) {
    return 1;
  }
  if (li_rt_litpu_backend_available(kind) != 1) {
    return 1;
  }
  const int32_t auto_id = li_rt_litpu_backend_select_auto();
  if (li_rt_litpu_backend_available(auto_id) != 1) {
    return 1;
  }
  const char* cap = li_rt_litpu_capability_json();
  if (cap == NULL || cap[0] == '\0') {
    return 1;
  }
  return 0;
}

int32_t li_rt_hetero_probe_asic(void) {
  const int32_t kind = li_rt_liasic_device_kind();
  if (kind < 1 || kind > 3) {
    return 1;
  }
  if (li_rt_liasic_backend_available(kind) != 1) {
    return 1;
  }
  const int32_t auto_id = li_rt_liasic_backend_select_auto();
  if (li_rt_liasic_backend_available(auto_id) != 1) {
    return 1;
  }
  const char* cap = li_rt_liasic_capability_json();
  if (cap == NULL || cap[0] == '\0') {
    return 1;
  }
  return 0;
}

int32_t li_rt_hetero_available_mask(void) {
  int32_t mask = 1;
  if (li_rt_hetero_probe_gpu() == 0) {
    mask |= 2;
  }
  if (li_rt_hetero_probe_tpu() == 0) {
    mask |= 4;
  }
  if (li_rt_hetero_probe_asic() == 0) {
    mask |= 8;
  }
  return mask;
}

int32_t li_rt_hetero_probe_pipeline(void) {
  if (li_rt_hetero_probe_gpu() != 0) {
    return 1;
  }
  if (li_rt_hetero_probe_tpu() != 0) {
    return 1;
  }
  if (li_rt_hetero_probe_asic() != 0) {
    return 1;
  }
  if (li_rt_hetero_available_mask() < 15) {
    return 1;
  }
  return 0;
}
