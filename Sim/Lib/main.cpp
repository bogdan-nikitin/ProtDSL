#include <elfio/elfio.hpp>
#include <iostream>
#include <iomanip>
#include "cpu_state.h"
#include "executor.h"
#include "mem.h"


int main(int argc, char** argv) {
    std::cout << "Hello\n";
    if (argc != 2) {
        std::cerr << "Usage: " << argv[0] << " <riscv_elf>\n";
        return 1;
    }

    ELFIO::elfio reader;

    if (!reader.load(argv[1])) {
        std::cerr << "Failed to load ELF file\n";
        return 1;
    }

    const ELFIO::section* text = reader.sections[".text"];
    if (!text) {
        std::cerr << "No .text section found\n";
        return 1;
    }

    const char* data = text->get_data();
    Memory mem;
    std::cout << "Executable size: " << text->get_size() << "\n";
    mem.load_executable(data, text->get_size()); 
    CpuState cpu_state;
    Executor executor(cpu_state, mem);

    for (int i = 0; i < 4; ++i) {
        std::cout << std::hex << std::setw(2) << std::setfill('0')
                  << (static_cast<unsigned>(static_cast<unsigned char>(data[3 - i])))
                  << " ";
    }

    std::cout << std::dec << "\n";

    return 0;
}
