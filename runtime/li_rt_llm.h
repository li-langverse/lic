#ifndef LI_RT_LLM_H
#define LI_RT_LLM_H

#include <stdint.h>

int32_t li_rt_llm_path_format_tag(const char* path);
int32_t li_rt_llm_weights_file_size(const char* path);
int32_t li_rt_llm_weights_file_byte_at(const char* path, int32_t off);

/* Returns 1 on success; sets g_st. ok==2 means legacy scaffold (no file). */
int32_t li_rt_llm_safetensors_resolve_path(const char* path);
int32_t li_rt_llm_safetensors_resolve_cached(void);
int32_t li_rt_llm_safetensors_probe_cached(void);
int32_t li_rt_llm_safetensors_probe_path(const char* path);
int32_t li_rt_llm_gguf_probe_cached(void);
int32_t li_rt_llm_last_safetensors_header_len(void);
int32_t li_rt_llm_last_safetensors_tensor_count(void);
int32_t li_rt_llm_last_safetensors_data_offset(void);
int32_t li_rt_llm_last_safetensors_first_dtype(void);
int32_t li_rt_llm_last_safetensors_first_shape0(void);
int32_t li_rt_llm_last_safetensors_first_shape1(void);
int32_t li_rt_llm_last_safetensors_is_scaffold(void);

int32_t li_rt_llm_gguf_probe_path(const char* path);
int32_t li_rt_llm_last_gguf_version(void);
int32_t li_rt_llm_last_gguf_tensor_count(void);

int32_t li_rt_llm_safetensors_tensor_byte_at(int32_t tensor_index, int32_t byte_off);

const char* li_rt_llm_import_model_path_default(void);
const char* li_rt_llm_legacy_safetensors_fixture_path(void);
const char* li_rt_llm_ph_ml_gguf_fixture_path(void);

#endif
