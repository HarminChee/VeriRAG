`timescale 1ns/100ps

module up_adc_common (
  // MMCM Reset
  output          mmcm_rst,
  // ADC Interface
  input           adc_clk,
  output          adc_rst,
  output          adc_r1_mode,
  output          adc_ddr_edgesel,
  output          adc_pin_mode,
  input           adc_status,
  input           adc_sync_status,
  input           adc_status_ovf,
  input           adc_status_unf,
  input   [31:0]  adc_clk_ratio,
  output  [31:0]  adc_start_code,
  output          adc_sync,
  // Status Interface
  input           up_status_pn_err,
  input           up_status_pn_oos,
  input           up_status_or,
  // DRP Interface
  output          up_drp_sel,
  output          up_drp_wr,
  output  [11:0]  up_drp_addr,
  output  [15:0]  up_drp_wdata,
  input   [15:0]  up_drp_rdata,
  input           up_drp_ready,
  input           up_drp_locked,
  // Channel Interface
  output  [ 7:0]  up_usr_chanmax,
  input   [ 7:0]  adc_usr_chanmax,
  // GPIO Interface
  input   [31:0]  up_adc_gpio_in,
  output  [31:0]  up_adc_gpio_out,
  // UP Interface
  input           up_rstn,
  input           up_clk,
  input           up_wreq,
  input   [13:0]  up_waddr,
  input   [31:0]  up_wdata,
  output          up_wack,
  input           up_rreq,
  input   [13:0]  up_raddr,
  output  [31:0]  up_rdata,
  output          up_rack);

  localparam  PCORE_VERSION = 32'h00090062;
  parameter   ID = 0;

  // MMCM Reset (Driven by ad_rst instance)
  output wire     mmcm_rst;
  // ADC Interface (Driven by ad_rst and up_xfer_cntrl instances)
  output wire     adc_rst;
  output wire     adc_r1_mode;
  output wire     adc_ddr_edgesel;
  output wire     adc_pin_mode;
  output wire [31:0] adc_start_code;
  output wire     adc_sync;
  // DRP Interface (Driven by internal registers)
  output reg      up_drp_sel = 'd0;
  output reg      up_drp_wr = 'd0;
  output reg [11:0] up_drp_addr = 'd0;
  output reg [15:0] up_drp_wdata = 'd0;
  // Channel Interface (Driven by internal registers)
  output reg [ 7:0] up_usr_chanmax = 'd0;
  // GPIO Interface (Driven by internal registers)
  output reg [31:0] up_adc_gpio_out = 'd0;
  // UP Interface (Driven by internal registers)
  output reg      up_wack = 'd0;
  output reg [31:0] up_rdata = 'd0;
  output reg      up_rack = 'd0;

  // internal registers
  reg             up_core_preset = 1'd1; // Initialize preset to ensure reset on startup before up_rstn is active
  reg             up_mmcm_preset = 1'd1; // Initialize preset
  reg     [31:0]  up_scratch = 'd0;
  reg             up_mmcm_resetn = 'd0;
  reg             up_resetn = 'd0;
  reg             up_adc_r1_mode_int = 'd0;
  reg             up_adc_ddr_edgesel_int = 'd0;
  reg             up_adc_pin_mode_int = 'd0;
  reg             up_drp_status = 'd0;
  reg             up_drp_rwn = 'd0;
  reg     [15:0]  up_drp_rdata_hold = 'd0;
  reg             up_status_ovf = 'd0;
  reg             up_status_unf = 'd0;
  reg     [31:0]  up_adc_start_code_int = 'd0;
  reg             up_adc_sync_int = 'd0;

  // internal wires
  wire            up_wreq_s;
  wire            up_rreq_s;
  wire            up_status_s;
  wire            up_sync_status_s;
  wire            up_status_ovf_s;
  wire            up_status_unf_s;
  wire            up_cntrl_xfer_done;
  wire    [31:0]  up_adc_clk_count_s;

  // request decoding
  assign up_wreq_s = (up_waddr[13:8] == 6'h00) ? up_wreq : 1'b0;
  assign up_rreq_s = (up_raddr[13:8] == 6'h00) ? up_rreq : 1'b0;

  // processor write interface
  always @(posedge up_clk or negedge up_rstn) begin
    if (up_rstn == 1'b0) begin
      up_core_preset <= 1'd1;
      up_mmcm_preset <= 1'd1;
      up_wack <= 'd0;
      up_scratch <= 'd0;
      up_mmcm_resetn <= 'd0;
      up_resetn <= 'd0;
      up_adc_r1_mode_int <= 'd0;
      up_adc_ddr_edgesel_int <= 'd0;
      up_adc_pin_mode_int <= 'd0;
      up_drp_sel <= 'd0;
      up_drp_wr <= 'd0;
      up_drp_status <= 'd0;
      up_drp_rwn <= 'd0;
      up_drp_addr <= 'd0;
      up_drp_wdata <= 'd0;
      up_drp_rdata_hold <= 'd0;
      up_status_ovf <= 'd0;
      up_status_unf <= 'd0;
      up_usr_chanmax <= 'd0;
      up_adc_gpio_out <= 'd0;
      up_adc_start_code_int <= 'd0;
      up_adc_sync_int <= 'd0;
    end else begin
      up_core_preset <= ~up_resetn;
      up_mmcm_preset <= ~up_mmcm_resetn;
      up_wack <= up_wreq_s;

      if ((up_wreq_s == 1'b1) && (up_waddr[7:0] == 8'h02)) begin
        up_scratch <= up_wdata;
      end
      if ((up_wreq_s == 1'b1) && (up_waddr[7:0] == 8'h10)) begin
        up_mmcm_resetn <= up_wdata[1];
        up_resetn <= up_wdata[0];
      end

      // ADC Sync logic - set by write, cleared by transfer done
      if (up_adc_sync_int == 1'b1) begin
        if (up_cntrl_xfer_done == 1'b1) begin
          up_adc_sync_int <= 1'b0;
        end
      end else if ((up_wreq_s == 1'b1) && (up_waddr[7:0] == 8'h11)) begin
        up_adc_sync_int <= up_wdata[3]; // Set sync if written
      end

      // ADC Control bits
      if ((up_wreq_s == 1'b1) && (up_waddr[7:0] == 8'h11)) begin
        up_adc_r1_mode_int <= up_wdata[2];
        up_adc_ddr_edgesel_int <= up_wdata[1];
        up_adc_pin_mode_int <= up_wdata[0];
      end

      // DRP control logic
      if ((up_wreq_s == 1'b1) && (up_waddr[7:0] == 8'h1c)) begin
        up_drp_sel <= 1'b1;
        up_drp_wr <= ~up_wdata[28]; // DRP write is active low on the interface?
        up_drp_rwn <= up_wdata[28]; // Internal flag for read/write
        up_drp_addr <= up_wdata[27:16];
        up_drp_wdata <= up_wdata[15:0];
        up_drp_status <= 1'b1; // Indicate DRP operation started
      end else begin
        up_drp_sel <= 1'b0;
        up_drp_wr <= 1'b0; // Default to inactive
        // Don't reset addr/wdata here, might be needed for readback
        if (up_drp_ready == 1'b1) begin // Clear status when DRP is done
             up_drp_status <= 1'b0;
        end
      end

      // Hold DRP read data
      if (up_drp_ready == 1'b1 && up_drp_rwn == 1'b1) begin // Hold only on read completion
        up_drp_rdata_hold <= up_drp_rdata;
      end

      // Status flags (sticky, clear on write)
      if (up_status_ovf_s == 1'b1) begin
        up_status_ovf <= 1'b1;
      end else if ((up_wreq_s == 1'b1) && (up_waddr[7:0] == 8'h22)) begin
        up_status_ovf <= up_status_ovf & ~up_wdata[2]; // Clear if written bit is 1
      end

      if (up_status_unf_s == 1'b1) begin
        up_status_unf <= 1'b1;
      end else if ((up_wreq_s == 1'b1) && (up_waddr[7:0] == 8'h22)) begin
        up_status_unf <= up_status_unf & ~up_wdata[1]; // Clear if written bit is 1
      end

      // Other write registers
      if ((up_wreq_s == 1'b1) && (up_waddr[7:0] == 8'h28)) begin
        up_usr_chanmax <= up_wdata[7:0];
      end
      if ((up_wreq_s == 1'b1) && (up_waddr[7:0] == 8'h29)) begin
        up_adc_start_code_int <= up_wdata[31:0];
      end
      if ((up_wreq_s == 1'b1) && (up_waddr[7:0] == 8'h2f)) begin
        up_adc_gpio_out <= up_wdata;
      end
    end
  end

  // processor read interface
  always @(posedge up_clk or negedge up_rstn) begin
    if (up_rstn == 1'b0) begin
      up_rack <= 'd0;
      up_rdata <= 'd0;
    end else begin
      up_rack <= up_rreq_s; // Acknowledge read request on the next cycle
      if (up_rreq_s == 1'b1) begin
        case (up_raddr[7:0])
          8'h00: up_rdata <= PCORE_VERSION;
          8'h01: up_rdata <= {{(32-($bits(ID))) {1'b0}}, ID}; // Ensure 32-bit width for ID
          8'h02: up_rdata <= up_scratch;
          8'h10: up_rdata <= {30'd0, up_mmcm_resetn, up_resetn};
          8'h11: up_rdata <= {28'd0, up_adc_sync_int, up_adc_r1_mode_int, up_adc_ddr_edgesel_int, up_adc_pin_mode_int}; // Read internal regs
          8'h15: up_rdata <= up_adc_clk_count_s;
          8'h16: up_rdata <= adc_clk_ratio;
          8'h17: up_rdata <= {28'd0, up_status_pn_err, up_status_pn_oos, up_status_or, up_status_s};
          8'h1a: up_rdata <= {31'd0, up_sync_status_s};
          8'h1c: up_rdata <= {3'd0, up_drp_rwn, up_drp_addr, up_drp_wdata}; // Read back DRP command regs
          8'h1d: up_rdata <= {14'd0, up_drp_locked, up_drp_status, up_drp_rdata_hold}; // Read DRP status and held data
          8'h22: up_rdata <= {29'd0, up_status_ovf, up_status_unf, 1'b0}; // Bit 0 reserved/unused
          8'h23: up_rdata <= 32'd8; // Fixed value? Represents number of channels?
          8'h28: up_rdata <= {24'd0, adc_usr_chanmax}; // Read back actual channel max from ADC core
          8'h29: up_rdata <= up_adc_start_code_int; // Read back internal start code reg
          8'h2e: up_rdata <= up_adc_gpio_in;
          8'h2f: up_rdata <= up_adc_gpio_out;
          default: up_rdata <= 32'd0;
        endcase
      end else begin
        up_rdata <= 32'd0; // Default value when not reading
      end
    end
  end

  // Instantiations
  ad_rst i_mmcm_rst_reg (.preset(up_mmcm_preset), .clk(up_clk),  .rst(mmcm_rst));
  ad_rst i_core_rst_reg (.preset(up_core_preset), .clk(adc_clk), .rst(adc_rst));

  up_xfer_cntrl #(.DATA_WIDTH(36)) i_xfer_cntrl (
    .up_rstn (up_rstn),
    .up_clk (up_clk),
    .up_data_cntrl ({ up_adc_sync_int, // Use internal reg values
                      up_adc_start_code_int,
                      up_adc_r1_mode_int,
                      up_adc_ddr_edgesel_int,
                      up_adc_pin_mode_int}),
    .up_xfer_done (up_cntrl_xfer_done),
    .d_rst (adc_rst), // Use generated adc_rst
    .d_clk (adc_clk),
    .d_data_cntrl ({  adc_sync,       // Drive output ports
                      adc_start_code,
                      adc_r1_mode,
                      adc_ddr_edgesel,
                      adc_pin_mode}));

  up_xfer_status #(.DATA_WIDTH(4)) i_xfer_status (
    .up_rstn (up_rstn),
    .up_clk (up_clk),
    .up_data_status ({up_sync_status_s, // Drive internal wires for readback/flag generation
                      up_status_s,
                      up_status_ovf_s,
                      up_status_unf_s}),
    .d_rst (adc_rst), // Use generated adc_rst
    .d_clk (adc_clk),
    .d_data_status ({ adc_sync_status, // Read input ports
                      adc_status,
                      adc_status_ovf,
                      adc_status_unf}));

  up_clock_mon i_clock_mon (
    .up_rstn (up_rstn),
    .up_clk (up_clk),
    .up_d_count (up_adc_clk_count_s), // Drive internal wire for readback
    .d_rst (adc_rst), // Use generated adc_rst
    .d_clk (adc_clk)); // Monitor adc_clk

endmodule