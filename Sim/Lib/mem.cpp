#include "mem.h"
#include <cstdint>


void Memory::load_executable(const char* data, size_t size) {
    memory.resize(size);
}

std::uint32_t Memory::read32(Address address) {
    return read<std::uint32_t>(address);
}

char *Memory::begin() { return memory.data(); }

char *Memory::end() { return begin() + memory.size(); }
