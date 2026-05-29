#include "li_rt_lkir_parse.h"

#include <ctype.h>
#include <stdio.h>
#include <string.h>

enum {
  LKIR_OP_TILE = 1,
  LKIR_OP_LOAD_A = 2,
  LKIR_OP_LOAD_B = 3,
  LKIR_OP_BARRIER = 4,
  LKIR_OP_STORE_C = 5,
  LKIR_OP_FMA_ACC = 6,
  LKIR_OP_RELU = 7,
};

static int parse_opcode(const char* line, int* out_op) {
  if (line == NULL || out_op == NULL) {
    return 0;
  }
  while (*line && isspace((unsigned char)*line)) {
    ++line;
  }
  if (strncmp(line, "tile ", 5) == 0) {
    *out_op = LKIR_OP_TILE;
    return 1;
  }
  if (strncmp(line, "load_a ", 7) == 0) {
    *out_op = LKIR_OP_LOAD_A;
    return 1;
  }
  if (strncmp(line, "load_b ", 7) == 0) {
    *out_op = LKIR_OP_LOAD_B;
    return 1;
  }
  if (strcmp(line, "barrier") == 0) {
    *out_op = LKIR_OP_BARRIER;
    return 1;
  }
  if (strncmp(line, "store_c ", 8) == 0) {
    *out_op = LKIR_OP_STORE_C;
    return 1;
  }
  if (strncmp(line, "fma_acc ", 8) == 0) {
    *out_op = LKIR_OP_FMA_ACC;
    return 1;
  }
  if (strncmp(line, "relu ", 5) == 0) {
    *out_op = LKIR_OP_RELU;
    return 1;
  }
  return 0;
}

static int read_ops(const char* path, int* ops, int max_ops, int* out_count) {
  FILE* f = fopen(path, "r");
  if (f == NULL) {
    return -1;
  }
  char buf[256];
  int n = 0;
  while (fgets(buf, sizeof(buf), f) != NULL) {
    size_t len = strlen(buf);
    while (len > 0 && (buf[len - 1] == '\n' || buf[len - 1] == '\r')) {
      buf[--len] = '\0';
    }
    char* p = buf;
    while (*p && isspace((unsigned char)*p)) {
      ++p;
    }
    if (*p == '\0' || *p == ';') {
      continue;
    }
    if (n >= max_ops) {
      fclose(f);
      return 0;
    }
    if (!parse_opcode(p, &ops[n])) {
      fclose(f);
      return 0;
    }
    ++n;
  }
  fclose(f);
  *out_count = n;
  return 1;
}

int32_t li_rt_lkir_count_op_lines(const char* path) {
  int ops[32];
  int n = 0;
  if (read_ops(path, ops, 32, &n) != 1) {
    return -1;
  }
  return n;
}

static int expect_ops(const int* got, int n, const int* expect, int expect_n) {
  if (n != expect_n) {
    return 0;
  }
  for (int i = 0; i < expect_n; ++i) {
    if (got[i] != expect[i]) {
      return 0;
    }
  }
  return 1;
}

int32_t li_rt_lkir_validate_file(const char* path, int32_t module_kind) {
  int ops[32];
  int n = 0;
  const int rc = read_ops(path, ops, 32, &n);
  if (rc == -1) {
    return -1;
  }
  if (rc != 1) {
    return 0;
  }
  if (module_kind == LI_LKIR_MODULE_MATMUL) {
    const int expect[] = {LKIR_OP_TILE, LKIR_OP_LOAD_A, LKIR_OP_LOAD_B, LKIR_OP_BARRIER,
                          LKIR_OP_STORE_C, LKIR_OP_BARRIER};
    return expect_ops(ops, n, expect, 6) ? 1 : 0;
  }
  if (module_kind == LI_LKIR_MODULE_MLP_FORWARD) {
    const int expect[] = {LKIR_OP_TILE,     LKIR_OP_LOAD_A,   LKIR_OP_LOAD_B, LKIR_OP_BARRIER,
                          LKIR_OP_FMA_ACC,  LKIR_OP_BARRIER,  LKIR_OP_RELU,   LKIR_OP_BARRIER,
                          LKIR_OP_STORE_C};
    return expect_ops(ops, n, expect, 9) ? 1 : 0;
  }
  return 0;
}
