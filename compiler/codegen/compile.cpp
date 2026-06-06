#include "li/compile.hpp"
#include "li/emit.hpp"
#include "li/mir.hpp"
#include "li/mir_abi.hpp"
#include "li/mir_runtime_link.hpp"
#include "li/num_stable.hpp"
#include "li/platform.hpp"

#include <atomic>
#include <chrono>
#include <cstdlib>
#include <filesystem>
#include <sstream>

#include "llvm/Config/llvm-config.h"

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


void maybe_keep_emit_ll(const std::string& ll_path) {
  if (const char* keep = std::getenv("LI_KEEP_LL"); keep == nullptr || keep[0] != '1' ||
      keep[1] != '\0') {
    return;
  }
  const std::string prefix = repo_build_prefix();
  if (prefix.empty()) {
    return;
  }
  std::error_code ec;
  std::filesystem::create_directories(prefix, ec);
  const std::filesystem::path dest = std::filesystem::path(prefix) / "last_emit.ll";
  std::filesystem::copy_file(ll_path, dest, std::filesystem::copy_options::overwrite_existing, ec);
}

bool clang_executable_exists(const std::string& cc) {
  if (cc.empty()) {
    return false;
  }
  std::error_code ec;
  if (std::filesystem::exists(cc, ec)) {
    return true;
  }
  const char* path_env = std::getenv("PATH");
  if (path_env == nullptr) {
    return false;
  }
  std::string paths(path_env);
  std::size_t start = 0;
  while (start < paths.size()) {
    const std::size_t end = paths.find(':', start);
    const std::string dir = paths.substr(start, end == std::string::npos ? std::string::npos
                                                                         : end - start);
    if (!dir.empty()) {
      const std::filesystem::path candidate = std::filesystem::path(dir) / cc;
      if (std::filesystem::exists(candidate, ec)) {
        return true;
      }
    }
    if (end == std::string::npos) {
      break;
    }
    start = end + 1;
  }
  return false;
}

std::string resolve_link_cc() {
  if (const char* cc_env = std::getenv("CC"); cc_env != nullptr && *cc_env != '\0') {
    return cc_env;
  }
  if (const char* major_env = std::getenv("LI_LLVM_MAJOR"); major_env != nullptr &&
      *major_env != '\0') {
    const std::string versioned = std::string("clang-") + major_env;
    if (clang_executable_exists(versioned)) {
      return versioned;
    }
  }
#if defined(LLVM_VERSION_MAJOR)
  const std::string versioned = "clang-" + std::to_string(LLVM_VERSION_MAJOR);
  if (clang_executable_exists(versioned)) {
    return versioned;
  }
#endif
  return "clang";
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
  std::string ll_path;
  const char* emit_ll = std::getenv("LI_EMIT_LL");
  if (emit_ll && emit_ll[0]) {
    ll_path = emit_ll;
  } else {
    ll_path = unique_temp_ll_path();
  }

  if (!emit_llvm_ir(mir, ll_path, opts.runtime_team_size, error)) {
    return false;
  }

  if (is_null_output_path(output_path)) {
    maybe_keep_emit_ll(ll_path);
    if (!emit_ll || !emit_ll[0]) {
      std::filesystem::remove(ll_path);
    }
    return true;
  }

  if (!is_safe_link_path(output_path)) {
    if (error) {
      *error = "unsafe characters in output path";
    }
    if (!emit_ll || !emit_ll[0]) {
      std::filesystem::remove(ll_path);
    }
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
  const std::filesystem::path rt_par_pool_path = resolve_runtime_c("li_par_pool.c");
  const std::filesystem::path rt_httpd_path = resolve_runtime_c("li_rt_httpd.c");
  const std::filesystem::path rt_log_path = resolve_runtime_c("li_rt_log.c");
  const std::filesystem::path rt_net_path = resolve_runtime_c("li_rt_net.c");
  const std::filesystem::path rt_tls_path = resolve_runtime_c("li_rt_tls.c");
  const std::filesystem::path rt_h2_path = resolve_runtime_c("li_rt_h2.c");
  const std::filesystem::path rt_llm_path = resolve_runtime_c("li_rt_llm.c");
  const std::filesystem::path rt_inference_sse_path = resolve_runtime_c("li_rt_inference_sse.c");

  MirModule rt_needs;
  mir_collect_runtime_link_needs(mir, rt_needs);
  mir_finalize_runtime_link_needs(rt_needs);
  const bool link_runtime_full =
      std::getenv("LI_LINK_RUNTIME_FULL") != nullptr && *std::getenv("LI_LINK_RUNTIME_FULL") != '0';
  const std::filesystem::path rt_lig_path = resolve_runtime_c("li_rt_lig.c");

  std::ostringstream cmd;
  const std::string cc = resolve_link_cc();
  cmd << cc << " -Wno-override-module";
#if defined(LLVM_VERSION_MAJOR) && LLVM_VERSION_MAJOR >= 15
  cmd << " -opaque-pointers";
#endif
  cmd << " -x ir \"" << ll_path << "\" -x c \"" << rt_path.string() << "\"";
  if (std::filesystem::exists(rt_par_pool_path)) {
    cmd << " -x c \"" << rt_par_pool_path.string() << "\"";
  }
  if (link_runtime_full || rt_needs.needs_rt_httpd) {
    if (std::filesystem::exists(rt_httpd_path)) {
      cmd << " -x c \"" << rt_httpd_path.string() << "\"";
    }
  }
  if (link_runtime_full || rt_needs.needs_rt_log) {
    if (std::filesystem::exists(rt_log_path)) {
      cmd << " -x c \"" << rt_log_path.string() << "\"";
    }
  }
  if (link_runtime_full || rt_needs.needs_rt_net) {
    if (std::filesystem::exists(rt_net_path)) {
      cmd << " -x c \"" << rt_net_path.string() << "\"";
    }
    if (std::filesystem::exists(rt_tls_path)) {
      cmd << " -x c \"" << rt_tls_path.string() << "\"";
    }
    if (std::filesystem::exists(rt_h2_path)) {
      cmd << " -x c \"" << rt_h2_path.string() << "\"";
    }
  }
  if (std::filesystem::exists(rt_lig_path)) {
    cmd << " -x c \"" << rt_lig_path.string() << "\"";
  }
  if (link_runtime_full || rt_needs.needs_rt_llm) {
    if (std::filesystem::exists(rt_llm_path)) {
      cmd << " -x c \"" << rt_llm_path.string() << "\"";
    }
    if (std::filesystem::exists(rt_inference_sse_path)) {
      cmd << " -x c \"" << rt_inference_sse_path.string() << "\"";
    }
  }
  const std::filesystem::path rt_studio_paint_path = resolve_runtime_c("li_rt_studio_paint_capture.c");
  if (std::filesystem::exists(rt_studio_paint_path)) {
    cmd << " -x c \"" << rt_studio_paint_path.string() << "\"";
  }
  const std::filesystem::path rt_studio_headless_path =
      resolve_runtime_c("li_rt_studio_headless_raster.c");
  if (std::filesystem::exists(rt_studio_headless_path)) {
    cmd << " -x c \"" << rt_studio_headless_path.string() << "\"";
  }
  const std::filesystem::path rt_studio_demo_path =
      resolve_runtime_c("li_rt_studio_demo_recorder.c");
  if (std::filesystem::exists(rt_studio_demo_path)) {
    cmd << " -x c \"" << rt_studio_demo_path.string() << "\"";
  }
  cmd << " -o \"" << output_path << "\"";
  if (opts.release) {
    cmd << " -O3 -march=native";
    if (!opts.fp_numerically_stable) {
      cmd << " -ffast-math -ffp-contract=fast";
    }
  }
  if (opts.fp_numerically_stable) {
    cmd << " -fno-fast-math -ffp-contract=off";
  }
  if (!extra_clang_flags.empty()) {
    cmd << " " << extra_clang_flags;
  }
  if (mir.uses_openmp || std::filesystem::exists(rt_par_pool_path)) {
#if defined(__linux__) || defined(__APPLE__)
    cmd << " -pthread";
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
          if (!emit_ll || !emit_ll[0]) {
            std::filesystem::remove(ll_path);
          }
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
  cmd << " -lm -ldl";
#elif defined(__APPLE__)
  cmd << " -lm";
#endif
#if defined(_WIN32)
  if (link_runtime_full || rt_needs.needs_rt_net) {
    cmd << " -lws2_32";
  }
#endif
  const int rc = std::system(cmd.str().c_str());
  maybe_keep_emit_ll(ll_path);
  if (!emit_ll || !emit_ll[0]) {
    std::filesystem::remove(ll_path);
  }
  if (rc != 0) {
    if (error) {
      *error = "clang link failed";
    }
    return false;
  }
  return true;
}

}  // namespace li
