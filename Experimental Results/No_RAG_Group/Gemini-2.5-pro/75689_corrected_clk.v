module audio_direct_path(
    input wire clk_i,
    input wire rst_ni, // Added reset input
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

// Assuming PdmDes has a 'done' output port
PdmDes PdmDes_Inst (
    .clk(clk_i),
    // .rst_n(rst_ni), // Assuming PdmDes uses reset
    .en(en_i),
    .dout(PdmDes_dout),
    .pdm_m_clk_o(pdm_m_clk_o),
    .pdm_m_data_i(pdm_audio_i),
    .done(PdmDes_done) // Connect done output
);

// Corrected logic for en_i_sync, clocked by clk_i and reset by rst_ni
always @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        en_i_sync <= 1'b0;
    end else if (PdmDes_done && en_i) begin // Use PdmDes_done as enable
        en_i_sync <= 1'b1;
    end
end

// Logic for PdmSer_In, clocked by clk_i and reset by rst_ni
always @(posedge clk_i or negedge rst_ni) begin
     if (!rst_ni) begin
        PdmSer_In <= 16'b0;
    end else begin
        PdmSer_In <= PdmDes_dout;
    end
end

// Instantiate PdmSer
PdmSer PdmSer_Inst (
    .clk(clk_i),
    // .rst_n(rst_ni), // Assuming PdmSer uses reset
    .en(en_i_sync),
    .din(PdmSer_In),
    .done(done_o),
    .pwm_audio_o(pwm_audio_o)
);

endmodule