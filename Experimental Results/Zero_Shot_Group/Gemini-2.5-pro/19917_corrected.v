module clk_rst_mngr (
    input clk_in,
    input rst_async_n,
    input en_clk_div8,
    output rst_sync_n,
    output clk_out,
    output clk_div2,
    output clk_div4,
    output clk_div8,
    output clk_div8_proc
  );

  // Clock divider counter
  reg [2:0] counter;
  always @(posedge clk_in or negedge rst_async_n) begin
    if (!rst_async_n) begin
      counter <= 3'b0;
    end else begin
      counter <= counter + 1; // Corrected: Increment counter
    end
  end

  // Clock outputs
  assign clk_out = clk_in;
  // Use registered outputs for divided clocks to avoid glitches
  reg clk_div2_reg, clk_div4_reg, clk_div8_reg;
  always @(posedge clk_in or negedge rst_async_n) begin
      if (!rst_async_n) begin
          clk_div2_reg <= 1'b0;
          clk_div4_reg <= 1'b0;
          clk_div8_reg <= 1'b0;
      end else begin
          clk_div2_reg <= counter[0];
          clk_div4_reg <= counter[1];
          clk_div8_reg <= counter[2];
      end
  end
  assign clk_div2 = clk_div2_reg;
  assign clk_div4 = clk_div4_reg;
  assign clk_div8 = clk_div8_reg;


  // Asynchronous Reset Synchronizer (using clk_in)
  reg synch_rst_reg1_n, synch_rst_reg2_n;
  always @(posedge clk_in or negedge rst_async_n) begin
    if (!rst_async_n) begin
      synch_rst_reg1_n <= 1'b0;
      synch_rst_reg2_n <= 1'b0;
    end else begin
      synch_rst_reg1_n <= 1'b1; // Release from reset
      synch_rst_reg2_n <= synch_rst_reg1_n; // Pipeline the sync
    end
  end
  assign rst_sync_n = synch_rst_reg2_n; // Output the synchronized reset

  // Register the enable signal using clk_in and async reset
  reg en_clk_div8_reg;
  always @(posedge clk_in or negedge rst_async_n) begin
      if (!rst_async_n) begin
          en_clk_div8_reg <= 1'b0;
      end else begin
          // Sample the enable on the main clock edge
          en_clk_div8_reg <= en_clk_div8;
      end
  end

  // Gated clock output (generally discouraged, but correcting original intent)
  // Gate clk_div8 (clk_div8_reg) with the registered enable
  // Use standard clock gating cell instance if available for better implementation
  // Simple behavioral model:
  assign clk_div8_proc = en_clk_div8_reg & clk_div8_reg;

endmodule