`include "src/include/InstSpec.v"

module RegFile(
    input clk, rst,
    input [4:0] rs1, rs2, rd,
    input write_en,
    input [31:0] write_data,
    output [31:0] rs1_data, rs2_data,
    output [31:0] x25
);

reg [31:0] registers[31:0];
integer i;

assign rs1_data = write_en == 1'b1 && rd != 0 && rs1 == rd ? write_data : registers[rs1];
assign rs2_data = write_en == 1'b1 && rd != 0 && rs2 == rd ? write_data : registers[rs2];

assign x25 = registers[25];

always @(posedge clk, posedge rst) begin
    if (rst) begin
        for (i = 0; i <= 31; i = i + 1) begin
            registers[i] <= 32'b0;
        end
    end else begin
        if (write_en == 1'b1 && rd != 5'b0) begin
            registers[rd] <= write_data;
            `ifdef IS_SIMULATION
            $fdisplay(sccomp_tb.foutput, "write to Reg addr %d with data %h", rd, write_data);
            `endif
        end
    end
end

endmodule
