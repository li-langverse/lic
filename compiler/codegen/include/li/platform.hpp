#pragma once

#include <cstddef>
#include <cstdlib>
#include <string>
#include <thread>

namespace li {

/// Repo root from LI_REPO_ROOT (may be empty).
inline std::string repo_root_from_env() {
  if (const char* root = std::getenv("LI_REPO_ROOT")) {
    return root;
  }
  return {};
}

/// Build tree: LI_BUILD_DIR when set, else $LI_REPO_ROOT/build, else "build".
inline std::string repo_build_prefix() {
  if (const char* dir = std::getenv("LI_BUILD_DIR")) {
    return dir;
  }
  const std::string root = repo_root_from_env();
  if (!root.empty()) {
    return root + "/build";
  }
  return "build";
}

/// Path under the active build tree (e.g. "generated/AutoVC.lean").
inline std::string repo_build_path(const char* relative) {
  std::string prefix = repo_build_prefix();
  if (relative == nullptr || relative[0] == '\0') {
    return prefix;
  }
  if (prefix.empty() || prefix.back() != '/') {
    prefix += '/';
  }
  prefix += relative;
  return prefix;
}

/// Host CPU count for tool defaults (LI_BUILD_JOBS / lic --jobs).
inline unsigned default_host_jobs() {
  if (const char* env = std::getenv("LI_BUILD_JOBS")) {
    const int n = std::atoi(env);
    if (n > 0) {
      return static_cast<unsigned>(n);
    }
  }
  const unsigned hc = std::thread::hardware_concurrency();
  return hc > 0 ? hc : 1u;
}

/// Optional compile-time memory budget (MB); 0 = unset.
inline std::size_t max_memory_mb_from_env() {
  if (const char* env = std::getenv("LI_MAX_MEMORY_MB")) {
    const int n = std::atoi(env);
    if (n > 0) {
      return static_cast<std::size_t>(n);
    }
  }
  return 0;
}


/// Discard-linked build output (POSIX /dev/null, Windows NUL).
inline constexpr const char* null_output_path() {
#if defined(_WIN32)
  return "NUL";
#else
  return "/dev/null";
#endif
}

inline bool is_null_output_path(const std::string& path) {
#if defined(_WIN32)
  return path == "NUL" || path == "nul";
#else
  return path == "/dev/null";
#endif
}

/// Reject shell metacharacters in paths passed to std::system via clang link.
inline bool is_safe_link_path(const std::string& path) {
  if (path.empty()) {
    return false;
  }
  for (char c : path) {
    if (c == ';' || c == '|' || c == '&' || c == '$' || c == '`' || c == '\n' ||
        c == '\r' || c == '"' || c == '\'') {
      return false;
    }
#if defined(_WIN32)
    if (c == '^' || c == '%' || c == '<' || c == '>') {
      return false;
    }
#endif
  }
  if (path.find("$(") != std::string::npos || path.find("${") != std::string::npos) {
    return false;
  }
  return true;
}

}  // namespace li
