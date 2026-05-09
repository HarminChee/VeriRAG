module clk_rst_mngr_corrected_ffc (
    input clk_in,
    input rst_async_n,
    input en_clk_div8,
    output rst_sync_n, // Synchronized reset output (sync to clk_in)
    output clk_out,
    output clk_div2,
    output clk_div4,
    output clk_div8,
    output clk_div8_proc
  );

// Asynchronous Reset Synchronizer (using clk_in)
reg rst_sync1_n, rst_sync2_n;
always @(posedge clk_in or negedge rst_async_n) begin
    if (!rst_async_n) begin
        rst_sync1_n <= 1'b0;
        rst_sync2_n <= 1'b0;
    end else begin
        rst_sync1_n <= 1'b1;
        rst_sync2_n <= rst_sync1_n;
    end
end
assign rst_sync_n = rst_sync2_n; // Output the synchronized reset

// Clock Divider Counter (using clk_in and synchronous reset)
reg [2:0] counter;
always @(posedge clk_in or negedge rst_sync_n) begin // Use synchronized reset
    if (!rst_sync_n) begin
        counter <= 3'b0; // Reset to 0
    end else begin
        counter <= counter - 1; // Decrementing as in original
    end
end

// Derived clock signals (as data outputs)
assign clk_out = clk_in;
assign clk_div2 = counter[0];
assign clk_div4 = counter[1];
assign clk_div8 = counter[2]; // This is now just a data signal

// Logic previously clocked by clk_div8, now clocked by clk_in with enable
reg en_clk_div8_reg;
// Enable signal generation: Capture on the effective "posedge" of clk_div8.
// Assuming counter decrements 7->6->...->0->7...
// posedge clk_div8 happens when counter goes from 0 (000) to 7 (111).
// The enable should be active at the clock edge when counter is 0 (000).
wire clk_div8_posedge_enable = (counter == 3'b000);

always @(posedge clk_in or negedge rst_sync_n) begin // Use clk_in and sync reset
    if (!rst_sync_n) begin
        en_clk_div8_reg <= 1'b0;
    end else if (clk_div8_posedge_enable) begin // Enable logic: Capture input when counter is 0
        en_clk_div8_reg <= en_clk_div8;
    end
    // No else branch: register keeps its value if enable is low
end

// Gated clock output (combinational logic based on registered enable and counter bit)
// Note: This is still potentially problematic if used as a clock downstream,
// but it fixes the FFCKNP within this module.
assign clk_div8_proc = en_clk_div8_reg ? counter[2] : 1'b0;

// Original reset synchronizer clocked by clk_div8 is removed as it caused FFCKNP.
// The new synchronizer clocked by clk_in replaces its function relative to clk_in.

endmodule