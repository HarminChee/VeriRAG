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
    input wire rst_ni, // Added reset for proper initialization
    input wire en_i,
    input wire pdm_audio_i,
    output wire pdm_m_clk_o,
    output wire pwm_audio_o,
    output wire done_o,
    output wire pwm_audio_shutdown
    );

wire PdmDes_done;
wire [15:0] PdmDes_dout;

reg en_i_sync = 1'b0; // Initialize to 0
reg [15:0] PdmSer_In;
reg PdmDes_done_dly; // For edge detection

assign pwm_audio_shutdown = en_i_sync;

// Instantiate PDM Deserializer
// Assuming PdmDes has a 'done' output port
PdmDes PdmDes_Inst (
    .clk(clk_i),
    .rst_n(rst_ni),          // Pass reset if PdmDes needs it
    .en(en_i),
    .pdm_m_data_i(pdm_audio_i),
    .pdm_m_clk_o(pdm_m_clk_o),
    .dout(PdmDes_dout),
    .done(PdmDes_done)      // Connect the done signal
);

// Synchronize enable based on PdmDes_done rising edge, using system clock
always @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        en_i_sync <= 1'b0;
        PdmDes_done_dly <= 1'b0;
    end else begin
        PdmDes_done_dly <= PdmDes_done; // Delay done signal by one clock
        // Check for rising edge of PdmDes_done
        if (PdmDes_done && !PdmDes_done_dly) begin
             if(en_i) begin
                en_i_sync <= 1'b1; // Latch enable high when PdmDes is done and en_i is high
             end
        end
        // Optional: Add logic to de-assert en_i_sync if needed, e.g., based on PdmSer done
        // else if (some_condition_to_reset) begin
        //    en_i_sync <= 1'b0;
        // end
   end
end

// Register the output data from PdmDes
always @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        PdmSer_In <= 16'b0;
    end else begin
        // Consider only latching when PdmDes_done is high if needed
        // if (PdmDes_done) begin
             PdmSer_In <= PdmDes_dout;
        // end
    end
end

// Instantiate PDM Serializer (PWM generator)
// Assuming PdmSer has clk, rst_n, en, din, done, pwm_audio_o ports
PdmSer PdmSer_Inst (
    .clk(clk_i),
    .rst_n(rst_ni),          // Pass reset if PdmSer needs it
    .en(en_i_sync),        // Use the synchronized enable
    .din(PdmSer_In),
    .pwm_audio_o(pwm_audio_o),
    .done(done_o)           // Output overall done signal
);

endmodule

//------------------------------------------------------------------------------
// Placeholder for PdmDes module (assuming its interface)
//------------------------------------------------------------------------------
module PdmDes (
    input wire clk,
    input wire rst_n,
    input wire en,
    input wire pdm_m_data_i,
    output wire pdm_m_clk_o,
    output wire [15:0] dout,
    output wire done
);
    // Internal logic for PDM deserialization would go here
    // This is just a placeholder to allow the top module to compile
    assign pdm_m_clk_o = clk; // Example assignment
    assign dout = 16'hAAAA;  // Example assignment
    assign done = 1'b0;      // Example assignment (needs proper logic)

endmodule

//------------------------------------------------------------------------------
// Placeholder for PdmSer module (assuming its interface)
//------------------------------------------------------------------------------
module PdmSer (
    input wire clk,
    input wire rst_n,
    input wire en,
    input wire [15:0] din,
    output wire pwm_audio_o,
    output wire done
);
    // Internal logic for PWM generation would go here
    // This is just a placeholder to allow the top module to compile
    assign pwm_audio_o = 1'b0; // Example assignment
    assign done = 1'b0;       // Example assignment (needs proper logic)

endmodule