`include "src/include/InstSpec.v"

module RegFileWriteDataSelector(
    input [`REGWRSRC_BUS] sig_regwrsrc,
    input [31:0] aluresult,
    input [31:0] data_mem_in,
    input [31:0] imm,
    input [31:0] pc,
    output reg [31:0] rd_data
);

always @(*) begin
    case (sig_regwrsrc)
        `REGWRSRC_ALU: rd_data <= aluresult;
        `REGWRSRC_MEM: rd_data <= data_mem_in;
        `REGWRSRC_IMM: rd_data <= imm;
        `REGWRSRC_PC4: rd_data <= pc + 4;
        default: rd_data <= 32'b0;
    endcase
end

endmodule
