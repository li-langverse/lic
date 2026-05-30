#include "dict_core.h"

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

enum { LI_DICT_CAP = 1048576, LI_DICT_OPS = 500000 };

typedef struct {
  int64_t key;
  int64_t val;
  uint8_t used;
} li_dict_entry;

static li_dict_entry* g_table;
static double g_checksum;

static uint64_t li_dict_hash(int64_t key) {
  uint64_t x = (uint64_t)key * 0x9E3779B97F4A7C15ULL;
  x ^= x >> 33;
  x *= 0xff51afd7ed558ccdULL;
  x ^= x >> 33;
  return x;
}

static void li_dict_insert(int64_t key, int64_t val) {
  uint64_t i = li_dict_hash(key) & (uint64_t)(LI_DICT_CAP - 1);
  while (g_table[i].used) {
    if (g_table[i].key == key) {
      g_table[i].val = val;
      return;
    }
    i = (i + 1) & (uint64_t)(LI_DICT_CAP - 1);
  }
  g_table[i].key = key;
  g_table[i].val = val;
  g_table[i].used = 1;
}

static int64_t li_dict_lookup(int64_t key) {
  uint64_t i = li_dict_hash(key) & (uint64_t)(LI_DICT_CAP - 1);
  while (g_table[i].used) {
    if (g_table[i].key == key) {
      return g_table[i].val;
    }
    i = (i + 1) & (uint64_t)(LI_DICT_CAP - 1);
  }
  return -1;
}

__attribute__((noinline)) void li_stdlib_dict_kernel(void) {
  if (!g_table) {
    g_table = (li_dict_entry*)calloc((size_t)LI_DICT_CAP, sizeof(li_dict_entry));
    if (!g_table) {
      g_checksum = 0.0;
      return;
    }
  } else {
    memset(g_table, 0, (size_t)LI_DICT_CAP * sizeof(li_dict_entry));
  }
  for (int64_t k = 0; k < LI_DICT_OPS; ++k) {
    li_dict_insert(k, k * 3 + 7);
  }
  double acc = 0.0;
  for (int64_t k = 0; k < LI_DICT_OPS; ++k) {
    acc += (double)li_dict_lookup(k);
  }
  g_checksum = acc;
}

double li_stdlib_dict_checksum(void) { return g_checksum; }
