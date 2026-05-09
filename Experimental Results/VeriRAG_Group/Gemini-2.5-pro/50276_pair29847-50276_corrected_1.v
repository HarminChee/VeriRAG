module MultiBootLoader
  (
   input       clock,          // Primary clock
   input       mode,
   input [3:0] id,
   // DFT input
   input       test_i,         // Test mode enable

   output      led1,
   output      led2,
   output      led3,
   output      ld1,
   output      ld2,
   output      ld3,
   output      ld4,
   output      ld5,
   output      ld6,
   output      ld7,
   output      ld8
   );

   // Internal signals for ICAP interface (combinational outputs)
   reg [15:0]  icap_din;
   reg         icap_ce;
   reg         icap_wr;

   // Flip-flops for ICAP interface inputs
   reg [15:0]  ff_icap_din_reversed;
   reg         ff_icap_ce;
   reg         ff_icap_wr;

   // Internal clock generation signals (registers)
   reg [1:0]   clk_internal = 2'b00; // Renamed from clk to avoid conflict, provide initial value

   // State machine registers
   parameter
     IDLE     = 5'd0,
     SYNC_H   = 5'd1,
     SYNC_L   = 5'd2,
     // CWD_H    = 3, // Unused
     // CWD_L    = 4, // Unused
     GEN1_H   = 5'd5,
     GEN1_L   = 5'd6,
     GEN2_H   = 5'd7,
     GEN2_L   = 5'd8,
     // GEN3_H   = 9, // Unused
     // GEN3_L   = 10, // Unused
     // GEN4_H   = 11, // Unused
     // GEN4_L   = 12, // Unused
     // GEN5_H   = 13, // Unused
     // GEN5_L   = 14, // Unused
     // NUL_H    = 15, // Unused
     // NUL_L    = 16, // Unused
     // MOD_H    = 17, // Unused
     // MOD_L    = 18, // Unused
     // HCO_H    = 19, // Unused
     // HCO_L    = 20, // Unused
     RBT_H    = 5'd21,
     RBT_L    = 5'd22,
     NOOP_0   = 5'd23,
     NOOP_1   = 5'd24,
     NOOP_2   = 5'd25,
     NOOP_3   = 5'd26;

   reg [4:0]   state = IDLE;
   reg [4:0]   next_state;


   // DFT Clock Muxing Logic
   wire icap_clk_muxed;
   wire state_ff_clk_muxed;

   // In test mode (test_i=1), use primary clock. In functional mode (test_i=0), use generated clocks.
   assign icap_clk_muxed   = test_i ? clock : clk_internal[0];
   assign state_ff_clk_muxed = test_i ? clock : clk_internal[1];

   // ICAP Instance
   // Ensure the ICAP primitive name matches the target library (e.g., ICAPE2 for 7-series)
   // Using ICAP_SPARTAN6 as specified in the original code
   ICAP_SPARTAN6 ICAP_SPARTAN6_inst
     (
      .BUSY      (), // Assuming BUSY and O are not needed for this logic
      .O         (),
      .CE        (ff_icap_ce),
      .CLK       (icap_clk_muxed), // Use muxed clock for ICAP
      .I         (ff_icap_din_reversed),
      .WRITE     (ff_icap_wr)
      );

   // Combinational logic for state machine next state and ICAP signals
   always @(*) // Use @(*) for combinational logic in SystemVerilog, or list all inputs for Verilog-2001
     begin: COMB
        // Default assignments
        next_state  = IDLE;
        icap_ce     = 1'b1; // Default inactive
        icap_wr     = 1'b1; // Default inactive
        icap_din    = 16'hFFFF; // Default value

        case (state)
          IDLE:
            begin
               // Simplified start condition: always start sequence
               next_state  = SYNC_H;
               icap_ce     = 1'b0; // Active
               icap_wr     = 1'b0; // Active
               icap_din    = 16'hAA99;
            end
          SYNC_H:
            begin
               next_state  = SYNC_L;
               icap_ce     = 1'b0;
               icap_wr     = 1'b0;
               icap_din    = 16'h5566;
            end
          SYNC_L:
            begin
               next_state  = GEN1_H;
               icap_ce     = 1'b0;
               icap_wr     = 1'b0;
               icap_din    = 16'h3261;
            end
          GEN1_H:
            begin
               next_state  = GEN1_L;
               icap_ce     = 1'b0;
               icap_wr     = 1'b0;
               case ({mode, id}) // Combined mode and id
                 5'b11110: icap_din    = 16'h8000;
                 5'b11101: icap_din    = 16'hC000;
                 5'b01101: icap_din    = 16'hC000;
                 5'b01110: icap_din    = 16'h0000;
                 5'b11100: icap_din    = 16'h4000;
                 5'b01100: icap_din    = 16'h4000;
                 default:  icap_din    = 16'h4000; // Default for GEN1_H
               endcase
            end
          GEN1_L:
            begin
               next_state  = GEN2_H;
               icap_ce     = 1'b0;
               icap_wr     = 1'b0;
               icap_din    = 16'h3281;
            end
          GEN2_H:
            begin
               next_state  = GEN2_L;
               icap_ce     = 1'b0;
               icap_wr     = 1'b0;
               case ({mode, id}) // Combined mode and id
                 5'b11110: icap_din    = 16'h030A;
                 5'b11101: icap_din    = 16'h030F;
                 5'b01101: icap_din    = 16'h030F;
                 5'b01110: icap_din    = 16'h0315;
                 5'b11100: icap_din    = 16'h031A;
                 5'b01100: icap_din    = 16'h031A;
                 default:  icap_din    = 16'h0305; // Default for GEN2_H
               endcase
            end
          GEN2_L:
            begin
               next_state  = RBT_H;
               icap_ce     = 1'b0;
               icap_wr     = 1'b0;
               icap_din    = 16'h30A1;
            end
          RBT_H:
            begin
               next_state  = RBT_L;
               icap_ce     = 1'b0;
               icap_wr     = 1'b0;
               icap_din    = 16'h000E;
            end
          RBT_L:
            begin
               next_state  = NOOP_0;
               icap_ce     = 1'b0;
               icap_wr     = 1'b0;
               icap_din    = 16'h2000;
            end
          NOOP_0:
            begin
               next_state  = NOOP_1;
               icap_ce     = 1'b0;
               icap_wr     = 1'b0;
               icap_din    = 16'h2000;
            end
          NOOP_1:
            begin
               next_state  = NOOP_2;
               icap_ce     = 1'b0;
               icap_wr     = 1'b0;
               icap_din    = 16'h2000;
            end
          NOOP_2:
            begin
               next_state  = NOOP_3;
               icap_ce     = 1'b0;
               icap_wr     = 1'b0;
               icap_din    = 16'h2000;
            end
          NOOP_3:
            begin
               next_state  = IDLE; // Loop back to IDLE
               icap_ce     = 1'b1; // Inactive
               icap_wr     = 1'b1; // Inactive
               icap_din    = 16'hFFFF; // Default/Inactive value
            end
          default: // Catch-all for undefined states
            begin
               next_state  = IDLE;
               icap_ce     = 1'b1;
               icap_wr     = 1'b1;
               icap_din    = 16'hFFFF;
            end
        endcase
     end

   // Sequential logic for state register
   // Uses state_ff_clk_muxed which is 'clock' in test mode
   always @(posedge state_ff_clk_muxed)
     begin
        state <= next_state;
     end

   // Sequential logic for ICAP interface registers
   // Uses icap_clk_muxed which is 'clock' in test mode
   // Implements bit reversal for icap_din
   always @(posedge icap_clk_muxed)
     begin
        ff_icap_ce <= icap_ce;
        ff_icap_wr <= icap_wr;
        // Bit reversal for ff_icap_din_reversed
        ff_icap_din_reversed[0]  <= icap_din[15];
        ff_icap_din_reversed[1]  <= icap_din[14];
        ff_icap_din_reversed[2]  <= icap_din[13];
        ff_icap_din_reversed[3]  <= icap_din[12];
        ff_icap_din_reversed[4]  <= icap_din[11];
        ff_icap_din_reversed[5]  <= icap_din[10];
        ff_icap_din_reversed[6]  <= icap_din[9];
        ff_icap_din_reversed[7]  <= icap_din[8];
        ff_icap_din_reversed[8]  <= icap_din[7];
        ff_icap_din_reversed[9]  <= icap_din[6];
        ff_icap_din_reversed[10] <= icap_din[5];
        ff_icap_din_reversed[11] <= icap_din[4];
        ff_icap_din_reversed[12] <= icap_din[3];
        ff_icap_din_reversed[13] <= icap_din[2];
        ff_icap_din_reversed[14] <= icap_din[1];
        ff_icap_din_reversed[15] <= icap_din[0];
     end

   // Internal clock generation logic (functional mode only)
   // This block creates flip-flops clocked by 'clock'
   // The outputs clk_internal[0] and clk_internal[1] drive other flops in functional mode (FFCKNP)
   // In test mode (test_i=1), these generated clocks are bypassed by the muxes.
   always @(posedge clock) begin
      // Simple clock divider / state machine for clock generation
      // This generates clk_internal[0] and clk_internal[1]
      // Example: Divide by 4 logic (00 ->