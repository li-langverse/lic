/* Dynamic library load shim (dlopen ↔ LoadLibrary) for OpenSSL on Windows. */
#ifndef LI_RT_DL_COMPAT_H
#define LI_RT_DL_COMPAT_H

#if defined(_WIN32)
#include <windows.h>
#include <stdio.h>

#ifndef RTLD_NOW
#define RTLD_NOW 0
#endif
#ifndef RTLD_GLOBAL
#define RTLD_GLOBAL 0
#endif

static inline void* li_rt_dlopen(const char* path, int flags) {
  (void)flags;
  return (void*)LoadLibraryA(path);
}

static inline void* li_rt_dlsym(void* handle, const char* symbol) {
  return (void*)GetProcAddress((HMODULE)handle, symbol);
}

static inline const char* li_rt_dlerror(void) {
  static char buf[128];
  DWORD err = GetLastError();
  snprintf(buf, sizeof(buf), "Win32 error %lu", (unsigned long)err);
  return buf;
}

#else
#include <dlfcn.h>

#define li_rt_dlopen(path, flags) dlopen((path), (flags))
#define li_rt_dlsym(handle, symbol) dlsym((handle), (symbol))
#define li_rt_dlerror() dlerror()

#endif

#endif /* LI_RT_DL_COMPAT_H */
