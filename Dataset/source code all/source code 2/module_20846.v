`timescale 1ns / 1ps
`timescale 1ns / 1ps
module asg_mt_generator #
    (
        parameter SIZE = 3200
    )
    (
        input wire RADAR_TRIG_PE,
        input wire USEC_PE,
        input wire SYS_CLK,
        output wire GEN_SIGNAL
    );
    reg EN = 1;
    reg [SIZE-1:0] DATA = 0;
    always @* begin
        DATA[302:300] <= 3'b111;
        DATA[702:700] <= 3'b111;
        DATA[1102:1100] <= 3'b111;
        DATA[1502:1500] <= 3'b111;
        DATA[1902:1900] <= 3'b111;
        DATA[2302:2300] <= 3'b111;
        DATA[2702:2700] <= 3'b111;
        DATA[3102:3100] <= 3'b111;
    end
    azimuth_signal_generator #(SIZE) asg (
        .EN(EN),
        .TRIG(RADAR_TRIG_PE),
        .DATA(DATA),
        .CLK_PE(USEC_PE),
        .SYS_CLK(SYS_CLK),
        .GEN_SIGNAL(GEN_SIGNAL)
    );
endmodule
