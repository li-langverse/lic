/* M2 TLS 1.3 terminate — OpenSSL via dlopen (no libssl-dev link dep). */
#ifndef LI_RT_TLS_H
#define LI_RT_TLS_H

#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>

#ifdef __cplusplus
extern "C" {
#endif

#define LI_HTTPD_MAX_CONN_TLS 512

/* 0=plain 1=tls+http/1.1 2=tls+h2 */
int32_t httpd_tls_slot_proto(int32_t slot);
void* httpd_tls_slot_ssl(int32_t slot);

int32_t httpd_tls_runtime_wanted(void);
int32_t httpd_tls_runtime_ready(void);

/* TLS 1.2 + dhparam for legacy DHE (gap-tls-dhe); call before httpd_tls_global_init. */
void httpd_tls_configure_legacy(int32_t min_proto_12, const char* dhparam_path);

/* Load cert/key from dir/fullchain.pem + privkey.pem; enable ALPN h2 when http2_on. */
int32_t httpd_tls_global_init(const char* cert_dir, int32_t http2_on);
int32_t httpd_tls_global_init_paths(const char* cert_dir, const char* manual_cert,
                                    const char* manual_key, int32_t http2_on);

void httpd_tls_global_shutdown(void);

/* 0=done, 1=want_io, -1=error */
int32_t httpd_tls_handshake_begin(int32_t slot, int32_t fd);
int32_t httpd_tls_handshake_continue(int32_t slot);
int32_t httpd_tls_handshake_pending(int32_t slot);
/* Spin accept with poll until done (max_rounds) or still want_io. */
int32_t httpd_tls_handshake_spin(int32_t slot, int32_t fd, int32_t max_rounds);

/* Non-blocking TLS accept after TCP accept; sets slot proto. Returns 0 ok, -1 fail. */
int32_t httpd_tls_handshake_slot(int32_t slot, int32_t fd);

void httpd_tls_free_slot(int32_t slot);

/* recv/send wrappers — use when httpd_tls_slot_proto(slot) != 0 */
ssize_t httpd_tls_read_slot(int32_t slot, void* buf, size_t cap);
ssize_t httpd_tls_write_slot(int32_t slot, const void* buf, size_t len);
ssize_t httpd_tls_write_fd(int32_t fd, const void* buf, size_t len);

#ifdef __cplusplus
}
#endif

#endif /* LI_RT_TLS_H */

int32_t httpd_pure_li_tls_enabled(void);
int32_t httpd_pure_tls_slot_active(int32_t slot);
int32_t httpd_pure_tls_attach(int32_t slot, int32_t conn);
int32_t httpd_pure_tls_poll(int32_t slot);
ssize_t httpd_pure_tls_read_app(int32_t slot, int max_bytes);
ssize_t httpd_pure_tls_write_app(int32_t slot, int len);
int32_t httpd_pure_tls_alpn(int32_t slot);
