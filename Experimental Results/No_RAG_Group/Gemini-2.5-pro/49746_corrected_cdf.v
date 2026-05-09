`timescale 1ns / 1ps
module UART_Rx_corrected_cdf ( // Renamed module
    input CLK,
    output reg [7:0] D = 8'b00000000,
	 input RD,
    input RST,
    input RX,
    output reg RXNE = 1'b0
    );

parameter CLOCK = 1_000_000;
parameter BAUD_RATE = 9_600;
localparam SAMPLES = 4;
// Ensure CLK_DIV is at least 1
localparam CLK_DIV = (CLOCK/(BAUD_RATE*SAMPLES*2) == 0) ? 1 : CLOCK/(BAUD_RATE*SAMPLES*2);
// Calculate width carefully, ensuring it's at least 1 bit wide even if CLK_DIV is 1
localparam BAUD_COUNTER_WIDTH = (CLK_DIV <= 1) ? 1 : $clog2(CLK_DIV);

reg [BAUD_COUNTER_WIDTH-1:0] baud_counter = 0;
// reg prev_CLK_B; // Removed - Caused CDFDAT
reg CLK_B = 1'b0;
reg clk_b_posedge_event; // Signal to capture the rising edge event

// Clock divider and edge detection logic
always @ (posedge CLK) begin
    // Detect rising edge event *before* updating CLK_B for the next cycle
    // Rising edge occurs when counter reaches max and CLK_B is currently low
    clk_b_posedge_event <= (baud_counter == CLK_DIV-1) && (~CLK_B);

    // Update baud counter and CLK_B
	 if (RST) begin // Reset overrides counter logic
        baud_counter <= 0;
        CLK_B <= 1'b0; // Define reset state for CLK_B
     end else if ( baud_counter == CLK_DIV-1) begin
		baud_counter <= 0;
		CLK_B <= ~CLK_B;
	 end else begin
        baud_counter <= baud_counter + 1'b1;
    end
end

reg [SAMPLES-1:0] symbol = {SAMPLES{1'b1}};
// Calculate width carefully, ensuring it's at least 1 bit wide
localparam SYMBOL_CNT_WIDTH = (SAMPLES <= 1) ? 1 : $clog2(SAMPLES);
reg [SYMBOL_CNT_WIDTH-1:0] symbol_cnt = 0;

reg busy = 1'b0;
reg [9:0] data = 10'b1111111111; // Stores start, 8 data, stop bits (LSB first shifted in)
reg [3:0] data_cnt = 0; // Counts bits remaining *after* start bit

// Main state machine logic - now triggered by clk_b_posedge_event
always @(posedge CLK) begin
	if (RST == 1'b1) begin
		symbol_cnt <= 0;
		data_cnt <= 0;
		RXNE <= 1'b0;
		busy <= 1'b0;
		D <= 8'b00000000;
        symbol <= {SAMPLES{1'b1}}; // Reset symbol register
        data <= 10'b1111111111; // Reset data register
        clk_b_posedge_event <= 1'b0; // Reset event flag (handled in other always block too, but safe here)
	end
	else begin // Non-reset operation

        // Main logic triggered by the detected rising edge of CLK_B
        if (clk_b_posedge_event) begin
            // Sample RX at the rising edge of CLK_B
            symbol <= {RX, symbol[SAMPLES-1:1]};

            // Start bit detection logic (uses previous cycle's symbol value and current RX)
            // Original condition: (RX==1'b0) && (symbol[SAMPLES-1]==1'b0) && !data_cnt && !busy
            // This checks current RX and the oldest sample from previous CLK_B edge.
            if((RX==1'b0) && (symbol[SAMPLES-1]==1'b0) && !data_cnt && !busy) begin // Start condition detection
                symbol_cnt <= SAMPLES/2; // Wait half a bit time to sample near center
                data_cnt <= 9; // Expect 8 data bits + 1 stop bit (9 bits after start)
                busy <= 1'b1;
                data <= 10'b1111111111; // Initialize shift register, expecting start bit '0' soon
            end

            // Data reception logic
            if(busy) begin
                if(symbol_cnt > 0) begin // Wait for sample point within the bit time
                    symbol_cnt <= symbol_cnt - 1'b1;
                end else begin // At sample point
                    // Use original sampling logic based on case statement
                    // Note: 'symbol' contains samples from the *current* bit time including the one just shifted in.
                    case (symbol[SAMPLES-2:0]) // Check 3 oldest samples (before the newest one just shifted in)
                        3'b111, 3'b110, 3'b101, 3'b011: // Majority '1'?
                            data <= {1'b1, data[9:1]}; // Shift in '1'
                        default: // Majority '0'?
                            data <= {1'b0, data[9:1]}; // Shift in '0'
                    endcase

                    if (data_cnt > 0) begin // More bits to receive?
                        data_cnt <= data_cnt - 1'b1;
                        symbol_cnt <= SAMPLES - 1; // Reset counter for next full bit period
                    else begin // Last bit (stop bit) should have been received and shifted in
                        // Check frame validity: start bit (data[9]) == 0, stop bit (data[0]) == 1
                        if ((data[9] == 1'b0) && (data[0] == 1'b1)) begin // Valid frame
                            D <= data[8:1]; // Store received data bits (data[8] is first data bit, data[1] is last)
                            RXNE <= 1'b1;   // Set data ready flag
                        end else begin
                            // Framing error - do not assert RXNE
                            RXNE <= 1'b0;
                        end
                        busy <= 1'b0; // Reception finished (successfully or with error)
                    end // end if(data_cnt > 0) else
                end // end if(symbol_cnt > 0) else
            end // end if(busy)
        end // end if(clk_b_posedge_event)

        // Read logic (synchronous clear of RXNE flag on next clock edge after RD is high)
        // Changed from original asynchronous-like clear to synchronous clear
        if (RD == 1'b1) begin
            RXNE <= 1'b0;
        end
	end // end else (non-reset)
end // end always @(posedge CLK)

endmodule