`include "src/include/InstSpec.v"

module InstResolver(
    input [31:0] inst,
    output reg [4:0] rs1, rs2, rd,
    output reg [31:0] imm,
    output reg [`ALUREGSRC_BUS] sig_aluregsrc,
    output reg [`ALUIMMSRC_BUS] sig_aluimmsrc,
    output reg sig_memread,
    output reg sig_memwrite,
    output reg [`MEMRDWIDTH_BUS] sig_memrdwidth,
    output reg [`MEMWRWIDTH_BUS] sig_memwrwidth,
    output reg sig_regwrite,
    output reg [`REGWRSRC_BUS] sig_regwrsrc,
    output reg [`ALUOP_BUS] sig_aluop,
    output reg [`BRANCH_BUS] sig_branch
);

wire [6:0] opcode = inst[6:0];
wire [4:0] rs1_holding = inst[19:15];  // R-type, I-type, S-type, SB-type 
wire [4:0] rs2_holding = inst[24:20];  // R-type, S-type, SB-type
wire [4:0] rd_holding = inst[11:7];  // R-type, I-type, U-type, J-type
wire [2:0] funct3 = inst[14:12];  // R-type, I-type, S-type, SB-type
wire funct7_b30 = inst[30];  // R-type
wire [11:0] I_imm12 = inst[31:20];  // I-type
wire [4:0] I_shamt5 = inst[24:20];  // I-type: slli, srli, srai
wire [11:0] S_imm12 = {inst[31:25], inst[11:7]};  // S-type
wire [12:0] SB_imm13 = {inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};  // SB-type
wire [31:0] U_imm32 = {inst[31:12], 12'b0};  // U-type
wire [20:0] UJ_imm21 = {inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};  // UJ-type

always @(*) begin
    case (opcode)
        7'b0110011: begin
            // R-type: add, sub, and, or, xor, sll, srl, sra, slt, sltu
            rs1 <= rs1_holding;
            rs2 <= rs2_holding;
            rd <= rd_holding;

            sig_aluregsrc <= `ALUREGSRC_RS1;
            sig_aluimmsrc <= `ALUIMMSRC_RS2;
            sig_memread <= 1'b0;
            sig_memwrite <= 1'b0;
            sig_memrdwidth <= `MEMRDWIDTH_WORD;
            sig_memwrwidth <= `MEMWRWIDTH_UNUSED;
            sig_regwrite <= 1'b1;
            sig_regwrsrc <= `REGWRSRC_ALU;
            /* add */ if (funct3 == 3'b000 && funct7_b30 == 1'b0) sig_aluop <= `ALUOP_ADD;
            /* sub */ else if (funct3 == 3'b000 && funct7_b30 == 1'b1) sig_aluop <= `ALUOP_SUB;
            /* and */ else if (funct3 == 3'b111 && funct7_b30 == 1'b0) sig_aluop <= `ALUOP_AND;
            /* or  */ else if (funct3 == 3'b110 && funct7_b30 == 1'b0) sig_aluop <= `ALUOP_OR;
            /* xor */ else if (funct3 == 3'b100 && funct7_b30 == 1'b0) sig_aluop <= `ALUOP_XOR;
            /* sll */ else if (funct3 == 3'b001 && funct7_b30 == 1'b0) sig_aluop <= `ALUOP_SHL;
            /* srl */ else if (funct3 == 3'b101 && funct7_b30 == 1'b0) sig_aluop <= `ALUOP_SHR;
            /* sra */ else if (funct3 == 3'b101 && funct7_b30 == 1'b1) sig_aluop <= `ALUOP_SAR;
            /* slt */ else if (funct3 == 3'b010 && funct7_b30 == 1'b0) sig_aluop <= `ALUOP_LT;
            /* sltu*/ else if (funct3 == 3'b011 && funct7_b30 == 1'b0) sig_aluop <= `ALUOP_LTU;
                      else sig_aluop <= `ALUOP_UNUSED;
            sig_branch <= `BRANCH_PC4;

            // ImmGen
            imm <= 32'b0;
        end

        7'b0010011: begin
            // I-type: addi, andi, ori, xori, slli, srli, srai, slti, sltiu
            rs1 <= rs1_holding;
            rs2 <= 5'b0;
            rd <= rd_holding;

            sig_aluregsrc <= `ALUREGSRC_RS1;
            sig_aluimmsrc <= `ALUIMMSRC_IMM;
            sig_memread <= 1'b0;
            sig_memwrite <= 1'b0;
            sig_memrdwidth <= `MEMRDWIDTH_WORD;
            sig_memwrwidth <= `MEMWRWIDTH_UNUSED;
            sig_regwrite <= 1'b1;
            sig_regwrsrc <= `REGWRSRC_ALU;
            /* addi */ if (funct3 == 3'b000) sig_aluop <= `ALUOP_ADD;
            /* andi */ else if (funct3 == 3'b111) sig_aluop <= `ALUOP_AND;
            /* ori  */ else if (funct3 == 3'b110) sig_aluop <= `ALUOP_OR;
            /* xori */ else if (funct3 == 3'b100) sig_aluop <= `ALUOP_XOR;
            /* slli */ else if (funct3 == 3'b001 && funct7_b30 == 1'b0) sig_aluop <= `ALUOP_SHL;
            /* srli */ else if (funct3 == 3'b101 && funct7_b30 == 1'b0) sig_aluop <= `ALUOP_SHR;
            /* srai */ else if (funct3 == 3'b101 && funct7_b30 == 1'b1) sig_aluop <= `ALUOP_SAR;
            /* slti */ else if (funct3 == 3'b010) sig_aluop <= `ALUOP_LT;
            /* sltiu*/ else if (funct3 == 3'b011) sig_aluop <= `ALUOP_LTU;
                       else sig_aluop <= `ALUOP_UNUSED;
            sig_branch <= `BRANCH_PC4;

            // ImmGen
            // slli, srli, srai
            if (funct3 == 3'b001 || funct3 == 3'b101) imm <= {27'b0, I_shamt5};  // Unsigned extension
            else imm <= {{(32 - 12){I_imm12[11]}}, I_imm12};
        end

        7'b0000011: begin
            // I-type: lb, lbu, lh, lhu, lw
            rs1 <= rs1_holding;
            rs2 <= 5'b0;
            rd <= rd_holding;

            sig_aluregsrc <= `ALUREGSRC_RS1;
            sig_aluimmsrc <= `ALUIMMSRC_IMM;
            sig_memread <= 1'b1;
            sig_memwrite <= 1'b0;
            /* lw  */ if (funct3 == 3'b010) sig_memrdwidth <= `MEMRDWIDTH_WORD;
            /* lh  */ else if (funct3 == 3'b001) sig_memrdwidth <= `MEMRDWIDTH_HWORD;
            /* lhu */ else if (funct3 == 3'b101) sig_memrdwidth <= `MEMRDWIDTH_UHWORD;
            /* lb  */ else if (funct3 == 3'b000) sig_memrdwidth <= `MEMRDWIDTH_BYTE;
            /* lbu */ else if (funct3 == 3'b100) sig_memrdwidth <= `MEMRDWIDTH_UBYTE;
                      else sig_memrdwidth <= `MEMRDWIDTH_UNUSED;
            sig_memwrwidth <= `MEMWRWIDTH_UNUSED;
            sig_regwrite <= 1'b1;
            sig_regwrsrc <= `REGWRSRC_MEM;
            sig_aluop <= `ALUOP_ADD;
            sig_branch <= `BRANCH_PC4;

            // ImmGen
            imm <= {{(32 - 12){I_imm12[11]}}, I_imm12};
        end

        7'b0100011: begin
            // S-type: sb, sh, sw
            rs1 <= rs1_holding;
            rs2 <= rs2_holding;
            rd <= 5'b0;

            sig_aluregsrc <= `ALUREGSRC_RS1;
            sig_aluimmsrc <= `ALUIMMSRC_IMM;
            sig_memread <= 1'b0;
            sig_memwrite <= 1'b1;
            sig_memrdwidth <= `MEMRDWIDTH_UNUSED;
            /* sw */ if (funct3 == 3'b010) sig_memwrwidth <= `MEMWRWIDTH_WORD;
            /* sh */ else if (funct3 == 3'b001) sig_memwrwidth <= `MEMWRWIDTH_HWORD;
            /* sb */ else if (funct3 == 3'b000) sig_memwrwidth <= `MEMWRWIDTH_BYTE;
                     else sig_memwrwidth <= `MEMWRWIDTH_UNUSED;
            sig_regwrite <= 1'b0;
            sig_regwrsrc <= `REGWRSRC_UNUSED;
            sig_aluop <= `ALUOP_ADD;
            sig_branch <= `BRANCH_PC4;

            // ImmGen
            imm <= {{(32 - 12){S_imm12[11]}}, S_imm12};
        end

        7'b1100011: begin
            // SB-type: beq, bne, blt, bltu, bge, bgeu
            rs1 <= rs1_holding;
            rs2 <= rs2_holding;
            rd <= 5'b0;

            sig_aluregsrc <= `ALUREGSRC_RS1;
            sig_aluimmsrc <= `ALUIMMSRC_RS2;
            sig_memread <= 1'b0;
            sig_memwrite <= 1'b0;
            sig_memrdwidth <= `MEMRDWIDTH_UNUSED;
            sig_memwrwidth <= `MEMWRWIDTH_UNUSED;
            sig_regwrite <= 1'b0;
            sig_regwrsrc <= `REGWRSRC_UNUSED;
            /* beq */ if (funct3 == 3'b000) begin
                sig_aluop <= `ALUOP_SUB;
                sig_branch <= `BRANCH_PCIMM_IF_ZERO;
            /* bne */ end else if (funct3 == 3'b001) begin
                sig_aluop <= `ALUOP_SUB;
                sig_branch <= `BRANCH_PCIMM_IF_NOT_ZERO;
            /* blt */ end else if (funct3 == 3'b100) begin
                sig_aluop <= `ALUOP_LT;
                sig_branch <= `BRANCH_PCIMM_IF_NOT_ZERO;
            /* bltu*/ end else if (funct3 == 3'b110) begin
                sig_aluop <= `ALUOP_LTU;
                sig_branch <= `BRANCH_PCIMM_IF_NOT_ZERO;
            /* bge */ end else if (funct3 == 3'b101) begin
                sig_aluop <= `ALUOP_LT;
                sig_branch <= `BRANCH_PCIMM_IF_ZERO;
            /* bgeu*/ end else if (funct3 == 3'b111) begin
                sig_aluop <= `ALUOP_LTU;
                sig_branch <= `BRANCH_PCIMM_IF_ZERO;
            end else begin
                sig_aluop <= `ALUOP_UNUSED;
                sig_branch <= `BRANCH_PC4;
            end

            // ImmGen
            imm <= {{(32 - 13){SB_imm13[12]}}, SB_imm13};
        end

        7'b1101111: begin
            // UJ-type: jal
            rs1 <= 5'b0;
            rs2 <= 5'b0;
            rd <= rd_holding;

            sig_aluregsrc <= `ALUREGSRC_UNUSED;
            sig_aluimmsrc <= `ALUIMMSRC_UNUSED;
            sig_memread <= 1'b0;
            sig_memwrite <= 1'b0;
            sig_memrdwidth <= `MEMRDWIDTH_WORD;
            sig_memwrwidth <= `MEMWRWIDTH_UNUSED;
            sig_regwrite <= 1'b1;
            sig_regwrsrc <= `REGWRSRC_PC4;
            sig_aluop <= `ALUOP_UNUSED;
            sig_branch <= `BRANCH_PCIMM;

            // ImmGen
            imm <= {{(32 - 21){UJ_imm21[20]}}, UJ_imm21};
        end

        7'b1100111: begin
            // I-type: jalr
            rs1 <= rs1_holding;
            rs2 <= 5'b0;
            rd <= rd_holding;

            sig_aluregsrc <= `ALUREGSRC_RS1;
            sig_aluimmsrc <= `ALUIMMSRC_IMM;
            sig_memread <= 1'b0;
            sig_memwrite <= 1'b0;
            sig_memrdwidth <= `MEMRDWIDTH_WORD;
            sig_memwrwidth <= `MEMWRWIDTH_UNUSED;
            sig_regwrite <= 1'b1;
            sig_regwrsrc <= `REGWRSRC_PC4;
            sig_aluop <= `ALUOP_ADD;
            sig_branch <= `BRANCH_ALU;

            // ImmGen
            imm <= {{(32 - 12){I_imm12[11]}}, I_imm12};
        end

        7'b0110111: begin
            // U-type: lui
            rs1 <= 5'b0;
            rs2 <= 5'b0;
            rd <= rd_holding;

            sig_aluregsrc <= `ALUREGSRC_UNUSED;
            sig_aluimmsrc <= `ALUIMMSRC_UNUSED;
            sig_memread <= 1'b0;
            sig_memwrite <= 1'b0;
            sig_memrdwidth <= `MEMRDWIDTH_WORD;
            sig_memwrwidth <= `MEMWRWIDTH_UNUSED;
            sig_regwrite <= 1'b1;
            sig_regwrsrc <= `REGWRSRC_IMM;
            sig_aluop <= `ALUOP_UNUSED;
            sig_branch <= `BRANCH_PC4;

            // ImmGen
            imm <= U_imm32;
        end

        7'b0010111: begin
            // U-type auipc
            rs1 <= 5'b0;
            rs2 <= 5'b0;
            rd <= rd_holding;

            sig_aluregsrc <= `ALUREGSRC_PC;
            sig_aluimmsrc <= `ALUIMMSRC_IMM;
            sig_memread <= 1'b0;
            sig_memwrite <= 1'b0;
            sig_memrdwidth <= `MEMRDWIDTH_WORD;
            sig_memwrwidth <= `MEMWRWIDTH_UNUSED;
            sig_regwrite <= 1'b1;
            sig_regwrsrc <= `REGWRSRC_ALU;
            sig_aluop <= `ALUOP_ADD;
            sig_branch <= `BRANCH_PC4;

            // ImmGen
            imm <= U_imm32;
        end

        default: begin
            rs1 <= 5'b0;
            rs2 <= 5'b0;
            rd <= 5'b0;

            sig_aluregsrc <= `ALUREGSRC_UNUSED;
            sig_aluimmsrc <= `ALUIMMSRC_UNUSED;
            sig_memread <= 1'b0;
            sig_memwrite <= 1'b0;
            sig_memrdwidth <= `MEMRDWIDTH_UNUSED;
            sig_memwrwidth <= `MEMWRWIDTH_UNUSED;
            sig_regwrite <= 1'b0;
            sig_regwrsrc <= `REGWRSRC_UNUSED;
            sig_aluop <= `ALUOP_UNUSED;
            sig_branch <= `BRANCH_PC4;

            // ImmGen
            imm <= 32'b0;
        end
    endcase
end

endmodule
