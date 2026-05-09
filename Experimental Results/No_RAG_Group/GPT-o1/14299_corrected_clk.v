module 1_corrected_clk (
    input  clk_in,
    inout  reset_inout_n,
    input  sdram_fb,
    output sdram_clk,
    output clk,
    output clk_ok,
    output reset
);
  wire clk_in_buf;
  reg reset_p_n;
  reg reset_s_n;
  reg [23:0] reset_counter;
  wire reset_counting;

  // Clock buffer from primary input
  IBUFG clk_in_buffer(
    .I(clk_in),
    .O(clk_in_buf)
  );

  // Assign primary-input-driven clocks
  assign sdram_clk = clk_in_buf;
  assign clk       = clk_in_buf;
  assign clk_ok    = 1'b1;

  // Reset logic
  assign reset_counting = (reset_counter == 24'hFFFFFF) ? 1'b0 : 1'b1;
  assign reset_inout_n  = (reset_counter[23] == 1'b0) ? 1'b0 : 1'bz;

  always @(posedge clk_in_buf) begin
    reset_p_n <= reset_inout_n;
    reset_s_n <= reset_p_n;
    if (reset_counting) begin
      reset_counter <= reset_counter + 1'b1;
    end else begin
      if (~reset_s_n) begin
        reset_counter <= 24'h000000;
      end
    end
  end

  assign reset = reset_counting;
endmodule