`timescale 1ns / 1ps
module audio_direct(
    input wire test_i,
    input wire clk_i,
    input wire en_i,
    input wire pdm_audio_i,
    output wire pdm_m_clk_o,
    output wire pwm_audio_o,
    output wire done_o,
    output wire pwm_audio_shutdown
    );

wire PdmDes_done;
wire [15:0] PdmDes_dout;
wire dft_clk;

reg en_i_sync;
reg [15:0] PdmSer_In;

assign pwm_audio_shutdown = en_i_sync;
assign dft_clk = test_i ? clk_i : PdmDes_done;

PdmDes PdmDes_Inst (
    .clk(clk_i),
    .en(en_i),
    .dout(PdmDes_dout),
    .pdm_m_clk_o(pdm_m_clk_o),
    .pdm_m_data_i(pdm_audio_i)
);

always @(posedge dft_clk)
if(en_i)
    en_i_sync <= 1'b1;

always @(posedge clk_i)
    PdmSer_In <= PdmDes_dout;

PdmSer PdmSer_Inst (
    .clk(clk_i),
    .en(en_i_sync),
    .din(PdmSer_In),
    .done(done_o),
    .pwm_audio_o(pwm_audio_o)
);

endmodule