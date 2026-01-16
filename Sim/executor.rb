require_relative "util"

BIN_OPS = {
    add: "+",
    sub: "-",
    xor: "^",
    shl: "<<",
}

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
#{gen_body(insn).indent(8)}
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

    void execute(Instruction& insn) {
        (this->*handlers[insn.opcode])(insn);
    }

};
CPP
    end

    private
    def self.gen_body(insn)
        body = []
        for stmt in insn.code.tree
            body << gen_stmt(stmt, insn.args)
            # printf("%s\n", stmt)
        end
        body.join "\n"
    end

    private
    def self.gen_stmt(stmt, oprnds)
        if stmt.name == :new_var
            "uint32_t #{stmt.oprnds[0].name};"
        elsif stmt.name == :new_const
            "uint32_t #{stmt.oprnds[0].name} = #{stmt.oprnds[1]};"
        elsif stmt.name == :let
            "#{stmt.oprnds[0].name} = #{stmt.oprnds[1].name};"
        elsif stmt.name == :init_imm
            "#{stmt.oprnds[0].name} = insn.operands[#{oprnds.index(stmt.oprnds[1])}];"
        elsif stmt.name == :getreg
            opd = stmt.oprnds[1]
            "#{stmt.oprnds[0].name} = cpu_state.get_#{opd.attrs[0]}(insn.operands[#{oprnds.index(opd)}]);"
        elsif stmt.name == :setreg
            opd = stmt.oprnds[0]
            "cpu_state.set_#{opd.attrs[0]}(insn.operands[#{oprnds.index(opd)}], #{stmt.oprnds[0].name});"
        elsif BIN_OPS.include? stmt.name
            "#{stmt.oprnds[0].name} = #{stmt.oprnds[1].name} #{BIN_OPS[stmt.name]} #{stmt.oprnds[2].name};"
        end
    end
end
