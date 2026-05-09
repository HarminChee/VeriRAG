`timescale 1ns / 1ps
`timescale 1ns / 1ps
module audio_direct_path(
    input wire clk_i,
    input wire rst_n_i, // Added primary reset input
    input wire test_i, // Added test mode input (optional but good practice)
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
assign pwm_audio_shutdown = en_i_sync;

PdmDes PdmDes_Inst (
    .clk(clk_i),
    // Assuming PdmDes needs reset
    // .rst_n(rst_n_i),
    .en(en_i),
    .dout(PdmDes_dout),
    .done(PdmDes_done), // Assuming PdmDes outputs done signal
    .pdm_m_clk_o(pdm_m_clk_o),
    .pdm_m_data_i(pdm_audio_i)
);

// Corrected: Clock en_i_sync with primary clock clk_i, use primary reset rst_n_i
// Use PdmDes_done as enable signal
always @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
        en_i_sync <= 1'b0;
    end else if (PdmDes_done) begin // Update only when PdmDes_done is asserted
        if(en_i) begin // Original condition
            en_i_sync <= 1'b1; // Original action: set FF
        end
        // Note: This FF is only ever set, never cleared except by reset.
        // Functional review might be needed depending on PdmDes_done behavior.
    end
end

// PdmSer_In register clocked by primary clock clk_i
always @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
        PdmSer_In <= 16'b0;
    end else begin
        PdmSer_In <= PdmDes_dout;
    end
end

PdmSer PdmSer_Inst (
    .clk(clk_i),
    // Assuming PdmSer needs reset
    // .rst_n(rst_n_i),
    .en(en_i_sync),
    .din(PdmSer_In),
    .done(done_o),
    .pwm_audio_o(pwm_audio_o)
);
endmodule