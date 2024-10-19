pub const RType = struct {
    rs2: u5,
    rs1: u5,
    rd: u5,

    pub fn decode(raw_without_opcode: u25) .{ RType, u3, u7 } {
        const funct3_bytes: u20 = raw_without_opcode >> 5;
        const funct3: u3 = funct3_bytes & 0b111;
        const rs1: u17 = funct3_bytes >> 3;
        const rs2: u12 = rs1 >> 5;
        const funct7: u7 = (rs2 >> 5) & 0b111_1111;
        return .{
            .{
                .rs2 = @intCast(rs2 & 0b1_1111),
                .rs1 = @intCast(rs1 & 0b1_1111),
                .rd = @intCast(raw_without_opcode & 0b1_1111),
            },
            funct3,
            funct7,
        };
    }
};

pub const IType = struct {
    imm: u12,
    rs1: u5,
    rd: u5,

    pub fn decode(raw_without_opcode: u25) .{ IType, u3 } {
        const funct3_bytes: u20 = raw_without_opcode >> 5;
        const funct3: u3 = funct3_bytes & 0b111;
        const rs1: u17 = funct3_bytes >> 3;
        const imm: u12 = rs1 >> 5;
        return .{
            .{
                .imm = @intCast(imm),
                .rs1 = @intCast(rs1 & 0b1_1111),
                .rd = @intCast(raw_without_opcode & 0b1_1111),
            },
            funct3,
        };
    }
};

pub const SType = struct {
    imm: u12,
    rs2: u5,
    rs1: u5,

    pub fn decode(raw_without_opcode: u25) .{ SType, u3 } {
        const imm4_0: u5 = raw_without_opcode & 0b1_1111;
        const funct3_bytes: u20 = raw_without_opcode >> 5;
        const funct3: u3 = funct3_bytes & 0b111;
        const rs1: u17 = funct3_bytes >> 3;
        const rs2: u12 = rs1 >> 5;
        const imm11_5: u12 = rs2 & 0b1111_1110_0000;
        return .{
            .{
                .imm = @intCast(imm11_5 | imm4_0),
                .rs2 = @intCast(rs2 & 0b1_1111),
                .rs1 = @intCast(rs1 & 0b1_1111),
            },
            funct3,
        };
    }
};

pub const BType = struct {
    imm: u12,
    rs2: u5,
    rs1: u5,

    pub fn decode(raw_without_opcode: u25) .{ BType, u3 } {
        const imm11: u11 = (raw_without_opcode & 0b1) << 10;
        const imm4_1_bytes: u24 = raw_without_opcode >> 1;
        const imm4_1: u4 = imm4_1_bytes & 0b1111;
        const funct3: u20 = imm4_1_bytes >> 4;
        const rs1: u17 = funct3 >> 3;
        const rs2: u12 = rs1 >> 5;
        const imm_bytes: u11 = rs2 >> 1;
        const imm10_5: u10 = imm_bytes & 0b11_1111_0000;
        const imm12: u12 = (imm_bytes & 0b100_0000_0000) << 1;
        return .{
            .{
                .imm = @intCast(imm12 | imm11 | imm10_5 | imm4_1),
                .rs2 = @intCast(rs2 & 0b1_1111),
                .rs1 = @intCast(rs1 & 0b1_1111),
            },
            (funct3 & 0b111),
        };
    }
};

pub const UType = struct {
    imm: u20,
    rd: u5,

    pub fn decode(raw_without_opcode: u25) UType {
        return .{
            .imm = @intCast(raw_without_opcode >> 5),
            .rd = @intCast(raw_without_opcode & 0b1_1111),
        };
    }
};

pub const JType = struct {
    imm: u20,
    rd: u5,

    pub fn decode(raw_without_opcode: u25) RType {
        const imm19_12: u19 = (raw_without_opcode & 0b1_1111_1110_0000) << 6;
        const imm11: u11 = (raw_without_opcode & 0b1_0000_0000_0000) >> 2;
        const imm_bytes21_31: u11 = raw_without_opcode >> 14;
        const imm10_1: u10 = imm_bytes21_31 & 0b11_1111_1111;
        const imm20 = (imm_bytes21_31 & 0b100_0000_0000) << 9;
        return .{
            .imm = @intCast(imm20 | imm19_12 | imm11 | imm10_1),
            .rd = @intCast(raw_without_opcode & 0b1_1111),
        };
    }
};
