`timescale 1ps/1ps

module Clock50MHz_exdes
 #(
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET,
  output [1:1]  CLK_OUT,
  output        COUNT,
  output        LOCKED
 );
  localparam    C_W       = 16;

  // Internal reset signal: active high if !LOCKED or COUNTER_RESET is high
  wire          reset_int = !LOCKED || COUNTER_RESET;

  // Reset synchronizer registers
  reg rst_sync;
  reg rst_sync_int;
  reg rst_sync_int1;
  reg rst_sync_int2;

  // Internal clock signals
  wire           clk_int; // Output from Clock50MHz primitive
  wire           clk_n;
  wire           clk;     // Clock used internally

  // Counter register
  reg  [C_W-1:0] counter;

  // Instantiate the clocking network (e.g., PLL or MMCM primitive)
  Clock50MHz clknetwork
   (
    .CLK_IN1            (CLK_IN1),
    .CLK_OUT1           (clk_int), // Connect to internal clock wire
    .LOCKED             (LOCKED)
   );

  // Assign internal clock from the clock network output
  assign clk = clk_int;
  // Generate inverted clock (often needed for DDR registers)
  assign clk_n = ~clk;

  // Output Double Data Rate register to drive the output clock pin
  // Configuration passes 'clk' through when D0=1, D1=0
  ODDR2 clkout_oddr
   (
    .Q  (CLK_OUT[1]), // Connect to the single bit output CLK_OUT[1]
    .C0 (clk),        // Positive edge clock
    .C1 (clk_n),      // Negative edge clock (or inverted clock)
    .CE (1'b1),       // Clock Enable always active
    .D0 (1'b1),       // Data input for posedge clock
    .D1 (1'b0),       // Data input for negedge clock
    .R  (1'b0),       // Async Reset (tied inactive)
    .S  (1'b0)        // Async Set (tied inactive)
   );

  // Reset synchronizer block
  // Synchronize the potentially asynchronous reset_int to the 'clk' domain
  // Corrected sensitivity list: only sensitive to posedge clk
  always @(posedge clk) begin
     // Check reset condition inside the always block
     if (reset_int) begin
          rst_sync <= 1'b1;
          rst_sync_int <= 1'b1;
          rst_sync_int1 <= 1'b1;
          rst_sync_int2 <= 1'b1;
     end
     else begin // Synchronous de-assertion path
          rst_sync <= 1'b0;
          rst_sync_int <= rst_sync;
          rst_sync_int1 <= rst_sync_int;
          rst_sync_int2 <= rst_sync_int1; // Final synchronized reset signal
     end
  end

  // Counter block using the synchronized reset
  // Corrected sensitivity list: only sensitive to posedge clk
  always @(posedge clk) begin
    // Check synchronous reset condition inside the always block
    if (rst_sync_int2) begin
      counter <= #TCQ { C_W { 1'b 0 } }; // Reset counter
    end else begin
      counter <= #TCQ counter + 1'b 1; // Increment counter
    end
  end

  // Assign the most significant bit of the counter to the output COUNT
  assign COUNT = counter[C_W-1];

endmodule