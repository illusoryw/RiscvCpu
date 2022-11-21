`include "src/include/InstSpec.v"

module CtrlMEMRegs(
    input clk, rst,
    input flush, lock,
    input sig_memread_in,
    input sig_memwrite_in,
    input [`MEMRDWIDTH_BUS] sig_memrdwidth_in,
    input [`MEMWRWIDTH_BUS] sig_memwrwidth_in,
    input [`BRANCH_BUS] sig_branch_in,
    output reg sig_memread_out,
    output reg sig_memwrite_out,
    output reg [`MEMRDWIDTH_BUS] sig_memrdwidth_out,
    output reg [`MEMWRWIDTH_BUS] sig_memwrwidth_out,
    output reg [`BRANCH_BUS] sig_branch_out
);

always @(posedge clk, posedge rst) begin
    if (rst || flush) begin
        sig_memread_out <= 1'b0;
        sig_memwrite_out <= 1'b0;
        sig_memrdwidth_out <= `MEMRDWIDTH_UNUSED;
        sig_memwrwidth_out <= `MEMWRWIDTH_UNUSED;
        sig_branch_out <= `BRANCH_PC4;
    end else if (lock == 1'b0) begin
        sig_memread_out <= sig_memread_in;
        sig_memwrite_out <= sig_memwrite_in;
        sig_memrdwidth_out <= sig_memrdwidth_in;
        sig_memwrwidth_out <= sig_memwrwidth_in;
        sig_branch_out <= sig_branch_in;
    end
end

endmodule
