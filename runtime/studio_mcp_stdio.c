/* PH-AGENT-2 — minimal MCP stdio server for li-engine (8 Studio tools). */
#include "li_rt.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MCP_LINE_MAX 65536
#define MCP_NAME_MAX 64

static const char* k_mcp_server_name = "li-engine";
static const char* k_mcp_server_version = "0.1.0";

static int json_extract_string(const char* line, const char* key, char* out, size_t out_cap) {
  if (line == NULL || key == NULL || out == NULL || out_cap == 0) {
    return 0;
  }
  char needle[128];
  snprintf(needle, sizeof(needle), "\"%s\"", key);
  const char* p = strstr(line, needle);
  if (p == NULL) {
    return 0;
  }
  p = strchr(p + strlen(needle), ':');
  if (p == NULL) {
    return 0;
  }
  p++;
  while (*p == ' ' || *p == '\t') {
    p++;
  }
  if (*p != '"') {
    return 0;
  }
  p++;
  size_t n = 0;
  while (p[n] != '\0' && p[n] != '"' && n + 1 < out_cap) {
    out[n] = p[n];
    n++;
  }
  if (p[n] != '"') {
    return 0;
  }
  out[n] = '\0';
  return 1;
}

static int json_has_id(const char* line) {
  return strstr(line, "\"id\"") != NULL;
}

static long json_extract_id(const char* line) {
  const char* p = strstr(line, "\"id\"");
  if (p == NULL) {
    return -1;
  }
  p = strchr(p, ':');
  if (p == NULL) {
    return -1;
  }
  p++;
  while (*p == ' ' || *p == '\t') {
    p++;
  }
  return strtol(p, NULL, 10);
}

static void write_tools_list(long id) {
  printf("{\"jsonrpc\":\"2.0\",\"id\":%ld,\"result\":{\"tools\":[", id);
  for (int32_t tid = 1; tid <= 8; tid++) {
    const char* name = li_rt_studio_mcp_tool_name(tid);
    if (name == NULL || name[0] == '\0') {
      continue;
    }
    if (tid > 1) {
      printf(",");
    }
    printf(
        "{\"name\":\"%s\",\"description\":\"Studio MCP tool %s (li_rt_studio_mcp_dispatch)\","
        "\"inputSchema\":{\"type\":\"object\",\"properties\":{}}}",
        name, name);
  }
  printf("]}}\n");
  fflush(stdout);
}

static void write_tool_call_result(long id, int is_error, const char* text) {
  printf(
      "{\"jsonrpc\":\"2.0\",\"id\":%ld,\"result\":{\"content\":[{\"type\":\"text\",\"text\":\"%s\"}],"
      "\"isError\":%s}}\n",
      id, text, is_error ? "true" : "false");
  fflush(stdout);
}

static void write_initialize(long id) {
  printf(
      "{\"jsonrpc\":\"2.0\",\"id\":%ld,\"result\":{\"protocolVersion\":\"2024-11-05\","
      "\"capabilities\":{\"tools\":{}},\"serverInfo\":{\"name\":\"%s\",\"version\":\"%s\"}}}\n",
      id, k_mcp_server_name, k_mcp_server_version);
  fflush(stdout);
}

static void write_error(long id, int code, const char* message) {
  printf(
      "{\"jsonrpc\":\"2.0\",\"id\":%ld,\"error\":{\"code\":%d,\"message\":\"%s\"}}\n", id, code,
      message);
  fflush(stdout);
}

static int dispatch_tool_name(const char* name, char* detail, size_t detail_cap) {
  const int32_t tid = li_rt_studio_mcp_tool_from_name(name);
  if (tid == 0) {
    snprintf(detail, detail_cap, "unknown tool: %s", name);
    return 2;
  }
  const int32_t rc = li_rt_studio_mcp_dispatch(tid);
  if (rc == 1) {
    snprintf(detail, detail_cap, "proof gate failed for %s", name);
    return 1;
  }
  if (rc == 2) {
    snprintf(detail, detail_cap, "dispatch I/O error for %s", name);
    return 2;
  }
  if (tid == 7) {
    const float e = li_rt_studio_mcp_chem_energy_hartree();
    snprintf(detail, detail_cap, "chem_dft_run ok energy_hartree=%.1f", (double)e);
    return 0;
  }
  if (tid == 2) {
    const int32_t pid = li_rt_studio_mcp_last_profile_id();
    snprintf(detail, detail_cap, "sim_set_profile ok profile_id=%d", (int)pid);
    return 0;
  }
  snprintf(detail, detail_cap, "%s ok", name);
  return 0;
}

static void handle_tools_call(const char* line, long id) {
  char name[MCP_NAME_MAX];
  if (!json_extract_string(line, "name", name, sizeof(name))) {
    write_error(id, -32602, "tools/call missing name");
    return;
  }
  char detail[256];
  const int err = dispatch_tool_name(name, detail, sizeof(detail));
  write_tool_call_result(id, err != 0, detail);
}

static void handle_line(const char* line) {
  if (line == NULL || line[0] == '\0') {
    return;
  }
  if (!json_has_id(line)) {
    return;
  }
  const long id = json_extract_id(line);
  char method[MCP_NAME_MAX];
  if (!json_extract_string(line, "method", method, sizeof(method))) {
    write_error(id, -32600, "missing method");
    return;
  }
  if (strcmp(method, "initialize") == 0) {
    write_initialize(id);
    return;
  }
  if (strcmp(method, "tools/list") == 0) {
    write_tools_list(id);
    return;
  }
  if (strcmp(method, "tools/call") == 0) {
    handle_tools_call(line, id);
    return;
  }
  write_error(id, -32601, "method not found");
}

int main(void) {
  char line[MCP_LINE_MAX];
  while (fgets(line, sizeof(line), stdin) != NULL) {
    size_t n = strlen(line);
    while (n > 0 && (line[n - 1] == '\n' || line[n - 1] == '\r')) {
      line[--n] = '\0';
    }
    handle_line(line);
  }
  return 0;
}
