module ps2_keyboard (
    output RESET_N,
    input CLK,
    inout PS2_CLK,
    inout PS2_DATA,
    output RX_SCAN,
    output RX_PRESSED,
    output RX_EXTENDED
);

// Internal signals
reg [7:0] scan_code;
reg       extended;
reg       pressed;
reg       reset_n;
reg [10:0] ps2_data_buffer;
reg [3:0]  bit_count;
reg        receiving;

// Constants
localparam IDLE = 0;
localparam RECEIVE = 1;

// State machine for PS/2 reception
reg [1:0] state;

// Assign outputs
assign RX_SCAN     = scan_code;
assign RX_PRESSED  = pressed;
assign RX_EXTENDED = extended;
assign RESET_N     = reset_n;

// Tri-state buffer control
assign PS2_CLK = (receiving) ? 1'bz : 1'b1; // Drive high when not receiving, high impedance when receiving
assign PS2_DATA = (receiving) ? 1'bz : 1'b1; // Drive high when not receiving, high impedance when receiving

// Initialization
initial begin
    reset_n = 1'b0; // Initialize reset to low
    receiving = 1'b0;
    state = IDLE;
	 bit_count = 4'b0;
	 scan_code = 8'b0;
	 extended = 1'b0;
	 pressed = 1'b0;

    #100  // Hold reset for a short time
    reset_n = 1'b1; // Release reset
end

// PS/2 Clock edge detection
reg ps2_clk_prev;

always @(posedge CLK) begin
    ps2_clk_prev <= PS2_CLK;
end

wire ps2_clk_falling_edge = (ps2_clk_prev == 1'b1) && (PS2_CLK == 1'b0);

// State machine for receiving PS/2 data
always @(posedge CLK) begin
    if (!reset_n) begin
        state <= IDLE;
        receiving <= 1'b0;
        bit_count <= 4'b0;
        scan_code <= 8'b0;
        extended <= 1'b0;
        pressed <= 1'b0;
    end else begin
        case (state)
            IDLE: begin
                if (!PS2_DATA && ps2_clk_falling_edge) begin
                    state <= RECEIVE;
                    receiving <= 1'b1;
                    bit_count <= 4'b0;
                    ps2_data_buffer[0] <= PS2_DATA; // Start bit
                end
            end
            RECEIVE: begin
                if (ps2_clk_falling_edge) begin
                    bit_count <= bit_count + 1'b1;
                    ps2_data_buffer[bit_count] <= PS2_DATA;

                    if (bit_count == 10) begin
                        // Stop bit received
                        state <= IDLE;
                        receiving <= 1'b0;

                        // Process the received data (excluding start and stop bits)
                        scan_code <= {ps2_data_buffer[8:1]};

                        // Detect extended keys and key press/release
                        if (scan_code == 8'b11100011) begin // E0 prefix
                            extended <= 1'b1;
                        end else begin
                            extended <= 1'b0;
                        end

                        if (ps2_data_buffer[9] == 1'b0) begin // Parity bit
							  pressed <= 1'b1;
                        end else begin
							  pressed <= 1'b0;
                        end
                    end
                end
            end
            default: state <= IDLE;
        endcase
    end
end

endmodule