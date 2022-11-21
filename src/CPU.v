`include "src/include/InstSpec.v"

module CPU(
    input clk, rst, int,
    output [31:0] inst_mem_addr,
    input [31:0] inst_mem_in,
    output [31:0] data_mem_addr,
    input [31:0] data_mem_in,
    output data_mem_write_en,
    output [`MEMWRWIDTH_BUS] data_mem_write_width,
    output [31:0] data_mem_out,
    output [31:0] x25
);

// ==================== IF ====================
wire [31:0] pcgenerator_new_pc;
wire pcgenerator_flush_needed;
// ==================== ID ====================
// ==================== EX ====================
wire aluforwarding_stall;
wire stageex_sig_regwrite;
wire [`REGWRSRC_BUS] stageex_sig_regwrsrc;
wire [31:0] alu_opout;
wire [4:0] stageex_rd;
wire [31:0] stageex_imm;
wire [31:0] stageex_pc;
// ==================== MEM ====================
wire stagemem_sig_regwrite;
wire [`REGWRSRC_BUS] stagemem_sig_regwrsrc;
wire [`BRANCH_BUS] stagemem_sig_branch;
wire [31:0] stagemem_aluresult;
wire stagemem_aluzero;
wire [4:0] stagemem_rd;
wire [31:0] stagemem_imm;
wire [31:0] stagemem_pc;
wire [31:0] dmreadhandler_result;
// ==================== WB ====================
wire stagewb_sig_regwrite;
wire [4:0] stagewb_rd;
wire [31:0] stagewb_rd_data;

// ==================== IF ====================
wire [31:0] pc_pc;
PC u_PC(
    .clk          (clk    ),
    .rst          (rst    ),
    .int          (int    ),
    .new_pc       (pcgenerator_new_pc),
    .pc           (pc_pc  )
);

PCGenerator u_PCGenerator(
    .pc         (pc_pc      ),
    .branch_pc  (stagemem_pc),
    .aluresult  (stagemem_aluresult),
    .imm        (stagemem_imm),
    .zero       (stagemem_aluzero),
    .sig_branch (stagemem_sig_branch),
    .stall      (aluforwarding_stall),
    .new_pc     (pcgenerator_new_pc),
    .flush_needed(pcgenerator_flush_needed)
);

assign inst_mem_addr = pc_pc;

// ==================== ID ====================
wire [31:0] stageid_pc;
wire [31:0] stageid_inst;
StageID u_StageID(
    .clk    (clk    ),
    .rst    (rst    ),
    .flush  (pcgenerator_flush_needed),
    .lock   (aluforwarding_stall),
    .inst_in(inst_mem_in),
    .pc_in  (pc_pc  ),
    .inst_out(stageid_inst),
    .pc_out (stageid_pc)
);

wire [4:0] instresolver_rs1, instresolver_rs2, instresolver_rd;
wire [31:0] instresolver_imm;
wire [`ALUREGSRC_BUS] instresolver_sig_aluregsrc;
wire [`ALUIMMSRC_BUS] instresolver_sig_aluimmsrc;
wire instresolver_sig_memread;
wire instresolver_sig_memwrite;
wire [`MEMRDWIDTH_BUS] instresolver_sig_memrdwidth;
wire [`MEMWRWIDTH_BUS] instresolver_sig_memwrwidth;
wire instresolver_sig_regwrite;
wire [`REGWRSRC_BUS] instresolver_sig_regwrsrc;
wire [`ALUOP_BUS] instresolver_sig_aluop;
wire [`BRANCH_BUS] instresolver_sig_branch;
InstResolver u_InstResolver(
    .inst           (stageid_inst   ),
    .rs1            (instresolver_rs1),
    .rs2            (instresolver_rs2),
    .rd             (instresolver_rd),
    .imm            (instresolver_imm),
    .sig_aluregsrc  (instresolver_sig_aluregsrc  ),
    .sig_aluimmsrc  (instresolver_sig_aluimmsrc  ),
    .sig_memread    (instresolver_sig_memread    ),
    .sig_memwrite   (instresolver_sig_memwrite   ),
    .sig_memrdwidth (instresolver_sig_memrdwidth ),
    .sig_memwrwidth (instresolver_sig_memwrwidth ),
    .sig_regwrite   (instresolver_sig_regwrite   ),
    .sig_regwrsrc   (instresolver_sig_regwrsrc   ),
    .sig_aluop      (instresolver_sig_aluop      ),
    .sig_branch     (instresolver_sig_branch     )
);

wire [31:0] regfile_rs1_data;
wire [31:0] regfile_rs2_data;
RegFile u_RegFile(
    .clk         (clk         ),
    .rst         (rst         ),
    .rs1         (instresolver_rs1),
    .rs2         (instresolver_rs2),
    .rd          (stagewb_rd      ),
    .write_en    (stagewb_sig_regwrite),
    .write_data  (stagewb_rd_data ),
    .rs1_data    (regfile_rs1_data),
    .rs2_data    (regfile_rs2_data),
    .x25         (x25)
);

// ==================== EX ====================
wire [`ALUREGSRC_BUS] stageex_sig_aluregsrc;
wire [`ALUIMMSRC_BUS] stageex_sig_aluimmsrc;
wire stageex_sig_memread;
wire stageex_sig_memwrite;
wire [`MEMRDWIDTH_BUS] stageex_sig_memrdwidth;
wire [`MEMWRWIDTH_BUS] stageex_sig_memwrwidth;
wire [`ALUOP_BUS] stageex_sig_aluop;
wire [`BRANCH_BUS] stageex_sig_branch;
wire [31:0] stageex_rs1_data, stageex_rs2_data;
wire [4:0] stageex_rs1, stageex_rs2;
StageEX u_StageEX(
    .clk                (clk                ),
    .rst                (rst                ),
    .flush              (pcgenerator_flush_needed),
    .lock               (aluforwarding_stall),
    .sig_aluregsrc_in   (instresolver_sig_aluregsrc),
    .sig_aluimmsrc_in   (instresolver_sig_aluimmsrc),
    .sig_aluop_in       (instresolver_sig_aluop),
    .sig_aluregsrc_out  (stageex_sig_aluregsrc),
    .sig_aluimmsrc_out  (stageex_sig_aluimmsrc),
    .sig_aluop_out      (stageex_sig_aluop),
    .sig_memread_in     (instresolver_sig_memread),
    .sig_memwrite_in    (instresolver_sig_memwrite),
    .sig_memwrwidth_in  (instresolver_sig_memwrwidth),
    .sig_branch_in      (instresolver_sig_branch),
    .sig_memread_out    (stageex_sig_memread),
    .sig_memwrite_out   (stageex_sig_memwrite),
    .sig_memwrwidth_out (stageex_sig_memwrwidth),
    .sig_branch_out     (stageex_sig_branch),
    .sig_regwrite_in    (instresolver_sig_regwrite),
    .sig_memrdwidth_in  (instresolver_sig_memrdwidth),
    .sig_regwrsrc_in    (instresolver_sig_regwrsrc),
    .sig_regwrite_out   (stageex_sig_regwrite),
    .sig_memrdwidth_out (stageex_sig_memrdwidth),
    .sig_regwrsrc_out   (stageex_sig_regwrsrc),
    .rs1_data_in        (regfile_rs1_data),
    .rs2_data_in        (regfile_rs2_data),
    .pc_in              (stageid_pc),
    .imm_in             (instresolver_imm),
    .rs1_in             (instresolver_rs1),
    .rs2_in             (instresolver_rs2),
    .rd_in              (instresolver_rd),
    .rs1_data_out       (stageex_rs1_data),
    .rs2_data_out       (stageex_rs2_data),
    .pc_out             (stageex_pc),
    .imm_out            (stageex_imm),
    .rs1_out            (stageex_rs1),
    .rs2_out            (stageex_rs2),
    .rd_out             (stageex_rd)
);

wire [31:0] aluforwarding_rs1_data, aluforwarding_rs2_data;
ALUForwarding u_ALUForwarding(
    .ex_rs1_data      (stageex_rs1_data),
    .ex_rs2_data      (stageex_rs2_data),
    .rs1_data         (aluforwarding_rs1_data),
    .rs2_data         (aluforwarding_rs2_data),
    .stall            (aluforwarding_stall),
    .ex_rs1           (stageex_rs1),
    .ex_rs2           (stageex_rs2),
    .mem_rd           (stagemem_rd),
    .mem_sig_regwrite (stagemem_sig_regwrite),
    .mem_sig_regwrsrc (stagemem_sig_regwrsrc),
    .mem_aluresult    (stagemem_aluresult),
    .mem_imm          (stagemem_imm),
    .mem_pc           (stagemem_pc),
    .wb_rd            (stagewb_rd),
    .wb_sig_regwrite  (stagewb_sig_regwrite),
    .wb_rd_data       (stagewb_rd_data)
);

wire [31:0] aluoperandselector_op1, aluoperandselector_op2;
ALUOperandSelector u_ALUOperandSelector(
    .sig_aluregsrc (stageex_sig_aluregsrc),
    .sig_aluimmsrc (stageex_sig_aluimmsrc),
    .rs1_data      (aluforwarding_rs1_data),
    .rs2_data      (aluforwarding_rs2_data),
    .imm           (stageex_imm   ),
    .pc            (stageex_pc    ),
    .op1           (aluoperandselector_op1),
    .op2           (aluoperandselector_op2)
);

wire alu_zero;
ALU u_ALU(
    .sig_aluop (stageex_sig_aluop),
    .op1       (aluoperandselector_op1),
    .op2       (aluoperandselector_op2),
    .opout     (alu_opout ),
    .zero      (alu_zero  )
);

// ==================== MEM ====================
wire stagemem_sig_memread;
wire stagemem_sig_memwrite;
wire [`MEMRDWIDTH_BUS] stagemem_sig_memrdwidth;
wire [`MEMWRWIDTH_BUS] stagemem_sig_memwrwidth;
wire [31:0] stagemem_rs2_data;
StageMEM u_StageMEM(
    .clk                (clk                ),
    .rst                (rst                ),
    .flush              (aluforwarding_stall | pcgenerator_flush_needed),
    .lock               (1'b0               ),
    .sig_memread_in     (stageex_sig_memread     ),
    .sig_memwrite_in    (stageex_sig_memwrite    ),
    .sig_memwrwidth_in  (stageex_sig_memwrwidth  ),
    .sig_branch_in      (stageex_sig_branch      ),
    .sig_memread_out    (stagemem_sig_memread    ),
    .sig_memwrite_out   (stagemem_sig_memwrite   ),
    .sig_memwrwidth_out (stagemem_sig_memwrwidth ),
    .sig_branch_out     (stagemem_sig_branch     ),
    .sig_regwrite_in    (stageex_sig_regwrite    ),
    .sig_memrdwidth_in  (stageex_sig_memrdwidth  ),
    .sig_regwrsrc_in    (stageex_sig_regwrsrc    ),
    .sig_regwrite_out   (stagemem_sig_regwrite   ),
    .sig_memrdwidth_out (stagemem_sig_memrdwidth ),
    .sig_regwrsrc_out   (stagemem_sig_regwrsrc   ),
    .rs2_data_in        (aluforwarding_rs2_data  ),
    .pc_in              (stageex_pc              ),
    .aluresult_in       (alu_opout               ),
    .aluzero_in         (alu_zero                ),
    .rd_in              (stageex_rd              ),
    .imm_in             (stageex_imm             ),
    .rs2_data_out       (stagemem_rs2_data       ),
    .pc_out             (stagemem_pc             ),
    .aluresult_out      (stagemem_aluresult      ),
    .aluzero_out        (stagemem_aluzero        ),
    .rd_out             (stagemem_rd             ),
    .imm_out            (stagemem_imm            )
);

assign data_mem_addr = stagemem_aluresult;
assign data_mem_out = stagemem_rs2_data;
assign data_mem_write_en = stagemem_sig_memwrite;
assign data_mem_write_width = stagemem_sig_memwrwidth;

DMReadHandler u_DMReadHandler(
    .memory_read_width (stagemem_sig_memrdwidth),
    .block_address     (data_mem_addr[1:0]),
    .data_mem_in       (data_mem_in       ),
    .read_result       (dmreadhandler_result)
);

// ==================== WB ====================
wire [`REGWRSRC_BUS] stagewb_sig_regwrsrc;
wire [31:0] stagewb_pc;
wire [31:0] stagewb_aluresult;
wire [31:0] stagewb_imm;
wire [31:0] stagewb_mem_read_data;
StageWB u_StageWB(
    .clk                (clk                ),
    .rst                (rst                ),
    .flush              (1'b0               ),
    .lock               (1'b0               ),
    .sig_regwrite_in    (stagemem_sig_regwrite  ),
    .sig_regwrsrc_in    (stagemem_sig_regwrsrc  ),
    .sig_regwrite_out   (stagewb_sig_regwrite   ),
    .sig_regwrsrc_out   (stagewb_sig_regwrsrc   ),
    .pc_in              (stagemem_pc            ),
    .rd_in              (stagemem_rd            ),
    .aluresult_in       (stagemem_aluresult     ),
    .imm_in             (stagemem_imm           ),
    .mem_read_data_in   (dmreadhandler_result   ),
    .pc_out             (stagewb_pc             ),
    .rd_out             (stagewb_rd             ),
    .aluresult_out      (stagewb_aluresult      ),
    .imm_out            (stagewb_imm            ),
    .mem_read_data_out  (stagewb_mem_read_data  )
);

RegFileWriteDataSelector u_RegFileWriteDataSelector(
    .sig_regwrsrc (stagewb_sig_regwrsrc),
    .aluresult    (stagewb_aluresult),
    .data_mem_in  (stagewb_mem_read_data),
    .imm          (stagewb_imm  ),
    .pc           (stagewb_pc   ),
    .rd_data      (stagewb_rd_data)
);

endmodule
