#pragma once

#include "li/ast.hpp"

#include <string>

namespace li {

bool compile_module(const Module& module, const std::string& output_path, bool release,
                  std::string* error);

}  // namespace li
