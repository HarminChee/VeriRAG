///////////////////////////////////////////////////////////////////////////////
//
// 6.111 FPGA Labkit -- Hex display driver
//
// File:   display_16hex.v
// Date:   24-Sep-05
//
// Created: April 27, 2004
// Author: Nathan Ickes
//
// 24-Sep-05 Ike: updated to use new reset-once state machine, remove clear
// 28-Nov-06 CJT: fixed race condition between CE and RS (thanks Javier!)
//
// This verilog module drives the labkit hex dot matrix displays, and puts
// up 16 hexadecimal digits (8 bytes).  These are passed to the module
// through a 64 bit wire (""data""), asynchronously.  
//
///////////////////////////////////////////////////////////////////////////////

module display_16hex (reset, clock_27mhz, data, 
		disp_blank, disp_clock, disp_rs, disp_ce_b,
		disp_reset_b, disp_data_out,
		// DFT inputs
		scan_en, test_clk
		);

   input reset, clock_27mhz;    // clock and reset (active high reset)
   input [63:0] data;		// 16 hex nibbles to display
   input scan_en, test_clk; // DFT inputs

   output disp_blank, disp_data_out, disp_rs, disp_ce_b, 
	  disp_reset_b;
   output disp_clock; // Keep functional clock output separate
   
   reg disp_data_out, disp_rs, disp_ce_b, disp_reset_b;
   
   ////////////////////////////////////////////////////////////////////////////
   //
   // Display Clock Generation (Functional)
   //
   // Generate a 500kHz clock for driving the displays.
   // This clock itself is generated correctly from primary inputs.
   //
   ////////////////////////////////////////////////////////////////////////////
   
   reg [4:0] count;
   reg [7:0] reset_count;
   reg clock; // Internal 500kHz functional clock
   wire dreset; // Internal reset signal

   // Counter and functional clock generation
   always @(posedge clock_27mhz)
     begin
	if (reset)
	  begin
	     count <= 0; // Use non-blocking assignment
	     clock <= 0; // Use non-blocking assignment
	  end
	else if (count == 26)
	  begin
	     clock <= ~clock; // Use non-blocking assignment
	     count <= 5'h00; // Use non-blocking assignment
	  end
	else
	  count <= count + 1; // Use non-blocking assignment
     end
   
   // Internal reset generation (functional)
   always @(posedge clock_27mhz)
     if (reset)
       reset_count <= 100;
     else
       reset_count <= (reset_count==0) ? 0 : reset_count-1;

   assign dreset = (reset_count != 0); // Functional reset condition

   // Output the functional display clock
   assign disp_clock = ~clock;

   ////////////////////////////////////////////////////////////////////////////
   // DFT Clock Muxing
   ////////////////////////////////////////////////////////////////////////////
   wire fsm_clk;
   // Select test_clk during scan mode, otherwise use functional clock
   assign fsm_clk = scan_en ? test_clk : clock;

   ////////////////////////////////////////////////////////////////////////////
   //
   // Display State Machine
   // Clocked by fsm_clk, Synchronous Reset using primary 'reset'
   //
   ////////////////////////////////////////////////////////////////////////////
      
   reg [7:0] state;		// FSM state
   reg [9:0] dot_index;		// index to current dot being clocked out
   reg [31:0] control;		// control register
   reg [3:0] char_index;	// index of current character
   reg [39:0] dots;		// dots for a single digit (combinational)
   reg [3:0] nibble;		// hex nibble of current character (combinational)
   
   assign disp_blank = 1'b0; // low <= not blanked
   
   // FSM logic with synchronous reset
   always @(posedge fsm_clk) // Use muxed clock
     if (reset) // Use primary input 'reset' for synchronous reset
       begin
          // Reset state and internal registers
	  state <= 8'h00;
	  dot_index <= 0;
	  control <= 32'h7F7F7F7F;
	  char_index <= 15; // Initialize to known state
          // Reset output registers controlled by FSM
	  disp_data_out <= 1'b0; 
	  disp_rs <= 1'b0; // Match initial state 0 intention
	  disp_ce_b <= 1'b1; // Match initial state 0 intention
	  disp_reset_b <= 1'b0; // Assert display reset during primary reset	     
       end
     else // Normal operation (state transitions)
       casex (state)
	 8'h00: // Initial actions after reset deasserts
	   begin
	      // Keep display reset asserted, prepare for end reset
	      disp_data_out <= 1'b0; 
	      disp_rs <= 1'b0; 
	      disp_ce_b <= 1'b1;
	      disp_reset_b <= 1'b0;	     
	      dot_index <= 0;
	      state <= state+1;
	   end
	 
	 8'h01: // End display reset
	   begin
	      disp_reset_b <= 1'b1; // Deassert display reset
	      state <= state+1;
	   end
	 
	 8'h02: // Initialize dot register
	   begin
	      disp_ce_b <= 1'b0;
	      disp_data_out <= 1'b0; 
	      if (dot_index == 639)
		state <= state+1;
	      else
		dot_index <= dot_index+1;
	   end
	 
	 8'h03: // Latch dot data / Prepare control register init
	   begin
	      disp_ce_b <= 1'b1;
	      dot_index <= 31;		// re-purpose to init ctrl reg
	      disp_rs <= 1'b1; // Select the control register
	      state <= state+1;
	   end
	 
	 8'h04: // Setup the control register
	   begin
	      disp_ce_b <= 1'b0;
	      disp_data_out <= control[31]; // Output MSB of control
	      control <= {control[30:0], 1'b0};	// shift left (functional intent)
	      if (dot_index == 0)
		state <= state+1;
	      else
		dot_index <= dot_index-1;
	   end
	  
	 8'h05: // Latch control register / Prepare dot data load
	   begin
	      disp_ce_b <= 1'b1;
	      dot_index <= 39;		// init for single char dots (40 bits)
	      char_index <= 15;		// start with MS char
	      state <= state+1;
	      disp_rs <= 1'b0;	 	// Select the dot register
	   end
	 
	 8'h06: // Load user dot data
	   begin
	      disp_ce_b <= 1'b0;
	      disp_data_out <= dots[dot_index]; // Output dot data from msb
	      if (dot_index == 0) // Finished one character
	        if (char_index == 0) // Finished all characters
	          state <= 5; // Loop back to latch state (original behavior)
		else // More characters left
		begin
		  char_index <= char_index - 1;	// goto next char
		  dot_index <= 39; // Reset dot index for next char
		  // state remains 6
		end
	      else // More dots for current character
		dot_index <= dot_index-1;	// else loop thru all dots 
		// state remains 6
	   end
         default: state <= 8'h00; // Go to known state for undefined states

       endcase

   // Combinational logic for selecting nibble based on char_index
   always @ (*) // Use inferred sensitivity list
     case (char_index)
       4'h0: 	 	nibble = data[3:0]; // Use blocking assignment
       4'h1: 	 	nibble = data[7:4];
       4'h2: 	 	nibble = data[11:8];
       4'h3: 	 	nibble = data[15:12];
       4'h4: 	 	nibble = data[19:16];
       4'h5: 	 	nibble = data[23:20];
       4'h6: 	 	nibble = data[27:24];
       4'h7: 	 	nibble = data[31:28];
       4'h8: 	 	nibble = data[35:32];
       4'h9: 	 	nibble = data[39:36];
       4'hA: 	 	nibble = data[43:40];
       4'hB: 	 	nibble = data[47:44];
       4'hC: 	 	nibble = data[51:48];
       4'hD: 	 	nibble = data[55:52];
       4'hE: 	 	nibble = data[59:56];
       4'hF: 	 	nibble = data[63:60];
       default:      nibble = 4'h0; // Default assignment
     endcase
      
   // Combinational logic for generating dot pattern from nibble
   always @(*) // Use inferred sensitivity list
     case (nibble)
       4'h0: dots = 40'b00111110_01010001_01001001_01000101_00111110; // Use blocking assignment
       4'h1: dots = 40'b00000000_01000010_01111111_01000000_00000000;
       4'h2: dots = 40'b01100010_01010001_01001001_01001001_01000110;