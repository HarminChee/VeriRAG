module mult_27x27
  (input wire clk,
   input wire [26:0] opa, opb,
   output reg [53:0] res);
   parameter LATENCY = 0; 
   wire                                     [26:0] multop_a;
   wire                                     [26:0] multop_b;
   assign multop_a = opa;
   assign multop_b = opb;
`define INSTANTIATED   
`ifdef INSTANTIATED
   wire [47:0] 					   p_low, p_high;
   reg [47:0] p_low_delay;
   wire [47:0] pcout_low;
   reg [47:0] c_in;
   reg 	      carryin;
   reg         dosub, dosub1;
   always @(posedge clk) begin
      dosub1 <= multop_a[2];
      dosub <= dosub1;
   end
   DSP48E1   
     #(.AREG(1),
       .ADREG(0), 
       .BREG(1),
       .ALUMODEREG(1),
       .CARRYINREG(1),
       .CARRYINSELREG(1),
       .CREG(1),
       .DREG(1),
       .INMODEREG(1),
       .MREG(1),
       .OPMODEREG(1),
       .PREG(1),
       .A_INPUT("DIRECT"),
       .B_INPUT("DIRECT"),
       .USE_DPORT("TRUE"),
       .USE_MULT("MULTIPLY"),
       .USE_SIMD("ONE48"))
   low(
       .ACOUT           (),
       .BCOUT           (),
       .CARRYCASCOUT    (),
       .CARRYOUT        (),
       .MULTSIGNOUT     (),
       .OVERFLOW        (),
       .P               (p_low),
       .PATTERNBDETECT  (),
       .PATTERNDETECT   (),
       .PCOUT           (pcout_low),
       .UNDERFLOW       (),
       .A               ({6'h0, multop_a[26:3]}),
       .ACIN            (),
       .ALUMODE         ({3'b000, dosub1}),
       .B               ({1'b0, multop_b[16:0]}),
       .BCIN            (),
       .C               (c_in),
       .CARRYCASCIN     (),
       .CARRYIN         (carryin), 
       .CARRYINSEL      (3'h0),
       .CEA1            (1'b1),
       .CEA2            (1'b1),
       .CEAD            (1'b1),
       .CEALUMODE       (1'b1),
       .CEB1            (1'b1),
       .CEB2            (1'b1),
       .CEC             (1'b1),
       .CECARRYIN       (1'b1),
       .CECTRL          (1'b1),
       .CED             (1'b1),
       .CEINMODE        (1'b1),
       .CEM             (1'b1),
       .CEP             (1'b1),
       .CLK             (clk),
       .D               ({24'h0, multop_a[2]}),
       .INMODE          (5'b00101),
       .MULTSIGNIN      (1'b0),
       .OPMODE          (7'b0110101), 
       .PCIN            (48'b0),
       .RSTA            (1'b0),
       .RSTALLCARRYIN   (1'b0),
       .RSTALUMODE      (1'b0),
       .RSTB            (1'b0),
       .RSTC            (1'b0),
       .RSTCTRL (1'b0),
       .RSTD            (1'b0),
       .RSTINMODE       (1'b0),
       .RSTM            (1'b0),
       .RSTP            (1'b0));
   reg [28:0] multfix;
   reg [28:0] add1, add2;
   always @* begin
      case(multop_a[2:0])
	3'b000: begin add1 <= 0;            add2 <= 0; end
	3'b001: begin add1 <= multop_b;     add2 <= 0; end
	3'b010: begin add1 <= 0;            add2 <= multop_b << 1; end
	3'b011: begin add1 <= multop_b;     add2 <= multop_b << 1; end
	3'b100: begin add1 <= multop_b <<1; add2 <= multop_b << 1; end
	3'b101: begin add1 <= multop_b;     add2 <= multop_b << 1; end
	3'b110: begin add1 <= 0;            add2 <= multop_b << 1; end
	3'b111: begin add1 <= multop_b;     add2 <= 0; end
      endcase
      multfix = add1 + add2;
   end
   always @(posedge clk) begin
      c_in <= multfix >> 3; 
      if(multop_a[2] == 0) begin
	 carryin <= 0;
      end else begin
	 carryin <= 0;
	 if(~multfix[2:0] == 3'b111) begin
	    carryin <= 1;
	 end
      end
   end
   reg [2:0] lsbresult1, lsbresult2, lsbresult3, lsbresult4;
   always @(posedge clk) begin
      lsbresult1 <= multop_a[2:0]*multop_b[2:0];
      lsbresult2 <= lsbresult1;
      lsbresult3 <= lsbresult2;
      lsbresult4 <= lsbresult3;
      p_low_delay <= p_low;
   end
   DSP48E1   
     #(.AREG(2),
       .ADREG(0), 
       .BREG(2),
       .ALUMODEREG(1),
       .CARRYINREG(1),
       .CARRYINSELREG(1),
       .CREG(1),
       .DREG(1),
       .INMODEREG(1),
       .MREG(1),
       .OPMODEREG(1),
       .PREG(1),
       .A_INPUT("DIRECT"),
       .B_INPUT("DIRECT"),
       .USE_DPORT("TRUE"),
       .USE_MULT("MULTIPLY"),
       .USE_SIMD("ONE48"))
   high(
       .ACOUT           (),
       .BCOUT           (),
       .CARRYCASCOUT    (),
       .CARRYOUT        (),
       .MULTSIGNOUT     (),
       .OVERFLOW        (),
       .P               (p_high),
       .PATTERNBDETECT  (),
       .PATTERNDETECT   (),
       .PCOUT           (),
       .UNDERFLOW       (),
       .A               ({6'h0, multop_a[26:3]}),
       .ACIN            (),
       .ALUMODE         ({4'b0000}),
       .B               ({8'b0, multop_b[26:17]}),
       .BCIN            (),
       .C               (48'h0),
       .CARRYCASCIN     (),
       .CARRYIN         (1'b0),
       .CARRYINSEL      (3'h0),
       .CEA1            (1'b1),
       .CEA2            (1'b1),
       .CEAD            (1'b1),
       .CEALUMODE       (1'b1),
       .CEB1            (1'b1),
       .CEB2            (1'b1),
       .CEC             (1'b1),
       .CECARRYIN       (1'b1),
       .CECTRL          (1'b1),
       .CED             (1'b1),
       .CEINMODE        (1'b1),
       .CEM             (1'b1),
       .CEP             (1'b1),
       .CLK             (clk),
       .D               ({24'h0, dosub1}),
       .INMODE          (5'b00100),
       .MULTSIGNIN      (1'b0),
       .OPMODE          (7'b1010101), 
       .PCIN            (pcout_low),
       .RSTA            (1'b0),
       .RSTALLCARRYIN   (1'b0),
       .RSTALUMODE      (1'b0),
       .RSTB            (1'b0),
       .RSTC            (1'b0),
       .RSTCTRL (1'b0),
       .RSTD            (1'b0),
       .RSTINMODE       (1'b0),
       .RSTM            (1'b0),
       .RSTP            (1'b0));
   always @* begin
      res  = {p_high, p_low_delay[16:0], lsbresult4};
   end
`endif   
endmodule
