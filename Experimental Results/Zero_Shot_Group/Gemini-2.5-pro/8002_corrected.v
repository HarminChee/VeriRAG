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

module display_16hex (
    input             reset,
    input             clock_27mhz,    // clock and reset (active high reset)
    input      [63:0] data,           // 16 hex nibbles to display

    output            disp_blank,
    output            disp_clock,
    output reg        disp_data_out,
    output reg        disp_rs,
    output reg        disp_ce_b,
    output reg        disp_reset_b
);

   ////////////////////////////////////////////////////////////////////////////
   //
   // Display Clock
   //
   // Generate a 500kHz clock for driving the displays.
   //
   ////////////////////////////////////////////////////////////////////////////

   reg [4:0] count;
   reg [7:0] reset_count;
   reg       clock;
   wire      dreset;

   always @(posedge clock_27mhz) begin
      if (reset) begin
         count <= 5'b0; // Use non-blocking assignment for sequential logic
         clock <= 1'b0; // Use non-blocking assignment for sequential logic
      end else if (count == 26) begin
         clock <= ~clock; // Use non-blocking assignment for sequential logic
         count <= 5'h00; // Use non-blocking assignment for sequential logic
      end else begin
         count <= count + 1; // Use non-blocking assignment for sequential logic
      end
   end

   always @(posedge clock_27mhz) begin
     if (reset)
       reset_count <= 100;
     else
       reset_count <= (reset_count == 0) ? 0 : reset_count - 1;
   end

   assign dreset = (reset_count != 0);

   assign disp_clock = ~clock;

   ////////////////////////////////////////////////////////////////////////////
   //
   // Display State Machine
   //
   ////////////////////////////////////////////////////////////////////////////

   reg [7:0]  state;         // FSM state
   reg [9:0]  dot_index;     // index to current dot being clocked out
   reg [31:0] control;       // control register
   reg [3:0]  char_index;    // index of current character
   reg [39:0] dots;          // dots for a single digit
   reg [3:0]  nibble;        // hex nibble of current character

   assign disp_blank = 1'b0; // low <= not blanked

   // State Machine Logic
   always @(posedge clock) begin
     if (dreset) begin
        state        <= 8'h00;
        dot_index    <= 10'b0;
        control      <= 32'h7F7F7F7F;
        disp_data_out <= 1'b0;
        disp_rs      <= 1'b0;
        disp_ce_b    <= 1'b1;
        disp_reset_b <= 1'b0; // Assert reset during dreset
        char_index   <= 4'b0;
     end else begin
       casex (state)
         8'h00: begin
            // Reset displays (Assert reset low)
            disp_data_out <= 1'b0;
            disp_rs      <= 1'b0; // Select dot register
            disp_ce_b    <= 1'b1; // Deassert CE
            disp_reset_b <= 1'b0; // Assert reset
            dot_index    <= 10'b0;
            state        <= state + 1;
         end

         8'h01: begin
            // End reset (Deassert reset high)
            disp_reset_b <= 1'b1;
            state        <= state + 1;
         end

         8'h02: begin
            // Initialize dot register (set all dots to zero)
            disp_rs      <= 1'b0; // Keep dot register selected
            disp_ce_b    <= 1'b0; // Assert CE
            disp_data_out <= 1'b0; // Clock out zeros
            if (dot_index == 639) begin
               state <= state + 1;
               disp_ce_b <= 1'b1; // Deassert CE before changing RS
            end else begin
               dot_index <= dot_index + 1;
            end
         end

         8'h03: begin
            // Prepare to load control register
            disp_ce_b    <= 1'b1; // Ensure CE is high before changing RS
            dot_index    <= 31;   // Re-purpose to init ctrl reg index
            disp_rs      <= 1'b1; // Select the control register
            state        <= state + 1;
         end

         8'h04: begin
            // Setup the control register
            disp_ce_b    <= 1'b0; // Assert CE
            disp_data_out <= control[31];
            control      <= {control[30:0], control[31]}; // Rotate (or shift as original) - keeping original shift
            // control      <= {control[30:0], 1'b0}; // Original shift left
            if (dot_index == 0) begin
               state <= state + 1;
               disp_ce_b <= 1'b1; // Deassert CE before changing RS
            end else begin
               dot_index <= dot_index - 1;
            end
         end

         8'h05: begin
            // Prepare to load dot data
            disp_ce_b    <= 1'b1; // Ensure CE is high before changing RS
            dot_index    <= 39;   // Init dot index for single char
            char_index   <= 15;   // Start with MS char
            disp_rs      <= 1'b0; // Select the dot register
            state        <= state + 1;
         end

         8'h06: begin
            // Load the user's dot data into the dot reg, char by char
            disp_ce_b    <= 1'b0; // Assert CE
            disp_data_out <= dots[dot_index]; // Output dot data from msb
            if (dot_index == 0) begin
               if (char_index == 0) begin
                  // Finished loading all characters, latch data and restart cycle
                  disp_ce_b <= 1'b1; // Latch data for the last character
                  state     <= 8'h05; // Go back to prepare for next refresh cycle
               end else begin
                  // Finished current char, move to next char
                  char_index <= char_index - 1; // Goto next char (less significant)
                  dot_index  <= 39;             // Reset dot index for next char
                  // Keep disp_ce_b low for continuous clocking? Or pulse high?
                  // Assuming continuous clocking is fine as RS is stable.
               end
            end else begin
               // Continue clocking dots for the current character
               dot_index <= dot_index - 1;
            end
         end
         default: state <= 8'h00; // Go to known state on error

       endcase
     end
   end

   // Combinational logic to select nibble based on char_index
   always @ (*) begin // Use Verilog-2001 implicit sensitivity list
     case (char_index)
       4'h0:   nibble = data[3:0];
       4'h1:   nibble = data[7:4];
       4'h2:   nibble = data[11:8];
       4'h3:   nibble = data[15:12];
       4'h4:   nibble = data[19:16];
       4'h5:   nibble = data[23:20];
       4'h6:   nibble = data[27:24];
       4'h7:   nibble = data[31:28];
       4'h8:   nibble = data[35:32];
       4'h9:   nibble = data[39:36];
       4'hA:   nibble = data[43:40];
       4'hB:   nibble = data[47:44];
       4'hC:   nibble = data[51:48];
       4'hD:   nibble = data[55:52];
       4'hE:   nibble = data[59:56];
       4'hF:   nibble = data[63:60];
       default: nibble = 4'h0; // Default case
     endcase
   end

   // Combinational logic for character ROM (Hex digit to dot pattern)
   always @ (*) begin // Use Verilog-2001 implicit sensitivity list
     case (nibble)
       4'h0: dots = 40'b00111110_01010001_01001001_01000101_00111110; // 0
       4'h1: dots = 40'b00000000_01000010_01111111_01000000_00000000; // 1
       4'h2: dots = 40'b01100010_01010001_01001001_01001001_01000110; // 2
       4'h3: dots = 40'b00100010_01000001_01001001_01001001_00110110; // 3
       4'h4: dots = 40'b00011000_00010100_00010010_01111111_00010000; // 4
       4'h5: dots = 40'b00100111_01000101_01000101_01000101_00111001; // 5
       4'h6: dots = 40'b00111100_01001010_01001001_01001001_00110000; // 6
       4'h7: dots = 40'b00000001_01110001_00001001_00000101_00000011; // 7
       4'h8: dots = 40'b00110110_01001001_01001001_01001001_00110110; // 8
       4'h9: dots = 40'b00000110_01001001_01001001_00101001_00011110; // 9
       4'hA: dots = 40'b01111110_00001001_00001001_00001001_01111110; // A
       4'hB: dots = 40'b01111111_01001001_01001001_01001001_00110110; // B
       4'hC: dots = 40'b00111110_01000001_01000001_01000001_00100010; // C
       4'hD: dots = 40'b01111111_01000001_01000001_01000001_00111110; // D
       4'hE: dots = 40'b01111111_01001001_01001001_01001001_01000001; // E
       4'hF: dots = 40'b01111111_00001001_00001001_00001001_00000001; // F
       default: dots = 40'b00111110_01010001_01001001_01000101_00111110; // Default to 0
     endcase
   end

endmodule