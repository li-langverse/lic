#pragma once

#include <cstddef>
#include <string>
#include <string_view>

namespace li {

struct ResourceOptions {
  unsigned jobs = 0;
  std::size_t max_memory_mb = 0;
  std::size_t job_memory_mb = 0;
  std::string build_dir;
  unsigned threads = 0;
  unsigned cores = 0;
  unsigned threads_per_core = 0;
  bool jobs_from_flag = false;
  bool max_memory_from_flag = false;
  bool job_memory_from_flag = false;
  bool build_dir_from_flag = false;
  bool threads_from_flag = false;
  bool cores_from_flag = false;
  bool threads_per_core_from_flag = false;

  unsigned effective_jobs(unsigned default_per_job_mb = 768) const;
  unsigned effective_cores() const;
  unsigned effective_threads_per_core() const;
  unsigned effective_omp_threads() const;
};

ResourceOptions& resource_options();
void reset_resource_options();
bool apply_resource_flag(std::string_view arg, ResourceOptions& out);
void finalize_resource_options(ResourceOptions& opts);
bool resource_options_invalid();
void clear_resource_options_invalid();

}  // namespace li
