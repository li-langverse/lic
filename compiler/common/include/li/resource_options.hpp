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
  bool jobs_from_flag = false, max_memory_from_flag = false, job_memory_from_flag = false;
  bool build_dir_from_flag = false, threads_from_flag = false;
  unsigned effective_jobs(unsigned default_per_job_mb = 768) const;
};
ResourceOptions& resource_options();
void reset_resource_options();
bool apply_resource_flag(std::string_view arg, ResourceOptions& out);
void finalize_resource_options(ResourceOptions& opts);
}
