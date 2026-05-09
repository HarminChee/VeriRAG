`timescale 1ns / 1ps

module PdmDes (
    input             clk,          // System clock
    input             rst_n,        // Asynchronous reset, active low
    input             en,           // Enable signal
    output reg        done,         // Output data valid pulse
    output reg [15:0] dout,         // Deserialized PDM data output
    output reg        pdm_m_clk_o,  // PDM clock output
    input             pdm_m_data_i  // PDM data input
);

    parameter C_SYSTEM_FREQ_HZ = 50_000_000; // Example System clock frequency
    parameter C_PDM_FREQ_HZ    = 2_000_000;  // Target PDM clock frequency

    // Calculate counter limit for PDM clock generation
    // Period = 1 / C_PDM_FREQ_HZ
    // Half Period = 1 / (2 * C_PDM_FREQ_HZ)
    // Ticks = Half Period / T_sys_clk = (1 / (2 * C_PDM_FREQ_HZ)) / (1 / C_SYSTEM_FREQ_HZ)
    // Ticks = C_SYSTEM_FREQ_HZ / (2 * C_PDM_FREQ_HZ)
    // Counter Limit = Ticks - 1
    localparam COUNTER_LIMIT = (C_SYSTEM_FREQ_HZ / (2 * C_PDM_FREQ_HZ)) - 1;

    // Internal registers
    reg [$clog2(COUNTER_LIMIT+1)-1:0] cnt_clk = 0;
    reg [3:0]                         cnt_bits = 0; // Count up to 15 (16 bits)
    reg [15:0]                        pdm_tmp = 0;
    reg                               pdm_clk_prev = 0;

    // Intermediate signal for rising edge detection
    wire pdm_clk_rising;

    // PDM Clock Generation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_clk <= 0;
            pdm_m_clk_o <= 1'b0;
        end else begin
            if (cnt_clk == COUNTER_LIMIT) begin
                cnt_clk <= 0;
                pdm_m_clk_o <= ~pdm_m_clk_o;
            end else begin
                cnt_clk <= cnt_clk + 1;
            end
        end
    end

    // PDM Clock Rising Edge Detection
    // Detects rising edge based on current and previous registered value of pdm_m_clk_o
    assign pdm_clk_rising = (pdm_m_clk_o == 1'b1) && (pdm_clk_prev == 1'b0);

    // Data Deserialization Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pdm_tmp <= 16'b0;
            cnt_bits <= 4'b0;
            done <= 1'b0;
            dout <= 16'b0;
            pdm_clk_prev <= 1'b0; // Reset previous state holder
        end else begin
            // Register previous clock state for edge detection
            pdm_clk_prev <= pdm_m_clk_o;

            // Default assignment for done pulse (active high for one cycle)
            done <= 1'b0;

            if (en) begin
                // Sample data on the detected rising edge of the PDM clock
                if (pdm_clk_rising) begin
                    pdm_tmp <= {pdm_tmp[14:0], pdm_m_data_i};
                    if (cnt_bits == 4'd15) begin
                        cnt_bits <= 4'd0;
                        // Latch the final complete data word
                        dout <= {pdm_tmp[14:0], pdm_m_data_i};
                        done <= 1'b1; // Assert done for one system clock cycle
                    end else begin
                        cnt_bits <= cnt_bits + 1;
                    end
                end
            end else begin // If not enabled, reset state
                cnt_bits <= 4'b0;
                pdm_tmp <= 16'b0;
                // done is already defaulted to 0
                // dout <= 16'b0; // Optional: Reset dout when disabled
            end
        end
    end

endmodule