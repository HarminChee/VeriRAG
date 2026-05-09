`timescale 1ns / 1ps

module audio_direct_path(
    input wire clk_i,
    input wire en_i,            // Master enable
    input wire pdm_audio_i,     // PDM input data
    output wire pdm_m_clk_o,    // PDM microphone clock output
    output wire pwm_audio_o,    // PWM audio output
    output wire done_o,         // Overall process done signal (from PdmSer)
    output wire pwm_audio_shutdown // Shutdown signal for PWM (active high when enabled)
    );

// Internal signals
wire        PdmDes_done;       // Done signal from PDM Decimator
wire [15:0] PdmDes_dout;       // Data output from PDM Decimator
reg  [15:0] PdmSer_In;         // Registered input for PDM Serializer/PWM
wire        PdmSer_en;         // Enable signal for PdmSer
reg         pwm_enabled_latch; // Latches high once PWM stage can be active

// PDM Decimator Instance
// Assumes PdmDes interface: (clk, en, pdm_m_data_i, pdm_m_clk_o, done, dout)
PdmDes PdmDes_Inst (
    .clk(clk_i),
    .en(en_i),              // Enabled by master enable
    .pdm_m_data_i(pdm_audio_i),
    .pdm_m_clk_o(pdm_m_clk_o),
    .done(PdmDes_done),     // Connect done output
    .dout(PdmDes_dout)
);

// Latch data from PdmDes into PdmSer_In register only when PdmDes signals done
always @(posedge clk_i) begin
    if (PdmDes_done) begin
        PdmSer_In <= PdmDes_dout;
    end
end

// Generate enable for PdmSer: PdmSer is enabled only when PdmDes is done AND master enable is high
assign PdmSer_en = PdmDes_done & en_i;

// PDM Serializer / PWM Generator Instance
// Assumes PdmSer interface: (clk, en, din, done, pwm_audio_o)
PdmSer PdmSer_Inst (
    .clk(clk_i),
    .en(PdmSer_en),         // Enable when PdmDes is done and en_i is high
    .din(PdmSer_In),
    .done(done_o),          // Pass through done signal from PdmSer
    .pwm_audio_o(pwm_audio_o)
);

// Logic for pwm_audio_shutdown output
// It should go high once the first PDM sample is processed and stay high while enabled.
always @(posedge clk_i) begin
    if (!en_i) begin        // If master enable goes low, reset the latch
        pwm_enabled_latch <= 1'b0;
    end else if (PdmDes_done) begin // If master enable is high and PdmDes finishes
        pwm_enabled_latch <= 1'b1;  // Set the latch high
    end
    // Otherwise, pwm_enabled_latch holds its value
end

// Assign the latched signal to the output. Active high indicates PWM is potentially active.
assign pwm_audio_shutdown = pwm_enabled_latch;

endmodule