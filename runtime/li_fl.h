#pragma once

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/** Device kind tags for hetero federated ranks (WP-PAR-63). */
typedef enum {
  LI_FL_DEVICE_CPU = 0,
  LI_FL_DEVICE_GPU = 1,
  LI_FL_DEVICE_TPU = 2,
  LI_FL_DEVICE_ASIC = 3
} li_fl_device_kind;

/** int8-compressed gradient/halo payload (WP-PAR-62). */
typedef struct {
  uint8_t data[64];
  int count;
  float scale;
  float offset;
} li_fl_compressed_payload;

typedef void (*li_fl_compute_fn)(void* ctx);

/** Active rank mask for partial participation (WP-PAR-60). Bit i = rank i. */
void li_fl_set_active_mask(uint64_t mask);
uint64_t li_fl_active_mask(void);
int li_fl_is_active(int rank);
int li_fl_active_count(uint64_t mask);

/** Hetero rank device tag (WP-PAR-63). */
void li_fl_set_device_kind(li_fl_device_kind kind);
li_fl_device_kind li_fl_get_device_kind(void);
void li_fl_gather_device_kinds(li_fl_device_kind* out, int world);

/** Compress/decompress f32 halo payloads (WP-PAR-62). */
void li_fl_compress_f32(const float* src, int n, li_fl_compressed_payload* out);
void li_fl_decompress_f32(const li_fl_compressed_payload* in, float* dst);

/** Federated average over active ranks only (WP-PAR-60). */
double li_fl_fedavg_masked_f64(double local, uint64_t active_mask);

/** Federated average with straggler timeout in ms (WP-PAR-61). */
double li_fl_fedavg_straggler_f64(double local, uint64_t active_mask, int timeout_ms,
                                  uint64_t* timed_out_mask);

/** Federated average with local compute overlap (WP-PAR-64). */
double li_fl_fedavg_overlap_f64(double local, uint64_t active_mask, li_fl_compute_fn compute,
                                void* ctx, int* overlap_ran);

/** Remove failed ranks from active set (WP-PAR-65). */
uint64_t li_fl_shrink_mask(uint64_t active_mask, uint64_t failed_mask);

/** Initialize active mask + device kind from LI_FL_* env. */
void li_fl_init_from_env(void);

#ifdef __cplusplus
}
#endif
