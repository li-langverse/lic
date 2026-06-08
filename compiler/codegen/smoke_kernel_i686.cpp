#include "smoke_kernel_i686.hpp"

#include <algorithm>
#include <cstdint>
#include <cstring>
#include <sstream>

namespace li {
namespace smoke_i686 {
namespace {

constexpr uint32_t kPageSize = 4096;
constexpr uint16_t kCom1Port = 0x3F8;

uint16_t read_le16(const uint8_t* p) {
  return static_cast<uint16_t>(p[0]) | (static_cast<uint16_t>(p[1]) << 8);
}

uint32_t read_le32(const uint8_t* p) {
  return static_cast<uint32_t>(p[0]) | (static_cast<uint32_t>(p[1]) << 8) |
         (static_cast<uint32_t>(p[2]) << 16) | (static_cast<uint32_t>(p[3]) << 24);
}

struct Decoder {
  Cpu* cpu;
  Memory* mem;

  uint8_t fetch8() {
    const uint8_t value = mem->read8(cpu->eip);
    cpu->eip += 1;
    return value;
  }

  uint16_t fetch16() {
    const uint16_t value = mem->read16(cpu->eip);
    cpu->eip += 2;
    return value;
  }

  uint32_t fetch32() {
    const uint32_t value = mem->read32(cpu->eip);
    cpu->eip += 4;
    return value;
  }

  uint32_t* reg32(int idx) {
    switch (idx & 7) {
      case 0:
        return &cpu->eax;
      case 1:
        return &cpu->ecx;
      case 2:
        return &cpu->edx;
      case 3:
        return &cpu->ebx;
      case 4:
        return &cpu->esp;
      case 5:
        return &cpu->ebp;
      case 6:
        return &cpu->esi;
      default:
        return &cpu->edi;
    }
  }

  uint8_t low8(int idx) const {
    switch (idx & 7) {
      case 0:
        return static_cast<uint8_t>(cpu->eax);
      case 1:
        return static_cast<uint8_t>(cpu->ecx);
      case 2:
        return static_cast<uint8_t>(cpu->edx);
      case 3:
        return static_cast<uint8_t>(cpu->ebx);
      case 4:
        return static_cast<uint8_t>(cpu->esp);
      case 5:
        return static_cast<uint8_t>(cpu->ebp);
      case 6:
        return static_cast<uint8_t>(cpu->esi);
      default:
        return static_cast<uint8_t>(cpu->edi);
    }
  }

  void set_low8(int idx, uint8_t value) {
    *reg32(idx) = (*reg32(idx) & ~0xFFu) | value;
  }

  struct EffectiveAddress {
    uint32_t addr = 0;
    bool ok = false;
  };

  EffectiveAddress decode_modrm(uint8_t modrm) {
    EffectiveAddress ea{};
    const int mod = (modrm >> 6) & 3;
    const int rm = modrm & 7;
    if (mod == 3) {
      ea.ok = true;
      return ea;
    }
    int32_t disp = 0;
    uint32_t base = 0;
    if (rm == 4) {
      const uint8_t sib = fetch8();
      const int scale = 1 << ((sib >> 6) & 3);
      const int index = (sib >> 3) & 7;
      const int base_reg = sib & 7;
      if (base_reg == 5 && mod == 0) {
        disp = static_cast<int32_t>(fetch32());
      } else {
        base = *reg32(base_reg);
        if (mod == 1) {
          disp = static_cast<int8_t>(fetch8());
        } else if (mod == 2) {
          disp = static_cast<int32_t>(fetch32());
        }
      }
      if (index != 4) {
        base += *reg32(index) * static_cast<uint32_t>(scale);
      }
    } else if (rm == 5 && mod == 0) {
      disp = static_cast<int32_t>(fetch32());
    } else {
      base = *reg32(rm);
      if (mod == 1) {
        disp = static_cast<int8_t>(fetch8());
      } else if (mod == 2) {
        disp = static_cast<int32_t>(fetch32());
      }
    }
    ea.addr = static_cast<uint32_t>(static_cast<int64_t>(base) + disp);
    ea.ok = true;
    return ea;
  }

  void push32(uint32_t value) {
    cpu->esp -= 4;
    mem->write32(cpu->esp, value);
  }

  uint32_t pop32() {
    const uint32_t value = mem->read32(cpu->esp);
    cpu->esp += 4;
    return value;
  }

  void out_serial(uint16_t port, uint8_t value) {
    if (port == kCom1Port) {
      cpu->serial.push_back(static_cast<char>(value));
    }
  }

  bool eval_jcc(int condition) const {
    (void)condition;
    return false;
  }

  bool handle_reg_reg(uint8_t op, int reg, int rm, std::string* error) {
    uint32_t* dst = reg32(rm);
    uint32_t* src = reg32(reg);
    switch (op) {
      case 0x89:
        *dst = *src;
        return true;
      case 0x8B:
        *src = *dst;
        return true;
      case 0x31:
        *dst ^= *src;
        return true;
      case 0x01:
        *dst += *src;
        return true;
      case 0x29:
        *dst -= *src;
        return true;
      case 0x85:
      case 0x3B:
        return true;
      default:
        break;
    }
    if (error) {
      *error = "unsupported register-register opcode";
    }
    return false;
  }

  bool handle_modrm(uint8_t op, int reg, int rm, uint32_t addr, std::string* error) {
    (void)rm;
    switch (op) {
      case 0x89:
        mem->write32(addr, *reg32(reg));
        return true;
      case 0x8B:
        *reg32(reg) = mem->read32(addr);
        return true;
      case 0x8D:
        *reg32(reg) = addr;
        return true;
      case 0xC7:
        mem->write32(addr, fetch32());
        return true;
      case 0x83: {
        const int subop = reg;
        const int8_t imm = static_cast<int8_t>(fetch8());
        const uint32_t old = mem->read32(addr);
        if (subop == 5) {
          mem->write32(addr, static_cast<uint32_t>(old + imm));
          return true;
        }
        if (subop == 7) {
          mem->write32(addr, static_cast<uint32_t>(old - imm));
          return true;
        }
        break;
      }
      case 0x81: {
        const int subop = reg;
        const int32_t imm = static_cast<int32_t>(fetch32());
        const uint32_t old = mem->read32(addr);
        if (subop == 5) {
          mem->write32(addr, static_cast<uint32_t>(old + imm));
          return true;
        }
        if (subop == 7) {
          mem->write32(addr, static_cast<uint32_t>(old - imm));
          return true;
        }
        break;
      }
      default:
        break;
    }
    if (error) {
      *error = "unsupported memory opcode";
    }
    return false;
  }

  bool step_once(std::string* error) {
    if (cpu->steps >= cpu->max_steps) {
      if (error) {
        *error = "smoke-kernel instruction limit reached";
      }
      return false;
    }
    ++cpu->steps;
    if (!mem->mapped(cpu->eip)) {
      if (error) {
        std::ostringstream msg;
        msg << "smoke-kernel jumped to unmapped EIP 0x" << std::hex << cpu->eip;
        *error = msg.str();
      }
      return false;
    }

    const uint32_t start_eip = cpu->eip;
    const uint8_t op = fetch8();

    switch (op) {
      case 0x90:
      case 0xF4:
        return true;
      case 0xEE:
        out_serial(static_cast<uint16_t>(cpu->edx & 0xFFFF), low8(0));
        return true;
      case 0xE6:
        out_serial(fetch8(), low8(0));
        return true;
      case 0xC3:
        cpu->eip = pop32();
        return true;
      case 0xC2: {
        const uint16_t imm = fetch16();
        cpu->eip = pop32();
        cpu->esp += imm;
        return true;
      }
      case 0xEB: {
        const int8_t rel = static_cast<int8_t>(fetch8());
        cpu->eip = static_cast<uint32_t>(static_cast<int64_t>(start_eip + 2 + rel));
        return true;
      }
      case 0xE9: {
        const int32_t rel = static_cast<int32_t>(fetch32());
        cpu->eip = static_cast<uint32_t>(static_cast<int64_t>(start_eip + 5 + rel));
        return true;
      }
      case 0xE8: {
        const int32_t rel = static_cast<int32_t>(fetch32());
        push32(start_eip + 5);
        cpu->eip = static_cast<uint32_t>(static_cast<int64_t>(start_eip + 5 + rel));
        return true;
      }
      default:
        break;
    }

    if (op >= 0xB8 && op <= 0xBF) {
      *reg32(op - 0xB8) = fetch32();
      return true;
    }
    if (op >= 0xB0 && op <= 0xB7) {
      set_low8(op - 0xB0, fetch8());
      return true;
    }
    if (op >= 0x50 && op <= 0x57) {
      push32(*reg32(op - 0x50));
      return true;
    }
    if (op >= 0x58 && op <= 0x5F) {
      *reg32(op - 0x58) = pop32();
      return true;
    }
    if (op == 0x68) {
      push32(fetch32());
      return true;
    }
    if (op == 0x6A) {
      push32(static_cast<uint32_t>(static_cast<int8_t>(fetch8())));
      return true;
    }
    if (op == 0x0F) {
      const uint8_t op2 = fetch8();
      if (op2 >= 0x80 && op2 <= 0x8F) {
        const int32_t rel = static_cast<int32_t>(fetch32());
        if (eval_jcc(op2 - 0x80)) {
          cpu->eip = static_cast<uint32_t>(static_cast<int64_t>(cpu->eip + rel));
        }
        return true;
      }
    }
    if (op >= 0x70 && op <= 0x7F) {
      const int8_t rel = static_cast<int8_t>(fetch8());
      if (eval_jcc(op - 0x70)) {
        cpu->eip = static_cast<uint32_t>(static_cast<int64_t>(start_eip + 2 + rel));
      }
      return true;
    }
    if (op == 0x89 || op == 0x8B || op == 0x8D || op == 0x01 || op == 0x29 || op == 0x31 ||
        op == 0x09 || op == 0x21 || op == 0x85 || op == 0x3B || op == 0xC7 || op == 0x81 ||
        op == 0x83) {
      const uint8_t modrm = fetch8();
      const int reg = (modrm >> 3) & 7;
      const int mod = (modrm >> 6) & 3;
      if (mod == 3) {
        return handle_reg_reg(op, reg, modrm & 7, error);
      }
      const EffectiveAddress ea = decode_modrm(modrm);
      if (!ea.ok) {
        if (error) {
          *error = "unsupported ModRM addressing mode";
        }
        return false;
      }
      return handle_modrm(op, reg, modrm & 7, ea.addr, error);
    }

    if (error) {
      std::ostringstream msg;
      msg << "unsupported opcode 0x" << std::hex << static_cast<int>(op) << " at EIP 0x"
          << start_eip;
      *error = msg.str();
    }
    return false;
  }
};

}  // namespace

uint32_t Memory::page_base(uint32_t addr) { return addr & ~(kPageSize - 1); }

void Memory::map(uint32_t vaddr, const uint8_t* data, std::size_t filesz, std::size_t memsz) {
  const std::size_t total = std::max(filesz, memsz);
  for (std::size_t off = 0; off < total; off += kPageSize) {
    const uint32_t page = page_base(vaddr + static_cast<uint32_t>(off));
    auto& page_bytes = pages_[page];
    if (page_bytes.empty()) {
      page_bytes.assign(kPageSize, 0);
    }
    const std::size_t page_off = (vaddr + off) & (kPageSize - 1);
    const std::size_t chunk = std::min(kPageSize - page_off, total - off);
    if (off < filesz && data != nullptr) {
      const std::size_t copy = std::min(chunk, filesz - off);
      std::memcpy(page_bytes.data() + page_off, data + off, copy);
    }
  }
}

bool Memory::mapped(uint32_t addr) const {
  return pages_.find(page_base(addr)) != pages_.end();
}

uint8_t Memory::read8(uint32_t addr) const {
  const auto it = pages_.find(page_base(addr));
  if (it == pages_.end()) {
    return 0;
  }
  return it->second[addr & (kPageSize - 1)];
}

uint16_t Memory::read16(uint32_t addr) const {
  return static_cast<uint16_t>(read8(addr)) |
         static_cast<uint16_t>(static_cast<uint16_t>(read8(addr + 1)) << 8);
}

uint32_t Memory::read32(uint32_t addr) const {
  return static_cast<uint32_t>(read8(addr)) |
         (static_cast<uint32_t>(read8(addr + 1)) << 8) |
         (static_cast<uint32_t>(read8(addr + 2)) << 16) |
         (static_cast<uint32_t>(read8(addr + 3)) << 24);
}

void Memory::write8(uint32_t addr, uint8_t value) {
  const uint32_t page = page_base(addr);
  auto& page_bytes = pages_[page];
  if (page_bytes.empty()) {
    page_bytes.assign(kPageSize, 0);
  }
  page_bytes[addr & (kPageSize - 1)] = value;
}

void Memory::write16(uint32_t addr, uint16_t value) {
  write8(addr, static_cast<uint8_t>(value & 0xFF));
  write8(addr + 1, static_cast<uint8_t>((value >> 8) & 0xFF));
}

void Memory::write32(uint32_t addr, uint32_t value) {
  write8(addr, static_cast<uint8_t>(value & 0xFF));
  write8(addr + 1, static_cast<uint8_t>((value >> 8) & 0xFF));
  write8(addr + 2, static_cast<uint8_t>((value >> 16) & 0xFF));
  write8(addr + 3, static_cast<uint8_t>((value >> 24) & 0xFF));
}

uint32_t choose_stack_top(const Memory& mem, uint32_t entry) {
  (void)entry;
  uint32_t top = 0x00120000;
  while (mem.mapped(top - 16)) {
    top += 0x1000;
  }
  return top;
}

bool load_elf32(const std::vector<uint8_t>& image, Memory* mem, uint32_t* entry,
                std::string* error) {
  auto read_le16 = [](const uint8_t* p) {
    return static_cast<uint16_t>(p[0]) | (static_cast<uint16_t>(p[1]) << 8);
  };
  auto read_le32 = [&](const uint8_t* p) {
    return static_cast<uint32_t>(p[0]) | (static_cast<uint32_t>(p[1]) << 8) |
           (static_cast<uint32_t>(p[2]) << 16) | (static_cast<uint32_t>(p[3]) << 24);
  };
  if (image.size() < 52 || image[0] != 0x7F || image[1] != 'E' || image[2] != 'L' ||
      image[3] != 'F' || image[4] != 1) {
    if (error) {
      *error = "expected ELF32 image";
    }
    return false;
  }
  const uint32_t e_entry = read_le32(image.data() + 0x18);
  const uint32_t phoff = read_le32(image.data() + 0x1C);
  const uint16_t phentsize = read_le16(image.data() + 0x2A);
  const uint16_t phnum = read_le16(image.data() + 0x2C);
  if (phoff + static_cast<uint32_t>(phentsize) * phnum > image.size()) {
    if (error) {
      *error = "ELF program header table out of range";
    }
    return false;
  }
  bool loaded = false;
  for (uint16_t i = 0; i < phnum; ++i) {
    const std::size_t off = phoff + static_cast<std::size_t>(i) * phentsize;
    const uint32_t p_type = read_le32(image.data() + off);
    if (p_type != 1) {
      continue;
    }
    const uint32_t p_offset = read_le32(image.data() + off + 4);
    const uint32_t p_vaddr = read_le32(image.data() + off + 8);
    const uint32_t p_filesz = read_le32(image.data() + off + 16);
    const uint32_t p_memsz = read_le32(image.data() + off + 20);
    if (p_filesz > 0) {
      if (p_offset + p_filesz > image.size()) {
        if (error) {
          *error = "ELF PT_LOAD segment out of range";
        }
        return false;
      }
      mem->map(p_vaddr, image.data() + p_offset, p_filesz, p_memsz);
      loaded = true;
    }
  }
  if (!loaded) {
    if (error) {
      *error = "ELF has no PT_LOAD segments";
    }
    return false;
  }
  *entry = e_entry;
  return true;
}

bool run(Cpu* cpu, Memory* mem, std::string* error) {
  Decoder dec{cpu, mem};
  while (true) {
    if (cpu->serial.find("hello_kern") != std::string::npos) {
      return true;
    }
    if (!dec.step_once(error)) {
      return cpu->serial.find("hello_kern") != std::string::npos;
    }
  }
}

}  // namespace smoke_i686
}  // namespace li
