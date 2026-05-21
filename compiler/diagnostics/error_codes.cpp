#include "li/error_codes.hpp"

namespace li {

namespace {

std::string cat(std::string_view a, std::string_view b) {
  std::string out;
  out.reserve(a.size() + b.size());
  out.append(a);
  out.append(b);
  return out;
}

}  // namespace

std::string_view error_code_string(ErrorCode code) {
  switch (code) {
    case ErrorCode::E0101:
      return "E0101";
    case ErrorCode::E0201:
      return "E0201";
    case ErrorCode::E0202:
      return "E0202";
    case ErrorCode::E0301:
      return "E0301";
    case ErrorCode::E0302:
      return "E0302";
    case ErrorCode::E0303:
      return "E0303";
    case ErrorCode::E0304:
      return "E0304";
    case ErrorCode::E0305:
      return "E0305";
    case ErrorCode::E0310:
      return "E0310";
    case ErrorCode::E0311:
      return "E0311";
    case ErrorCode::E0320:
      return "E0320";
    case ErrorCode::E0321:
      return "E0321";
    case ErrorCode::E0322:
      return "E0322";
    case ErrorCode::E0330:
      return "E0330";
    case ErrorCode::E0340:
      return "E0340";
    case ErrorCode::E0350:
      return "E0350";
    case ErrorCode::E0360:
      return "E0360";
    case ErrorCode::E0401:
      return "E0401";
    case ErrorCode::E0402:
      return "E0402";
    case ErrorCode::E0501:
      return "E0501";
    case ErrorCode::E0502:
      return "E0502";
    case ErrorCode::E0503:
      return "E0503";
    case ErrorCode::E0504:
      return "E0504";
  }
  return "E0000";
}

FormattedDiagnostic format_diagnostic(ErrorCode code, std::string_view message,
                                      std::string_view hint) {
  return FormattedDiagnostic{std::string(error_code_string(code)), std::string(message),
                             std::string(hint)};
}

void diag_error(DiagnosticBag& bag, SourceLoc loc, ErrorCode code, std::string_view message,
                std::string_view hint) {
  const auto fd = format_diagnostic(code, message, hint);
  bag.error(loc, fd.code, fd.message, fd.hint);
}

}  // namespace li
