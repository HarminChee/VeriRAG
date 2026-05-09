`timescale 1ns/1ps

module I2C_wr(
    sda,scl,ack,rst_n,clk,WR,RD,data,maddress_sel
);

input  rst_n,WR,RD,clk;
input  maddress_sel;
output scl,ack;
inout [7:0] data; 
inout  sda;

reg link_sda,link_data;
reg[7:0] data_buf;
reg scl,ack,WF,RF,FF;
reg wr_state;
reg head_state;
reg[8:0] sh8out_state;
reg[9:0] sh8in_state;
reg stop_state;
reg[5:0] main_state; // Changed from [6:0] to [5:0] to match parameter width
reg[7:0] data_from_rm;
reg[7:0] cnt_read;
reg[7:0] cnt_write;

assign sda  = (link_sda)   ? data_buf[7] : 1'bz;
assign data = (link_data)  ? data_from_rm : 8'hz;

parameter page_write_num = 8'd32, // Changed from 10'd32 to 8'd32 to match cnt_write width
         page_read_num  = 8'd32;  // Changed from 10'd32 to 8'd32 to match cnt_read width

parameter
        idle         = 6'b000001,
        ready        = 6'b000010, 
        write_start  = 6'b000100,
        addr_write   = 6'b001000,
        data_read    = 6'b010000,
        stop         = 6'b100000;

parameter
        bit7     = 9'b0_0000_0001,
        bit6     = 9'b0_0000_0010,
        bit5     = 9'b0_0000_0100,
        bit4     = 9'b0_0000_1000,
        bit3     = 9'b0_0001_0000,
        bit2     = 9'b0_0010_0000,
        bit1     = 9'b0_0100_0000,
        bit0     = 9'b0_1000_0000,
        bitend   = 9'b1_0000_0000;

parameter 
        read_begin  = 10'b00_0000_0001,
        read_bit7   = 10'b00_0000_0010,
        read_bit6   = 10'b00_0000_0100,
        read_bit5   = 10'b00_0000_1000,
        read_bit4   = 10'b00_0001_0000,
        read_bit3   = 10'b00_0010_0000,
        read_bit2   = 10'b00_0100_0000,
        read_bit1   = 10'b00_1000_0000,
        read_bit0   = 10'b01_0000_0000,
        read_end    = 10'b10_0000_0000;

// Rest of the code remains unchanged
// ... 

endmodule