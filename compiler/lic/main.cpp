#include "li/compile.hpp"
#include "li/parser.hpp"
#include "li/platform.hpp"
#include "li/policy.hpp"
#include "li/import_resolve.hpp"
#include "li/prelude.hpp"
#include "li/smoke_llvm.hpp"
#include "li/typecheck.hpp"
#include "li/vc_emit.hpp"
#include "li/mir.hpp"
#include "li/vc_summary.hpp"
#include "li/vc_witness.hpp"
#include "li/terminal.hpp"
#include "li/error_codes.hpp"
#include "li/proof_cli.hpp"

#include "li_rt.h"

#include <cstdio>
#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>
#include <string_view>

namespace {

int usage() {
  const unsigned jobs = li::default_host_jobs();
  li::print_lic_banner(std::cerr);
  std::cerr << li::styled_accent("lic") << li::styled_dim(" — prove · write · run fast") << li::reset_style()
            << "\nusage:\n"
            << "  lic parse <file>       parse and validate syntax\n"
            << "  lic check <file> [--format=json]  parse + typecheck\n"
            << "  lic diagnose <file>    agent-oriented JSON diagnostics\n"
            << "  lic verify <file>      VC summary; --lean lake; --strict-lean fails open VCs\n"
            << "                       [--allow-open-vc] [--no-lean-verify]\n"
            << "  lic build <file> -o <out> [--release] [--numerically-stable]\n"
            << "                       [--strict-lean]  fail on open AutoVC goals + lake strict check\n"
            << "                       [--allow-open-vc]  allow obligations without Lean proof (dev only)\n"
            << "                       [--no-lean-verify] skip lake / AutoVC typecheck\n"
            << "                       default: fail on open goals; lake typecheck when installed\n"
            << "                       [--threads=N] [--jobs=N] [--max-memory=MB]\n"
            << "                       [--coverage-instrument]\n"
            << "  lic smoke-llvm         verify LLVM can emit main returning 0\n"
            << "  lic httpd explain-config <file.toml>  desugar [routes] to canonical form\n"
            << "  lic httpd validate-config <file.toml>  validate [routes] (E0501–E0504)\n"
            << "  lic validate-httpd-config <file.toml>  M1 TOML schema + overlap (Python)\n"
            << "  lic --version          print version\n"
            << "\n"
            << "resource defaults (override via flags or env):\n"
            << "  --jobs=N / LI_COMPILE_JOBS / LI_BUILD_JOBS (host=" << jobs
            << ") — reserved for parallel frontend\n"
            << "  --max-memory=MB / LI_MAX_MEMORY_MB — reserved memory budget\n"
            << "  --threads=N / LI_OMP_THREADS — OpenMP team size at run time\n"
            << "  --numerically-stable / LI_FP_NUMERICALLY_STABLE=1 — cancellation-safe FP\n";
  return 1;
}

std::filesystem::path resolve_httpd_config_script() {
  if (const char* root = std::getenv("LI_REPO_ROOT")) {
    const std::filesystem::path p =
        std::filesystem::path(root) / "scripts" / "httpd_config.py";
    if (std::filesystem::exists(p)) {
      return p;
    }
  }
  const std::filesystem::path candidates[] = {
      std::filesystem::path("scripts/httpd_config.py"),
      std::filesystem::path("../scripts/httpd_config.py"),
  };
  for (const auto& c : candidates) {
    if (std::filesystem::exists(c)) {
      return std::filesystem::absolute(c);
    }
  }
  return {};
}

static li::ErrorCode httpd_error_kind_to_code(int32_t kind) {
  switch (kind) {
    case 1:
      return li::ErrorCode::E0501;
    case 2:
      return li::ErrorCode::E0502;
    case 3:
      return li::ErrorCode::E0503;
    case 4:
      return li::ErrorCode::E0504;
    default:
      return li::ErrorCode::E0502;
  }
}

int httpd_validate_config(int argc, char** argv) {
  if (argc < 4 || std::string_view(argv[2]) != "validate-config") {
    std::cerr << "usage: lic httpd validate-config <config.toml>\n";
    return 1;
  }
  const char* path = argv[3];
  if (li_rt_httpd_load_config(path) != 0) {
    const int32_t kind = li_rt_httpd_last_error_kind();
    const char* msg = li_rt_httpd_last_error_message();
    const auto code = httpd_error_kind_to_code(kind);
    const auto fd = li::format_diagnostic(code, msg ? msg : "config error",
                                        "fix [routes] keys or paths; see docs/ecosystem/httpd-prerequisites.md");
    std::cerr << path << ":1:1: " << li::styled_error_label() << " [" << fd.code << "]: " << fd.message;
    if (!fd.hint.empty()) {
      std::cerr << "\n  hint: " << fd.hint;
    }
    std::cerr << '\n';
    return 1;
  }
  std::cout << "OK: " << li_rt_httpd_route_count() << " routes\n";
  return 0;
}

int validate_httpd_config_cmd(int argc, char** argv) {
  if (argc < 3) {
    std::cerr << "usage: lic validate-httpd-config <config.toml>\n";
    return 1;
  }
  std::filesystem::path repo = std::filesystem::current_path();
  if (const char* root = std::getenv("LI_REPO_ROOT")) {
    repo = root;
  }
  const std::filesystem::path script = repo / "scripts/validate-httpd-config.py";
  if (!std::filesystem::is_regular_file(script)) {
    std::cerr << "validate-httpd-config: missing " << script << " (set LI_REPO_ROOT)\n";
    return 1;
  }
  std::ostringstream cmd;
  cmd << "python3 " << script.string() << " " << argv[2];
  const int st = std::system(cmd.str().c_str());
  return st != 0 ? 1 : 0;
}

int httpd_explain_config(int argc, char** argv) {
  if (argc < 4 || std::string_view(argv[2]) != "explain-config") {
    std::cerr << "usage: lic httpd explain-config <config.toml>\n";
    return 1;
  }
  const std::filesystem::path script = resolve_httpd_config_script();
  if (script.empty()) {
    std::cerr << "lic: cannot find scripts/httpd_config.py (set LI_REPO_ROOT)\n";
    return 1;
  }
  std::ostringstream cmd;
  cmd << "python3 \"" << script.string() << "\" \"" << argv[3] << "\" --explain";
  const int rc = std::system(cmd.str().c_str());
  if (rc != 0) {
    return 1;
  }
  return 0;
}

bool apply_resource_flag(std::string_view arg) {
  if (arg.rfind("--jobs=", 0) == 0) {
    setenv("LI_COMPILE_JOBS", std::string(arg.substr(7)).c_str(), 1);
    return true;
  }
  if (arg.rfind("--max-memory=", 0) == 0) {
    setenv("LI_MAX_MEMORY_MB", std::string(arg.substr(13)).c_str(), 1);
    return true;
  }
  return false;
}

std::string read_file(const char* path) {
  std::ifstream in(path);
  std::ostringstream ss;
  ss << in.rdbuf();
  return ss.str();
}

bool frontend(const char* path, const std::string& source, li::Module& out,
              li::DiagnosticBag& diags) {
  li::check_source_policies(source, path, diags);
  if (!diags.empty()) {
    return false;
  }
  auto parsed = li::parse_module(source, path);
  for (const auto& d : parsed.diagnostics.items()) {
    diags.error(d.loc, d.message);
  }
  if (!parsed.module) {
    return false;
  }
  li::check_stdlib_seal(*parsed.module, path, diags);
  if (!diags.empty()) {
    return false;
  }
  if (!li::resolve_imports(*parsed.module, path, diags)) {
    return false;
  }
  li::check_module_policies(*parsed.module, path, diags);
  if (!diags.empty()) {
    return false;
  }
  li::check_duplicate_definitions(*parsed.module, path, diags);
  if (!diags.empty()) {
    return false;
  }
  auto checked = li::typecheck_module(*parsed.module);
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
  out = std::move(*parsed.module);
  return true;
}

enum class DiagOutput { Human, Json };

int check_file(const char* path, DiagOutput output, std::string_view json_command) {
  const std::string source = read_file(path);
  li::Module module;
  li::DiagnosticBag diags;
  if (!frontend(path, source, module, diags)) {
    if (output == DiagOutput::Json) {
      li::print_diagnostics_json(diags, std::cout, json_command);
    } else {
      li::print_diagnostics(diags);
    }
    return 1;
  }
  if (output == DiagOutput::Json) {
    li::print_diagnostics_json(diags, std::cout, json_command);
  }
  return 0;
}

void warn_deprecated_proof_env() {
  if (std::getenv("LI_ALLOW_OPEN_VC") != nullptr) {
    std::cerr << "lic: warning — LI_ALLOW_OPEN_VC is ignored; use --allow-open-vc on the command line\n";
  }
  if (const char* v = std::getenv("LI_BUILD_VERIFY_LEAN"); v != nullptr && v[0] == '0') {
    std::cerr << "lic: warning — LI_BUILD_VERIFY_LEAN=0 is ignored; use --no-lean-verify\n";
  }
  if (std::getenv("LI_BUILD_VERIFY_LEAN_STRICT") != nullptr) {
    std::cerr << "lic: warning — LI_BUILD_VERIFY_LEAN_STRICT is ignored; use --strict-lean\n";
  }
}

bool parse_proof_cli_flag(std::string_view arg) {
  if (arg == "--allow-open-vc") {
    li::proof_cli_flags().allow_open_vc = true;
    return true;
  }
  if (arg == "--no-lean-verify") {
    li::proof_cli_flags().no_lean_verify = true;
    return true;
  }
  return false;
}

bool lake_available() {
  return std::system("command -v lake >/dev/null 2>&1") == 0;
}

int run_lean_verify_script(bool check_open_goals) {
  const char* root = std::getenv("LI_REPO_ROOT");
  std::string script = "scripts/lean-verify-stub.sh";
  if (root != nullptr) {
    script = std::string(root) + "/" + script;
  }
  if (!lake_available()) {
    std::cerr << "lic build: warning — Lean 4 / lake not installed; skipping semantics proof "
                 "(install elan for full 2f gate)\n";
    return 0;
  }
  std::string cmd = "bash " + script;
  if (check_open_goals) {
    cmd += " --check-open-goals";
  }
  const int rc = std::system(cmd.c_str());
  if (rc != 0) {
    std::cerr << "lic build: Lean semantics verification failed (see docs/semantics)\n";
    return 1;
  }
  return 0;
}

int count_open_autovc_goals() {
  const char* root = std::getenv("LI_REPO_ROOT");
  std::string script = "scripts/check-autovc-open-goals.sh";
  if (root != nullptr) {
    script = std::string(root) + "/" + script;
  }
  const std::string autovc = li::repo_build_path("generated/AutoVC.lean");
  const std::string cmd = "bash \"" + script + "\" \"" + autovc + "\" 2>&1";
  FILE* pipe = popen(cmd.c_str(), "r");
  if (pipe == nullptr) {
    return -1;
  }
  char buf[256];
  std::string out;
  while (fgets(buf, sizeof(buf), pipe) != nullptr) {
    out += buf;
  }
  pclose(pipe);
  if (out.find("open obligation") != std::string::npos) {
    std::size_t i = 0;
    int count = 0;
    while ((i = out.find("open VC:", i)) != std::string::npos) {
      ++count;
      ++i;
    }
    return count;
  }
  return 0;
}

int verify_file(const char* path, bool run_lean, bool strict_lean) {
  const std::string source = read_file(path);
  li::Module module;
  li::DiagnosticBag diags;
  if (!frontend(path, source, module, diags)) {
    li::print_diagnostics(diags);
    return 1;
  }
  const li::MirModule mir = li::lower_to_mir(module);
  li::VcSummary vc = li::summarize_vcs(module);
  vc.mir_fn_count = mir.functions.size();
  const li::VcWitnessStats witness = li::compute_vc_witness_stats(module, &mir);
  vc.ensures_witnessed = witness.ensures_witnessed;
  vc.mir_return_linked = witness.mir_return_linked;
  const std::size_t mir_vectorized_proc = li::count_mir_vectorized_proc(mir);
  std::cout << "verify: procs=" << vc.proc_count << " mir_fns=" << vc.mir_fn_count
            << " requires=" << vc.requires_count << " ensures=" << vc.ensures_count
            << " decreases=" << vc.decreases_count << " invariant=" << vc.invariant_count
            << " witnessed_ensures=" << vc.ensures_witnessed
            << " mir_return_linked=" << vc.mir_return_linked
            << " mir_vectorized_proc=" << mir_vectorized_proc << '\n';
  if (li::terminal_color_enabled()) {
    std::cout << li::styled_success("verify") << li::styled_dim(" telemetry") << li::reset_style()
              << '\n';
    li::print_verify_telemetry(std::cout, "procs", std::to_string(vc.proc_count));
    li::print_verify_telemetry(std::cout, "mir_fns", std::to_string(vc.mir_fn_count));
    li::print_verify_telemetry(std::cout, "requires", std::to_string(vc.requires_count));
    li::print_verify_telemetry(std::cout, "ensures", std::to_string(vc.ensures_count));
    li::print_verify_telemetry(std::cout, "witnessed_ensures",
                               std::to_string(vc.ensures_witnessed));
    li::print_verify_telemetry(std::cout, "mir_return_linked",
                               std::to_string(vc.mir_return_linked));
    li::print_verify_telemetry(std::cout, "mir_vectorized_proc",
                               std::to_string(mir_vectorized_proc));
  }
  if (vc.requires_count == 0 && vc.ensures_count == 0) {
    std::cerr << li::styled_warning("verify") << li::styled_dim(" — no procedure contracts (G-vc partial)")
              << li::reset_style() << '\n';
  }
  if (std::getenv("LI_EMIT_VCS") != nullptr) {
    std::string vc_path = li::repo_build_path("vcs.json");
    std::string vc_err;
    if (!li::write_vcs_json(module, vc_path, &vc_err)) {
      std::cerr << "verify: " << vc_err << '\n';
    } else {
      std::cout << "verify: wrote " << vc_path << '\n';
    }
  }
  if (run_lean) {
    const std::string vc_lean = li::repo_build_path("generated/AutoVC.lean");
    std::error_code fs_err;
    std::filesystem::create_directories(std::filesystem::path(vc_lean).parent_path(), fs_err);
    std::string vc_err;
    (void)li::write_vcs_lean(module, vc_lean, &vc_err);
    const int open = count_open_autovc_goals();
    if (open >= 0) {
      std::cout << "verify: open_vc_goals=" << open << '\n';
      if (strict_lean && open > 0 && !li::allow_open_vc()) {
        std::cerr << "verify: strict-lean failed (" << open << " open obligations)\n";
        return 1;
      }
    }
    if (!li::no_lean_verify()) {
      return run_lean_verify_script(strict_lean);
    }
  }
  return 0;
}

int build_file(const char* path, const char* output, const li::CompileOptions& opts) {
  const std::string source = read_file(path);
  li::Module module;
  li::DiagnosticBag diags;
  if (!frontend(path, source, module, diags)) {
    li::print_diagnostics(diags);
    return 1;
  }
  std::string err;
  if (!li::compile_module(module, output, opts, "", &err)) {
    std::cerr << li::styled_error_label() << ": build failed: " << err << li::reset_style() << '\n';
    return 1;
  }
  return 0;
}

}  // namespace

int main(int argc, char** argv) {
  if (argc < 2) {
    return usage();
  }
  const std::string_view cmd = argv[1];
  if (cmd == "--version" || cmd == "-V") {
    li::print_lic_banner(std::cout);
#ifdef LI_VERSION
    std::cout << li::styled_accent("lic ") << LI_VERSION << li::reset_style() << '\n';
#else
    std::cout << li::styled_accent("lic 0.0.0-dev") << li::reset_style() << '\n';
#endif
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
  if (cmd == "check") {
    if (argc < 3) {
      return usage();
    }
    const char* path = nullptr;
    DiagOutput output = DiagOutput::Human;
    for (int i = 2; i < argc; ++i) {
      const std::string_view arg = argv[i];
      if (arg == "--format=json") {
        output = DiagOutput::Json;
      } else if (path == nullptr) {
        path = argv[i];
      } else {
        return usage();
      }
    }
    if (path == nullptr) {
      return usage();
    }
    return check_file(path, output, "check");
  }
  if (cmd == "diagnose") {
    if (argc < 3) {
      return usage();
    }
    return check_file(argv[2], DiagOutput::Json, "diagnose");
  }
  if (cmd == "verify") {
    if (argc < 3) {
      return usage();
    }
    li::reset_proof_cli_flags();
    warn_deprecated_proof_env();
    bool run_lean = false;
    bool strict_lean = false;
    for (int i = 3; i < argc; ++i) {
      if (std::string_view(argv[i]) == "--lean") {
        run_lean = true;
      } else if (std::string_view(argv[i]) == "--strict-lean") {
        run_lean = true;
        strict_lean = true;
      } else if (parse_proof_cli_flag(argv[i])) {
        continue;
      }
    }
    return verify_file(argv[2], run_lean, strict_lean);
  }
  if (cmd == "validate-httpd-config") {
    return validate_httpd_config_cmd(argc, argv);
  }
  if (cmd == "httpd") {
    if (argc >= 3 && std::string_view(argv[2]) == "validate-config") {
      return httpd_validate_config(argc, argv);
    }
    if (argc >= 3 && std::string_view(argv[2]) == "explain-config") {
      return httpd_explain_config(argc, argv);
    }
    std::cerr << "usage: lic httpd explain-config|validate-config <config.toml>\n";
    return 1;
  }
  if (cmd == "build") {
    if (argc < 3) {
      return usage();
    }
    li::reset_proof_cli_flags();
    warn_deprecated_proof_env();
    const char* input = nullptr;
    const char* output = li::null_output_path();
    li::CompileOptions opts;
    bool coverage = false;
    bool strict_lean = false;
    std::string extra_flags;
    if (const char* env_stable = std::getenv("LI_FP_NUMERICALLY_STABLE");
        env_stable && *env_stable && env_stable[0] != '0') {
      opts.fp_numerically_stable = true;
    }
    for (int i = 2; i < argc; ++i) {
      const std::string_view arg = argv[i];
      if (arg == "-o" && i + 1 < argc) {
        output = argv[++i];
      } else if (!input && arg[0] != '-' && arg != "--release") {
        input = argv[i];
      } else if (arg == "--release") {
        opts.release = true;
      } else if (arg == "--numerically-stable") {
        opts.fp_numerically_stable = true;
      } else if (arg == "--coverage-instrument") {
        coverage = true;
      } else if (arg == "--strict-lean") {
        strict_lean = true;
      } else if (parse_proof_cli_flag(arg)) {
        continue;
      } else if (arg.rfind("--threads=", 0) == 0) {
        setenv("LI_OMP_THREADS", std::string(arg.substr(10)).c_str(), 1);
      } else if (apply_resource_flag(arg)) {
        continue;
      } else {
        extra_flags.append(argv[i]);
        extra_flags.push_back(' ');
      }
    }
    if (coverage) {
      extra_flags += "-fprofile-instr-generate -fcoverage-mapping ";
    }
    if (!input) {
      return usage();
    }
    const std::string source = read_file(input);
    li::Module module;
    li::DiagnosticBag diags;
    if (!frontend(input, source, module, diags)) {
      li::print_diagnostics(diags);
      return 1;
    }
    std::string err;
    if (!li::compile_module(module, output, opts, extra_flags, &err)) {
      std::cerr << li::styled_error_label() << ": build failed: " << err << li::reset_style() << '\n';
      return 1;
    }
    if (li::terminal_color_enabled()) {
      std::cout << li::styled_success("build") << li::styled_dim(" ok → ") << li::styled_accent(output)
                << li::reset_style() << '\n';
    }
    const std::string vc_lean = li::repo_build_path("generated/AutoVC.lean");
    std::error_code fs_err;
    std::filesystem::create_directories(std::filesystem::path(vc_lean).parent_path(), fs_err);
    if (!li::write_vcs_lean(module, vc_lean, &err)) {
      std::cerr << "vc emit: " << err << '\n';
    }
    if (!li::allow_open_vc()) {
      const int open = count_open_autovc_goals();
      if (open > 0) {
        std::cerr << "lic build: " << open
                  << " proof obligation(s) still need a Lean proof "
                     "(see " << vc_lean << ")\n";
        std::cerr << "hint: a `requires` or `ensures` on your code created a goal the compiler "
                     "could not close automatically — prove it in Lean, simplify the "
                     "contract, or pass --allow-open-vc only for documented dev/tests\n";
        return 1;
      }
    }
    if (!li::no_lean_verify()) {
      if (const int lean_rc = run_lean_verify_script(strict_lean); lean_rc != 0) {
        return lean_rc;
      }
    } else {
      std::cerr << "lic build: warning — Lean verify skipped (--no-lean-verify)\n";
    }
    return 0;
  }
  return usage();
}
