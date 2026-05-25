#include "li/check_cache.hpp"

#include <algorithm>
#include <cctype>
#include <cstdlib>
#include <chrono>
#include <fstream>
#include <iostream>
#include <sstream>
#include <vector>

namespace li {
namespace {

const char* check_cache_compiler_version() {
#ifdef LI_VERSION
  return LI_VERSION;
#else
  return "dev";
#endif
}

std::uint64_t fnv1a64_update(std::uint64_t hash, const unsigned char* data, std::size_t len) {
  constexpr std::uint64_t prime = 1099511628211ull;
  constexpr std::uint64_t offset = 14695981039346656037ull;
  for (std::size_t i = 0; i < len; ++i) {
    hash ^= static_cast<std::uint64_t>(data[i]);
    hash *= prime;
  }
  return hash == 0 ? offset : hash;
}

std::string hex64(std::uint64_t value) {
  static const char* kHex = "0123456789abcdef";
  std::string out(16, '0');
  for (int i = 15; i >= 0; --i) {
    out[static_cast<std::size_t>(i)] = kHex[value & 0xf];
    value >>= 4;
  }
  return out;
}

std::filesystem::path cache_entry_path(const std::filesystem::path& cache_dir,
                                       const std::string& key) {
  return cache_dir / (key + ".json");
}

std::size_t dir_size_bytes(const std::filesystem::path& dir) {
  std::size_t total = 0;
  if (!std::filesystem::exists(dir)) {
    return 0;
  }
  for (const auto& entry : std::filesystem::directory_iterator(dir)) {
    if (entry.is_regular_file()) {
      total += static_cast<std::size_t>(entry.file_size());
    }
  }
  return total;
}

}  // namespace

std::string check_config_hash(const CheckConfig& cfg) {
  std::ostringstream ss;
  ss << "typosquat=";
  switch (cfg.typosquat) {
    case CheckRuleLevel::Allow:
      ss << "allow";
      break;
    case CheckRuleLevel::Deny:
      ss << "deny";
      break;
    case CheckRuleLevel::Warn:
    default:
      ss << "warn";
      break;
  }
  return ss.str();
}

std::uint64_t hash_file_content(const std::filesystem::path& path) {
  std::ifstream in(path, std::ios::binary);
  if (!in) {
    return 0;
  }
  std::uint64_t hash = 14695981039346656037ull;
  std::vector<unsigned char> buf(65536);
  while (in) {
    in.read(reinterpret_cast<char*>(buf.data()),
            static_cast<std::streamsize>(buf.size()));
    const auto got = static_cast<std::size_t>(in.gcount());
    if (got == 0) {
      break;
    }
    hash = fnv1a64_update(hash, buf.data(), got);
  }
  return hash;
}

std::string make_check_cache_key(const std::filesystem::path& path, std::uint64_t content_hash,
                                 const std::string& config_hash, const std::string& version) {
  std::ostringstream ss;
  ss << hex64(content_hash) << '-' << hex64(fnv1a64_update(0,
      reinterpret_cast<const unsigned char*>(config_hash.data()), config_hash.size()))
     << '-' << hex64(fnv1a64_update(0,
      reinterpret_cast<const unsigned char*>(path.string().data()), path.string().size()))
     << '-' << hex64(fnv1a64_update(
          0, reinterpret_cast<const unsigned char*>(version.data()), version.size()));
  return ss.str();
}

bool apply_check_cache_flag(std::string_view arg, CheckCacheOptions& out) {
  if (arg == "--no-cache") {
    out.enabled = false;
    return true;
  }
  if (arg.rfind("--cache-dir=", 0) == 0) {
    out.cache_dir = std::filesystem::path(std::string(arg.substr(12)));
    return true;
  }
  if (arg.rfind("--cache-max-mb=", 0) == 0) {
    const int n = std::atoi(arg.substr(15).data());
    if (n > 0) {
      out.max_mb = static_cast<std::size_t>(n);
    }
    return true;
  }
  return false;
}

CheckCacheHit try_load_check_cache(const CheckCacheOptions& opts, const std::string& key) {
  CheckCacheHit hit;
  if (!opts.enabled || opts.cache_dir.empty()) {
    return hit;
  }
  const auto path = cache_entry_path(opts.cache_dir, key);
  std::ifstream in(path);
  if (!in) {
    return hit;
  }
  std::string line;
  if (!std::getline(in, line) || line.rfind("exit=", 0) != 0) {
    return hit;
  }
  hit.exit_code = std::atoi(line.c_str() + 5);
  if (!std::getline(in, line) || line != "---") {
    return hit;
  }
  std::ostringstream body;
  body << in.rdbuf();
  hit.output = body.str();
  hit.hit = true;
  return hit;
}

void store_check_cache(const CheckCacheOptions& opts, const std::string& key, int exit_code,
                       const std::string& output) {
  if (!opts.enabled || opts.cache_dir.empty()) {
    return;
  }
  std::error_code ec;
  std::filesystem::create_directories(opts.cache_dir, ec);
  const auto path = cache_entry_path(opts.cache_dir, key);
  std::ofstream out(path, std::ios::trunc);
  if (!out) {
    return;
  }
  out << "exit=" << exit_code << "\n---\n" << output;
  out.close();
  evict_check_cache_lru(opts.cache_dir, opts.max_mb);
}

void evict_check_cache_lru(const std::filesystem::path& cache_dir, std::size_t max_mb) {
  if (max_mb == 0 || !std::filesystem::exists(cache_dir)) {
    return;
  }
  const std::size_t cap = max_mb * 1024u * 1024u;
  struct Entry {
    std::filesystem::path path;
    std::filesystem::file_time_type mtime;
    std::uintmax_t size = 0;
  };
  std::vector<Entry> entries;
  for (const auto& item : std::filesystem::directory_iterator(cache_dir)) {
    if (!item.is_regular_file()) {
      continue;
    }
    entries.push_back(
        Entry{item.path(), std::filesystem::last_write_time(item.path()), item.file_size()});
  }
  auto total = dir_size_bytes(cache_dir);
  std::sort(entries.begin(), entries.end(),
            [](const Entry& a, const Entry& b) { return a.mtime < b.mtime; });
  for (const auto& entry : entries) {
    if (total <= cap) {
      break;
    }
    std::error_code ec;
    std::filesystem::remove(entry.path, ec);
    total -= static_cast<std::size_t>(entry.size);
  }
}

}  // namespace li
