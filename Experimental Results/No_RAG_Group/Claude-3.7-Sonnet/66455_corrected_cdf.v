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
    input wire rst_n,
    input wire en_i,
    input wire pdm_audio_i,
    input wire test_mode,
    output wire pdm_m_clk_o,
    output wire pwm_audio_o,
    output wire done_o,
    output wire pwm_audio_shutdown
    );

wire PdmDes_done;
wire [15:0] PdmDes_dout;

reg en_i_sync;
reg [15:0] PdmSer_In;
reg sync_done;

assign pwm_audio_shutdown = en_i_sync;
    
PdmDes PdmDes_Inst (
    .clk(clk_i),
    .en(en_i),
    .dout(PdmDes_dout),
    .pdm_m_clk_o(pdm_m_clk_o),
    .pdm_m_data_i(pdm_audio_i)
);

always @(posedge clk_i or negedge rst_n) begin
    if (!rst_n) begin
        en_i_sync <= 1'b0;
        sync_done <= 1'b0;
    end
    else begin
        if (!test_mode) begin
            if (PdmDes_done && en_i && !sync_done) begin
                en_i_sync <= 1'b1;
                sync_done <= 1'b1;
            end
        end
        else begin
            en_i_sync <= en_i;
        end
    end
end

always @(posedge clk_i or negedge rst_n) begin
    if (!rst_n)
        PdmSer_In <= 16'h0000;
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