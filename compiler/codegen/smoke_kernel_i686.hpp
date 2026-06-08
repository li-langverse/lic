#pragma once

#include <cstdint>
#include <string>
#include <unordered_map>
#include <vector>

namespace li {
namespace smoke_i686 {

struct Cpu {
  uint32_t eax = 0;
  uint32_t ecx = 0;
  uint32_t edx = 0;
  uint32_t ebx = 0;
  uint32_t esp = 0;
  uint32_t ebp = 0;
  uint32_t esi = 0;
  uint32_t edi = 0;
  uint32_t eip = 0;
  std::string serial;
  uint64_t steps = 0;
  uint64_t max_steps = 0;
};

class Memory {
 public:
  void map(uint32_t vaddr, const uint8_t* data, std::size_t filesz, std::size_t memsz);
  uint8_t read8(uint32_t addr) const;
  uint16_t read16(uint32_t addr) const;
  uint32_t read32(uint32_t addr) const;
  void write8(uint32_t addr, uint8_t value);
  void write16(uint32_t addr, uint16_t value);
  void write32(uint32_t addr, uint32_t value);
  bool mapped(uint32_t addr) const;

 private:
  std::unordered_map<uint32_t, std::vector<uint8_t>> pages_;
  static uint32_t page_base(uint32_t addr);
};

bool load_elf32(const std::vector<uint8_t>& image, Memory* mem, uint32_t* entry, std::string* error);
bool run(Cpu* cpu, Memory* mem, std::string* error);
uint32_t choose_stack_top(const Memory& mem, uint32_t entry);

}  // namespace smoke_i686
}  // namespace li
