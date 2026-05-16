#include "li/prelude.hpp"

#include <set>
#include <string>
#include <string_view>

namespace li {
namespace {

bool in_set(std::string_view name, std::initializer_list<const char*> names) {
  for (const char* n : names) {
    if (n == nullptr) {
      break;
    }
    if (name == n) {
      return true;
    }
  }
  return false;
}

}  // namespace

bool is_prelude_type_name(const std::string_view name) {
  return in_set(name, {"int",   "float", "bool", "str",  "unit", "int64",
                       "list",  "dict",  "tuple", "Option", "simd",
                       "bytes", "stringview", nullptr});
}

bool is_prelude_proc_name(const std::string_view name) {
  return in_set(name, {"echo", "sum", nullptr});
}

bool is_reserved_decorator_name(const std::string_view name) {
  return in_set(name, {"cpu",          "gpu",          "tpu",          "user_defined",
                       "parallel",     "vectorized",   "async",        "serial",
                       "no_vectorize", nullptr});
}

bool is_std_module_symbol(const std::string_view name) {
  // Sync with std/**/*.li top-level symbols (see scripts/gen-stdlib-manifest.sh).
  return in_set(name, {"__execution_decorators_doc", "Bytes", "StringView", "Reader",
                       "Writer", "bytes_len", "bytes_slice", nullptr});
}

void check_duplicate_definitions(const Module& module, const std::string& file,
                                 DiagnosticBag& diags) {
  std::set<std::string> seen_procs;
  std::set<std::string> seen_types;
  auto report = [&](const Span& span, const std::string& msg) {
    diags.error(SourceLoc{file, 1, 1, span.start}, msg);
  };
  for (const auto& alias : module.types) {
    if (seen_types.count(alias.name)) {
      report(alias.span, "duplicate_definition: " + alias.name);
    }
    seen_types.insert(alias.name);
  }
  for (const auto& proc : module.procs) {
    if (seen_procs.count(proc.name)) {
      report(proc.span, "duplicate_definition: " + proc.name);
    }
    seen_procs.insert(proc.name);
  }
}

void check_stdlib_seal(const Module& module, const std::string& file,
                       DiagnosticBag& diags) {
  auto report = [&](const Span& span, const std::string& msg) {
    diags.error(SourceLoc{file, 1, 1, span.start}, msg);
  };
  const bool defining_std =
      file.find("/std/") != std::string::npos || file.find("\\std\\") != std::string::npos ||
      (file.size() >= 4 && file.compare(0, 4, "std/") == 0);

  for (const auto& alias : module.types) {
    if (is_prelude_type_name(alias.name)) {
      report(alias.span, "stdlib_symbol_shadow: " + alias.name);
    }
    if (!defining_std && is_std_module_symbol(alias.name)) {
      report(alias.span, "stdlib_symbol_shadow: " + alias.name);
    }
  }

  for (const auto& proc : module.procs) {
    if (is_prelude_proc_name(proc.name)) {
      report(proc.span, "stdlib_symbol_shadow: " + proc.name);
    }
    if (!defining_std && is_std_module_symbol(proc.name)) {
      report(proc.span, "stdlib_symbol_shadow: " + proc.name);
    }
    if (is_prelude_type_name(proc.name)) {
      report(proc.span, "stdlib_symbol_shadow: " + proc.name);
    }
  }
}

}  // namespace li
