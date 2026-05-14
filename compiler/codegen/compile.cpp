#include "li/compile.hpp"
#include "li/emit.hpp"
#include "li/mir.hpp"

#include <cstdlib>
#include <filesystem>
#include <sstream>
#include <unistd.h>

namespace li {

bool compile_module(const Module& module, const std::string& output_path, bool release,
                  std::string* error) {
  const MirModule mir = lower_to_mir(module);
  const std::string ll_path =
      (std::filesystem::temp_directory_path() /
       ("li_build_" + std::to_string(getpid()) + ".ll"))
          .string();

  if (!emit_llvm_ir(mir, ll_path, error)) {
    return false;
  }

  if (output_path == "/dev/null") {
    std::filesystem::remove(ll_path);
    return true;
  }

  std::filesystem::path rt_path = std::filesystem::path("runtime") / "li_rt.c";
  if (!std::filesystem::exists(rt_path)) {
    rt_path = std::filesystem::path("..") / "runtime" / "li_rt.c";
  }

  std::ostringstream cmd;
  cmd << "clang -Wno-override-module -x ir \"" << ll_path << "\" -x c \""
      << rt_path.string() << "\" -o \"" << output_path << "\"";
  if (release) {
    cmd << " -O2";
  }
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
