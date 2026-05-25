#pragma once

#include <cstddef>
#include <string>
#include <string_view>

namespace li {

/** Must match `LI_MAX_THREADS` in runtime/li_parallel.h. */
constexpr unsigned kLiMaxRuntimeThreads = 64;

struct ResourceOptions {
  unsigned jobs = 0;
  std::size_t max_memory_mb = 0;
  std::size_t job_memory_mb = 0;
  std::string build_dir;
  /** Total runtime parallel team (`--threads=N`); deprecated vs --cores. */
  unsigned threads = 0;
  /** Hardware cores for runtime team (`--cores=N`). */
  unsigned cores = 0;
  /** Logical threads per core (`--threads-per-core=M`, default 1). */
  unsigned threads_per_core = 1;
  bool jobs_from_flag = false;
  bool max_memory_from_flag = false;
  bool job_memory_from_flag = false;
  bool build_dir_from_flag = false;
  bool threads_from_flag = false;
  bool cores_from_flag = false;
  bool threads_per_core_from_flag = false;

  unsigned effective_jobs(unsigned default_per_job_mb = 768) const;
  /** Runtime team baked into `li_parallel_for_i64` at link time; 0 = host default in RT. */
  int effective_runtime_team_size() const;
};

ResourceOptions& resource_options();
void reset_resource_options();
bool apply_resource_flag(std::string_view arg, ResourceOptions& out);
void finalize_resource_options(ResourceOptions& opts);
void note_compile_jobs_reserved(const ResourceOptions& opts);
unsigned compile_jobs_reserved();

}  // namespace li
