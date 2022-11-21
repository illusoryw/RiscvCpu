`include "src/include/InstSpec.v"

module StageMEM(
    input clk, rst,
    input flush, lock,
    // ========== CtrlMEM ==========
    input sig_memread_in,
    input sig_memwrite_in,
    input [`MEMRDWIDTH_BUS] sig_memrdwidth_in,
    input [`MEMWRWIDTH_BUS] sig_memwrwidth_in,
    input [`BRANCH_BUS] sig_branch_in,
    output sig_memread_out,
    output sig_memwrite_out,
    output [`MEMRDWIDTH_BUS] sig_memrdwidth_out,
    output [`MEMWRWIDTH_BUS] sig_memwrwidth_out,
    output [`BRANCH_BUS] sig_branch_out,
    // ========== CtrlWB ==========
    input sig_regwrite_in,
    input [`REGWRSRC_BUS] sig_regwrsrc_in,
    output sig_regwrite_out,
    output [`REGWRSRC_BUS] sig_regwrsrc_out,
    // ========== Other ==========
    input [31:0] rs2_data_in,
    input [31:0] pc_in,
    input [31:0] aluresult_in,
    input aluzero_in,
    input [4:0] rd_in,
    input [31:0] imm_in,
    output reg [31:0] rs2_data_out,
    output reg [31:0] pc_out,
    output reg [31:0] aluresult_out,
    output reg aluzero_out,
    output reg [4:0] rd_out,
    output reg [31:0] imm_out
);

CtrlMEMRegs u_CtrlMEMRegs(
    .clk                (clk                ),
    .rst                (rst                ),
    .flush              (flush              ),
    .lock               (lock               ),
    .sig_memread_in     (sig_memread_in     ),
    .sig_memwrite_in    (sig_memwrite_in    ),
    .sig_memrdwidth_in  (sig_memrdwidth_in  ),
    .sig_memwrwidth_in  (sig_memwrwidth_in  ),
    .sig_branch_in      (sig_branch_in      ),
    .sig_memread_out    (sig_memread_out    ),
    .sig_memwrite_out   (sig_memwrite_out   ),
    .sig_memrdwidth_out (sig_memrdwidth_out ),
    .sig_memwrwidth_out (sig_memwrwidth_out ),
    .sig_branch_out     (sig_branch_out     )
);

CtrlWBRegs u_CtrlWBRegs(
    .clk                (clk                ),
    .rst                (rst                ),
    .flush              (flush              ),
    .lock               (lock               ),
    .sig_regwrite_in    (sig_regwrite_in    ),
    .sig_regwrsrc_in    (sig_regwrsrc_in    ),
    .sig_regwrite_out   (sig_regwrite_out   ),
    .sig_regwrsrc_out   (sig_regwrsrc_out   )
);

always @(posedge clk, posedge rst) begin
    if (rst || flush) begin
        rs2_data_out <= 32'b0;
        pc_out <= 32'b0;
        aluresult_out <= 32'b0;
        aluzero_out <= 1'b0;
        rd_out <= 5'b0;
        imm_out <= 32'b0;
    end else if (lock == 1'b0) begin
        rs2_data_out <= rs2_data_in;
        pc_out <= pc_in;
        aluresult_out <= aluresult_in;
        aluzero_out <= aluzero_in;
        rd_out <= rd_in;
        imm_out <= imm_in;
    end
end

endmodule
