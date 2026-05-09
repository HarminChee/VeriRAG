`timescale 1ns / 1ps
// File: 1_corrected_cdf.v
module PdmDes(
    input clk,
    input rst_n, // Added asynchronous reset for better practice
    input test_mode, // Added test mode signal for DFT
    input en,
    output done,
    output [15:0] dout,
    output pdm_m_clk_o,
    input pdm_m_data_i
    );

// Parameter C_PDM_FREQ_HZ=2000000; // Parameter not used, commented out

reg en_int=0;
reg done_int=0;
reg clk_int=0;
reg pdm_clk_rising;
reg [15:0] pdm_tmp;
reg [15:0] dout_reg; // Make dout a register
integer cnt_bits=0; // Consider replacing integer with fixed-size reg [4:0] if synthesis requires
integer cnt_clk=0;  // Consider replacing integer with fixed-size reg [4:0] if synthesis requires

assign done = done_int;
assign pdm_m_clk_o = clk_int;
assign dout = dout_reg; // Assign registered version to output

// Register enable signal
// Use asynchronous reset rst_n
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        en_int <= 1'b0;
    end else begin
        en_int <= en;
    end
end

// PDM data shift register
// Use asynchronous reset rst_n
// Condition update on pdm_clk_rising (which is controlled by test_mode)
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pdm_tmp <= 16'b0;
    end else if (en == 1'b0) begin // Functional synchronous reset/clear when disabled
        pdm_tmp <= 16'b0;
    end else if (pdm_clk_rising) begin // Update only when pdm_clk_rising is asserted (functional mode)
        pdm_tmp <= {pdm_tmp[14:0], pdm_m_data_i};
    end
    // In test mode, pdm_clk_rising is forced low, so pdm_tmp holds unless en=0 or !rst_n
end

// Bit counter
// Use asynchronous reset rst_n
// Condition update on pdm_clk_rising (which is controlled by test_mode)
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_bits <= 0;
    end else if (en_int == 1'b0) begin // Functional synchronous reset/clear when disabled
        cnt_bits <= 0;
    end else if (pdm_clk_rising) begin // Update only when pdm_clk_rising is asserted (functional mode)
        if (cnt_bits == 15) begin
            cnt_bits <= 0;
        end else begin
            cnt_bits <= cnt_bits + 1;
        end
    end
    // In test mode, pdm_clk_rising is forced low, so cnt_bits holds unless en_int=0 or !rst_n
end

// Done signal and output data register
// Use asynchronous reset rst_n
// Condition update on pdm_clk_rising (which is controlled by test_mode)
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        done_int <= 1'b0;
        dout_reg <= 16'b0;
    end else begin
        // Default assignment to handle 'else' case for done_int
        done_int <= 1'b0;
        // Update logic based on pdm_clk_rising
        if (pdm_clk_rising) begin
            if (cnt_bits == 0 && en_int) begin // Condition to latch output and set done
                done_int <= 1'b1;
                dout_reg <= pdm_tmp;
            end
            // else: done_int remains 0 (from default assignment)
            // Note: dout_reg holds its value if not updated here
        end
        // else (!pdm_clk_rising): done_int remains 0 (from default assignment)
        // Note: dout_reg holds its value if not updated here
    end
    // In test mode, pdm_clk_rising is forced low, so done_int remains 0 and dout_reg holds, unless !rst_n
end


// Clock divider and pdm_clk_rising generation
// Use asynchronous reset rst_n
// Isolate pdm_clk_rising generation during test mode to fix CDFDAT related issue
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_clk <= 0;
        clk_int <= 1'b0;
        pdm_clk_rising <= 1'b0;
    end else begin
        if (test_mode) begin
            // In test mode, hold the state of clock divider and force pdm_clk_rising low
            // This prevents the clock-derived logic from affecting data paths during test.
            cnt_clk <= cnt_clk; // Hold state
            clk_int <= clk_int; // Hold state
            pdm_clk_rising <= 1'b0; // Force control signal inactive
        end else begin // Functional mode
            reg will_rise; // Temporary signal for clarity

            // Determine if pdm_clk_rising should be asserted in the next cycle
            // It should rise for one cycle when cnt_clk hits 24 and clk_int is about to fall (was 1)
            will_rise = (cnt_clk == 24 && clk_int == 1'b1);

            // Update counters and internal clock based on functional logic
            if (cnt_clk == 24) begin
                cnt_clk <= 0;
                clk_int <= ~clk_int; // Toggle internal clock
            end else begin
                cnt_clk <= cnt_clk + 1;
                // clk_int holds value until cnt_clk reaches 24
            end

            // Update pdm_clk_rising based on functional logic calculation
            pdm_clk_rising <= will_rise;
        end
    end
end

endmodule