#pragma once

#include <string>

namespace li {

struct SmokeKernelOptions {
  std::string elf_path;
  int timeout_sec = 10;
  /** Optional gate stub: virtio-mmio | mm-bump (maps MMIO + serial marker). */
  std::string stub;
};

bool smoke_kernel(const SmokeKernelOptions& opts, std::string* error = nullptr);

}  // namespace li
