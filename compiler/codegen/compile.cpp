#include "li/compile.hpp"
#include "li/emit.hpp"
#include "li/mir.hpp"
#include "li/mir_abi.hpp"
#include "li/num_stable.hpp"
#include "li/platform.hpp"

#include <atomic>
#include <chrono>
#include <cstdlib>
#include <filesystem>
#include <sstream>

namespace li {
namespace {

std::string unique_temp_ll_path() {
  static std::atomic<std::uint64_t> seq{0};
  const auto tick =
      static_cast<std::uint64_t>(std::chrono::steady_clock::now().time_since_epoch().count());
  const auto n = seq.fetch_add(1, std::memory_order_relaxed);
  return (std::filesystem::temp_directory_path() /
          ("li_build_" + std::to_string(tick) + "_" + std::to_string(n) + ".ll"))
      .string();
}

}  // namespace

bool compile_module(const Module& module, const std::string& output_path,
                  const CompileOptions& opts, const std::string& extra_clang_flags,
                  std::string* error) {
  MirModule mir = lower_to_mir(module);
  mir.fp_numerically_stable = opts.fp_numerically_stable;
  apply_numerical_stability(mir);
  std::string abi_err;
  if (!verify_mir_extern_abi(module, mir, &abi_err)) {
    if (error) {
      *error = abi_err;
    }
    return false;
  }
  const std::string ll_path = unique_temp_ll_path();

  if (!emit_llvm_ir(mir, ll_path, error)) {
    return false;
  }

  if (is_null_output_path(output_path)) {
    std::filesystem::remove(ll_path);
    return true;
  }

  if (!is_safe_link_path(output_path)) {
    if (error) {
      *error = "unsafe characters in output path";
    }
    std::filesystem::remove(ll_path);
    return false;
  }

  auto resolve_runtime_c = [](const char* name) -> std::filesystem::path {
    std::filesystem::path p = std::filesystem::path("runtime") / name;
    if (!std::filesystem::exists(p)) {
      p = std::filesystem::path("..") / "runtime" / name;
    }
    return p;
  };
  const std::filesystem::path rt_path = resolve_runtime_c("li_rt.c");
  const std::filesystem::path rt_httpd_path = resolve_runtime_c("li_rt_httpd.c");
  const std::filesystem::path rt_net_path = resolve_runtime_c("li_rt_net.c");

  std::ostringstream cmd;
  const char* cc_env = std::getenv("CC");
  const char* cc = (cc_env && *cc_env) ? cc_env : "clang";
  cmd << cc << " -Wno-override-module -x ir \"" << ll_path << "\" -x c \"" << rt_path.string() << "\"";
  if (std::filesystem::exists(rt_httpd_path)) {
    cmd << " -x c \"" << rt_httpd_path.string() << "\"";
  }
  if (std::filesystem::exists(rt_net_path)) {
    cmd << " -x c \"" << rt_net_path.string() << "\"";
  }
  cmd << " -o \"" << output_path << "\"";
  if (opts.release) {
    cmd << " -O2";
  }
  if (opts.fp_numerically_stable) {
    cmd << " -fno-fast-math -ffp-contract=off";
  }
  if (!extra_clang_flags.empty()) {
    cmd << " " << extra_clang_flags;
  }
  if (mir.uses_openmp) {
#if defined(__linux__)
    cmd << " -fopenmp";
#elif defined(__APPLE__)
    if (std::filesystem::exists("/opt/homebrew/opt/libomp/lib/libomp.dylib")) {
      cmd << " -Xpreprocessor -fopenmp -I/opt/homebrew/opt/libomp/include"
          << " -L/opt/homebrew/opt/libomp/lib -lomp";
    }
#else
    if (const char* omp = std::getenv("LI_OPENMP_FLAGS")) {
      cmd << " " << omp;
    }
#endif
  }
  if (const char* extra_c = std::getenv("LI_EXTRA_C")) {
    std::string paths(extra_c);
    std::size_t start = 0;
    while (start < paths.size()) {
      const std::size_t end = paths.find(' ', start);
      const std::string path = paths.substr(start, end == std::string::npos ? std::string::npos
                                                                            : end - start);
      if (!path.empty()) {
        if (!is_safe_link_path(path)) {
          if (error) {
            *error = "unsafe characters in LI_EXTRA_C path";
          }
          std::filesystem::remove(ll_path);
          return false;
        }
        cmd << " -x c \"" << path << "\"";
      }
      if (end == std::string::npos) {
        break;
      }
      start = end + 1;
    }
  }
#if defined(__linux__)
  cmd << " -lm";
#endif
  const int rc = std::system(cmd.str().c_str());
  std::filesystem::remove(ll_path);
  if (rc != 0) {
    if (error) {
      *error = "clang link failed";
    }
    return false;
  }
  return true;
}

}  // namespace li
