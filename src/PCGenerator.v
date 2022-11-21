`include "src/include/InstSpec.v"

module PCGenerator(
    input [31:0] pc,
    input [31:0] branch_pc,
    input [31:0] aluresult,
    input [31:0] imm,
    input zero,
    input [`BRANCH_BUS] sig_branch,
    input stall,
    output reg [31:0] new_pc,
    output reg flush_needed
);

always @(*) begin
    case (sig_branch)
        `BRANCH_PC4: begin
            if (stall == 1'b0) new_pc <= pc + 4;
            else new_pc <= pc;
            flush_needed <= 1'b0;
        end
        `BRANCH_PCIMM: begin
            new_pc <= branch_pc + imm;
            flush_needed <= 1'b1;
        end
        `BRANCH_ALU: begin
            new_pc <= aluresult;
            flush_needed <= 1'b1;
        end
        `BRANCH_PCIMM_IF_ZERO: begin
            if (zero == 1'b1) begin
                new_pc <= branch_pc + imm;
                flush_needed <= 1'b1;
            end else begin
                if (stall == 1'b0) new_pc <= pc + 4;
                else new_pc <= pc;
                flush_needed <= 1'b0;
            end
        end
        `BRANCH_PCIMM_IF_NOT_ZERO: begin
            if (zero != 1'b1) begin
                new_pc <= branch_pc + imm;
                flush_needed <= 1'b1;
            end else begin
                if (stall == 1'b0) new_pc <= pc + 4;
                else new_pc <= pc;
                flush_needed <= 1'b0;
            end
        end
        default: begin
            if (stall == 1'b0) new_pc <= pc + 4;
            else new_pc <= pc;
            flush_needed <= 1'b0;
        end
    endcase
end

endmodule
