`timescale 1ps/1ps
module pll_exdes_corrected_clk
 #(
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET,
  input         TEST_MODE, // Added for DFT clock selection
  input         TEST_CLK,  // Added for DFT test clock
  output [2:1]  CLK_OUT,
  output [2:1]  COUNT
 );
  localparam    C_W       = 16;
  localparam    NUM_C     = 2;
  genvar        count_gen;
  wire          reset_int = COUNTER_RESET;
   reg [NUM_C:1] rst_sync;
   reg [NUM_C:1] rst_sync_int;
   reg [NUM_C:1] rst_sync_int1;
   reg [NUM_C:1] rst_sync_int2;
  wire [NUM_C:1] clk_int; // PLL output clocks (functional)
  wire [NUM_C:1] clk_n;
  wire [NUM_C:1] clk;     // Functional clocks (potentially for non-FF logic like ODDR)
  wire [NUM_C:1] clk_muxed; // Muxed clock for FFs (DFT compliant)
  reg [C_W-1:0]  counter [NUM_C:1];

  // PLL instance generates functional clocks
  pll clknetwork
   (
    .CLK_IN1            (CLK_IN1),
    .CLK_OUT1           (clk_int[1]),
    .CLK_OUT2           (clk_int[2]));

  // Assign functional clocks (used by ODDR below)
  assign clk[1] = clk_int[1];
  assign clk[2] = clk_int[2];

  // Clock Multiplexing for Flip-Flops based on TEST_MODE
  genvar mux_gen;
  generate
    for (mux_gen = 1; mux_gen <= NUM_C; mux_gen = mux_gen + 1) begin: gen_clk_mux
      assign clk_muxed[mux_gen] = TEST_MODE ? TEST_CLK : clk_int[mux_gen];
    end
  endgenerate

  // ODDR generation using functional clocks (ODDRs might have specific DFT handling)
  genvar clk_out_pins;
  generate
    for (clk_out_pins = 1; clk_out_pins <= NUM_C; clk_out_pins = clk_out_pins + 1)
    begin: gen_outclk_oddr
      assign clk_n[clk_out_pins] = ~clk[clk_out_pins]; // Use functional clock
      ODDR2 clkout_oddr
       (.Q  (CLK_OUT[clk_out_pins]),
        .C0 (clk[clk_out_pins]),     // Functional clock
        .C1 (clk_n[clk_out_pins]),   // Inverted functional clock
        .CE (1'b1),
        .D0 (1'b1),
        .D1 (1'b0),
        .R  (1'b0),
        .S  (1'b0));
    end
  endgenerate

  // Reset synchronizer generation - clocked by DFT-muxed clock
  generate for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1) begin: counters_1
    // Use the multiplexed clock clk_muxed
    always @(posedge reset_int or posedge clk_muxed[count_gen]) begin
       if (reset_int) begin
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

  // Counter generation - clocked by DFT-muxed clock
  generate for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1) begin: counters
    // Use the multiplexed clock clk_muxed
    always @(posedge clk_muxed[count_gen] or posedge rst_sync_int2[count_gen]) begin
      if (rst_sync_int2[count_gen]) begin
        counter[count_gen] <= #TCQ { C_W { 1'b 0 } };
      end else begin
        counter[count_gen] <= #TCQ counter[count_gen] + 1'b 1;
      end
    end
    assign COUNT[count_gen] = counter[count_gen][C_W-1];
  end
  endgenerate

endmodule

// Mock PLL module for compilation purposes (replace with actual PLL model if available)
module pll (
    input CLK_IN1,
    output CLK_OUT1,
    output CLK_OUT2
);
    // Dummy assignment - replace with actual PLL behavior or model
    assign CLK_OUT1 = CLK_IN1;
    assign CLK_OUT2 = CLK_IN1;
endmodule

// Mock ODDR2 module for compilation purposes (replace with actual library cell)
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
    // Dummy behavior - replace with actual ODDR2 model
    reg q_reg;
    always @(posedge C0 or posedge R or posedge S) begin
        if (R) q_reg <= 1'b0;
        else if (S) q_reg <= 1'b1;
        else if (CE) q_reg <= D0;
    end
    always @(posedge C1 or posedge R or posedge S) begin
         if (R) q_reg <= 1'b0;
         else if (S) q_reg <= 1'b1;
         else if (CE) q_reg <= D1;
    end
    assign Q = q_reg;
endmodule