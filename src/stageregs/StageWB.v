`include "src/include/InstSpec.v"

module StageWB(
    input clk, rst,
    input flush, lock,
    // ========== CtrlWB ==========
    input sig_regwrite_in,
    input [`REGWRSRC_BUS] sig_regwrsrc_in,
    output sig_regwrite_out,
    output [`REGWRSRC_BUS] sig_regwrsrc_out,
    // ========== Other ==========
    input [31:0] pc_in,
    input [4:0] rd_in,
    input [31:0] aluresult_in,
    input [31:0] imm_in,
    input [31:0] mem_read_data_in,
    output reg [31:0] pc_out,
    output reg [4:0] rd_out,
    output reg [31:0] aluresult_out,
    output reg [31:0] imm_out,
    output reg [31:0] mem_read_data_out
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
        pc_out <= 32'b0;
        rd_out <= 5'b0;
        aluresult_out <= 32'b0;
        imm_out <= 32'b0;
        mem_read_data_out <= 32'b0;
    end else if (lock == 1'b0) begin
        pc_out <= pc_in;
        rd_out <= rd_in;
        aluresult_out <= aluresult_in;
        imm_out <= imm_in;
        mem_read_data_out <= mem_read_data_in;
    end
end

endmodule
