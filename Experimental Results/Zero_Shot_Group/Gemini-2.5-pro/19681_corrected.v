module qdec(
    input       rst_n,
    input       freq_clk, // Typically 50MHz or similar system clock
    input       enable,
    output      pha,
    output      phb,
    output      index,
    output reg  led      // Changed to output reg
);

// Internal registers for outputs driven by always blocks
reg pha_reg;
reg phb_reg;
reg index_reg;

// Counter for index pulse generation
reg [7:0] pha_count;

// Clock divider to generate a slower clock (e.g., 200Hz square wave from 50MHz)
// 50,000,000 Hz / (2 * 125,000) = 200 Hz
reg [31:0] count_reg;
reg out_200hz; // This signal toggles at 400Hz, giving a 200Hz clock

// Generate 200 Hz clock (out_200hz toggles at 400Hz)
always @(posedge freq_clk or negedge rst_n) begin
    if (!rst_n) begin
        count_reg <= 32'd0;
        out_200hz <= 1'b0;
        // Removed redundant assignments
    end else if (enable) begin
        if (count_reg < 32'd124999) begin // Count up to 125,000 cycles (0 to 124999)
            count_reg <= count_reg + 1;
        end else begin
            count_reg <= 32'd0;
            out_200hz <= ~out_200hz; // Toggle output
        end
    end else begin
        // Hold state if not enabled (optional, prevents toggling)
        count_reg <= count_reg;
        out_200hz <= out_200hz;
    end
end

/*
  Target waveform generation based on out_200hz posedge:
        _   _       (State: 10 -> 11 -> 01 -> 00)
  pha  | |_| |_
         _   _
  phb  _| |_| |_

  index pulse generation based on pha_count
*/

// Process the pha_count (used for index generation)
always @ (posedge out_200hz or negedge rst_n) begin
    if (!rst_n) begin
        pha_count <= 8'd0;
        led <= 1'b0; // Reset LED state
    end else begin // Removed 'if (out_200hz)' check, logic runs on posedge
       led <= ~led; // Toggle LED on every 200Hz clock edge for visual feedback
        // Count from 0 to 24 (25 steps), then wrap around
        if (pha_count == 8'd24) begin // Check for max value before incrementing
            pha_count <= 8'd0;
        end else begin
            pha_count <= pha_count + 1;
        end
    end
end

// State counter for quadrature phase generation
reg [1:0] Phase90_Count;

// Process the pha and phb signals (Quadrature Generation)
always @ (posedge out_200hz or negedge rst_n) begin
    if (!rst_n) begin
        Phase90_Count <= 2'b0;
        pha_reg <= 1'b1; // Initialize to state 0 (10)
        phb_reg <= 1'b0;
    end else begin // Removed 'if (out_200hz)' check
        case (Phase90_Count)
            2'd0: // Current state: 10
            begin
                pha_reg <= 1'b1; // Next state: 11
                phb_reg <= 1'b1;
                Phase90_Count <= Phase90_Count + 1;
            end
            2'd1: // Current state: 11
            begin
                pha_reg <= 1'b0; // Next state: 01
                phb_reg <= 1'b1;
                Phase90_Count <= Phase90_Count + 1;
            end
            2'd2: // Current state: 01
            begin
                pha_reg <= 1'b0; // Next state: 00
                phb_reg <= 1'b0;
                Phase90_Count <= Phase90_Count + 1;
            end
            2'd3: // Current state: 00
            begin
                pha_reg <= 1'b1; // Next state: 10 (loop back)
                phb_reg <= 1'b0;
                Phase90_Count <= 2'b0; // Reset counter
            end
            default: // Should not be reached
            begin
                Phase90_Count <= 2'b0;
                pha_reg <= 1'b1;
                phb_reg <= 1'b0;
            end
        endcase
    end
end

// Assign internal registers to outputs
assign pha = pha_reg;
assign phb = phb_reg;

// Process the index signal (pulse generation)
always @ (posedge out_200hz or negedge rst_n) begin
    if (!rst_n) begin
        index_reg <= 1'b0;
    end else begin // Removed 'if (out_200hz)' check
        // Generate index pulse when pha_count is 23 or 24
        if (pha_count == 8'd23 || pha_count == 8'd24) begin
            index_reg <= 1'b1;
        end else begin
            index_reg <= 1'b0;
        end
        // Alternative using case:
        // case (pha_count)
        //     8'd23:   index_reg <= 1'b1;
        //     8'd24:   index_reg <= 1'b1;
        //     default: index_reg <= 1'b0;
        // endcase
    end
end

// Assign internal register to output
assign index = index_reg;

endmodule