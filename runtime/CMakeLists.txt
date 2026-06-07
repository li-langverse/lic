set(LI_RT_SOURCES
  li_rt.c
  li_rt_httpd.c
  li_rt_log.c
  li_rt_net.c
  li_rt_rng.c
  li_rt_tls.c
  li_rt_h2.c
  li_rt_winsock.c
  li_rt_llm.c
  li_rt_inference_sse.c
  li_par_pool.c
  li_par_reduce.c
  li_dpar.c
  li_dpar_collective.c
)

add_library(li_rt STATIC ${LI_RT_SOURCES})

if(WIN32)
  target_link_libraries(li_rt PRIVATE ws2_32)
else()
  target_link_libraries(li_rt PRIVATE dl pthread)
endif()

target_include_directories(li_rt PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
