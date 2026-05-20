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

/* Async reactor stubs (httpd P0 — sync completion until epoll/kqueue lands). */
void li_async_frame_enter(void);
void li_async_frame_leave(void);
int32_t li_async_await_i32(int32_t pending);
int32_t li_async_poll(uint32_t slot);

/* Net trusted seam (li_rt_net.c) — primitives only; HTTP in Li packages. */
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
const char* int_to_str(int32_t n);
const char* str_cat2(const char* a, const char* b);
const char* str_path_join(const char* root, const char* path);
const char* file_read_all(const char* path, int32_t max_bytes);
int32_t httpd_parse_port(const char* s);
const char* net_empty_str(void);
const char* net_slash_path(void);
intptr_t tcp_recv_i(int32_t conn, int32_t max);
int32_t tcp_send_i(int32_t conn, intptr_t data);
intptr_t li_rt_argv_i(int32_t index);
int32_t bytes_len_i(intptr_t b);
intptr_t bytes_slice_i(intptr_t b, int32_t off, int32_t n);
intptr_t bytes_append_i(intptr_t a, intptr_t b);
int32_t net_byte_at_i(intptr_t b, int32_t off);
intptr_t int_to_str_i(int32_t n);
intptr_t str_cat2_i(intptr_t a, intptr_t b);
intptr_t str_path_join_i(intptr_t root, intptr_t path);
intptr_t file_read_all_i(intptr_t path, int32_t max);
intptr_t net_empty_str_i(void);
intptr_t net_slash_path_i(void);
int32_t httpd_parse_port_i(intptr_t s);
int32_t httpd_send_reply_i(int32_t conn, intptr_t body, int32_t keep_alive);
int32_t httpd_send_404_i(int32_t conn, int32_t keep_alive);
int32_t net_diag(int32_t tag);
