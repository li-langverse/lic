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
#include <windows.h>
#include <winsock2.h>
#include <ws2tcpip.h>
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

struct pollfd {
  SOCKET fd;
  SHORT events;
  SHORT revents;
};

static inline int poll(struct pollfd* fds, unsigned long nfds, int timeout) {
  return WSAPoll(fds, nfds, timeout);
}

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
