
// testbench for simulation
module sccomp_tb();
    
   reg  clk, rstn;
   reg  [4:0] reg_sel;
   wire [31:0] reg_data;
    
// instantiation of sccomp    
   sccomp U_SCCOMP(
      .clk(clk), .rstn(rstn), .reg_sel(reg_sel), .reg_data(reg_data) 
   );

  	integer foutput;
  	integer counter = 0;
  	integer end_pc = 999999;
   
   initial begin
      $readmemh( "cputest.in" , U_SCCOMP.U_IM.memory); // load instructions into instruction memory
      foutput = $fopen("cputest.out");
      clk = 1;
      rstn = 1;
      #5 ;
      rstn = 0;
      #20 ;
      rstn = 1;
      #1000 ;
      reg_sel = 7;
   end
   
    always begin
    #(50) clk = ~clk;
	   
    if (clk == 1'b1) begin
      counter = counter + 1;
      // 指令结束
      if (U_SCCOMP.U_SCPU.inst_mem_in=== 32'b0 && end_pc == 999999) begin
        end_pc <= U_SCCOMP.U_SCPU.inst_mem_addr + 20;
      end
      if (counter == 1000 || U_SCCOMP.U_SCPU.inst_mem_addr == end_pc) begin
        $fclose(foutput);
        $stop;
      end
    end
  end //end always

initial
begin
  $dumpfile("wave.vcd");
  $dumpvars(0, sccomp_tb );
end
   
endmodule
