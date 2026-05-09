`default_nettype none

module Counter (
    input wire rst,
    output wire dout,
    output wire dout_fabric
);

    wire clk_6khz_cnt;
    wire clk_6khz;

    // Assuming GP_RCOSC is a predefined module/primitive
    // Corrected FABRIC_DIV to 4 to likely match the intended ~6kHz frequency
    // based on the wire name clk_6khz. If 25kHz was intended for clk_6khz,
    // FABRIC_DIV should be 1, and the wire should ideally be renamed.
    GP_RCOSC #(
        .PWRDN_EN(0),
        .AUTO_PWRDN(0),
        .OSC_FREQ("25k"), // Base frequency ~25kHz
        .HARDIP_DIV(4),   // Results in ~6.25kHz for clk_6khz_cnt (25k / 4)
        .FABRIC_DIV(4)    // Results in ~6.25kHz for clk_6khz (25k / 4)
    ) rcosc (
        .PWRDN(1'b0),
        .CLKOUT_HARDIP(clk_6khz_cnt),
        .CLKOUT_FABRIC(clk_6khz)
    );

    localparam COUNT_MAX = 31; // Requires 5 bits (0 to 31)

    // Corrected width to match COUNT_MAX, removed inline initialization
    reg [4:0] count;
    always @(posedge clk_6khz_cnt or posedge rst) begin // Use 'or' for sensitivity list
        if (rst)
            count <= 5'd0; // Initialize to 0 on reset
        else begin
            if (count == 0)
                count <= COUNT_MAX;
            else
                count <= count - 1'b1; // Use 1'b1 for subtraction
        end
    end

    assign dout = (count == 0);

    // Corrected width to match COUNT_MAX, removed inline initialization
    reg [4:0] count_fabric;
    always @(posedge clk_6khz or posedge rst) begin // Use 'or' for sensitivity list
        if (rst)
            count_fabric <= 5'd0; // Initialize to 0 on reset
        else begin
            if (count_fabric == 0)
                count_fabric <= COUNT_MAX;
            else
                count_fabric <= count_fabric - 1'b1; // Use 1'b1 for subtraction
        end
    end

    assign dout_fabric = (count_fabric == 0);

endmodule