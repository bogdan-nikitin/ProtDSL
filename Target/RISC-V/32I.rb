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

    Instruction(:SLL, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_alu(:sll, rd, rs1, rs2)
        asm { "SLL #{rd}, #{rs1}, #{rs2}" }
        code { rd[]= rs1 << (rs2 & 0x1f) }
    }

    Instruction(:SLT, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_alu(:slt, rd, rs1, rs2)
        asm { "SLT #{rd}, #{rs1}, #{rs2}" }
        code { rd[]= select(rs1 < rs2, 1, 0) }
    }

    Instruction(:SLTU, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_alu(:sltu, rd, rs1, rs2)
        asm { "SLTU #{rd}, #{rs1}, #{rs2}" }
        code { rd[]= select(rs1 < rs2, 1, 0) }
    }

    Instruction(:XOR, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_alu(:xor, rd, rs1, rs2)
        asm { "XOR #{rd}, #{rs1}, #{rs2}" }
        code { rd[]= rs1 ^ rs2 }
    }

    Instruction(:SRL, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_alu(:srl, rd, rs1, rs2)
        asm { "SRL #{rd}, #{rs1}, #{rs2}" }
        code { rd[]= rs1 >> (rs2 & 0x1f) }
    }

    Instruction(:SRA, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_alu(:sra, rd, rs1, rs2)
        asm { "SRA #{rd}, #{rs1}, #{rs2}" }
        code { rd[]= ashr(rs1, rs2 & 0x1f) }
    }

    Instruction(:OR, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_alu(:or, rd, rs1, rs2)
        asm { "OR #{rd}, #{rs1}, #{rs2}" }
        code { rd[]= rs1 | rs2 }
    }

    Instruction(:AND, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_alu(:and, rd, rs1, rs2)
        asm { "AND #{rd}, #{rs1}, #{rs2}" }
        code { rd[]= rs1 & rs2 }
    }

    Instruction(:ADDI, XReg(:rd), XReg(:rs1), Imm12(:imm)) {
        encoding *format_i_alu(:addi, rd, rs1, imm)
        asm { "ADDI #{rd}, #{rs1}, #{imm}" }
        code { rd[]= rs1 + i_imm }
    }

    Instruction(:SLTI, XReg(:rd), XReg(:rs1), Imm12(:imm)) {
        encoding *format_i_alu(:slti, rd, rs1, imm)
        asm { "SLTI #{rd}, #{rs1}, #{imm}" }
        code { rd[]= select(rs1 < i_imm, 1, 0) }
    }

    Instruction(:SLTIU, XReg(:rd), XReg(:rs1), Imm12(:imm)) {
        encoding *format_i_alu(:sltiu, rd, rs1, imm)
        asm { "SLTIU #{rd}, #{rs1}, #{imm}" }
        code { rd[]= select(rs1 < i_imm, 1, 0) }
    }

    Instruction(:XORI, XReg(:rd), XReg(:rs1), Imm12(:imm)) {
        encoding *format_i_alu(:xori, rd, rs1, imm)
        asm { "XORI #{rd}, #{rs1}, #{imm}" }
        code { rd[]= rs1 ^ i_imm }
    }

    Instruction(:ORI, XReg(:rd), XReg(:rs1), Imm12(:imm)) {
        encoding *format_i_alu(:ori, rd, rs1, imm)
        asm { "ORI #{rd}, #{rs1}, #{imm}" }
        code { rd[]= rs1 | i_imm }
    }

    Instruction(:ANDI, XReg(:rd), XReg(:rs1), Imm12(:imm)) {
        encoding *format_i_alu(:andi, rd, rs1, imm)
        asm { "ANDI #{rd}, #{rs1}, #{imm}" }
        code { rd[]= rs1 & i_imm }
    }

    Instruction(:SLLI, XReg(:rd), XReg(:rs1), Imm5(:imm)) {
        encoding *format_i_shift(:slli, rd, rs1, imm)
        asm { "SLLI #{rd}, #{rs1}, #{imm}" }
        code { rd[]= rs1 << imm }
    }

    Instruction(:SRLI, XReg(:rd), XReg(:rs1), Imm5(:imm)) {
        encoding *format_i_shift(:srli, rd, rs1, imm)
        asm { "SRLI #{rd}, #{rs1}, #{imm}" }
        code { rd[]= rs1 >> imm }
    }

    Instruction(:SRAI, XReg(:rd), XReg(:rs1), Imm5(:imm)) {
        encoding *format_i_shift(:srai, rd, rs1, imm)
        asm { "SRAI #{rd}, #{rs1}, #{imm}" }
        code { rd[]= ashr(rs1, imm) }
    }

    Instruction(:LB, XReg(:rd), XReg(:rs1), Imm12(:imm)) {
        encoding *format_i_mem(:lb, rd, rs1, imm)
        asm { "LB #{rd}, #{rs1}, #{imm}" }
        code { rd[]= sext(load8(rs1 + i_imm), 8) }
    }

    Instruction(:LH, XReg(:rd), XReg(:rs1), Imm12(:imm)) {
        encoding *format_i_mem(:lh, rd, rs1, imm)
        asm { "LH #{rd}, #{rs1}, #{imm}" }
        code { rd[]= sext(load16(rs1 + i_imm), 16) }
    }

    Instruction(:LW, XReg(:rd), XReg(:rs1), Imm12(:imm)) {
        encoding *format_i_mem(:lw, rd, rs1, imm)
        asm { "LW #{rd}, #{rs1}, #{imm}" }
        code { rd[]= load32(rs1 + i_imm) }
    }

    Instruction(:LBU, XReg(:rd), XReg(:rs1), Imm12(:imm)) {
        encoding *format_i_mem(:lbu, rd, rs1, imm)
        asm { "LBU #{rd}, #{rs1}, #{imm}" }
        code { rd[]= load8(rs1 + i_imm) }
    }

    Instruction(:LHU, XReg(:rd), XReg(:rs1), Imm12(:imm)) {
        encoding *format_i_mem(:lhu, rd, rs1, imm)
        asm { "LHU #{rd}, #{rs1}, #{imm}" }
        code { rd[]= load16(rs1 + i_imm) }
    }

    Instruction(:SB, XReg(:rs1), XReg(:rs2), Imm5(:imm), Imm7(:imm_hi)) {
        encoding *format_s(:sb, rs1, rs2, imm, imm_hi)
        asm { "SB #{rs2}, #{rs1}, #{imm}" }
        code { store8(rs2, rs1 + s_imm) }
    }

    Instruction(:SH, XReg(:rs1), XReg(:rs2), Imm5(:imm), Imm7(:imm_hi)) {
        encoding *format_s(:sh, rs1, rs2, imm, imm_hi)
        asm { "SH #{rs2}, #{rs1}, #{imm}" }
        code { store16(rs2, rs1 + s_imm) }
    }

    Instruction(:SW, XReg(:rs1), XReg(:rs2), Imm5(:imm), Imm7(:imm_hi)) {
        encoding *format_s(:sw, rs1, rs2, imm, imm_hi)
        asm { "SW #{rs2}, #{rs1}, #{imm}" }
        code { store32(rs2, rs1 + s_imm) }
    }

    Instruction(:BEQ, XReg(:rs1), XReg(:rs2), Imm5(:imm), Imm7(:imm_hi)) {
        encoding *format_b(:beq, rs1, rs2, imm, imm_hi)
        asm { "BEQ #{rs1}, #{rs2}, #{imm}" }
        code { pc[]= pc + select(rs1 == rs2, b_imm, 4) }
    }

    Instruction(:BNE, XReg(:rs1), XReg(:rs2), Imm5(:imm), Imm7(:imm_hi)) {
        encoding *format_b(:bne, rs1, rs2, imm, imm_hi)
        asm { "BNE #{rs1}, #{rs2}, #{imm}" }
        code { pc[]= pc + select(rs1 != rs2, b_imm, 4) }
    }

    Instruction(:BLT, XReg(:rs1), XReg(:rs2), Imm5(:imm), Imm7(:imm_hi)) {
        encoding *format_b(:blt, rs1, rs2, imm, imm_hi)
        asm { "BLT #{rs1}, #{rs2}, #{imm}" }
        code { pc[]= pc + select(rs1 < rs2, b_imm, 4) }
    }

    Instruction(:BGE, XReg(:rs1), XReg(:rs2), Imm5(:imm), Imm7(:imm_hi)) {
        encoding *format_b(:bge, rs1, rs2, imm, imm_hi)
        asm { "BGE #{rs1}, #{rs2}, #{imm}" }
        code { pc[]= pc + select(rs1 >= rs2, b_imm, 4) }
    }

    Instruction(:BLTU, XReg(:rs1), XReg(:rs2), Imm5(:imm), Imm7(:imm_hi)) {
        encoding *format_b(:bltu, rs1, rs2, imm, imm_hi)
        asm { "BLTU #{rs1}, #{rs2}, #{imm}" }
        code { pc[]= pc + select(rs1 < rs2, b_imm, 4) }
    }

    Instruction(:BGEU, XReg(:rs1), XReg(:rs2), Imm5(:imm), Imm7(:imm_hi)) {
        encoding *format_b(:bgeu, rs1, rs2, imm, imm_hi)
        asm { "BGEU #{rs1}, #{rs2}, #{imm}" }
        code { pc[]= pc + select(rs1 >= rs2, b_imm, 4) }
    }

    Instruction(:LUI, XReg(:rd), Imm20(:imm)) {
        encoding *format_u(:lui, rd, imm)
        asm { "LUI #{rd}, #{imm}" }
        code { rd[]= u_imm }
    }

    Instruction(:AUIPC, XReg(:rd), Imm20(:imm)) {
        encoding *format_u(:auipc, rd, imm)
        asm { "AUIPC #{rd}, #{imm}" }
        code { rd[]= pc + u_imm }
    }

    Instruction(:JAL, XReg(:rd), Imm20(:imm)) {
        encoding *format_j(:jal, rd, imm)
        asm { "JAL #{rd}, #{imm}" }
        code {
            t = pc + 4
            pc[]= pc + j_imm
            rd[]= t
        }
    }

    Instruction(:JALR, XReg(:rd), XReg(:rs1), Imm12(:imm)) {
        encoding *format_i_jalr(:jalr, rd, rs1, imm)
        asm { "JALR #{rd}, #{rs1}, #{imm}" }
        code {
            t = pc + 4
            pc[]= (rs1 + i_imm) & 0xfffffffe
            rd[]= t
        }
    }

    Instruction(:MUL, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_alu(:mul, rd, rs1, rs2)
        asm { "MUL #{rd}, #{rs1}, #{rs2}" }
        code { rd[]= (rs1 * rs2) & 0xffffffff }
    }

    Instruction(:DIVU, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_alu(:divu, rd, rs1, rs2)
        asm { "DIVU #{rd}, #{rs1}, #{rs2}" }
        code { rd[]= rs1 / rs2 }
    }

    Instruction(:REMU, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_alu(:remu, rd, rs1, rs2)
        asm { "REMU #{rd}, #{rs1}, #{rs2}" }
        code { rd[]= rs1 % rs2 }
    }

    Instruction(:DIV, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_alu(:div, rd, rs1, rs2)
        asm { "DIV #{rd}, #{rs1}, #{rs2}" }
        code { rd[]= divs(rs1, rs2) }
    }

    Instruction(:REM, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_alu(:rem, rd, rs1, rs2)
        asm { "REM #{rd}, #{rs1}, #{rs2}" }
        code { rd[]= rems(rs1, rs2) }
    }

    Instruction(:ECALL) {
        encoding *format_sys(:ecall)
        asm { "ECALL" }
    }

    Instruction(:EBREAK) {
        encoding *format_sys(:ebreak)
        asm { "EBREAK" }
    }
end
