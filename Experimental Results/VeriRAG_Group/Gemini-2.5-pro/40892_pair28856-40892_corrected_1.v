`timescale 1ns / 1ps
module i2c_module(
	input clk,
	input reset_n,
	// Removed test_mode, using enable-based clocking for DFT
	output reg sda_oe = 1,
	input wire sda_in,
	output reg sda = 1,
	output reg scl_out = 1, // Initialize to 1
	input[7:0] writedata,
	input write,
	input[2:0] address,
	output reg ready = 1,
	output reg success_out = 0
);

// State definitions
localparam STATE_IDLE = 0;
localparam STATE_ADDRESS_START = 1;
localparam STATE_ADDRESS_START_2 = 111;
localparam STATE_ADDRESS_START_3 = 112;
localparam STATE_ADDRESS_BIT_1 = 2;
localparam STATE_ADDRESS_BIT_2 = 3;
localparam STATE_ADDRESS_BIT_3 = 4;
localparam STATE_ADDRESS_BIT_4 = 5;
localparam STATE_ADDRESS_BIT_5 = 6;
localparam STATE_ADDRESS_BIT_6 = 7;
localparam STATE_ADDRESS_BIT_7 = 8;
localparam STATE_ADDRESS_BIT_8 = 9;
localparam STATE_ADDRESS_ACK = 10;
localparam STATE_TRANSIT_1 =	102;
localparam STATE_REG_BIT_1 = 11;
localparam STATE_REG_BIT_2 = 12;
localparam STATE_REG_BIT_3 = 13;
localparam STATE_REG_BIT_4 = 14;
localparam STATE_REG_BIT_5 = 15;
localparam STATE_REG_BIT_6 = 16;
localparam STATE_REG_BIT_7 = 17;
localparam STATE_REG_BIT_8 = 18;
localparam STATE_REG_ACK = 19;
localparam STATE_TRANSIT_2 =	192;
localparam STATE_DATA_BIT_1 = 20;
localparam STATE_DATA_BIT_2 = 21;
localparam STATE_DATA_BIT_3 = 22;
localparam STATE_DATA_BIT_4 = 23;
localparam STATE_DATA_BIT_5 = 24;
localparam STATE_DATA_BIT_6 = 25;
localparam STATE_DATA_BIT_7 = 26;
localparam STATE_DATA_BIT_8 = 27;
localparam STATE_DATA_ACK = 28;
localparam STATE_STOP = 29;
localparam STATE_STOP_1 = 30;
localparam STATE_STOP_2 = 31; // Note: Seems unused in original logic

// Internal registers
reg [7:0] state_next = STATE_IDLE;
reg [7:0] control_reg = 0;
reg [7:0] slave_address = 0;
reg [7:0] slave_reg_address = 0;
reg [7:0] slave_data_1 = 0;
reg [7:0] slave_data_2 = 0;
reg scl_output_enable = 0;
reg scl_output_zero = 0;
reg success = 0;
reg ack_ok = 0;

// Clock Division Logic using Enables (DFT Friendly)
parameter CLK_DIV_RATIO = 128; // Determines I2C speed relative to clk. Adjust as needed.
parameter CLK_COUNTER_WIDTH = $clog2(CLK_DIV_RATIO * 2);
reg [CLK_COUNTER_WIDTH-1:0] clk_counter = 0;
wire i2c_posedge_event;
wire i2c_negedge_event;
wire i2c_clk_phase; // Replaces original clk_div

always @(posedge clk or negedge reset_n) begin
	if (!reset_n) begin
		clk_counter <= 0;
	end else begin
		if (clk_counter == (CLK_DIV_RATIO * 2 - 1)) begin
			clk_counter <= 0;
		end else begin
			clk_counter <= clk_counter + 1;
		end
	end
end

// Generate enables based on counter values
assign i2c_posedge_event = (clk_counter == CLK_DIV_RATIO - 1);     // Corresponds to original posedge clk_div_2
assign i2c_negedge_event = (clk_counter == CLK_DIV_RATIO * 2 - 1); // Corresponds to original negedge clk_div_2
assign i2c_clk_phase     = (clk_counter >= CLK_DIV_RATIO);         // Corresponds to original clk_div (high phase)

// Control/Data Register Updates (Clocked by primary clk)
always@(posedge clk or negedge reset_n)
begin
	if(reset_n == 0)
	begin
		control_reg <= 0;
		slave_address <= 0;
		slave_reg_address <= 0;
		slave_data_1 <= 0;
		slave_data_2 <= 0;
	end
	else
	begin
		// Write logic
		if(write == 1'b1)
		begin
			case(address)
				3'b000: control_reg <= writedata;
				3'b001:	slave_address <= writedata;
				3'b010:	slave_reg_address <= writedata;
				3'b011:	slave_data_1 <= writedata;
				3'b100:	slave_data_2 <= writedata;
				default: ; // Avoid latches
			endcase
		end

		// Clear control bit 0 after starting transaction
        // This uses the state from the previous cycle, check if this matches intent
		if(state_next != STATE_IDLE)
			control_reg[0] <= 0; // Clear start bit
	end
end

// SCL Output Logic (Clocked by primary clk, enabled by i2c_posedge_event)
always@(posedge clk or negedge reset_n)
begin
    if (!reset_n) begin
        scl_out <= 1'b1; // SCL high when idle/reset
    end else begin
        if (i2c_posedge_event) begin // Update on the cycle corresponding to original posedge clk_div_2
            if(scl_output_enable == 1)
            begin
                scl_out <= ~scl_out; // Toggle when enabled
            end
            else
            begin
                if(scl_output_zero == 0)
                    scl_out <= 1'b1; // Drive high
                else
                    scl_out <= 1'b0; // Drive low
            end
        end
    end
end

// ACK Check Logic (Clocked by primary clk, enabled by i2c_posedge_event)
always@(posedge clk or negedge reset_n)
begin
    if (!reset_n) begin
        ack_ok <= 1'b0;
    end else begin
        if (i2c_posedge_event) begin // Sample at the cycle corresponding to original posedge clk_div_2
            // Check ACK during the high phase of the derived clock
            if( (state_next == STATE_ADDRESS_ACK || state_next == STATE_REG_ACK || state_next == STATE_DATA_ACK) && sda_in == 1'b0 && i2c_clk_phase == 1)
            begin
                ack_ok <= 1'b1;
            end
            else begin
                ack_ok <= 1'b0;
            end
        end else begin
             // ack_ok should retain value between posedge events if not reset
             // However, safer to explicitly reset it if not asserted
             if (ack_ok && !( (state_next == STATE_ADDRESS_ACK || state_next == STATE_REG_ACK || state_next == STATE_DATA_ACK) && sda_in == 1'b0 && i2c_clk_phase == 1)) begin
                // Deassert if condition is no longer met, but only check on the event edge?
                // Let's deassert unless condition met on event edge.
                ack_ok <= 1'b0;
             end
        end
    end
end


// Success Output Logic (Clocked by primary clk, enabled by i2c_negedge_event)
always@(posedge clk or negedge reset_n)
begin
    if (!reset_n) begin
        success_out <= 1'b0;
    end else begin
        if (i2c_negedge_event) begin // Update on the cycle corresponding to original negedge clk_div_2
            // Check during the high phase of the derived clock
            if(i2c_clk_phase == 1)
            begin
                if(state_next == STATE_STOP && success == 1'b1)
                    success_out <= 1'b1;
                else if(state_next == STATE_ADDRESS_START) // Reset success_out at start
                    success_out <= 1'b0;
                // else: retain value - handled by flop nature
            end else if (state_next == STATE_ADDRESS_START) begin // Reset condition check outside phase
                 success_out <= 1'b0;
            end
        end
        // else: retain value - handled by flop nature
    end
end


// Main State Machine and Output Logic (Clocked by primary clk, enabled by i2c_negedge_event)
always@(posedge clk or negedge reset_n)
begin
	if(reset_n == 0)
	begin
		 state_next <= STATE_IDLE;
		 // Reset output logic regs
		 sda <= 1'b1;
		 sda_oe <= 1'b1;
		 scl_output_enable <= 1'b0;
		 scl_output_zero <= 1'b0; // Ensure scl_out goes high indirectly via scl_out logic reset
		 ready <= 1;
		 success <= 0;
	end
	else
	begin
        if (i2c_negedge_event) begin // Only update state and outputs on the correct clock event
            // State transition logic (functionally unchanged, but conditioned by enable)
            case(state_next)
                STATE_IDLE:
                begin
                    if(control_reg[0] == 1'b1 )
                    begin
                        state_next <= STATE_ADDRESS_START;
                    end
                end
                STATE_ADDRESS_START:
                begin
                    if(i2c_clk_phase == 0) // Check phase instead of clk_div
                    begin
                        state_next <= STATE_ADDRESS_START_2;
                    end
                end
                STATE_ADDRESS_START_2:
                begin
                    if(i2c_clk_phase == 1) // Check phase instead of clk_div
                    begin
                        state_next <= STATE_ADDRESS_START_3;
                    end
                end
                STATE_ADDRESS_START_3:
                begin
                    if(i2c_clk_phase == 0) // Check phase instead of clk_div
                    begin
                        state_next <= STATE_ADDRESS_BIT_1;
                    end
                end
                STATE_ADDRESS_BIT_1:
                begin
                    if(i2c_clk_phase == 0) // Check phase instead of clk_div
                    begin
                        state_next <= STATE_ADDRESS_BIT_2;
                    end
                end
                STATE_ADDRESS_BIT_2:
                begin
                    if(i2c_clk_phase == 0) // Check phase instead of clk_div
                    begin
                        state_next <= STATE_ADDRESS_BIT_3;
                    end
                end
                STATE_ADDRESS_BIT_3:
                begin
                    if(i2c_clk_phase == 0) // Check phase instead of clk_div
                    begin
                        state_next <= STATE_ADDRESS_BIT_4;
                    end
                end
                STATE_ADDRESS_BIT_4:
                begin
                    if(i2c_clk_phase == 0) // Check phase instead of clk_div
                    begin
                        state_next <= STATE_ADDRESS_BIT_5;
                    end
                end
                STATE_ADDRESS_BIT_5:
                begin
                    if(i2c_clk_phase == 0) // Check phase instead of clk_div
                    begin
                        state_next <= STATE_ADDRESS_BIT_6;
                    end
                end
                STATE_ADDRESS_BIT_6:
                begin
                    if(i2c_clk_phase == 0) // Check phase instead of clk_div
                    begin
                        state_next <= STATE_ADDRESS_BIT_7;
                    end
                end
                STATE_ADDRESS_BIT_7:
                begin
                    if(i2c_clk_phase == 0) // Check phase instead of clk_div
                    begin
                        state_next <= STATE_ADDRESS_BIT_8;
                    end
                end
                STATE_ADDRESS_BIT_8:
                begin
                    if(i2c_clk_phase == 0) // Check phase instead of clk_div
                    begin
                        state_next <= STATE_ADDRESS_ACK;
                    end
                end
                STATE_ADDRESS_ACK:
                begin
                if(i2c_clk_phase == 0) // Check phase instead of clk_div
                    begin
                    if(ack_ok == 1'b1)
                        begin
                            state_next <= STATE_TRANSIT_1;
                        end
                        else
                        begin
                            state_next <= STATE_STOP;
                        end
                    end
                end
                STATE_TRANSIT_1:
                begin
                    if(i2c_clk_phase == 0) // Check phase instead of clk_div
                    begin
                        state_next <= STATE_REG_BIT_1;
                    end
                end
                STATE_REG_BIT_1:
                begin
                    if(i2c_clk_phase == 0) // Check phase instead of clk_div
                    begin
                        state_next <= STATE_REG_BIT_2;
                    end
                end
                STATE_REG_BIT_2:
                begin
                    if(i2c_clk_phase == 0) // Check phase instead of clk_div
                    begin
                        state_next <= STATE_REG_BIT_3;
                    end
                end
                STATE_REG_BIT_3:
                begin
                    if(i2c_clk_phase == 0) // Check phase instead of clk_div
                    begin
                        state_next <= STATE_REG_BIT_4;
                    end
                end
                STATE_REG_BIT_4:
                begin
                    if(i2c_clk_phase == 0) // Check phase instead of clk_div
                    begin
                        state_next <= STATE_REG_BIT_5;
                    end
                end
                STATE_REG_BIT_5:
                begin
                    if(i2c_clk_phase == 0) // Check phase instead of clk_div
                    begin
                        state_next <= STATE_REG_BIT_6;
                    end
                end
                STATE_REG_BIT_6:
                begin
                    if(i2c_clk_phase == 0) // Check phase instead of clk_div
                    begin
                        state_next <= STATE_REG_BIT_7;
                    end
                end
                STATE_REG_BIT_7:
                begin
                    if(i2c_clk_phase == 0) // Check phase instead of clk_div
                    begin
                        state_next <= STATE_REG_BIT_8;
                    end
                end
                STATE_REG_BIT_8:
                begin
                    if(i2c_clk_phase == 0) // Check phase instead of clk_div
                    begin
                        state_next <= STATE_REG_ACK;
                    end
                end
                STATE_REG_ACK:
                begin
                    if(i2c_clk_phase == 0) // Check phase instead of clk_div
                    begin
                        if(ack_ok == 1'b1)
                        begin
                            state_next <= STATE_TRANSIT_2;
                        end
                        else
                        begin
                            state_next <= STATE_STOP;
                        end
                    end
                end
                STATE_TRANSIT_2:
                begin
                    if(i2c_clk_phase == 0) // Check phase instead of clk_div
                    begin
                        state_next <= STATE_DATA_BIT_1;
                    end
                end
                STATE_DATA_BIT_1:
                begin
                    if(i2c_clk_phase == 0) // Check phase instead of clk_div
                    begin
                        state_next <= STATE_DATA_BIT_2;
                    end
                end
                STATE_DATA_BIT_2:
                begin
                    if(i2c_clk_phase == 0) // Check phase instead of clk_div
                    begin
                        state_next <= STATE_DATA_BIT_3;
                    end
                end
                STATE_DATA_BIT_3:
                begin
                    if(i2c_clk_phase == 0) // Check phase instead of clk_div
                    begin
                        state_next <= STATE_DATA_BIT_4;
                    end
                end
                STATE_DATA_BIT_4:
                begin
                    if(i2c_clk_phase == 0) // Check phase instead of clk_div
                    begin
                        state_next <= STATE_DATA_BIT_5;
                    end
                end
                STATE_DATA_BIT_5:
                begin
                    if(i2c_clk_phase == 0) // Check phase instead of clk_div
                    begin
                        state_next <= STATE_DATA_BIT_6;
                    end
                end
                STATE_DATA_BIT_6:
                begin
                    if(i2c_clk_phase == 0) // Check phase instead of clk_div
                    begin
                        state_next <= STATE_DATA_BIT_7;
                    end
                end
                STATE_DATA_BIT_7:
                begin
                    if(i2c_clk_phase == 0) // Check phase instead of clk_div
                    begin
                        state_next <= STATE_DATA_BIT_8;
                    end
                end
                STATE_DATA_BIT_8:
                begin
                    if(i2c_clk_phase == 0) // Check phase instead of clk_div
                    begin
                        state_next <= STATE_DATA_ACK;
                    end
                end
                STATE_DATA_ACK:
                begin
                    if(i2c_clk_phase == 0) // Check phase instead of clk_div
                    begin
                        state_next <= STATE_STOP;
                    end
                end
                STATE_STOP:
                begin
                    if(i2c_clk_phase == 1) // Check phase instead of clk_div
                    begin
                        state_next <= STATE_STOP_1;
                    end
                end
                STATE_STOP_1:
                begin
                    if(i2c_clk_phase == 0) // Check phase instead of clk_div
                    begin
                        state_next <= STATE_IDLE;
                    end
                end
                STATE_STOP_2: // This state seems unreachable, keeping original logic
                begin
                    if(i2c_clk_phase == 1) // Check phase instead of clk_div
                    begin
                        state_next <= STATE_IDLE;
                    end
                end
                default: state_next <= STATE_IDLE; // Ensure default goes to IDLE
            endcase

            // Output logic based on state (functionally unchanged, but conditioned by enable)
            case(state_next) // Using state_next for output logic as in original
                STATE_IDLE:
                begin
                    sda <= 1'b1;
                    sda_oe <= 1'b1;
                    scl_output_enable <= 1'b0;
                    ready <= 1;
                    success <= 0;
                    scl_output_zero <= 0;
                end
                STATE_ADDRESS_START:
                begin
                    if(i2c_clk_phase == 0) // Check phase instead of clk_div
                    begin
                        scl_output_zero <= 0;
                        scl_output_enable <= 0;
                        sda_oe <= 1;
                        sda <= 0;
                        ready <= 0;
                        success <= 0