`timescale 1ns / 1ps
module shift4(
    input  wire        test_i,
    input  wire        scan_load,
    input  wire        clk,
    input  wire        sys_rst_n,
    output reg  [3:0]  data
);
parameter NP  = 21;
parameter INI = 1;

wire   prescaler_pulse;
wire   dft_prescaler_pulse;
reg    load_shift = 0;
wire   serin;

prescaler #(.N(NP))
pres1 (
    .clk_in(clk),
    .pulse_out(prescaler_pulse)
);

assign dft_prescaler_pulse = test_i ? scan_load : prescaler_pulse;

always @(posedge clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        load_shift <= 1'b0;
    else if(dft_prescaler_pulse)
        load_shift <= 1'b1;
    else
        load_shift <= 1'b0;
end

always @(posedge clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        data <= INI;
    else if(!load_shift)
        data <= INI;
    else
        data <= {data[2:0], serin};
end

assign serin = data[3];

endmodule