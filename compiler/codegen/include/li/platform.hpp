#pragma once
#include "li/resource_options.hpp"
#include <cstdlib>
#include <string>
#include <thread>
namespace li {
inline std::string repo_build_prefix(){
  const auto& o=resource_options();
  if(!o.build_dir.empty())return o.build_dir;
  if(const char*d=getenv("LI_BUILD_DIR"))return d;
  if(const char*r=getenv("LI_REPO_ROOT"))return std::string(r)+"/build";
  return "build";
}
inline std::string repo_build_path(const char* rel){
  std::string p=repo_build_prefix();
  if(!rel||!*rel)return p;
  if(p.empty()||p.back()!='/')p+='/';
  return p+rel;
}
inline unsigned default_host_jobs(){
  if(resource_options().jobs)return resource_options().jobs;
  unsigned h=std::thread::hardware_concurrency();
  return h?h:1u;
}
inline constexpr const char* null_output_path(){
#if defined(_WIN32)
  return "NUL";
#else
  return "/dev/null";
#endif
}
inline bool is_null_output_path(const std::string& p){
#if defined(_WIN32)
  return p=="NUL"||p=="nul";
#else
  return p=="/dev/null";
#endif
}
inline bool is_safe_link_path(const std::string& path){
  if(path.empty())return false;
  for(char c:path)if(c==';'||c=='|'||c=='&'||c=='$'||c=='`')return false;
  return path.find("$(")==std::string::npos;
}
}
