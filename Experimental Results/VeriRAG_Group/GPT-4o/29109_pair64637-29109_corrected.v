module avalanche_entropy_core(
                              input wire           clk,
                              input wire           scan_clk,
                              input wire           test_i,
                              input wire           reset_n,
                              input wire           noise,
                              input wire           enable,
                              output wire          entropy_enabled,
                              output wire [31 : 0] entropy_data,
                              output wire          entropy_valid,
                              input wire           entropy_ack,
                              output wire [31 : 0] delta,
                              output wire [7 : 0]  debug,
                              input wire           debug_update
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
  wire         dft_clk;
  assign entropy_valid   = entropy_valid_reg;
  assign entropy_data    = entropy_reg;
  assign delta           = delta_reg;
  assign debug           = debug_reg;
  assign entropy_enabled = enable_reg;
  assign dft_clk = test_i ? scan_clk : clk;
  always @ (posedge dft_clk or negedge reset_n)
    begin
      if (!reset_n)
        begin
          noise_sample0_reg   <= 1'b0;
          noise_sample_reg    <= 1'b0;
          flank0_reg          <= 1'b0;
          flank1_reg          <= 1'b0;
          entropy_valid_reg     <= 1'b0;
          entropy_reg         <= 32'h00000000;
          entropy_bit_reg     <= 1'b0;
          bit_ctr_reg         <= 6'h00;
          cycle_ctr_reg       <= 32'h00000000;
          delta_reg           <= 32'h00000000;
          debug_delay_ctr_reg <= 32'h00000000;
          debug_reg           <= 8'h00;
          debug_update_reg    <= 0;
          enable_reg          <= 0;
        end
      else
        begin
          noise_sample0_reg <= noise;
          noise_sample_reg  <= noise_sample0_reg;
          flank0_reg        <= noise_sample_reg;
          flank1_reg        <= flank0_reg;
          entropy_valid_reg <= entropy_valid_new;
          entropy_bit_reg   <= ~entropy_bit_reg;
          cycle_ctr_reg     <= cycle_ctr_new;
          debug_update_reg  <= debug_update;
          enable_reg        <= enable;
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
  always @*
    begin : debug_out
      debug_delay_ctr_new = 32'h00000000;
      debug_delay_ctr_we  = 0;
      debug_we            = 0;
      if (debug_update_reg)
        begin
          debug_delay_ctr_new = debug_delay_ctr_reg + 1'b1;
          debug_delay_ctr_we  = 1;
        end
      if (debug_delay_ctr_reg == DEBUG_DELAY)
        begin
          debug_delay_ctr_new = 32'h00000000;
          debug_delay_ctr_we  = 1;
          debug_we            = 1;
        end
    end
  always @*
    begin : entropy_collect
      entropy_new   = 32'h00000000;
      entropy_we    = 1'b0;
      bit_ctr_inc   = 1'b0;
      if ((flank0_reg) && (!flank1_reg))
        begin
          entropy_new   = {entropy_reg[30 : 0], entropy_bit_reg};
          entropy_we    = 1'b1;
          bit_ctr_inc   = 1'b1;
        end
    end 
  always @*
    begin : delta_logic
      cycle_ctr_new      = cycle_ctr_reg + 1'b1;
      delta_we           = 1'b0;
      if ((flank0_reg) && (!flank1_reg))
        begin
          cycle_ctr_new = 32'h00000000;
          delta_we      = 1'b1;
        end
    end 
  always @*
    begin : entropy_ack_logic
      bit_ctr_new       = 6'h00;
      bit_ctr_we        = 1'b0;
      entropy_valid_new = 1'b0;
      if (bit_ctr_reg == MIN_ENTROPY_BITS)
        begin
          entropy_valid_new = 1'b1;
        end
      if ((bit_ctr_inc) && (bit_ctr_reg < 6'h20))
        begin
          bit_ctr_new = bit_ctr_reg + 1'b1;
          bit_ctr_we  = 1'b1;
        end
      else if (entropy_ack)
        begin
          bit_ctr_new = 6'h00;
          bit_ctr_we  = 1'b1;
        end
      end 
endmodule