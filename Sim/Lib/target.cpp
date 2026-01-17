#include "executor.h"
#include <iostream>


void Executor::do_ECALL(Instruction &insn) {
    std::cout << "ECALL called\n";
}

void Executor::do_EBREAK(Instruction &insn) {
    std::cout << "EBREAK called\n";
}
