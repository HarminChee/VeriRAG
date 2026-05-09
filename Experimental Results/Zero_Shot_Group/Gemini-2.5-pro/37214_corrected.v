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
reg start_reg;
wire start_sync; // Renamed for clarity

IBUFDS #(.DIFF_TERM("TRUE")) // Assuming IBUFDS primitive exists
  IBUFDS_inst (
  .O(data_in),
  .I(data_in_p),
  .IB(data_in_n)
  );

OBUFDS OBUFDS_inst1 ( // Assuming OBUFDS primitive exists
  .I(data_out),
  .O(data_out_p),
  .OB(data_out_n)
  );

OBUFDS OBUFDS_inst2 ( // Assuming OBUFDS primitive exists
  .I(clk_sr),
  .O(clk_sr_p),
  .OB(clk_sr_n)
  );

OBUFDS OBUFDS_inst3 ( // Assuming OBUFDS primitive exists
  .I(load_sr),
  .O(load_sr_p),
  .OB(load_sr_n)
  );

Clock_Div #(.DIV_WIDTH(DIV_WIDTH), .COUNT_WIDTH(COUNT_WIDTH)) // Assuming Clock_Div module exists
    clock_div_0(
        .clk_in(clk_in),
        .rst(rst),
        .div(div),
        .counter(counter),
        .clk_out(clk)
        );

SR_Control #(.DATA_WIDTH(WIDTH), .CNT_WIDTH(CNT_WIDTH), .SHIFT_DIRECTION(SHIFT_DIRECTION)) // Assuming SR_Control module exists
     sr_control_0(
         .din(din),
         .clk(clk),
         .rst(rst),
         .start(start_sync), // Use synchronized start
         .data_out(data_out),
         .load_sr(load_sr),
         .count_delay(count_delay)
        );

// Synchronize start signal to the generated clock 'clk' domain
assign start_sync = start_reg;
always@(posedge clk or posedge rst)
 begin
  if(rst)
  begin
    start_reg <= 1'b0;
  end
 else
  begin
    start_reg <= start; // Capture external start
  end
 end

Clock_SR #(.WIDTH(WIDTH), .CNT_WIDTH(CNT_WIDTH), .COUNT_WIDTH(COUNT_WIDTH), .DIV_WIDTH(DIV_WIDTH)) // Assuming Clock_SR module exists
   clock_sr_0(
        .clk_in(clk_in),
        .rst(rst),
        .count(count_delay),
        .counter(counter),
        .start(start_sync), // Use synchronized start signal
        //.start_tmp(start_tmp), // Removed redundant/confusing input
        .div(div),
        .clk_sr(clk_sr)
   );

// Trigger logic for Receive_Data
assign trig = (READ_TRIG_SRC == 1) ? load_sr : start_sync; // Use synchronized start for consistency if READ_TRIG_SRC = 0

Receive_Data #(.DATA_WIDTH(WIDTH), .CNT_WIDTH(CNT_WIDTH), .SHIFT_DIRECTION(SHIFT_DIRECTION), .READ_DELAY(READ_DELAY)) // Assuming Receive_Data module exists
     receive_data_0(
        .data_in(data_in),
        .clk(clk),
        .rst(rst),
        .start(trig), // Use the generated trigger signal
        .valid(valid),
        .dout(dout)
        );

endmodule