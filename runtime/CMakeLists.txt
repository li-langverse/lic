add_library(li_rt STATIC li_rt.c li_rt_httpd.c li_rt_log.c li_rt_net.c li_rt_tls.c li_rt_h2.c)
target_link_libraries(li_rt PRIVATE dl)
target_include_directories(li_rt PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
