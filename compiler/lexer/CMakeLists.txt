add_library(li_lexer STATIC lexer.cpp)
target_include_directories(li_lexer PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include)
