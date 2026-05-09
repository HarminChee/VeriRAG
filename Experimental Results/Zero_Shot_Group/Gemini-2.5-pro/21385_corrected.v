`timescale 1 ns / 100 ps 

module dec256sinc24b
(
    input                       reset_i,
    input                       mclkout_i,    // High-speed clock
    input                       mdata_i,      // Single-bit input data
    output                      data_rdy_o,   // Data ready pulse (single cycle)
    output reg  [15:0]          data_o        // Decimated output data
);

// Internal registers and wires
reg  [23:0] ip_data1;  // Registered and extended input data
reg  [23:0] acc1;      // Integrator stage 1
reg  [23:0] acc2;      // Integrator stage 2
reg  [23:0] acc3;      // Integrator stage 3

reg  [7:0]  word_count; // Counter for decimation rate (0 to 255)
reg         comb_enable_reg; // Registered enable signal for comb stage
wire        comb_enable;     // Combinatorial enable signal

reg  [23:0] acc3_d1;   // Delayed acc3 (1 decimation cycle)
reg  [23:0] diff1_d1;  // Delayed diff1 (1 decimation cycle)
reg  [23:0] diff2_d1;  // Delayed diff2 (1 decimation cycle)
wire [23:0] diff1;     // Comb stage 1 output
wire [23:0] diff2;     // Comb stage 2 output
wire [23:0] diff3;     // Comb stage 3 output

reg         data_rdy_o_reg; // Internal register for data_rdy_o

//--------------------------------------------------------------------------
// Input Sampling and Integrator Stage (runs at high-speed clock, negedge)
//--------------------------------------------------------------------------
always @(negedge mclkout_i or posedge reset_i)
begin
    if (reset_i == 1'b1)
    begin
        ip_data1 <= 24'd0;
        acc1     <= 24'd0;
        acc2     <= 24'd0;
        acc3     <= 24'd0;
    end
    else
    begin
        // Sample and zero-extend input data
        ip_data1 <= {23'b0, mdata_i}; 
        // Integrator stages
        acc1     <= acc1 + ip_data1;
        acc2     <= acc2 + acc1;
        acc3     <= acc3 + acc2;
    end
end

//--------------------------------------------------------------------------
// Decimation Counter and Strobe Generation (runs at high-speed clock, posedge)
//--------------------------------------------------------------------------
// Strobe signal: high for one mclkout_i cycle when count reaches 255
assign comb_enable = (word_count == 8'd255);

always @(posedge mclkout_i or posedge reset_i)
begin
    if (reset_i == 1'b1)
    begin
        word_count      <= 8'd0;
        comb_enable_reg <= 1'b0;
    end
    else
    begin
        comb_enable_reg <= comb_enable; // Register the strobe for use in next cycle
        if (word_count == 8'd255)
        begin
            word_count <= 8'd0; // Reset counter
        end
        else
        begin
            word_count <= word_count + 1; // Increment counter
        end
    end
end

//--------------------------------------------------------------------------
// Comb Stage (runs at low-speed rate, clocked by mclkout_i, enabled by strobe)
//--------------------------------------------------------------------------
// Combinatorial difference calculations
// These use the acc3 value updated on the previous negedge mclkout_i
// and delayed values from previous decimation cycles.
assign diff1 = acc3 - acc3_d1;
assign diff2 = diff1 - diff1_d1;
assign diff3 = diff2 - diff2_d1;

// Register delayed values and final output data on posedge mclkout_i
// Update occurs one cycle after the strobe is asserted (using comb_enable_reg)
always @(posedge mclkout_i or posedge reset_i)
begin
    if (reset_i == 1'b1)
    begin
        acc3_d1  <= 24'd0;
        diff1_d1 <= 24'd0;
        diff2_d1 <= 24'd0;
        data_o   <= 16'd0; // Reset registered output
    end
    else if (comb_enable_reg) // Update enabled by registered strobe
    begin
        acc3_d1  <= acc3;   // Store current acc3 for next cycle's diff1 calculation
        diff1_d1 <= diff1;  // Store current diff1 for next cycle's diff2 calculation
        diff2_d1 <= diff2;  // Store current diff2 for next cycle's diff3 calculation
        data_o   <= diff3[23:8]; // Store truncated output data
    end
end

//--------------------------------------------------------------------------
// Output Data Ready Signal (registered, pulsed high for one mclkout_i cycle)
//--------------------------------------------------------------------------
assign data_rdy_o = data_rdy_o_reg; // Assign registered value to output port

always @(posedge mclkout_i or posedge reset_i)
begin
    if (reset_i == 1'b1)
    begin
        data_rdy_o_reg <= 1'b0;
    end
    else
    begin
        data_rdy_o_reg <= comb_enable_reg; // data_rdy is high when comb stage registers (and data_o) are updated
    end
end

endmodule