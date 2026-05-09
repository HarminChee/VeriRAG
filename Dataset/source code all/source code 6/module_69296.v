module t (
   clk
   );
   input clk;
   reg gated_clk_en = 1'b0 ;
   reg [1:0] pc = 2'b0;
   reg [1:0] res = 2'b0;
   wire gated_clk = gated_clk_en & clk;
   always @(posedge clk) begin
      pc <= pc + 1;
      gated_clk_en <= 1'b1;
   end
   always @(posedge gated_clk) begin
      res <= pc;
   end
   always @(posedge clk) begin
      if (pc == 2'b11) begin
	 if (res == 2'b10) begin
	    $write("*-* All Finished *-*\n");
	    $finish;
	 end
	 else begin
	   $stop;
	 end
      end
   end
endmodule
