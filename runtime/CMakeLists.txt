add_library(li_rt STATIC li_rt.c li_rt_httpd.c li_rt_net.c)
target_include_directories(li_rt PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
