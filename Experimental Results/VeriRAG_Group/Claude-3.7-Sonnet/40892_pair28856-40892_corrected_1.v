module i2c_module(
    input dft_clk,
    input dft_reset_n,
    output reg sda_oe = 1,
    input wire sda_in,
    output reg sda = 1,
    output reg scl_out,
    input[7:0] writedata,
    input write,
    input[2:0] address,
    output reg ready = 1,
    output reg success_out = 0
);

reg[7:0] state_next = 0;
localparam STATE_IDLE = 0;
localparam STATE_ADDRESS_START = 1;
localparam STATE_ADDRESS_START_2 = 111;
localparam STATE_ADDRESS_START_3 = 112;
localparam STATE_ADDRESS_BIT_1 = 2;
localparam STATE_ADDRESS_BIT_2 = 3;
localparam STATE_ADDRESS_BIT_3 = 4;
localparam STATE_ADDRESS_BIT_4 = 5;
localparam STATE_ADDRESS_BIT_5 = 6;
localparam STATE_ADDRESS_BIT_6 = 7;
localparam STATE_ADDRESS_BIT_7 = 8;
localparam STATE_ADDRESS_BIT_8 = 9;
localparam STATE_ADDRESS_ACK = 10;
localparam STATE_TRANSIT_1 = 102;
localparam STATE_REG_BIT_1 = 11;
localparam STATE_REG_BIT_2 = 12;
localparam STATE_REG_BIT_3 = 13;
localparam STATE_REG_BIT_4 = 14;
localparam STATE_REG_BIT_5 = 15;
localparam STATE_REG_BIT_6 = 16;
localparam STATE_REG_BIT_7 = 17;
localparam STATE_REG_BIT_8 = 18;
localparam STATE_REG_ACK = 19;
localparam STATE_TRANSIT_2 = 192;
localparam STATE_DATA_BIT_1 = 20;
localparam STATE_DATA_BIT_2 = 21;
localparam STATE_DATA_BIT_3 = 22;
localparam STATE_DATA_BIT_4 = 23;
localparam STATE_DATA_BIT_5 = 24;
localparam STATE_DATA_BIT_6 = 25;
localparam STATE_DATA_BIT_7 = 26;
localparam STATE_DATA_BIT_8 = 27;
localparam STATE_DATA_ACK = 28;
localparam STATE_STOP = 29;
localparam STATE_STOP_1 = 30;
localparam STATE_STOP_2 = 31;

reg clk_div = 0;
wire clk_div_2;
reg[7:0] divider2 = 0;

always @(posedge dft_clk)
begin
    divider2 <= divider2 + 8'b1;
end

assign clk_div_2 = divider2[7];

always @(posedge clk_div_2)
begin
    clk_div <= ~clk_div;
end

reg [7:0] control_reg = 0;
reg [7:0] slave_address = 0;
reg [7:0] slave_reg_address = 0;
reg [7:0] slave_data_1 = 0;
reg [7:0] slave_data_2 = 0;

endmodule