#pragma once
#include <vector>


class Memory {
    std::vector<char> memory;
    using Address = uint32_t;

    template <typename T> T read(Address address);
public:
    void load_executable(const char* data, size_t size);
    std::uint32_t read32(Address address);
    char *begin();
    char *end();
};

template <typename T> inline T Memory::read(Address address) {
  return *reinterpret_cast<T *>(address);
}
