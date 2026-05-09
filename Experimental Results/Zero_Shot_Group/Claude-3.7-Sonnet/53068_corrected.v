`default_nettype none
module RedundantFF(clear, underflow);
    input wire clear;
    output wire underflow;
    wire clk_108hz;
    
    GP_LFOSC #(
        .PWRDN_EN(0),
        .AUTO_PWRDN(0), 
        .OUT_DIV(16)
    ) lfosc (
        .PWRDN(1'b0),
        .CLKOUT(clk_108hz)
    );

    reg [7:0] count;

    always @(posedge clk_108hz or posedge clear) begin
        if (clear)
            count <= 8'd15;
        else begin
            if (count == 8'd0)
                count <= 8'd15;
            else
                count <= count - 8'd1;
        end
    end

    assign underflow = (count == 8'd0);

endmodule