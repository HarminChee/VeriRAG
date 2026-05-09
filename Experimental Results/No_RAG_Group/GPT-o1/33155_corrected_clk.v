module system_controller_xilinx_corrected_clk (
    clk_i, rst_i, nrst_i,
    clk_sys_i, rst_sys_i
);
    input wire clk_sys_i;
    input wire rst_sys_i;
    output wire clk_i;
    output reg  rst_i;
    output wire nrst_i;

    wire xclk_buf;
    IBUF clk_ibuf (
        .I(clk_sys_i),
        .O(xclk_buf)
    );

    BUFGCE clk_buf (
        .CE(1'b1),
        .O(clk_i),
        .I(xclk_buf)
    );

    reg [3:0] rst_count;
    assign nrst_i = ~rst_i;

    always @(posedge clk_i) begin
        if (rst_sys_i) begin
            rst_i <= 1;
            rst_count <= 4'hF;
        end else begin
            if (rst_count != 0) begin
                rst_count <= rst_count - 1;
            end else begin
                rst_i <= 0;
            end
        end
    end

endmodule