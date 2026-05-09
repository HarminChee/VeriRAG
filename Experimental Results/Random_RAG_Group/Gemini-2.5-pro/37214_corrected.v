`timescale 1ns / 1ps
`timescale 1ns / 1ps
module Top_SR #(parameter WIDTH=170,
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
	input test_i, // Added test mode input
    output clk,
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
wire clk_internal; // Renamed original clk output wire
wire clk_muxed;    // Muxed clock for internal FFs

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
  .I(clk_sr), // clk_sr remains internally generated for output
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
        .clk_out(clk_internal) // Output the generated clock
        );

// Assign the generated clock to the output port
assign clk = clk_internal;

// Mux the clock for internal use based on test_i
assign clk_muxed = test_i ? clk_in : clk_internal;

SR_Control #(.DATA_WIDTH(WIDTH), .CNT_WIDTH(CNT_WIDTH), .SHIFT_DIRECTION(SHIFT_DIRECTION))
     sr_control_0(
         .din(din),
         .clk(clk_muxed), // Use muxed clock
         .rst(rst),
         .start(start),
         .data_out(data_out),
         .load_sr(load_sr),
         .count_delay(count_delay)
        );

reg start_reg;
wire start_tmp;
assign start_tmp=start_reg;
always@(posedge clk_muxed or posedge rst) // Use muxed clock
 begin
  if(rst)
  begin
  start_reg<=0;
  end
 else
  begin
  start_reg<=start;
  end
 end

Clock_SR #(.WIDTH(WIDTH), .CNT_WIDTH(CNT_WIDTH), .COUNT_WIDTH(COUNT_WIDTH), .DIV_WIDTH(DIV_WIDTH))
   clock_sr_0(
        .clk_in(clk_in), // Use primary clock for potential internal FFs if any
        .rst(rst),
        .count(count_delay),
        .counter(counter),
        .start(start),
        .start_tmp(start_tmp),
        .div(div),
        .clk_sr(clk_sr) // Output the generated clock sr
   );

assign trig= (READ_TRIG_SRC==1)? load_sr: start;

Receive_Data #(.DATA_WIDTH(WIDTH), .CNT_WIDTH(CNT_WIDTH), .SHIFT_DIRECTION(SHIFT_DIRECTION), .READ_DELAY(READ_DELAY))
     receive_data_0(
        .data_in(data_in),
        .clk(clk_muxed), // Use muxed clock
        .rst(rst),
        .start(trig),
        .valid(valid),
        .dout(dout)
        );
endmodule