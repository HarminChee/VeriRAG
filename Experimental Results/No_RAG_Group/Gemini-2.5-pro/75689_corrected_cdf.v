`timescale 1ns / 1ps
module audio_direct_path_corrected_cdf (
    input wire clk_i,
    input wire rst_ni, // Added reset for proper initialization and testability
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

// Instantiate PdmDes module
PdmDes PdmDes_Inst (
    .clk(clk_i),
    // Assuming PdmDes has a reset input, connect it
    // .rst_n(rst_ni),
    .en(en_i),
    .dout(PdmDes_dout),
    .done(PdmDes_done), // Connect the done signal output
    .pdm_m_clk_o(pdm_m_clk_o),
    .pdm_m_data_i(pdm_audio_i)
);

// Corrected: Use the main clock clk_i for the flip-flop updating en_i_sync
// Avoid using PdmDes_done as a clock. Check its value synchronously.
// Added asynchronous reset for proper initialization.
always @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        en_i_sync <= 1'b0;
    end else begin
        // Update en_i_sync based on PdmDes_done and en_i when clk_i rises
        // This implementation makes en_i_sync a sticky bit once set while enabled
        if (PdmDes_done && en_i) begin
            en_i_sync <= 1'b1;
        end
        // If en_i_sync should be cleared under certain conditions (e.g., when en_i goes low),
        // add that logic here. For example:
        // else if (!en_i) begin
        //     en_i_sync <= 1'b0;
        // end
    end
end

// Register the output of PdmDes synchronously using the main clock clk_i
// Added asynchronous reset.
always @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        PdmSer_In <= 16'b0;
    end else begin
        // Continuously sample PdmDes_dout - adjust if sampling should only happen when PdmDes_done is high
        PdmSer_In <= PdmDes_dout;
    end
end

// Instantiate PdmSer module
PdmSer PdmSer_Inst (
    .clk(clk_i),
    // Assuming PdmSer has a reset input, connect it
    // .rst_n(rst_ni),
    .en(en_i_sync), // Use the synchronously updated enable signal
    .din(PdmSer_In),
    .done(done_o),
    .pwm_audio_o(pwm_audio_o)
);

endmodule

// Note: Assumes PdmDes and PdmSer are pre-existing modules.
// Added rst_ni input for reset capability, essential for testability and robust design.
// Corrected the clocking of en_i_sync to use clk_i instead of PdmDes_done.