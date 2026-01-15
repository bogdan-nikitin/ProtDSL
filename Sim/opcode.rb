module SimInfra
    def self.gen_opcode
<<CPP
#pragma once


enum Opcode {
#{
opcodes = []
for insn in @@instructions
    opcodes << "    #{insn.name}"
end
opcodes.join ",\n"
}
};
CPP
    end
end
