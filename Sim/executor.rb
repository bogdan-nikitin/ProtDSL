require_relative "util"
require_relative "../Generic/shared"

BIN_OPS = {
    add: "+",
    sub: "-",
    xor: "^",
    shl: "<<",
    and: "&",
    or: "|",
    ult: "<",
    uge: ">=",
    lshr: ">>",
    ne: '!=',
    mul: '*',
    div: '/',
    mod: '%',
}


def signed_op(a, b, op)
    "static_cast<uint32_t>(static_cast<int32_t>(#{a}) #{op} static_cast<int32_t>(#{b}))"
end

module SimInfra
    def self.gen_executor
<<CPP
#pragma once
#include "cpu_state.h"
#include "instruction.h"
#include "mem.h"
#include "decoder.h"
#include "syscall.h"


struct Executor {
    CpuState &cpu_state;
    Memory &memory;
    Decoder decoder;


    Executor(CpuState &cpu_state, Memory &memory) : 
        cpu_state{cpu_state}, memory{memory} {}

    void init();

#{
methods = []
for insn in @@instructions
    sig = "void do_#{insn.name}(Instruction &insn)"
    if insn.code.nil?
        methods << "#{sig};\n".indent(8)
    else
        methods <<
<<DEF
    #{sig} {
#{gen_body(insn).indent(8)}
    }
DEF
    end
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
handlers.join ""
}
    };

    void execute(Instruction& insn) {
        (this->*handlers[insn.opcode])(insn);
    }

    int run() {
        init();
        cpu_state.set_#{get_pc().name}(memory.get_entry_point());
        while (true) {
            uint32_t insn = memory.read32(cpu_state.get_#{get_pc().name}());
            Instruction decoded = decoder.decode(insn);
            try {
                execute(decoded);
            } catch (const ExitSignal &e) {
                return e.get_code();
            }
        }
    }

};
CPP
    end

    private
    def self.gen_body(insn)
        body = []
        for stmt in insn.code.tree
            body << gen_stmt(stmt, insn.args)
        end
        if !change_pc?(insn)
            pc = get_pc()
            body << "cpu_state.set_#{pc.name}(cpu_state.get_#{pc.name}() + 4);"
        end
        body.join "\n"
    end

    private
    def self.gen_stmt(stmt, oprnds)
        name = stmt.name
        if name == :new_var
            "uint32_t #{stmt.oprnds[0].name};"
        elsif name == :new_const
            "uint32_t #{stmt.oprnds[0].name} = #{stmt.oprnds[1]};"
        elsif name == :let
            "#{stmt.oprnds[0].name} = #{stmt.oprnds[1].name};"
        elsif name == :init_imm
            "#{stmt.oprnds[0].name} = insn.operands[#{oprnds.index(stmt.oprnds[1])}];"
        elsif name == :getreg
            opd = stmt.oprnds[1]
            if opd.class == Operand
                "#{stmt.oprnds[0].name} = cpu_state.get_#{opd.attrs[0]}(insn.operands[#{oprnds.index(opd)}]);"
            elsif opd.class == Register
                "#{stmt.oprnds[0].name} = cpu_state.get_#{opd.name}();"
            end
        elsif name == :setreg
            opd = stmt.oprnds[0]
            if opd.class == Operand
                "cpu_state.set_#{opd.attrs[0]}(insn.operands[#{oprnds.index(opd)}], #{stmt.oprnds[0].name});"
            elsif opd.class == Register
                "cpu_state.set_#{opd.name}(#{stmt.oprnds[0].name});"
            end
        elsif name == :eq
            "#{stmt.oprnds[0].name} = static_cast<uint32_t>(#{stmt.oprnds[1].name} == #{stmt.oprnds[2].name});"
        elsif name == :ashr
            "#{stmt.oprnds[0].name} = #{signed_op(stmt.oprnds[1].name, stmt.oprnds[2].name, '>>')};"
        elsif name == :select
            "#{stmt.oprnds[0].name} = #{stmt.oprnds[1].name} ? #{stmt.oprnds[2].name} : #{stmt.oprnds[3].name};"
        elsif name == :divs
            "#{stmt.oprnds[0].name} = #{signed_op(stmt.oprnds[1].name, stmt.oprnds[2].name, '/')};"
        elsif name == :rems
            "#{stmt.oprnds[0].name} = #{signed_op(stmt.oprnds[1].name, stmt.oprnds[2].name, '%')};"
        elsif name == :mulhu
            "#{stmt.oprnds[0].name} = static_cast<uint32_t>((static_cast<uint64_t>(#{stmt.oprnds[1].name}) * static_cast<uint64_t>(#{stmt.oprnds[2].name})) >> 32);"
        elsif name.start_with? 'load'
            "#{stmt.oprnds[0].name} = memory.read<uint#{name[4, 2]}_t>(#{stmt.oprnds[1].name});"
        elsif name.start_with? 'store'
            "memory.write<uint#{name[5, 2]}_t>(#{stmt.oprnds[1].name}, #{stmt.oprnds[2].name});"
        elsif BIN_OPS.include? name
            "#{stmt.oprnds[0].name} = #{stmt.oprnds[1].name} #{BIN_OPS[name]} #{stmt.oprnds[2].name};"
        else
            raise "Unhandled #{name}"
        end
    end
end
