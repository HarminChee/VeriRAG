`default_nettype none

module RedundantFF(
    input wire clear,
    output wire underflow
    // clk_108hz is generated internally
);

    // Internal clock generation
    wire clk_108hz;
    // Assuming GP_LFOSC is a defined module elsewhere
    GP_LFOSC #(
        .PWRDN_EN(0),
        .AUTO_PWRDN(0),
        .OUT_DIV(16)
    ) lfosc (
        .PWRDN(1'b0),
        .CLKOUT(clk_108hz)
    );

    // Counter register
    reg [7:0] count;

    // Counter logic with active-high asynchronous reset
    // Counts down from 15 to 0, then wraps back to 15.
    always @(posedge clk_108hz or posedge clear) begin
        if (clear) begin // Asynchronous reset overrides clock edge
            count <= 8'd15;
        end else begin   // Normal clocked operation
            if (count == 8'd0) begin
                count <= 8'd15; // Reload when count is currently 0
            end else begin
                count <= count - 8'd1; // Decrement otherwise
            end
        end
    end

    // Underflow signal assignment (combinational)
    // Asserted when the counter's value is exactly 0
    assign underflow = (count == 8'd0);

endmodule