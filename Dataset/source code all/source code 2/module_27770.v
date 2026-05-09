`timescale 1 ps / 1 ps
module flt_recip_rom
  (
   input            clk,
   input      [6:0] index,
   output reg [7:0] init_est
   );
   always @(posedge clk) begin
      case (index) 
        7'h00: init_est <= 8'hff;
        7'h01: init_est <= 8'hfb;
        7'h02: init_est <= 8'hf7;
        7'h03: init_est <= 8'hf3;
        7'h04: init_est <= 8'hef;
        7'h05: init_est <= 8'heb;
        7'h06: init_est <= 8'he8;
        7'h07: init_est <= 8'he4;
        7'h08: init_est <= 8'he1;
        7'h09: init_est <= 8'hdd;
        7'h0a: init_est <= 8'hda;
        7'h0b: init_est <= 8'hd6;
        7'h0c: init_est <= 8'hd3;
        7'h0d: init_est <= 8'hd0;
        7'h0e: init_est <= 8'hcc;
        7'h0f: init_est <= 8'hc9;
        7'h10: init_est <= 8'hc6;
        7'h11: init_est <= 8'hc3;
        7'h12: init_est <= 8'hc0;
        7'h13: init_est <= 8'hbd;
        7'h14: init_est <= 8'hba;
        7'h15: init_est <= 8'hb7;
        7'h16: init_est <= 8'hb4;
        7'h17: init_est <= 8'hb1;
        7'h18: init_est <= 8'hae;
        7'h19: init_est <= 8'hab;
        7'h1a: init_est <= 8'ha9;
        7'h1b: init_est <= 8'ha6;
        7'h1c: init_est <= 8'ha3;
        7'h1d: init_est <= 8'ha1;
        7'h1e: init_est <= 8'h9e;
        7'h1f: init_est <= 8'h9b;
        7'h20: init_est <= 8'h99;
        7'h21: init_est <= 8'h96;
        7'h22: init_est <= 8'h94;
        7'h23: init_est <= 8'h91;
        7'h24: init_est <= 8'h8f;
        7'h25: init_est <= 8'h8c;
        7'h26: init_est <= 8'h8a;
        7'h27: init_est <= 8'h88;
        7'h28: init_est <= 8'h85;
        7'h29: init_est <= 8'h83;
        7'h2a: init_est <= 8'h81;
        7'h2b: init_est <= 8'h7f;
        7'h2c: init_est <= 8'h7c;
        7'h2d: init_est <= 8'h7a;
        7'h2e: init_est <= 8'h78;
        7'h2f: init_est <= 8'h76;
        7'h30: init_est <= 8'h74;
        7'h31: init_est <= 8'h72;
        7'h32: init_est <= 8'h70;
        7'h33: init_est <= 8'h6e;
        7'h34: init_est <= 8'h6c;
        7'h35: init_est <= 8'h6a;
        7'h36: init_est <= 8'h68;
        7'h37: init_est <= 8'h66;
        7'h38: init_est <= 8'h64;
        7'h39: init_est <= 8'h62;
        7'h3a: init_est <= 8'h60;
        7'h3b: init_est <= 8'h5e;
        7'h3c: init_est <= 8'h5c;
        7'h3d: init_est <= 8'h5a;
        7'h3e: init_est <= 8'h59;
        7'h3f: init_est <= 8'h57;
        7'h40: init_est <= 8'h55;
        7'h41: init_est <= 8'h53;
        7'h42: init_est <= 8'h51;
        7'h43: init_est <= 8'h50;
        7'h44: init_est <= 8'h4e;
        7'h45: init_est <= 8'h4c;
        7'h46: init_est <= 8'h4b;
        7'h47: init_est <= 8'h49;
        7'h48: init_est <= 8'h47;
        7'h49: init_est <= 8'h46;
        7'h4a: init_est <= 8'h44;
        7'h4b: init_est <= 8'h43;
        7'h4c: init_est <= 8'h41;
        7'h4d: init_est <= 8'h3f;
        7'h4e: init_est <= 8'h3e;
        7'h4f: init_est <= 8'h3c;
        7'h50: init_est <= 8'h3b;
        7'h51: init_est <= 8'h39;
        7'h52: init_est <= 8'h38;
        7'h53: init_est <= 8'h36;
        7'h54: init_est <= 8'h35;
        7'h55: init_est <= 8'h33;
        7'h56: init_est <= 8'h32;
        7'h57: init_est <= 8'h31;
        7'h58: init_est <= 8'h2f;
        7'h59: init_est <= 8'h2e;
        7'h5a: init_est <= 8'h2c;
        7'h5b: init_est <= 8'h2b;
        7'h5c: init_est <= 8'h2a;
        7'h5d: init_est <= 8'h28;
        7'h5e: init_est <= 8'h27;
        7'h5f: init_est <= 8'h26;
        7'h60: init_est <= 8'h24;
        7'h61: init_est <= 8'h23;
        7'h62: init_est <= 8'h22;
        7'h63: init_est <= 8'h21;
        7'h64: init_est <= 8'h1f;
        7'h65: init_est <= 8'h1e;
        7'h66: init_est <= 8'h1d;
        7'h67: init_est <= 8'h1c;
        7'h68: init_est <= 8'h1a;
        7'h69: init_est <= 8'h19;
        7'h6a: init_est <= 8'h18;
        7'h6b: init_est <= 8'h17;
        7'h6c: init_est <= 8'h16;
        7'h6d: init_est <= 8'h14;
        7'h6e: init_est <= 8'h13;
        7'h6f: init_est <= 8'h12;
        7'h70: init_est <= 8'h11;
        7'h71: init_est <= 8'h10;
        7'h72: init_est <= 8'h0f;
        7'h73: init_est <= 8'h0e;
        7'h74: init_est <= 8'h0d;
        7'h75: init_est <= 8'h0b;
        7'h76: init_est <= 8'h0a;
        7'h77: init_est <= 8'h09;
        7'h78: init_est <= 8'h08;
        7'h79: init_est <= 8'h07;
        7'h7a: init_est <= 8'h06;
        7'h7b: init_est <= 8'h05;
        7'h7c: init_est <= 8'h04;
        7'h7d: init_est <= 8'h03;
        7'h7e: init_est <= 8'h02;
        7'h7f: init_est <= 8'h01;
      endcase
   end
endmodule
module flt_recip_iter
   (
   input	 clk,
   input [7:0]	 X0,
   input [31:0]	 denom,
   output reg [31:0] recip
   );
   reg		 sign;
   reg [30:23]	 exp;
   reg [22:0]	 B;
   wire [24:0]	 round;
   reg  [32:0]	 mult1;
   wire [32:8]	 round_mult1;
   reg  [34:0]	 mult2;
   reg  [41:0]	 mult3;
   wire [25:0]	 round_mult3;
   reg  [43:0]	 mult4;
   wire [24:0]	 sub1;
   wire [25:0]	 sub2;
   reg		 sign1, sign1a, sign2, sign3;
   reg [30:23]	 exp1, exp1a, exp2, exp3;
   reg [7:0]	 X0_reg;
   wire [24:0]	 pipe1;
   reg [17:0]	 X1_reg;
   reg [25:0]	 pipe2;
   reg [22:0]	 B1;
   reg [22:0]	 B1a;
   wire [30:23]	 exp_after_norm;
   reg [23:0]	 round_after_norm;
   always @(posedge clk) begin
   	sign <= denom[31];
   	exp  <= denom[30:23];
   	B    <= denom[22:0];
   end
   always @(posedge clk) begin
   	 mult1  <= ({1'b1,B} * {1'b1,X0});
	 X0_reg <= X0;
	 sign1  <= sign;
	 exp1   <= 9'hFE - exp;
	 B1     <= B;
   end
   assign round_mult1 = mult1[32:8] + mult1[7];
   assign pipe1 =  ~round_mult1 + 1; 
   always @(posedge clk) begin
	 mult2  <= (pipe1 * {1'b1,X0_reg});
	 exp1a  <= exp1;
	 sign1a <= sign1;
	 B1a    <= B1;
   end
   always @(posedge clk) begin
   	 mult3 <= ({1'b1,B1a} * mult2[33:16]);
	 sign2 <= sign1a;
	 exp2 <= exp1a;
	 X1_reg <= mult2[33:16];
   end
   assign sub2 = ~(mult3[40:15] + mult3[14]) + 1; 
   always @(posedge clk) begin
	 sign3 <= sign2;
	 exp3  <= exp2;
   	 mult4 <= (X1_reg * sub2);
   end
   assign round = mult4[41:18] + mult4[17];
   assign exp_after_norm = exp3 - !round[24];
   always @(round) begin
      if (round[24]) begin 
	 round_after_norm <= round[24:1];
      end
      else begin           
	 round_after_norm <= round[23:0];
      end
   end
   always @(posedge clk) recip <= {sign2,exp_after_norm,round_after_norm[22:0]};
endmodule
`timescale 1 ps / 1 ps
module flt_recip
   (
   input	 clk,
   input [31:0]	 denom,
   output [31:0] recip
   );
   wire [7:0]	 lutv;
   flt_recip_rom u_flt_recip_rom
   	(
	.clk		(clk),
	.index		(denom[22:16]),
	.init_est	(lutv)
	);
   flt_recip_iter u_flt_recip_iter
      (
       .clk     (clk),
       .X0         (lutv),
       .denom      (denom),
       .recip      (recip)
       );
endmodule
module flt_recip_rom
  (
   input            clk,
   input      [6:0] index,
   output reg [7:0] init_est
   );
   always @(posedge clk) begin
      case (index) 
        7'h00: init_est <= 8'hff;
        7'h01: init_est <= 8'hfb;
        7'h02: init_est <= 8'hf7;
        7'h03: init_est <= 8'hf3;
        7'h04: init_est <= 8'hef;
        7'h05: init_est <= 8'heb;
        7'h06: init_est <= 8'he8;
        7'h07: init_est <= 8'he4;
        7'h08: init_est <= 8'he1;
        7'h09: init_est <= 8'hdd;
        7'h0a: init_est <= 8'hda;
        7'h0b: init_est <= 8'hd6;
        7'h0c: init_est <= 8'hd3;
        7'h0d: init_est <= 8'hd0;
        7'h0e: init_est <= 8'hcc;
        7'h0f: init_est <= 8'hc9;
        7'h10: init_est <= 8'hc6;
        7'h11: init_est <= 8'hc3;
        7'h12: init_est <= 8'hc0;
        7'h13: init_est <= 8'hbd;
        7'h14: init_est <= 8'hba;
        7'h15: init_est <= 8'hb7;
        7'h16: init_est <= 8'hb4;
        7'h17: init_est <= 8'hb1;
        7'h18: init_est <= 8'hae;
        7'h19: init_est <= 8'hab;
        7'h1a: init_est <= 8'ha9;
        7'h1b: init_est <= 8'ha6;
        7'h1c: init_est <= 8'ha3;
        7'h1d: init_est <= 8'ha1;
        7'h1e: init_est <= 8'h9e;
        7'h1f: init_est <= 8'h9b;
        7'h20: init_est <= 8'h99;
        7'h21: init_est <= 8'h96;
        7'h22: init_est <= 8'h94;
        7'h23: init_est <= 8'h91;
        7'h24: init_est <= 8'h8f;
        7'h25: init_est <= 8'h8c;
        7'h26: init_est <= 8'h8a;
        7'h27: init_est <= 8'h88;
        7'h28: init_est <= 8'h85;
        7'h29: init_est <= 8'h83;
        7'h2a: init_est <= 8'h81;
        7'h2b: init_est <= 8'h7f;
        7'h2c: init_est <= 8'h7c;
        7'h2d: init_est <= 8'h7a;
        7'h2e: init_est <= 8'h78;
        7'h2f: init_est <= 8'h76;
        7'h30: init_est <= 8'h74;
        7'h31: init_est <= 8'h72;
        7'h32: init_est <= 8'h70;
        7'h33: init_est <= 8'h6e;
        7'h34: init_est <= 8'h6c;
        7'h35: init_est <= 8'h6a;
        7'h36: init_est <= 8'h68;
        7'h37: init_est <= 8'h66;
        7'h38: init_est <= 8'h64;
        7'h39: init_est <= 8'h62;
        7'h3a: init_est <= 8'h60;
        7'h3b: init_est <= 8'h5e;
        7'h3c: init_est <= 8'h5c;
        7'h3d: init_est <= 8'h5a;
        7'h3e: init_est <= 8'h59;
        7'h3f: init_est <= 8'h57;
        7'h40: init_est <= 8'h55;
        7'h41: init_est <= 8'h53;
        7'h42: init_est <= 8'h51;
        7'h43: init_est <= 8'h50;
        7'h44: init_est <= 8'h4e;
        7'h45: init_est <= 8'h4c;
        7'h46: init_est <= 8'h4b;
        7'h47: init_est <= 8'h49;
        7'h48: init_est <= 8'h47;
        7'h49: init_est <= 8'h46;
        7'h4a: init_est <= 8'h44;
        7'h4b: init_est <= 8'h43;
        7'h4c: init_est <= 8'h41;
        7'h4d: init_est <= 8'h3f;
        7'h4e: init_est <= 8'h3e;
        7'h4f: init_est <= 8'h3c;
        7'h50: init_est <= 8'h3b;
        7'h51: init_est <= 8'h39;
        7'h52: init_est <= 8'h38;
        7'h53: init_est <= 8'h36;
        7'h54: init_est <= 8'h35;
        7'h55: init_est <= 8'h33;
        7'h56: init_est <= 8'h32;
        7'h57: init_est <= 8'h31;
        7'h58: init_est <= 8'h2f;
        7'h59: init_est <= 8'h2e;
        7'h5a: init_est <= 8'h2c;
        7'h5b: init_est <= 8'h2b;
        7'h5c: init_est <= 8'h2a;
        7'h5d: init_est <= 8'h28;
        7'h5e: init_est <= 8'h27;
        7'h5f: init_est <= 8'h26;
        7'h60: init_est <= 8'h24;
        7'h61: init_est <= 8'h23;
        7'h62: init_est <= 8'h22;
        7'h63: init_est <= 8'h21;
        7'h64: init_est <= 8'h1f;
        7'h65: init_est <= 8'h1e;
        7'h66: init_est <= 8'h1d;
        7'h67: init_est <= 8'h1c;
        7'h68: init_est <= 8'h1a;
        7'h69: init_est <= 8'h19;
        7'h6a: init_est <= 8'h18;
        7'h6b: init_est <= 8'h17;
        7'h6c: init_est <= 8'h16;
        7'h6d: init_est <= 8'h14;
        7'h6e: init_est <= 8'h13;
        7'h6f: init_est <= 8'h12;
        7'h70: init_est <= 8'h11;
        7'h71: init_est <= 8'h10;
        7'h72: init_est <= 8'h0f;
        7'h73: init_est <= 8'h0e;
        7'h74: init_est <= 8'h0d;
        7'h75: init_est <= 8'h0b;
        7'h76: init_est <= 8'h0a;
        7'h77: init_est <= 8'h09;
        7'h78: init_est <= 8'h08;
        7'h79: init_est <= 8'h07;
        7'h7a: init_est <= 8'h06;
        7'h7b: init_est <= 8'h05;
        7'h7c: init_est <= 8'h04;
        7'h7d: init_est <= 8'h03;
        7'h7e: init_est <= 8'h02;
        7'h7f: init_est <= 8'h01;
      endcase
   end
endmodule
module flt_recip_iter
   (
   input	 clk,
   input [7:0]	 X0,
   input [31:0]	 denom,
   output reg [31:0] recip
   );
   reg		 sign;
   reg [30:23]	 exp;
   reg [22:0]	 B;
   wire [24:0]	 round;
   reg  [32:0]	 mult1;
   wire [32:8]	 round_mult1;
   reg  [34:0]	 mult2;
   reg  [41:0]	 mult3;
   wire [25:0]	 round_mult3;
   reg  [43:0]	 mult4;
   wire [24:0]	 sub1;
   wire [25:0]	 sub2;
   reg		 sign1, sign1a, sign2, sign3;
   reg [30:23]	 exp1, exp1a, exp2, exp3;
   reg [7:0]	 X0_reg;
   wire [24:0]	 pipe1;
   reg [17:0]	 X1_reg;
   reg [25:0]	 pipe2;
   reg [22:0]	 B1;
   reg [22:0]	 B1a;
   wire [30:23]	 exp_after_norm;
   reg [23:0]	 round_after_norm;
   always @(posedge clk) begin
   	sign <= denom[31];
   	exp  <= denom[30:23];
   	B    <= denom[22:0];
   end
   always @(posedge clk) begin
   	 mult1  <= ({1'b1,B} * {1'b1,X0});
	 X0_reg <= X0;
	 sign1  <= sign;
	 exp1   <= 9'hFE - exp;
	 B1     <= B;
   end
   assign round_mult1 = mult1[32:8] + mult1[7];
   assign pipe1 =  ~round_mult1 + 1; 
   always @(posedge clk) begin
	 mult2  <= (pipe1 * {1'b1,X0_reg});
	 exp1a  <= exp1;
	 sign1a <= sign1;
	 B1a    <= B1;
   end
   always @(posedge clk) begin
   	 mult3 <= ({1'b1,B1a} * mult2[33:16]);
	 sign2 <= sign1a;
	 exp2 <= exp1a;
	 X1_reg <= mult2[33:16];
   end
   assign sub2 = ~(mult3[40:15] + mult3[14]) + 1; 
   always @(posedge clk) begin
	 sign3 <= sign2;
	 exp3  <= exp2;
   	 mult4 <= (X1_reg * sub2);
   end
   assign round = mult4[41:18] + mult4[17];
   assign exp_after_norm = exp3 - !round[24];
   always @(round) begin
      if (round[24]) begin 
	 round_after_norm <= round[24:1];
      end
      else begin           
	 round_after_norm <= round[23:0];
      end
   end
   always @(posedge clk) recip <= {sign2,exp_after_norm,round_after_norm[22:0]};
endmodule
