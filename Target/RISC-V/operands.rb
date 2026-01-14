module SimInfra
    def XReg(name) = Operand.new(name, :regclass, :XRegs)
    def Imm12(name) = Operand.new(name, :operand, 12)
    def Imm5(name) = Operand.new(name, :operand, 5)
end
