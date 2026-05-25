#pragma once

#include "li/ast.hpp"
#include "li/diagnostics.hpp"

#include <cstdint>
#include <string>

namespace li {

/// Load `import` modules into `out` (append types/procs). Returns false on error.
bool resolve_imports(Module& out, const std::string& file_path, DiagnosticBag& diags);

/// FNV-1a hash of direct import paths and their file contents (check cache key input).
std::uint64_t hash_direct_import_graph(const std::string& file_path);

}  // namespace li
