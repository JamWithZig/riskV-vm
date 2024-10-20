const std = @import("std");
const testing = std.testing;

pub const RType = struct {
    rs2: u5,
    rs1: u5,
    rd: u5,

    pub fn decode(raw: u32) struct { rtype: RType, funct3: u3, funct7: u7 } {
        return .{
            .rtype = .{
                .rs2 = @truncate((raw >> 20) & 0b1_1111),
                .rs1 = @truncate((raw >> 15) & 0b1_1111),
                .rd = @truncate((raw >> 7) & 0b1_1111),
            },
            .funct3 = @truncate((raw >> 12) & 0b111),
            .funct7 = @truncate((raw >> 25) & 0b111_1111),
        };
    }
};

pub const IType = struct {
    imm: u12,
    rs1: u5,
    rd: u5,

    pub fn decode(raw: u32) struct { itype: IType, funct3: u3 } {
        return .{
            .itype = .{
                .imm = @truncate(raw >> 20),
                .rs1 = @truncate((raw >> 15) & 0b1_1111),
                .rd = @truncate((raw >> 7) & 0b1_1111),
            },
            .funct3 = @truncate((raw >> 12) & 0b111),
        };
    }
};

pub const SType = struct {
    imm: u12,
    rs2: u5,
    rs1: u5,

    pub fn decode(raw: u32) struct { stype: SType, funct3: u3 } {
        const imm4_0 = (raw >> 7) & 0b1_1111;
        const imm11_5 = (raw >> 25) & 0b1111_1110_0000;
        return .{
            .stype = .{
                .imm = @truncate(imm11_5 | imm4_0),
                .rs2 = @truncate((raw >> 20) & 0b1_1111),
                .rs1 = @truncate((raw >> 15) & 0b1_1111),
            },
            .funct3 = @truncate((raw >> 12) & 0b111),
        };
    }
};

pub const BType = struct {
    imm: u12,
    rs2: u5,
    rs1: u5,

    pub fn decode(raw: u32) struct { btype: BType, funct3: u3 } {
        const imm11 = ((raw >> 7) & 0b1) << 10;
        const imm4_1 = (raw >> 8) & 0b1111;
        const imm10_5 = (raw >> 25) & 0b11_1111_0000;
        const imm12 = raw >> 30;
        return .{
            .btype = .{
                .imm = @truncate(imm12 | imm11 | imm10_5 | imm4_1),
                .rs2 = @truncate((raw >> 20) & 0b1_1111),
                .rs1 = @truncate((raw >> 15) & 0b1_1111),
            },
            .funct3 = ((raw >> 12) & 0b111),
        };
    }
};

pub const UType = struct {
    imm: u20,
    rd: u5,

    pub fn decode(raw: u32) UType {
        return .{
            .imm = @truncate(raw >> 12),
            .rd = @truncate((raw >> 7) & 0b1_1111),
        };
    }
};

pub const JType = struct {
    imm: u20,
    rd: u5,

    pub fn decode(raw: u32) RType {
        const imm19_12 = ((raw >> 12) & 0b1111_1111) << 11;
        const imm11 = ((raw >> 20) & 0b1) >> 10;
        const imm10_1 = (raw >> 21) & 0b11_1111_1111;
        const imm20 = (raw >> 31) << 19;
        return .{
            .imm = @truncate(imm20 | imm19_12 | imm11 | imm10_1),
            .rd = @truncate((raw >> 7) & 0b1_1111),
        };
    }
};

test "test R-Type" {
    const actual = RType.decode(0b0000_0001_0110_0010_0000_1001_1011_0011);
    try testing.expectEqual(0b1_0110, actual.rtype.rs2);
    try testing.expectEqual(0b0_0100, actual.rtype.rs1);
    try testing.expectEqual(0b1_0011, actual.rtype.rd);
    try testing.expectEqual(0b000, actual.funct3);
    try testing.expectEqual(0b000_0000, actual.funct7);
}

test "test I-Type" {
    const actual = IType.decode(0b0000_0001_0110_0010_0000_1001_1011_0011);
    try testing.expectEqual(0b1_0011, actual.itype.imm);
    try testing.expectEqual(0b0_0100, actual.itype.rs1);
    try testing.expectEqual(0b000, actual.funct3);
    try testing.expectEqual(0b1_0110, actual.itype.rd);
}

test "test S-Type" {
    const actual = SType.decode(0b0000_0001_0110_0010_0000_1001_1011_0011);
    try testing.expectEqual(0b1_0011, actual.stype.imm);
    try testing.expectEqual(0b1_0110, actual.stype.rs2);
    try testing.expectEqual(0b0_0100, actual.stype.rs1);
    try testing.expectEqual(0b000, actual.funct3);
}

test "test B-Type" {
    const actual = BType.decode(0b0000_0001_0110_0010_0000_1001_1011_0011);
    try testing.expectEqual(0b1_0011, actual.btype.imm);
    try testing.expectEqual(0b1_0110, actual.btype.rs2);
    try testing.expectEqual(0b0_0100, actual.btype.rs1);
    try testing.expectEqual(0b000, actual.funct3);
}
