/* POSIX ↔ Winsock shim for li_rt_net / li_rt_tls / li_rt_h2 on native Windows (MSYS2 UCRT). */
#ifndef LI_RT_POSIX_COMPAT_H
#define LI_RT_POSIX_COMPAT_H

#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#if defined(_WIN32)

#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#include <winsock2.h>
#include <ws2tcpip.h>
#include <windows.h>
#include <io.h>
#include <fcntl.h>
#include <sys/stat.h>

#ifndef O_NONBLOCK
#define O_NONBLOCK 0x0004
#endif

#ifndef ssize_t
#ifdef _WIN64
typedef __int64 ssize_t;
#else
typedef long ssize_t;
#endif
#endif

#ifndef POLLRDNORM
#define POLLRDNORM POLLIN
#endif
#ifndef POLLWRNORM
#define POLLWRNORM POLLOUT
#endif

#ifndef POLLIN
#define POLLIN 0x0001
#endif
#ifndef POLLOUT
#define POLLOUT 0x0004
#endif
#ifndef POLLRDHUP
#define POLLRDHUP 0
#endif
#ifndef POLLHUP
#define POLLHUP 0x0002
#endif
#ifndef POLLERR
#define POLLERR 0x0008
#endif

/* winsock2.h already defines struct pollfd + WSAPoll on MSYS2 UCRT. */
#ifndef poll
#define poll WSAPoll
#endif

static inline void li_rt_sock_close(int fd) {
  if (fd >= 0) {
    closesocket((SOCKET)(intptr_t)fd);
  }
}

static inline void li_rt_file_close(int fd) {
  if (fd >= 0) {
    _close(fd);
  }
}

static inline int li_rt_sock_set_nonblocking(int fd) {
  u_long mode = 1;
  return ioctlsocket((SOCKET)(intptr_t)fd, FIONBIO, &mode) == 0 ? 0 : -1;
}

static inline int li_rt_sock_fcntl_setfl(int fd, int flags) {
  if (flags & O_NONBLOCK) {
    return li_rt_sock_set_nonblocking(fd);
  }
  u_long mode = 0;
  return ioctlsocket((SOCKET)(intptr_t)fd, FIONBIO, &mode) == 0 ? 0 : -1;
}

static inline int li_rt_httpd_cpu_count(void) {
  SYSTEM_INFO info;
  GetSystemInfo(&info);
  int n = (int)info.dwNumberOfProcessors;
  if (n < 1) {
    return 1;
  }
  if (n > 64) {
    return 64;
  }
  return n;
}

#ifndef MSG_NOSIGNAL
#define MSG_NOSIGNAL 0
#endif
#ifndef MSG_DONTWAIT
#define MSG_DONTWAIT 0
#endif

/* Winsock setsockopt expects const char* option values. */
static inline int li_rt_winsock_setsockopt(SOCKET s, int level, int optname, const void* optval, int optlen) {
  return setsockopt(s, level, optname, (const char*)optval, optlen);
}
#undef setsockopt
#define setsockopt(s, level, optname, optval, optlen) \
  li_rt_winsock_setsockopt((SOCKET)(s), (level), (optname), (optval), (int)(optlen))

static inline int clock_gettime(int clk_id, struct timespec* ts) {
  (void)clk_id;
  if (!ts) {
    return -1;
  }
  FILETIME ft;
  GetSystemTimePreciseAsFileTime(&ft);
  ULONGLONG t = ((ULONGLONG)ft.dwHighDateTime << 32) | ft.dwLowDateTime;
  t -= 116444736000000000ULL;
  ts->tv_sec = (time_t)(t / 10000000ULL);
  ts->tv_nsec = (long)((t % 10000000ULL) * 100ULL);
  return 0;
}

#ifndef CLOCK_MONOTONIC
#define CLOCK_MONOTONIC 1
#endif
#ifndef CLOCK_REALTIME
#define CLOCK_REALTIME 0
#endif

static inline void* memmem(const void* haystack, size_t haystacklen, const void* needle, size_t needlelen) {
  if (needlelen == 0) {
    return (void*)haystack;
  }
  if (haystacklen < needlelen) {
    return NULL;
  }
  const unsigned char* h = (const unsigned char*)haystack;
  const unsigned char* n = (const unsigned char*)needle;
  for (size_t i = 0; i + needlelen <= haystacklen; i++) {
    if (memcmp(h + i, n, needlelen) == 0) {
      return (void*)(h + i);
    }
  }
  return NULL;
}

static inline struct tm* gmtime_r(const time_t* t, struct tm* out) {
  return gmtime_s(out, t) == 0 ? out : NULL;
}

static inline void li_rt_winsock_ensure(void) {
  static int ready;
  if (ready) {
    return;
  }
  WSADATA wsa;
  if (WSAStartup(MAKEWORD(2, 2), &wsa) == 0) {
    ready = 1;
  }
}

#else /* ! _WIN32 */

#include <arpa/inet.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <poll.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <unistd.h>

#if !defined(__linux__) && !defined(__APPLE__)
#include <signal.h>
#include <sys/wait.h>
#endif

static inline void li_rt_sock_close(int fd) {
  if (fd >= 0) {
    close(fd);
  }
}

static inline void li_rt_file_close(int fd) {
  li_rt_sock_close(fd);
}

static inline int li_rt_sock_set_nonblocking(int fd) {
  int flags = fcntl(fd, F_GETFL, 0);
  if (flags < 0) {
    return -1;
  }
  return fcntl(fd, F_SETFL, flags | O_NONBLOCK);
}

static inline int li_rt_sock_fcntl_setfl(int fd, int flags) {
  return fcntl(fd, F_SETFL, flags);
}

static inline int li_rt_httpd_cpu_count(void) {
#ifdef _SC_NPROCESSORS_ONLN
  long n = sysconf(_SC_NPROCESSORS_ONLN);
  if (n < 1) {
    return 1;
  }
  if (n > 64) {
    return 64;
  }
  return (int)n;
#else
  return 1;
#endif
}

static inline void li_rt_winsock_ensure(void) {}

#endif /* _WIN32 */

#endif /* LI_RT_POSIX_COMPAT_H */
