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
            add: [0, 0],
            sub: [0, 0x20]
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
            addi: 0,
        }[name]
        format_i(0b0010011, funct3, rd, rs1, imm12)
    end

    def format_i_shift(name, rd, rs1, imm5)
        funct3, imm5hi = 
        {
            slli: [0x1, 0x00],
            srli: [0x5, 0x00],
            srai: [0x5, 0x20]
        }
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
            lb: 0x0
        }[name]
        format_i(0b0010011, funct3, rd, rs1, imm12)
    end

    def format_b(name, rs1, rs2, imm5, imm7)
        funct3 =
        {
            beq: 0x0,
        }[name]
        return :B, [
            field(imm7.name, 31, 25, :imm_hi),
            field(rs1.name, 19, 15, :reg),
            field(rs2.name, 24, 20, :reg),
            field(imm5.name, 11, 7, :imm),
            field(:opcode, 6, 0, 0b1100011),
            field(:funct3, 14, 12, funct3),
        ]
    end

    class Scope 
        def sext(value, size)
            mask = 1 << (size - 1)
            (value ^ mask) - mask
        end

        def i_imm
            # zext(imm, 32) ^ mask - mask
            sext(imm, 12)
        end

        def b_imm
            raw = (
                ((imm & 1) << 11) | 
                (imm & 0) | 
                ((imm_hi & 0b111111) << 5) |
                ((imm_hi & 0b1000000) << 12)
            )
            sext(raw, 13)
        end
    end
end
