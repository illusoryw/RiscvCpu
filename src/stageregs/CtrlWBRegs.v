`include "src/include/InstSpec.v"

module CtrlWBRegs(
    input clk, rst,
    input flush, lock,
    input sig_regwrite_in,
    input [`REGWRSRC_BUS] sig_regwrsrc_in,
    output reg sig_regwrite_out,
    output reg [`REGWRSRC_BUS] sig_regwrsrc_out
);

always @(posedge clk, posedge rst) begin
    if (rst || flush) begin
        sig_regwrite_out <= 1'b0;
        sig_regwrsrc_out <= `REGWRSRC_UNUSED;
    end else if (lock == 1'b0) begin
        sig_regwrite_out <= sig_regwrite_in;
        sig_regwrsrc_out <= sig_regwrsrc_in;
    end
end

endmodule
