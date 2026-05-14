#include "li/policy.hpp"

#include <sstream>

namespace li {
namespace {

std::string strip_comments(const std::string& source) {
  std::ostringstream out;
  for (std::size_t i = 0; i < source.size(); ++i) {
    if (source[i] == '#') {
      while (i < source.size() && source[i] != '\n') {
        i++;
      }
    } else {
      out << source[i];
    }
  }
  return out.str();
}

}  // namespace

void check_source_policies(const std::string& source, const std::string& file,
                           DiagnosticBag& diags) {
  const std::string code = strip_comments(source);
  const bool has_par_slice = code.find("par_slice") != std::string::npos;
  const bool has_parallel = code.find("parallel for") != std::string::npos;
  if (has_par_slice && has_parallel) {
    if (code.find("disjoint") == std::string::npos) {
      SourceLoc loc{file, 1, 1, 0};
      diags.error(loc,
                  "parallel for with par_slice requires proved disjoint slices");
    }
  }
  if (code.find("-> Any") != std::string::npos ||
      code.find(": Any") != std::string::npos) {
    SourceLoc loc{file, 1, 1, 0};
    diags.error(loc, "type 'Any' is forbidden");
  }
}

}  // namespace li
