// 1_corrected_clk.v
`timescale 1ns/100ps
module axi_ad9739a_if (
  // Primary Inputs/Outputs
  dac_clk_in_p,
  dac_clk_in_n,
  dac_clk_out_p,
  dac_clk_out_n,
  dac_data_out_a_p,
  dac_data_out_a_n,
  dac_data_out_b_p,
  dac_data_out_b_n,
  dac_rst, // Assuming asynchronous reset
  dac_clk,
  dac_div_clk, // Keep original output for external use if needed
  dac_status,
  dac_data_00,
  dac_data_01,
  dac_data_02,
  dac_data_03,
  dac_data_04,
  dac_data_05,
  dac_data_06,
  dac_data_07,
  dac_data_08,
  dac_data_09,
  dac_data_10,
  dac_data_11,
  dac_data_12,
  dac_data_13,
  dac_data_14,
  dac_data_15,

  // DFT Input
  scan_mode // Test mode control
);
  parameter   PCORE_DEVICE_TYPE = 0;

  // Primary Inputs
  input           dac_clk_in_p;
  input           dac_clk_in_n;
  input           dac_rst;        // Primary asynchronous reset
  input   [15:0]  dac_data_00;
  input   [15:0]  dac_data_01;
  input   [15:0]  dac_data_02;
  input   [15:0]  dac_data_03;
  input   [15:0]  dac_data_04;
  input   [15:0]  dac_data_05;
  input   [15:0]  dac_data_06;
  input   [15:0]  dac_data_07;
  input   [15:0]  dac_data_08;
  input   [15:0]  dac_data_09;
  input   [15:0]  dac_data_10;
  input   [15:0]  dac_data_11;
  input   [15:0]  dac_data_12;
  input   [15:0]  dac_data_13;
  input   [15:0]  dac_data_14;
  input   [15:0]  dac_data_15;
  input           scan_mode;      // DFT Scan Mode Enable

  // Primary Outputs
  output          dac_clk_out_p;
  output          dac_clk_out_n;
  output  [13:0]  dac_data_out_a_p;
  output  [13:0]  dac_data_out_a_n;
  output  [13:0]  dac_data_out_b_p;
  output  [13:0]  dac_data_out_b_n;
  output          dac_clk;        // Buffered primary clock output
  output          dac_div_clk;    // Divided clock output (functional)
  output          dac_status;

  // Internal signals
  reg             dac_status_reg; // Internal register for dac_status
  wire            dac_clk_in_s;
  wire            dac_div_clk_s;
  wire            dac_div_clk_internal; // Internally generated divided clock
  wire            clk_mux_out;     // Clock signal after DFT mux

  // Clock Generation Logic
  IBUFGDS i_dac_clk_in_ibuf (
    .I (dac_clk_in_p),
    .IB (dac_clk_in_n),
    .O (dac_clk_in_s));

  BUFG i_dac_clk_in_gbuf (
    .I (dac_clk_in_s),
    .O (dac_clk)); // dac_clk is derived from primary input, usable as test clock

  BUFR #(.BUFR_DIVIDE("4")) i_dac_div_clk_rbuf (
    .CLR (1'b0), // Consider reset connection for BUFR if needed
    .CE (1'b1),
    .I (dac_clk_in_s),
    .O (dac_div_clk_s));

  BUFG i_dac_div_clk_gbuf (
    .I (dac_div_clk_s),
    .O (dac_div_clk_internal)); // Internal divided clock

  // Assign internal divided clock to output port
  assign dac_div_clk = dac_div_clk_internal;

  // DFT Clock Mux: Select between functional divided clock and test clock (dac_clk)
  // In functional mode (scan_mode=0), use dac_div_clk_internal
  // In test mode (scan_mode=1), use dac_clk (derived from primary input)
  assign clk_mux_out = scan_mode ? dac_clk : dac_div_clk_internal;

  // Status Register - Clocked by muxed clock, with asynchronous reset
  always @(posedge clk_mux_out or posedge dac_rst) begin
    if (dac_rst == 1'b1) begin
      dac_status_reg <= 1'd0;
    end else begin
      // In functional mode, clocked by dac_div_clk_internal
      // In scan mode, clocked by dac_clk
      dac_status_reg <= 1'd1; // Original logic maintained
    end
  end
  assign dac_status = dac_status_reg; // Assign register output to port

  // SerDes Instances - Use the muxed clock for div_clk input
  ad_serdes_out #(
    .SERDES(1),
    .DATA_WIDTH(14),
    .DEVICE_TYPE (PCORE_DEVICE_TYPE))
  i_serdes_out_data_a (
    .rst (dac_rst),
    .clk (dac_clk),           // High-speed clock (derived from primary input)
    .div_clk (clk_mux_out),   // Use muxed clock for internal logic
    .data_s0 (dac_data_00[15:2]),
    .data_s1 (dac_data_02[15:2]),
    .data_s2 (dac_data_04[15:2]),
    .data_s3 (dac_data_06[15:2]),
    .data_s4 (dac_data_08[15:2]),
    .data_s5 (dac_data_10[15:2]),
    .data_s6 (dac_data_12[15:2]),
    .data_s7 (dac_data_14[15:2]),
    .data_out_p (dac_data_out_a_p),
    .data_out_n (dac_data_out_a_n));

  ad_serdes_out #(
    .SERDES(1),
    .DATA_WIDTH(14),
    .DEVICE_TYPE (PCORE_DEVICE_TYPE))
  i_serdes_out_data_b (
    .rst (dac_rst),
    .clk (dac_clk),           // High-speed clock
    .div_clk (clk_mux_out),   // Use muxed clock
    .data_s0 (dac_data_01[15:2]),
    .data_s1 (dac_data_03[15:2]),
    .data_s2 (dac_data_05[15:2]),
    .data_s3 (dac_data_07[15:2]),
    .data_s4 (dac_data_09[15:2]),
    .data_s5 (dac_data_11[15:2]),
    .data_s6 (dac_data_13[15:2]),
    .data_s7 (dac_data_15[15:2]),
    .data_out_p (dac_data_out_b_p),
    .data_out_n (dac_data_out_b_n));

  ad_serdes_out #(
    .SERDES(1),
    .DATA_WIDTH(1),
    .DEVICE_TYPE (PCORE_DEVICE_TYPE))
  i_serdes_out_clk (
    .rst (dac_rst),
    .clk (dac_clk),           // High-speed clock
    .div_clk (clk_mux_out),   // Use muxed clock
    .data_s0 (1'b1),
    .data_s1 (1'b0),
    .data_s2 (1'b1),
    .data_s3 (1'b0),
    .data_s4 (1'b1),
    .data_s5 (1'b0),
    .data_s6 (1'b1),
    .data_s7 (1'b0),
    .data_out_p (dac_clk_out_p),
    .data_out_n (dac_clk_out_n));

endmodule