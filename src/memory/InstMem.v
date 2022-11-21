module InstMem(
    input [31:0] addr,
    output reg [31:0] dout
);

reg [31:0] memory[255:0];
integer i;

wire [31:2] addr_memory_unit = addr[31:2];
wire [1:0] addr_memory_cell = addr[1:0];

initial begin
    for (i = 0; i <= 255; i = i + 1) begin
        memory[i] = 32'b0;
    end
end

always @(addr_memory_unit, addr_memory_cell, memory[addr_memory_unit]) begin
    case (addr_memory_cell)
        2'b00: dout[31:0] <= memory[addr_memory_unit][31:0];
        2'b01: begin
            dout[23:0] <= memory[addr_memory_unit][31:8];
            dout[31:24] <= memory[addr_memory_unit + 1][7:0];
        end
        2'b10: begin
            dout[15:0] <= memory[addr_memory_unit][31:16];
            dout[31:16] <= memory[addr_memory_unit + 1][15:0];
        end
        2'b11: begin
            dout[7:0] <= memory[addr_memory_unit][31:24];
            dout[31:8] <= memory[addr_memory_unit + 1][23:0];
        end
    endcase
end

endmodule
