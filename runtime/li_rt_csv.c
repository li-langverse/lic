#include "li_rt.h"

#include <stdlib.h>
#include <string.h>

#define LI_CSV_MAX_COLS 64
#define LI_CSV_MAX_ROWS 1024
#define LI_CSV_MAX_FIELD 512

typedef struct LiCsvDoc {
  int32_t row_count;
  int32_t col_count;
  char headers[LI_CSV_MAX_COLS][LI_CSV_MAX_FIELD];
} LiCsvDoc;

static LiCsvDoc* li_rt_csv_doc_from_ptr(intptr_t doc) {
  if (doc == 0) {
    return NULL;
  }
  return (LiCsvDoc*)(intptr_t)doc;
}

static int32_t li_rt_csv_streq(const char* a, const char* b) {
  if (a == NULL || b == NULL) {
    return 0;
  }
  return strcmp(a, b) == 0 ? 1 : 0;
}

static void li_rt_csv_trim_inplace(char* s) {
  if (s == NULL) {
    return;
  }
  char* start = s;
  while (*start == ' ' || *start == '\t' || *start == '\r') {
    ++start;
  }
  if (start != s) {
    memmove(s, start, strlen(start) + 1u);
  }
  size_t n = strlen(s);
  while (n > 0 && (s[n - 1] == ' ' || s[n - 1] == '\t' || s[n - 1] == '\r')) {
    s[--n] = '\0';
  }
}

static int32_t li_rt_csv_split_line(char* line, char* fields[], int32_t max_fields) {
  int32_t count = 0;
  char* p = line;
  while (*p != '\0' && count < max_fields) {
    fields[count++] = p;
    char* comma = strchr(p, ',');
    if (comma == NULL) {
      break;
    }
    *comma = '\0';
    li_rt_csv_trim_inplace(fields[count - 1]);
    p = comma + 1;
  }
  if (count < max_fields) {
    li_rt_csv_trim_inplace(p);
    fields[count++] = p;
  }
  return count;
}

intptr_t csv_parse(intptr_t data, int32_t n) {
  const char* raw = (const char*)(intptr_t)data;
  if (raw == NULL || n < 0) {
    return 0;
  }
  char* buf = (char*)malloc((size_t)n + 1u);
  if (buf == NULL) {
    return 0;
  }
  memcpy(buf, raw, (size_t)n);
  buf[n] = '\0';

  LiCsvDoc* doc = (LiCsvDoc*)calloc(1, sizeof(LiCsvDoc));
  if (doc == NULL) {
    free(buf);
    return 0;
  }

  char* first_nl = strchr(buf, '\n');
  if (first_nl == NULL) {
    free(buf);
    free(doc);
    return 0;
  }
  *first_nl = '\0';

  char* fields[LI_CSV_MAX_COLS];
  int32_t header_fields = li_rt_csv_split_line(buf, fields, LI_CSV_MAX_COLS);
  if (header_fields <= 0) {
    free(buf);
    free(doc);
    return 0;
  }
  doc->col_count = header_fields;
  if (doc->col_count > LI_CSV_MAX_COLS) {
    doc->col_count = LI_CSV_MAX_COLS;
  }
  for (int32_t i = 0; i < doc->col_count; ++i) {
    strncpy(doc->headers[i], fields[i], LI_CSV_MAX_FIELD - 1);
    doc->headers[i][LI_CSV_MAX_FIELD - 1] = '\0';
  }

  int32_t rows = 0;
  char* line = first_nl + 1;
  while (line != NULL && *line != '\0' && rows < LI_CSV_MAX_ROWS) {
    char* line_end = strchr(line, '\n');
    if (line_end != NULL) {
      *line_end = '\0';
    }
    li_rt_csv_trim_inplace(line);
    if (line[0] != '\0') {
      char* row_fields[LI_CSV_MAX_COLS];
      if (li_rt_csv_split_line(line, row_fields, LI_CSV_MAX_COLS) > 0) {
        ++rows;
      }
    }
    if (line_end == NULL) {
      break;
    }
    line = line_end + 1;
  }

  doc->row_count = rows;
  free(buf);
  return (intptr_t)doc;
}

int32_t csv_row_count(intptr_t doc_ptr) {
  LiCsvDoc* doc = li_rt_csv_doc_from_ptr(doc_ptr);
  if (doc == NULL) {
    return 0;
  }
  return doc->row_count;
}

int32_t csv_col_index(intptr_t doc_ptr, const char* name) {
  LiCsvDoc* doc = li_rt_csv_doc_from_ptr(doc_ptr);
  if (doc == NULL || name == NULL) {
    return -1;
  }
  for (int32_t i = 0; i < doc->col_count; ++i) {
    if (li_rt_csv_streq(doc->headers[i], name)) {
      return i;
    }
  }
  return -1;
}

void csv_free(intptr_t doc_ptr) {
  LiCsvDoc* doc = li_rt_csv_doc_from_ptr(doc_ptr);
  if (doc == NULL) {
    return;
  }
  free(doc);
}
