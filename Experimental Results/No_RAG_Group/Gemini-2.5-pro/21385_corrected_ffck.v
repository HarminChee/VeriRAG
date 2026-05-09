`timescale 1 ns / 100 ps
module dec256sinc24b_corrected_ffc
(
    input                       reset_i,
    input                       mclkout_i, // Primary clock input
    input                       mdata_i,
    output                      data_rdy_o,
    output reg  [15:0]          data_o
);

// Removed reg ip_data1; - Now a wire assigned combinatorially
wire [23:0] ip_data1;
reg [23:0]  acc1;
reg [23:0]  acc2;
reg [23:0]  acc3;
// Removed acc3_d1 - not used
reg [23:0]  acc3_d2;
reg [23:0]  diff1;
reg [23:0]  diff2;
reg [23:0]  diff3;
reg [23:0]  diff1_d;
reg [23:0]  diff2_d;
reg [7:0]   word_count;
// Removed reg word_clk; - Internally generated clock removed

// DFT Fix: Generate enable signal instead of internal clock
wire        update_enable;
reg         data_rdy_o_reg; // Register for data_rdy_o output timing

// Combinational assignment for ip_data1 based on mdata_i
assign ip_data1 = (mdata_i == 1'b0) ? 24'd0 : 24'd1;

// Assign data_rdy_o based on the registered enable signal
assign data_rdy_o = data_rdy_o_reg;

// Accumulator stages clocked by negedge of primary clock
always @(negedge mclkout_i or posedge reset_i)
begin
    if( reset_i == 1'b1 )
    begin
        acc1    <= 0;
        acc2    <= 0;
        acc3    <= 0;
    end
    else
    begin
        acc1    <= acc1 + ip_data1; // Using combinational ip_data1
        acc2    <= acc2 + acc1;
        acc3    <= acc3 + acc2;
    end
end

// Word counter clocked by posedge of primary clock
always@(posedge mclkout_i or posedge reset_i )
begin
    if(reset_i == 1'b1)
    begin
        word_count  <= 0;
    end
    else
    begin
        word_count <= word_count + 1;
    end
end

// DFT Fix: Generate update_enable combinatorially based on word_count
// Enable is high for one cycle when word_count is 127, triggering update on the next posedge mclkout_i
assign update_enable = (word_count == 8'd127);

// DFT Fix: Logic previously clocked by word_clk is now clocked by mclkout_i and enabled by update_enable
always @(posedge mclkout_i or posedge reset_i)
begin
    if(reset_i == 1'b1)
    begin
        acc3_d2 <= 0;
        diff1_d <= 0;
        diff2_d <= 0;
        diff1   <= 0;
        diff2   <= 0;
        diff3   <= 0;
    end
    else if (update_enable) // Update only when enabled
    begin
        // Capture acc3 value from the previous cycle on enable
        acc3_d2 <= acc3; // Note: acc3 updates on negedge, this samples on posedge
                         // Consider if acc3 needs synchronization or if this timing is intended.
                         // Assuming current acc3 value (after last negedge) is desired.

        // Calculate differences using values from the previous enabled cycle
        diff1   <= acc3 - acc3_d2;
        diff1_d <= diff1;
        diff2   <= diff1 - diff1_d;
        diff2_d <= diff2;
        diff3   <= diff2 - diff2_d;

    end
    // Note: If no enable, registers hold their values (implied)
end

// DFT Fix: data_o register logic previously clocked by word_clk
// Now clocked by mclkout_i and enabled by update_enable
always @(posedge mclkout_i or posedge reset_i)
begin
    if (reset_i == 1'b1) begin
        data_o <= 16'b0;
    end else if (update_enable) begin // Update only when enabled
        // Capture the upper bits of diff3 calculated in the same enabled cycle
        data_o[15]  <= diff3[23];
        data_o[14]  <= diff3[22];
        data_o[13]  <= diff3[21];
        data_o[12]  <= diff3[20];
        data_o[11]  <= diff3[19];
        data_o[10]  <= diff3[18];
        data_o[9]   <= diff3[17];
        data_o[8]   <= diff3[16];
        data_o[7]   <= diff3[15];
        data_o[6]   <= diff3[14];
        data_o[5]   <= diff3[13];
        data_o[4]   <= diff3[12];
        data_o[3]   <= diff3[11];
        data_o[2]   <= diff3[10];
        data_o[1]   <= diff3[9];
        data_o[0]   <= diff3[8];
    end
    // Note: If no enable, data_o holds its value (implied)
end

// Register the enable signal to create data_rdy_o
// data_rdy_o will be high for one cycle, coinciding with the data_o update
always @(posedge mclkout_i or posedge reset_i) begin
    if (reset_i) begin
        data_rdy_o_reg <= 1'b0;
    end else begin
        data_rdy_o_reg <= update_enable;
    end
end

endmodule