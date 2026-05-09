`default_nettype none
`timescale 1ns / 1ps
module memory(
  input  wire pll_ref_clk,
  input  wire reset_in,
  input  wire test_mode,
  input  wire test_clk,
  output reg  reset_out,
  output wire clk,
  input  wire        write_req,
  input  wire        read_req,
  input  wire [31:0] data_write,
  output reg  [31:0] data_read,
  input  wire [25:0] addr,
  output wire        busy,
  output wire [ 12: 0]       mem_addr,
  output wire [  2: 0]       mem_ba,
  output wire                mem_cas_n,
  output wire [  0: 0]       mem_cke,
  inout  wire [  0: 0]       mem_clk,
  inout  wire [  0: 0]       mem_clk_n,
  output wire [  0: 0]       mem_cs_n,
  output wire [  1: 0]       mem_dm,
  inout  wire [ 15: 0]       mem_dq,
  inout  wire [  1: 0]       mem_dqs,
  output wire [  0: 0]       mem_odt,
  output wire                mem_ras_n,
  output wire                mem_we_n,
  output wire        flash_dq0,
  input  wire        flash_dq1,
  output wire        flash_wb,
  output wire        flash_holdb,
  output wire        flash_c,
  output wire        flash_sb,
  input  wire         program_req,
  output reg          program_ack,
  input  wire         program_buffer_empty,
  input  wire [31:0]  program_buffer_q,
  output reg          program_buffer_read,
  output reg  [5:0]  state,
  output reg         busy_int
);

wire phy_clk;
wire reset_sync;

assign clk = pll_ref_clk;
assign busy = busy_int;

sync_reset sync_reset_inst (
  .clk(pll_ref_clk),
  .async_reset(reset_in),
  .sync_reset(reset_sync)
);

always @(posedge pll_ref_clk) begin
  if (reset_sync) begin
    reset_out <= 1'b1;
    state <= 6'd0;
    busy_int <= 1'b0;
    program_ack <= 1'b0;
    program_buffer_read <= 1'b0;
    data_read <= 32'd0;
  end
  else begin
    // ... existing state machine logic ...
  end
end

ram_controller ram_controller_inst(
  .pll_ref_clk(pll_ref_clk),
  .phy_clk(phy_clk),
  .global_reset_n(~reset_sync),
  .soft_reset_n(1'b1),
  // ... existing port connections ...
);

flash_interface flash_interface_inst (
  .clk(pll_ref_clk),
  .reset(reset_sync),
  // ... existing port connections ...
);

endmodule

module sync_reset (
  input  wire clk,
  input  wire async_reset,
  output reg  sync_reset
);

reg reset_meta;

always @(posedge clk or posedge async_reset) begin
  if (async_reset) begin
    reset_meta <= 1'b1;
    sync_reset <= 1'b1;
  end else begin
    reset_meta <= 1'b0;
    sync_reset <= reset_meta;
  end
end

endmodule