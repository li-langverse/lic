#include "li/emit.hpp"

#include <llvm/IR/BasicBlock.h>
#include <llvm/IR/Constants.h>
#include <llvm/IR/Function.h>
#include <llvm/IR/IRBuilder.h>
#include <llvm/IR/LLVMContext.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/Type.h>
#include <llvm/IR/Verifier.h>
#include <llvm/Support/FileSystem.h>
#include <llvm/Support/raw_ostream.h>

#include <map>
#include <memory>
#include <string>
#include <vector>

namespace li {

namespace {

llvm::Type* llvm_scalar(llvm::LLVMContext& ctx, bool is_float) {
  return is_float ? llvm::Type::getDoubleTy(ctx) : llvm::Type::getInt32Ty(ctx);
}

}  // namespace

bool emit_llvm_ir(const MirModule& mir, const std::string& out_path, std::string* error) {
  llvm::LLVMContext context;
  auto module = std::make_unique<llvm::Module>("li", context);

  for (const auto& fn : mir.functions) {
    llvm::Type* ret_ty = llvm_scalar(context, fn.returns_float);
    std::vector<llvm::Type*> param_tys;
    for (const auto& p : fn.params) {
      param_tys.push_back(llvm_scalar(context, p.is_float));
    }
    llvm::FunctionType* fn_ty = llvm::FunctionType::get(ret_ty, param_tys, false);
    llvm::Function* func =
        llvm::Function::Create(fn_ty, llvm::Function::ExternalLinkage, fn.name, module.get());

    std::map<std::string, llvm::Value*> locals;
    unsigned idx = 0;
    for (auto& arg : func->args()) {
      if (idx < fn.params.size()) {
        arg.setName(fn.params[idx].name);
        locals[fn.params[idx].name] = &arg;
      }
      idx++;
    }

    llvm::BasicBlock* entry = llvm::BasicBlock::Create(context, "entry", func);
    llvm::IRBuilder<> builder(entry);

    for (const auto& ins : fn.body) {
      switch (ins.op) {
        case MirOp::ReturnVoid:
          builder.CreateRet(fn.returns_float ? llvm::ConstantFP::get(ret_ty, 0.0)
                                           : llvm::ConstantInt::get(ret_ty, 0));
          break;
        case MirOp::ReturnInt:
          builder.CreateRet(llvm::ConstantInt::get(ret_ty, ins.int_value));
          break;
        case MirOp::ReturnFloat:
          builder.CreateRet(llvm::ConstantFP::get(llvm::Type::getDoubleTy(context), ins.float_value));
          break;
        case MirOp::ReturnIdent: {
          auto it = locals.find(ins.ident);
          if (it != locals.end()) {
            builder.CreateRet(it->second);
          } else {
            builder.CreateRet(fn.returns_float ? llvm::ConstantFP::get(ret_ty, 0.0)
                                             : llvm::ConstantInt::get(ret_ty, 0));
          }
          break;
        }
      }
    }
  }

  llvm::FunctionType* main_ty =
      llvm::FunctionType::get(llvm::Type::getInt32Ty(context), {}, false);
  llvm::Function* main_fn =
      llvm::Function::Create(main_ty, llvm::Function::ExternalLinkage, "main", module.get());
  llvm::BasicBlock* main_entry = llvm::BasicBlock::Create(context, "entry", main_fn);
  llvm::IRBuilder<> main_builder(main_entry);
  main_builder.CreateRet(llvm::ConstantInt::get(llvm::Type::getInt32Ty(context), 0));

  std::string verify_err;
  llvm::raw_string_ostream verify_stream(verify_err);
  if (llvm::verifyModule(*module, &verify_stream)) {
    if (error) {
      *error = verify_err;
    }
    return false;
  }

  std::error_code ec;
  llvm::raw_fd_ostream out(out_path, ec, llvm::sys::fs::OF_Text);
  if (ec) {
    if (error) {
      *error = ec.message();
    }
    return false;
  }
  module->print(out, nullptr);
  return true;
}

}  // namespace li
