`define FAIL 1
module Nested
  (
   input logic 	clk,
   input logic 	x,
   output logic y
   );
   logic 		   t;
   always_comb t = x ^ 1'b1;
   always_ff @(posedge clk) begin
      if (clk)
        y <= t;
   end
endmodule
module Test
  (
   input logic 	      clk,
   input logic [7:0]  datai,
   input logic 	      enable,
   output logic [7:0] datao
   );
   logic [7:0] 	      datat;
   for (genvar i = 0; i < 8; i++) begin
      if (i%4 != 3) begin
`ifndef FAIL
         logic t;
         always_comb begin
	    t = datai[i] ^ 1'b1;
	 end
         always_ff @(posedge clk) begin
	    if (clk)
              datat[i] <= t;
	 end
`else
         Nested nested_i
	   (
	    .clk(clk),
	    .x(datai[i]),
	    .y(datat[i])  
	    );
`endif
         always_comb begin
	   casez (enable)
	     1'b1: datao[i] = datat[i];
	     1'b0: datao[i] = '0;
	     default: datao[i] = 'x;
	   endcase
	 end
      end
      else begin
         always_ff @(posedge clk) begin
	    if (clk)
              datat[i] <= 0;  
         end
         always_comb begin
	   casez (enable)
	     1'b1: datao[i] = datat[i] ^ 1'b1;
	     1'b0: datao[i] = '1;
	     default: datao[i] = 'x;
	   endcase
	 end
      end
   end
endmodule
module t (
   clk
   );
   input clk;
   integer 	cyc = 0;
   reg [63:0] 	crc;
   reg [63:0] 	sum;
   wire [7:0]  datai = crc[7:0];
   wire        enable = crc[8];
   logic [7:0]		datao;			
   Test test (
	      .datao			(datao[7:0]),
	      .clk			(clk),
	      .datai			(datai[7:0]),
	      .enable			(enable));
   wire [63:0] result = {56'h0, datao};
   always @ (posedge clk) begin
`ifdef TEST_VERBOSE
      $write("[%0t] cyc==%0d crc=%x result=%x\n", $time, cyc, crc, result);
`endif
      cyc <= cyc + 1;
      crc <= {crc[62:0], crc[63] ^ crc[2] ^ crc[0]};
      sum <= result ^ {sum[62:0], sum[63] ^ sum[2] ^ sum[0]};
      if (cyc==0) begin
	 crc <= 64'h5aef0c8d_d70a4497;
	 sum <= 64'h0;
      end
      else if (cyc<10) begin
	 sum <= 64'h0;
      end
      else if (cyc<90) begin
      end
      else if (cyc==99) begin
	 $write("[%0t] cyc==%0d crc=%x sum=%x\n", $time, cyc, crc, sum);
	 if (crc !== 64'hc77bb9b3784ea091) $stop;
`define EXPECTED_SUM 64'h9d550d82d38926fa
	 if (sum !== `EXPECTED_SUM) $stop;
	 $write("*-* All Finished *-*\n");
	 $finish;
      end
   end
endmodule
`define FAIL 1
module Nested
  (
   input logic 	clk,
   input logic 	x,
   output logic y
   );
   logic 		   t;
   always_comb t = x ^ 1'b1;
   always_ff @(posedge clk) begin
      if (clk)
        y <= t;
   end
endmodule
module Test
  (
   input logic 	      clk,
   input logic [7:0]  datai,
   input logic 	      enable,
   output logic [7:0] datao
   );
   logic [7:0] 	      datat;
   for (genvar i = 0; i < 8; i++) begin
      if (i%4 != 3) begin
`ifndef FAIL
         logic t;
         always_comb begin
	    t = datai[i] ^ 1'b1;
	 end
         always_ff @(posedge clk) begin
	    if (clk)
              datat[i] <= t;
	 end
`else
         Nested nested_i
	   (
	    .clk(clk),
	    .x(datai[i]),
	    .y(datat[i])  
	    );
`endif
         always_comb begin
	   casez (enable)
	     1'b1: datao[i] = datat[i];
	     1'b0: datao[i] = '0;
	     default: datao[i] = 'x;
	   endcase
	 end
      end
      else begin
         always_ff @(posedge clk) begin
	    if (clk)
              datat[i] <= 0;  
         end
         always_comb begin
	   casez (enable)
	     1'b1: datao[i] = datat[i] ^ 1'b1;
	     1'b0: datao[i] = '1;
	     default: datao[i] = 'x;
	   endcase
	 end
      end
   end
endmodule
