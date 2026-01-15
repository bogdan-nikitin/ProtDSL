#include <cstdint>
#include "opcode.h"

#define MAX_OPERANDS 4


struct Instruction {
    Opcode opcode;
    uint32_t operands[MAX_OPERANDS];
};
