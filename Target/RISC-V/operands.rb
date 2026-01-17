module SimInfra
    def XReg(name) = Operand.new(name, :regclass, :XRegs)
    def Imm20(name) = Operand.new(name, :operand, 20)
    def Imm12(name) = Operand.new(name, :operand, 12)
    def Imm5(name) = Operand.new(name, :operand, 5)
    def Imm5(name) = Operand.new(name, :operand, 5)
    def Imm7(name) = Operand.new(name, :operand, 7)
end
