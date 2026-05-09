`default_nettype none
module Counter(rst, dout, dout_fabric);
    output wire dout;
    output wire dout_fabric;
    input wire rst;
    wire clk_6khz_cnt;            
    wire clk_6khz;                
    GP_RCOSC #(
        .PWRDN_EN(0),
        .AUTO_PWRDN(0), 
        .OSC_FREQ("25k"),
        .HARDIP_DIV(4),
        .FABRIC_DIV(1)
    ) rcosc (
        .PWRDN(1'b0),
        .CLKOUT_HARDIP(clk_6khz_cnt),
        .CLKOUT_FABRIC(clk_6khz)
    );
    localparam COUNT_MAX = 31;
    reg [4:0] count = COUNT_MAX;
    always @(posedge clk_6khz_cnt or posedge rst) begin
        if(rst)
            count           <= 0;
        else begin
            if(count == 0)
                count       <= COUNT_MAX;
            else
                count       <= count - 1'd1;
        end
    end
    assign dout = (count == 0);
    reg [4:0] count_fabric = COUNT_MAX;                    
    always @(posedge clk_6khz or posedge rst) begin
        if(rst)
            count_fabric        <= 0;
        else begin
            if(count_fabric == 0)
                count_fabric    <= COUNT_MAX;
            else
                count_fabric    <= count_fabric - 1'd1;
        end
    end
    assign dout_fabric = (count_fabric == 0);
endmodule