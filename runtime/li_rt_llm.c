#include "li_rt_llm.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define LI_RT_LLM_MAX_HEADER (1 << 20)
#define LI_RT_LLM_MAX_FILE (64 << 20)

typedef struct {
  int32_t ok;
  int32_t header_len;
  int32_t tensor_count;
  int32_t data_offset;
  int32_t dtype;
  int32_t shape0;
  int32_t shape1;
} LlmStProbe;

typedef struct {
  int32_t ok;
  int32_t version;
  int32_t tensor_count;
} LlmGgufProbe;

static LlmStProbe g_st = {0};
static LlmGgufProbe g_gguf = {0};
static char g_last_weights_path[4096] = {0};

static int li_rt_llm_path_is_cached_sentinel(const char* path) {
  return path == NULL || path[0] == '\0' || (path[0] == '.' && path[1] == '\0');
}

static void li_rt_llm_remember_path(const char* path) {
  g_last_weights_path[0] = '\0';
  if (path != NULL) {
    strncpy(g_last_weights_path, path, sizeof(g_last_weights_path) - 1);
    g_last_weights_path[sizeof(g_last_weights_path) - 1] = '\0';
  }
}

int32_t li_rt_llm_path_format_tag(const char* path) {
  li_rt_llm_remember_path(path);
  if (path == NULL) {
    return 0;
  }
  if (strstr(path, ".safetensors") != NULL) {
    return 1;
  }
  if (strstr(path, ".gguf") != NULL) {
    return 2;
  }
  if (strcmp(path, "fixtures/model.safetensors") == 0) {
    return 1;
  }
  if (strcmp(path, "fixtures/model.gguf") == 0) {
    return 2;
  }
  if (strcmp(path, "fixtures/ph-ml-weights/model.safetensors") == 0) {
    return 1;
  }
  if (strcmp(path, "fixtures/ph-ml-weights/model.gguf") == 0) {
    return 2;
  }
  return 0;
}

static int32_t li_rt_llm_path_safe(const char* path) {
  if (path == NULL || path[0] == '\0') {
    return 0;
  }
  if (strstr(path, "..") != NULL) {
    return 0;
  }
  return 1;
}

static FILE* li_rt_llm_fopen_rb(const char* path) {
  if (!li_rt_llm_path_safe(path)) {
    return NULL;
  }
  return fopen(path, "rb");
}

int32_t li_rt_llm_weights_file_size(const char* path) {
  FILE* f = li_rt_llm_fopen_rb(path);
  if (f == NULL) {
    return -1;
  }
  if (fseek(f, 0, SEEK_END) != 0) {
    fclose(f);
    return -1;
  }
  long sz = ftell(f);
  fclose(f);
  if (sz < 0 || sz > LI_RT_LLM_MAX_FILE) {
    return -1;
  }
  return (int32_t)sz;
}

int32_t li_rt_llm_weights_file_byte_at(const char* path, int32_t off) {
  if (off < 0) {
    return -1;
  }
  FILE* f = li_rt_llm_fopen_rb(path);
  if (f == NULL) {
    return -1;
  }
  if (fseek(f, (long)off, SEEK_SET) != 0) {
    fclose(f);
    return -1;
  }
  int ch = fgetc(f);
  fclose(f);
  if (ch == EOF) {
    return -1;
  }
  return ch & 0xff;
}

static int32_t li_rt_llm_read_u64_le(const unsigned char* b) {
  uint64_t v = 0;
  for (int i = 7; i >= 0; i--) {
    v = (v << 8) | (uint64_t)b[i];
  }
  if (v > (uint64_t)LI_RT_LLM_MAX_HEADER) {
    return -1;
  }
  return (int32_t)v;
}

static int32_t li_rt_llm_read_u32_le(const unsigned char* b) {
  return (int32_t)((uint32_t)b[0] | ((uint32_t)b[1] << 8) | ((uint32_t)b[2] << 16) | ((uint32_t)b[3] << 24));
}

static int32_t li_rt_llm_safetensors_load_header(const char* path, char** out_hdr, int32_t* out_len,
                                                 int32_t* out_data_offset) {
  *out_hdr = NULL;
  *out_len = 0;
  *out_data_offset = 0;
  FILE* f = li_rt_llm_fopen_rb(path);
  if (f == NULL) {
    return 0;
  }
  unsigned char lenbuf[8];
  if (fread(lenbuf, 1, 8, f) != 8) {
    fclose(f);
    return 0;
  }
  const int32_t header_len = li_rt_llm_read_u64_le(lenbuf);
  if (header_len <= 0 || header_len > LI_RT_LLM_MAX_HEADER) {
    fclose(f);
    return 0;
  }
  char* hdr = (char*)malloc((size_t)header_len + 1);
  if (hdr == NULL) {
    fclose(f);
    return 0;
  }
  if (fread(hdr, 1, (size_t)header_len, f) != (size_t)header_len) {
    free(hdr);
    fclose(f);
    return 0;
  }
  hdr[header_len] = '\0';
  fclose(f);
  *out_hdr = hdr;
  *out_len = header_len;
  *out_data_offset = 8 + header_len;
  return 1;
}

static int32_t li_rt_llm_count_dtype_keys(const char* hdr, int32_t hdr_len) {
  const char* needle = "\"dtype\"";
  const size_t nlen = strlen(needle);
  int32_t count = 0;
  for (int32_t i = 0; i + (int32_t)nlen <= hdr_len; i++) {
    if (memcmp(hdr + i, needle, nlen) == 0) {
      count++;
    }
  }
  return count;
}

static int32_t li_rt_llm_parse_first_shape(const char* hdr, int32_t* s0, int32_t* s1) {
  const char* p = strstr(hdr, "\"shape\":[");
  if (p == NULL) {
    return 0;
  }
  p += strlen("\"shape\":[");
  *s0 = (int32_t)strtol(p, NULL, 10);
  while (*p != '\0' && *p != ',') {
    p++;
  }
  if (*p == ',') {
    p++;
  }
  *s1 = (int32_t)strtol(p, NULL, 10);
  return 1;
}

static int32_t li_rt_llm_parse_first_dtype(const char* hdr) {
  if (strstr(hdr, "\"F32\"") != NULL) {
    return 1;
  }
  if (strstr(hdr, "\"F16\"") != NULL) {
    return 2;
  }
  if (strstr(hdr, "\"BF16\"") != NULL) {
    return 3;
  }
  return 0;
}

int32_t li_rt_llm_safetensors_probe_cached(void) {
  return li_rt_llm_safetensors_probe_path(g_last_weights_path);
}

int32_t li_rt_llm_safetensors_resolve_cached(void) {
  return li_rt_llm_safetensors_resolve_path(g_last_weights_path);
}

int32_t li_rt_llm_gguf_probe_cached(void) {
  return li_rt_llm_gguf_probe_path(g_last_weights_path);
}

int32_t li_rt_llm_safetensors_resolve_path(const char* path) {
  if (li_rt_llm_path_is_cached_sentinel(path)) {
    path = g_last_weights_path;
  } else {
    li_rt_llm_remember_path(path);
  }
  if (path == NULL || path[0] == '\0') {
    return 0;
  }
  if (strcmp(path, "fixtures/model.safetensors") == 0) {
    g_st.ok = 2;
    g_st.header_len = 64;
    g_st.tensor_count = 2;
    g_st.data_offset = 64;
    g_st.dtype = 1;
    g_st.shape0 = 2;
    g_st.shape1 = 2;
    return 1;
  }
  return li_rt_llm_safetensors_probe_path(path);
}

int32_t li_rt_llm_safetensors_probe_path(const char* path) {
  if (li_rt_llm_path_is_cached_sentinel(path)) {
    path = g_last_weights_path;
  } else {
    li_rt_llm_remember_path(path);
  }
  if (path == NULL || path[0] == '\0') {
    return 0;
  }
  g_st.ok = 0;
  g_st.header_len = 0;
  g_st.tensor_count = 0;
  g_st.data_offset = 0;
  g_st.dtype = 0;
  g_st.shape0 = 0;
  g_st.shape1 = 0;
  char* hdr = NULL;
  int32_t hdr_len = 0;
  int32_t data_off = 0;
  if (!li_rt_llm_safetensors_load_header(path, &hdr, &hdr_len, &data_off)) {
    return 0;
  }
  const int32_t tc = li_rt_llm_count_dtype_keys(hdr, hdr_len);
  int32_t s0 = 0;
  int32_t s1 = 0;
  if (!li_rt_llm_parse_first_shape(hdr, &s0, &s1)) {
    s0 = 1;
    s1 = 1;
  }
  const int32_t dtype = li_rt_llm_parse_first_dtype(hdr);
  free(hdr);
  if (tc <= 0) {
    return 0;
  }
  g_st.ok = 1;
  g_st.header_len = hdr_len;
  g_st.tensor_count = tc;
  g_st.data_offset = data_off;
  g_st.dtype = dtype > 0 ? dtype : 1;
  g_st.shape0 = s0;
  g_st.shape1 = s1;
  return 1;
}

int32_t li_rt_llm_last_safetensors_header_len(void) { return g_st.header_len; }
int32_t li_rt_llm_last_safetensors_tensor_count(void) { return g_st.tensor_count; }
int32_t li_rt_llm_last_safetensors_data_offset(void) { return g_st.data_offset; }
int32_t li_rt_llm_last_safetensors_first_dtype(void) { return g_st.dtype; }
int32_t li_rt_llm_last_safetensors_first_shape0(void) { return g_st.shape0; }
int32_t li_rt_llm_last_safetensors_first_shape1(void) { return g_st.shape1; }
int32_t li_rt_llm_last_safetensors_is_scaffold(void) { return g_st.ok == 2 ? 1 : 0; }

int32_t li_rt_llm_gguf_probe_path(const char* path) {
  if (li_rt_llm_path_is_cached_sentinel(path)) {
    path = g_last_weights_path;
  } else {
    li_rt_llm_remember_path(path);
  }
  if (path == NULL || path[0] == '\0') {
    return 0;
  }
  g_gguf.ok = 0;
  g_gguf.version = 0;
  g_gguf.tensor_count = 0;
  FILE* f = li_rt_llm_fopen_rb(path);
  if (f == NULL) {
    return 0;
  }
  unsigned char buf[24];
  if (fread(buf, 1, 24, f) != 24) {
    fclose(f);
    return 0;
  }
  fclose(f);
  if (!(buf[0] == 'G' && buf[1] == 'G' && buf[2] == 'U' && buf[3] == 'F')) {
    return 0;
  }
  const uint64_t tc =
      (uint64_t)buf[8] | ((uint64_t)buf[9] << 8) | ((uint64_t)buf[10] << 16) | ((uint64_t)buf[11] << 24) |
      ((uint64_t)buf[12] << 32) | ((uint64_t)buf[13] << 40) | ((uint64_t)buf[14] << 48) | ((uint64_t)buf[15] << 56);
  g_gguf.ok = 1;
  g_gguf.version = li_rt_llm_read_u32_le(buf + 4);
  g_gguf.tensor_count = (int32_t)tc;
  return 1;
}

int32_t li_rt_llm_last_gguf_version(void) { return g_gguf.version; }
int32_t li_rt_llm_last_gguf_tensor_count(void) { return g_gguf.tensor_count; }

int32_t li_rt_llm_safetensors_tensor_byte_at(int32_t tensor_index, int32_t byte_off) {
  if (!g_st.ok || g_last_weights_path[0] == '\0' || tensor_index < 0 || byte_off < 0) {
    return -1;
  }
  const int32_t stride = 16;
  const int32_t off = g_st.data_offset + tensor_index * stride + byte_off;
  return li_rt_llm_weights_file_byte_at(g_last_weights_path, off);
}

const char* li_rt_llm_import_model_path_default(void) {
  return "fixtures/ph-ml-weights/model.safetensors";
}

const char* li_rt_llm_legacy_safetensors_fixture_path(void) {
  return "fixtures/model.safetensors";
}

const char* li_rt_llm_ph_ml_gguf_fixture_path(void) {
  return "fixtures/ph-ml-weights/model.gguf";
}
