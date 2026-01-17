#include "mem.h"
#include <cstdint>
#include <limits>
#include <string_view>
#include <elfio/elfio.hpp>


void Memory::load_executable(std::string_view path) {
    ELFIO::elfio reader;

    if (!reader.load(path.data())) {
        throw ElfError("Failed to load ELF");
    }

    uint64_t base = std::numeric_limits<uint64_t>::max();
    uint64_t end  = 0;

    for (const auto& seg : reader.segments) {
        if (seg->get_type() == ELFIO::PT_LOAD) {
            uint64_t vaddr = seg->get_virtual_address();
            uint64_t memsz = seg->get_memory_size();

            base = std::min(base, vaddr);
            end  = std::max(end,  vaddr + memsz);
        }
    }

    if (base == std::numeric_limits<uint64_t>::max()) {
        throw ElfError("No PT_LOAD segments");
    }

    memory.resize(end - base);
    base_address = base;
    entry_point = reader.get_entry();
    for (const auto& seg : reader.segments) {
        if (seg->get_type() == ELFIO::PT_LOAD) {
            uint64_t vaddr  = seg->get_virtual_address();
            uint64_t filesz = seg->get_file_size();
            const char* data = seg->get_data();

            std::memcpy(
                memory.data() + (vaddr - base),
                data,
                filesz
            );
        }
    }
}

std::uint32_t Memory::read32(Address address) {
    return read<std::uint32_t>(address);
}

void *Memory::translate_address(Address address) {
    return reinterpret_cast<void *>(address + address_space_offset());
}

char *Memory::begin() { return memory.data(); }

char *Memory::end() { return begin() + memory.size(); }

std::uint64_t Memory::address_space_offset() {
    return reinterpret_cast<std::uint64_t>(begin()) - base_address;
}

Memory::Address Memory::get_entry_point() {
    return entry_point;
}

