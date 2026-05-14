#include "li/emit.hpp"

#include <llvm/IR/BasicBlock.h>
#include <llvm/IR/Constants.h>
#include <llvm/IR/Function.h>
#include <llvm/IR/GlobalVariable.h>
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

llvm::Type* i8_ptr(llvm::LLVMContext& ctx) {
  return llvm::PointerType::getUnqual(llvm::Type::getInt8Ty(ctx));
}

llvm::Type* llvm_scalar(llvm::LLVMContext& ctx, bool is_float) {
  return is_float ? llvm::Type::getDoubleTy(ctx) : llvm::Type::getInt32Ty(ctx);
}

llvm::Value* int32_val(llvm::IRBuilder<>& builder, llvm::LLVMContext& ctx, std::int64_t v) {
  return llvm::ConstantInt::get(llvm::Type::getInt32Ty(ctx), v);
}

llvm::GlobalVariable* emit_string_global(llvm::Module* module, const std::string& text,
                                         int& counter) {
  llvm::LLVMContext& ctx = module->getContext();
  std::string name = ".str." + std::to_string(counter++);
  const std::size_t len = text.size() + 1;
  llvm::ArrayType* arr_ty = llvm::ArrayType::get(llvm::Type::getInt8Ty(ctx), len);
  llvm::Constant* init =
      llvm::ConstantDataArray::getString(ctx, text, true);
  auto* gv = new llvm::GlobalVariable(*module, arr_ty, true,
                                      llvm::GlobalValue::PrivateLinkage, init, name);
  return gv;
}

llvm::Value* string_ptr(llvm::IRBuilder<>& builder, llvm::GlobalVariable* gv) {
  llvm::Value* zero = llvm::ConstantInt::get(builder.getInt32Ty(), 0);
  llvm::Value* indices[] = {zero, zero};
  return builder.CreateInBoundsGEP(gv->getValueType(), gv, indices);
}

llvm::Value* resolve_index(llvm::IRBuilder<>& builder, llvm::LLVMContext& ctx,
                           const MirInsn& ins,
                           const std::map<std::string, llvm::Value*>& locals) {
  if (ins.index_is_literal) {
    return int32_val(builder, ctx, ins.int_value);
  }
  auto it = locals.find(ins.index_ident);
  if (it != locals.end()) {
    return it->second;
  }
  return int32_val(builder, ctx, 0);
}

llvm::Value* resolve_rhs_int(llvm::IRBuilder<>& builder, llvm::LLVMContext& ctx,
                             const MirInsn& ins,
                             const std::map<std::string, llvm::Value*>& locals) {
  if (ins.rhs_is_literal) {
    return int32_val(builder, ctx, ins.rhs_int);
  }
  auto it = locals.find(ins.rhs_ident);
  if (it != locals.end()) {
    return it->second;
  }
  return int32_val(builder, ctx, 0);
}

struct ArraySlot {
  llvm::AllocaInst* alloca = nullptr;
  std::int64_t size = 0;
};

}  // namespace

bool emit_llvm_ir(const MirModule& mir, const std::string& out_path, std::string* error) {
  llvm::LLVMContext context;
  auto module = std::make_unique<llvm::Module>("li", context);
  llvm::IRBuilder<> decl_builder(context);

  module->getOrInsertFunction("li_rt_print_int",
                              llvm::FunctionType::get(llvm::Type::getVoidTy(context),
                                                      {llvm::Type::getInt32Ty(context)}, false));
  module->getOrInsertFunction("li_rt_print_str",
                              llvm::FunctionType::get(llvm::Type::getVoidTy(context),
                                                      {i8_ptr(context)}, false));
  module->getOrInsertFunction("li_bounds_fail",
                              llvm::FunctionType::get(llvm::Type::getVoidTy(context), {}, false));

  int str_counter = 0;
  const llvm::Function* user_main = nullptr;

  for (const auto& fn : mir.functions) {
    if (fn.is_extern) {
      llvm::Type* ret_ty = llvm_scalar(context, fn.returns_float);
      std::vector<llvm::Type*> param_tys;
      for (const auto& p : fn.params) {
        if (p.is_string) {
          param_tys.push_back(i8_ptr(context));
        } else {
          param_tys.push_back(llvm_scalar(context, p.is_float));
        }
      }
      llvm::FunctionType* fn_ty = llvm::FunctionType::get(ret_ty, param_tys, false);
      llvm::Function::Create(fn_ty, llvm::Function::ExternalLinkage, fn.name, module.get());
      continue;
    }

    llvm::Type* ret_ty = llvm_scalar(context, fn.returns_float);
    std::vector<llvm::Type*> param_tys;
    for (const auto& p : fn.params) {
      param_tys.push_back(llvm_scalar(context, p.is_float));
    }
    llvm::FunctionType* fn_ty = llvm::FunctionType::get(ret_ty, param_tys, false);
    llvm::Function* func =
        llvm::Function::Create(fn_ty, llvm::Function::ExternalLinkage, fn.name, module.get());
    if (fn.name == "main") {
      user_main = func;
    }

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

    std::map<std::string, ArraySlot> arrays;
    llvm::Value* pending_int = nullptr;

    for (const auto& ins : fn.body) {
      switch (ins.op) {
        case MirOp::ReturnVoid:
          builder.CreateRet(fn.returns_float ? llvm::ConstantFP::get(ret_ty, 0.0)
                                           : llvm::ConstantInt::get(ret_ty, 0));
          break;
        case MirOp::ReturnInt:
          if (ins.use_loaded_int && pending_int) {
            builder.CreateRet(pending_int);
          } else {
            builder.CreateRet(llvm::ConstantInt::get(ret_ty, ins.int_value));
          }
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
        case MirOp::EchoInt: {
          llvm::Function* rt_fn = module->getFunction("li_rt_print_int");
          llvm::Value* val;
          if (!ins.ident.empty()) {
            auto it = locals.find(ins.ident);
            val = (it != locals.end()) ? it->second : int32_val(builder, context, 0);
          } else {
            val = int32_val(builder, context, ins.int_value);
          }
          builder.CreateCall(rt_fn, {val});
          break;
        }
        case MirOp::EchoString: {
          llvm::Function* rt_fn = module->getFunction("li_rt_print_str");
          llvm::GlobalVariable* gv = emit_string_global(module.get(), ins.str_value, str_counter);
          builder.CreateCall(rt_fn, {string_ptr(builder, gv)});
          break;
        }
        case MirOp::CallExtern: {
          llvm::Function* callee = module->getFunction(ins.callee);
          if (!callee) {
            break;
          }
          std::vector<llvm::Value*> args;
          if (!ins.str_value.empty()) {
            llvm::GlobalVariable* gv = emit_string_global(module.get(), ins.str_value, str_counter);
            args.push_back(string_ptr(builder, gv));
          } else if (!ins.ident.empty()) {
            auto it = locals.find(ins.ident);
            args.push_back(it != locals.end() ? it->second : int32_val(builder, context, 0));
          } else if (ins.rhs_is_literal) {
            args.push_back(int32_val(builder, context, ins.rhs_int));
          }
          builder.CreateCall(callee, args);
          break;
        }
        case MirOp::ArrayAlloc: {
          llvm::ArrayType* arr_ty =
              llvm::ArrayType::get(llvm::Type::getInt32Ty(context),
                                   static_cast<unsigned>(ins.int_value));
          llvm::AllocaInst* slot = builder.CreateAlloca(arr_ty, nullptr, ins.ident);
          arrays[ins.ident] = ArraySlot{slot, ins.int_value};
          break;
        }
        case MirOp::ArrayStoreInt: {
          auto it = arrays.find(ins.ident);
          if (it == arrays.end()) {
            break;
          }
          llvm::Value* idx = resolve_index(builder, context, ins, locals);
          llvm::Value* zero = llvm::ConstantInt::get(builder.getInt32Ty(), 0);
          llvm::Value* gep_indices[] = {zero, idx};
          llvm::Value* ptr =
              builder.CreateInBoundsGEP(it->second.alloca->getAllocatedType(), it->second.alloca,
                                        gep_indices);
          llvm::Value* val = resolve_rhs_int(builder, context, ins, locals);
          builder.CreateStore(val, ptr);
          break;
        }
        case MirOp::ArrayLoadInt: {
          auto it = arrays.find(ins.ident);
          if (it == arrays.end()) {
            break;
          }
          llvm::Value* idx = resolve_index(builder, context, ins, locals);
          llvm::Value* zero = llvm::ConstantInt::get(builder.getInt32Ty(), 0);
          llvm::Value* gep_indices[] = {zero, idx};
          llvm::Value* ptr =
              builder.CreateInBoundsGEP(it->second.alloca->getAllocatedType(), it->second.alloca,
                                        gep_indices);
          pending_int = builder.CreateLoad(llvm::Type::getInt32Ty(context), ptr);
          break;
        }
      }
    }
  }

  if (!user_main) {
    llvm::FunctionType* main_ty =
        llvm::FunctionType::get(llvm::Type::getInt32Ty(context), {}, false);
    llvm::Function* main_fn =
        llvm::Function::Create(main_ty, llvm::Function::ExternalLinkage, "main", module.get());
    llvm::BasicBlock* main_entry = llvm::BasicBlock::Create(context, "entry", main_fn);
    llvm::IRBuilder<> main_builder(main_entry);
    main_builder.CreateRet(llvm::ConstantInt::get(llvm::Type::getInt32Ty(context), 0));
  }

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
