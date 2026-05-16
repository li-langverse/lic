#pragma once

#include <cstddef>
#include <iosfwd>
#include <optional>
#include <string>
#include <string_view>
#include <vector>

namespace li {

struct SourceLoc {
  std::string file;
  std::size_t line = 1;
  std::size_t column = 1;
  std::size_t offset = 0;
};

struct Diagnostic {
  SourceLoc loc;
  std::string code;
  std::string message;
  std::optional<std::string> hint;
};

class DiagnosticBag {
 public:
  void error(SourceLoc loc, std::string message);
  void error(SourceLoc loc, std::string code, std::string message, std::string hint = {});
  bool empty() const { return items_.empty(); }
  const std::vector<Diagnostic>& items() const { return items_; }

 private:
  std::vector<Diagnostic> items_;
};

void print_diagnostics(const DiagnosticBag& bag);

/// Machine-readable diagnostics for agents (`lic check --format=json`, `lic diagnose`).
void print_diagnostics_json(const DiagnosticBag& bag, std::ostream& out,
                            std::string_view command = "check");

}  // namespace li
