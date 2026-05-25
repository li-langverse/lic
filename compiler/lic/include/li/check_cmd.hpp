#pragma once

#include "li/check_options.hpp"
#include "li/diagnostics.hpp"

namespace li {

struct Module;

bool run_frontend_check(const char* path, const CheckOptions& options, DiagnosticBag& diags,
                        Module* out_module = nullptr);

int lic_check_main(int argc, char** argv);
int lic_diagnose_main(int argc, char** argv);

}  // namespace li
