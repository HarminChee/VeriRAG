`timescale 1ps/1ps
`timescale 1ps/1ps
module Clock48MHZ_exdes
 #(
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET,
  output [4:1]  CLK_OUT,
  output [4:1]  COUNT,
  output        LOCKED,
  // DFT Ports
  input         test_mode,
  input         test_clk,
  input         test_reset // Assuming active high test reset
 );
  localparam    C_W       = 16;
  localparam    NUM_C     = 4;
  genvar        count_gen;
  wire          reset_int = !LOCKED || COUNTER_RESET;
   reg [NUM_C:1] rst_sync;
   reg [NUM_C:1] rst_sync_int;
   reg [NUM_C:1] rst_sync_int1;
   reg [NUM_C:1] rst_sync_int2;
  wire [NUM_C:1] clk_int;
  wire [NUM_C:1] clk;
  reg [C_W-1:0]  counter [NUM_C:1];

  // DFT Signals
  wire [NUM_C:1] dft_clk;
  wire [NUM_C:1] dft_reset_counters1_trigger;
  wire [NUM_C:1] dft_reset_counters_trigger;

  Clock48MHZ clknetwork
   (
    .CLK_100            (CLK_IN1),
    .CLK_48           (clk_int[1]),
    .CLK_OUT1           (clk_int[2]),
    .CLK_OUT2           (clk_int[3]),
    .CLK_OUT4           (clk_int[4]),
    .LOCKED             (LOCKED));

genvar clk_out_pins;
generate
  for (clk_out_pins = 1; clk_out_pins <= NUM_C; clk_out_pins = clk_out_pins + 1)
  begin: gen_outclk_oddr
  ODDR clkout_oddr
   (.Q  (CLK_OUT[clk_out_pins]),
    .C  (dft_clk[clk_out_pins]), // Use DFT muxed clock
    .CE (1'b1),
    .D1 (1'b1),
    .D2 (1'b0),
    .R  (1'b0),
    .S  (1'b0));
  end
endgenerate

  assign clk[1] = clk_int[1];
  assign clk[2] = clk_int[2];
  assign clk[3] = clk_int[3];
  assign clk[4] = clk_int[4];

  // Generate DFT clocks and reset triggers
  genvar i;
  generate
    for (i = 1; i <= NUM_C; i = i + 1) begin : gen_dft_signals
      assign dft_clk[i] = test_mode ? test_clk : clk[i];
      // Reset trigger for counters_1 block
      assign dft_reset_counters1_trigger[i] = test_mode ? test_reset : reset_int;
      // Reset trigger for counters block (depends on rst_sync_int2 functionally)
      assign dft_reset_counters_trigger[i] = test_mode ? test_reset : rst_sync_int2[i];
    end
  endgenerate


  generate for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1) begin: counters_1
    // Use DFT clock and DFT reset trigger
    always @(posedge dft_clk[count_gen] or posedge dft_reset_counters1_trigger[count_gen]) begin
       if (dft_reset_counters1_trigger[count_gen]) begin // Reset condition based on muxed trigger
            rst_sync[count_gen] <= 1'b1;
            rst_sync_int[count_gen]<= 1'b1;
            rst_sync_int1[count_gen]<= 1'b1;
            rst_sync_int2[count_gen]<= 1'b1;
       end
       else begin
            rst_sync[count_gen] <= 1'b0;
            rst_sync_int[count_gen] <= rst_sync[count_gen];
            rst_sync_int1[count_gen] <= rst_sync_int[count_gen];
            rst_sync_int2[count_gen] <= rst_sync_int1[count_gen];
       end
    end
  end
  endgenerate

  generate for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1) begin: counters
    // Use DFT clock and DFT reset trigger
    always @(posedge dft_clk[count_gen] or posedge dft_reset_counters_trigger[count_gen]) begin
      if (dft_reset_counters_trigger[count_gen]) begin // Reset condition based on muxed trigger
        counter[count_gen] <= #TCQ { C_W { 1'b 0 } };
      end else begin
        counter[count_gen] <= #TCQ counter[count_gen] + 1'b 1;
      end
    end
    assign COUNT[count_gen] = counter[count_gen][C_W-1];
  end
  endgenerate

endmodule