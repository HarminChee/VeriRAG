module avalanche_entropy_core_corrected_cdf( // Module name changed
                              input wire           clk,
                              input wire           reset_n,
                              // Added DFT control signal
                              input wire           scan_en,
                              input wire           noise,
                              input wire           enable,
                              output wire          entropy_enabled,
                              output wire [31 : 0] entropy_data,
                              output wire          entropy_valid,
                              input wire           entropy_ack,
                              output wire [31 : 0] delta,
                              output wire [7 : 0]  debug,
                              input wire           debug_update,
                              // Added placeholder scan input for the modified FF
                              // In a full scan chain, this connects to the previous FF's scan_out
                              input wire           entropy_bit_scan_in
                             );
  parameter DEBUG_DELAY      = 32'h002c4b40;
  parameter MIN_ENTROPY_BITS = 6'h20;
  reg          noise_sample0_reg;
  reg          noise_sample_reg;
  reg          flank0_reg;
  reg          flank1_reg;
  reg          entropy_bit_reg;
  reg [31 : 0] entropy_reg;
  reg [31 : 0] entropy_new;
  reg          entropy_we;
  reg          entropy_valid_reg;
  reg          entropy_valid_new;
  reg [5 :  0] bit_ctr_reg;
  reg [5 :  0] bit_ctr_new;
  reg          bit_ctr_inc;
  reg          bit_ctr_we;
  reg          enable_reg;
  reg [31 : 0] cycle_ctr_reg;
  reg [31 : 0] cycle_ctr_new;
  reg [31 : 0] delta_reg;
  reg          delta_we;
  reg [31 : 0] debug_delay_ctr_reg;
  reg [31 : 0] debug_delay_ctr_new;
  reg          debug_delay_ctr_we;
  reg [7 : 0]  debug_reg;
  reg          debug_we;
  reg          debug_update_reg;

  assign entropy_valid   = entropy_valid_reg;
  assign entropy_data    = entropy_reg;
  assign delta           = delta_reg;
  assign debug           = debug_reg;
  assign entropy_enabled = enable_reg;

  always @ (posedge clk or negedge reset_n)
    begin
      if (!reset_n)
        begin
          noise_sample0_reg   <= 1'b0;
          noise_sample_reg    <= 1'b0;
          flank0_reg          <= 1'b0;
          flank1_reg          <= 1'b0;
          entropy_valid_reg   <= 1'b0;
          entropy_reg         <= 32'h00000000;
          entropy_bit_reg     <= 1'b0; // Reset state for the toggle FF
          bit_ctr_reg         <= 6'h00;
          cycle_ctr_reg       <= 32'h00000000;
          delta_reg           <= 32'h00000000;
          debug_delay_ctr_reg <= 32'h00000000;
          debug_reg           <= 8'h00;
          debug_update_reg    <= 1'b0; // Use 1'b0 for reset
          enable_reg          <= 1'b0; // Use 1'b0 for reset
        end
      else
        begin
          noise_sample0_reg <= noise;
          noise_sample_reg  <= noise_sample0_reg;
          flank0_reg        <= noise_sample_reg;
          flank1_reg        <= flank0_reg;
          entropy_valid_reg <= entropy_valid_new;

          // DFT Modification for entropy_bit_reg (Toggle FF)
          // In scan mode (scan_en=1), load data from scan input
          // In functional mode (scan_en=0), perform original toggle operation
          if (scan_en) begin
            entropy_bit_reg <= entropy_bit_scan_in;
          end else begin
            entropy_bit_reg <= ~entropy_bit_reg; // Original toggle behavior
          end

          cycle_ctr_reg     <= cycle_ctr_new;
          debug_update_reg  <= debug_update;
          enable_reg        <= enable;

          // Conditional updates remain, assuming enables are controllable/observable
          if (delta_we)
            begin
              delta_reg <= cycle_ctr_reg;
            end
          if (bit_ctr_we)
            begin
              bit_ctr_reg <= bit_ctr_new;
            end
          if (entropy_we)
            begin
              entropy_reg <= entropy_new;
            end
          if (debug_delay_ctr_we)
            begin
              debug_delay_ctr_reg <= debug_delay_ctr_new;
            end
          if (debug_we)
            begin
              debug_reg <= entropy_reg[7 : 0];
            end
        end
    end

  // Combinational logic blocks
  always @*
    begin : debug_out
      debug_delay_ctr_new = 32'h00000000;
      debug_delay_ctr_we  = 1'b0; // Default assignment
      debug_we            = 1'b0; // Default assignment
      if (debug_update_reg)
        begin
          debug_delay_ctr_new = debug_delay_ctr_reg + 1'b1;
          debug_delay_ctr_we  = 1'b1;
        end
      // Use parameter for comparison
      if (debug_delay_ctr_reg == DEBUG_DELAY)
        begin
          debug_delay_ctr_new = 32'h00000000;
          debug_delay_ctr_we  = 1'b1;
          debug_we            = 1'b1;
        end
    end

  always @*
    begin : entropy_collect
      entropy_new   = 32'h00000000; // Default assignment
      entropy_we    = 1'b0;         // Default assignment
      bit_ctr_inc   = 1'b0;         // Default assignment
      // Detect rising edge of noise_sample_reg
      if ((flank0_reg) && (!flank1_reg))
        begin
          // Use the potentially scan-controlled entropy_bit_reg value
          entropy_new   = {entropy_reg[30 : 0], entropy_bit_reg};
          entropy_we    = 1'b1;
          bit_ctr_inc   = 1'b1;
        end
    end

  always @*
    begin : delta_logic
      cycle_ctr_new      = cycle_ctr_reg + 1'b1; // Default increment
      delta_we           = 1'b0;               // Default assignment
      // Detect rising edge of noise_sample_reg
      if ((flank0_reg) && (!flank1_reg))
        begin
          cycle_ctr_new = 32'h00000000; // Reset cycle counter
          delta_we      = 1'b1;         // Enable delta register update
        end
    end

  always @*
    begin : entropy_ack_logic
      bit_ctr_new       = bit_ctr_reg; // Default: hold value
      bit_ctr_we        = 1'b0;        // Default assignment
      entropy_valid_new = 1'b0;        // Default assignment

      // Check if minimum entropy bits reached
      if (bit_ctr_reg == MIN_ENTROPY_BITS)
        begin
          entropy_valid_new = 1'b1;
        end

      // Increment counter if a new bit was collected and not yet full
      // Use parameter MIN_ENTROPY_BITS
      if ((bit_ctr_inc) && (bit_ctr_reg < MIN_ENTROPY_BITS))
        begin
          bit_ctr_new = bit_ctr_reg + 1'b1;
          bit_ctr_we  = 1'b1;
          // Ensure valid stays low while collecting
          entropy_valid_new = 1'b0;
        end
      // Reset counter if acknowledged by consumer OR if full and not acknowledged yet
      // If entropy_ack comes, it should reset the counter and deassert valid for next cycle
      else if (entropy_ack)
        begin
          bit_ctr_new = 6'h00;
          bit_ctr_we  = 1'b1;
          entropy_valid_new = 1'b0; // Deassert valid on ack
        end
      // If counter is full (valid is high), hold state until ack
      else if (bit_ctr_reg == MIN_ENTROPY_BITS)
        begin
             bit_ctr_new = bit_ctr_reg; // Hold value
             bit_ctr_we  = 1'b0;        // No write
             entropy_valid_new = 1'b1; // Keep valid high
        end
      // Otherwise (no increment, no ack, not full), hold current state
      // else begin
      //    bit_ctr_new = bit_ctr_reg; // Already default
      //    bit_ctr_we = 1'b0;         // Already default
      //    entropy_valid_new = 1'b0; // Already default
      // end

      end
endmodule