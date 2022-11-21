`include "src/include/InstSpec.v"

module ALUOperandSelector(
    input [`ALUREGSRC_BUS] sig_aluregsrc,
    input [`ALUIMMSRC_BUS] sig_aluimmsrc,
    input [31:0] rs1_data,
    input [31:0] rs2_data,
    input [31:0] imm,
    input [31:0] pc,
    output [31:0] op1,
    output [31:0] op2
);

assign op1 = sig_aluregsrc == `ALUREGSRC_RS1 ? rs1_data : pc;
assign op2 = sig_aluimmsrc == `ALUIMMSRC_RS2 ? rs2_data : imm;

endmodule
