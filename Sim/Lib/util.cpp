#include "util.h"


std::uint32_t slice(std::uint32_t value, std::size_t end, std::size_t start) {
  std::size_t width = end - start + 1;
  return (value >> start) & ((UINT64_C(1) << width) - 1);
}

