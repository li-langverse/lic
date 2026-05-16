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

/* Async reactor stubs (httpd P0 — sync completion until epoll/kqueue lands). */
void li_async_frame_enter(void);
void li_async_frame_leave(void);
int32_t li_async_await_i32(int32_t pending);
/* Poll slot: 1 = ready, 0 = pending (stub always ready). */
int32_t li_async_poll(uint32_t slot);
