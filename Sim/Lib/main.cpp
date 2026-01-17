#include <iomanip>
#include <iostream>
#include "cpu_state.h"
#include "executor.h"
#include "mem.h"


int main(int argc, char** argv) {
    std::cout << "Run sim\n";
    if (argc != 2) {
        std::cerr << "Usage: " << argv[0] << " <riscv_elf>\n";
        return 1;
    }

    Memory mem;
    try {
        mem.load_executable(argv[1]); 
        CpuState cpu_state;
        Executor executor(cpu_state, mem);
        const char* data = static_cast<char*>(mem.translate_address(mem.get_entry_point()));

        for (int i = 0; i < 4; ++i) {
            std::cout << std::hex << std::setw(2) << std::setfill('0')
                      << (static_cast<unsigned>(static_cast<unsigned char>(data[3 - i])))
                      << " ";
        }

        std::cout << std::dec << "\n";
        executor.run();
    } catch (const ElfError &err) {
        std::cerr << "Elf error: " << err.what() << "\n";
    } catch (const DecodeError &err) {
        std::cerr << "Decoding error: " << err.what() << "\n";
    } catch (const std::runtime_error &err) {
        std::cerr << "Error during run: " << err.what() << "\n";
    }

    return 0;
}
