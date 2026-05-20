#include "li/compile.hpp"
#include "li/parser.hpp"
#include "li/platform.hpp"
#include "li/policy.hpp"
#include "li/import_resolve.hpp"
#include "li/prelude.hpp"
#include "li/trusted_extern.hpp"
#include "li/smoke_llvm.hpp"
#include "li/typecheck.hpp"
#include "li/vc_emit.hpp"
#include "li/mir.hpp"
#include "li/vc_summary.hpp"
#include "li/vc_witness.hpp"
#include "li/terminal.hpp"

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
            << "  lic verify <file>      VC summary; --lean runs semantics; --strict-lean fails open VCs\n"
            << "  lic build <file> -o <out> [--release] [--numerically-stable]\n"
            << "                       [--threads=N] [--jobs=N] [--max-memory=MB]\n"
            << "                       [--coverage-instrument]\n"
            << "  lic smoke-llvm         verify LLVM can emit main returning 0\n"
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
  li::check_trusted_extern_abi(*parsed.module, path, diags);
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
    diags.error(d.loc, d.message);
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

int count_open_autovc_goals() {
  const char* root = std::getenv("LI_REPO_ROOT");
  std::string script = "scripts/check-autovc-open-goals.sh";
  if (root != nullptr) {
    script = std::string(root) + "/" + script;
  }
  const std::string cmd = "bash " + script + " 2>&1";
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
  std::cout << "verify: procs=" << vc.proc_count << " mir_fns=" << vc.mir_fn_count
            << " requires=" << vc.requires_count << " ensures=" << vc.ensures_count
            << " decreases=" << vc.decreases_count << " invariant=" << vc.invariant_count
            << " witnessed_ensures=" << vc.ensures_witnessed
            << " mir_return_linked=" << vc.mir_return_linked << '\n';
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
  }
  if (vc.requires_count == 0 && vc.ensures_count == 0) {
    std::cerr << li::styled_warning("verify") << li::styled_dim(" — no procedure contracts (G-vc partial)")
              << li::reset_style() << '\n';
  }
  if (std::getenv("LI_EMIT_VCS") != nullptr) {
    std::string vc_path = "build/vcs.json";
    if (const char* root = std::getenv("LI_REPO_ROOT")) {
      vc_path = std::string(root) + "/build/vcs.json";
    }
    std::string vc_err;
    if (!li::write_vcs_json(module, vc_path, &vc_err)) {
      std::cerr << "verify: " << vc_err << '\n';
    } else {
      std::cout << "verify: wrote " << vc_path << '\n';
    }
  }
  if (run_lean) {
    std::string vc_lean = "build/generated/AutoVC.lean";
    if (const char* root = std::getenv("LI_REPO_ROOT")) {
      vc_lean = std::string(root) + "/" + vc_lean;
    }
    std::error_code fs_err;
    std::filesystem::create_directories(std::filesystem::path(vc_lean).parent_path(), fs_err);
    std::string vc_err;
    (void)li::write_vcs_lean(module, vc_lean, &vc_err);
    const int open = count_open_autovc_goals();
    if (open >= 0) {
      std::cout << "verify: open_vc_goals=" << open << '\n';
      if (strict_lean && open > 0) {
        std::cerr << "verify: strict-lean failed (" << open << " open obligations)\n";
        return 1;
      }
    }
    if (strict_lean) {
      setenv("LI_BUILD_VERIFY_LEAN_STRICT", "1", 1);
    }
    setenv("LI_BUILD_VERIFY_LEAN", "1", 1);
    std::string script = "scripts/lean-verify-stub.sh";
    if (const char* root = std::getenv("LI_REPO_ROOT")) {
      script = std::string(root) + "/" + script;
    }
    const std::string cmd = "bash " + script;
    const int lean_rc = std::system(cmd.c_str());
    return lean_rc == 0 ? 0 : 1;
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
    bool run_lean = false;
    bool strict_lean = false;
    for (int i = 3; i < argc; ++i) {
      if (std::string_view(argv[i]) == "--lean") {
        run_lean = true;
      } else if (std::string_view(argv[i]) == "--strict-lean") {
        run_lean = true;
        strict_lean = true;
      }
    }
    return verify_file(argv[2], run_lean, strict_lean);
  }
  if (cmd == "build") {
    if (argc < 3) {
      return usage();
    }
    const char* input = argv[2];
    const char* output = li::null_output_path();
    li::CompileOptions opts;
    bool coverage = false;
    std::string extra_flags;
    if (const char* env_stable = std::getenv("LI_FP_NUMERICALLY_STABLE");
        env_stable && *env_stable && env_stable[0] != '0') {
      opts.fp_numerically_stable = true;
    }
    for (int i = 3; i < argc; ++i) {
      const std::string_view arg = argv[i];
      if (arg == "-o" && i + 1 < argc) {
        output = argv[++i];
      } else if (arg == "--release") {
        opts.release = true;
      } else if (arg == "--numerically-stable") {
        opts.fp_numerically_stable = true;
      } else if (arg == "--coverage-instrument") {
        coverage = true;
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
    std::string vc_lean = "build/generated/AutoVC.lean";
    if (const char* root = std::getenv("LI_REPO_ROOT")) {
      vc_lean = std::string(root) + "/" + vc_lean;
    }
    std::error_code fs_err;
    std::filesystem::create_directories(std::filesystem::path(vc_lean).parent_path(), fs_err);
    if (!li::write_vcs_lean(module, vc_lean, &err)) {
      std::cerr << "vc emit: " << err << '\n';
    }
    if (std::getenv("LI_BUILD_VERIFY_LEAN") != nullptr) {
      return verify_file(input, true, false);
    }
    return 0;
  }
  return usage();
}
