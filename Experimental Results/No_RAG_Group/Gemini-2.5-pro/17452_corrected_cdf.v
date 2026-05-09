`define CLKDEL_PIPE_SZ 3
`define RIPPLE_DIVIDER
`ifdef USE_DIVIDER_23
  `define USE_LATCH_ENABLE 1
`endif
`define SINGLE_HS_RETIMER 1
// Note: Original defines are kept, but implementation might override their original intent (e.g., RIPPLE_DIVIDER implemented synchronously)

module clkctrl_phi2_corrected_cdf (
               input  hsclk_in,
               input  lsclk_in,
               input  rst_b,          // Original async active low reset
               input  hsclk_sel,
               input  delay_bypass,
               input  cpuclk_div_sel,
               output hsclk_selected,
               output lsclk_selected,
               output clkout,
               output fast_clkout
               );

  // Use a synchronous active high reset derived from rst_b
  // This assumes rst_b is asserted asynchronously but deasserted synchronously to the fastest clock,
  // or appropriate reset synchronization is handled externally.
  // For simplicity here, we derive a signal. Proper reset handling might need more context.
  wire rst_sync = !rst_b;

  reg                      hs_enable_q, ls_enable_q;
  reg                      selected_ls_q;
  reg                      selected_hs_q;
`ifdef SINGLE_HS_RETIMER
  reg                      retimed_ls_enable_q;
`else
  reg [1:0]                retimed_ls_enable_q;
`endif
  reg                      retimed_hs_enable_q;
  reg [`CLKDEL_PIPE_SZ-1:0] del_q;
  wire                     retimed_ls_enable_w;
  (* KEEP="TRUE" *) wire  cpuclk_w;
  (* KEEP="TRUE" *) wire  lsclk_del_w;

  assign lsclk_del_w = (delay_bypass) ? lsclk_in :