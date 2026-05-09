`timescale 1 ns / 1 ps
module dac_control_corrected_ffc
(
  input clk, // Primary clock input
  input enable_update,
  input enable, // Used for clr_n
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

// Clock divider counter - clocked by primary clock 'clk'
reg [7:0] clk_div;
// Clock enable signal derived from clk_div - combinational logic
// Generates a single 'clk' cycle pulse when clk_div reaches FF
wire clk_en = (clk_div == 8'HFF);

// Static assignments
assign clr_n = enable; // Assuming 'enable' controls clear
assign pd_n = 1;       // Power down tied inactive

// Registers to store previous data values - clocked by primary clock 'clk'
reg [7:0]dbA_prev;
reg [7:0]dbB_prev;
reg [7:0]dbC_prev;
reg [7:0]dbD_prev;
// Update trigger register - clocked by primary clock 'clk'
reg update_trigger;

// State machine counter - clocked by primary clock 'clk'
reg [3:0] cntr;

// Clock divider logic - runs continuously on 'clk'
always @(posedge clk) begin
  clk_div <= clk_div + 1;
end

// Update trigger and previous data capture logic
// Clocked by primary clock 'clk', enabled by 'clk_en' and 'enable_update'
always @(posedge clk) begin
  if (clk_en && enable_update) begin // Update only when enabled
    if ((dbA != dbA_prev) || (dbB != dbB_prev) || (dbC != dbC_prev) || (dbD != dbD_prev)) begin
      update_trigger <= 1;
    end else begin
      update_trigger <= 0;
    end
    // Capture current data into previous data registers
    dbA_prev <= dbA;
    dbB_prev <= dbB;
    dbC_prev <= dbC;
    dbD_prev <= dbD;
  end else if (clk_en && !enable_update) begin
      // Reset trigger if update not enabled on the clk_en pulse
      update_trigger <= 0;
  end
  // Note: If clk_en is low, update_trigger and dbX_prev registers hold their values.
end

// DAC control state machine logic
// Clocked by primary clock 'clk', enabled by 'clk_en'
// Assumes wr_n, cs_n, ldac_n are active low based on '_n' suffix
always @(posedge clk) begin
  if (clk_en) begin // State machine progresses only when clk_en is high
    if ((update_trigger == 1) || (cntr != 0)) begin
        cs_n <= 0; // Assert CS# when state machine is active

        // Actions based on the *current* value of cntr
        case (cntr)
          0: begin // Setup Load A
                 A <= 2'b00;
                 db <= dbA;
                 wr_n <= 1;   // De-assert WR#
                 ldac_n <= 1; // De-assert LDAC#
               end
          1: begin // Assert WR# for A
                 wr_n <= 0;
               end
          2: begin // Setup Load B
                 A <= 2'b01;
                 db <= dbB;
                 wr_n <= 1;   // De-assert WR#
               end
          3: begin // Assert WR# for B
                 wr_n <= 0;
               end
          4: begin // Setup Load C
                 A <= 2'b10;
                 db <= dbC;
                 wr_n <= 1;   // De-assert WR#
               end
          5: begin // Assert WR# for C
                 wr_n <= 0;
               end
          6: begin // Setup Load D
                 A <= 2'b11;
                 db <= dbD;
                 wr_n <= 1;   // De-assert WR#
               end
          7: begin // Assert WR# for D
                 wr_n <= 0;
               end
          8: begin // De-assert WR# (finish writes)
                 wr_n <= 1;
               end
          9: begin // Assert LDAC#
                 ldac_n <= 0;
               end
          default: begin // Should not be reached
                 wr_n <= 1;
                 ldac_n <= 1;
                 cs_n <= 1;
               end
        endcase

        // Increment counter for the next state (on the next clk_en)
        cntr <= (cntr + 1) % 10;

    end else begin // State machine is idle (cntr == 0 and update_trigger == 0)
      // Ensure control signals are in inactive state
      cs_n <= 1;   // De-assert CS#
      wr_n <= 1;   // De-assert WR#
      ldac_n <= 1; // De-assert LDAC#
      // cntr remains 0. A and db hold previous values.
    end
  end else begin
      // If clk_en is low, the state machine pauses.
      // If it was active (cntr != 0), it will resume from the current state
      // on the next clk_en pulse. Registers hold their values.
      // If it was idle (cntr == 0), ensure control signals remain inactive.
      if (cntr == 0) begin
          cs_n <= 1;
          wr_n <= 1;
          ldac_n <= 1;
      end
  end
end

endmodule