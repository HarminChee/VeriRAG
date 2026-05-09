`timescale 1ns / 1ps
module Top_SR_corrected_clk #(parameter WIDTH=170,
                parameter CNT_WIDTH=8,
                parameter DIV_WIDTH=6,
                parameter COUNT_WIDTH=64,
                parameter SHIFT_DIRECTION=1,
                parameter READ_TRIG_SRC=0,
                parameter READ_DELAY=1
   ) (
    input clk_in,
    input rst,
    input start,
    input [WIDTH-1:0] din,
    input data_in_p,
    input data_in_n,
    input [DIV_WIDTH-1:0] div,
    input scan_mode, // Added scan_mode input for DFT
    output clk, // Keep original clk output for potential external use/debug
    output clk_sr_p,
    output clk_sr_n,
    output data_out_p,
    output data_out_n,
    output load_sr_p,
    output load_sr_n,
    output valid,
    output [WIDTH-1:0] dout
    );
wire data_in;
wire data_out;
wire clk_sr;
wire load_sr;
wire trig;
wire [CNT_WIDTH-1:0] count_delay;
wire [COUNT_WIDTH-1:0] counter;
wire clk_internal; // Renamed output of Clock_Div
wire clk_muxed;    // Clock signal after DFT mux

IBUFDS #(.DIFF_TERM("TRUE"))
  IBUFDS_inst (
  .O(data_in),
  .I(data_in_p),
  .IB(data_in_n)
  );
OBUFDS OBUFDS_inst1 (
  .I(data_out),
  .O(data_out_p),
  .OB(data_out_n)
  );
OBUFDS OBUFDS_inst2 (
  .I(clk_sr),
  .O(clk_sr_p),
  .OB(clk_sr_n)
  );
OBUFDS OBUFDS_inst3 (
  .I(load_sr),
  .O(load_sr_p),
  .OB(load_sr_n)
  );
Clock_Div #(.DIV_WIDTH(DIV_WIDTH), .COUNT_WIDTH(COUNT_WIDTH))
    clock_div_0(
        .clk_in(clk_in),
        .rst(rst),
        .div(div),
        .counter(counter),
        .clk_out(clk_internal) // Output internal clock
        );

// DFT Clock Mux: Select primary clock (clk_in) during scan_mode
assign clk_muxed = scan_mode ? clk_in : clk_internal;

// Assign original clk output if needed externally, driven by internal clock
assign clk = clk_internal;

SR_Control #(.DATA_WIDTH(WIDTH), .CNT_WIDTH(CNT_WIDTH), .SHIFT_DIRECTION(SHIFT_DIRECTION))
     sr_control_0(
         .din(din),
         .clk(clk_muxed), // Use DFT-muxed clock
         .rst(rst),
         .start(start),
         .data_out(data_out),
         .load_sr(load_sr),
         .count_delay(count_delay)
        );
reg start_reg;
wire start_tmp;
assign start_tmp=start_reg;
always@(posedge clk_muxed or posedge rst) // Use DFT-muxed clock
 begin
  if(rst)
  begin
  start_reg<=1'b0;
  end
 else
  begin
  // In scan mode, start_reg is part of the chain clocked by clk_in.
  // In functional mode, it captures 'start' based on the divided clock timing.
  start_reg<=start;
  end
 end

// Note: Clock_SR potentially generates another internal clock clk_sr.
// If clk_sr drives FFs needing scan, it would also need DFT modification (e.g., muxing).
// Assuming the primary CLKNPI issue was related to 'clk' driving SR_Control, Receive_Data, and start_reg.
Clock_SR #(.WIDTH(WIDTH), .CNT_WIDTH(CNT_WIDTH), .COUNT_WIDTH(COUNT_WIDTH), .DIV_WIDTH(DIV_WIDTH))
   clock_sr_0(
        .clk_in(clk_in), // Still based on primary clock input
        .rst(rst),
        .count(count_delay),
        .counter(counter),
        .start(start),
        .start_tmp(start_tmp),
        .div(div),
        .clk_sr(clk_sr) // Output clk_sr
   );

assign trig = (READ_TRIG_SRC==1)? load_sr: start;

Receive_Data #(.DATA_WIDTH(WIDTH), .CNT_WIDTH(CNT_WIDTH), .SHIFT_DIRECTION(SHIFT_DIRECTION), .READ_DELAY(READ_DELAY))
     receive_data_0(
        .data_in(data_in),
        .clk(clk_muxed), // Use DFT-muxed clock
        .rst(rst),
        .start(trig),
        .valid(valid),
        .dout(dout)
        );
endmodule