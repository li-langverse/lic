#include "li/smoke_kernel.hpp"

#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <filesystem>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>

namespace li {
namespace {

bool file_exists(const std::filesystem::path& path) {
  std::error_code ec;
  return std::filesystem::is_regular_file(path, ec);
}

bool looks_like_elf32(const std::filesystem::path& path) {
  std::ifstream in(path, std::ios::binary);
  if (!in) {
    return false;
  }
  unsigned char hdr[5] = {};
  in.read(reinterpret_cast<char*>(hdr), sizeof(hdr));
  return in.gcount() == static_cast<std::streamsize>(sizeof(hdr)) && hdr[0] == 0x7F &&
         hdr[1] == 'E' && hdr[2] == 'L' && hdr[3] == 'F' && hdr[4] == 1;
}

std::string shell_quote(const std::string& value) {
  std::string out = "'";
  for (char ch : value) {
    if (ch == '\'') {
      out += "'\\''";
    } else {
      out += ch;
    }
  }
  out += "'";
  return out;
}

std::vector<std::filesystem::path> qemu_candidates() {
  return {
      std::filesystem::path("/opt/qemu/usr/libexec/qemu-system-i386"),
      std::filesystem::path("/opt/qemu/usr/bin/qemu-system-i386"),
      std::filesystem::path("qemu-system-i386"),
      std::filesystem::path("qemu-system-x86_64"),
  };
}

std::filesystem::path resolve_qemu() {
  if (const char* env = std::getenv("LIOS_QEMU"); env != nullptr && *env != '\0') {
    const std::filesystem::path from_env(env);
    if (file_exists(from_env)) {
      return from_env;
    }
  }
  for (const auto& candidate : qemu_candidates()) {
    if (candidate.is_absolute() && file_exists(candidate)) {
      return candidate;
    }
    if (!candidate.is_absolute()) {
      const std::string cmd = "command -v " + candidate.string() + " 2>/dev/null";
      if (FILE* pipe = popen(cmd.c_str(), "r")) {
        char buf[512] = {};
        if (fgets(buf, sizeof(buf), pipe) != nullptr) {
          const std::string resolved = buf;
          pclose(pipe);
          const std::size_t end = resolved.find_first_of("\r\n");
          const std::string trimmed = resolved.substr(0, end);
          if (!trimmed.empty() && file_exists(trimmed)) {
            return trimmed;
          }
        } else {
          pclose(pipe);
        }
      }
    }
  }
  return {};
}

bool run_qemu_serial_smoke(const SmokeKernelOptions& opts, std::string* captured,
                           std::string* error) {
  if (!file_exists(opts.elf_path)) {
    if (error) {
      *error = "missing kernel ELF: " + opts.elf_path;
    }
    return false;
  }
  if (!looks_like_elf32(opts.elf_path)) {
    if (error) {
      *error = "expected ELF32 kernel: " + opts.elf_path;
    }
    return false;
  }

  const std::filesystem::path qemu = resolve_qemu();
  if (qemu.empty()) {
    if (error) {
      *error = "qemu-system-i386 not found (install QEMU or set LIOS_QEMU=)";
    }
    return false;
  }

  std::ostringstream cmd;
  cmd << "timeout " << opts.timeout_sec << ' '
      << shell_quote(qemu.string()) << " -display none "
      << "-chardev stdio,id=s0 -device isa-serial,chardev=s0,iobase=0x3f8,irq=4 "
      << "-kernel " << shell_quote(opts.elf_path) << " 2>&1";

  FILE* pipe = popen(cmd.str().c_str(), "r");
  if (pipe == nullptr) {
    if (error) {
      *error = "failed to launch QEMU serial smoke";
    }
    return false;
  }

  char buf[4096];
  std::string output;
  while (fgets(buf, sizeof(buf), pipe) != nullptr) {
    output += buf;
  }
  const int rc = pclose(pipe);
  if (captured) {
    *captured = output;
  }

  if (output.find("hello_kern") != std::string::npos) {
    return true;
  }

  if (error) {
    std::ostringstream msg;
    msg << "serial smoke failed (QEMU rc=" << rc << ")";
    if (!output.empty()) {
      msg << ":\n" << output;
    }
    *error = msg.str();
  }
  return false;
}

}  // namespace

bool smoke_kernel(const SmokeKernelOptions& opts, std::string* error) {
  std::string captured;
  if (!run_qemu_serial_smoke(opts, &captured, error)) {
    return false;
  }
  if (!captured.empty()) {
    std::cout << captured;
    if (captured.back() != '\n') {
      std::cout << '\n';
    }
  }
  return true;
}

}  // namespace li
