`timescale 1ns/1ps
// 1_corrected_cdf.v
/***************************************************************************
Name:
Date: 7/18/2016
Founction: I2C Write and read
Note: Corrected for CDFDAT violation by isolating scl dependency in test_mode.
****************************************************************************/
module I2C_wr(
sda,scl,ack,rst_n,clk,WR,RD,data,maddress_sel,
test_mode // Added DFT control signal
);

input  rst_n,WR,RD,clk;
input  maddress_sel;
input  test_mode; // Added DFT control signal
output scl,ack;
inout [7:0] data;
inout  sda;

reg link_sda,link_data;
reg[7:0] data_buf;
reg scl_internal; // Internal register for SCL generation
reg scl; // Output register for SCL
reg ack,WF,RF,FF;
reg wr_state;
reg head_state;
reg[8:0] sh8out_state;
reg[9:0] sh8in_state;
reg stop_state;
reg[6:0] main_state;
reg[7:0] data_from_rm;
reg[7:0] cnt_read;
reg[7:0] cnt_write;

/******************************************************************************
*use switch to control serial datas
*******************************************************************************/
assign sda  = (link_sda)   ? data_buf[7] : 1'bz;
assign data = (link_data)  ? data_from_rm : 8'hz;

/******************************************************************************
*number of read and write
*******************************************************************************/
parameter page_write_num = 10'd32,
			 page_read_num  = 10'd32;

/******************************************************************************
*main state machine state
*******************************************************************************/
parameter
				idle         = 10'b000_0001,
				ready        = 10'b000_0010,
				write_start  = 11'b000_0100,
				addr_write   = 11'b000_1000,
				data_read    = 11'b001_0000,
				stop         = 11'b010_0000,
				ackn         = 11'b100_0000;


/******************************************************************************
*parallel data change to serial data state machine state
*******************************************************************************/
parameter
				bit7     = 9'b0_0000_0001,
				bit6     = 9'b0_0000_0010,
				bit5     = 9'b0_0000_0100,
				bit4     = 9'b0_0000_1000,
				bit3     = 9'b0_0001_0000,
				bit2     = 9'b0_0010_0000,
				bit1     = 9'b0_0100_0000,
				bit0     = 9'b0_1000_0000,
				bitend   = 9'b1_0000_0000;

/******************************************************************************
*serial data change to parallel data state machine state
*******************************************************************************/
parameter
				read_begin  = 10'b00_0000_0001,
				read_bit7   = 10'b00_0000_0010,
				read_bit6   = 10'b00_0000_0100,
				read_bit5   = 10'b00_0000_1000,
				read_bit4   = 10'b00_0001_0000,
				read_bit3   = 10'b00_0010_0000,
				read_bit2   = 10'b00_0100_0000,
				read_bit1   = 10'b00_1000_0000,
				read_bit0   = 10'b01_0000_0000,
				read_end    = 10'b10_0000_0000;

/******************************************************************************
*generate scl - Modified for DFT
* Generate internal scl toggle
*******************************************************************************/
always @(negedge clk or negedge rst_n) begin
	if(!rst_n)
		scl_internal <= 1'b0;
	else
		scl_internal <= ~scl_internal;
end

// Drive output scl based on test_mode
// In test mode, hold scl low to prevent issues with logic sensitive to scl edges/levels
// This assignment must be combinational or clocked appropriately.
// Since scl is used in posedge clk logic, driving it based on scl_internal (negedge) is inherently risky.
// A better fix modifies the *usage* of scl, which is done below.
// However, we still need to drive the output 'scl'. Let's make it reflect internal value in func mode, hold in test.
always @(posedge clk or negedge rst_n) begin // Use posedge clk for output flop consistency if needed elsewhere, or make combinational
    if (!rst_n) begin
        scl <= 1'b0;
    end else begin
        if (test_mode) begin
            scl <= 1'b0; // Hold low during test mode
        end else begin
            scl <= scl_internal; // Follow internal toggle in functional mode
        end
    end
end


/******************************************************************************
*main state machine
*******************************************************************************/
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		link_sda    <= 1'b0;
		ack         <= 1'b0;
		RF          <= 1'b0;
		WF          <= 1'b0;
		FF          <= 1'b0;
		main_state  <= idle;
		head_state  <= 'h0;
		sh8out_state<= bit7;
		sh8in_state <= read_begin;
		stop_state  <= 'h0;
		cnt_read    <= 'h1;
		cnt_write   <= 'h1;
        wr_state    <= 1'b0;
        link_data   <= 1'b0;
        data_buf    <= 8'b0;
        data_from_rm <= 8'b0;
	end
	else begin
		// Default assignments to prevent latches for signals not assigned in all branches
        // Or ensure assignments cover all conditions within the case statement.
        // Example:
        // link_sda <= link_sda;
        // ack <= ack;
        // ... other registers ...

		case(main_state)
			idle:begin
				link_data  <= 1'b0;
				link_sda   <= 1'b0;
				if(WR) begin
					WF <= 1'b1;
                    RF <= 1'b0; // Ensure RF is deasserted
					main_state <= ready;
				end
				else if(RD)begin
					RF <= 1'b1;
                    WF <= 1'b0; // Ensure WF is deasserted
					main_state <= ready;
				end
				else begin
					WF <= 1'b0;
					RF <= 1'b0;
					main_state <= idle;
				end
			end
			ready:begin
				FF         <= 1'b0;
				main_state <= write_start;
			end
			write_start:begin
				if(FF==1'b0)
					shift_head; // Task call
				else begin // FF is 1 (means shift_head finished)
				   if(WF == 1'b1)
					data_buf        <= maddress_sel ? {1'b0,1'b1,1'b0,1'b0,1'b1,1'b1,1'b1,1'b0}:{1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b0,1'b0};
					else // RF == 1'b1 assumed if not WF
					data_buf        <= maddress_sel ? {1'b0,1'b1,1'b0,1'b0,1'b1,1'b1,1'b1,1'b1}:{1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b0,1'b1};
					FF              <= 1'b0; // Reset flag
					sh8out_state    <= bit6; // Start shifting from bit 6 (bit 7 was address R/W bit)
					main_state      <= addr_write;
				end
			end
			addr_write:begin
				if(FF==1'b0)
					shift8_out; // Task call
				else begin // FF is 1 (means shift8_out finished)
					if(