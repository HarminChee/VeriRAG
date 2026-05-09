module adc08d1020_serial(
			 output wire sclk,  
			 output reg sdata,
			 output reg scs,
			 input wire [15:0] w_data,
			 input wire [3:0] w_addr,
			 input wire commit,
			 output wire busy,
			 input wire clk12p5
			 );
   reg [15:0] 			    l_data;
   reg [3:0] 			    l_addr;
   reg 				    l_commit;
   reg 				    l_busy;
   reg [5:0] 			    cycle;
   reg [31:0] 			    shifter;
   reg 				    commit_d;
   reg 				    commit_pulse;  
   assign busy = l_busy;
   always @(posedge clk12p5) begin
      l_data <= w_data;
      l_addr <= w_addr;
      l_commit <= commit;
      l_busy <= (cycle[5:0] != 6'b0);
   end
   always @(posedge clk12p5) begin
      commit_d <= l_commit;
      commit_pulse <= !commit_d && l_commit;
   end
   ODDR2 sclk_oddr2 (
		     .D0(1'b1),
		     .D1(1'b0),
		     .C0(clk12p5),
		     .C1(!clk12p5),
		     .CE(1'b1),
		     .R(1'b0),
		     .S(1'b0),
		     .Q(sclk) );
   always @(posedge clk12p5) begin
      if( commit_pulse && (cycle[5:0] == 6'b0) ) begin
	 shifter[31:0] <= {12'b0000_0000_0001,l_addr[3:0],l_data[15:0]};
	 cycle[5:0] <= 6'b10_0000;
      end else if( cycle[5:0] != 6'b0 ) begin
	 cycle[5:0] <= cycle[5:0] - 6'b1;
	 shifter[31:0] <= {shifter[30:0], 1'b0};
      end else begin
	 cycle[5:0] <= 6'b0;
	 shifter[31:0] <= 32'b0;
      end
   end
   always @(posedge clk12p5) begin
      sdata <= shifter[31];
      scs <= !(cycle[5:0] != 6'b0);
   end
endmodule 
