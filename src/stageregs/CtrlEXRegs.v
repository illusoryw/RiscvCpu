`include "src/include/InstSpec.v"

module CtrlEXRegs(
    input clk, rst,
    input flush, lock,
    input [`ALUREGSRC_BUS] sig_aluregsrc_in,
    input [`ALUIMMSRC_BUS] sig_aluimmsrc_in,
    input [`ALUOP_BUS] sig_aluop_in,
    output reg [`ALUREGSRC_BUS] sig_aluregsrc_out,
    output reg [`ALUIMMSRC_BUS] sig_aluimmsrc_out,
    output reg [`ALUOP_BUS] sig_aluop_out
);

always @(posedge clk, posedge rst) begin
    if (rst || flush) begin
        sig_aluregsrc_out <= `ALUREGSRC_UNUSED;
        sig_aluimmsrc_out <= `ALUIMMSRC_UNUSED;
        sig_aluop_out <= `ALUOP_UNUSED;
    end else if (lock == 1'b0) begin
        sig_aluregsrc_out <= sig_aluregsrc_in;
        sig_aluimmsrc_out <= sig_aluimmsrc_in;
        sig_aluop_out <= sig_aluop_in;
    end
end

endmodule
