`default_nettype none

module RedundantFF(
    input wire clear,
    output wire underflow
);
    wire clk_108hz;

    GP_LFOSC #(
        .PWRDN_EN(0),
        .AUTO_PWRDN(0),
        .OUT_DIV(16)
    ) lfosc (
        .PWRDN(1'b0),
        .CLKOUT(clk_108hz)
    );

    reg [7:0] count = 8'h0F;

    always @(posedge clk_108hz or posedge clear) begin
        if (clear) begin
            count <= 8'h0F;
        end
        else begin
            count <= count - 1'b1;
            if (count == 0)
                count <= 8'h0F;
        end
    end

    assign underflow = (count == 0);
endmodule