#pragma once

#include "li/ast.hpp"

#include <cstdint>
#include <string>
#include <vector>

namespace li {

enum class MirOp { ReturnVoid, ReturnInt, ReturnFloat, ReturnIdent };

struct MirInsn {
  MirOp op = MirOp::ReturnVoid;
  std::int64_t int_value = 0;
  double float_value = 0.0;
  std::string ident;
  bool ret_is_float = false;
};

struct MirParam {
  std::string name;
  bool is_float = false;
};

struct MirFn {
  std::string name;
  bool returns_float = false;
  std::vector<MirParam> params;
  std::vector<MirInsn> body;
};

struct MirModule {
  std::vector<MirFn> functions;
};

MirModule lower_to_mir(const Module& module);

}  // namespace li
