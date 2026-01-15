module SimInfra
    def self.gen_cpu_state 
<<CPP
#pragma once
#include <cstdint>


struct CpuState {
#{
definitions = []
methods = []
for regfile in @@register_files
    for reg in regfile.registers
        definitions << 
<<DEF
    uint32_t reg_#{reg.name} = 0;
DEF
        methods << 
<<DEF
    void set_#{reg.name}(uint32_t value) {
#{
        if !reg.attrs.include? :zero
<<BODY
        reg_#{reg.name} = value;
BODY
        end
}
    }
DEF
        methods << 
<<DEF
    uint32_t get_#{reg.name}(uint32_t value) {
        return reg_#{reg.name};
    }
DEF
    end
end
definitions.join + "\n" + methods.join("\n")
}
};
CPP
    end
end
