`timescale 1ns / 1ps
module audio_direct(
    input wire clk_i,
    input wire en_i,
    input wire pdm_audio_i,
    output wire pdm_m_clk_o,
    output wire pwm_audio_o,
    output wire done_o,
    output wire pwm_audio_shutdown
    );

wire pdm_des_done;
wire [15:0] pdm_des_dout;

reg en_i_sync = 1'b0;
reg [15:0] pdm_ser_in = 16'b0;

assign pwm_audio_shutdown = ~en_i_sync;

PdmDes PdmDes_Inst (
    .clk(clk_i),
    .en(en_i),
    .done(pdm_des_done),
    .dout(pdm_des_dout),
    .pdm_m_clk_o(pdm_m_clk_o),
    .pdm_m_data_i(pdm_audio_i)
);

always @(posedge clk_i) begin
    if (pdm_des_done && en_i)
        en_i_sync <= 1'b1;
    else if (!en_i)
        en_i_sync <= 1'b0;
end

always @(posedge clk_i)
    pdm_ser_in <= pdm_des_dout;

PdmSer PdmSer_Inst (
    .clk(clk_i),
    .en(en_i_sync),
    .din(pdm_ser_in),
    .done(done_o),
    .pwm_audio_o(pwm_audio_o)
);

endmodule