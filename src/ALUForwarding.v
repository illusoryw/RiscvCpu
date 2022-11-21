`include "src/include/InstSpec.v"

module ALUForwarding(
    input [31:0] ex_rs1_data, ex_rs2_data,
    output reg [31:0] rs1_data, rs2_data,
    output reg stall,
    // ========== EX ==========
    input [4:0] ex_rs1, ex_rs2,
    // ========== MEM ==========
    input [4:0] mem_rd,
    input mem_sig_regwrite,
    input [`REGWRSRC_BUS] mem_sig_regwrsrc,
    input [31:0] mem_aluresult,
    input [31:0] mem_imm,
    input [31:0] mem_pc,
    // ========== WB ==========
    input [4:0] wb_rd,
    input wb_sig_regwrite,
    input [31:0] wb_rd_data
);

always @(*) begin
    rs1_data <= ex_rs1_data;
    rs2_data <= ex_rs2_data;
    stall <= 1'b0;
    
    if (mem_sig_regwrite == 1'b1 && mem_rd != 5'b0 && mem_rd == ex_rs1) begin
        case (mem_sig_regwrsrc)
            `REGWRSRC_ALU: rs1_data <= mem_aluresult;
            `REGWRSRC_MEM: stall <= 1'b1;
            `REGWRSRC_IMM: rs1_data <= mem_imm;
            `REGWRSRC_PC4: rs1_data <= mem_pc + 4;
        endcase
    end else if (wb_sig_regwrite == 1'b1 && wb_rd != 5'b0 && wb_rd == ex_rs1) begin
        rs1_data <= wb_rd_data;
    end

    if (mem_sig_regwrite == 1'b1 && mem_rd != 5'b0 && mem_rd == ex_rs2) begin
        case (mem_sig_regwrsrc)
            `REGWRSRC_ALU: rs2_data <= mem_aluresult;
            `REGWRSRC_MEM: stall <= 1'b1;
            `REGWRSRC_IMM: rs2_data <= mem_imm;
            `REGWRSRC_PC4: rs2_data <= mem_pc + 4;
        endcase
    end else if (wb_sig_regwrite == 1'b1 && wb_rd != 5'b0 && wb_rd == ex_rs2) begin
        rs2_data <= wb_rd_data;
    end
end

endmodule
