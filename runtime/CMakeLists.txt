set(LI_RT_SOURCES
  li_rt.c
  li_rt_httpd.c
  li_rt_log.c
  li_rt_net.c
  li_rt_rng.c
  li_rt_tls.c
  li_rt_h2.c
  li_rt_winsock.c
)

add_library(li_rt STATIC ${LI_RT_SOURCES})

if(WIN32)
  target_link_libraries(li_rt PRIVATE ws2_32)
else()
  target_link_libraries(li_rt PRIVATE dl)
endif()

target_include_directories(li_rt PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
