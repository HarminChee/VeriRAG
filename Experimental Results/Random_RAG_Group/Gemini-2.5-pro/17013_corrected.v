`timescale 1 ns / 1 ps
`timescale 1 ns / 1 ps
module dac_control
(
  input clk,
  input rst_n, // Added primary reset input
  input enable_update,
  input enable,
  input [7:0]dbA,
  input [7:0]dbB,
  input [7:0]dbC,
  input [7:0]dbD,
  output reg [7:0]db,
  output wire clr_n,
  output wire pd_n,
  output reg cs_n,
  output reg wr_n,
  output reg [1:0]A,
  output reg ldac_n
);

reg [7:0] clk_div;
reg clk_enable; // Synchronous enable signal

// Generate synchronous clock enable
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    clk_div <= 8'b0;
    clk_enable <= 1'b0;
  end else begin
    clk_div <= clk_div + 1;
    clk_enable <= (clk_div == 8'HFF);
  end
end

assign clr_n = enable; // Assumes 'enable' is a controllable primary input/signal
assign pd_n = 1;

reg [7:0]dbA_prev;
reg [7:0]dbB_prev;
reg [7:0]dbC_prev;
reg [7:0]dbD_prev;
reg update_trigger;

// Update trigger logic, synchronous to clk, enabled by clk_enable
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    dbA_prev <= 8'b0;
    dbB_prev <= 8'b0;
    dbC_prev <= 8'b0;
    dbD_prev <= 8'b0;
    update_trigger <= 1'b0;
  end else begin
    if (clk_enable) begin // Only update on clk_enable edge
        if (enable_update) begin // Check the original enable condition
            if ((dbA != dbA_prev) || (dbB != dbB_prev) || (dbC != dbC_prev) || (dbD != dbD_prev))
                update_trigger <= 1;
            else
                update_trigger <= 0;
            dbA_prev <= dbA;
            dbB_prev <= dbB;
            dbC_prev <= dbC;
            dbD_prev <= dbD;
        end else begin
             update_trigger <= 0; // Reset trigger if enable_update is low
             // db*_prev hold their values
        end
    end
    // If !clk_enable, registers hold their values.
  end
end

reg [3:0] cntr;
reg [3:0] cntr_nxt; // Next state for counter
reg update_active; // Signal indicating the update sequence is running

// Combinational logic for next state and activity
always @(*) begin
    update_active = (update_trigger == 1) || (cntr != 0);
    if (update_active) begin
        cntr_nxt = (cntr == 9) ? 4'b0 : cntr + 1; // Sequence 0-9
    end else begin
        cntr_nxt = cntr; // Hold state
    end
end

// Main state machine logic, synchronous to clk, enabled by clk_enable
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    cntr <= 4'b0;
    A <= 2'b0;
    db <= 8'b0;
    wr_n <= 1'b1;   // Default inactive state
    ldac_n <= 1'b1; // Default inactive state
  end else begin
    if (clk_enable) begin
        cntr <= cntr_nxt; // Update counter state

        if (update_active) begin // Actions based on *current* cntr before update
            // Default assignments (inactive high)
            wr_n <= 1'b1;
            ldac_n <= 1'b1;

            case (cntr) // Use current value of cntr to determine outputs
              0 : begin A <= 2'b00; db <= dbA; wr_n <= 0; end // Write A
              1 : begin wr_n <= 1; end // Finish write A
              2 : begin A <= 2'b01; db <= dbB; wr_n <= 0; end // Write B
              3 : begin wr_n <= 1; end // Finish write B
              4 : begin A <= 2'b10; db <= dbC; wr_n <= 0; end // Write C
              5 : begin wr_n <= 1; end // Finish write C
              6 : begin A <= 2'b11; db <= dbD; wr_n <= 0; end // Write D
              7 : begin wr_n <= 1; end // Finish write D
              8 : begin ldac_n <= 0; end // Pulse LDAC low (latch data)
              9 : begin ldac_n <= 1; end // Bring LDAC high, end sequence
              default: begin // Should not happen
                 wr_n <= 1'b1;
                 ldac_n <= 1'b1;
              end
            endcase
        end else begin
            // Not active, set outputs to default/inactive state
            wr_n <= 1'b1;
            ldac_n <= 1'b1;
            // A, db hold previous values. cntr holds 0.
        end
    end
    // If !clk_enable, all registers hold values
  end
end

// cs_n logic, synchronous to clk, reflects active state during clk_enable
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cs_n <= 1'b1; // Inactive high
    end else begin
        if (clk_enable) begin
            // cs_n is low when the update sequence is active
            if (update_active) begin
               cs_n <= 1'b0; // Active low during sequence
            end else begin
               cs_n <= 1'b1; // Inactive high otherwise
            end
        end
        // If !clk_enable, cs_n holds value
    end
end

endmodule