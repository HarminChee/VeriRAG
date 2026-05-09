`timescale 1ps/1ps
`timescale 1ps/1ps
module clk_gen_83M_exdes
 #(
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET,
  output [3:1]  COUNT,
  input         RESET,
  output        LOCKED,
  // DFT Ports
  input         dft_scan_en,
  input         dft_clk,
  input         dft_reset_n // Active low DFT reset
 );
  localparam    C_W       = 16;
  localparam    NUM_C     = 3;
  genvar        count_gen;
  wire          reset_int_func = !LOCKED || RESET || COUNTER_RESET;
   reg [NUM_C:1] rst_sync;
   reg [NUM_C:1] rst_sync_int;
   reg [NUM_C:1] rst_sync_int1;
   reg [NUM_C:1] rst_sync_int2;
  wire [NUM_C:1] clk_int;
  wire [NUM_C:1] clk;
  reg [C_W-1:0]  counter [NUM_C:1];

  // DFT Signals
  wire [NUM_C:1] effective_clk_sync;
  wire [NUM_C:1] effective_reset_sync_n; // Active low effective reset
  wire [NUM_C:1] effective_reset_sync;   // Active high effective reset

  wire [NUM_C:1] effective_clk_count;
  wire [NUM_C:1] effective_reset_count_n; // Active low effective reset
  wire [NUM_C:1] effective_reset_count;   // Active high effective reset


  clk_gen_83M clknetwork
   (
    .CLK_IN1            (CLK_IN1),
    .CLK_OUT1           (clk_int[1]),
    .CLK_OUT2           (clk_int[2]),
    .CLK_OUT3           (clk_int[3]),
    .RESET              (RESET),
    .LOCKED             (LOCKED));

  assign clk[1] = clk_int[1];
  assign clk[2] = clk_int[2];
  assign clk[3] = clk_int[3];

  generate for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1) begin: counters_1
    // DFT Muxing for clock and reset
    assign effective_clk_sync[count_gen] = dft_scan_en ? dft_clk : clk[count_gen];
    // Mux reset: Use dft_reset_n (active low) in test mode, functional reset (active high) otherwise.
    // Resulting effective_reset_sync is active high.
    assign effective_reset_sync[count_gen] = dft_scan_en ? !dft_reset_n : reset_int_func;

    // Note: Original code used posedge reset_int. We keep posedge effective_reset_sync.
    always @(posedge effective_clk_sync[count_gen] or posedge effective_reset_sync[count_gen]) begin
       if (effective_reset_sync[count_gen]) begin
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
    // DFT Muxing for clock and reset
    assign effective_clk_count[count_gen] = dft_scan_en ? dft_clk : clk[count_gen];
    // Mux reset: Use dft_reset_n (active low) in test mode, functional reset (active high) otherwise.
    // Resulting effective_reset_count is active high.
    assign effective_reset_count[count_gen] = dft_scan_en ? !dft_reset_n : rst_sync_int2[count_gen];

    // Note: Original code used posedge rst_sync_int2. We keep posedge effective_reset_count.
    always @(posedge effective_clk_count[count_gen] or posedge effective_reset_count[count_gen]) begin
      if (effective_reset_count[count_gen]) begin
        counter[count_gen] <= #TCQ { C_W { 1'b 0 } };
      end else begin
        counter[count_gen] <= #TCQ counter[count_gen] + 1'b 1;
      end
    end
    assign COUNT[count_gen] = counter[count_gen][C_W-1];
  end
  endgenerate

endmodule