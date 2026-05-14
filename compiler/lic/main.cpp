#include "li/smoke_llvm.hpp"

#include <cstdlib>
#include <iostream>
#include <string_view>

namespace {

int usage() {
  std::cerr << "lic — Li compiler (bootstrap)\n"
            << "usage:\n"
            << "  lic smoke-llvm   verify LLVM can emit main returning 0\n"
            << "  lic --version    print version\n";
  return 1;
}

}  // namespace

int main(int argc, char** argv) {
  if (argc < 2) {
    return usage();
  }
  const std::string_view cmd = argv[1];
  if (cmd == "--version" || cmd == "-V") {
    std::cout << "lic 0.1.0 (phase 0 bootstrap)\n";
    return 0;
  }
  if (cmd == "smoke-llvm") {
    std::string err;
    if (!li::smoke_llvm(&err)) {
      std::cerr << "smoke-llvm failed: " << err << '\n';
      return 1;
    }
    std::cout << "smoke-llvm: ok (main returns 0)\n";
    return 0;
  }
  return usage();
}
