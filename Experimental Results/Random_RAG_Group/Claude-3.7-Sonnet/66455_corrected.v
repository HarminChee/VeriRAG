`timescale 1ns / 1ps

module audio_direct(
    input wire clk_i,
    input wire en_i,
    input wire pdm_audio_i,
    input wire rst_n,
    input wire test_mode,
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

assign dft_clk = test_mode ? clk_i : PdmDes_done;
assign pwm_audio_shutdown = en_i_sync;
    
PdmDes PdmDes_Inst (
    .clk(clk_i),
    .en(en_i),
    .dout(PdmDes_dout),
    .pdm_m_clk_o(pdm_m_clk_o),
    .pdm_m_data_i(pdm_audio_i)
);

always @(posedge dft_clk or negedge rst_n)
begin
    if (!rst_n)
        en_i_sync <= 1'b0;
    else if(en_i)
        en_i_sync <= 1'b1;
end

always @(posedge clk_i or negedge rst_n)
begin
    if (!rst_n)
        PdmSer_In <= 16'b0;
    else
        PdmSer_In <= PdmDes_dout;
end

PdmSer PdmSer_Inst (
    .clk(clk_i),
    .en(en_i_sync),
    .din(PdmSer_In),
    .done(done_o),
    .pwm_audio_o(pwm_audio_o)
);

endmodule