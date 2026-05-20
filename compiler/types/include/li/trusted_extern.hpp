#pragma once

#include "li/ast.hpp"
#include "li/diagnostics.hpp"

#include <string>

namespace li {

/// Enforce trusted runtime ABI: extern proc only in canonical seam files unless exempt.
void check_trusted_extern_abi(const Module& module, const std::string& file,
                              DiagnosticBag& diags);

}  // namespace li
