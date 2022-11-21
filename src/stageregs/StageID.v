module StageID(
    input clk, rst,
    input flush, lock,
    // ========== Other ==========
    input [31:0] inst_in,
    input [31:0] pc_in,
    output reg [31:0] inst_out,
    output reg [31:0] pc_out
);

always @(posedge clk, posedge rst) begin
    if (rst || flush) begin
        inst_out <= 32'b0;
        pc_out <= 32'b0;
    end else if (lock == 1'b0) begin
        inst_out <= inst_in;
        pc_out <= pc_in;
    end
end

endmodule
