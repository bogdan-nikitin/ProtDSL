#pragma once
#include <stdexcept>
#include <string_view>
#include <vector>


class ElfError : public std::runtime_error {
    using std::runtime_error::runtime_error;
};


class Memory {
    std::vector<char> memory;
    uint32_t entry_point;
    uint64_t base_address;
    using Address = uint32_t;

    template <typename T> T read(Address address);
public:
    void load_executable(std::string_view path);
    Address get_entry_point();
    std::uint32_t read32(Address address);
    void *translate_address(Address address);
    std::uint64_t address_space_offset();
    char *begin();
    char *end();
};

template <typename T> inline T Memory::read(Address address) {
  return *reinterpret_cast<T *>(translate_address(address));
}
