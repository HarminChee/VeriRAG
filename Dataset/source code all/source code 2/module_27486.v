`timescale 1ns/1ps
`timescale 1ns/1ps
module  freq_meter#(
    parameter WIDTH =    12, 
    parameter PRESCALE = 1 
)(
    input                     rst,
    input                     clk,
    input                    xclk,
    output reg [WIDTH - 1:0] dout
);
    localparam TIMER_WIDTH = WIDTH - PRESCALE;
    reg [TIMER_WIDTH - 1 :0] timer;
    reg       [WIDTH - 1 :0] counter;
    wire                     restart;
    reg                [3:0] run_xclk;
    always @ (posedge clk) begin
        if      (rst || restart)          timer <= 0;
        else if (!timer[TIMER_WIDTH - 1]) timer <= timer + 1;
        if (restart) dout <= counter; 
    end
    always @ (posedge xclk) begin
        run_xclk <= {run_xclk[2:0], ~timer[TIMER_WIDTH - 1] & ~rst};
        if      (run_xclk[2]) counter <= counter + 1;
        else if (run_xclk[1]) counter <= 0;
    end
    pulse_cross_clock #(
        .EXTRA_DLY(0)
    ) xclk2clk_i (
        .rst       (rst),                         
        .src_clk   (xclk),                        
        .dst_clk   (clk),                         
        .in_pulse  (!run_xclk[2] && run_xclk[3]), 
        .out_pulse (restart),                     
        .busy      ()                             
    );
endmodule
