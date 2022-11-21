`include "src/include/InstSpec.v"

module StageEX(
    input clk, rst,
    input flush, lock,
    // ========== CtrlEX ==========
    input [`ALUREGSRC_BUS] sig_aluregsrc_in,
    input [`ALUIMMSRC_BUS] sig_aluimmsrc_in,
    input [`ALUOP_BUS] sig_aluop_in,
    output [`ALUREGSRC_BUS] sig_aluregsrc_out,
    output [`ALUIMMSRC_BUS] sig_aluimmsrc_out,
    output [`ALUOP_BUS] sig_aluop_out,
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
    input [31:0] rs1_data_in,
    input [31:0] rs2_data_in,
    input [31:0] pc_in,
    input [31:0] imm_in,
    input [4:0] rs1_in, rs2_in,
    input [4:0] rd_in,
    output reg [31:0] rs1_data_out,
    output reg [31:0] rs2_data_out,
    output reg [31:0] pc_out,
    output reg [31:0] imm_out,
    output reg [4:0] rs1_out, rs2_out,
    output reg [4:0] rd_out
);

CtrlEXRegs u_CtrlEXRegs(
    .clk               (clk               ),
    .rst               (rst               ),
    .flush             (flush             ),
    .lock              (lock              ),
    .sig_aluregsrc_in  (sig_aluregsrc_in  ),
    .sig_aluimmsrc_in  (sig_aluimmsrc_in  ),
    .sig_aluop_in      (sig_aluop_in      ),
    .sig_aluregsrc_out (sig_aluregsrc_out ),
    .sig_aluimmsrc_out (sig_aluimmsrc_out ),
    .sig_aluop_out     (sig_aluop_out     )
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
        rs1_data_out <= 32'b0;
        rs2_data_out <= 32'b0;
        pc_out <= 32'b0;
        imm_out <= 32'b0;
        rs1_out <= 5'b0;
        rs2_out <= 5'b0;
        rd_out <= 5'b0;
    end else if (lock == 1'b0) begin
        rs1_data_out <= rs1_data_in;
        rs2_data_out <= rs2_data_in;
        pc_out <= pc_in;
        imm_out <= imm_in;
        rs1_out <= rs1_in;
        rs2_out <= rs2_in;
        rd_out <= rd_in;
    end
end

endmodule
