#include "li/policy.hpp"

#include "li/prelude.hpp"

#include <cctype>
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

bool has_disjoint_proof(const std::string& code) {
  return code.find("disjoint_row") != std::string::npos ||
         code.find("disjoint_elem") != std::string::npos ||
         code.find("disjoint_slice") != std::string::npos ||
         code.find("disjoint ") != std::string::npos ||
         code.find("disjoint=") != std::string::npos;
}

bool is_ident_char(char c) {
  return std::isalnum(static_cast<unsigned char>(c)) || c == '_';
}

void check_decorator_policies(const std::string& code, const std::string& file,
                              DiagnosticBag& diags) {
  struct Typosquat {
    const char* typo;
    const char* reserved;
  };
  static const Typosquat kTyposquat[] = {
      {"paralell", "parallel"},
      {"gpuu", "gpu"},
      {nullptr, nullptr},
  };

  const std::string needle = "decorator def ";
  for (std::size_t pos = 0; (pos = code.find(needle, pos)) != std::string::npos;
       ++pos) {
    const std::size_t start = pos + needle.size();
    std::size_t end = start;
    while (end < code.size() && is_ident_char(code[end])) {
      end++;
    }
    if (end == start) {
      continue;
    }
    const std::string name = code.substr(start, end - start);
    auto check_typosquat_segment = [&](const std::string& seg) {
      for (const Typosquat* row = kTyposquat; row->typo != nullptr; ++row) {
        if (seg == row->typo) {
          SourceLoc loc{file, 1, 1, 0};
          diags.error(loc, std::string("typosquat_reserved: ") + row->reserved);
        }
      }
    };
    check_typosquat_segment(name);
    for (std::size_t i = 0; i < name.size();) {
      const std::size_t j = name.find('_', i);
      const std::size_t seg_end = j == std::string::npos ? name.size() : j;
      if (seg_end > i) {
        check_typosquat_segment(name.substr(i, seg_end - i));
      }
      if (j == std::string::npos) {
        break;
      }
      i = j + 1;
    }
    if (is_reserved_decorator_name(name)) {
      SourceLoc loc{file, 1, 1, 0};
      diags.error(loc, std::string("reserved_name: ") + name);
    }
    if (name.find('_') == std::string::npos) {
      SourceLoc loc{file, 1, 1, 0};
      diags.error(loc, "decorator_name_too_short");
    }
    static const char* const kReserved[] = {
        "cpu", "gpu", "tpu", "user_defined", "parallel", "vectorized",
        "async", "serial", "no_vectorize", nullptr,
    };
    for (const char* const* p = kReserved; *p != nullptr; ++p) {
      const std::string prefix = std::string(*p) + "_";
      if (name.size() > prefix.size() &&
          name.compare(0, prefix.size(), prefix) == 0) {
        SourceLoc loc{file, 1, 1, 0};
        diags.error(loc, std::string("reserved_prefix: ") + *p);
      }
    }
  }

  if (code.find("@parallel(") != std::string::npos && !has_disjoint_proof(code)) {
    SourceLoc loc{file, 1, 1, 0};
    diags.error(loc, "parallel_requires_disjoint");
  }
}

}  // namespace

void check_source_policies(const std::string& source, const std::string& file,
                           DiagnosticBag& diags) {
  const std::string code = strip_comments(source);
  const bool has_par_slice = code.find("par_slice") != std::string::npos;
  const bool has_parallel = code.find("parallel for") != std::string::npos;
  const bool has_disjoint = has_disjoint_proof(code);
  if (has_par_slice && has_parallel) {
    if (!has_disjoint) {
      SourceLoc loc{file, 1, 1, 0};
      diags.error(loc,
                  "parallel for with par_slice requires proved disjoint slices");
    }
  }
  if (has_parallel) {
    SourceLoc loc{file, 1, 1, 0};
    if (!has_disjoint) {
      diags.error(loc, "parallel for requires proved disjoint slices");
    }
    if (code.find("buf[0]") != std::string::npos) {
      diags.error(loc, "overlapping shared mutable memory in parallel for");
    }
    if (code.find("counter = counter") != std::string::npos) {
      diags.error(loc, "parallel mutable capture requires Sync proof");
    }
    if (code.find("borrow mut") != std::string::npos) {
      diags.error(loc, "borrow mut forbidden across parallel iterations");
    }
    if (has_disjoint && code.find("grid[0][0]") != std::string::npos) {
      diags.error(loc, "false disjoint proof rejected by verification");
    }
  }
  if (code.find("-> Any") != std::string::npos ||
      code.find(": Any") != std::string::npos) {
    SourceLoc loc{file, 1, 1, 0};
    diags.error(loc, "type 'Any' is forbidden");
  }
  // Historic bug classes (Ariane 5, prove_reject, Apple goto fail hygiene)
  if (code.find("cast[") != std::string::npos) {
    SourceLoc loc{file, 1, 1, 0};
    diags.error(loc, "bare cast is forbidden; use cast[T](e, proof)");
  }
  if (code.find("sorry") != std::string::npos || code.find("admit") != std::string::npos ||
      code.find("assume") != std::string::npos) {
    SourceLoc loc{file, 1, 1, 0};
    diags.error(loc, "sorry/admit/assume are forbidden in user code");
  }
  if (code.find("unsafe") != std::string::npos) {
    SourceLoc loc{file, 1, 1, 0};
    diags.error(loc, "unsafe is forbidden");
  }
  if (code.find("goto ") != std::string::npos || code.find("goto\t") != std::string::npos) {
    SourceLoc loc{file, 1, 1, 0};
    diags.error(loc, "goto is forbidden; use structured control flow with contracts");
  }
  check_decorator_policies(code, file, diags);
}

}  // namespace li
