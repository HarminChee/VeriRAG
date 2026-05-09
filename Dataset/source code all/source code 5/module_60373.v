`define DDIFF_BITS 9
`define AOA_BITS 8
`define HALF_DDIFF `DDIFF_BITS'd256
`define MAX_AOA `AOA_BITS'd255
`define BURP_DIVIDER 9'd16
module Test (
   AOA_B,
   DDIFF_B, reset, clk
   );
   input [`DDIFF_BITS-1:0] DDIFF_B;
   input reset;
   input clk;
   output reg [`AOA_BITS-1:0] AOA_B;
   reg [`AOA_BITS-1:0] AOA_NEXT_B;
   reg [`AOA_BITS-1:0] tmp;
   always @(posedge clk) begin
      if (reset) begin
	 AOA_B <= 8'h80;
      end
      else begin
	 AOA_B <= AOA_NEXT_B;
      end
   end
   always @* begin
      tmp = ((`HALF_DDIFF-DDIFF_B)/`BURP_DIVIDER);
      t_aoa_update(AOA_NEXT_B, AOA_B, ((`HALF_DDIFF-DDIFF_B)/`BURP_DIVIDER));
   end
   task t_aoa_update;
      output [`AOA_BITS-1:0] aoa_reg_next;
      input [`AOA_BITS-1:0] aoa_reg;
      input [`AOA_BITS-1:0] aoa_delta_update;
      begin
         if ((`MAX_AOA-aoa_reg)<aoa_delta_update) 
           aoa_reg_next=`MAX_AOA;
         else
           aoa_reg_next=aoa_reg+aoa_delta_update;
      end
   endtask
endmodule
`define DDIFF_BITS 9
`define AOA_BITS 8
`define HALF_DDIFF `DDIFF_BITS'd256
`define MAX_AOA `AOA_BITS'd255
`define BURP_DIVIDER 9'd16
module t (
   clk
   );
   input clk;
   integer 	cyc = 0;
   reg [63:0] 	crc;
   reg [63:0] 	sum;
   wire [`DDIFF_BITS-1:0] DDIFF_B = crc[`DDIFF_BITS-1:0];
   wire reset = (cyc<7);
   wire [`AOA_BITS-1:0]	AOA_B;			
   Test test (
	      .AOA_B			(AOA_B[`AOA_BITS-1:0]),
	      .DDIFF_B			(DDIFF_B[`DDIFF_BITS-1:0]),
	      .reset			(reset),
	      .clk			(clk));
   wire [63:0] result = {56'h0, AOA_B};
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
`define EXPECTED_SUM 64'h3a74e9d34771ad93
	 if (sum !== `EXPECTED_SUM) $stop;
	 $write("*-* All Finished *-*\n");
	 $finish;
      end
   end
endmodule
module Test (
   AOA_B,
   DDIFF_B, reset, clk
   );
   input [`DDIFF_BITS-1:0] DDIFF_B;
   input reset;
   input clk;
   output reg [`AOA_BITS-1:0] AOA_B;
   reg [`AOA_BITS-1:0] AOA_NEXT_B;
   reg [`AOA_BITS-1:0] tmp;
   always @(posedge clk) begin
      if (reset) begin
	 AOA_B <= 8'h80;
      end
      else begin
	 AOA_B <= AOA_NEXT_B;
      end
   end
   always @* begin
      tmp = ((`HALF_DDIFF-DDIFF_B)/`BURP_DIVIDER);
      t_aoa_update(AOA_NEXT_B, AOA_B, ((`HALF_DDIFF-DDIFF_B)/`BURP_DIVIDER));
   end
   task t_aoa_update;
      output [`AOA_BITS-1:0] aoa_reg_next;
      input [`AOA_BITS-1:0] aoa_reg;
      input [`AOA_BITS-1:0] aoa_delta_update;
      begin
         if ((`MAX_AOA-aoa_reg)<aoa_delta_update) 
           aoa_reg_next=`MAX_AOA;
         else
           aoa_reg_next=aoa_reg+aoa_delta_update;
      end
   endtask
endmodule
