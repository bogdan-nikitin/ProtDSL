module SimInfra
    def self.get_pc()
        for regfile in @@register_files
            for reg in regfile.registers
                if reg.attrs.include? :pc
                    return reg
                end
            end
        end
    end

    private
    def self.change_pc?(insn)
        tree = insn.code.tree
        for stmt in tree
            next if stmt.name != :setreg
            reg = stmt.oprnds[0]
            return true if reg.class == Register and reg.attrs.include? :pc
        end
        false
    end

end
