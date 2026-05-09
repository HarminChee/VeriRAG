`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Xilinx, Inc
// Engineer: Parimal Patel
// Create Date: 06/24/2016 09:26:14 AM
// Module Name: audio_direct (Corrected for CLKNPI)
// Project Name: PYNQ
//////////////////////////////////////////////////////////////////////////////////


module audio_direct(
    input wire clk_i,
    input wire rst_n_i, // Added asynchronous reset for proper initialization/DFT
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

// Internal signals for synchronizing and edge detection
reg PdmDes_done_q1;
reg PdmDes_done_q2;
reg PdmDes_done_q2_prev;
wire PdmDes_done_posedge;

assign pwm_audio_shutdown = en_i_sync; // 1'b1;

PdmDes PdmDes_Inst (
    .clk(clk_i),
    // Assuming PdmDes has appropriate reset handling if needed
    .en(en_i),
    .dout(PdmDes_dout),
    .done(PdmDes_done), // Connect done output
    .pdm_m_clk_o(pdm_m_clk_o),
    .pdm_m_data_i(pdm_audio_i)
);

// Synchronize PdmDes_done to clk_i to avoid metastability and use clk_i domain
always @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
        PdmDes_done_q1 <= 1'b0;
        PdmDes_done_q2 <= 1'b0;
    end else begin
        PdmDes_done_q1 <= PdmDes_done;
        PdmDes_done_q2 <= PdmDes_done_q1;
    end
end

// Store previous value of synchronized signal for edge detection
always @(posedge clk_i or negedge rst_n_i) begin
     if (!rst_n_i) begin
        PdmDes_done_q2_prev <= 1'b0;
     end else begin
        PdmDes_done_q2_prev <= PdmDes_done_q2;
     end
end

// Detect rising edge of synchronized PdmDes_done
assign PdmDes_done_posedge = PdmDes_done_q2 & ~PdmDes_done_q2_prev;

// Original logic for en_i_sync, now clocked by clk_i
always @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
        en_i_sync <= 1'b0; // Reset en_i_sync
    end else if (PdmDes_done_posedge && en_i) begin // Check condition synchronously
        en_i_sync <= 1'b1;
    end
    // Note: en_i_sync stays high once set, unless reset.
    // If it needs to be cleared under other conditions, add logic here.
end

// Register PdmDes_dout synchronously with clk_i
always @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
        PdmSer_In <= 16'b0;
    end else begin
        PdmSer_In <= PdmDes_dout;
    end
end

PdmSer PdmSer_Inst (
    .clk(clk_i),
    .rst_n(rst_n_i), // Pass reset to submodule
    .en(en_i_sync),
    .din(PdmSer_In),
    .done(done_o),
    .pwm_audio_o(pwm_audio_o)
);


endmodule