#include "li/check_cmd.hpp"

#include "li/advisory.hpp"
#include "li/check_config.hpp"
#include "li/import_resolve.hpp"
#include "li/parser.hpp"
#include "li/policy.hpp"
#include "li/prelude.hpp"
#include "li/typecheck.hpp"

#include <fstream>
#include <iostream>
#include <sstream>
#include <string_view>

namespace li {
namespace {

enum class DiagOutput { Human, Json };

std::string read_file(const char* path) {
  std::ifstream in(path);
  std::ostringstream ss;
  ss << in.rdbuf();
  return ss.str();
}

void append_diagnostic(DiagnosticBag& out, const Diagnostic& d) {
  const std::string hint = d.hint ? *d.hint : std::string{};
  if (d.severity == DiagnosticSeverity::Error) {
    if (!d.code.empty()) {
      out.error(d.loc, d.code, d.message, hint);
    } else {
      out.error(d.loc, d.message);
    }
  } else if (d.severity == DiagnosticSeverity::Warning) {
    out.warning(d.loc, d.code, d.message, hint);
  } else {
    out.note(d.loc, d.code, d.message, hint);
  }
}

int check_exit_code(const DiagnosticBag& diags, bool deny_warnings) {
  if (diags.has_errors()) {
    return 1;
  }
  if (deny_warnings && diags.has_warnings()) {
    return 1;
  }
  return 0;
}

int check_file(const char* path, DiagOutput output, std::string_view json_command,
               bool deny_warnings) {
  const std::string source = read_file(path);
  Module module;
  DiagnosticBag diags;
  FrontendCheckOptions options;
  options.deny_warnings = deny_warnings;
  if (!run_frontend_check(path, source, module, diags, options)) {
    if (output == DiagOutput::Json) {
      print_diagnostics_json(diags, std::cout, json_command);
    } else {
      print_diagnostics(diags);
    }
    return 1;
  }
  if (output == DiagOutput::Json) {
    print_diagnostics_json(diags, std::cout, json_command);
  }
  return check_exit_code(diags, deny_warnings);
}

}  // namespace

bool run_frontend_check(const char* path, const std::string& source, Module& out,
                        DiagnosticBag& diags, const FrontendCheckOptions& options) {
  const CheckConfig cfg = load_check_config(path);
  const AdvisoryOptions advisory_opts{cfg};

  check_source_policies(source, path, cfg, diags);
  if (diags.has_errors()) {
    return false;
  }

  auto parsed = parse_module(source, path);
  for (const auto& d : parsed.diagnostics.items()) {
    append_diagnostic(diags, d);
  }
  if (!parsed.module) {
    return false;
  }

  check_stdlib_seal(*parsed.module, path, diags);
  if (diags.has_errors()) {
    return false;
  }
  if (!resolve_imports(*parsed.module, path, diags)) {
    return false;
  }
  check_module_policies(*parsed.module, path, diags);
  if (diags.has_errors()) {
    return false;
  }
  check_duplicate_definitions(*parsed.module, path, diags);
  if (diags.has_errors()) {
    return false;
  }

  auto checked = typecheck_module(*parsed.module);
  for (const auto& d : checked.diagnostics.items()) {
    append_diagnostic(diags, d);
  }
  if (!checked.ok) {
    return false;
  }

  run_advisory_passes(*parsed.module, path, advisory_opts, diags);
  if (options.deny_warnings && diags.has_warnings()) {
    SourceLoc loc{path, 1, 1, 0};
    diags.error(loc, "warnings denied by --deny-warnings");
    return false;
  }
  out = std::move(*parsed.module);
  return true;
}

int lic_check_main(int argc, char** argv) {
  if (argc < 3) {
    std::cerr << "usage: lic check <file> [--format=json] [--deny-warnings]\n";
    return 1;
  }
  const char* path = nullptr;
  DiagOutput output = DiagOutput::Human;
  bool deny_warnings = false;
  for (int i = 2; i < argc; ++i) {
    const std::string_view arg = argv[i];
    if (arg == "--format=json") {
      output = DiagOutput::Json;
    } else if (arg == "--deny-warnings") {
      deny_warnings = true;
    } else if (path == nullptr) {
      path = argv[i];
    } else {
      std::cerr << "usage: lic check <file> [--format=json] [--deny-warnings]\n";
      return 1;
    }
  }
  if (path == nullptr) {
    std::cerr << "usage: lic check <file> [--format=json] [--deny-warnings]\n";
    return 1;
  }
  return check_file(path, output, "check", deny_warnings);
}

int lic_diagnose_main(int argc, char** argv) {
  if (argc < 3) {
    std::cerr << "usage: lic diagnose <file>\n";
    return 1;
  }
  return check_file(argv[2], DiagOutput::Json, "diagnose", false);
}

}  // namespace li
