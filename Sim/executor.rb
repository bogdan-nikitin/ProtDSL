module SimInfra
    def self.gen_executor
<<CPP
#pragma once
#include "cpu_state.h"
#include "instruction.h"


struct Executor {
    CpuState cpu_state;

#{
methods = []
for insn in @@instructions
    methods <<
<<DEF
    void do_#{insn.name}(Instruction &insn) {

    }
DEF
end
methods.join "\n"
}

    using handler_t = void (Executor::*)(Instruction&);

    constexpr static handler_t handlers[] = {
#{
handlers = []
for insn in @@instructions
    handlers <<
<<DEF
    &Executor::do_#{insn.name},
DEF
end
handlers.join "\n"
}
    };

};
CPP
    end
end
