`default_nettype none
module Counter (
    input wire rst,
    input wire clk_6khz_cnt,
    input wire clk_6khz,
    output wire dout,
    output wire dout_fabric
);

    localparam COUNT_MAX = 31;
    reg [7:0] count = COUNT_MAX;

    always @(posedge clk_6khz_cnt or posedge rst) begin
        if (rst)
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

    always @(posedge clk_6khz or posedge rst) begin
        if (rst)
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