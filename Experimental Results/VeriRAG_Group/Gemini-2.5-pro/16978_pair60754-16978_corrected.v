`timescale 1ps/1ps
`timescale 1ps/1ps
module Clock70MHz_exdes
 #(
  parameter TCQ = 100
  )
 (
  input         test_i,         // DFT test mode enable
  input         test_rst_i,     // DFT asynchronous reset
  input         CLK_IN1,
  input         COUNTER_RESET,
  output [1:1]  CLK_OUT,
  output        COUNT,
  output        LOCKED
 );
  localparam    C_W       = 16;
  wire          reset_int = !LOCKED || COUNTER_RESET;
   reg rst_sync;
   reg rst_sync_int;
   reg rst_sync_int1;
   reg rst_sync_int2;
  wire           clk_int;
  wire           clk_n;
  wire           clk;
  wire           dft_clk;        // DFT clock mux output
  wire           dft_reset_async; // DFT async reset for synchronizer
  wire           dft_counter_reset_async; // DFT async reset for counter
  reg  [C_W-1:0] counter;

  // DFT clock mux: Use CLK_IN1 in test mode, internal clk otherwise
  assign dft_clk = test_i ? CLK_IN1 : clk;

  // DFT reset mux for synchronizer: Use test_rst_i in test mode, reset_int otherwise
  assign dft_reset_async = test_i ? test_rst_i : reset_int;

  // DFT reset mux for counter: Use test_rst_i in test mode, synchronized reset otherwise
  assign dft_counter_reset_async = test_i ? test_rst_i : rst_sync_int2;

  Clock70MHz clknetwork
   (
    .CLK_IN1            (CLK_IN1),
    .CLK_OUT1           (clk_int),
    .LOCKED             (LOCKED));

  assign clk_n = ~clk;

  ODDR2 clkout_oddr // Note: DFT handling for ODDR might need specific tool directives
   (.Q  (CLK_OUT[1]),
    .C0 (clk),
    .C1 (clk_n),
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (1'b0),
    .S  (1'b0));

  assign clk = clk_int;

    // Reset synchronizer flip-flops
    // Uses DFT clock and DFT asynchronous reset
    always @(posedge dft_reset_async or posedge dft_clk) begin
       if (dft_reset_async) begin // Use DFT async reset
            rst_sync <= 1'b1;
            rst_sync_int <= 1'b1;
            rst_sync_int1 <= 1'b1;
            rst_sync_int2 <= 1'b1;
       end
       else begin
            rst_sync <= 1'b0;
            rst_sync_int <= rst_sync;
            rst_sync_int1 <= rst_sync_int;
            rst_sync_int2 <= rst_sync_int1;
       end
    end

  // Counter flip-flops
  // Uses DFT clock and DFT asynchronous reset for counter
  always @(posedge dft_clk or posedge dft_counter_reset_async) begin
    if (dft_counter_reset_async) begin // Use DFT async reset for counter
      counter <= #TCQ { C_W { 1'b 0 } };
    end else begin
      counter <= #TCQ counter + 1'b 1;
    end
  end

  assign COUNT = counter[C_W-1];
endmodule