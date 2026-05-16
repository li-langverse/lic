#include "li/import_resolve.hpp"

#include "li/parser.hpp"
#include "li/prelude.hpp"

#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <sstream>

namespace li {
namespace {

std::string read_file(const std::filesystem::path& path) {
  std::ifstream in(path);
  std::ostringstream ss;
  ss << in.rdbuf();
  return ss.str();
}

std::filesystem::path std_root() {
  if (const char* root = std::getenv("LI_REPO_ROOT")) {
    return std::filesystem::path(root) / "std";
  }
  if (const char* std_path = std::getenv("LI_STD_PATH")) {
    return std::filesystem::path(std_path);
  }
  return std::filesystem::path("std");
}

std::filesystem::path module_to_path(const std::string& module) {
  std::string rest = module;
  if (rest.rfind("std.", 0) == 0) {
    rest = rest.substr(4);
  } else if (rest == "std") {
    rest.clear();
  }
  std::filesystem::path p = std_root();
  std::size_t i = 0;
  std::string last;
  while (i <= rest.size()) {
    const std::size_t dot = rest.find('.', i);
    const std::string seg =
        dot == std::string::npos ? rest.substr(i) : rest.substr(i, dot - i);
    if (!seg.empty()) {
      last = seg;
      p /= seg;
    }
    if (dot == std::string::npos) {
      break;
    }
    i = dot + 1;
  }
  if (!last.empty()) {
    p = p.parent_path() / (last + ".li");
  } else {
    p /= "lib.li";
  }
  return p;
}

void merge_module(Module& into, Module&& from) {
  for (auto& t : from.types) {
    into.types.push_back(std::move(t));
  }
  for (auto& p : from.procs) {
    into.procs.push_back(std::move(p));
  }
}

}  // namespace

bool resolve_imports(Module& out, const std::string& file_path, DiagnosticBag& diags) {
  const auto imports = out.imports;
  for (const auto& imp : imports) {
    if (imp.module.rfind("std.", 0) != 0 && imp.module != "std") {
      continue;
    }
    const std::filesystem::path mod_path = module_to_path(imp.module);
    if (!std::filesystem::exists(mod_path)) {
      SourceLoc loc{file_path, 1, 1, imp.span.start};
      diags.error(loc, "import_resolve: module not found: " + imp.module);
      continue;
    }
    const std::string source = read_file(mod_path);
    auto parsed = parse_module(source, mod_path.string());
    for (const auto& d : parsed.diagnostics.items()) {
      diags.error(d.loc, d.message);
    }
    if (!parsed.module) {
      continue;
    }
    merge_module(out, std::move(*parsed.module));
  }
  return diags.empty();
}

}  // namespace li
