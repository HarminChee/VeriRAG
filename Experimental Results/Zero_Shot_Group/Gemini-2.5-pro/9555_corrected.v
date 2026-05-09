module i2s
(
    input           clk_i,
    input           rst_i,
    input  [31:0]   pcm_data_i,
    input           pcm_fifo_empty_i,
    output reg      pcm_fifo_rd_o,
    output reg      pcm_fifo_ur_o,
    output reg      bclk_o,
    output reg      ws_o,
    output reg      data_o
);

parameter       CLK_DIVISOR = 6; // Generates BCLK = clk_i / (CLK_DIVISOR * 2)

localparam      CLK_DIV_WIDTH = $clog2(CLK_DIVISOR);
localparam      BIT_COUNT_WIDTH = 4; // Counts 0 to 15

reg             audio_clock;
reg [CLK_DIV_WIDTH-1:0] audio_clock_div;
reg [BIT_COUNT_WIDTH-1:0] bit_count;
reg             word_sel; // 0 for left (reg0), 1 for right (reg1)
reg [15:0]      input_reg0; // Left channel data
reg [15:0]      input_reg1; // Right channel data
reg [31:0]      pcm_data_last; // Store last valid data in case of underrun
reg             prev_audio_clock;


// Audio Clock Generation (BCLK/2)
always @(posedge clk_i or posedge rst_i)
begin
    if (rst_i == 1'b1)
    begin
        audio_clock_div <= 0;
        audio_clock     <= 1'b0;
    end
    else
    begin
        if (audio_clock_div == (CLK_DIVISOR - 1))
        begin
            audio_clock     <= ~audio_clock;
            audio_clock_div <= 0;
        end
        else
        begin
            audio_clock_div <= audio_clock_div + 1;
        end
    end
end

// I2S Main Logic
always @(posedge clk_i or posedge rst_i)
begin
    if (rst_i == 1'b1)
    begin
        input_reg0       <= 16'h0000;
        input_reg1       <= 16'h0000;
        bit_count        <= 0;
        data_o           <= 1'b0;
        word_sel         <= 1'b0; // Start with Left channel
        ws_o             <= 1'b0; // WS corresponds to word_sel
        prev_audio_clock <= 1'b0;
        pcm_fifo_rd_o    <= 1'b0;
        pcm_fifo_ur_o    <= 1'b0;
        pcm_data_last    <= 32'h00000000;
        bclk_o           <= 1'b0;
    end
    else
    begin
        // Default assignments
        pcm_fifo_rd_o    <= 1'b0;
        // pcm_fifo_ur_o should persist if underrun occurs until reset?
        // Let's make it pulse for one cycle as in the original code.
        pcm_fifo_ur_o    <= 1'b0;

        prev_audio_clock <= audio_clock;

        // Detect falling edge of audio_clock (center of BCLK low phase)
        // This is where WS changes and data is latched internally
        if ((prev_audio_clock == 1'b1) && (audio_clock == 1'b0))
        begin
            bclk_o <= 1'b0; // BCLK goes low

            if (bit_count == 0) // Start of a new word (Left or Right)
            begin
                word_sel <= ~word_sel; // Toggle channel select
                ws_o     <= ~word_sel; // Update WS output (WS changes one cycle before MSB)

                // Load data for the *next* word transmission
                if (pcm_fifo_empty_i == 1'b0)
                begin
                    pcm_data_last <= pcm_data_i;
                    input_reg0    <= pcm_data_i[31:16]; // Left channel
                    input_reg1    <= pcm_data_i[15:0];  // Right channel
                    pcm_fifo_rd_o <= 1'b1;             // Request next data word
                end
                else // FIFO is empty - Underrun
                begin
                    // Keep transmitting the last valid data
                    input_reg0    <= pcm_data_last[31:16];
                    input_reg1    <= pcm_data_last[15:0];
                    pcm_fifo_ur_o <= 1'b1; // Signal underrun
                end

                // Output MSB of the *current* word (which was loaded previously)
                if (word_sel == 1'b0) // Outputting Left channel MSB
                    data_o <= input_reg0[15];
                else                  // Outputting Right channel MSB
                    data_o <= input_reg1[15];

                bit_count <= bit_count + 1;
            end
            else // Continue shifting out the current word
            begin
                 if (word_sel == 1'b0) // Outputting Left channel data
                 begin
                    data_o <= input_reg0[15];
                    input_reg0 <= {input_reg0[14:0], 1'b0}; // Shift left
                 end
                 else // Outputting Right channel data
                 begin
                    data_o <= input_reg1[15];
                    input_reg1 <= {input_reg1[14:0], 1'b0}; // Shift left
                 end

                 if (bit_count == 15) // Reached end of 16-bit word
                     bit_count <= 0;
                 else
                     bit_count <= bit_count + 1;
            end
        end
        // Detect rising edge of audio_clock (center of BCLK high phase)
        // Data is shifted out on this edge in I2S standard
        else if ((prev_audio_clock == 1'b0) && (audio_clock == 1'b1))
        begin
            bclk_o <= 1'b1; // BCLK goes high
            // Data output logic is handled on the falling edge of audio_clock
            // to ensure setup time before the rising edge of BCLK.
        end
    end
end

// Function to calculate log base 2
function integer $clog2 (input integer value);
    begin
        value = value - 1;
        for ($clog2 = 0; value > 0; $clog2 = $clog2 + 1)
            value = value >> 1;
    end
endfunction

endmodule