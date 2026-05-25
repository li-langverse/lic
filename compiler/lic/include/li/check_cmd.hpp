#pragma once

#include "li/ast.hpp"
#include "li/diagnostics.hpp"

#include <string>

namespace li {

struct FrontendCheckOptions {
  bool deny_warnings = false;
};

bool run_frontend_check(const char* path, const std::string& source, Module& out,
                        DiagnosticBag& diags,
                        const FrontendCheckOptions& options = FrontendCheckOptions{});

int lic_check_main(int argc, char** argv);
int lic_diagnose_main(int argc, char** argv);

}  // namespace li
