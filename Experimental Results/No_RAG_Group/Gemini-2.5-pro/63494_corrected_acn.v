`timescale 1 ns / 1 ns
module altera_avalon_st_jtag_interface_corrected_acn #(
    parameter PURPOSE = 0,
    parameter UPSTREAM_FIFO_SIZE = 0,
    parameter DOWNSTREAM_FIFO_SIZE = 0,
    parameter MGMT_CHANNEL_WIDTH = -1,
    parameter EXPORT_JTAG = 0,
    parameter USE_PLI = 0,
    parameter PLI_PORT = 50000
) (
    // JTAG Ports
    input  wire       jtag_tck,
    input  wire       jtag_tms,
    input  wire       jtag_tdi,
    output wire       jtag_tdo,
    input  wire       jtag_ena,
    input  wire       jtag_usr1,
    input  wire       jtag_clr,    // Unused in this module directly, potentially used by submodules
    input  wire       jtag_clrn,   // Unused in this module directly, potentially used by submodules