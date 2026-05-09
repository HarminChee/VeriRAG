`default_nettype none

module Counter_corrected_clk (
    // Add primary clock input for DFT compliance
    input wire clk,
    input wire rst,
    output wire dout,
    output wire dout_fabric
);

    // Internal oscillator generates clocks, but these should not directly clock scan FFs
    wire clk_6khz_cnt_internal; // Renamed to avoid confusion if used elsewhere
    wire clk_6khz_internal;     // Renamed to avoid confusion if used elsewhere

    // Instance of the oscillator (remains for potential functional use, but not for FF clocking)
    GP_RCOSC #(
        .PWRDN_EN(0),
        .AUTO_PWRDN(0),
        .OSC_FREQ("25k"),
        .HARDIP_DIV(4), // 25k / 4 = ~6.25kHz
        .FABRIC_DIV(1)  // 25k / 1 = 25kHz (Note: Original comment said 6khz, but FABRIC_DIV=1 yields 25k)
    ) rcosc (
        .PWRDN(1'b0),
        .CLKOUT_HARDIP(clk_6khz_cnt_internal),
        .CLKOUT_FABRIC(clk_6khz_internal)
    );

    localparam COUNT_WIDTH = 5; // Parameter for width based on COUNT_MAX
    localparam COUNT_MAX = 31;  // Maximum count value (requires 5 bits)

    // Counter logic clocked by the primary input 'clk'
    reg [COUNT_WIDTH-1:0] count = COUNT_MAX;
    always @(posedge clk, posedge rst) begin // Use primary clock 'clk'
        if (rst)
            count <= {COUNT_WIDTH{1'b0}}; // Explicit width reset
        else begin
            if (count == {COUNT_WIDTH{1'b0}})
                count <= COUNT_MAX;
            else
                count <= count - 1'd1;
        end
    end
    assign dout = (count == {COUNT_WIDTH{1'b0}});

    // Second counter logic clocked by the primary input 'clk'
    reg [COUNT_WIDTH-1:0] count_fabric = COUNT_MAX; // Adjusted width
    always @(posedge clk, posedge rst) begin // Use primary clock 'clk'
        if (rst)
            count_fabric <= {COUNT_WIDTH{1'b0}}; // Explicit width reset
        else begin
            if (count_fabric == {COUNT_WIDTH{1'b0}})
                count_fabric <= COUNT_MAX;
            else
                count_fabric <= count_fabric - 1'd1;
        end
    end
    assign dout_fabric = (count_fabric == {COUNT_WIDTH{1'b0}});

endmodule

`default_nettype wire // Restore default nettype