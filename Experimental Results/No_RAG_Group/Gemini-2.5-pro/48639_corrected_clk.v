`timescale 1ps/1ps
module ddr3_clkgen_exdes_corrected_clk 
 #( 
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,         // Primary Clock Input
  input         COUNTER_RESET,   // Primary Asynchronous Reset Input
  output [3:1]  CLK_OUT,
  output [3:1]  COUNT,
  input         RESET,           // Another Primary Reset Input (used by ddr3_clkgen)
  input         test_mode,       // DFT Test Mode Input
  output        LOCKED
 );

  localparam    C_W       = 16;
  localparam    NUM_C     = 3;
  genvar        count_gen;

  // Internal signals
  reg [NUM_C:1] rst_sync;
  reg [NUM_C:1] rst_sync_int;
  reg [NUM_C:1] rst_sync_int1;
  reg [NUM_C:1] rst_sync_int2;
  wire [NUM_C:1] clk_int;         // Generated clocks from ddr3_clkgen
  wire [NUM_C:1] clk;             // Wires for generated clocks
  wire [NUM_C:1] dft_clk;         // DFT Muxed Clocks
  reg [C_W-1:0]  counter [NUM_C:1];

  // Instantiate the clock generator
  ddr3_clkgen clknetwork
   (
    .clk50in            (CLK_IN1),
    .clk50              (clk_int[1]),
    .clk400             (clk_int[2]),
    .clk100             (clk_int[3]),
    .RESET              (RESET),       // Pass primary reset to generator
    .LOCKED             (LOCKED));

  // Assign outputs and internal clock wires
  assign CLK_OUT = clk_int;
  assign clk[1] = clk_int[1];
  assign clk[2] = clk_int[2];
  assign clk[3] = clk_int[3];

  generate for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1) begin: clk_mux
      // DFT Clock Mux: Select primary clock CLK_IN1 in test_mode, functional clock otherwise
      assign dft_clk[count_gen] = test_mode ? CLK_IN1 : clk[count_gen];
  end
  endgenerate

  // Reset Synchronization Chain (Modified for DFT)
  // Uses DFT Muxed Clock (dft_clk) and Primary Asynchronous Reset (COUNTER_RESET)
  generate for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1) begin: counters_sync_reset
    // Use primary asynchronous reset COUNTER_RESET
    always @(posedge dft_clk[count_gen] or posedge COUNTER_RESET) begin 
       if (COUNTER_RESET) begin // Use primary asynchronous reset
            rst_sync[count_gen]      <= 1'b1;
            rst_sync_int[count_gen]  <= 1'b1;
            rst_sync_int1[count_gen] <= 1'b1;
            rst_sync_int2[count_gen] <= 1'b1;
       end
       else begin
            rst_sync[count_gen]      <= 1'b0; // Deassert synchronously
            rst_sync_int[count_gen]  <= rst_sync[count_gen];     
            rst_sync_int1[count_gen] <= rst_sync_int[count_gen]; 
            rst_sync_int2[count_gen] <= rst_sync_int1[count_gen];
       end
    end
  end
  endgenerate

  // Counter Logic (Modified for DFT)
  // Uses DFT Muxed Clock (dft_clk) and Primary Asynchronous Reset (COUNTER_RESET)
  generate for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1) begin: counters_main
    always @(posedge dft_clk[count_gen] or posedge COUNTER_RESET) begin // Use dft_clk and primary reset
      if (COUNTER_RESET) begin // Use primary asynchronous reset
        counter[count_gen] <= #TCQ { C_W { 1'b 0 } };
      end else begin
        counter[count_gen] <= #TCQ counter[count_gen] + 1'b 1;
      end
    end
    // Assign counter output
    assign COUNT[count_gen] = counter[count_gen][C_W-1];
  end
  endgenerate

endmodule