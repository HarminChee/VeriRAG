module Test (
   b, c,
   clk, rst_l, in
   );
   parameter    WIDTH = 5;
   input                 clk;
   input 		 rst_l;
   input [WIDTH-1:0] 	 in;
   output wire [WIDTH-1:0] 	b;
   output wire [WIDTH-1:0] 	c;
   dff # ( .WIDTH	(WIDTH),
	   .RESET	('0),   
	   .RESET_WIDTH (1) )
   sub1
     ( .clk(clk), .rst_l(rst_l), .q(b), .d(in) );
   dff # ( .WIDTH	(WIDTH),
	   .RESET	({ 1'b1, {(WIDTH-1){1'b0}} }),
	   .RESET_WIDTH (WIDTH))
   sub2
     ( .clk(clk), .rst_l(rst_l), .q(c), .d(in) );
endmodule
module dff (
   q,
   clk, rst_l, d
   );
   parameter WIDTH = 1;
   parameter RESET = {WIDTH{1'b0}};
   parameter RESET_WIDTH = WIDTH;
   input   clk;
   input   rst_l;
   input [WIDTH-1:0] d;
   output reg [WIDTH-1:0] q;
   always_ff @(posedge clk or negedge rst_l) begin
      if ($bits(RESET) != RESET_WIDTH) $stop;
      if (~rst_l) q <= RESET;
      else q <= d;
   end
endmodule
module t (
   clk
   );
   input clk;
   integer 	cyc = 0;
   reg [63:0] 	crc;
   reg [63:0] 	sum;
   wire [31:0]  in = crc[31:0];
   localparam WIDTH = 31;
   wire [WIDTH-1:0]	b;			
   wire [WIDTH-1:0]	c;			
   reg 			rst_l;
   Test #(.WIDTH(WIDTH))
   test (
	 .b				(b[WIDTH-1:0]),
	 .c				(c[WIDTH-1:0]),
	 .clk				(clk),
	 .rst_l				(rst_l),
	 .in				(in[WIDTH-1:0]));
   wire [63:0] result = {1'h0, c, 1'b0, b};
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
	 rst_l <= ~1'b1;
      end
      else if (cyc<10) begin
	 sum <= 64'h0;
	 rst_l <= ~1'b1;
      end
      else if (cyc<20) begin
	 rst_l <= ~1'b0;
      end
      else if (cyc<90) begin
      end
      else if (cyc==99) begin
	 $write("[%0t] cyc==%0d crc=%x sum=%x\n", $time, cyc, crc, sum);
	 if (crc !== 64'hc77bb9b3784ea091) $stop;
`define EXPECTED_SUM 64'hbcfcebdb75ec9d32
	 if (sum !== `EXPECTED_SUM) $stop;
	 $write("*-* All Finished *-*\n");
	 $finish;
      end
   end
endmodule
module Test (
   b, c,
   clk, rst_l, in
   );
   parameter    WIDTH = 5;
   input                 clk;
   input 		 rst_l;
   input [WIDTH-1:0] 	 in;
   output wire [WIDTH-1:0] 	b;
   output wire [WIDTH-1:0] 	c;
   dff # ( .WIDTH	(WIDTH),
	   .RESET	('0),   
	   .RESET_WIDTH (1) )
   sub1
     ( .clk(clk), .rst_l(rst_l), .q(b), .d(in) );
   dff # ( .WIDTH	(WIDTH),
	   .RESET	({ 1'b1, {(WIDTH-1){1'b0}} }),
	   .RESET_WIDTH (WIDTH))
   sub2
     ( .clk(clk), .rst_l(rst_l), .q(c), .d(in) );
endmodule
module dff (
   q,
   clk, rst_l, d
   );
   parameter WIDTH = 1;
   parameter RESET = {WIDTH{1'b0}};
   parameter RESET_WIDTH = WIDTH;
   input   clk;
   input   rst_l;
   input [WIDTH-1:0] d;
   output reg [WIDTH-1:0] q;
   always_ff @(posedge clk or negedge rst_l) begin
      if ($bits(RESET) != RESET_WIDTH) $stop;
      if (~rst_l) q <= RESET;
      else q <= d;
   end
endmodule
