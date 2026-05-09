`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Xilinx, Inc
// Engineer: Parimal Patel
// Create Date: 06/24/2016 09:26:14 AM
// Module Name: audio_direct
// Project Name: PYNQ
//////////////////////////////////////////////////////////////////////////////////

module audio_direct(
    input wire clk_i,
    input wire en_i,
    input wire pdm_audio_i,
    output wire pdm_m_clk_o,
    output wire pwm_audio_o,
    output wire done_o,
    output wire pwm_audio_shutdown,
    input wire scan_clk,
    input wire test_i
);

wire PdmDes_done;
wire [15:0] PdmDes_dout;

reg en_i_sync;
reg [15:0] PdmSer_In;

wire dft_clk;
assign dft_clk = test_i ? scan_clk : clk_i;
assign pwm_audio_shutdown = en_i_sync;

PdmDes PdmDes_Inst (
    .clk(dft_clk),
    .en(en_i),
    .dout(PdmDes_dout),
    .done(PdmDes_done),
    .pdm_m_clk_o(pdm_m_clk_o),
    .pdm_m_data_i(pdm_audio_i)
);

always @(posedge dft_clk or posedge en_i)
if (en_i)
    en_i_sync <= 1'b1;
else
    en_i_sync <= 1'b0;

always @(posedge dft_clk)
    PdmSer_In <= PdmDes_dout;

PdmSer PdmSer_Inst (
    .clk(dft_clk),
    .en(en_i_sync),
    .din(PdmSer_In),
    .done(done_o),
    .pwm_audio_o(pwm_audio_o)
);

endmodule