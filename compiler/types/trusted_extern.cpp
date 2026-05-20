#include "li/trusted_extern.hpp"

#include "li/error_codes.hpp"

#include <set>
#include <string>
#include <string_view>

namespace li {
namespace {

bool path_contains(std::string_view file, std::string_view part) {
  return file.find(part) != std::string_view::npos;
}

bool is_exempt_extern_file(std::string_view file) {
  auto starts = [&](std::string_view prefix) {
    return file.size() >= prefix.size() && file.substr(0, prefix.size()) == prefix;
  };
  return path_contains(file, "/li-tests/") || path_contains(file, "\\li-tests\\") ||
         starts("li-tests/") || path_contains(file, "/benchmarks/") ||
         path_contains(file, "\\benchmarks\\") || starts("benchmarks/") ||
         path_contains(file, "/examples/") || path_contains(file, "\\examples\\") ||
         starts("examples/") || path_contains(file, "/bootstrap/") ||
         path_contains(file, "\\bootstrap\\") || starts("bootstrap/");
}

bool is_canonical_extern_file(std::string_view file) {
  return path_contains(file, "/std/runtime/seam.li") ||
         path_contains(file, "\\std\\runtime\\seam.li") ||
         path_contains(file, "std/runtime/seam.li") ||
         path_contains(file, "/std/bytes/bytes.li") ||
         path_contains(file, "\\std\\bytes\\bytes.li") ||
         path_contains(file, "std/bytes/bytes.li");
}

const std::set<std::string>& runtime_manifest_symbols() {
  static const std::set<std::string> k = {
      "li_rt_argc",
      "li_rt_argv_i",
      "li_rt_sqrt",
      "li_rt_sin",
      "li_rt_cos",
      "li_rt_atan2",
      "li_rt_exp",
      "li_rt_log",
      "tcp_listen",
      "tcp_accept",
      "tcp_close",
      "tcp_tune_client",
      "net_set_nonblock",
      "tcp_accept_nb",
      "tcp_recv_slot",
      "tcp_send_buf",
      "tcp_send_coalesce_i",
      "net_buf_len",
      "net_slot_buf_ptr",
      "httpd_slot_hdr_i",
      "httpd_prepare_root_i",
      "httpd_cache_ready_i",
      "httpd_cached_body_i",
      "httpd_cached_sz_i",
      "httpd_reply_cached_index_i",
      "httpd_drain_slot_i",
      "net_slot_consume",
      "httpd_slot_alloc",
      "httpd_slot_find_fd",
      "httpd_slot_free",
      "epoll_create1_i",
      "epoll_ctl_add_i",
      "epoll_ctl_add_listen_i",
      "epoll_ctl_del_i",
      "epoll_wait_events_i",
      "net_events_fd",
      "net_events_revents",
      "net_epoll_readable",
      "net_epoll_hangup",
      "net_fill_not_found_i",
      "net_tcp_ack_now",
      "net_open_readonly_i",
      "net_fstat_size",
      "net_read_fd",
      "net_close_fd",
      "net_sendfile_fd",
      "net_buf_alloc",
      "net_buf_free",
      "httpd_write_response_hdr_i",
      "bytes_len_i",
      "bytes_slice_i",
      "net_byte_at_i",
      "str_cat2_i",
      "net_lit_index_html_i",
      "httpd_parse_port_i",
      "net_diag",
      "bytes_len",
      "bytes_slice",
  };
  return k;
}

}  // namespace

void check_trusted_extern_abi(const Module& module, const std::string& file,
                              DiagnosticBag& diags) {
  const bool exempt = is_exempt_extern_file(file);
  const bool canonical = is_canonical_extern_file(file);
  const auto& manifest = runtime_manifest_symbols();

  for (const auto& proc : module.procs) {
    if (!proc.is_extern) {
      continue;
    }
    if (exempt) {
      continue;
    }
    if (!canonical) {
      diag_error(diags, SourceLoc{file, 1, 1, proc.span.start}, ErrorCode::E0331,
                 "`extern proc " + proc.name +
                     "` is not allowed here — the trusted runtime ABI is declared only in "
                     "`std/runtime/seam.li` (import `std.runtime.seam` or `net`).",
                 "See docs/compiler/trusted-extern-abi.md and security/trusted-extern-manifest.toml.");
      continue;
    }
    if (!manifest.count(proc.name)) {
      diag_error(diags, SourceLoc{file, 1, 1, proc.span.start}, ErrorCode::E0331,
                 "`extern proc " + proc.name +
                     "` is not in the trusted runtime manifest — add it to "
                     "`security/trusted-extern-manifest.toml` and `runtime/li_rt*.c` together.",
                 "Keep Li proc name identical to the C symbol the linker expects.");
    }
  }
}

}  // namespace li
