`timescale 1ns / 1ps
`timescale 1ns / 1ps
module sinemod(
input clkdds,
input[31:0] freq,
input signed[15:0] amp,
input signed[15:0] amp_off,
output[11:0] sin
);
wire data_valid;
reg phase_valid = 1;
wire signed[16:0] data;
wire[23:0] phase = (freq*83886)/10000;
dds_compiler_0 sine_dds(clkdds, phase_valid, phase, data_valid, data);
reg signed[16:0] amped = 16'b0;
reg signed[16:0] offseted = 16'b0;
reg signed[16:0] clipped = 16'b0;
wire signed[16:0] amp_clipped = amp > 2048 ? 2048 : amp;
always @(posedge clkdds) begin
    amped <= (data * amp_clipped) / 1024; 
    offseted <= amp_off + amped;
    clipped <= offseted < 0 ? 0 : offseted > 4095 ? 4095 : offseted;
end
assign sin = data_valid?clipped:0;
endmodule
