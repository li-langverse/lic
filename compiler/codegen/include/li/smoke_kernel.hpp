#pragma once

#include <string>

namespace li {

struct SmokeKernelOptions {
  std::string elf_path;
  int timeout_sec = 10;
};

bool smoke_kernel(const SmokeKernelOptions& opts, std::string* error = nullptr);

}  // namespace li
