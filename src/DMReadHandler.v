`include "src/include/InstSpec.v"

module DMReadHandler(
    input [`MEMRDWIDTH_BUS] memory_read_width,
    input [1:0] block_address,
    input [31:0] data_mem_in,
    output reg [31:0] read_result
);

always @(*) begin
    read_result <= 32'b0;
    case (memory_read_width)
        `MEMRDWIDTH_WORD: begin
            read_result <= data_mem_in;
        end
        `MEMRDWIDTH_HWORD: begin
            if (block_address == 2'b00) begin
                read_result <= {{16{data_mem_in[15]}}, data_mem_in[15:0]};
            end else if (block_address == 2'b01) begin
                read_result <= {{16{data_mem_in[23]}}, data_mem_in[23:8]};
            end else if (block_address == 2'b10) begin
                read_result <= {{16{data_mem_in[31]}}, data_mem_in[31:16]};
            end
        end
        `MEMRDWIDTH_UHWORD: begin
            if (block_address == 2'b00) begin
                read_result <= {16'b0, data_mem_in[15:0]};
            end else if (block_address == 2'b01) begin
                read_result <= {16'b0, data_mem_in[23:8]};
            end else if (block_address == 2'b10) begin
                read_result <= {16'b0, data_mem_in[31:16]};
            end
        end
        `MEMRDWIDTH_BYTE: begin
            if (block_address == 2'b00) begin
                read_result <= {{24{data_mem_in[7]}}, data_mem_in[7:0]};
            end else if (block_address == 2'b01) begin
                read_result <= {{24{data_mem_in[15]}}, data_mem_in[15:8]};
            end else if (block_address == 2'b10) begin
                read_result <= {{24{data_mem_in[23]}}, data_mem_in[23:16]};
            end else if (block_address == 2'b11) begin
                read_result <= {{24{data_mem_in[31]}}, data_mem_in[31:24]};
            end
        end
        `MEMRDWIDTH_UBYTE: begin
            if (block_address == 2'b00) begin
                read_result <= {24'b0, data_mem_in[7:0]};
            end else if (block_address == 2'b01) begin
                read_result <= {24'b0, data_mem_in[15:8]};
            end else if (block_address == 2'b10) begin
                read_result <= {24'b0, data_mem_in[23:16]};
            end else if (block_address == 2'b11) begin
                read_result <= {24'b0, data_mem_in[31:24]};
            end
        end
    endcase
end

endmodule
