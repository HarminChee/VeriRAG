`timescale 1ps/1ps

module mmcm_mkid_exdes
 #(
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET,
  output [4:1]  CLK_OUT,
  output [4:1]  COUNT,
  output        LOCKED
 );
  localparam    C_W       = 16;
  localparam    NUM_C     = 4;
  genvar        count_gen;
  genvar        clk_out_pins;

  wire          reset_int = !LOCKED || COUNTER_RESET; // Raw reset signal

  // Reset synchronizer registers for each clock domain
  reg [NUM_C:1] rst_sync;
  reg [NUM_C:1] rst_sync_int;
  reg [NUM_C:1] rst_sync_int1;
  reg [NUM_C:1] rst_sync_int2; // Synchronized reset output per domain

  wire          CLKFB_OUT;
  wire          CLKFB_IN;
  wire [NUM_C:1] clk_int; // Internal clock before BUFG
  wire [NUM_C:1] clk;     // Clock after BUFG
  reg [C_W-1:0]  counter [NUM_C:1];

  // Feedback loop
  assign        CLKFB_IN  = CLKFB_OUT;

  // Instantiate the MMCM primitive (assuming it's defined elsewhere)
  mmcm_mkid clknetwork
   (
    .CLK_IN1            (CLK_IN1),
    .CLKFB_IN           (CLKFB_IN),
    .CLK_OUT1           (clk_int[1]),
    .CLK_OUT2           (clk_int[2]),
    .CLK_OUT3           (clk_int[3]),
    .CLK_OUT4           (clk_int[4]),
    .CLKFB_OUT          (CLKFB_OUT),
    .LOCKED             (LOCKED));

  // Generate ODDRs for clock outputs (if needed, often BUFG output is sufficient)
  generate
    for (clk_out_pins = 1; clk_out_pins <= NUM_C; clk_out_pins = clk_out_pins + 1)
    begin: gen_outclk_oddr
       // ODDR usage might be optional depending on requirements.
       // If CLK_OUT just needs to reflect the buffered clock, assign clk directly.
       // This example keeps the ODDR for toggling output.
       ODDR clkout_oddr
       (
        .Q  (CLK_OUT[clk_out_pins]), // Output port
        .C  (clk[clk_out_pins]),     // Clock input (from BUFG)
        .CE (1'b1),                  // Clock Enable
        .D1 (1'b1),                  // Data input (posedge)
        .D2 (1'b0),                  // Data input (negedge)
        .R  (1'b0),                  // Async Reset (not used)
        .S  (1'b0)                   // Async Set (not used)
       );
    end
  endgenerate

  // Instantiate BUFGs for clock outputs
  BUFG clkout1_buf
   (.O (clk[1]),
    .I (clk_int[1]));
  BUFG clkout2_buf
   (.O (clk[2]),
    .I (clk_int[2]));
  BUFG clkout3_buf
   (.O (clk[3]),
    .I (clk_int[3]));
  BUFG clkout4_buf
   (.O (clk[4]),
    .I (clk_int[4]));

  // Generate reset synchronizers for each clock domain
  generate
    for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1) begin: reset_sync_gen
      // Asynchronous Reset Synchronizer for clock domain clk[count_gen]
      // Uses reset_int as asynchronous input, produces rst_sync_int2 as synchronized output

      // First stage: Asynchronous set, synchronous reset
      always @(posedge clk[count_gen] or posedge reset_int) begin
         if (reset_int) begin
              rst_sync[count_gen] <= #TCQ 1'b1; // Asynchronously assert on reset_int edge
         end else begin
              rst_sync[count_gen] <= #TCQ 1'b0; // Synchronously deassert on clock edge
         end
      end

      // Subsequent stages: Purely synchronous propagation
      always @(posedge clk[count_gen]) begin
         rst_sync_int[count_gen]  <= #TCQ rst_sync[count_gen];
         rst_sync_int1[count_gen] <= #TCQ rst_sync_int[count_gen];
         rst_sync_int2[count_gen] <= #TCQ rst_sync_int1[count_gen]; // Final synchronized reset
      end
    end
  endgenerate

  // Generate counters for each clock domain
  generate
    for (count_gen = 1; count_gen <= NUM_C; count_gen = count_gen + 1) begin: counters
      // Counter clocked by clk[count_gen], reset by synchronized rst_sync_int2[count_gen]
      always @(posedge clk[count_gen] or posedge rst_sync_int2[count_gen]) begin
        if (rst_sync_int2[count_gen]) begin // Use synchronized, active-high reset
          counter[count_gen] <= #TCQ { C_W { 1'b0 } };
        end else begin
          counter[count_gen] <= #TCQ counter[count_gen] + 1'b1;
        end
      end
      // Assign MSB of counter to output COUNT port
      assign COUNT[count_gen] = counter[count_gen][C_W-1];
    end
  endgenerate

endmodule