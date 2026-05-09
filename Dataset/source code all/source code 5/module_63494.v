`timescale 1 ns / 1 ns
`timescale 1 ns / 1 ns
module altera_avalon_st_jtag_interface #(
    parameter PURPOSE = 0, 
    parameter UPSTREAM_FIFO_SIZE = 0,
    parameter DOWNSTREAM_FIFO_SIZE = 0,
    parameter MGMT_CHANNEL_WIDTH = -1,
    parameter EXPORT_JTAG = 0,
    parameter USE_PLI = 0,      
    parameter PLI_PORT = 50000  
) (
    input  wire       jtag_tck,
    input  wire       jtag_tms,
    input  wire       jtag_tdi,
    output wire       jtag_tdo,
    input  wire       jtag_ena,
    input  wire       jtag_usr1,
    input  wire       jtag_clr,
    input  wire       jtag_clrn,
    input  wire       jtag_state_tlr,
    input  wire       jtag_state_rti,
    input  wire       jtag_state_sdrs,
    input  wire       jtag_state_cdr,
    input  wire       jtag_state_sdr,
    input  wire       jtag_state_e1dr,
    input  wire       jtag_state_pdr,
    input  wire       jtag_state_e2dr,
    input  wire       jtag_state_udr,
    input  wire       jtag_state_sirs,
    input  wire       jtag_state_cir,
    input  wire       jtag_state_sir,
    input  wire       jtag_state_e1ir,
    input  wire       jtag_state_pir,
    input  wire       jtag_state_e2ir,
    input  wire       jtag_state_uir,
    input  wire [2:0] jtag_ir_in,
    output wire       jtag_irq,
    output wire [2:0] jtag_ir_out,
    input  wire       clk,
    input  wire       reset_n,
    input  wire       source_ready,
    output wire [7:0] source_data,
    output wire       source_valid,
    input  wire [7:0] sink_data,
    input  wire       sink_valid,
    output wire       sink_ready,
    output wire       resetrequest,
    output wire       debug_reset,
    output wire       mgmt_valid,
    output wire [(MGMT_CHANNEL_WIDTH>0?MGMT_CHANNEL_WIDTH:1)-1:0] mgmt_channel,
    output wire       mgmt_data
);
  wire       tck;
  wire       tdi;
  wire       tdo;
  wire [2:0] ir_in;
  wire       virtual_state_cdr;
  wire       virtual_state_sdr;
  wire       virtual_state_udr;
  assign jtag_irq = 1'b0;
  assign jtag_ir_out = 3'b000;
  generate
    if (EXPORT_JTAG == 0) begin
      altera_jtag_sld_node node (
        .tck                (tck),
        .tdi                (tdi),
        .tdo                (tdo),
        .ir_out             (1'b0),
        .ir_in              (ir_in),
        .virtual_state_cdr  (virtual_state_cdr),
        .virtual_state_cir  (),
        .virtual_state_e1dr (),
        .virtual_state_e2dr (),
        .virtual_state_pdr  (),
        .virtual_state_sdr  (virtual_state_sdr),
        .virtual_state_udr  (virtual_state_udr),
        .virtual_state_uir  ()
      );
      assign jtag_tdo = 1'b0;
    end else begin
      assign tck = jtag_tck;
      assign tdi = jtag_tdi;
      assign jtag_tdo = tdo;
      assign ir_in = jtag_ir_in;
      assign virtual_state_cdr = jtag_ena && !jtag_usr1 && jtag_state_cdr;
      assign virtual_state_sdr = jtag_ena && !jtag_usr1 && jtag_state_sdr;
      assign virtual_state_udr = jtag_ena && !jtag_usr1 && jtag_state_udr;
    end
  endgenerate
  generate 
    if (USE_PLI == 0)
      begin : normal
        altera_jtag_dc_streaming #(
          .PURPOSE(PURPOSE),
          .UPSTREAM_FIFO_SIZE(UPSTREAM_FIFO_SIZE),
          .DOWNSTREAM_FIFO_SIZE(DOWNSTREAM_FIFO_SIZE),
          .MGMT_CHANNEL_WIDTH(MGMT_CHANNEL_WIDTH)
        ) jtag_dc_streaming (
          .tck              (tck),
          .tdi              (tdi),
          .tdo              (tdo),
          .ir_in            (ir_in),
          .virtual_state_cdr(virtual_state_cdr),
          .virtual_state_sdr(virtual_state_sdr),
          .virtual_state_udr(virtual_state_udr),
          .clk(clk),
          .reset_n(reset_n),
          .source_data(source_data),
          .source_valid(source_valid),
          .sink_data(sink_data),
          .sink_valid(sink_valid),
          .sink_ready(sink_ready),
          .resetrequest(resetrequest),
          .debug_reset(debug_reset),
          .mgmt_valid(mgmt_valid),
          .mgmt_channel(mgmt_channel),
          .mgmt_data(mgmt_data)
        );
      end
    else
      begin : pli_mode
        reg pli_out_valid;
        reg pli_in_ready;
        reg [7 : 0] pli_out_data;
        always @(posedge clk or negedge reset_n) begin
          if (!reset_n) begin
            pli_out_valid <= 0;
            pli_out_data <= 'b0;
            pli_in_ready <= 0;
          end
          else begin
            `ifdef MODEL_TECH
              $do_transaction(
                PLI_PORT, 
                pli_out_valid, 
                source_ready, 
                pli_out_data,
                sink_valid,
                pli_in_ready,
                sink_data
              );
            `endif
          end
        end
        wire [7:0] jtag_source_data;
        wire jtag_source_valid;
        wire jtag_sink_ready;
        wire jtag_resetrequest;
        altera_jtag_dc_streaming #(
          .PURPOSE(PURPOSE),
          .UPSTREAM_FIFO_SIZE(UPSTREAM_FIFO_SIZE),
          .DOWNSTREAM_FIFO_SIZE(DOWNSTREAM_FIFO_SIZE),
          .MGMT_CHANNEL_WIDTH(MGMT_CHANNEL_WIDTH)
        ) jtag_dc_streaming (
          .tck              (tck),
          .tdi              (tdi),
          .tdo              (tdo),
          .ir_in            (ir_in),
          .virtual_state_cdr(virtual_state_cdr),
          .virtual_state_sdr(virtual_state_sdr),
          .virtual_state_udr(virtual_state_udr),
          .clk(clk),
          .reset_n(reset_n),
          .source_data(jtag_source_data),
          .source_valid(jtag_source_valid),
          .sink_data(sink_data),
          .sink_valid(sink_valid),
          .sink_ready(jtag_sink_ready),
          .resetrequest(jtag_resetrequest)
        );
	  assign source_valid = pli_out_valid;
          assign source_data = pli_out_data;
          assign sink_ready = pli_in_ready;
          assign resetrequest = 1'b0;
          assign jtag_tdo = 1'b0;
      end
  endgenerate
endmodule
