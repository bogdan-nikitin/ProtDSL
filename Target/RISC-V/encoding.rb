require_relative "../../Generic/base"

module SimInfra
    def format_r(opcode, funct3, funct7, rd, rs1, rs2)
        return :R, [
            field(rd.name, 11, 7, :reg),
            field(rs1.name, 19, 15, :reg),
            field(rs2.name, 24, 20, :reg),
            field(:opcode, 6, 0, opcode),
            field(:funct7, 31, 25, funct7),
            field(:funct3, 14, 12, funct3),
        ]
    end

    def format_r_alu(name, rd, rs1, rs2)
        funct3, funct7 =
        {
            add: [0x0, 0x00],
            sub: [0x0, 0x20],
            sll: [0x1, 0x00],
            slt: [0x2, 0x00],
            sltu: [0x3, 0x00],
            xor: [0x4, 0x00],
            srl: [0x5, 0x00],
            sra: [0x5, 0x20],
            or: [0x6, 0x00],
            and: [0x7, 0x00],
            mul: [0x0, 0x01],
            mulh: [0x1, 0x01],
            mulhsu: [0x2, 0x01],
            mulhu: [0x3, 0x01],
            div: [0x4, 0x01],
            divu: [0x5, 0x01],
            rem: [0x6, 0x01],
            remu: [0x7, 0x01],
        }[name]
        format_r(0b0110011, funct3, funct7, rd, rs1, rs2)
    end

    def format_i(opcode, funct3, rd, rs1, imm12)
        return :I, [
            field(rd.name, 11, 7, :reg),
            field(rs1.name, 19, 15, :reg),
            field(imm12.name, 31, 20, :imm),
            field(:opcode, 6, 0, opcode),
            field(:funct3, 14, 12, funct3),
        ]
    end

    def format_i_alu(name, rd, rs1, imm12)
        funct3 =
        {
            addi: 0x0,
            slti: 0x2,
            sltiu: 0x3,
            xori: 0x4,
            ori: 0x6,
            andi: 0x7,
        }[name]
        format_i(0b0010011, funct3, rd, rs1, imm12)
    end

    def format_i_shift(name, rd, rs1, imm5)
        funct3, imm5hi =
        {
            slli: [0x1, 0x00],
            srli: [0x5, 0x00],
            srai: [0x5, 0x20],
        }[name]
        return :I_shift, [
            field(rd.name, 11, 7, :reg),
            field(rs1.name, 19, 15, :reg),
            field(imm5.name, 24, 20, :imm),
            field(:opcode, 6, 0, 0b0010011),
            field(:imm5hi, 31, 25, imm5hi),
            field(:funct3, 14, 12, funct3),
        ]
    end

    def format_i_mem(name, rd, rs1, imm12)
        funct3 =
        {
            lb: 0x0,
            lh: 0x1,
            lw: 0x2,
            lbu: 0x4,
            lhu: 0x5,
        }[name]
        format_i(0b0000011, funct3, rd, rs1, imm12)
    end

    def format_s(name, rs1, rs2, imm5, imm_hi)
        funct3 =
        {
            sb: 0x0,
            sh: 0x1,
            sw: 0x2,
        }[name]
        return :S, [
            field(imm5.name, 11, 7, :imm),
            field(rs2.name, 24, 20, :reg),
            field(rs1.name, 19, 15, :reg),
            field(:opcode, 6, 0, 0b0100011),
            field(:funct3, 14, 12, funct3),
            field(imm_hi.name, 31, 25, :imm_hi),
        ]
    end

    def format_b(name, rs1, rs2, imm5, imm_hi)
        funct3 =
        {
            beq: 0x0,
            bne: 0x1,
            blt: 0x4,
            bge: 0x5,
            bltu: 0x6,
            bgeu: 0x7,
        }[name]
        return :B, [
            field(imm5.name, 11, 7, :imm),
            field(rs1.name, 19, 15, :reg),
            field(rs2.name, 24, 20, :reg),
            field(:opcode, 6, 0, 0b1100011),
            field(:funct3, 14, 12, funct3),
            field(imm_hi.name, 31, 25, :imm_hi),
        ]
    end

    def format_u(name, rd, imm20)
        opcode =
        {
            lui: 0b0110111,
            auipc: 0b0010111,
        }[name]
        return :U, [
            field(rd.name, 11, 7, :reg),
            field(imm20.name, 31, 12, :imm),
            field(:opcode, 6, 0, opcode),
        ]
    end

    def format_j(name, rd, imm20)
        return :J, [
            field(rd.name, 11, 7, :reg),
            field(imm20.name, 31, 12, :imm),
            field(:opcode, 6, 0, 0b1101111),
        ]
    end

    def format_i_jalr(name, rd, rs1, imm12)
        return :I_jalr, [
            field(rd.name, 11, 7, :reg),
            field(rs1.name, 19, 15, :reg),
            field(imm12.name, 31, 20, :imm),
            field(:opcode, 6, 0, 0b1100111),
            field(:funct3, 14, 12, 0x0),
        ]
    end

    def format_sys(name)
        opcode, funct12 =
        {
            ecall: [0b1110011, 0],
            ebreak: [0b1110011, 1]
        }[name]
        return :SYSTEM, [
            field(:opcode, 6, 0, opcode),
            field(:funct12, 31, 20, funct12),
        ]
    end

    class Scope 
        def sext(value, size)
            mask = 1 << (size - 1)
            (value ^ mask) - mask
        end

        def i_imm
            sext(imm, 12)
        end

        def b_imm
            raw = 
                ((imm_hi & 0x40) << 6) | 
                ((imm_hi & 0x3f) << 5) | 
                ((imm & 0x1e)) | 
                ((imm & 0x1) << 11)
            sext(raw, 13)
        end

        def s_imm
            raw = (imm_hi << 5) | imm
            sext(raw, 12)
        end


        def u_imm
            imm << 12
        end

        def j_imm
            raw = 
                ((imm & 0xff) << 12) |
                ((imm & 0x100) << 3) |
                ((imm & 0x7fe00) >> 8) |
                ((imm & 0x80000) << 1)
            sext(raw, 21)
        end
    end
end
