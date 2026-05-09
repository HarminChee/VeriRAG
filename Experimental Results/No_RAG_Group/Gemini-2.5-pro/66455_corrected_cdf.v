// 1_corrected_cdf.v
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Xilinx, Inc
// Engineer: Parimal Patel
// Create Date: 06/24/2016 09:26:14 AM
// Module Name: audio_direct
// Project Name: PYNQ
// Description: Corrected version addressing potential CDFDAT violation by
//              synchronizing logic previously clocked by PdmDes_done to clk_i.
//              Added asynchronous reset for improved testability.
//////////////////////////////////////////////////////////////////////////////////


module audio_direct(
    input wire clk_i,
    input wire rst_ni, // Added reset input for DFT
    input wire en_i,
    input wire pdm_audio_i,
    output wire pdm_m_clk_o,
    output wire pwm_audio_o,
    output wire done_o,
    output wire pwm_audio_shutdown
    );

wire PdmDes_done; // Assumed output from PdmDes_Inst
wire [15:0] PdmDes_dout;

reg en_i_sync;
reg [15:0] PdmSer_In;

assign pwm_audio_shutdown = en_i_sync; // 1'b1;

PdmDes PdmDes_Inst (
    .clk(clk_i),
    // .rst_n(rst_ni), // Assuming PdmDes also needs reset connection if applicable
    .en(en_i),
    .dout(PdmDes_dout),
    .done(PdmDes_done), // Assuming PdmDes module has a 'done' output port
    .pdm_m_clk_o(pdm_m_clk_o),
    .pdm_m_data_i(pdm_audio_i)
);

// Corrected block: en_i_sync is now clocked by clk_i and reset by rst_ni
// It gets set when PdmDes_done is asserted (assuming it's a pulse) and en_i is high.
always @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        en_i_sync <= 1'b0;
    end else begin
        // Set en_i_sync if PdmDes is done and the enable is high
        // Holds value otherwise. Original logic only specified setting the bit.
        if (PdmDes_done && en_i) begin
            en_i_sync <= 1'b1;
        end
        // Add clear condition if needed: else if (CLEAR_CONDITION) en_i_sync <= 1'b0;
    end
end

// PdmSer_In register, clocked by clk_i and reset by rst_ni - DFT friendly.
always @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        PdmSer_In <= 16'b0;
    end else begin
        // Capture data output from PdmDes
        PdmSer_In <= PdmDes_dout;
    end
end

PdmSer PdmSer_Inst (
    .clk(clk_i),
    // .rst_n(rst_ni), // Assuming PdmSer also needs reset connection if applicable
    .en(en_i_sync), // en_i_sync is now a standard synchronous signal
    .din(PdmSer_In),
    .done(done_o),
    .pwm_audio_o(pwm_audio_o)
);


endmodule