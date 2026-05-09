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
    input wire rst_n_i, // Added primary reset input
    input wire en_i,
    input wire pdm_audio_i,
    output wire pdm_m_clk_o,
    output wire pwm_audio_o,
    output wire done_o,
    output wire pwm_audio_shutdown
    );

wire PdmDes_done;
wire [15:0] PdmDes_dout;

reg en_i_sync;
reg [15:0] PdmSer_In;

assign pwm_audio_shutdown = en_i_sync; // 1'b1;

PdmDes PdmDes_Inst (
    .clk(clk_i),
    .en(en_i),
    .dout(PdmDes_dout),
    .pdm_m_clk_o(pdm_m_clk_o),
    .pdm_m_data_i(pdm_audio_i)
);

// Corrected: Clocked by primary clock clk_i, added reset
always @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
        en_i_sync <= 1'b0;
    end else begin
        // Logic triggered by PdmDes_done condition, gated by en_i
        if (PdmDes_done && en_i) begin
            en_i_sync <= 1'b1;
        end
        // Add logic to clear en_i_sync if needed, otherwise it stays high after being set once while rst_n_i is high
        // Example: else if (!en_i) begin en_i_sync <= 1'b0; end
    end
end

// Added reset to the second flip-flop for completeness
always @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
        PdmSer_In <= 16'b0;
    end else begin
        PdmSer_In <= PdmDes_dout;
    end
end

PdmSer PdmSer_Inst (
    .clk(clk_i),
    .en(en_i_sync),
    .din(PdmSer_In),
    .done(done_o),
    .pwm_audio_o(pwm_audio_o)
);


endmodule