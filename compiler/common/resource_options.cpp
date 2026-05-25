#include "li/resource_options.hpp"

#include <cstdlib>
#include <iostream>

namespace li {
namespace {

ResourceOptions g_opts;
bool g_env_warned = false;

void warn_deprecated_env_once(const char* var, const char* flag) {
  if (g_env_warned) {
    return;
  }
  g_env_warned = true;
  std::cerr << "lic: warning: " << var << " is deprecated; use " << flag << " on the command line\n";
}

unsigned parse_positive(const char* s) {
  if (s == nullptr || *s == '\0') {
    return 0;
  }
  const int n = std::atoi(s);
  return n > 0 ? static_cast<unsigned>(n) : 0u;
}

std::size_t parse_positive_size(const char* s) {
  const unsigned n = parse_positive(s);
  return n > 0 ? static_cast<std::size_t>(n) : 0u;
}

}  // namespace

ResourceOptions& resource_options() { return g_opts; }

void reset_resource_options() {
  g_opts = ResourceOptions{};
  g_env_warned = false;
}

bool apply_resource_flag(std::string_view arg, ResourceOptions& out) {
  if (arg.rfind("--jobs=", 0) == 0) {
    out.jobs = parse_positive(arg.substr(7).data());
    out.jobs_from_flag = out.jobs > 0;
    return true;
  }
  if (arg.rfind("--max-memory=", 0) == 0) {
    out.max_memory_mb = parse_positive_size(arg.substr(13).data());
    out.max_memory_from_flag = out.max_memory_mb > 0;
    return true;
  }
  if (arg.rfind("--job-memory-mb=", 0) == 0) {
    out.job_memory_mb = parse_positive_size(arg.substr(16).data());
    out.job_memory_from_flag = out.job_memory_mb > 0;
    return true;
  }
  if (arg.rfind("--build-dir=", 0) == 0) {
    out.build_dir = std::string(arg.substr(12));
    out.build_dir_from_flag = !out.build_dir.empty();
    return true;
  }
  if (arg.rfind("--threads=", 0) == 0) {
    out.threads = parse_positive(arg.substr(10).data());
    out.threads_from_flag = out.threads > 0;
    return true;
  }
  return false;
}

void finalize_resource_options(ResourceOptions& opts) {
  if (!opts.jobs_from_flag) {
    if (const char* v = std::getenv("LI_COMPILE_JOBS")) {
      warn_deprecated_env_once("LI_COMPILE_JOBS", "--jobs=N");
      opts.jobs = parse_positive(v);
    }
  }
  if (!opts.max_memory_from_flag) {
    if (const char* v = std::getenv("LI_MAX_MEMORY_MB")) {
      warn_deprecated_env_once("LI_MAX_MEMORY_MB", "--max-memory=MB");
      opts.max_memory_mb = parse_positive_size(v);
    }
  }
  if (!opts.threads_from_flag) {
    if (const char* v = std::getenv("LI_OMP_THREADS")) {
      warn_deprecated_env_once("LI_OMP_THREADS", "--threads=N");
      opts.threads = parse_positive(v);
    }
  }
}

}  // namespace li
