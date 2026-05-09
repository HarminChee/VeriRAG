`timescale 1ns / 1ps
`timescale 1ns / 1ps
module asg_ft_generator #
    (
        parameter SIZE = 3200
    )
    (
        input wire RADAR_TRIG_PE,
        input wire USEC_PE,
        (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 SYS_CLK CLK" *)
        (* X_INTERFACE_PARAMETER = "FREQ_HZ 100000000" *)
        input wire SYS_CLK,
        output wire GEN_SIGNAL
    );
    reg EN = 1;
    reg [SIZE-1:0] DATA = 0;
    always @* begin
        DATA[102:100] <= 3'b111;
        DATA[502:500] <= 3'b111;
        DATA[902:900] <= 3'b111;
        DATA[1302:1300] <= 3'b111;
        DATA[1702:1700] <= 3'b111;
        DATA[2102:2100] <= 3'b111;
        DATA[2502:2500] <= 3'b111;
        DATA[2902:2900] <= 3'b111;
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
