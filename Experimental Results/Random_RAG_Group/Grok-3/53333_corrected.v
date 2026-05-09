module VGA_Ctrl (	
    input wire test_i,
    input wire [9:0] iRed,
    input wire [9:0] iGreen,
    input wire [9:0] iBlue,
    output wire [21:0] oAddress,
    output wire [10:0] oCurrent_X,
    output wire [10:0] oCurrent_Y,
    output wire oRequest,
    output wire [9:0] oVGA_R,
    output wire [9:0] oVGA_G,
    output wire [9:0] oVGA_B,
    output reg oVGA_HS,
    output reg oVGA_VS,
    output wire oVGA_SYNC,
    output wire oVGA_BLANK,
    output wire oVGA_CLOCK,
    input wire iCLK,
    input wire iRST_N
);

reg [10:0] H_Cont;
reg [10:0] V_Cont;
wire dft_clk;
wire dft_rst;

parameter H_FRONT = 16;
parameter H_SYNC = 96;
parameter H_BACK = 48;
parameter H_ACT = 640;
parameter H_BLANK = H_FRONT + H_SYNC + H_BACK;
parameter H_TOTAL = H_FRONT + H_SYNC + H_BACK + H_ACT;
parameter V_FRONT = 11;
parameter V_SYNC = 2;
parameter V_BACK = 31;
parameter V_ACT = 480;
parameter V_BLANK = V_FRONT + V_SYNC + V_BACK;
parameter V_TOTAL = V_FRONT + V_SYNC + V_BACK + V_ACT;

assign dft_clk = test_i ? iCLK : ~iCLK;
assign dft_rst = test_i ? iRST_N : iRST_N;

assign oVGA_SYNC = 1'b1;			
assign oVGA_BLANK = ~((H_Cont < H_BLANK) || (V_Cont < V_BLANK));
assign oVGA_CLOCK = dft_clk;
assign oVGA_R = iRed;
assign oVGA_G = iGreen;
assign oVGA_B = iBlue;
assign oAddress = oCurrent_Y * H_ACT + oCurrent_X;
assign oRequest = ((H_Cont >= H_BLANK && H_Cont < H_TOTAL) && 
                   (V_Cont >= V_BLANK && V_Cont < V_TOTAL));
assign oCurrent_X = (H_Cont >= H_BLANK) ? H_Cont - H_BLANK : 11'h0;
assign oCurrent_Y = (V_Cont >= V_BLANK) ? V_Cont - V_BLANK : 11'h0;

always @(posedge dft_clk or negedge dft_rst)
begin
    if (!dft_rst)
    begin
        H_Cont <= 0;
        oVGA_HS <= 1;
    end
    else
    begin
        if (H_Cont < H_TOTAL)
            H_Cont <= H_Cont + 1'b1;
        else
            H_Cont <= 0;
        if (H_Cont == H_FRONT - 1)			
            oVGA_HS <= 1'b0;
        if (H_Cont == H_FRONT + H_SYNC - 1)	
            oVGA_HS <= 1'b1;
    end
end

always @(posedge oVGA_HS or negedge dft_rst)
begin
    if (!dft_rst)
    begin
        V_Cont <= 0;
        oVGA_VS <= 1;
    end
    else
    begin
        if (V_Cont < V_TOTAL)
            V_Cont <= V_Cont + 1'b1;
        else
            V_Cont <= 0;
        if (V_Cont == V_FRONT - 1)			
            oVGA_VS <= 1'b0;
        if (V_Cont == V_FRONT + V_SYNC - 1)	
            oVGA_VS <= 1'b1;
    end
end

endmodule