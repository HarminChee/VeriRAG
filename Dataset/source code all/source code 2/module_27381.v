`timescale 1ns/100ps
`timescale 1ns/100ps
module spi_slave (
  input  wire        clk,
  input  wire        rst,
  input  wire        send,
  input  wire [31:0] send_data,
  input  wire  [3:0] send_valid,
  input  wire [31:0] dataIn,
  output wire [39:0] cmd,
  output wire        execute,
  output wire        busy,
  input  wire        spi_cs_n,
  input  wire        spi_sclk,
  input  wire        spi_mosi,
  output wire        spi_miso
);
reg query_id; 
reg query_metadata;
reg query_dataIn; 
reg dly_execute; 
wire [7:0] opcode;
wire [31:0] opdata;
assign cmd = {opdata,opcode};
full_synchronizer spi_sclk_sync (clk, rst, spi_sclk, sync_sclk);
full_synchronizer spi_cs_n_sync (clk, rst, spi_cs_n, sync_cs_n);
wire [7:0] meta_data;
meta_handler meta_handler(
  .clock           (clk),
  .extReset        (rst),
  .query_metadata  (query_metadata),
  .xmit_idle       (!busy && !send && byteDone),
  .writeMeta       (writeMeta),
  .meta_data       (meta_data)
);
spi_receiver spi_receiver(
  .clk          (clk),
  .rst          (rst),
  .spi_sclk     (sync_sclk),
  .spi_mosi     (spi_mosi),
  .spi_cs_n     (sync_cs_n),
  .transmitting (busy),
  .opcode       (opcode),
  .opdata       (opdata),
  .execute      (execute)
);
spi_transmitter spi_transmitter(
  .clk          (clk),
  .rst          (rst),
  .spi_sclk     (sync_sclk),
  .spi_cs_n     (sync_cs_n),
  .spi_miso     (spi_miso),
  .send         (send),
  .send_data    (send_data),
  .send_valid   (send_valid),
  .writeMeta    (writeMeta),
  .meta_data    (meta_data),
  .query_id     (query_id), 
  .query_dataIn (query_dataIn),
  .dataIn       (dataIn),
  .busy         (busy),
  .byteDone     (byteDone)
);
always @(posedge clk) 
begin
  dly_execute    <= execute;
  if (!dly_execute && execute) begin
    query_id       <= (opcode == 8'h02);
    query_metadata <= (opcode == 8'h04); 
    query_dataIn   <= (opcode == 8'h06);
  end else begin
    query_id       <= 1'b0; 
    query_metadata <= 1'b0;
    query_dataIn   <= 1'b0;
  end
end
endmodule
