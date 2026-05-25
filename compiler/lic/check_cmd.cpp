#include "li/check_cmd.hpp"

#include "li/check_cache.hpp"
#include "li/import_resolve.hpp"
#include "li/parser.hpp"
#include "li/policy.hpp"
#include "li/prelude.hpp"
#include "li/typecheck.hpp"

#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <sstream>

namespace li {

namespace {

std::string read_file(const char* path) {
  std::ifstream in(path);
  std::ostringstream ss;
  ss << in.rdbuf();
  return ss.str();
}

bool parse_check_cache_flag(std::string_view arg, CheckOptions& opts) {
  if (arg == "--no-cache") {
    opts.cache.no_cache = true;
    return true;
  }
  if (arg.rfind("--cache-dir=", 0) == 0) {
    opts.cache.cache_dir = std::string(arg.substr(12));
    return true;
  }
  if (arg.rfind("--cache-max-mb=", 0) == 0) {
    const int n = std::atoi(arg.substr(15).data());
    if (n > 0) {
      opts.cache.cache_max_mb = static_cast<std::size_t>(n);
    }
    return true;
  }
  return false;
}

}  // namespace

bool run_frontend_check(const char* path, const CheckOptions& /*options*/, DiagnosticBag& diags,
                        Module* out_module) {
  const std::string source = read_file(path);
  check_source_policies(source, path, diags);
  if (!diags.empty()) {
    return false;
  }
  auto parsed = parse_module(source, path);
  for (const auto& d : parsed.diagnostics.items()) {
    diags.error(d.loc, d.message);
  }
  if (!parsed.module) {
    return false;
  }
  check_stdlib_seal(*parsed.module, path, diags);
  if (!diags.empty()) {
    return false;
  }
  if (!resolve_imports(*parsed.module, path, diags)) {
    return false;
  }
  check_module_policies(*parsed.module, path, diags);
  if (!diags.empty()) {
    return false;
  }
  check_duplicate_definitions(*parsed.module, path, diags);
  if (!diags.empty()) {
    return false;
  }
  auto checked = typecheck_module(*parsed.module);
  for (const auto& d : checked.diagnostics.items()) {
    if (!d.code.empty()) {
      diags.error(d.loc, d.code, d.message, d.hint ? *d.hint : std::string{});
    } else {
      diags.error(d.loc, d.message);
    }
  }
  if (!checked.ok) {
    return false;
  }
  if (out_module) {
    *out_module = std::move(*parsed.module);
  }
  return true;
}

int lic_check_main(int argc, char** argv) {
  const char* path = nullptr;
  bool format_json = false;
  CheckOptions options;
  for (int i = 2; i < argc; ++i) {
    const std::string_view arg = argv[i];
    if (arg == "--format=json") {
      format_json = true;
    } else if (arg == "--deny-warnings") {
      options.deny_warnings = true;
    } else if (parse_check_cache_flag(arg, options)) {
      continue;
    } else if (path == nullptr) {
      path = argv[i];
    } else {
      return 1;
    }
  }
  if (path == nullptr) {
    return 1;
  }

  DiagnosticBag diags;
  CheckCache cache(options.cache);
  const std::filesystem::path src_path(path);
  std::ostringstream cached_json;
  if (const auto hit = cache.try_load(src_path, check_config_hash_v1(), cached_json)) {
    if (format_json) {
      std::cout << cached_json.str();
    }
    return *hit;
  }

  const bool ok = run_frontend_check(path, options, diags, nullptr);
  const int exit_code = ok ? 0 : 1;
  if (format_json) {
    print_diagnostics_json(diags, std::cout, "check");
  } else if (!ok) {
    print_diagnostics(diags);
  }
  cache.store(src_path, check_config_hash_v1(), diags, exit_code);
  return exit_code;
}

int lic_diagnose_main(int argc, char** argv) {
  if (argc < 3) {
    return 1;
  }
  CheckOptions options;
  for (int i = 3; i < argc; ++i) {
    parse_check_cache_flag(argv[i], options);
  }
  DiagnosticBag diags;
  (void)run_frontend_check(argv[2], options, diags, nullptr);
  print_diagnostics_json(diags, std::cout, "diagnose");
  return diags.empty() ? 0 : 1;
}

}  // namespace li
