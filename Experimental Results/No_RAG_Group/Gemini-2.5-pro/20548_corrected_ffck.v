module adio_codec_corrected_ffc (
    output wire         oAUD_DATA,
    output wire         oAUD_LRCK,
    output reg          oAUD_BCK,
    input wire          key1_on,
    input wire  [1:0]   iSrc_Select,
    input wire          iCLK_18_4,
    input wire          iRST_N,
    input wire  [15:0]  sound1
);

    parameter   REF_CLK         =   18432000;
    parameter   SAMPLE_RATE     =   48000;
    parameter   DATA_WIDTH      =   16;
    parameter   CHANNEL_NUM     =   2;
    parameter   SIN_SAMPLE_DATA =   48;
    parameter   SIN_SANPLE      =   0;
    parameter   RAMP_MAX_VAL    =   60000; // Define parameter for ramp_max

    // Registers for clock division and generated clocks
    reg [3:0]   BCK_DIV;
    reg [8:0]   LRCK_1X_DIV;
    reg [7:0]   LRCK_2X_DIV;
    reg [6:0]   LRCK_4X_DIV;
    reg         LRCK_1X;
    reg         LRCK_2X;
    reg         LRCK_4X;

    // Registers previously clocked by generated clocks
    reg [3:0]   SEL_Cont;
    reg [5:0]   SIN_Cont;
    reg [15:0]  ramp1;

    // Registers for edge detection
    reg         LRCK_1X_prev;
    reg         oAUD_BCK_prev;

    // Wires for clock enables
    wire        SIN_Cont_enable;
    wire        SEL_Cont_enable;
    wire        ramp1_enable;

    // Main synchronous logic block
    always @(posedge iCLK_18_4 or negedge iRST_N) begin
        if (!iRST_N) begin
            // Reset all registers
            BCK_DIV         <= 0;
            oAUD_BCK        <= 0;
            LRCK_1X_DIV     <= 0;
            LRCK_2X_DIV     <= 0;
            LRCK_4X_DIV     <= 0;
            LRCK_1X         <= 0;
            LRCK_2X         <= 0;
            LRCK_4X         <= 0;
            SEL_Cont        <= 0;
            SIN_Cont        <= 0;
            ramp1           <= 0;
            LRCK_1X_prev    <= 0;
            oAUD_BCK_prev   <= 0;
        end else begin
            // Store previous values for edge detection
            LRCK_1X_prev    <= LRCK_1X;
            oAUD_BCK_prev   <= oAUD_BCK;

            // BCK Generation
            if (BCK_DIV >= REF_CLK / (SAMPLE_RATE * DATA_WIDTH * CHANNEL_NUM * 2) - 1) begin
                BCK_DIV     <= 0;
                oAUD_BCK    <= ~oAUD_BCK;
            end else begin
                BCK_DIV     <= BCK_DIV + 1;
            end

            // LRCK Generations
            if (LRCK_1X_DIV >= REF_CLK / (SAMPLE_RATE * 2) - 1) begin
                LRCK_1X_DIV <= 0;
                LRCK_1X     <= ~LRCK_1X;
            end else begin
                LRCK_1X_DIV <= LRCK_1X_DIV + 1;
            end

            if (LRCK_2X_DIV >= REF_CLK / (SAMPLE_RATE * 4) - 1) begin
                LRCK_2X_DIV <= 0;
                LRCK_2X     <= ~LRCK_2X;
            end else begin
                LRCK_2X_DIV <= LRCK_2X_DIV + 1;
            end

            if (LRCK_4X_DIV >= REF_CLK / (SAMPLE_RATE * 8) - 1) begin
                LRCK_4X_DIV <= 0;
                LRCK_4X     <= ~LRCK_4X;
            end else begin
                LRCK_4X_DIV <= LRCK_4X_DIV + 1;
            end

            // Update SIN_Cont based on LRCK_1X negedge enable
            if (SIN_Cont_enable) begin
                if (SIN_Cont < SIN_SAMPLE_DATA - 1)
                    SIN_Cont <= SIN_Cont + 1;
                else
                    SIN_Cont <= 0;
            end

            // Update SEL_Cont based on oAUD_BCK negedge enable
            if (SEL_Cont_enable) begin
                SEL_Cont <= SEL_Cont + 1; // Wraps around automatically
            end

            // Update ramp1 based on key1_on and LRCK_1X negedge enable
            if (!key1_on) begin // Synchronous control based on key1_on
                ramp1 <= 0;
            end else if (ramp1_enable) begin
                if (ramp1 > RAMP_MAX_VAL) // Use defined parameter
                    ramp1 <= 0;
                else
                    ramp1 <= ramp1 + sound1;
            end
        end
    end

    // Generate clock enable signals (combinational logic)
    // Detect negedge synchronously: previous was high, current is low
    assign SIN_Cont_enable = LRCK_1X_prev & ~LRCK_1X;
    assign SEL_Cont_enable = oAUD_BCK_prev & ~oAUD_BCK;
    assign ramp1_enable    = LRCK_1X_prev & ~LRCK_1X; // Same enable condition as SIN_Cont

    // Output assignments and module instantiation
    assign oAUD_LRCK = LRCK_1X;

    wire [15:0] music1_ramp;
    wire [15:0] music1 = music1_ramp; // Intermediate signal
    wire [15:0] sound_o = music1;

    // Select output data based on SEL_Cont value
    // Note: SEL_Cont is 4 bits (0-15), accessing bit 16 (index 15) requires careful check
    // Using `~SEL_Cont[3:0]` selects bits 15 down to 0 based on SEL_Cont value.
    assign oAUD_DATA = ((key1_on) && (iSrc_Select == SIN_SANPLE)) ? sound_o[~SEL_Cont[3:0]] : 1'b0;

    // Use parameter for ramp_max comparison in always block
    // wire [15:0] ramp_max = RAMP_MAX_VAL; // No need for this wire, use parameter directly

    wire [5:0] ramp1_ramp = ramp1[15:10];

    wave_gen_string r1 (
        .ramp(ramp1_ramp),
        .music_o(music1_ramp)
    );

endmodule

// Dummy module for wave_gen_string as it was not provided
// Replace with actual module if available
module wave_gen_string (
    input wire [5:0] ramp,
    output wire [15:0] music_o
);
    // Placeholder logic
    assign music_o = {ramp, 10'b0};
endmodule