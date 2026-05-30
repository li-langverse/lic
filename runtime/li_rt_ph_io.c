#include "li_rt.h"

#include <spawn.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>

extern char** environ;

static const char* path_i(intptr_t p) { return (const char*)(intptr_t)p; }

static const char* benchmarks_root(void) {
  const char* env = getenv("LI_BENCHMARKS_ROOT");
  if (env && env[0]) {
    return env;
  }
  if (access("catalog.toml", R_OK) == 0) {
    return ".";
  }
  return NULL;
}

static int run_python_script(const char* script_rel, int extra_argc, char* const* extra_argv) {
  const char* root = benchmarks_root();
  if (!root) {
    return 1;
  }
  char script[4096];
  if (snprintf(script, sizeof(script), "%s/%s", root, script_rel) >= (int)sizeof(script)) {
    return 1;
  }
  if (access(script, R_OK) != 0) {
    return 1;
  }
  char* argv[16];
  int argc = 0;
  argv[argc++] = (char*)"python3";
  argv[argc++] = script;
  for (int i = 0; i < extra_argc && argc < 15; ++i) {
    argv[argc++] = extra_argv[i];
  }
  argv[argc] = NULL;
  pid_t pid = 0;
  int rc = posix_spawnp(&pid, "python3", NULL, NULL, argv, environ);
  if (rc != 0) {
    return 1;
  }
  int status = 0;
  if (waitpid(pid, &status, 0) < 0) {
    return 1;
  }
  if (!WIFEXITED(status)) {
    return 1;
  }
  return WEXITSTATUS(status);
}

int32_t summary_build(intptr_t catalog, intptr_t lic_csv, intptr_t lis_csv, intptr_t stab,
                      intptr_t out) {
  const char* args[] = {path_i(catalog), path_i(lic_csv), path_i(lis_csv), path_i(stab), path_i(out)};
  return (int32_t)run_python_script("scripts/ingest/summary_build_from_paths.py", 5, (char* const*)args);
}

int32_t plot_render_dashboard(intptr_t summary_json, intptr_t html_out) {
  const char* args[] = {path_i(summary_json), path_i(html_out)};
  return (int32_t)run_python_script("scripts/dashboard/plot_render_dashboard.py", 2, (char* const*)args);
}
