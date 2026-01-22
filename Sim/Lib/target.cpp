#include "executor.h"
#include "syscall.h"
#include <iostream>


void Executor::do_ECALL(Instruction &) {
    uint32_t syscall = cpu_state.get_x17();
    switch (syscall) {
        case 64: { // write
            uint32_t fd     = cpu_state.get_x10();
            uint32_t buf    = cpu_state.get_x11();
            uint32_t count  = cpu_state.get_x12();
            if (fd == 1) {
                for (uint32_t i = 0; i < count; ++i) {
                    uint8_t c = memory.read<uint8_t>(buf + i);
                    std::cout.put(static_cast<char>(c));
                }
                std::cout.flush();
            }
            cpu_state.set_x10(count);
            break;
        }
        case 63: { // read
            uint32_t fd     = cpu_state.get_x10();
            uint32_t buf    = cpu_state.get_x11();
            uint32_t count  = cpu_state.get_x12();
            uint32_t read_bytes = 0;
            std::cout << fd << " " << buf << " " << count << "\n";

            if (fd == 0) { // stdin
                for (uint32_t i = 0; i < count; ++i) {
                    int c = std::cin.get();
                    if (c == EOF) break;
                    memory.write<uint8_t>(static_cast<uint8_t>(c), buf + i);
                    read_bytes++;
                }
            } 
            cpu_state.set_x10(read_bytes);
            break;
        }
        case 93: { // exit
            uint32_t code = cpu_state.get_x10();
            throw ExitSignal{static_cast<int>(code)};
        }
        default:
            throw BadSyscall{"Unknown syscall"};
    }
    cpu_state.set_pc(cpu_state.get_pc() + 4);
}

void Executor::do_EBREAK(Instruction&) {
    std::cout << "EBREAK called\n";
    cpu_state.set_pc(cpu_state.get_pc() + 4);
}
