#include "executor.h"
#include "syscall.h"
#include <iostream>
#include <string>


enum Syscall {
    READ = 63,
    WRITE = 64,
    EXIT = 93,
};


void Executor::init() {
    cpu_state.set_x2(memory.reverse_address(memory.end())); // stack pointer
}


void Executor::do_ECALL(Instruction &) {
    uint32_t syscall = cpu_state.get_x17();
    switch (syscall) {
        case WRITE: {
            uint32_t fd     = cpu_state.get_x10();
            uint32_t buf    = cpu_state.get_x11();
            uint32_t count  = cpu_state.get_x12();
            uint32_t i = 0;
            if (fd == 1) { // stdout
                for (; i < count; ++i) {
                    uint8_t c = memory.read<uint8_t>(buf + i);
                    std::cout.put(static_cast<char>(c));
                }
                std::cout.flush();
            } 
            cpu_state.set_x10(i);
            break;
        }
        case READ: {
            uint32_t fd     = cpu_state.get_x10();
            uint32_t buf    = cpu_state.get_x11();
            uint32_t count  = cpu_state.get_x12();
            uint32_t read_bytes = 0;

            if (fd == 0) { // stdin
                for (uint32_t i = 0; i < count; ++i) {
                    int c = std::cin.get();
                    if (c == EOF) break;
                    memory.write<uint8_t>(static_cast<uint8_t>(c), buf + i);
                    ++read_bytes;
                }
            } 
            cpu_state.set_x10(read_bytes);
            break;
        }
        case EXIT: {
            uint32_t code = cpu_state.get_x10();
            throw ExitSignal{static_cast<int>(code)};
        }
        default:
            throw BadSyscall{"Unknown syscall " + std::to_string(syscall)};
    }
    cpu_state.set_pc(cpu_state.get_pc() + 4);
}

void Executor::do_EBREAK(Instruction&) {
    std::cout << "EBREAK called\n";
    cpu_state.set_pc(cpu_state.get_pc() + 4);
}
