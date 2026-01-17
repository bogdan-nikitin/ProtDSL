require_relative "encoding"
require_relative "operands"
require_relative "../../Generic/base"

module RV32I
    extend SimInfra

    RegisterFile(:XRegs, 32) {
        reg :x0, :zero
        reg :x1
        reg :x2
        reg :x3
        reg :x4
        reg :x5
        reg :x6
        reg :x7
        reg :x8
        reg :x9
        reg :x10
        reg :x11
        reg :x12
        reg :x13
        reg :x14
        reg :x15
        reg :x16
        reg :x17
        reg :x18
        reg :x19
        reg :x20
        reg :x21
        reg :x22
        reg :x23
        reg :x24
        reg :x25
        reg :x26
        reg :x27
        reg :x28
        reg :x29
        reg :x30
        reg :x31
    }


    RegisterFile(:Sys, 32) {
        reg :pc, :pc
    }

    Instruction(:ADD, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_alu(:add, rd, rs1, rs2)
        asm { "ADD #{rd}, #{rs1}, #{rs2}" }
        code { rd[]= rs1 + rs2 }
    }

    Instruction(:SUB, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_alu(:sub, rd, rs1, rs2)
        asm { "SUB #{rd}, #{rs1}, #{rs2}" }
        code { rd[]= rs1 - rs2 }
    }

    Instruction(:ADDI, XReg(:rd), XReg(:rs1), Imm12(:imm)) {
        encoding *format_i_alu(:addi, rd, rs1, imm)
        asm { "ADDI #{rd}, #{rs1}, #{imm}" }
        code { rd[]= rs1 + i_imm }
    }

    Instruction(:SLLI, XReg(:rd), XReg(:rs1), Imm5(:imm)) {
        encoding *format_i_shift(:slli, rd, rs1, imm)
        asm { "SLLI #{rd}, #{rs1}, #{imm}" }
        code { rd[]= rs1 << imm }
    }

    Instruction(:BEQ, XReg(:rs1), XReg(:rs2), Imm5(:imm), Imm7(:imm_hi)) {
        encoding *format_b(:slli, rs1, rs2, imm, imm_hi)
        asm { "BEQ #{rs1}, #{rs2}, #{imm}" }
        code { pc[] = pc + select(rs1 == rs2, b_imm, 4) }
    }

    Instruction(:LB, XReg(:rd), XReg(:rs1), Imm12(:imm)) {
        encoding *format_i_mem(:lb, rd, rs1, imm)
        asm { "LB #{rd}, #{rs1}, #{imm}" }
        code { rd[] = sext(load8(rs1 + i_imm), 8) }
    }
end
