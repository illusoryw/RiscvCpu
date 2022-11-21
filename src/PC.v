`include "src/include/InstSpec.v"

module PC(
    input clk,
    input rst,
    input int,
    input [31:0] new_pc,
    output reg [31:0] pc
);

always @(posedge clk, posedge rst) begin
    if (rst) begin
        `ifdef IS_SIMULATION
        $fdisplay(sccomp_tb.foutput, "PC <= %h", 32'h0000_0000);
        `endif
        pc <= 32'h0000_0000;
    end else if (int) begin
        `ifdef IS_SIMULATION
        $fdisplay(sccomp_tb.foutput, "PC <= %h", 32'h1C09_0000);
        `endif
        pc <= 32'h1C09_0000;
    end else begin
        `ifdef IS_SIMULATION
        $fdisplay(sccomp_tb.foutput, "PC <= %h", new_pc);
        `endif
        pc <= new_pc;
    end
end

endmodule
