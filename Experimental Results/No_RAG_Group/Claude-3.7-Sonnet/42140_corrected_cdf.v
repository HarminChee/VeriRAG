module I2C_wr(
sda,scl,ack,rst_n,clk,WR,RD,data,maddress_sel,test_mode
);

input  rst_n,WR,RD,clk,test_mode;
input  maddress_sel;
output scl,ack;
inout [7:0] data; 
inout  sda;

reg link_sda,link_data;
reg[7:0] data_buf;
reg scl_int,ack,WF,RF,FF;
reg wr_state;
reg head_state;
reg[8:0] sh8out_state;
reg[9:0] sh8in_state;
reg stop_state;
reg[6:0] main_state;
reg[7:0] data_from_rm;
reg[7:0] cnt_read;
reg[7:0] cnt_write;

assign scl = scl_int;
assign sda = (link_sda) ? data_buf[7] : 1'bz;
assign data = (link_data) ? data_from_rm : 8'hz;

parameter page_write_num = 10'd32,
         page_read_num = 10'd32;

parameter
        idle = 10'b000_0001,
        ready = 10'b000_0010,
        write_start = 11'b000_0100,
        addr_write = 11'b000_1000,
        data_read = 11'b001_0000,
        stop = 11'b010_0000,
        ackn = 11'b100_0000;
        
parameter
        bit7 = 9'b0_0000_0001,
        bit6 = 9'b0_0000_0010,
        bit5 = 9'b0_0000_0100,
        bit4 = 9'b0_0000_1000,
        bit3 = 9'b0_0001_0000,
        bit2 = 9'b0_0010_0000,
        bit1 = 9'b0_0100_0000,
        bit0 = 9'b0_1000_0000,
        bitend = 9'b1_0000_0000;
        
parameter 
        read_begin = 10'b00_0000_0001,
        read_bit7 = 10'b00_0000_0010,
        read_bit6 = 10'b00_0000_0100,
        read_bit5 = 10'b00_0000_1000,
        read_bit4 = 10'b00_0001_0000,
        read_bit3 = 10'b00_0010_0000,
        read_bit2 = 10'b00_0100_0000,
        read_bit1 = 10'b00_1000_0000,
        read_bit0 = 10'b01_0000_0000,
        read_end = 10'b10_0000_0000;

reg clk_div;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        clk_div <= 1'b0;
    else
        clk_div <= ~clk_div;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        scl_int <= 1'b0;
    else if(test_mode)
        scl_int <= 1'b0;
    else
        scl_int <= clk_div;
end

// Rest of the code remains unchanged
// ... existing code ...

endmodule