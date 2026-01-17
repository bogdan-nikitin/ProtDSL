module SimInfra
    def self.gen_decoder
<<CPP
#pragma once
#include <stdexcept>
#include "instruction.h"


struct DecodeError : public std::runtime_error {
     using std::runtime_error::runtime_error;
};


struct Decoder {
    Instruction decode(uint32_t insn) {
        throw DecodeError{"unimplemented"};
    }
};
CPP
    end
end
