`timescale 1ps/1ps
`timescale 1ps/1ps
module sdram_clk_gen_exdes_corrected
 #(
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET,
  input         scan_mode, // Added scan mode input
  output [1:1]  CLK_OUT,
  output        COUNT
 );
  localparam    C_W       = 16;
  wire          reset_int = COUNTER_RESET;
   reg rst_sync;
   reg rst_sync_int;
   reg rst_sync_int1;
   reg rst_sync_int2;
  wire           clk_int;
  wire           clk_n;
  wire           clk;
  wire           scan_clk; // Multiplexed clock for DFT
  wire           scan_clk_n; // Inverted scan clock

  reg  [C_W-1:0] counter;

  sdram_clk_gen clknetwork
   (
    .clk_in            (CLK_IN1),
    .clk_out           (clk_int));

  // Select between functional clock and test clock based on scan_mode
  assign clk = clk_int;
  assign scan_clk = scan_mode ? CLK_IN1 : clk;
  assign scan_clk_n = ~scan_clk;

  ODDR2 clkout_oddr
   (.Q  (CLK_OUT[1]),
    .C0 (scan_clk),      // Use scan_clk
    .C1 (scan_clk_n),    // Use inverted scan_clk
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (1'b0),
    .S  (1'b0));

    // Reset synchronizer clocked by scan_clk
    always @(posedge reset_int or posedge scan_clk) begin // Use scan_clk
       if (reset_int) begin
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

  // Counter clocked by scan_clk
  always @(posedge scan_clk or posedge rst_sync_int2) begin // Use scan_clk
    if (rst_sync_int2) begin
      counter <= #TCQ { C_W { 1'b 0 } };
    end else begin
      counter <= #TCQ counter + 1'b 1;
    end
  end

  assign COUNT = counter[C_W-1];

endmodule

// Dummy module definition for sdram_clk_gen for compilation purposes
// Replace with actual module if available
module sdram_clk_gen (
    input clk_in,
    output clk_out
);
    // Example: Simple buffer or clock divider/multiplier logic
    assign clk_out = clk_in;
endmodule

// Dummy module definition for ODDR2 for compilation purposes
// Replace with actual primitive if targeting specific FPGA/ASIC library
module ODDR2 (
    output Q,
    input C0,
    input C1,
    input CE,
    input D0,
    input D1,
    input R,
    input S
);
    // Simplified behavioral model
    reg Q_internal;
    assign Q = Q_internal;

    always @(posedge C0 or posedge R or posedge S) begin
        if (R)
            Q_internal <= 1'b0;
        else if (S)
            Q_internal <= 1'b1;
        else if (CE)
            Q_internal <= D0;
    end

    always @(posedge C1 or posedge R or posedge S) begin
        if (R)
            Q_internal <= 1'b0;
        else if (S)
            Q_internal <= 1'b1;
        else if (CE)
            Q_internal <= D1;
    end
endmodule