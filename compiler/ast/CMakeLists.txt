add_library(li_ast STATIC ast.cpp)
target_include_directories(li_ast PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include)
