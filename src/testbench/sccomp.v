`include "src/include/InstSpec.v"

module sccomp(clk, rstn, reg_sel, reg_data);
   input          clk;
   input          rstn;
   input [4:0]    reg_sel;
   output [31:0]  reg_data;
   
   wire [31:0]    instr;
   wire [31:0]    PC;
   wire           MemWrite;
   wire [31:0]    dm_addr, dm_din, dm_dout;
   wire [`MEMWRWIDTH_BUS] dm_width;
   
   wire rst = ~rstn;
       
  // instantiation of single-cycle CPU   
   CPU U_SCPU(
         .clk(clk),                 // input:  cpu clock
         .rst(rst),                 // input:  reset
         .inst_mem_in(instr),             // input:  instruction
         .inst_mem_addr(PC),                   // output: PC
         .data_mem_in(dm_dout),        // input:  data to cpu  
         .data_mem_addr(dm_addr),          // output: address from cpu to memory
         .data_mem_write_en(MemWrite),       // output: memory write signal
         .data_mem_write_width(dm_width),    // output: memory write width
         .data_mem_out(dm_din),        // output: data from cpu to memory
         .int(1'b0)
         );
         
  // instantiation of data memory  
   DataMem    U_DM(
         .clk(clk),           // input:  cpu clock
         .write_en(MemWrite),     // input:  ram write
         .addr(dm_addr), // input:  ram address
         .din(dm_din),        // input:  data to ram
         .dout(dm_dout),       // output: data from ram
         .write_width(dm_width)
         );
         
  // instantiation of intruction memory (used for simulation)
   InstMem    U_IM ( 
      .addr(PC),     // input:  rom address
      .dout(instr)        // output: instruction
   );
        
endmodule

