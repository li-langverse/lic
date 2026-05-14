#include "li/parser.hpp"
#include "li/smoke_llvm.hpp"

#include <fstream>
#include <iostream>
#include <sstream>
#include <string>
#include <string_view>

namespace {

int usage() {
  std::cerr << "lic — Li compiler\n"
            << "usage:\n"
            << "  lic parse <file>    parse and validate syntax\n"
            << "  lic smoke-llvm      verify LLVM can emit main returning 0\n"
            << "  lic --version       print version\n";
  return 1;
}

std::string read_file(const char* path) {
  std::ifstream in(path);
  std::ostringstream ss;
  ss << in.rdbuf();
  return ss.str();
}

}  // namespace

int main(int argc, char** argv) {
  if (argc < 2) {
    return usage();
  }
  const std::string_view cmd = argv[1];
  if (cmd == "--version" || cmd == "-V") {
    std::cout << "lic 0.1.0\n";
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
  if (cmd == "parse") {
    if (argc < 3) {
      return usage();
    }
    const std::string source = read_file(argv[2]);
    auto result = li::parse_module(source, argv[2]);
    if (!result.ok()) {
      li::print_diagnostics(result.diagnostics);
      return 1;
    }
    return 0;
  }
  return usage();
}
