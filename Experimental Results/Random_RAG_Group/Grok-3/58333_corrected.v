`default_nettype none
module Counter (
    input  wire test_i,
    input  wire rst,
    input  wire clk_in,
    output wire dout,
    output wire dout_fabric
);
    wire clk_6khz_cnt;
    wire clk_6khz;
    wire dft_clk_6khz_cnt;
    wire dft_clk_6khz;
    wire dft_rst;

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

    assign dft_clk_6khz_cnt = test_i ? clk_in : clk_6khz_cnt;
    assign dft_clk_6khz = test_i ? clk_in : clk_6khz;
    assign dft_rst = test_i ? rst : rst;

    localparam COUNT_MAX = 31;
    reg [7:0] count = COUNT_MAX;
    always @(posedge dft_clk_6khz_cnt or posedge dft_rst) begin
        if (dft_rst)
            count <= 0;
        else begin
            if (count == 0)
                count <= COUNT_MAX;
            else
                count <= count - 1'd1;
        end
    end
    assign dout = (count == 0);

    reg [5:0] count_fabric = COUNT_MAX;
    always @(posedge dft_clk_6khz or posedge dft_rst) begin
        if (dft_rst)
            count_fabric <= 0;
        else begin
            if (count_fabric == 0)
                count_fabric <= COUNT_MAX;
            else
                count_fabric <= count_fabric - 1'd1;
        end
    end
    assign dout_fabric = (count_fabric == 0);
endmodule