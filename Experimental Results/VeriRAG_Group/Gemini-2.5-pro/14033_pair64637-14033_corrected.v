`timescale 1ns/1ps
`timescale 1ns/1ps
module I2C_wr_subad(
sda,scl,ack,rst_n,clk,WR,RD,data,
scan_clk, test_mode // Added DFT ports
);
input  rst_n,WR,RD,clk;
input  scan_clk, test_mode; // Added DFT ports
output scl,ack;
inout [7:0] data; 
inout  sda;
reg link_sda,link_data;
reg[7:0] data_buf;
reg scl,ack,WF,RF,FF;
reg wr_state;
reg head_state;
reg[8:0] sh8out_state;
reg[9:0] sh8in_state;
reg stop_state;
reg[6:0] main_state;
reg[7:0] data_from_rm;
reg[7:0] cnt_read;
reg[7:0] cnt_write;

wire dft_clk; // Added DFT clock mux
assign dft_clk = test_mode ? scan_clk : clk; // MUX for clock based on test_mode

assign sda  = (link_sda)   ? data_buf[7] : 1'bz;
assign data = (link_data)  ? data_from_rm : 8'hz;
parameter page_write_num = 10'd34,
			 page_read_num  = 10'd32;
parameter
				idle         = 10'b000_0001,
				ready        = 10'b000_0010,
				write_start  = 11'b000_0100,
				addr_write   = 11'b000_1000,
				data_read    = 11'b001_0000,
				stop         = 11'b010_0000,
				ackn         = 11'b100_0000;
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

// Use multiplexed clock dft_clk instead of clk
always @(negedge dft_clk or negedge rst_n) begin
	if(!rst_n)
		scl <= 1'b0;
	else
		scl <= ~scl;
end

// Use multiplexed clock dft_clk instead of clk
always @(posedge dft_clk or negedge rst_n) begin
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
		wr_state    <= 1'b0; // Initialize wr_state
		link_data   <= 1'b0; // Initialize link_data
		data_buf    <= 8'h0; // Initialize data_buf
		data_from_rm<= 8'h0; // Initialize data_from_rm
	end
	else begin
		case(main_state)
			idle:begin
				link_data  <= 'h0;
				link_sda   <= 'h0;
				if(WR) begin
					WF <= 1'b1;
					main_state <= ready;
				end
				else if(RD)begin
					RF <= 1'b1;
					main_state <= ready;
				end
				else begin
					WF <= 1'b0;
					RF <= 1'b0;
					main_state <=idle;
				end
			end
			ready:begin
				FF         <= 1'b0;
				main_state <= write_start;
			end
			write_start:begin
				if(FF==1'b0)
					shift_head;
				else begin
				   if(WF == 1'b1)
					data_buf        <= {1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b0,1'b0};
					else
					data_buf        <= {1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b0,1'b1};
					FF              <= 1'b0;
					sh8out_state    <= bit6; // Start from bit6 after address LSB (W/R bit)
					main_state      <= addr_write;
				end
			end
			addr_write:begin
				if(FF==1'b0)
					shift8_out;
				else begin
					if(RF==1'b1)begin
						data_buf   <= 'h0; // Prepare for read ack
						link_sda  <= 1'b0; // Release SDA for slave ack
						FF          <= 1'b0;
						cnt_read <= 1'b1;
						main_state  <= data_read;
						sh8in_state <= read_begin; // Reset read state machine
					end
					else if(WF==1'b1)begin
						FF             <= 1'b0;
						main_state     <= data_read;
						data_buf       <= data; // Load first data byte to write
						cnt_write      <= 1'b1;
						sh8out_state   <= bit7; // Reset write state machine for data
						link_sda       <= 1'b1; // Drive SDA for data write
						wr_state       <= 1'b0; // Reset write sub-state
					end
				end
			end
			data_read:begin
				if(RF==1'b1)begin
					if(cnt_read <= page_read_num)
						shift8_in;
					else begin
						main_state <= stop;
						FF         <= 1'b0;
						stop_state <= 1'b0; // Reset stop state machine
					end
				end
				else if(WF==1'b1)begin
					if(cnt_write <= page_write_num)
						case(wr_state)
							1'b0:begin // Wait for ACK check / Load next data
								if(!scl)begin // Check ACK on falling edge
								    // Assuming slave pulls SDA low for ACK
									if (sda == 1'b0) begin // Check if ACK received
										// Load next data if not the last byte
										if (cnt_write < page_write_num) begin
										    data_buf  <= data; // Load next data byte
										    link_sda  <= 1'b1; // Start driving next byte
										    sh8out_state<= bit7; // Start shifting from MSB
										    wr_state    <= 1'b1; // Go to shift state
										    ack         <= 1'b0; // Deassert master ack signal
										end else begin // Last byte ACKed
										    main_state <= stop;
										    wr_state   <= 1'b0;
										    FF         <= 1'b0;
										    stop_state <= 1'b0;
										end
									end else begin // NACK received or error
									    // Handle NACK - typically stop
									    main_state <= stop;
										wr_state   <= 1'b0;
										FF         <= 1'b0;
										stop_state <= 1'b0;
									end
								end // else wait for falling edge of scl
							end
							1'b1:shift8_out; // Shifting out data byte
							endcase
					else begin // Finished writing page_write_num bytes
						main_state  <= stop;
						wr_state    <= 1'b0;
						FF          <= 1'b0;
						stop_state  <= 1'b0; // Reset stop state machine
					end
				end
			end
			stop:begin
				if(FF == 1'b0)
					task_stop;
				else begin
					ack <= 1'b1; // Signal completion
					FF  <= 1'b0;
					main_state <= ackn;
				end
			end
			ackn:begin
				ack <= 1'b0;
				WF  <= 1'b0;
				RF  <= 1'b0;
				main_state <= idle;
			end
			default:main_state <= idle;
		endcase
	end
end
task shift_head;
begin
	case(head_state)
		1'b0:begin // SDA high, SCL high -> Start condition setup
			if(!scl)begin // Wait for SCL low
				link_sda      <= 1'b1; // Keep SDA high
				data_buf[7]   <= 1'b1; // Ensure data_buf reflects SDA state
				head_state    <= 1'b1;
			end
			// else wait for SCL low
		end
		1'b1:begin // SCL low -> Bring SDA low for start condition
			if(scl)begin // Wait for SCL high
				// Should not happen here, SCL should be low from previous state
				// If it happens, might be a glitch, stay in state or reset
				head_state <= 1'b1; // Stay? Or error?
			end
			else begin // SCL is low, bring SDA low
				data_buf[7]   <= 1'b0; // SDA goes low while SCL is low
				link_sda      <= 1'b1; // Drive SDA low
				FF            <= 1'b1; // Signal task completion
				head_state    <= 1'b0; // Reset task state
			end
		end
	endcase	
end
endtask
task shift8_out;
begin
	case(sh8out_state)
		bit7:begin // Shift bit 7
			if(!scl) begin // On SCL falling edge
				link_sda     <= 1'b1; // Ensure SDA is driven
				// data_buf[7] is already set
				sh8out_state <= bit6;
			end
			// else wait for falling edge
		end
		bit6:begin // Shift bit 6
			if(!scl) begin
				data_buf   <= data_buf<<1'b1; // Shift next bit into MSB position
				sh8out_state <= bit5;
			end
			// else wait for falling edge
		end
		bit5:begin // Shift bit 5
			if(!scl) begin
				data_buf   <= data_buf<<1'b1;
				sh8out_state <= bit4;
			end
			// else wait for falling edge
		end
		bit4:begin // Shift bit 4
			if(!scl) begin
				data_buf   <= data_buf<<1'b1;
				sh8out_state <= bit3;
			end
			// else wait for falling edge
		end
		bit3:begin // Shift bit 3
			if(!scl) begin
				data_buf   <= data_buf<<1'b1;
				sh8out_state <= bit2;
			end
			// else wait for falling edge
		end
		bit2:begin // Shift bit 2
			if(!scl) begin
				data_buf   <= data_buf<<1'b1;
				sh8out_state <= bit1;
			end
			// else wait for falling edge
		end
		bit1:begin // Shift bit 1
			if(!scl) begin
				data_buf   <= data_buf<<1'b1;
				sh8out_state <= bit0;
			end
			// else wait for falling edge
		end
		bit0:begin // Shift bit 0
			if(!scl) begin
				data_buf   <= data_buf<<1'b1;
				sh8out_state <= bitend; // Move to check ACK state
			end
			// else wait for falling edge
		end
		bitend:begin // Check ACK state
			if(!scl) begin // On SCL falling edge
				link_sda       <= 1'b0; // Release SDA to check for ACK
				if (main_state == addr_write) begin // After address phase
					FF           <= 1'b1; // Signal completion of address/data byte
					sh8out_state <= bit7; // Reset for next byte (handled in main FSM)
				end else if (main_state == data_read && WF == 1'b1) begin // After data write phase
					// Stay in this state, main FSM will check ACK in wr_state 1'b0
					// Increment count and signal completion in main FSM based on ACK
					cnt_write      <= cnt_write + 1'b1;
					wr_state       <= 1'b0; // Go back to ACK check state
				    FF             <= 1'b1; // Signal byte transmission complete
				    sh8out_state   <= bit7; // Reset state machine for next potential byte
				end
			end
			// else wait for falling edge
		end
	endcase
end
endtask
task shift8_in;
begin
	case(sh8in_state)
		read_begin:begin // Setup for read
			if (!scl) begin // Wait for SCL low
			    link_sda    <= 1'b0; // Release SDA
				link_data   <= 1'b0; // Don't drive parallel data bus yet
				ack         <= 1'b0; // Ensure master ack is low
				sh8in_state <= read_bit7;
			end
		end
		read_bit7:begin // Read bit 7
			if(scl)begin // Sample on SCL rising edge
				data_from_rm[7] <= sda;
				sh8in_state     <= read_bit6;
			end
			// else wait for rising edge
		end
		read_bit6:begin // Read bit 6
			if(scl)begin
				data_from_rm[6] <= sda;
				sh8in_state     <= read_bit5;
			end
			// else wait for rising edge
		end
		read_bit5:begin // Read bit 5
			if(scl)begin
				data_from_rm[5] <= sda;
				sh8in_state     <= read_bit4;
			end
			// else wait for rising edge
		end
		read_bit4:begin // Read bit 4
			if(scl)begin
				data_from_rm[4] <= sda;
				sh8in_state     <= read_bit3;
			end
			// else wait for rising edge
		end
		read_bit3:begin // Read bit 3
			if(scl)begin
				data_from_rm[3] <= sda;
				sh8in_state     <= read_bit2;
			end
			// else wait for rising edge
		end
		read_bit2:begin // Read bit 2
			if(scl)begin
				data_from_rm[2] <= sda;
				sh8in_state     <= read_bit1;
			end
			// else wait for rising edge
		end
		read_bit1:begin // Read bit 1
			if(scl)begin
				data_from_rm[1] <= sda;
				sh8in_state     <= read_bit0;
			end
			// else wait for rising edge
		end
		read_bit0:begin // Read bit 0
			if(scl)begin
				data_from_rm[0] <= sda;
				sh8in_state     <= read_end; // Move to ACK/NACK state
			end
			// else wait for rising edge
		end
		read_end:begin // Send ACK/NACK
			if(!scl) begin // On SCL falling edge
				link_data       <= 1'b1; // Make data available on parallel bus
				link_sda        <= 1'b1; // Drive SDA for ACK/NACK
				if(cnt_read == page_read_num)begin // Last byte? Send NACK
					data_buf[7]     <= 1'b1; // NACK = high
				end
				else begin // Not last byte? Send ACK
					data_buf[7]     <= 1'b0; // ACK = low
				end
				FF              <= 1'b1; // Signal byte read and ACK/NACK sent
				cnt_read        <= cnt_read + 1'b1;
				sh8in_state     <= read_begin; // Reset for next byte
				// ack signal is for master indicating cycle end, not I2C ACK
			end
			// else wait for falling edge
		end
		default:begin
			sh8in_state    <= read_begin;
		end
		endcase
end
endtask
task task_stop;
begin
	case(stop_state)
		1'b0:begin // Bring SCL high, then SDA high for stop condition
			if(!scl)begin // Wait for SCL low (should be low after last ACK/NACK)
				link_sda <= 1'b1;   // Drive SDA
				data_buf[7]<= 1'b0; // Keep SDA low first
				stop_state <= 1'b1;
			end
			// else wait for SCL low
		end
		1'b1:begin // SCL is low, SDA is low -> Bring SCL high
			if(scl)begin // Wait for SCL high
				data_buf[7] <= 1'b1; // Bring SDA high while SCL is high = Stop condition
				FF          <= 1'b1; // Signal task completion
				stop_state  <= 1'b0; // Reset task state
			end
			// else wait for SCL high
		end
	endcase
end 
endtask
endmodule