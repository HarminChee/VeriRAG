`timescale 1ns / 1ps
module LCD_dis(
    input clk,
    input[127:0] num,
    input reset,
    output reg lcd_rs,
    output lcd_rw,
    output reg lcd_e,
    output reg[3:0] lcd_d,
    output flash_ce
    );

assign flash_ce = 1;
assign lcd_rw = 0;
reg [19:0] delay_count;
reg [19:0] num_count;
wire[7:0] ascii;
wire[3:0] hex;
reg[4:0] dis_count;
reg [5:0] state;
reg [5:0] next_state;

assign ascii = (hex[3] & (hex[2] | hex[1]))? (8'h37 + {4'h0,hex}) : {4'h3 ,hex};
assign hex = 
    {4{(dis_count == 5'h1F)}} & num[3:0] |
    {4{(dis_count == 5'h1E)}} & num[7:4] |
    {4{(dis_count == 5'h1D)}} & num[11:8] |
    {4{(dis_count == 5'h1C)}} & num[15:12] |
    {4{(dis_count == 5'h1B)}} & num[19:16] |
    {4{(dis_count == 5'h1A)}} & num[23:20] |
    {4{(dis_count == 5'h19)}} & num[27:24] |
    {4{(dis_count == 5'h18)}} & num[31:28] |
    {4{(dis_count == 5'h17)}} & num[35:32] |
    {4{(dis_count == 5'h16)}} & num[39:36] |
    {4{(dis_count == 5'h15)}} & num[43:40] |
    {4{(dis_count == 5'h14)}} & num[47:44] |
    {4{(dis_count == 5'h13)}} & num[51:48] |
    {4{(dis_count == 5'h12)}} & num[55:52] |
    {4{(dis_count == 5'h11)}} & num[59:56] |
    {4{(dis_count == 5'h10)}} & num[63:60] |
    {4{(dis_count == 5'hF)}} & num[67:64] |
    {4{(dis_count == 5'hE)}} & num[71:68] |
    {4{(dis_count == 5'hD)}} & num[75:72] |
    {4{(dis_count == 5'hC)}} & num[79:76] |
    {4{(dis_count == 5'hB)}} & num[83:80] |
    {4{(dis_count == 5'hA)}} & num[87:84] |
    {4{(dis_count == 5'h9)}} & num[91:88] |
    {4{(dis_count == 5'h8)}} & num[95:92] |
    {4{(dis_count == 5'h7)}} & num[99:96] |
    {4{(dis_count == 5'h6)}} & num[103:100] |
    {4{(dis_count == 5'h5)}} & num[107:104] |
    {4{(dis_count == 5'h4)}} & num[111:108] |
    {4{(dis_count == 5'h3)}} & num[115:112] |
    {4{(dis_count == 5'h2)}} & num[119:116] |
    {4{(dis_count == 5'h1)}} & num[123:120] |
    {4{(dis_count == 5'h0)}} & num[127:124] ;

parameter state1 = 6'b000001;
parameter state2 = 6'b000010;
// ... existing code for state parameters ...
parameter state58 = 6'b111010;
parameter state59 = 6'b111011;

always @(posedge clk or posedge reset)
    if(reset) begin
        delay_count <= 1'b1;
        state <= state1;
    end
    else if(delay_count == num_count - 1) begin
        delay_count <= 1'b1;
        state <= next_state;
    end
    else begin
        delay_count <= delay_count + 1'b1;
    end

always @(*) begin
    next_state = state;
    case(state)
    state1:begin
        next_state = state2;
        num_count = 20'd4;
        lcd_rs = 1'b0;
        lcd_e = 1'b0;
        lcd_d = 4'h3;
    end
    state2:begin
        next_state = state3;
        num_count = 20'd12;
        lcd_e = 1'b1;
    end
    // ... existing code for other states ...
    state46:begin
        next_state = state35;
        num_count = 20'd2000;
        lcd_e = 1'b0;
        dis_count = dis_count + 1;
    end
    default:begin
        next_state = state1;
        num_count = 20'd800;
    end
    endcase
end

endmodule