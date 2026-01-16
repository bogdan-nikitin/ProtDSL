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
    uint32_t get_#{reg.name}() {
        return reg_#{reg.name};
    }
DEF
    end

    methods << 
<<DEF
    void set_#{regfile.name}(int i, uint32_t value) {
        switch (i) {
#{
cases = []
regfile.registers.each_with_index do |reg, i|
    cases <<
<<CASE
            case #{i}:
                set_#{reg.name}(value);
                break;
CASE
end
cases.join "\n"
}
        }
    }
DEF
    methods << 
<<DEF
    uint32_t get_#{regfile.name}(int i) {
        switch (i) {
#{
cases = []
regfile.registers.each_with_index do |reg, i|
    cases <<
<<CASE
            case #{i}:
                return get_#{reg.name}();
CASE
end
cases.join "\n"
}
        }
        // unreachable
        return 0;
    }
DEF
end
definitions.join + "\n" + methods.join("\n")
}
};
CPP
    end
end
