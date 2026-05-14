add_executable(lic main.cpp)
target_link_libraries(lic PRIVATE li_codegen li_diagnostics li_parser li_types)
