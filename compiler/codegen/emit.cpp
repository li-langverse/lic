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
#include <unordered_map>
#include <vector>

namespace li {

namespace {

llvm::Type* i8_ptr(llvm::LLVMContext& ctx) {
  return llvm::PointerType::getUnqual(llvm::Type::getInt8Ty(ctx));
}

llvm::Type* i32_ty(llvm::LLVMContext& ctx) {
  return llvm::Type::getInt32Ty(ctx);
}

llvm::Type* i64_ty(llvm::LLVMContext& ctx) {
  return llvm::Type::getInt64Ty(ctx);
}

llvm::Type* llvm_scalar(llvm::LLVMContext& ctx, bool is_float, bool is_i64, bool is_string = false) {
  if (is_string) {
    return i8_ptr(ctx);
  }
  if (is_i64) {
    return i64_ty(ctx);
  }
  return is_float ? llvm::Type::getDoubleTy(ctx) : i32_ty(ctx);
}

llvm::Type* llvm_array_type(llvm::LLVMContext& ctx, const MirParam& p) {
  llvm::Type* elem = llvm_scalar(ctx, p.is_float, p.is_i64, p.is_string);
  return llvm::ArrayType::get(elem, static_cast<unsigned>(p.fixed_array_elems));
}

llvm::Type* llvm_type_for_mir_param(llvm::LLVMContext& ctx, const MirParam& p) {
  if (p.fixed_array_elems > 0) {
    return llvm_array_type(ctx, p);
  }
  return llvm_scalar(ctx, p.is_float, p.is_i64, p.is_string);
}

llvm::Type* llvm_array_param_ptr(llvm::LLVMContext& ctx, const MirParam& p) {
  return llvm::PointerType::getUnqual(llvm_array_type(ctx, p));
}

llvm::Type* llvm_struct_from_layout(llvm::LLVMContext& ctx, const std::vector<MirParam>& layout) {
  std::vector<llvm::Type*> elems;
  elems.reserve(layout.size());
  for (const auto& p : layout) {
    elems.push_back(llvm_type_for_mir_param(ctx, p));
  }
  if (elems.empty()) {
    return llvm::Type::getVoidTy(ctx);
  }
  return llvm::StructType::get(ctx, elems);
}

llvm::Value* int32_val(llvm::IRBuilder<>& builder, llvm::LLVMContext& ctx, std::int64_t v) {
  return llvm::ConstantInt::get(i32_ty(ctx), v);
}

llvm::GlobalVariable* emit_string_global(llvm::Module* module, const std::string& text,
                                         int& counter) {
  llvm::LLVMContext& ctx = module->getContext();
  std::string name = ".str." + std::to_string(counter++);
  const std::size_t len = text.size() + 1;
  llvm::ArrayType* arr_ty = llvm::ArrayType::get(llvm::Type::getInt8Ty(ctx), len);
  llvm::Constant* init = llvm::ConstantDataArray::getString(ctx, text, true);
  auto* gv = new llvm::GlobalVariable(*module, arr_ty, true,
                                      llvm::GlobalValue::PrivateLinkage, init, name);
  return gv;
}

llvm::Value* string_ptr(llvm::IRBuilder<>& builder, llvm::GlobalVariable* gv) {
  llvm::Value* zero = llvm::ConstantInt::get(builder.getInt32Ty(), 0);
  llvm::Value* indices[] = {zero, zero};
  return builder.CreateInBoundsGEP(gv->getValueType(), gv, indices);
}

struct ArraySlot {
  llvm::AllocaInst* alloca = nullptr;
  std::int64_t size = 0;
  std::int64_t cols = 0;
  bool is_float = false;
  bool is_matrix = false;
};

struct EmitCtx {
  llvm::LLVMContext& context;
  llvm::Module* module;
  llvm::Function* func;
  llvm::IRBuilder<>* builder;
  llvm::Type* ret_ty = nullptr;
  bool returns_float = false;
  bool returns_i64 = false;
  bool returns_object = false;
  bool fp_numerically_stable = false;
  bool enable_array_simd = true;
  std::vector<bool> array_simd_scope_stack;
  std::map<std::string, llvm::AllocaInst*> int_locals;
  std::map<std::string, llvm::AllocaInst*> float_locals;
  std::map<std::string, llvm::AllocaInst*> i64_locals;
  std::map<std::string, llvm::AllocaInst*> ptr_locals;
  std::map<std::string, ArraySlot> arrays;
  std::map<std::string, llvm::AllocaInst*> simd_f64x4_locals;
  std::unordered_map<std::string, llvm::BasicBlock*> labels;
  int str_counter = 0;

  llvm::Type* vec4_f64() const {
    return llvm::VectorType::get(llvm::Type::getDoubleTy(context),
                                 llvm::ElementCount::getFixed(4));
  }

  bool array_simd_enabled() const {
    if (!array_simd_scope_stack.empty()) {
      return array_simd_scope_stack.back();
    }
    return enable_array_simd;
  }

  llvm::AllocaInst* ensure_simd_f64x4(const std::string& name) {
    auto it = simd_f64x4_locals.find(name);
    if (it != simd_f64x4_locals.end()) {
      return it->second;
    }
    llvm::AllocaInst* slot = builder->CreateAlloca(vec4_f64(), nullptr, name);
    simd_f64x4_locals[name] = slot;
    return slot;
  }

  llvm::Value* load_simd_f64x4(const std::string& name) {
    return builder->CreateLoad(vec4_f64(), ensure_simd_f64x4(name));
  }

  llvm::Value* horiz_sum_f64x4(llvm::Value* vec) {
    llvm::Type* f64 = llvm::Type::getDoubleTy(context);
    llvm::Value* sum = llvm::ConstantFP::get(f64, 0.0);
    for (unsigned lane = 0; lane < 4; ++lane) {
      llvm::Value* elt = builder->CreateExtractElement(
          vec, llvm::ConstantInt::get(i32_ty(context), lane));
      sum = builder->CreateFAdd(sum, elt);
    }
    return sum;
  }

  llvm::Value* gather_array_f64x4(llvm::AllocaInst* alloca, unsigned start) {
    llvm::Type* f64 = llvm::Type::getDoubleTy(context);
    llvm::Value* zero = llvm::ConstantInt::get(builder->getInt32Ty(), 0);
    llvm::Type* arr_ty = alloca->getAllocatedType();
    llvm::Value* vec = llvm::UndefValue::get(vec4_f64());
    for (unsigned lane = 0; lane < 4; ++lane) {
      llvm::Value* idx = llvm::ConstantInt::get(i32_ty(context), start + lane);
      llvm::Value* gep_idx[] = {zero, idx};
      llvm::Value* ptr = builder->CreateInBoundsGEP(arr_ty, alloca, gep_idx);
      llvm::Value* scalar = builder->CreateLoad(f64, ptr);
      vec = builder->CreateInsertElement(
          vec, scalar, llvm::ConstantInt::get(i32_ty(context), lane));
    }
    return vec;
  }

  void scatter_array_f64x4(llvm::AllocaInst* alloca, unsigned start, llvm::Value* vec) {
    llvm::Type* f64 = llvm::Type::getDoubleTy(context);
    llvm::Value* zero = llvm::ConstantInt::get(builder->getInt32Ty(), 0);
    llvm::Type* arr_ty = alloca->getAllocatedType();
    for (unsigned lane = 0; lane < 4; ++lane) {
      llvm::Value* idx = llvm::ConstantInt::get(i32_ty(context), start + lane);
      llvm::Value* gep_idx[] = {zero, idx};
      llvm::Value* ptr = builder->CreateInBoundsGEP(arr_ty, alloca, gep_idx);
      llvm::Value* scalar = builder->CreateExtractElement(
          vec, llvm::ConstantInt::get(i32_ty(context), lane));
      builder->CreateStore(scalar, ptr);
    }
  }

  llvm::AllocaInst* ensure_int_local(const std::string& name) {
    auto it = int_locals.find(name);
    if (it != int_locals.end()) {
      return it->second;
    }
    llvm::AllocaInst* slot =
        builder->CreateAlloca(i32_ty(context), nullptr, name);
    int_locals[name] = slot;
    return slot;
  }

  llvm::AllocaInst* ensure_float_local(const std::string& name) {
    auto it = float_locals.find(name);
    if (it != float_locals.end()) {
      return it->second;
    }
    llvm::AllocaInst* slot =
        builder->CreateAlloca(llvm::Type::getDoubleTy(context), nullptr, name);
    float_locals[name] = slot;
    return slot;
  }

  llvm::Value* load_float(const std::string& name) {
    return builder->CreateLoad(llvm::Type::getDoubleTy(context), ensure_float_local(name));
  }

  llvm::AllocaInst* ensure_ptr_local(const std::string& name) {
    auto it = ptr_locals.find(name);
    if (it != ptr_locals.end()) {
      return it->second;
    }
    llvm::AllocaInst* slot =
        builder->CreateAlloca(i8_ptr(context), nullptr, name);
    ptr_locals[name] = slot;
    return slot;
  }

  llvm::Value* load_ptr(const std::string& name) {
    if (auto it = ptr_locals.find(name); it != ptr_locals.end()) {
      return builder->CreateLoad(i8_ptr(context), it->second);
    }
    if (auto it64 = i64_locals.find(name); it64 != i64_locals.end()) {
      return builder->CreateIntToPtr(
          builder->CreateLoad(i64_ty(context), it64->second), i8_ptr(context));
    }
    return llvm::ConstantPointerNull::get(llvm::cast<llvm::PointerType>(i8_ptr(context)));
  }

  llvm::AllocaInst* ensure_i64_local(const std::string& name) {
    auto it = i64_locals.find(name);
    if (it != i64_locals.end()) {
      return it->second;
    }
    llvm::AllocaInst* slot =
        builder->CreateAlloca(i64_ty(context), nullptr, name);
    i64_locals[name] = slot;
    return slot;
  }

  llvm::Value* load_int(const std::string& name) {
    if (auto it = float_locals.find(name); it != float_locals.end()) {
      return builder->CreateFPToSI(
          builder->CreateLoad(llvm::Type::getDoubleTy(context), it->second), i32_ty(context));
    }
    if (auto it64 = i64_locals.find(name); it64 != i64_locals.end()) {
      return builder->CreateTrunc(
          builder->CreateLoad(i64_ty(context), it64->second), i32_ty(context));
    }
    return builder->CreateLoad(i32_ty(context), ensure_int_local(name));
  }

  llvm::Value* load_i64(const std::string& name) {
    if (auto it = i64_locals.find(name); it != i64_locals.end()) {
      return builder->CreateLoad(i64_ty(context), it->second);
    }
    return builder->CreateSExt(load_int(name), i64_ty(context));
  }

  llvm::BasicBlock* block_for(const std::string& label) {
    auto it = labels.find(label);
    if (it != labels.end()) {
      return it->second;
    }
    llvm::BasicBlock* bb = llvm::BasicBlock::Create(context, label, func);
    labels[label] = bb;
    return bb;
  }

  llvm::Function* rt_fn_i32_i32(const char* name) {
    if (llvm::Function* f = module->getFunction(name)) {
      return f;
    }
    llvm::FunctionType* ft =
        llvm::FunctionType::get(i32_ty(context), {i32_ty(context), i32_ty(context)}, false);
    return llvm::Function::Create(ft, llvm::Function::ExternalLinkage, name, module);
  }

  llvm::Value* call_rt_i32_i32(const char* name, llvm::Value* a, llvm::Value* b) {
    return builder->CreateCall(rt_fn_i32_i32(name), {a, b});
  }

  llvm::Value* emit_binop(BinOp op, llvm::Value* lhs, llvm::Value* rhs) {
    switch (op) {
      case BinOp::Add:
        return builder->CreateAdd(lhs, rhs);
      case BinOp::Sub:
        return builder->CreateSub(lhs, rhs);
      case BinOp::Mul:
        return builder->CreateMul(lhs, rhs);
      case BinOp::Div:
        return builder->CreateSDiv(lhs, rhs);
      case BinOp::Mod:
        return builder->CreateSRem(lhs, rhs);
      case BinOp::FloorDiv:
        return call_rt_i32_i32("li_rt_floor_div_i32", lhs, rhs);
      case BinOp::Pow:
        return call_rt_i32_i32("li_rt_pow_i32", lhs, rhs);
      case BinOp::Lt:
        return builder->CreateZExt(
            builder->CreateICmpSLT(lhs, rhs), i32_ty(context));
      case BinOp::Le:
        return builder->CreateZExt(
            builder->CreateICmpSLE(lhs, rhs), i32_ty(context));
      case BinOp::Gt:
        return builder->CreateZExt(
            builder->CreateICmpSGT(lhs, rhs), i32_ty(context));
      case BinOp::Ge:
        return builder->CreateZExt(
            builder->CreateICmpSGE(lhs, rhs), i32_ty(context));
      case BinOp::Eq:
        return builder->CreateZExt(
            builder->CreateICmpEQ(lhs, rhs), i32_ty(context));
      case BinOp::Ne:
        return builder->CreateZExt(
            builder->CreateICmpNE(lhs, rhs), i32_ty(context));
      case BinOp::And:
        return builder->CreateAnd(lhs, rhs);
      case BinOp::Or:
        return builder->CreateOr(lhs, rhs);
    }
    return lhs;
  }

  llvm::Value* emit_fbinop(BinOp op, llvm::Value* lhs, llvm::Value* rhs) {
    switch (op) {
      case BinOp::Add:
        return builder->CreateFAdd(lhs, rhs);
      case BinOp::Sub:
        return builder->CreateFSub(lhs, rhs);
      case BinOp::Mul:
        return builder->CreateFMul(lhs, rhs);
      case BinOp::Div:
        return builder->CreateFDiv(lhs, rhs);
      default:
        return lhs;
    }
  }

  llvm::Value* mir_arg_value(const MirArg& arg, bool ptr_param = false) {
    if (arg.is_string) {
      llvm::GlobalVariable* gv = emit_string_global(module, arg.str_value, str_counter);
      return string_ptr(*builder, gv);
    }
    if (arg.is_float_literal) {
      return llvm::ConstantFP::get(llvm::Type::getDoubleTy(context), arg.float_value);
    }
    if (arg.is_literal) {
      return int32_val(*builder, context, arg.int_value);
    }
    if (arg.is_array_ident) {
      if (auto a_it = arrays.find(arg.ident); a_it != arrays.end()) {
        return a_it->second.alloca;
      }
    }
    if (auto a_it = arrays.find(arg.ident); a_it != arrays.end()) {
      llvm::Type* arr_ty = a_it->second.alloca->getAllocatedType();
      return builder->CreateLoad(arr_ty, a_it->second.alloca);
    }
    if (float_locals.find(arg.ident) != float_locals.end()) {
      return load_float(arg.ident);
    }
    if (ptr_param || ptr_locals.find(arg.ident) != ptr_locals.end()) {
      return load_ptr(arg.ident);
    }
    if (i64_locals.find(arg.ident) != i64_locals.end()) {
      return load_i64(arg.ident);
    }
    return load_int(arg.ident);
  }

  bool emit_insn(const MirInsn& ins) {
    switch (ins.op) {
      case MirOp::Label: {
        llvm::BasicBlock* dest = block_for(ins.label);
        if (builder->GetInsertBlock() != nullptr &&
            builder->GetInsertBlock()->getTerminator() == nullptr) {
          builder->CreateBr(dest);
        }
        builder->SetInsertPoint(dest);
        return true;
      }
      case MirOp::Jump:
        builder->CreateBr(block_for(ins.label));
        return false;
      case MirOp::BranchIfZero: {
        llvm::Value* cond = load_int(ins.ident);
        llvm::Value* zero = int32_val(*builder, context, 0);
        llvm::Value* is_zero = builder->CreateICmpEQ(cond, zero);
        llvm::BasicBlock* dest = block_for(ins.label);
        llvm::BasicBlock* fall =
            llvm::BasicBlock::Create(context, "br_fall", func);
        builder->CreateCondBr(is_zero, dest, fall);
        builder->SetInsertPoint(fall);
        return true;
      }
      case MirOp::ReturnVoid:
        if (ret_ty->isVoidTy()) {
          builder->CreateRetVoid();
        } else if (returns_object && ret_ty->isStructTy()) {
          builder->CreateRet(llvm::ConstantAggregateZero::get(ret_ty));
        } else {
          builder->CreateRet(returns_float ? llvm::ConstantFP::get(ret_ty, 0.0)
                                           : llvm::ConstantInt::get(ret_ty, 0));
        }
        return false;
      case MirOp::ReturnInt:
        builder->CreateRet(int32_val(*builder, context, ins.int_value));
        return false;
      case MirOp::ReturnFloat:
        builder->CreateRet(llvm::ConstantFP::get(llvm::Type::getDoubleTy(context),
                                                    ins.float_value));
        return false;
      case MirOp::ReturnIdent:
        if (ins.ret_is_float || returns_float || float_locals.count(ins.ident) > 0) {
          builder->CreateRet(load_float(ins.ident));
        } else if (ins.ret_is_i64 || returns_i64 || i64_locals.count(ins.ident) > 0) {
          llvm::Value* wide = load_i64(ins.ident);
          if (ret_ty->isPointerTy()) {
            builder->CreateRet(builder->CreateIntToPtr(wide, ret_ty));
          } else {
            builder->CreateRet(wide);
          }
        } else {
          builder->CreateRet(load_int(ins.ident));
        }
        return false;
      case MirOp::ReturnObject: {
        auto* st = llvm::dyn_cast<llvm::StructType>(ret_ty);
        if (!st || ins.object_layout.empty()) {
          builder->CreateRetVoid();
          return false;
        }
        llvm::Value* agg = llvm::UndefValue::get(st);
        for (unsigned i = 0; i < ins.object_layout.size(); ++i) {
          const MirParam& leaf = ins.object_layout[i];
          const std::string full = ins.ident + "_" + leaf.name;
          llvm::Value* v = nullptr;
          if (leaf.fixed_array_elems > 0) {
            auto a_it = arrays.find(full);
            if (a_it != arrays.end()) {
              llvm::Type* arr_ty = a_it->second.alloca->getAllocatedType();
              v = builder->CreateLoad(arr_ty, a_it->second.alloca);
            }
          } else {
            v = leaf.is_float ? load_float(full)
                            : (leaf.is_i64 || leaf.is_string ? load_i64(full) : load_int(full));
          }
          if (!v) {
            continue;
          }
          llvm::Type* want = st->getElementType(i);
          if (v->getType() != want) {
            if (want->isIntegerTy(32) && v->getType()->isIntegerTy(64)) {
              v = builder->CreateTrunc(v, want);
            } else if (want->isIntegerTy(64) && v->getType()->isIntegerTy(32)) {
              v = builder->CreateSExt(v, want);
            }
          }
          agg = builder->CreateInsertValue(agg, v, i);
        }
        builder->CreateRet(agg);
        return false;
      }
      case MirOp::LocalAllocInt:
        (void)ensure_int_local(ins.ident);
        return true;
      case MirOp::LocalAllocFloat:
        (void)ensure_float_local(ins.ident);
        return true;
      case MirOp::LocalAllocI64:
        (void)ensure_i64_local(ins.ident);
        return true;
      case MirOp::StoreInt: {
        llvm::Value* val = ins.rhs_is_literal ? int32_val(*builder, context, ins.rhs_int)
                                              : load_int(ins.rhs_ident);
        builder->CreateStore(val, ensure_int_local(ins.ident));
        return true;
      }
      case MirOp::StoreI64: {
        llvm::Value* val = ins.rhs_is_literal
                               ? llvm::ConstantInt::get(i64_ty(context), ins.rhs_int)
                               : load_i64(ins.rhs_ident);
        builder->CreateStore(val, ensure_i64_local(ins.ident));
        return true;
      }
      case MirOp::StoreFloat: {
        llvm::Value* val = ins.rhs_is_literal
                               ? llvm::ConstantFP::get(llvm::Type::getDoubleTy(context),
                                                       ins.float_value)
                               : load_float(ins.rhs_ident);
        builder->CreateStore(val, ensure_float_local(ins.ident));
        return true;
      }
      case MirOp::BinOpInt: {
        llvm::Value* lhs = load_int(ins.lhs_ident);
        llvm::Value* rhs = load_int(ins.rhs_ident);
        llvm::Value* result = emit_binop(ins.bin_op, lhs, rhs);
        builder->CreateStore(result, ensure_int_local(ins.ident));
        return true;
      }
      case MirOp::BinOpFloat: {
        llvm::Value* lhs = load_float(ins.lhs_ident);
        llvm::Value* rhs = load_float(ins.rhs_ident);
        llvm::Value* result = emit_fbinop(ins.bin_op, lhs, rhs);
        builder->CreateStore(result, ensure_float_local(ins.ident));
        return true;
      }
      case MirOp::EchoInt: {
        llvm::Function* rt_fn = module->getFunction("li_rt_print_int");
        llvm::Value* val = ins.ident.empty() ? int32_val(*builder, context, ins.int_value)
                                             : load_int(ins.ident);
        builder->CreateCall(rt_fn, {val});
        return true;
      }
      case MirOp::EchoString: {
        llvm::Function* rt_fn = module->getFunction("li_rt_print_str");
        llvm::GlobalVariable* gv = emit_string_global(module, ins.str_value, str_counter);
        builder->CreateCall(rt_fn, {string_ptr(*builder, gv)});
        return true;
      }
      case MirOp::CallExtern: {
        llvm::Function* callee = module->getFunction(ins.callee);
        if (!callee) {
          return true;
        }
        std::vector<llvm::Value*> args;
        for (std::size_t ai = 0; ai < ins.args.size(); ++ai) {
          const bool ptr_param =
              ai < callee->arg_size() &&
              callee->getArg(ai)->getType() == i8_ptr(context);
          llvm::Value* val = mir_arg_value(ins.args[ai], ptr_param);
          if (ptr_param && val->getType() == i64_ty(context)) {
            val = builder->CreateIntToPtr(val, i8_ptr(context));
          }
          args.push_back(val);
        }
        llvm::CallInst* call = builder->CreateCall(callee, args);
        if (!ins.ident.empty()) {
          if (ins.is_i64) {
            llvm::Value* wide = call;
            if (wide->getType()->isPointerTy()) {
              wide = builder->CreatePtrToInt(wide, i64_ty(context));
            } else if (wide->getType()->isIntegerTy(32)) {
              wide = builder->CreateSExt(wide, i64_ty(context));
            }
            builder->CreateStore(wide, ensure_i64_local(ins.ident));
          } else if (ins.ret_is_float) {
            builder->CreateStore(call, ensure_float_local(ins.ident));
          } else {
            builder->CreateStore(call, ensure_int_local(ins.ident));
          }
        }
        return true;
      }
      case MirOp::CallProc: {
        llvm::Function* callee = module->getFunction(ins.callee);
        if (!callee) {
          return true;
        }
        std::vector<llvm::Value*> args;
        for (std::size_t ai = 0; ai < ins.args.size(); ++ai) {
          const bool ptr_param =
              ai < callee->arg_size() &&
              callee->getArg(ai)->getType() == i8_ptr(context);
          llvm::Value* val = mir_arg_value(ins.args[ai], ptr_param);
          if (ptr_param && val->getType() == i64_ty(context)) {
            val = builder->CreateIntToPtr(val, i8_ptr(context));
          }
          if (ai < callee->arg_size()) {
            llvm::Type* want = callee->getArg(ai)->getType();
            if (want != val->getType()) {
              if (want->isDoubleTy() && val->getType()->isIntegerTy(32)) {
                val = builder->CreateSIToFP(val, want);
              } else if (want->isIntegerTy(32) && val->getType()->isDoubleTy()) {
                val = builder->CreateFPTrunc(val, llvm::Type::getFloatTy(context));
                val = builder->CreateBitCast(val, want);
              } else if (want->isIntegerTy(32) && val->getType()->isFloatTy()) {
                val = builder->CreateBitCast(val, want);
              }
            }
          }
          args.push_back(val);
        }
        llvm::CallInst* call = builder->CreateCall(callee, args);
        if (callee->getReturnType()->isVoidTy()) {
          return true;
        }
        if (!ins.object_layout.empty() && callee->getReturnType()->isStructTy()) {
          llvm::Value* agg = call;
          auto* st = llvm::cast<llvm::StructType>(callee->getReturnType());
          for (unsigned i = 0; i < ins.object_layout.size(); ++i) {
            const MirParam& leaf = ins.object_layout[i];
            const std::string full = ins.ident + "_" + leaf.name;
            llvm::Value* elt = builder->CreateExtractValue(agg, i);
            llvm::Type* want = st->getElementType(i);
            if (leaf.fixed_array_elems > 0) {
              auto a_it = arrays.find(full);
              if (a_it != arrays.end() && elt->getType() == a_it->second.alloca->getAllocatedType()) {
                builder->CreateStore(elt, a_it->second.alloca);
              }
              continue;
            }
            if (elt->getType() != want) {
              if (want->isIntegerTy(32) && elt->getType()->isIntegerTy(64)) {
                elt = builder->CreateTrunc(elt, want);
              } else if (want->isIntegerTy(64) && elt->getType()->isIntegerTy(32)) {
                elt = builder->CreateSExt(elt, want);
              }
            }
            if (leaf.is_float) {
              builder->CreateStore(elt, ensure_float_local(full));
            } else if (leaf.is_i64 || leaf.is_string) {
              builder->CreateStore(elt, ensure_i64_local(full));
            } else {
              builder->CreateStore(elt, ensure_int_local(full));
            }
          }
          return true;
        }
        if (!ins.ident.empty()) {
          if (ins.ret_is_float) {
            builder->CreateStore(call, ensure_float_local(ins.ident));
          } else if (ins.ret_is_i64) {
            llvm::Value* wide = call;
            if (wide->getType()->isPointerTy()) {
              wide = builder->CreatePtrToInt(wide, i64_ty(context));
            } else if (wide->getType()->isIntegerTy(32)) {
              wide = builder->CreateSExt(wide, i64_ty(context));
            }
            builder->CreateStore(wide, ensure_i64_local(ins.ident));
          } else {
            builder->CreateStore(call, ensure_int_local(ins.ident));
          }
        }
        return true;
      }
      case MirOp::LocalAllocSimdF64:
        (void)ensure_simd_f64x4(ins.ident);
        return true;
      case MirOp::SimdSplatF64: {
        llvm::Value* scalar = ins.rhs_is_literal
                                  ? llvm::ConstantFP::get(llvm::Type::getDoubleTy(context),
                                                          ins.float_value)
                                  : load_float(ins.rhs_ident);
        llvm::Value* vec = builder->CreateVectorSplat(4, scalar);
        builder->CreateStore(vec, ensure_simd_f64x4(ins.ident));
        return true;
      }
      case MirOp::SimdMulF64:
      case MirOp::SimdAddF64: {
        llvm::Value* lhs = load_simd_f64x4(ins.lhs_ident);
        llvm::Value* rhs = load_simd_f64x4(ins.rhs_ident);
        llvm::Value* result = ins.op == MirOp::SimdMulF64 ? builder->CreateFMul(lhs, rhs)
                                                          : builder->CreateFAdd(lhs, rhs);
        builder->CreateStore(result, ensure_simd_f64x4(ins.ident));
        return true;
      }
      case MirOp::SimdHorizSumF64: {
        llvm::Value* vec = load_simd_f64x4(ins.lhs_ident);
        llvm::Value* sum = llvm::ConstantFP::get(llvm::Type::getDoubleTy(context), 0.0);
        for (unsigned i = 0; i < 4; ++i) {
          llvm::Value* elt = builder->CreateExtractElement(vec, llvm::ConstantInt::get(i32_ty(context), i));
          sum = builder->CreateFAdd(sum, elt);
        }
        builder->CreateStore(sum, ensure_float_local(ins.ident));
        return true;
      }
      case MirOp::SimdCopyF64: {
        llvm::Value* vec = load_simd_f64x4(ins.rhs_ident);
        builder->CreateStore(vec, ensure_simd_f64x4(ins.ident));
        return true;
      }
      case MirOp::OmpParallelFor: {
        llvm::Function* par_fn = module->getFunction(ins.callee);
        if (!par_fn) {
          return true;
        }
        llvm::FunctionType* iter_ty =
            llvm::FunctionType::get(llvm::Type::getVoidTy(context), {i64_ty(context)}, false);
        llvm::FunctionType* omp_ty = llvm::FunctionType::get(
            llvm::Type::getVoidTy(context),
            {i64_ty(context), i64_ty(context), iter_ty->getPointerTo()}, false);
        llvm::FunctionCallee omp_rt =
            module->getOrInsertFunction("li_omp_parallel_for_i64", omp_ty);
        builder->CreateCall(
            omp_rt,
            {llvm::ConstantInt::get(i64_ty(context), ins.int_value),
             llvm::ConstantInt::get(i64_ty(context), ins.rhs_int), par_fn});
        return true;
      }
      case MirOp::ArrayAlloc: {
        llvm::AllocaInst* slot = nullptr;
        if (ins.array_is_matrix) {
          llvm::Type* f64 = llvm::Type::getDoubleTy(context);
          llvm::ArrayType* row_ty =
              llvm::ArrayType::get(f64, static_cast<unsigned>(ins.rhs_int));
          llvm::ArrayType* mat_ty =
              llvm::ArrayType::get(row_ty, static_cast<unsigned>(ins.int_value));
          slot = builder->CreateAlloca(mat_ty, nullptr, ins.ident);
          arrays[ins.ident] = ArraySlot{slot, ins.int_value, ins.rhs_int, true, true};
        } else {
          llvm::Type* elem_ty = ins.array_is_float ? llvm::Type::getDoubleTy(context)
                                                   : i32_ty(context);
          llvm::ArrayType* arr_ty =
              llvm::ArrayType::get(elem_ty, static_cast<unsigned>(ins.int_value));
          slot = builder->CreateAlloca(arr_ty, nullptr, ins.ident);
          arrays[ins.ident] = ArraySlot{slot, ins.int_value, 0, ins.array_is_float, false};
        }
        return true;
      }
      case MirOp::ArrayStoreInt:
      case MirOp::ArrayStoreFloat: {
        auto it = arrays.find(ins.ident);
        if (it == arrays.end()) {
          return true;
        }
        llvm::Value* idx = ins.index_is_literal
                               ? int32_val(*builder, context, ins.int_value)
                               : load_int(ins.index_ident);
        llvm::Value* zero = llvm::ConstantInt::get(builder->getInt32Ty(), 0);
        llvm::Value* gep_indices[] = {zero, idx};
        llvm::Value* ptr = builder->CreateInBoundsGEP(
            it->second.alloca->getAllocatedType(), it->second.alloca, gep_indices);
        if (it->second.is_float || ins.op == MirOp::ArrayStoreFloat) {
          llvm::Value* val =
              ins.rhs_is_literal
                  ? llvm::ConstantFP::get(llvm::Type::getDoubleTy(context), ins.float_value)
                  : load_float(ins.rhs_ident);
          builder->CreateStore(val, ptr);
        } else {
          llvm::Value* val = ins.rhs_is_literal ? int32_val(*builder, context, ins.rhs_int)
                                                : load_int(ins.rhs_ident);
          builder->CreateStore(val, ptr);
        }
        return true;
      }
      case MirOp::ArrayLoadInt: {
        auto it = arrays.find(ins.ident);
        if (it == arrays.end()) {
          return true;
        }
        llvm::Value* idx = ins.index_is_literal
                               ? int32_val(*builder, context, ins.int_value)
                               : load_int(ins.index_ident);
        llvm::Value* zero = llvm::ConstantInt::get(builder->getInt32Ty(), 0);
        llvm::Value* gep_indices[] = {zero, idx};
        llvm::Value* ptr = builder->CreateInBoundsGEP(
            it->second.alloca->getAllocatedType(), it->second.alloca, gep_indices);
        if (it->second.is_float) {
          llvm::Value* loaded = builder->CreateLoad(llvm::Type::getDoubleTy(context), ptr);
          if (!ins.lhs_ident.empty()) {
            builder->CreateStore(loaded, ensure_float_local(ins.lhs_ident));
          }
        } else {
          llvm::Value* loaded = builder->CreateLoad(i32_ty(context), ptr);
          if (!ins.lhs_ident.empty()) {
            builder->CreateStore(loaded, ensure_int_local(ins.lhs_ident));
          }
        }
        return true;
      }
      case MirOp::ArrayLoadFloat:
        return true;
      case MirOp::ArraySumF64: {
        auto a_it = arrays.find(ins.lhs_ident);
        if (a_it == arrays.end()) {
          return true;
        }
        llvm::Type* f64 = llvm::Type::getDoubleTy(context);
        llvm::Value* sum = llvm::ConstantFP::get(f64, 0.0);
        llvm::Value* c_comp = llvm::ConstantFP::get(f64, 0.0);
        const auto n = static_cast<unsigned>(ins.int_value);
        for (unsigned i = 0; i < n; ++i) {
          llvm::Value* idx = llvm::ConstantInt::get(i32_ty(context), i);
          llvm::Value* zero = llvm::ConstantInt::get(builder->getInt32Ty(), 0);
          llvm::Value* gep_idx[] = {zero, idx};
          llvm::Value* ap = builder->CreateInBoundsGEP(
              a_it->second.alloca->getAllocatedType(), a_it->second.alloca, gep_idx);
          llvm::Value* y = builder->CreateLoad(f64, ap);
          if (fp_numerically_stable) {
            llvm::Value* y_adj = builder->CreateFSub(y, c_comp);
            llvm::Value* t = builder->CreateFAdd(sum, y_adj);
            c_comp = builder->CreateFSub(builder->CreateFSub(t, sum), y_adj);
            sum = t;
          } else {
            sum = builder->CreateFAdd(sum, y);
          }
        }
        builder->CreateStore(sum, ensure_float_local(ins.ident));
        return true;
      }
      case MirOp::ArraySumI64: {
        auto a_it = arrays.find(ins.lhs_ident);
        if (a_it == arrays.end()) {
          return true;
        }
        llvm::Value* acc = llvm::ConstantInt::get(i32_ty(context), 0);
        const auto n = static_cast<unsigned>(ins.int_value);
        for (unsigned i = 0; i < n; ++i) {
          llvm::Value* idx = llvm::ConstantInt::get(i32_ty(context), i);
          llvm::Value* zero = llvm::ConstantInt::get(builder->getInt32Ty(), 0);
          llvm::Value* gep_idx[] = {zero, idx};
          llvm::Value* ap = builder->CreateInBoundsGEP(
              a_it->second.alloca->getAllocatedType(), a_it->second.alloca, gep_idx);
          llvm::Value* av = builder->CreateLoad(i32_ty(context), ap);
          acc = builder->CreateAdd(acc, av);
        }
        builder->CreateStore(acc, ensure_int_local(ins.ident));
        return true;
      }
      case MirOp::ArrayBinOpF64: {
        auto d_it = arrays.find(ins.ident);
        auto a_it = arrays.find(ins.lhs_ident);
        auto b_it = arrays.find(ins.rhs_ident);
        if (d_it == arrays.end() || a_it == arrays.end() || b_it == arrays.end()) {
          return true;
        }
        llvm::Type* f64 = llvm::Type::getDoubleTy(context);
        const auto n = static_cast<unsigned>(ins.int_value);
        const unsigned simd_end = array_simd_enabled() ? (n / 4) * 4 : 0;
        for (unsigned i = 0; i < simd_end; i += 4) {
          llvm::Value* av = gather_array_f64x4(a_it->second.alloca, i);
          llvm::Value* bv = gather_array_f64x4(b_it->second.alloca, i);
          llvm::Value* rv = emit_fbinop(ins.bin_op, av, bv);
          scatter_array_f64x4(d_it->second.alloca, i, rv);
        }
        llvm::Value* zero = llvm::ConstantInt::get(builder->getInt32Ty(), 0);
        for (unsigned i = simd_end; i < n; ++i) {
          llvm::Value* idx = llvm::ConstantInt::get(i32_ty(context), i);
          llvm::Value* gep_idx[] = {zero, idx};
          llvm::Value* ap = builder->CreateInBoundsGEP(
              a_it->second.alloca->getAllocatedType(), a_it->second.alloca, gep_idx);
          llvm::Value* bp = builder->CreateInBoundsGEP(
              b_it->second.alloca->getAllocatedType(), b_it->second.alloca, gep_idx);
          llvm::Value* dp = builder->CreateInBoundsGEP(
              d_it->second.alloca->getAllocatedType(), d_it->second.alloca, gep_idx);
          llvm::Value* av = builder->CreateLoad(f64, ap);
          llvm::Value* bv = builder->CreateLoad(f64, bp);
          llvm::Value* rv = emit_fbinop(ins.bin_op, av, bv);
          builder->CreateStore(rv, dp);
        }
        return true;
      }
      case MirOp::ArrayBinOpI64: {
        auto d_it = arrays.find(ins.ident);
        auto a_it = arrays.find(ins.lhs_ident);
        auto b_it = arrays.find(ins.rhs_ident);
        if (d_it == arrays.end() || a_it == arrays.end() || b_it == arrays.end()) {
          return true;
        }
        const auto n = static_cast<unsigned>(ins.int_value);
        llvm::Value* zero = llvm::ConstantInt::get(builder->getInt32Ty(), 0);
        for (unsigned i = 0; i < n; ++i) {
          llvm::Value* idx = llvm::ConstantInt::get(i32_ty(context), i);
          llvm::Value* gep_idx[] = {zero, idx};
          llvm::Value* ap = builder->CreateInBoundsGEP(
              a_it->second.alloca->getAllocatedType(), a_it->second.alloca, gep_idx);
          llvm::Value* bp = builder->CreateInBoundsGEP(
              b_it->second.alloca->getAllocatedType(), b_it->second.alloca, gep_idx);
          llvm::Value* dp = builder->CreateInBoundsGEP(
              d_it->second.alloca->getAllocatedType(), d_it->second.alloca, gep_idx);
          llvm::Value* av = builder->CreateLoad(i32_ty(context), ap);
          llvm::Value* bv = builder->CreateLoad(i32_ty(context), bp);
          llvm::Value* rv = emit_binop(ins.bin_op, av, bv);
          builder->CreateStore(rv, dp);
        }
        return true;
      }
      case MirOp::ArrayLoad2DF64: {
        auto it = arrays.find(ins.ident);
        if (it == arrays.end() || !it->second.is_matrix) {
          return true;
        }
        llvm::Type* f64 = llvm::Type::getDoubleTy(context);
        llvm::Value* row = ins.index_is_literal
                               ? int32_val(*builder, context, ins.int_value)
                               : load_int(ins.index_ident);
        llvm::Value* col = ins.rhs_is_literal
                               ? int32_val(*builder, context, ins.rhs_int)
                               : load_int(ins.rhs_ident);
        llvm::Value* zero = llvm::ConstantInt::get(builder->getInt32Ty(), 0);
        llvm::Value* gep_idx[] = {zero, row, col};
        llvm::Value* ptr = builder->CreateInBoundsGEP(
            it->second.alloca->getAllocatedType(), it->second.alloca, gep_idx);
        llvm::Value* loaded = builder->CreateLoad(f64, ptr);
        if (!ins.lhs_ident.empty()) {
          builder->CreateStore(loaded, ensure_float_local(ins.lhs_ident));
        }
        return true;
      }
      case MirOp::ArrayStore2DF64: {
        auto it = arrays.find(ins.ident);
        if (it == arrays.end() || !it->second.is_matrix) {
          return true;
        }
        llvm::Type* f64 = llvm::Type::getDoubleTy(context);
        llvm::Value* row = ins.index_is_literal
                               ? int32_val(*builder, context, ins.int_value)
                               : load_int(ins.index_ident);
        llvm::Value* col = ins.rhs_is_literal
                               ? int32_val(*builder, context, ins.rhs_int)
                               : load_int(ins.rhs_ident);
        llvm::Value* val =
            ins.lhs_is_literal
                ? llvm::ConstantFP::get(f64, ins.float_value)
                : load_float(ins.lhs_ident);
        llvm::Value* zero = llvm::ConstantInt::get(builder->getInt32Ty(), 0);
        llvm::Value* gep_idx[] = {zero, row, col};
        llvm::Value* ptr = builder->CreateInBoundsGEP(
            it->second.alloca->getAllocatedType(), it->second.alloca, gep_idx);
        builder->CreateStore(val, ptr);
        return true;
      }
      case MirOp::ArrayMatMul2DF64: {
        auto c_it = arrays.find(ins.ident);
        auto a_it = arrays.find(ins.lhs_ident);
        auto b_it = arrays.find(ins.rhs_ident);
        if (c_it == arrays.end() || a_it == arrays.end() || b_it == arrays.end()) {
          return true;
        }
        llvm::Type* f64 = llvm::Type::getDoubleTy(context);
        const unsigned m = static_cast<unsigned>(ins.int_value);
        const unsigned k = static_cast<unsigned>(ins.rhs_int);
        const unsigned n = static_cast<unsigned>(ins.lhs_int);
        llvm::Value* zero = llvm::ConstantInt::get(builder->getInt32Ty(), 0);
        llvm::Value* zf = llvm::ConstantFP::get(f64, 0.0);
        for (unsigned i = 0; i < m; ++i) {
          llvm::Value* ri = llvm::ConstantInt::get(i32_ty(context), i);
          for (unsigned j = 0; j < n; ++j) {
            llvm::Value* rj = llvm::ConstantInt::get(i32_ty(context), j);
            llvm::Value* sum = zf;
            for (unsigned t = 0; t < k; ++t) {
              llvm::Value* rt = llvm::ConstantInt::get(i32_ty(context), t);
              llvm::Value* a_idx[] = {zero, ri, rt};
              llvm::Value* ap = builder->CreateInBoundsGEP(
                  a_it->second.alloca->getAllocatedType(), a_it->second.alloca, a_idx);
              llvm::Value* av = builder->CreateLoad(f64, ap);
              llvm::Value* b_idx[] = {zero, rt, rj};
              llvm::Value* bp = builder->CreateInBoundsGEP(
                  b_it->second.alloca->getAllocatedType(), b_it->second.alloca, b_idx);
              llvm::Value* bv = builder->CreateLoad(f64, bp);
              sum = builder->CreateFAdd(sum, builder->CreateFMul(av, bv));
            }
            llvm::Value* c_idx[] = {zero, ri, rj};
            llvm::Value* cp = builder->CreateInBoundsGEP(
                c_it->second.alloca->getAllocatedType(), c_it->second.alloca, c_idx);
            builder->CreateStore(sum, cp);
          }
        }
        return true;
      }
      case MirOp::ArrayDotF64: {
        auto a_it = arrays.find(ins.lhs_ident);
        auto b_it = arrays.find(ins.rhs_ident);
        if (a_it == arrays.end() || b_it == arrays.end()) {
          return true;
        }
        llvm::Type* f64 = llvm::Type::getDoubleTy(context);
        llvm::Value* acc = llvm::ConstantFP::get(f64, 0.0);
        const auto n = static_cast<unsigned>(ins.int_value);
        const unsigned simd_end = array_simd_enabled() ? (n / 4) * 4 : 0;
        if (simd_end > 0) {
          llvm::Value* v_acc =
              builder->CreateVectorSplat(4, llvm::ConstantFP::get(f64, 0.0));
          for (unsigned i = 0; i < simd_end; i += 4) {
            llvm::Value* av = gather_array_f64x4(a_it->second.alloca, i);
            llvm::Value* bv = gather_array_f64x4(b_it->second.alloca, i);
            v_acc = builder->CreateFAdd(v_acc, builder->CreateFMul(av, bv));
          }
          acc = horiz_sum_f64x4(v_acc);
        }
        llvm::Value* zero = llvm::ConstantInt::get(builder->getInt32Ty(), 0);
        for (unsigned i = simd_end; i < n; ++i) {
          llvm::Value* idx = llvm::ConstantInt::get(i32_ty(context), i);
          llvm::Value* gep_idx[] = {zero, idx};
          llvm::Value* ap = builder->CreateInBoundsGEP(
              a_it->second.alloca->getAllocatedType(), a_it->second.alloca, gep_idx);
          llvm::Value* bp = builder->CreateInBoundsGEP(
              b_it->second.alloca->getAllocatedType(), b_it->second.alloca, gep_idx);
          llvm::Value* av = builder->CreateLoad(f64, ap);
          llvm::Value* bv = builder->CreateLoad(f64, bp);
          acc = builder->CreateFAdd(acc, builder->CreateFMul(av, bv));
        }
        builder->CreateStore(acc, ensure_float_local(ins.ident));
        return true;
      }
      case MirOp::LoadIntToIdent:
        return true;
      case MirOp::AsyncAwait: {
        llvm::Function* await_fn = module->getFunction("li_async_await_i32");
        llvm::Value* pending = load_int(ins.lhs_ident);
        llvm::Value* result = builder->CreateCall(await_fn, {pending});
        builder->CreateStore(result, ensure_int_local(ins.ident));
        return true;
      }
      case MirOp::AsyncFrameEnter: {
        llvm::Function* enter = module->getFunction("li_async_frame_enter");
        builder->CreateCall(enter, {});
        return true;
      }
      case MirOp::AsyncFrameLeave: {
        llvm::Function* leave = module->getFunction("li_async_frame_leave");
        builder->CreateCall(leave, {});
        return true;
      }
      case MirOp::ArraySimdScope:
        if (ins.int_value != 0) {
          array_simd_scope_stack.push_back(true);
        } else if (!array_simd_scope_stack.empty()) {
          array_simd_scope_stack.pop_back();
        }
        return true;
    }
    return true;
  }
};

}  // namespace

bool emit_llvm_ir(const MirModule& mir, const std::string& out_path, std::string* error) {
  llvm::LLVMContext context;
  auto module = std::make_unique<llvm::Module>("li", context);

  module->getOrInsertFunction("li_rt_print_int",
                              llvm::FunctionType::get(llvm::Type::getVoidTy(context),
                                                      {i32_ty(context)}, false));
  module->getOrInsertFunction("li_rt_print_str",
                              llvm::FunctionType::get(llvm::Type::getVoidTy(context),
                                                      {i8_ptr(context)}, false));
  module->getOrInsertFunction("li_bounds_fail",
                              llvm::FunctionType::get(llvm::Type::getVoidTy(context), {}, false));
  module->getOrInsertFunction(
      "li_rt_set_args",
      llvm::FunctionType::get(llvm::Type::getVoidTy(context),
                              {i32_ty(context), llvm::PointerType::getUnqual(i8_ptr(context))},
                              false));
  module->getOrInsertFunction("li_rt_argc",
                              llvm::FunctionType::get(i32_ty(context), {}, false));
  module->getOrInsertFunction("li_rt_argv",
                              llvm::FunctionType::get(i8_ptr(context), {i32_ty(context)}, false));
  module->getOrInsertFunction("li_rt_sqrt",
                              llvm::FunctionType::get(llvm::Type::getDoubleTy(context),
                                                      {llvm::Type::getDoubleTy(context)}, false));
  llvm::Type* f64 = llvm::Type::getDoubleTy(context);
  module->getOrInsertFunction(
      "li_rt_hypot", llvm::FunctionType::get(f64, {f64, f64}, false));
  module->getOrInsertFunction("li_rt_expm1", llvm::FunctionType::get(f64, {f64}, false));
  module->getOrInsertFunction("li_rt_log1p", llvm::FunctionType::get(f64, {f64}, false));
  module->getOrInsertFunction(
      "li_rt_volatile_sink_f64",
      llvm::FunctionType::get(llvm::Type::getVoidTy(context), {f64}, false));
  module->getOrInsertFunction(
      "li_omp_parallel_for_i64",
      llvm::FunctionType::get(llvm::Type::getVoidTy(context),
                              {i64_ty(context), i64_ty(context),
                               llvm::PointerType::getUnqual(llvm::FunctionType::get(
                                   llvm::Type::getVoidTy(context), {i64_ty(context)}, false))},
                              false));
  module->getOrInsertFunction("li_async_frame_enter",
                              llvm::FunctionType::get(llvm::Type::getVoidTy(context), {}, false));
  module->getOrInsertFunction("li_async_frame_leave",
                              llvm::FunctionType::get(llvm::Type::getVoidTy(context), {}, false));
  module->getOrInsertFunction("li_async_await_i32",
                              llvm::FunctionType::get(i32_ty(context), {i32_ty(context)}, false));
  module->getOrInsertFunction("li_async_poll",
                              llvm::FunctionType::get(i32_ty(context), {i32_ty(context)}, false));

  module->getOrInsertFunction("bytes_len",
                              llvm::FunctionType::get(i32_ty(context), {i8_ptr(context)}, false));
  module->getOrInsertFunction(
      "bytes_slice",
      llvm::FunctionType::get(i8_ptr(context), {i8_ptr(context), i32_ty(context), i32_ty(context)},
                              false));
  module->getOrInsertFunction(
      "li_rt_str_byte_at",
      llvm::FunctionType::get(i32_ty(context), {i8_ptr(context), i32_ty(context)}, false));
  module->getOrInsertFunction(
      "li_rt_str_eq",
      llvm::FunctionType::get(i32_ty(context), {i8_ptr(context), i8_ptr(context)}, false));
  module->getOrInsertFunction(
      "li_rt_path_exact",
      llvm::FunctionType::get(i32_ty(context), {i8_ptr(context), i8_ptr(context)}, false));
  module->getOrInsertFunction(
      "li_rt_path_prefix",
      llvm::FunctionType::get(i32_ty(context), {i8_ptr(context), i8_ptr(context)}, false));
  module->getOrInsertFunction(
      "li_rt_match_route_fixture",
      llvm::FunctionType::get(i32_ty(context), {i8_ptr(context), i8_ptr(context)}, false));
  module->getOrInsertFunction("tcp_listen",
                              llvm::FunctionType::get(i32_ty(context), {i32_ty(context)}, false));
  module->getOrInsertFunction("tcp_accept",
                              llvm::FunctionType::get(i32_ty(context), {i32_ty(context)}, false));
  module->getOrInsertFunction(
      "tcp_send",
      llvm::FunctionType::get(i32_ty(context), {i32_ty(context), i8_ptr(context)}, false));
  module->getOrInsertFunction(
      "tcp_recv",
      llvm::FunctionType::get(i8_ptr(context), {i32_ty(context), i32_ty(context)}, false));
  module->getOrInsertFunction("tcp_close",
                              llvm::FunctionType::get(llvm::Type::getVoidTy(context),
                                                      {i32_ty(context)}, false));

  llvm::Function* user_main = nullptr;
  bool user_main_argv_wrapper = false;

  struct UserFnEmit {
    const MirFn* mir_fn = nullptr;
    llvm::Function* llvm_fn = nullptr;
    llvm::Type* ret_ty = nullptr;
    bool is_par_fn = false;
  };
  std::vector<UserFnEmit> user_fns;

  // Pass 1: declare every MIR function before any body references callees.
  for (const auto& fn : mir.functions) {
    if (fn.is_extern) {
      llvm::Type* ret_ty = fn.returns_void ? llvm::Type::getVoidTy(context)
                                           : (fn.returns_i64 ? i8_ptr(context)
                                                             : llvm_scalar(context, fn.returns_float, false));
      std::vector<llvm::Type*> param_tys;
      for (const auto& p : fn.params) {
        if (p.is_string || p.is_i64) {
          param_tys.push_back(i8_ptr(context));
        } else {
          param_tys.push_back(llvm_scalar(context, p.is_float, false));
        }
      }
      llvm::FunctionType* fn_ty = llvm::FunctionType::get(ret_ty, param_tys, false);
      llvm::Function::Create(fn_ty, llvm::Function::ExternalLinkage, fn.name, module.get());
      continue;
    }

    const bool is_par_fn = fn.name.rfind("__li_par_", 0) == 0;
    llvm::Type* ret_ty = nullptr;
    if (fn.returns_void) {
      ret_ty = llvm::Type::getVoidTy(context);
    } else if (fn.returns_object && !fn.return_object_layout.empty()) {
      ret_ty = llvm_struct_from_layout(context, fn.return_object_layout);
    } else if (fn.returns_i64) {
      ret_ty = i8_ptr(context);
    } else {
      ret_ty = llvm_scalar(context, fn.returns_float, false);
    }
    std::vector<llvm::Type*> param_tys;
    for (const auto& p : fn.params) {
      if (is_par_fn) {
        param_tys.push_back(i64_ty(context));
      } else if (p.is_simd_f64) {
        param_tys.push_back(llvm::VectorType::get(llvm::Type::getDoubleTy(context),
                                                  llvm::ElementCount::getFixed(4)));
      } else if (p.fixed_array_elems > 0) {
        param_tys.push_back(llvm_array_param_ptr(context, p));
      } else {
        param_tys.push_back(llvm_type_for_mir_param(context, p));
      }
    }
    llvm::FunctionType* fn_ty = llvm::FunctionType::get(ret_ty, param_tys, false);
    const bool argv_main = fn.name == "main" && fn.params.empty();
    const std::string llvm_name = argv_main ? "li_user_main" : fn.name;
    llvm::Function* func =
        llvm::Function::Create(fn_ty, llvm::Function::ExternalLinkage, llvm_name, module.get());
    if (fn.name == "main") {
      user_main = func;
      user_main_argv_wrapper = argv_main;
    }
    user_fns.push_back(UserFnEmit{&fn, func, ret_ty, is_par_fn});
  }

  // Pass 2: emit bodies (all callees already declared).
  for (const UserFnEmit& ufe : user_fns) {
    const MirFn& fn = *ufe.mir_fn;
    llvm::Function* func = ufe.llvm_fn;
    llvm::Type* ret_ty = ufe.ret_ty;
    const bool is_par_fn = ufe.is_par_fn;

    llvm::BasicBlock* entry = llvm::BasicBlock::Create(context, "entry", func);
    llvm::IRBuilder<> builder(entry);
    llvm::FastMathFlags saved_fmf;
    if (mir.fp_numerically_stable) {
      saved_fmf = builder.getFastMathFlags();
      builder.setFastMathFlags(llvm::FastMathFlags());
    }

    EmitCtx ctx{context,
                module.get(),
                func,
                &builder,
                ret_ty,
                fn.returns_float,
                fn.returns_i64,
                fn.returns_object,
                mir.fp_numerically_stable,
                !fn.no_vectorize,
                {},
                {},
                {},
                {},
                {},
                {}};

    unsigned idx = 0;
    for (auto& arg : func->args()) {
      if (idx < fn.params.size()) {
        arg.setName(fn.params[idx].name);
        const auto& mp = fn.params[idx];
        if (mp.fixed_array_elems > 0) {
          llvm::Type* arr_ty = llvm_array_type(context, mp);
          llvm::AllocaInst* ap = builder.CreateAlloca(arr_ty, nullptr, mp.name);
          ctx.arrays[mp.name] = ArraySlot{ap, mp.fixed_array_elems, 0, mp.is_float, false};
          llvm::Type* elem = llvm_scalar(context, mp.is_float, mp.is_i64, mp.is_string);
          llvm::Value* zero = llvm::ConstantInt::get(builder.getInt32Ty(), 0);
          const auto n = static_cast<unsigned>(mp.fixed_array_elems);
          for (unsigned i = 0; i < n; ++i) {
            llvm::Value* idx = llvm::ConstantInt::get(i32_ty(context), i);
            llvm::Value* gep_idx[] = {zero, idx};
            llvm::Value* from_p = builder.CreateInBoundsGEP(arr_ty, &arg, gep_idx);
            llvm::Value* to_p = builder.CreateInBoundsGEP(arr_ty, ap, gep_idx);
            llvm::Value* v = builder.CreateLoad(elem, from_p);
            builder.CreateStore(v, to_p);
          }
        } else if (mp.is_string) {
          builder.CreateStore(&arg, ctx.ensure_ptr_local(mp.name));
        } else if (is_par_fn || mp.is_i64) {
          builder.CreateStore(&arg, ctx.ensure_i64_local(mp.name));
        } else if (mp.is_float) {
          builder.CreateStore(&arg, ctx.ensure_float_local(mp.name));
        } else {
          builder.CreateStore(&arg, ctx.ensure_int_local(mp.name));
        }
      }
      idx++;
    }

    for (const auto& ins : fn.body) {
      ctx.emit_insn(ins);
    }
    if (mir.fp_numerically_stable) {
      builder.setFastMathFlags(saved_fmf);
    }
  }

  if (user_main && user_main_argv_wrapper) {
    llvm::Type* argv_ty = llvm::PointerType::getUnqual(i8_ptr(context));
    llvm::FunctionType* main_ty =
        llvm::FunctionType::get(i32_ty(context), {i32_ty(context), argv_ty}, false);
    llvm::Function* main_fn =
        llvm::Function::Create(main_ty, llvm::Function::ExternalLinkage, "main", module.get());
    llvm::BasicBlock* main_entry = llvm::BasicBlock::Create(context, "entry", main_fn);
    llvm::IRBuilder<> main_builder(main_entry);
    llvm::Function* set_args = module->getFunction("li_rt_set_args");
    main_builder.CreateCall(set_args, {main_fn->getArg(0), main_fn->getArg(1)});
    llvm::CallInst* user_ret = main_builder.CreateCall(user_main, {});
    main_builder.CreateRet(user_ret);
  } else if (!user_main) {
    llvm::FunctionType* main_ty = llvm::FunctionType::get(i32_ty(context), {}, false);
    llvm::Function* main_fn =
        llvm::Function::Create(main_ty, llvm::Function::ExternalLinkage, "main", module.get());
    llvm::BasicBlock* main_entry = llvm::BasicBlock::Create(context, "entry", main_fn);
    llvm::IRBuilder<> main_builder(main_entry);
    main_builder.CreateRet(llvm::ConstantInt::get(i32_ty(context), 0));
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
