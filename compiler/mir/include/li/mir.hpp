#pragma once

#include "li/ast.hpp"

#include <cstdint>
#include <string>
#include <vector>

namespace li {

enum class MirOp {
  ReturnVoid,
  ReturnInt,
  ReturnFloat,
  ReturnIdent,
  EchoInt,
  EchoString,
  CallExtern,
  ArrayAlloc,
  ArrayStoreInt,
  ArrayLoadInt,
};

struct MirInsn {
  MirOp op = MirOp::ReturnVoid;
  std::int64_t int_value = 0;
  double float_value = 0.0;
  std::string ident;
  std::string str_value;
  std::string callee;
  bool ret_is_float = false;
  bool index_is_literal = true;
  std::string index_ident;
  bool use_loaded_int = false;
  bool rhs_is_literal = true;
  std::int64_t rhs_int = 0;
  std::string rhs_ident;
};

struct MirParam {
  std::string name;
  bool is_float = false;
  bool is_string = false;
};

struct MirFn {
  std::string name;
  bool returns_float = false;
  bool is_extern = false;
  std::vector<MirParam> params;
  std::vector<MirInsn> body;
};

struct MirModule {
  std::vector<MirFn> functions;
};

MirModule lower_to_mir(const Module& module);

}  // namespace li
