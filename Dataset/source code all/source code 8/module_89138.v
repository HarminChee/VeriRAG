module one_wire_io (
  CLK, DDIR, DOUT, DQ_CONTROL, MR, DIN, DQ_IN, DATA_IN, DATA_OUT, 
  DQ0_T, DQ1_T, DQ2_T, DQ3_T, DQ4_T, DQ5_T, DQ6_T, DQ7_T, 
  DQ0_O, DQ1_O, DQ2_O, DQ3_O, DQ4_O, DQ5_O, DQ6_O, DQ7_O, 
  DQ0_I, DQ1_I, DQ2_I, DQ3_I, DQ4_I, DQ5_I, DQ6_I, DQ7_I, DQ_SEL);
  input        CLK;
  input        DDIR;
  input [7:0]  DOUT;
  input        DQ_CONTROL;
  input        MR;
  output [7:0] DIN;
  output       DQ_IN;
  input [7:0]  DATA_IN;
  output [7:0] DATA_OUT;
  output DQ0_T;
  output DQ1_T;
  output DQ2_T;
  output DQ3_T;
  output DQ4_T;
  output DQ5_T;
  output DQ6_T;
  output DQ7_T;
  output DQ0_O;
  output DQ1_O;
  output DQ2_O;
  output DQ3_O;
  output DQ4_O;
  output DQ5_O;
  output DQ6_O;
  output DQ7_O;
  input  DQ0_I;
  input  DQ1_I;
  input  DQ2_I;
  input  DQ3_I;
  input  DQ4_I;
  input  DQ5_I;
  input  DQ6_I;
  input  DQ7_I;
  input  [2:0] DQ_SEL;
  reg         DQ_IN;  
  assign DATA_OUT = DOUT;
  assign DIN      = DATA_IN;
  wire DQ_INTERNAL;
   assign DQ0_T    = (DQ_SEL [2:0] == 0) ? DQ_CONTROL : 1'b1;
   assign DQ1_T    = (DQ_SEL [2:0] == 1) ? DQ_CONTROL : 1'b1;
   assign DQ2_T    = (DQ_SEL [2:0] == 2) ? DQ_CONTROL : 1'b1;
   assign DQ3_T    = (DQ_SEL [2:0] == 3) ? DQ_CONTROL : 1'b1;
   assign DQ4_T    = (DQ_SEL [2:0] == 4) ? DQ_CONTROL : 1'b1;
   assign DQ5_T    = (DQ_SEL [2:0] == 5) ? DQ_CONTROL : 1'b1;
   assign DQ6_T    = (DQ_SEL [2:0] == 6) ? DQ_CONTROL : 1'b1;
   assign DQ7_T    = (DQ_SEL [2:0] == 7) ? DQ_CONTROL : 1'b1;
   assign DQ0_O  = 1'b0;
   assign DQ1_O  = 1'b0;
   assign DQ2_O  = 1'b0;
   assign DQ3_O  = 1'b0;
   assign DQ4_O  = 1'b0;
   assign DQ5_O  = 1'b0;
   assign DQ6_O  = 1'b0;
   assign DQ7_O  = 1'b0;
   assign DQ_INTERNAL = (DQ_SEL [2:0] == 0) & DQ0_I
                      | (DQ_SEL [2:0] == 1) & DQ1_I
                      | (DQ_SEL [2:0] == 2) & DQ2_I
                      | (DQ_SEL [2:0] == 3) & DQ3_I
                      | (DQ_SEL [2:0] == 4) & DQ4_I
                      | (DQ_SEL [2:0] == 5) & DQ5_I
                      | (DQ_SEL [2:0] == 6) & DQ6_I
                      | (DQ_SEL [2:0] == 7) & DQ7_I;
  always @(posedge MR or negedge CLK)
    if (MR)
      DQ_IN <= 1'b1;
    else
      DQ_IN <= DQ_INTERNAL;
endmodule 
