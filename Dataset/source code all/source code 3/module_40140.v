`timescale 1ns/100ps
`timescale 1ns/100ps
module spi_slave(
  clock, extReset, 
  sclk, cs, mosi, dataIn,
  send, send_data, send_valid,
  cmd, execute, busy, miso);
input clock;
input sclk;
input extReset;
input cs;
input send;
input [31:0] send_data;
input [3:0] send_valid;
input [31:0] dataIn;
input mosi;
output [39:0] cmd;
output execute;
output busy;
output miso;
wire [39:0] cmd;
wire execute;
wire busy;
wire miso;
reg query_id, next_query_id; 
reg query_metadata, next_query_metadata;
reg query_dataIn, next_query_dataIn; 
reg dly_execute, next_dly_execute; 
wire [7:0] opcode;
wire [31:0] opdata;
assign cmd = {opdata,opcode};
full_synchronizer sclk_sync (clock, extReset, sclk, sync_sclk);
full_synchronizer cs_sync (clock, extReset, cs, sync_cs);
wire [7:0] meta_data;
meta_handler meta_handler(
  .clock(clock), .extReset(extReset),
  .query_metadata(query_metadata), .xmit_idle(!busy && !send && byteDone),
  .writeMeta(writeMeta), .meta_data(meta_data));
spi_receiver spi_receiver(
  .clock(clock), .sclk(sync_sclk), .extReset(extReset),
  .mosi(mosi), .cs(sync_cs), .transmitting(busy),
  .op(opcode), .data(opdata), .execute(execute));
spi_transmitter spi_transmitter(
  .clock(clock), .sclk(sync_sclk), .extReset(extReset),
  .send(send), .send_data(send_data), .send_valid(send_valid),
  .writeMeta(writeMeta), .meta_data(meta_data),
  .cs(sync_cs), .query_id(query_id), 
  .query_dataIn(query_dataIn), .dataIn(dataIn),
  .tx(miso), .busy(busy), .byteDone(byteDone));
always @(posedge clock) 
begin
  query_id = next_query_id;
  query_metadata = next_query_metadata;
  query_dataIn = next_query_dataIn;
  dly_execute = next_dly_execute;
end
always @*
begin
  #1;
  next_query_id = 1'b0; 
  next_query_metadata = 1'b0;
  next_query_dataIn = 1'b0;
  next_dly_execute = execute;
  if (!dly_execute && execute)
    case (opcode)
      8'h02 : next_query_id = 1'b1;
      8'h04 : next_query_metadata = 1'b1; 
      8'h06 : next_query_dataIn = 1'b1;
    endcase
end
endmodule
