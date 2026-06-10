#include "li_rt.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct LiIoBlob {
  char* data;
  int32_t len;
} LiIoBlob;

static int32_t li_rt_io_path_safe(const char* path) {
  if (path == NULL || path[0] == '\0') {
    return 0;
  }
  if (strstr(path, "..") != NULL) {
    return 0;
  }
  if (path[0] == '/') {
    return 0;
  }
  return 1;
}

static LiIoBlob* li_rt_io_blob_from_ptr(intptr_t blob) {
  if (blob == 0) {
    return NULL;
  }
  return (LiIoBlob*)(intptr_t)blob;
}

intptr_t io_read_file(const char* path, int32_t max_bytes) {
  if (!li_rt_io_path_safe(path)) {
    return 0;
  }
  if (max_bytes < 0) {
    return 0;
  }
  if (max_bytes == 0) {
    return 0;
  }
  FILE* f = fopen(path, "rb");
  if (f == NULL) {
    return 0;
  }
  if (fseek(f, 0, SEEK_END) != 0) {
    fclose(f);
    return 0;
  }
  long sz = ftell(f);
  if (sz < 0) {
    fclose(f);
    return 0;
  }
  if (fseek(f, 0, SEEK_SET) != 0) {
    fclose(f);
    return 0;
  }
  int32_t read_len = (int32_t)sz;
  if (read_len > max_bytes) {
    read_len = max_bytes;
  }
  LiIoBlob* blob = (LiIoBlob*)malloc(sizeof(LiIoBlob));
  if (blob == NULL) {
    fclose(f);
    return 0;
  }
  blob->data = (char*)malloc((size_t)read_len + 1u);
  if (blob->data == NULL) {
    free(blob);
    fclose(f);
    return 0;
  }
  size_t got = fread(blob->data, 1, (size_t)read_len, f);
  fclose(f);
  blob->len = (int32_t)got;
  blob->data[blob->len] = '\0';
  return (intptr_t)blob;
}

intptr_t io_blob_data(intptr_t blob) {
  LiIoBlob* b = li_rt_io_blob_from_ptr(blob);
  if (b == NULL || b->data == NULL) {
    return 0;
  }
  return (intptr_t)b->data;
}

int32_t io_blob_len(intptr_t blob) {
  LiIoBlob* b = li_rt_io_blob_from_ptr(blob);
  if (b == NULL) {
    return 0;
  }
  return b->len;
}

void io_free(intptr_t blob) {
  LiIoBlob* b = li_rt_io_blob_from_ptr(blob);
  if (b == NULL) {
    return;
  }
  free(b->data);
  free(b);
}
