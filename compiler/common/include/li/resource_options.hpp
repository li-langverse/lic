#pragma once

#include <cstddef>
#include <string>
#include <string_view>

namespace li {

// Documented caps — refuse unbounded fork / memory DoS via CLI (see check-cache-threat-model).
inline constexpr unsigned kMaxResourceJobs = 256;
inline constexpr std::size_t kMaxResourceMemoryMb = 65536;  // 64 GiB
inline constexpr std::size_t kMaxResourceJobMemoryMb = 8192;
inline constexpr unsigned kMaxResourceThreads = 256;

struct ResourceOptions {
  unsigned jobs = 0;
  std::size_t max_memory_mb = 0;
  std::size_t job_memory_mb = 0;
  std::string build_dir;
  unsigned threads = 0;
  bool jobs_from_flag = false;
  bool max_memory_from_flag = false;
  bool job_memory_from_flag = false;
  bool build_dir_from_flag = false;
  bool threads_from_flag = false;

  unsigned effective_jobs(unsigned default_per_job_mb = 768) const;
};

ResourceOptions& resource_options();
void reset_resource_options();
bool apply_resource_flag(std::string_view arg, ResourceOptions& out);
void finalize_resource_options(ResourceOptions& opts);
void note_compile_jobs_reserved(const ResourceOptions& opts);
unsigned compile_jobs_reserved();

}  // namespace li
