add_executable(lic main.cpp)
target_compile_definitions(lic PRIVATE LI_VERSION="${LI_VERSION_STRING}")
target_include_directories(lic PRIVATE "${CMAKE_SOURCE_DIR}/runtime")
target_link_libraries(lic PRIVATE li_common li_codegen li_diagnostics li_parser li_types li_verify
                                   li_mir li_rt)
