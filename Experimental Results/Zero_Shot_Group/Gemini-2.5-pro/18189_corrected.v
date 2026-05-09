module spdr_uart_framer
(
    input clk_50,
    input rst,
    output reg tx_busy,
    input tx_vld,
    input [7:0] tx_data,
    output rx_vld,
    output reg [7:0] rx_data, // Made reg for procedural assignment
    output reg rx_frame_error,
    output uart_tx,
    input uart_rx
);
    // Parameter for sampling clock divider. Adjust based on clk_50 frequency and desired baud rate.
    // Example: For 115200 baud @ 50MHz with 8x oversampling: 50,000,000 / 115200 / 8 = ~54
    // Example: For 115200 baud @ 50MHz with 16x oversampling: 50,000,000 / 115200 / 16 = ~27
    // The original value 62 gives ~79.3kbps baud with 8x oversampling logic below (7 sample_en per bit).
    parameter SAMPLE_CLK_DIV = 6'd62;

    // Sample Clock Generation
    reg [5:0] sample_cnt;
    reg sample_en;
    always @ (posedge clk_50 or posedge rst)
        if (rst)
        begin
            sample_cnt <= 6'd0;
            sample_en <= 1'b0;
        end
        else
        begin
            sample_en <= 1'b0; // Default value
            if (sample_cnt == SAMPLE_CLK_DIV)
            begin
                sample_cnt <= 6'd0;
                sample_en <= 1'b1;
            end
            else
            begin
                sample_cnt <= sample_cnt + 1'b1;
            end
        end

    // RX Logic
    reg [6:0] rx_sample; // Input synchronizer/filter shift register
    reg [2:0] rx_bitclk_cnt; // Counts sample_en pulses within a bit period (Suggests 7x oversampling based on usage)
    reg rx_bitclk_en; // Pulse indicating bit sample time
    reg [3:0] rx_bit_cnt; // Counts received bits (0=start, 1-8=data, 9=stop)
    reg rx_busy; // Receiver active flag
    reg [8:0] rx_capture; // Shift register for captured bits (Start + 8 Data)
    reg rx_data_done; // Pulse indicating valid data received
    reg rx_busy_d1; // Previous state of rx_busy for edge detection
    reg stop_bit_value; // Store the sampled stop bit value

    // RX Input Sampling
    always @ (posedge clk_50 or posedge rst)
        if (rst)
            rx_sample <= 7'h7F; // Initialize to idle (high)
        else if (sample_en)
            rx_sample <= {rx_sample[5:0], uart_rx};

    // RX Start Bit Detection (Look for 1->0 transition)
    // A robust way is looking for a pattern like '1110000' in rx_sample
    wire rx_falling_edge = (rx_sample == 7'b1110000); // Example: need 3 high then 4 low samples

    // RX State Machine / Bit Sampling Control
    always @ (posedge clk_50 or posedge rst)
        if (rst)
        begin
            rx_bitclk_cnt <= 3'd0;
            rx_bitclk_en <= 1'b0;
            rx_bit_cnt <= 4'd0;
            rx_busy <= 1'b0;
        end
        else
        begin
            rx_bitclk_en <= 1'b0; // Default value
            if (sample_en) // Operate only on sample clock edge
            begin
                if (!rx_busy) // Idle state
                begin
                    rx_bitclk_cnt <= 3'd0;
                    rx_bit_cnt <= 4'd0;
                    if (rx_falling_edge) // Detected start bit
                    begin
                        rx_busy <= 1'b1;
                        // rx_bitclk_cnt already 0, start counting for the first bit sample point
                    end
                end
                else // Receiving state
                begin
                    // Check if bit time ended (7 sample clocks per bit)
                    if (rx_bitclk_cnt == 3'd6)
                    begin
                        rx_bitclk_cnt <= 3'd0;
                        if (rx_bit_cnt == 4'd9) // Finished receiving stop bit
                        begin
                            rx_busy <= 1'b0; // Go back to idle
                            rx_bit_cnt <= 4'd0; // Reset bit counter for next frame
                        end
                        else
                        begin
                            rx_bit_cnt <= rx_bit_cnt + 1'b1; // Move to next bit
                        end
                    end
                    else
                    begin
                        rx_bitclk_cnt <= rx_bitclk_cnt + 1'b1;
                    end

                    // Generate sample enable pulse near the middle of the bit (e.g., count 3 of 0-6)
                    if (rx_bitclk_cnt == 3'd3)
                    begin
                        rx_bitclk_en <= 1'b1;
                    end
                end
            end
        end

    // RX Data Capture and Stop Bit Check
    always @ (posedge clk_50 or posedge rst)
        if (rst)
        begin
            rx_capture <= 9'd0;
            stop_bit_value <= 1'b1; // Expect high stop bit
        end
        else if (sample_en && rx_bitclk_en) // Sample at the designated time
        begin
            // Sample the middle bit of the filter register
            // rx_bit_cnt: 0=start, 1-8=data, 9=stop
            if (rx_bit_cnt > 0 && rx_bit_cnt < 9) // Capture data bits
            begin
                // Shift LSB first, so new bit goes to MSB of capture slice
                rx_capture[8:1] <= {rx_sample[3], rx_capture[8:2]};
            end
            else if (rx_bit_cnt == 9) // Capture stop bit
            begin
                 stop_bit_value <= rx_sample[3];
                 rx_capture[0] <= rx_sample[3]; // Capture last data bit (shifted from [1])
            end
             else if (rx_bit_cnt == 0) // Capture start bit (for potential debug, not usually stored)
             begin
                // Optionally capture start bit if needed: rx_capture[8] <= rx_sample[3];
                // Or just shift previous data down:
                 rx_capture[8:1] <= rx_capture[7:0];
             end
        end


    // RX Output Generation
    always @ (posedge clk_50 or posedge rst)
        if (rst)
        begin
            rx_data_done <= 1'b0;
            rx_busy_d1 <= 1'b0;
            rx_frame_error <= 1'b0;
            rx_data <= 8'd0;
        end
        else
        begin
            rx_busy_d1 <= rx_busy;
            rx_data_done <= rx_busy_d1 && !rx_busy; // Pulse when rx goes from busy to not busy

            if (rx_data_done)
            begin
                // Assign data and check frame error when reception completes
                rx_data <= rx_capture[7:0]; // Data bits are now in the lower 8 bits
                rx_frame_error <= !stop_bit_value; // Error if stop bit was low
            end
            else
            begin
                 // Don't clear frame error immediately, let user logic see it with rx_vld
                 // rx_frame_error <= 1'b0; // Or clear it here if preferred
                 rx_data_done <= 1'b0;
            end

            // Clear error when starting new reception or idle
            if (!rx_busy && !rx_busy_d1) begin
                rx_frame_error <= 1'b0;
            end
        end

    assign rx_vld = rx_data_done;

    // TX Logic
    reg [9:0] tx_shift; // 1 Start bit + 8 Data bits + 1 Stop bit
    reg [2:0] tx_bitclk_cnt; // Counts sample_en pulses within a bit period
    reg [3:0] tx_cnt; // Counts transmitted bits (0-9)

    assign uart_tx = tx_shift[0]; // Output LSB of shift register

    always @ (posedge clk_50 or posedge rst)
        if (rst)
        begin
            tx_shift <= {10{1'b1}}; // Idle state (high)
            tx_bitclk_cnt <= 3'd0;
            tx_cnt <= 4'd0;
            tx_busy <= 1'b0;
        end
        else
        begin
            if (!tx_busy && tx_vld) // Load data when idle and input valid
            begin
                // Load with Stop bit (1), Data (MSB..LSB), Start bit (0)
                tx_shift <= {1'b1, tx_data[7:0], 1'b0};
                tx_bitclk_cnt <= 3'd0;
                tx_cnt <= 4'd0; // Start counting bits from 0
                tx_busy <= 1'b1;
            end
            else if (tx_busy && sample_en) // Shift data out when busy
            begin
                // Check if bit time ended (7 sample clocks per bit)
                if (tx_bitclk_cnt == 3'd6)
                begin
                    tx_bitclk_cnt <= 3'd0;
                    tx_shift <= {1'b1, tx_shift[9:1]}; // Shift right, shift in '1' (idle level)
                    tx_cnt <= tx_cnt + 1'b1;

                    if (tx_cnt == 4'd9) // After shifting 10 times (bits 0 through 9)
                    begin
                        tx_busy <= 1'b0; // Transmission complete
                        // tx_cnt will roll over or be reset implicitly by !tx_busy next cycle
                    end
                end
                else
                begin
                    tx_bitclk_cnt <= tx_bitclk_cnt + 1'b1;
                end
            end
            // Keep state otherwise (e.g., tx_busy high but sample_en low)
        end

endmodule