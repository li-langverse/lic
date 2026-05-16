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
  std::cerr << "lic — Li compiler\n"
            << "usage:\n"
            << "  lic parse <file>       parse and validate syntax\n"
            << "  lic check <file>       parse + typecheck\n"
            << "  lic verify <file>      VC summary; --lean runs semantics stub\n"
            << "  lic build <file> -o <out> [--release] [--threads=N]\n"
            << "                       [--jobs=N] [--max-memory=MB]\n"
            << "                       [--coverage-instrument]\n"
            << "  lic smoke-llvm         verify LLVM can emit main returning 0\n"
            << "  lic --version          print version\n"
            << "\n"
            << "resource defaults (override via flags or env):\n"
            << "  --jobs=N / LI_COMPILE_JOBS / LI_BUILD_JOBS (host=" << jobs
            << ") — reserved for parallel frontend\n"
            << "  --max-memory=MB / LI_MAX_MEMORY_MB — reserved memory budget\n"
            << "  --threads=N / LI_OMP_THREADS — OpenMP team size at run time\n";
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

int check_file(const char* path) {
  const std::string source = read_file(path);
  li::Module module;
  li::DiagnosticBag diags;
  if (!frontend(path, source, module, diags)) {
    li::print_diagnostics(diags);
    return 1;
  }
  return 0;
}

int verify_file(const char* path, bool run_lean) {
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
  std::cout << "verify: procs=" << vc.proc_count << " mir_fns=" << vc.mir_fn_count
            << " requires=" << vc.requires_count << " ensures=" << vc.ensures_count
            << " decreases=" << vc.decreases_count << " invariant=" << vc.invariant_count
            << '\n';
  if (vc.requires_count == 0 && vc.ensures_count == 0) {
    std::cerr << "verify: warning — no procedure contracts (G-vc partial)\n";
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
  if (!run_lean) {
    return 0;
  }
  std::string script = "scripts/lean-verify-stub.sh";
  if (const char* root = std::getenv("LI_REPO_ROOT")) {
    script = std::string(root) + "/" + script;
  }
  const std::string cmd = "bash " + script;
  const int lean_rc = std::system(cmd.c_str());
  return lean_rc == 0 ? 0 : 1;
}

int build_file(const char* path, const char* output, bool release) {
  const std::string source = read_file(path);
  li::Module module;
  li::DiagnosticBag diags;
  if (!frontend(path, source, module, diags)) {
    li::print_diagnostics(diags);
    return 1;
  }
  std::string err;
  if (!li::compile_module(module, output, release, "", &err)) {
    std::cerr << "build failed: " << err << '\n';
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
#ifdef LI_VERSION
    std::cout << "lic " << LI_VERSION << '\n';
#else
    std::cout << "lic 0.0.0-dev\n";
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
    return check_file(argv[2]);
  }
  if (cmd == "verify") {
    if (argc < 3) {
      return usage();
    }
    bool run_lean = false;
    for (int i = 3; i < argc; ++i) {
      if (std::string_view(argv[i]) == "--lean") {
        run_lean = true;
      }
    }
    return verify_file(argv[2], run_lean);
  }
  if (cmd == "build") {
    if (argc < 3) {
      return usage();
    }
    const char* input = argv[2];
    const char* output = li::null_output_path();
    bool release = false;
    bool coverage = false;
    std::string extra_flags;
    for (int i = 3; i < argc; ++i) {
      const std::string_view arg = argv[i];
      if (arg == "-o" && i + 1 < argc) {
        output = argv[++i];
      } else if (arg == "--release") {
        release = true;
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
    if (!li::compile_module(module, output, release, extra_flags, &err)) {
      std::cerr << "build failed: " << err << '\n';
      return 1;
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
      return verify_file(input, true);
    }
    return 0;
  }
  return usage();
}
