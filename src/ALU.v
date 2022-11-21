`include "src/include/InstSpec.v"

module ALU(
    input [`ALUOP_BUS] sig_aluop,
    input [31:0] op1, op2,
    output reg [31:0] opout,
    output zero
);

assign zero = (opout == 32'b0);

always @(*) begin    
    case(sig_aluop)
        `ALUOP_ADD: opout <= op1 + op2;
        `ALUOP_SUB: opout <= op1 - op2;
        `ALUOP_AND: opout <= op1 & op2;
        `ALUOP_OR : opout <= op1 | op2;
        `ALUOP_XOR: opout <= op1 ^ op2;
        `ALUOP_SHL: opout <= op1 << op2;
        `ALUOP_SHR: opout <= $signed(op1) >> op2;
        `ALUOP_SAR: opout <= $signed(op1) >>> op2;
        `ALUOP_LT : opout <= ($signed(op1) < $signed(op2) ? 32'b1 : 32'b0);
        `ALUOP_LTU: opout <= (op1 < op2 ? 32'b1 : 32'b0);
        default: opout <= 0;
    endcase
end

endmodule
