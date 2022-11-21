`ifndef INST_SPEC_HEADER
`define INST_SPEC_HEADER

`define IS_SIMULATION

// ALU operand
`define ALUOP_BUS 3:0
`define ALUOP_ADD 4'b0000
`define ALUOP_SUB 4'b0001
`define ALUOP_AND 4'b0010
`define ALUOP_OR  4'b0011
`define ALUOP_XOR 4'b0100
`define ALUOP_SHL 4'b0101
`define ALUOP_SHR 4'b0110
`define ALUOP_SAR 4'b0111
`define ALUOP_LT  4'b1000
`define ALUOP_LTU 4'b1001
`define ALUOP_UNUSED 4'b0000

// Branch behavior
`define BRANCH_BUS 2:0
`define BRANCH_PC4 3'b000
`define BRANCH_PCIMM 3'b001
`define BRANCH_ALU 3'b010
`define BRANCH_PCIMM_IF_ZERO 3'b011
`define BRANCH_PCIMM_IF_NOT_ZERO 3'b100

// ALU source 1
`define ALUREGSRC_BUS 0:0
`define ALUREGSRC_RS1 1'b0
`define ALUREGSRC_PC  1'b1
`define ALUREGSRC_UNUSED 1'b0

// ALU source 2
`define ALUIMMSRC_BUS 0:0
`define ALUIMMSRC_RS2 1'b0
`define ALUIMMSRC_IMM 1'b1
`define ALUIMMSRC_UNUSED 1'b0

// RegFile source
`define REGWRSRC_BUS 1:0
`define REGWRSRC_ALU 2'b00
`define REGWRSRC_MEM 2'b01
`define REGWRSRC_IMM 2'b10
`define REGWRSRC_PC4 2'b11
`define REGWRSRC_UNUSED 2'b00

// MemRead width
`define MEMRDWIDTH_BUS    2:0
`define MEMRDWIDTH_WORD   3'b010
`define MEMRDWIDTH_HWORD  3'b001
`define MEMRDWIDTH_UHWORD 3'b101
`define MEMRDWIDTH_BYTE   3'b000
`define MEMRDWIDTH_UBYTE  3'b100
`define MEMRDWIDTH_UNUSED 3'b010

// MemWrite width
`define MEMWRWIDTH_BUS   1:0
`define MEMWRWIDTH_WORD  2'b10
`define MEMWRWIDTH_HWORD 2'b01
`define MEMWRWIDTH_BYTE  2'b00
`define MEMWRWIDTH_UNUSED 2'b10

`endif