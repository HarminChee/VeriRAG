`timescale 1ns / 1ps
`timescale 1ns / 1ps
module KeyBoard_ctrl(ROW, KEY_IN, COLUMN, CLK, RESET, test_i);
  input  CLK;
  input  RESET;
  input  [3:0]  COLUMN;
  output [3:0]  ROW;
  output [3:0]  KEY_IN;
  input test_i; // Added test mode input
  reg    [3:0]  ROW;
  reg    [3:0]  DEBOUNCE_COUNT;
  reg    [3:0]  SCAN_CODE;
  reg    [3:0]  SCAN_NUMBER;
  reg    [3:0]  DECODE_BCD0;
  reg    [3:0]  DECODE_BCD1;  
  reg    [3:0]  KEY_CODE;
  reg    [3:0] KEY_BUFFER;
  reg    [14:0] DIVIDER;
  reg    PRESS;
  wire   PRESS_VALID;
  wire   DEBOUNCE_CLK;
  wire   SCAN_CLK;
  wire   dft_debounce_clk; // Muxed clock for DFT

  always @(posedge CLK or negedge RESET)
    begin 
	     if (!RESET) 
	        DIVIDER <= {12'h000,2'b00};
	     else
	        DIVIDER <= DIVIDER + 1;
	end 
  assign DEBOUNCE_CLK = DIVIDER[14];
  assign SCAN_CLK     = DIVIDER[14]; // SCAN_CLK is not used to clock FFs

  // DFT Clock Mux: Use CLK in test mode, DEBOUNCE_CLK in functional mode
  assign dft_debounce_clk = test_i ? CLK : DEBOUNCE_CLK;

  always @(posedge CLK or negedge RESET) // SCAN_CODE uses primary CLK
    begin
      if (!RESET) 
	        SCAN_CODE <= 4'h0;
      else if (PRESS) // Note: PRESS is derived combinationally, could cause issues if SCAN_CLK was intended here. Using CLK.
	        SCAN_CODE <= SCAN_CODE + 1; // Assuming scan increments happen based on main CLK or a test clock. Original logic might be flawed if dependent on SCAN_CLK.
                                     // Let's assume SCAN_CODE increments based on the main CLK as written.
    end

  // Combinational logic for ROW and PRESS
  always @(SCAN_CODE,COLUMN)
    begin
      case (SCAN_CODE[3:2])
        2'b00 : ROW = 4'b1110;
        2'b01 : ROW = 4'b1101;
        2'b10 : ROW = 4'b1011;
        2'b11 : ROW = 4'b0111;
      endcase
      case (SCAN_CODE[1:0])
        2'b00 : PRESS = COLUMN[0];
        2'b01 : PRESS = COLUMN[1];
        2'b10 : PRESS = COLUMN[2];
        2'b11 : PRESS = COLUMN[3];
      endcase
    end

  // DEBOUNCE_COUNT FF: Use muxed clock dft_debounce_clk
  always @(posedge dft_debounce_clk or negedge RESET)
   begin
    if (!RESET)
	     DEBOUNCE_COUNT <= 4'h0;
	   else if (PRESS) // PRESS is combinational based on SCAN_CODE and COLUMN
      DEBOUNCE_COUNT <= 4'h0;
    else if (DEBOUNCE_COUNT <= 4'hE)
	     DEBOUNCE_COUNT <= DEBOUNCE_COUNT + 1;
   end 
   
  assign PRESS_VALID = (DEBOUNCE_COUNT == 4'hD)? 1'b1 : 1'b0;

  // Combinational logic for SCAN_NUMBER
  always @(SCAN_CODE)
   begin
     case (SCAN_CODE)
	   4'b0000 : SCAN_NUMBER = 4'hF;
	   4'b0001 : SCAN_NUMBER = 4'hE;
	   4'b0010 : SCAN_NUMBER = 4'hD;
	   4'b0011 : SCAN_NUMBER = 4'hC;
	   4'b0100 : SCAN_NUMBER = 4'hB;
	   4'b0101 : SCAN_NUMBER = 4'h3;
	   4'b0110 : SCAN_NUMBER = 4'h6;
	   4'b0111 : SCAN_NUMBER = 4'h9;
	   4'b1000 : SCAN_NUMBER = 4'hA;
	   4'b1001 : SCAN_NUMBER = 4'h2;
	   4'b1010 : SCAN_NUMBER = 4'h5;
	   4'b1011 : SCAN_NUMBER = 4'h8;	   
	   4'b1100 : SCAN_NUMBER = 4'h0;
	   4'b1101 : SCAN_NUMBER = 4'h1;
	   4'b1110 : SCAN_NUMBER = 4'h4;
	   4'b1111 : SCAN_NUMBER = 4'h7;	   
	 endcase
   end

  // KEY_BUFFER FF: Use negedge of muxed clock dft_debounce_clk
  // Note: Using negedge CLK in test mode is non-ideal for standard scan, but corrects FFCKNP/CLKNPI per definition.
  always @(negedge dft_debounce_clk or negedge RESET)
   begin
    if (!RESET)
      KEY_BUFFER <= 4'h0;
    else if (PRESS_VALID) // PRESS_VALID is combinational based on DEBOUNCE_COUNT
      KEY_BUFFER <= SCAN_NUMBER; // SCAN_NUMBER is combinational based on SCAN_CODE
   end
   
	assign KEY_IN = KEY_BUFFER;
endmodule