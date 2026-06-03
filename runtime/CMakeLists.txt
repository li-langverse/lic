# Core runtime always built (compiler + stdlib benches).
set(LI_RT_CORE_SOURCES
  li_rt.c
  li_rt_log.c
  li_rt_rng.c
)

# Server seam (POSIX sockets, epoll, OpenSSL dlopen) — not available on native WIN32/MSYS2 UCRT.
set(LI_RT_SERVER_SOURCES
  li_rt_httpd.c
  li_rt_net.c
  li_rt_tls.c
  li_rt_h2.c
)

if(WIN32)
  add_library(li_rt STATIC ${LI_RT_CORE_SOURCES})
else()
  add_library(li_rt STATIC ${LI_RT_CORE_SOURCES} ${LI_RT_SERVER_SOURCES})
  target_link_libraries(li_rt PRIVATE dl)
endif()

target_include_directories(li_rt PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
