module adio_codec (
    output          oAUD_DATA,
    output          oAUD_LRCK,
    output reg      oAUD_BCK,
    input           key1_on,
    input   [1:0]   iSrc_Select,
    input           iCLK_18_4,
    input           iRST_N,
    input   [15:0]  sound1
);

    parameter   REF_CLK         =   18432000;
    parameter   SAMPLE_RATE     =   48000;
    parameter   DATA_WIDTH      =   16;
    parameter   CHANNEL_NUM     =   2;
    parameter   SIN_SAMPLE_DATA =   48;
    parameter   SIN_SANPLE      =   0; // Note: Unusual name, kept as is.

    localparam BCK_DIV_MAX      =   REF_CLK/(SAMPLE_RATE*DATA_WIDTH*CHANNEL_NUM*2) - 1;
    localparam LRCK_1X_DIV_MAX  =   REF_CLK/(SAMPLE_RATE*2) - 1;
    localparam LRCK_2X_DIV_MAX  =   REF_CLK/(SAMPLE_RATE*4) - 1;
    localparam LRCK_4X_DIV_MAX  =   REF_CLK/(SAMPLE_RATE*8) - 1;

    reg     [3:0]   BCK_DIV;
    reg     [8:0]   LRCK_1X_DIV;
    reg     [7:0]   LRCK_2X_DIV;
    reg     [6:0]   LRCK_4X_DIV;
    reg     [3:0]   SEL_Cont;
    reg     [5:0]   SIN_Cont;
    reg             LRCK_1X;
    reg             LRCK_2X;
    reg             LRCK_4X;

    // BCK Generator
    always @(posedge iCLK_18_4 or negedge iRST_N) begin
        if (!iRST_N) begin
            BCK_DIV     <= 4'b0;
            oAUD_BCK    <= 1'b0;
        end else begin
            if (BCK_DIV >= BCK_DIV_MAX) begin
                BCK_DIV     <= 4'b0;
                oAUD_BCK    <= ~oAUD_BCK;
            end else begin
                BCK_DIV     <= BCK_DIV + 1;
            end
        end
    end

    // LRCK Generators (1x, 2x, 4x Sample Rate)
    always @(posedge iCLK_18_4 or negedge iRST_N) begin
        if (!iRST_N) begin
            LRCK_1X_DIV <= 9'b0;
            LRCK_2X_DIV <= 8'b0;
            LRCK_4X_DIV <= 7'b0;
            LRCK_1X     <= 1'b0;
            LRCK_2X     <= 1'b0;
            LRCK_4X     <= 1'b0;
        end else begin
            // 1x LRCK
            if (LRCK_1X_DIV >= LRCK_1X_DIV_MAX) begin
                LRCK_1X_DIV <= 9'b0;
                LRCK_1X     <= ~LRCK_1X;
            end else begin
                LRCK_1X_DIV <= LRCK_1X_DIV + 1;
            end

            // 2x LRCK
            if (LRCK_2X_DIV >= LRCK_2X_DIV_MAX) begin
                LRCK_2X_DIV <= 8'b0;
                LRCK_2X     <= ~LRCK_2X;
            end else begin
                LRCK_2X_DIV <= LRCK_2X_DIV + 1;
            end

            // 4x LRCK
            if (LRCK_4X_DIV >= LRCK_4X_DIV_MAX) begin
                LRCK_4X_DIV <= 7'b0;
                LRCK_4X     <= ~LRCK_4X;
            end else begin
                LRCK_4X_DIV <= LRCK_4X_DIV + 1;
            end
        end
    end

    assign oAUD_LRCK = LRCK_1X;

    // SIN Counter (Example usage, counts based on LRCK)
    always @(negedge LRCK_1X or negedge iRST_N) begin // Assuming negedge trigger is intentional
        if (!iRST_N) begin
            SIN_Cont <= 6'b0;
        end else begin
            if (SIN_Cont < SIN_SAMPLE_DATA - 1) begin
                SIN_Cont <= SIN_Cont + 1;
            else begin
                SIN_Cont <= 6'b0;
            end
        end
    end

    wire [15:0] music1_ramp;
    wire [15:0] music1 = music1_ramp; // Assign output of wave_gen_string
    wire [15:0] sound_o;
    assign sound_o = music1; // Use generated music as sound source

    // Bit Select Counter for Serialization
    always @(negedge oAUD_BCK or negedge iRST_N) begin // Serialize on falling BCK edge
        if (!iRST_N) begin
            SEL_Cont <= 4'b0;
        end else begin
             // Assuming DATA_WIDTH is 16, counter needs 4 bits (0-15)
            if (SEL_Cont == DATA_WIDTH - 1) begin
                 SEL_Cont <= 4'b0;
            end else begin
                 SEL_Cont <= SEL_Cont + 1;
            end
           // Original code just incremented: SEL_Cont <= SEL_Cont + 1;
           // This depends on how many bits per LRCK cycle are needed.
           // If it's exactly 16 bits per half LRCK cycle:
           // if (LRCK_1X == 1'b0) begin // Example: Reset counter at start of frame
           //      if (SEL_Cont == DATA_WIDTH - 1)
           //          SEL_Cont <= 4'b0;
           //      else
           //          SEL_Cont <= SEL_Cont + 1;
           // end else if (LRCK_1X == 1'b1) begin // Reset counter for next channel
           //      if (SEL_Cont == DATA_WIDTH - 1)
           //          SEL_Cont <= 4'b0;
           //      else
           //          SEL_Cont <= SEL_Cont + 1;
           // end else begin
           //      SEL_Cont <= SEL_Cont + 1; // Default increment
           // end
           // Let's stick to simple increment as per original for now. Needs clarification based on I2S spec.
        end
    end

    // Data Output Multiplexer
    // Selects generated sound based on key1 and source select, serializes MSB first
    assign oAUD_DATA = ((key1_on) && (iSrc_Select == SIN_SANPLE)) ? sound_o[DATA_WIDTH-1-SEL_Cont] : 1'b0;
    // Corrected indexing: Use (DATA_WIDTH-1-SEL_Cont) for MSB first serialization
    // Original was sound_o[~SEL_Cont] which is unconventional but might work if SEL_Cont wraps correctly

    // Ramp Generator based on key press and sound1 input
    reg  [15:0] ramp1;
    localparam [15:0] ramp_max = 16'd60000; // Use localparam for constant

    // Synchronous ramp generation with asynchronous reset
    always @(negedge LRCK_1X or negedge iRST_N) begin // Clocked by negedge LRCK_1X
        if (!iRST_N) begin
            ramp1 <= 16'b0;
        end else begin
            if (!key1_on) begin // Reset ramp when key is not pressed
                ramp1 <= 16'b0;
            end else begin // Increment ramp when key is pressed
                if (ramp1 >= ramp_max) begin // Check >= to prevent potential overflow before reset
                    ramp1 <= 16'b0; // Wrap around
                end else begin
                     // Add sound1, ensure result doesn't exceed 16 bits if sound1 is large
                     // A simple add might be sufficient depending on sound1 magnitude.
                     ramp1 <= ramp1 + sound1;
                end
            end
        end
    end

    // Connect upper bits of ramp to wave generator input
    wire [5:0] ramp1_ramp;
    assign ramp1_ramp = ramp1[15:10]; // Use assign statement

    // Instantiate wave generator (definition assumed elsewhere)
    // Ensure wave_gen_string module definition exists
    wave_gen_string r1 (
        .ramp(ramp1_ramp),
        .music_o(music1_ramp) // Output connects to music1_ramp wire
    );

endmodule

// Placeholder for the wave_gen_string module (replace with actual definition)
// This is needed for the code to compile, even if functionally empty for testing syntax.
module wave_gen_string (
    input [5:0] ramp,
    output reg [15:0] music_o
);
    // Example: Simple pass-through or basic logic
    // Replace with actual wave generation logic (e.g., sine lookup)
    always @(*) begin
        // Simple example: scale ramp to full range
        music_o = {ramp, 10'b0}; // Just an example
    end
endmodule