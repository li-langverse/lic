#ifndef LI_RT_LKIR_PARSE_H
#define LI_RT_LKIR_PARSE_H

#include <stdint.h>

/** 1 = matmul module, 2 = mlp_forward module */
#define LI_LKIR_MODULE_MATMUL 1
#define LI_LKIR_MODULE_MLP_FORWARD 2

/** 1 = valid, 0 = schema mismatch, -1 = I/O error */
int32_t li_rt_lkir_validate_file(const char* path, int32_t module_kind);

/** Non-comment line count (for diagnostics). */
int32_t li_rt_lkir_count_op_lines(const char* path);

#endif
