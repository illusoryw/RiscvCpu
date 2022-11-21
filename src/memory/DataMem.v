`include "src/include/InstSpec.v"

module DataMem(
    input clk, write_en,
    input [31:0] addr,
    input [31:0] din,
    output [31:0] dout,
    input [`MEMWRWIDTH_BUS] write_width
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

assign dout = memory[addr_memory_unit];

always @(posedge clk) begin
    if (write_en) begin
        case (write_width)
            `MEMWRWIDTH_WORD: begin
                case (addr_memory_cell)
                    2'b00: memory[addr_memory_unit][31:0] <= din[31:0];
                    2'b01: begin
                        memory[addr_memory_unit][31:8] <= din[23:0];
                        memory[addr_memory_unit + 1][7:0] <= din[31:24];
                    end
                    2'b10: begin
                        memory[addr_memory_unit][31:16] <= din[15:0];
                        memory[addr_memory_unit + 1][15:0] <= din[31:16];
                    end
                    2'b11: begin
                        memory[addr_memory_unit][31:24] <= din[7:0];
                        memory[addr_memory_unit + 1][23:0] <= din[31:8];
                    end
                endcase
                `ifdef IS_SIMULATION
                $fdisplay(sccomp_tb.foutput, "write to DataMem addr %h with data %h", addr, din[31:0]);
                `endif
            end
            `MEMWRWIDTH_HWORD: begin
                case (addr_memory_cell)
                    2'b00: memory[addr_memory_unit][15:0] <= din[15:0];
                    2'b01: memory[addr_memory_unit][23:8] <= din[15:0];
                    2'b10: memory[addr_memory_unit][31:16] <= din[15:0];
                    2'b11: begin
                        memory[addr_memory_unit][31:24] <= din[7:0];
                        memory[addr_memory_unit][7:0] <= din[15:8];
                    end
                endcase
                `ifdef IS_SIMULATION
                $fdisplay(sccomp_tb.foutput, "write to DataMem addr %h with data %h", addr, din[15:0]);
                `endif
            end
            `MEMWRWIDTH_BYTE: begin
                case (addr_memory_cell)
                    2'b00: memory[addr_memory_unit][7:0] <= din[7:0];
                    2'b01: memory[addr_memory_unit][15:8] <= din[7:0];
                    2'b10: memory[addr_memory_unit][23:16] <= din[7:0];
                    2'b11: memory[addr_memory_unit][31:24] <= din[7:0];
                endcase
                `ifdef IS_SIMULATION
                $fdisplay(sccomp_tb.foutput, "write to DataMem addr %h with data %h", addr, din[7:0]);
                `endif
            end
        endcase
    end
end

endmodule
