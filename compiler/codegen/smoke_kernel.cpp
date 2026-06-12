#include "li/smoke_kernel.hpp"
#include "smoke_kernel_i686.hpp"

#include <fstream>
#include <iostream>
#include <vector>

namespace li {
namespace {

std::vector<uint8_t> read_file_bytes(const std::string& path) {
  std::ifstream in(path, std::ios::binary);
  return std::vector<uint8_t>((std::istreambuf_iterator<char>(in)), std::istreambuf_iterator<char>());
}

bool serial_passes(const smoke_i686::Cpu& cpu, const std::string& stub) {
  if (stub == "virtio-mmio") {
    return cpu.serial.find("virtio-mmio:blk-read-ok") != std::string::npos;
  }
  if (stub == "mm-bump") {
    return cpu.serial.find("mm:bump:ok") != std::string::npos;
  }
  return cpu.serial.find("hello_kern") != std::string::npos;
}

const char* pass_label(const std::string& stub) {
  if (stub == "virtio-mmio") {
    return "virtio-mmio on COM1";
  }
  if (stub == "mm-bump") {
    return "mm:bump on COM1";
  }
  return "hello_kern on COM1";
}

}  // namespace

bool smoke_kernel(const SmokeKernelOptions& opts, std::string* error) {
  const std::vector<uint8_t> image = read_file_bytes(opts.elf_path);
  if (image.empty()) {
    if (error) {
      *error = "missing or empty kernel ELF: " + opts.elf_path;
    }
    return false;
  }

  smoke_i686::Memory mem;
  uint32_t entry = 0;
  if (!smoke_i686::load_elf32(image, &mem, &entry, error)) {
    return false;
  }

  smoke_i686::seed_stub_regions(&mem, opts.stub);

  smoke_i686::Cpu cpu;
  cpu.eip = entry;
  cpu.esp = smoke_i686::choose_stack_top(mem, entry) - 16;
  cpu.max_steps = static_cast<uint64_t>(opts.timeout_sec) * 100000ULL;
  if (cpu.max_steps < 100000ULL) {
    cpu.max_steps = 100000ULL;
  }

  mem.map(cpu.esp & ~0xFFFu, nullptr, 0, 0x4000);

  if (!smoke_i686::run(&cpu, &mem, opts.stub, error)) {
    if (!serial_passes(cpu, opts.stub)) {
      if (error && error->empty()) {
        std::string expect = "hello_kern on COM1 (0x3F8)";
        if (opts.stub == "virtio-mmio") {
          expect = "virtio-mmio:blk-read-ok on COM1";
        } else if (opts.stub == "mm-bump") {
          expect = "mm:bump:ok on COM1";
        }
        *error = "serial smoke failed — expected " + expect;
      }
      return false;
    }
  }

  if (!cpu.serial.empty()) {
    std::cout << cpu.serial;
    if (cpu.serial.back() != '\n') {
      std::cout << '\n';
    }
  }

  if (error) {
    error->clear();
    *error = pass_label(opts.stub);
  }
  return true;
}

}  // namespace li
