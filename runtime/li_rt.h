#pragma once

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

void li_panic(const char* msg);
void li_bounds_fail(void);
void li_rt_print_int(int32_t value);
void li_rt_print_str(const char* s);
void li_rt_set_args(int argc, char** argv);
int li_rt_argc(void);
const char* li_rt_argv(int index);
void li_omp_parallel_for_i64(long long start, long long end, void (*body)(long long));
int32_t li_rt_floor_div_i32(int32_t a, int32_t b);
int32_t li_rt_pow_i32(int32_t base, int32_t exp);
double li_rt_sqrt(double x);
double li_rt_sin(double x);
double li_rt_cos(double x);
double li_rt_atan2(double y, double x);
double li_rt_exp(double x);
double li_rt_log(double x);
double li_rt_hypot(double x, double y);
double li_rt_expm1(double x);
double li_rt_log1p(double x);

void li_async_frame_enter(void);
void li_async_frame_leave(void);
int32_t li_async_await_i32(int32_t pending);
int32_t li_async_poll(uint32_t slot);

/* Net trusted seam (li_rt_net.c) — syscalls + I/O buffers; HTTP in Li packages. */
int32_t tcp_listen(int32_t port);
int32_t tcp_accept(int32_t listen_fd);
int32_t tcp_send(int32_t conn_fd, const char* data);
int32_t tcp_send_n(int32_t conn_fd, const char* data, int32_t len);
const char* tcp_recv(int32_t conn_fd, int32_t max_bytes);
void tcp_close(int32_t fd);
void tcp_tune_client(int32_t fd);
int32_t bytes_len(const char* b);
const char* bytes_slice(const char* b, int32_t off, int32_t n);
const char* bytes_append(const char* a, const char* b);
int32_t net_byte_at(const char* b, int32_t off);
int32_t net_atoi(const char* s);

intptr_t tcp_recv_i(int32_t conn, int32_t max);
int32_t tcp_send_i(int32_t conn, intptr_t data);
intptr_t li_rt_argv_i(int32_t index);
int32_t bytes_len_i(intptr_t b);
intptr_t bytes_slice_i(intptr_t b, int32_t off, int32_t n);
intptr_t bytes_append_i(intptr_t a, intptr_t b);
int32_t net_byte_at_i(intptr_t b, int32_t off);
int32_t httpd_parse_port_i(intptr_t s);

int32_t net_set_nonblock(int32_t fd);
int32_t net_tcp_ack_now(int32_t fd);
int32_t tcp_accept_nb(int32_t listen_fd);
int32_t tcp_recv_slot(int32_t conn, int32_t slot, int32_t max_bytes);
int32_t tcp_send_buf(int32_t conn, intptr_t data, int32_t off, int32_t n);
int32_t tcp_send_coalesce_i(int32_t conn, intptr_t a, int32_t la, intptr_t b, int32_t lb);
int32_t net_buf_len(int32_t slot);
intptr_t net_slot_buf_ptr(int32_t slot);
intptr_t httpd_slot_hdr_i(int32_t slot);
int32_t net_slot_consume(int32_t slot, int32_t n);
int32_t httpd_prepare_root_i(intptr_t root);
int32_t httpd_cache_ready_i(void);
intptr_t httpd_cached_body_i(void);
int32_t httpd_cached_sz_i(void);
int32_t httpd_reply_cached_index_i(int32_t conn, int32_t slot, int32_t keep_alive);
int32_t httpd_drain_slot_i(int32_t conn, int32_t slot);
int32_t httpd_slot_alloc(int32_t fd);
int32_t httpd_slot_find_fd(int32_t fd);
void httpd_slot_free(int32_t slot);

int32_t epoll_create1_i(void);
int32_t epoll_ctl_add_i(int32_t epfd, int32_t fd);
int32_t epoll_ctl_add_listen_i(int32_t epfd, int32_t fd);
int32_t epoll_ctl_del_i(int32_t epfd, int32_t fd);
int32_t epoll_wait_events_i(int32_t epfd, intptr_t events, int32_t max_events);
int32_t net_events_fd(intptr_t events, int32_t index);
int32_t net_events_revents(intptr_t events, int32_t index);
int32_t net_epoll_readable(int32_t revents);
int32_t net_epoll_hangup(int32_t revents);
int32_t net_fill_not_found_i(intptr_t p);

int32_t net_open_readonly_i(intptr_t path);
int32_t net_fstat_size(int32_t fd);
int32_t net_read_fd(int32_t fd, intptr_t buf, int32_t max_bytes);
int32_t net_close_fd(int32_t fd);
int32_t net_sendfile_fd(int32_t conn, int32_t file_fd, int32_t file_size);

intptr_t net_buf_alloc(int32_t size);
void net_buf_free(intptr_t p);
int32_t net_buf_fill_i(intptr_t dst, intptr_t src, int32_t off, int32_t n);
int32_t httpd_write_response_hdr_i(intptr_t buf, int32_t cap, int32_t status, int32_t body_len,
                                   int32_t keep_alive);

intptr_t str_cat2_i(intptr_t a, intptr_t b);
intptr_t net_lit_index_html_i(void);
int32_t net_diag(int32_t tag);
