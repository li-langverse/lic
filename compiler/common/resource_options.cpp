#include "li/resource_options.hpp"

#include <cstdlib>
#include <iostream>
#include <unistd.h>

namespace li {
namespace {

ResourceOptions g_opts;
bool g_env_warned = false;
bool g_threads_cores_warned = false;
bool g_invalid = false;

void warn_deprecated_env_once(const char* var, const char* flag) {
  if (g_env_warned) {
    return;
  }
  g_env_warned = true;
  std::cerr << "lic: warning: " << var << " is deprecated; use " << flag << " on the command line\n";
}

void warn_env_ignored_once(const char* var) {
  if (g_env_warned) {
    return;
  }
  g_env_warned = true;
  std::cerr << "lic: warning: " << var << " is set but ignored because the matching flag was passed\n";
}

void warn_threads_over_cores_once() {
  if (g_threads_cores_warned) {
    return;
  }
  g_threads_cores_warned = true;
  std::cerr << "lic: warning: --threads= wins over --cores/--threads-per-core= when both are set\n";
}

int parse_int(const char* s) {
  if (s == nullptr || *s == '\0') {
    return 0;
  }
  return std::atoi(s);
}

unsigned parse_positive(const char* s) {
  const int n = parse_int(s);
  return n > 0 ? static_cast<unsigned>(n) : 0u;
}

std::size_t parse_positive_size(const char* s) {
  const unsigned n = parse_positive(s);
  return n > 0 ? static_cast<std::size_t>(n) : 0u;
}

unsigned host_logical_cores() {
#ifdef _SC_NPROCESSORS_ONLN
  const long n = sysconf(_SC_NPROCESSORS_ONLN);
  return n > 0 ? static_cast<unsigned>(n) : 1u;
#else
  return 1u;
#endif
}

}  // namespace

ResourceOptions& resource_options() { return g_opts; }

void reset_resource_options() {
  g_opts = ResourceOptions{};
  g_env_warned = false;
  g_threads_cores_warned = false;
  g_invalid = false;
}

bool resource_options_invalid() { return g_invalid; }

void clear_resource_options_invalid() { g_invalid = false; }

unsigned ResourceOptions::effective_jobs(unsigned default_per_job_mb) const {
  unsigned j = jobs > 0 ? jobs : 1u;
  const std::size_t per = job_memory_mb > 0 ? job_memory_mb : default_per_job_mb;
  if (max_memory_mb == 0 || per == 0) {
    return j;
  }
  const std::size_t cap = max_memory_mb / per;
  const unsigned capped = cap < 1 ? 1u : static_cast<unsigned>(cap);
  return j < capped ? j : capped;
}

int ResourceOptions::effective_runtime_team_size() const {
  unsigned raw = 0;
  if (threads_from_flag && threads > 0) {
    raw = threads;
  } else if (cores_from_flag && cores > 0) {
    const unsigned tpc = threads_per_core > 0 ? threads_per_core : 1u;
    raw = cores * tpc;
  } else if (threads > 0) {
    raw = threads;
  }
  if (raw == 0) {
    return 0;
  }
  if (raw > kLiMaxRuntimeThreads) {
    return static_cast<int>(kLiMaxRuntimeThreads);
  }
  return static_cast<int>(raw);
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
  if (arg.rfind("--threads-per-core=", 0) == 0) {
    const int raw = parse_int(arg.substr(19).data());
    if (raw <= 0) {
      std::cerr << "lic: error: --threads-per-core must be a positive integer\n";
      g_invalid = true;
      return true;
    }
    out.threads_per_core = static_cast<unsigned>(raw);
    out.threads_per_core_from_flag = true;
    return true;
  }
  if (arg.rfind("--cores=", 0) == 0) {
    const int raw = parse_int(arg.substr(8).data());
    if (raw <= 0) {
      std::cerr << "lic: error: --cores must be a positive integer\n";
      g_invalid = true;
      return true;
    }
    out.cores = static_cast<unsigned>(raw);
    out.cores_from_flag = true;
    return true;
  }
  if (arg.rfind("--threads=", 0) == 0) {
    const int raw = parse_int(arg.substr(10).data());
    if (raw <= 0) {
      std::cerr << "lic: error: --threads must be a positive integer\n";
      g_invalid = true;
      return true;
    }
    out.threads = static_cast<unsigned>(raw);
    out.threads_from_flag = true;
    return true;
  }
  return false;
}

void finalize_resource_options(ResourceOptions& opts) {
  if (!opts.jobs_from_flag && std::getenv("LI_COMPILE_JOBS")) {
    if (const unsigned v = parse_positive(std::getenv("LI_COMPILE_JOBS")); v > 0) {
      opts.jobs = v;
      warn_deprecated_env_once("LI_COMPILE_JOBS", "--jobs=N");
    }
  } else if (opts.jobs_from_flag && std::getenv("LI_COMPILE_JOBS")) {
    warn_env_ignored_once("LI_COMPILE_JOBS");
  }
  if (!opts.max_memory_from_flag && std::getenv("LI_MAX_MEMORY_MB")) {
    if (const std::size_t v = parse_positive_size(std::getenv("LI_MAX_MEMORY_MB")); v > 0) {
      opts.max_memory_mb = v;
      warn_deprecated_env_once("LI_MAX_MEMORY_MB", "--max-memory=MB");
    }
  } else if (opts.max_memory_from_flag && std::getenv("LI_MAX_MEMORY_MB")) {
    warn_env_ignored_once("LI_MAX_MEMORY_MB");
  }
  if (!opts.build_dir_from_flag && std::getenv("LI_BUILD_DIR")) {
    if (const char* env = std::getenv("LI_BUILD_DIR"); env && env[0]) {
      opts.build_dir = env;
      warn_deprecated_env_once("LI_BUILD_DIR", "--build-dir=PATH");
    }
  } else if (opts.build_dir_from_flag && std::getenv("LI_BUILD_DIR")) {
    warn_env_ignored_once("LI_BUILD_DIR");
  }
  if (!opts.threads_from_flag && std::getenv("LI_OMP_THREADS")) {
    if (const unsigned v = parse_positive(std::getenv("LI_OMP_THREADS")); v > 0) {
      opts.threads = v;
      warn_deprecated_env_once("LI_OMP_THREADS", "--threads=N");
    }
  } else if (opts.threads_from_flag && std::getenv("LI_OMP_THREADS")) {
    warn_env_ignored_once("LI_OMP_THREADS");
  }
  if (opts.threads_from_flag && (opts.cores_from_flag || opts.threads_per_core_from_flag)) {
    warn_threads_over_cores_once();
  }
  const unsigned host = host_logical_cores();
  if (opts.cores_from_flag && opts.cores > host) {
    std::cerr << "lic: warning: --cores=" << opts.cores << " capped to host logical cores (" << host
              << ")\n";
    opts.cores = host;
  }
  if (opts.jobs == 0) {
    opts.jobs = 1;
  }
}

unsigned g_compile_jobs_reserved = 1;
void note_compile_jobs_reserved(const ResourceOptions& opts) {
  g_compile_jobs_reserved = opts.effective_jobs();
  setenv("LI_COMPILE_JOBS", std::to_string(g_compile_jobs_reserved).c_str(), 1);
}
unsigned compile_jobs_reserved() { return g_compile_jobs_reserved; }

}  // namespace li
