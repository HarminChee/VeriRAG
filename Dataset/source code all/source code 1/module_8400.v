`default_nettype none
`default_nettype none
module serial_wb_mcu(
	   clk_i, rst_i,
	   pm_addr_o, pm_insn_i,
	   port0_o,
	   port1_o,
	   strobe1_o,
	   port2_i,
	   strobe2_o
	   );
   input clk_i;
   input rst_i;
   output [9:0] pm_addr_o;
   input [15:0] pm_insn_i;
   output reg [7:0] port0_o;
   output reg [7:0] port1_o;
   output 	strobe1_o;
   input wire [7:0] 	port2_i;
   output 	strobe2_o;
   wire 	clk_i;
   wire 	rst_i;
   reg [9:0] 	pm_addr_o;
   wire [15:0] 	pm_insn_i;
   reg 	strobe1_o;
   reg  strobe2_o;
   reg [7:0] port2_r;
   reg [15:0] insnreg;
   reg [7:0] 	regfile[15:0];
   reg [7:0] 	rf_op_a;
   reg [7:0] 	rf_op_b;
   reg 		rf_w; 
   reg [7:0] 	rf_result; 
   reg [3:0] 	rf_index_r; 
   reg [8:0] 	alu_result;
   reg 		alu_flag_z;
   reg 		alu_flag_c;
   reg [8:0] 	pc;
   reg [8:0] 	returnpc_0; 
   reg [8:0] 	next_returnpc_0;
   reg [8:0] 	returnpc_1; 
   reg [8:0] 	next_returnpc_1;
   always @(posedge clk_i) begin
      port2_r <= port2_i;
   end
   reg [7:0] from_pm_r;
   always @(posedge clk_i) begin
      if(!rf_op_b[0]) begin
	 from_pm_r <= pm_insn_i[15:8];
      end else begin
	 from_pm_r <= pm_insn_i[7:0];
      end
   end
   always @(posedge clk_i)
     if(rst_i) begin
     end else begin
	if(rf_w)
	  regfile[rf_index_r] <= rf_result;
     end
   wire [7:0] rf_output;
   assign rf_output = regfile[rf_index_r];
   localparam [1:0] FETCH = 2'd0;   
   localparam [1:0] DECODE1 = 2'd1;  
   localparam [1:0] DECODE2 = 2'd2; 
   localparam [1:0] EXECUTE = 2'd3; 
   reg [1:0] 	    state_r;
   always @(posedge clk_i)
      if(rst_i) begin
	 $display("In reset");
	 state_r <= FETCH;
      end else begin
	 case(state_r)
	   FETCH: state_r <= DECODE1;
	   DECODE1: state_r <= DECODE2;
	   DECODE2: state_r <= EXECUTE;
	   EXECUTE: state_r <= FETCH;
	 endcase 
      end
   always @(posedge clk_i)
     if(rst_i) begin
	insnreg <= 16'hffff;
     end else begin
	if(state_r == FETCH) begin
	   insnreg <= pm_insn_i;
	   if(pm_insn_i == 16'hfffe) begin
	      $display("Breakpoint!");
	      $stop;
	   end
	end
     end
   always @* 
      case(state_r)
	FETCH: rf_index_r = insnreg[11:8];
	DECODE1: rf_index_r = insnreg[7:4];
	DECODE2: rf_index_r = insnreg[3:0];
	default: rf_index_r = insnreg[3:0];
      endcase 
   always @(posedge clk_i) begin
      if(state_r == DECODE1) rf_op_a <= rf_output;
      if(state_r == DECODE2) rf_op_b <= rf_output;
   end
   always @* begin
      if(state_r == DECODE1) begin
	 pm_addr_o = {rf_op_a[2:0],rf_op_b[7:1]};
      end else begin
	 pm_addr_o = pc;
      end
   end 
   always @(posedge clk_i)
     if(rst_i) begin
	pc <= 0;
	returnpc_0 <= 0;
	returnpc_1 <= 0;
     end else begin
	if(state_r == FETCH) begin
	   pc <= pc + 1;
	end else if(state_r == DECODE1) begin
	   if(insnreg[15:12] == 4'b1000) begin
	      case(insnreg[11:9])
		3'b000:
		  pc <= insnreg[8:0];
		3'b001:
		  if(alu_flag_z)
		    pc <= insnreg[8:0];
		3'b010:
		  if(alu_flag_c)
		    pc <= insnreg[8:0];
		3'b011: begin
		   pc <= insnreg[8:0];
		   returnpc_0 <= pc;
		   returnpc_1 <= returnpc_0;
		end
		default: begin
		   pc <= returnpc_0;
		   returnpc_0 <= returnpc_1;
		end
	      endcase 
	   end 
	end
     end 
   always @(posedge clk_i)
     if(rst_i) begin
	port0_o <= 0;
	port1_o <= 0;
	strobe1_o <= 0;
     end else begin
	strobe1_o <= 0;
	if(state_r == EXECUTE) begin
	   if(insnreg[15:12] == 4'b1001) begin
	      if(insnreg[8] == 0) begin
		 port0_o <= rf_op_a;
	      end else begin
		 strobe1_o <= 1;
		 port1_o <= rf_op_a;
	      end
	   end
	end
     end 
   reg [7:0] alu_result_r;
   always @*
     case(insnreg[13:12])
       2'b00:   alu_result = { 1'b0 , rf_op_a} + {1'b0, rf_op_b};
       2'b01:   alu_result = rf_op_a ^ rf_op_b;
       2'b10:   alu_result = rf_op_a & rf_op_b;
       default: alu_result = rf_op_a | rf_op_b;
     endcase 
   always @(posedge clk_i)
     if(rst_i) begin
	alu_result_r <= 8'b0;
     end else begin
	alu_result_r <= alu_result;
     end 
   always @(posedge clk_i)
     if(rst_i) begin
	alu_flag_c <= 0;
	alu_flag_z <= 0;
	strobe2_o <= 1'b0;
	rf_w <= 0;
     end else begin
	strobe2_o <= 1'b0;
	rf_w <= 0;
      if(state_r == DECODE1) begin
	 if(insnreg[15:12] == 4'b0101) begin
	    strobe2_o <= 1'b1;
	 end
      end else if(state_r == EXECUTE) begin
	 case(insnreg[15:14])
	   2'b00: begin 
	      rf_result <= alu_result;
	      rf_w <= 1;
	      alu_flag_c <= alu_result[8];
	      if(alu_result[7:0] == 0) 
		alu_flag_z <= 1;
	      else
		alu_flag_z <= 0;
	   end
	   2'b01: begin
	      rf_w <= 1;
	      case(insnreg[13:12])
		2'b00: begin
		   rf_result <= insnreg[7:0];
		end
		2'b01: begin
		   rf_result <= port2_r;
		end
		2'b10: begin
		   rf_result <= from_pm_r;
		end
		default: begin
		   rf_result <= {rf_op_a[3:0], rf_op_a[7:4]};
		end
	      endcase 
	   end
	   default: begin
	      rf_w <= 0;
	   end
	 endcase 
      end
   end
endmodule 
