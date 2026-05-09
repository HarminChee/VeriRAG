`timescale 1 ns / 1 ps

module dac_control (
  input             clk,
  input             rst_n, // Added reset input
  input             enable_update, // Trigger update sequence on change
  input             enable,        // Used for clr_n
  input       [7:0] dbA,
  input       [7:0] dbB,
  input       [7:0] dbC,
  input       [7:0] dbD,
  output reg  [7:0] db,
  output wire       clr_n,
  output wire       pd_n,
  output reg        cs_n,
  output reg        wr_n,
  output reg  [1:0] A,
  output reg        ldac_n
);

  // Internal slow clock generation
  reg [7:0] clk_div;
  reg       clk_int;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      clk_div <= 8'd0;
      clk_int <= 1'b0;
    end else begin
      clk_div <= clk_div + 1;
      clk_int <= (clk_div == 8'hFF); // Generate one pulse when counter wraps
    end
  end

  // Static assignments
  assign clr_n = enable; // Assuming enable controls clear directly
  assign pd_n = 1'b1;    // Power Down inactive

  // Input change detection logic
  reg [7:0] dbA_prev;
  reg [7:0] dbB_prev;
  reg [7:0] dbC_prev;
  reg [7:0] dbD_prev;
  reg       update_req; // Request an update sequence
  reg       update_pending; // Indicates an update is requested and not yet started

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      dbA_prev <= 8'd0;
      dbB_prev <= 8'd0;
      dbC_prev <= 8'd0;
      dbD_prev <= 8'd0;
      update_req <= 1'b0;
      update_pending <= 1'b0;
    end else begin
      // Latch previous values on the slow clock edge when update is enabled
      if (clk_int && enable_update) begin
         dbA_prev <= dbA;
         dbB_prev <= dbB;
         dbC_prev <= dbC;
         dbD_prev <= dbD;
         // Check if any input changed compared to the *previously latched* value
         if ((dbA != dbA_prev) || (dbB != dbB_prev) || (dbC != dbC_prev) || (dbD != dbD_prev)) begin
           update_req <= 1'b1;
           update_pending <= 1'b1; // Set pending flag
         end else begin
           update_req <= 1'b0;
           // Keep pending flag if already set and sequence hasn't started
           update_pending <= update_pending;
         end
      end else begin
          update_req <= 1'b0; // Clear request if not enabled or no clk_int
          // Keep pending flag if already set and sequence hasn't started
          update_pending <= update_pending;
      end

      // Clear pending flag when the state machine starts the sequence (moves from state 0)
      if (state != IDLE && state_next == IDLE) begin // Sequence completed
          update_pending <= 1'b0;
      end
    end
  end


  // State machine for DAC update sequence
  parameter IDLE      = 4'd0;
  parameter SETUP_A   = 4'd1;
  parameter WRITE_A   = 4'd2;
  parameter HOLD_A    = 4'd3;
  parameter SETUP_B   = 4'd4;
  parameter WRITE_B   = 4'd5;
  parameter HOLD_B    = 4'd6;
  parameter SETUP_C   = 4'd7;
  parameter WRITE_C   = 4'd8;
  parameter HOLD_C    = 4'd9;
  parameter SETUP_D   = 4'd10;
  parameter WRITE_D   = 4'd11;
  parameter HOLD_D    = 4'd12;
  parameter LDAC_LOW  = 4'd13;
  parameter LDAC_HIGH = 4'd14;

  reg [3:0] state, state_next;

  // State Register
  always @(posedge clk_int or negedge rst_n) begin
    if (!rst_n) begin
      state <= IDLE;
    end else begin
      state <= state_next;
    end
  end

  // Next State Logic & Output Logic
  always @(*) begin
    // Default assignments (combinational) - values held unless changed by state
    state_next = state;
    cs_n = 1'b1;         // Default inactive
    wr_n = 1'b1;         // Default inactive
    ldac_n = 1'b1;       // Default inactive
    A = A;               // Keep previous value unless changed
    db = db;             // Keep previous value unless changed

    case (state)
      IDLE: begin
        cs_n = 1'b1;
        wr_n = 1'b1;
        ldac_n = 1'b1;
        if (update_pending) begin // Start sequence if update requested
          state_next = SETUP_A;
        end else begin
          state_next = IDLE;
        end
      end

      SETUP_A: begin
        cs_n = 1'b0; // Assert CS
        wr_n = 1'b1; // Keep WR high
        A = 2'b00;
        db = dbA;
        state_next = WRITE_A;
      end
      WRITE_A: begin
        cs_n = 1'b0;
        wr_n = 1'b0; // Assert WR
        A = 2'b00;   // Keep address/data stable
        db = dbA;
        state_next = HOLD_A;
      end
      HOLD_A: begin
        cs_n = 1'b0;
        wr_n = 1'b1; // Deassert WR
        A = 2'b00;
        db = dbA;
        state_next = SETUP_B;
      end

      SETUP_B: begin
        cs_n = 1'b0;
        wr_n = 1'b1;
        A = 2'b01;
        db = dbB;
        state_next = WRITE_B;
      end
      WRITE_B: begin
        cs_n = 1'b0;
        wr_n = 1'b0;
        A = 2'b01;
        db = dbB;
        state_next = HOLD_B;
      end
      HOLD_B: begin
        cs_n = 1'b0;
        wr_n = 1'b1;
        A = 2'b01;
        db = dbB;
        state_next = SETUP_C;
      end

      SETUP_C: begin
        cs_n = 1'b0;
        wr_n = 1'b1;
        A = 2'b10;
        db = dbC;
        state_next = WRITE_C;
      end
      WRITE_C: begin
        cs_n = 1'b0;
        wr_n = 1'b0;
        A = 2'b10;
        db = dbC;
        state_next = HOLD_C;
      end
      HOLD_C: begin
        cs_n = 1'b0;
        wr_n = 1'b1;
        A = 2'b10;
        db = dbC;
        state_next = SETUP_D;
      end

      SETUP_D: begin
        cs_n = 1'b0;
        wr_n = 1'b1;
        A = 2'b11;
        db = dbD;
        state_next = WRITE_D;
      end
      WRITE_D: begin
        cs_n = 1'b0;
        wr_n = 1'b0;
        A = 2'b11;
        db = dbD;
        state_next = HOLD_D;
      end
      HOLD_D: begin
        cs_n = 1'b1; // Deassert CS after last write
        wr_n = 1'b1;
        A = 2'b11;
        db = dbD;
        state_next = LDAC_LOW;
      end

      LDAC_LOW: begin
        cs_n = 1'b1;
        wr_n = 1'b1;
        ldac_n = 1'b0; // Assert LDAC
        state_next = LDAC_HIGH;
      end
      LDAC_HIGH: begin
        cs_n = 1'b1;
        wr_n = 1'b1;
        ldac_n = 1'b1; // Deassert LDAC
        state_next = IDLE; // End of sequence
      end

      default: begin
        state_next = IDLE;
        cs_n = 1'b1;
        wr_n = 1'b1;
        ldac_n = 1'b1;
      end
    endcase
  end

  // Assign registered outputs driven by FSM logic
  // This avoids potential glitches compared to assigning directly in combinational block
  // Note: A and db are assigned combinationally based on state for simplicity here,
  // assuming they need to be valid during setup/write phases.
  // If they needed to be registered outputs, additional logic would be needed.


endmodule