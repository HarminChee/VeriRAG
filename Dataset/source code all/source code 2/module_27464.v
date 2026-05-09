module spi_slave(clk, mosi, miso, sck, cs, tx_data, rx_data, rx_ready);
  parameter DATA_LEN = 32;
  input clk, sck;
  input cs; 
  input mosi;
  output miso;  
  output [DATA_LEN - 1:0] rx_data;
  input [DATA_LEN - 1:0] tx_data;
  output rx_ready;
  reg [DATA_LEN - 1:0] trx_buffer;
  reg [2:0] sck_sync, ssel_sync;
  always @(posedge clk) begin
    sck_sync <= {sck, sck_sync[2:1]};
    ssel_sync <= {cs, ssel_sync[2:1]};
  end
  wire sck_posedge = sck_sync[1:0] == 2'b10;
  wire sck_negedge = sck_sync[1:0] == 2'b01;
  wire ssel_posedge = ssel_sync[1:0] == 2'b10;
  wire ssel_negedge = ssel_sync[1:0] == 2'b01;
  wire ssel_active = ssel_sync[0] == 0;
  reg mosi_mem;
  reg [7:0] bit_count;
  always @(posedge clk) begin
    if (ssel_negedge) begin
      trx_buffer = tx_data;
	  bit_count = 0;
    end
    else if (sck_posedge) begin
		mosi_mem = mosi;
    end
    else if (sck_negedge) begin
      trx_buffer = {mosi_mem, trx_buffer[DATA_LEN - 1: 1]};
	  bit_count = bit_count + 1;
    end
  end
  assign miso = ssel_active ? trx_buffer[0] : 1'bz;
  assign rx_ready = ssel_active && (bit_count == DATA_LEN);
  assign rx_data = trx_buffer;
endmodule
