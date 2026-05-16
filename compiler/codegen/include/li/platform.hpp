#pragma once

#include <string>

namespace li {

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

}  // namespace li
