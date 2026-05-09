/*
 * Corrected JTAG FIFO module.
 * Assumes fifo_generator_v8_2 instances are generated with appropriate widths:
 * - tck_to_rx_clk_blk: DIN_WIDTH=9, DOUT_WIDTH=9
 * - rx_clk_to_tck_blk: DIN_WIDTH=12, DOUT_WIDTH=12
 */
module jtag_fifo (
	// RX Clock Domain Interface (Data from System to JTAG)
	input rx_clk,
	input [11:0] rx_data,
	input wr_en,            // Write enable for rx_clk_to_tck_blk FIFO
	output tx_full,         // Full flag for rx_clk_to_tck_blk FIFO

	// TX Clock Domain Interface (Data from JTAG to System)
	input rd_en,            // Read enable for tck_to_rx_clk_blk FIFO
	output [8:0] tx_data,
	output tx_empty         // Empty flag for tck_to_rx_clk_blk FIFO

	// JTAG signals are implicitly connected via BSCAN primitive
);

	// Internal JTAG signals from BSCAN
	wire jt_capture;
	wire jt_drck; // Note: This is a clock derived from TCK, often unused directly if TCK is used
	wire jt_reset; // JTAG TAP reset (TRST or state machine reset)
	wire jt_sel;   // Indicates Instruction or Data Register scan path is selected
	wire jt_shift; // Shift-DR or Shift-IR state active
	wire jt_tck;   // JTAG Test Clock
	wire jt_tdi;   // JTAG Test Data In
	wire jt_update;// Update-DR or Update-IR state active
	wire jt_tdo;   // JTAG Test Data Out

	// BSCAN Primitive Instantiation
	BSCAN_SPARTAN6 #(
		.JTAG_CHAIN(1) // Specify the JTAG chain number
	) jtag_blk (
		.CAPTURE(jt_capture), // Output: High during Capture-DR state
		.DRCK(jt_drck),       // Output: Clock for shifting data (can be gated TCK)
		.RESET(jt_reset),     // Output: High when TAP controller is reset
		.RUNTEST(),           // Output: Tied to RUNTEST/IDLE state (often unused)
		.SEL(jt_sel),         // Output: High when USER scan chain selected
		.SHIFT(jt_shift),     // Output: High during Shift-DR state
		.TCK(jt_tck),         // Output: JTAG test clock
		.TDI(jt_tdi),         // Output: Data input from JTAG TDI pin
		.TDO(jt_tdo),         // Input: Data output to JTAG TDO pin
		.TMS(),               // Output: JTAG TMS signal (usually not needed internally)
		.UPDATE(jt_update)    // Output: High during Update-DR state
	);

	// Internal signals for FIFO control and data path
	reg captured_data_valid = 1'b0;
	reg [12:0] dr; // JTAG Data Register (Shift Register)
	wire fifo_out_full; // Full signal for tck_to_rx_clk_blk
	wire fifo_out_empty; // Empty signal for tck_to_rx_clk_blk (renamed to avoid clash)
	wire [8:0] fifo_out_dout; // Data output from tck_to_rx_clk_blk

	// FIFO: JTAG TCK domain to System RX Clock domain (Transmitting data out of JTAG)
	// Data shifted into 'dr' during Shift-DR is written here during Update-DR
	// and read by the system logic on rx_clk.
	fifo_generator_v8_2 tck_to_rx_clk_blk (
		.wr_clk(jt_tck),      // Write clock (JTAG clock)
		.rd_clk(rx_clk),      // Read clock (System clock)
		.din(dr[8:0]),        // Data input (Lower 9 bits of JTAG DR) - ASSUMES 9-bit FIFO width
		.wr_en(jt_update & jt_sel & !fifo_out_full), // Write enable: during Update-DR if selected and not full
		.rd_en(rd_en & !fifo_out_empty), // Read enable: controlled by system logic when not empty
		.dout(fifo_out_dout), // Data output to system - ASSUMES 9-bit FIFO width
		.full(fifo_out_full), // Full status flag
		.empty(fifo_out_empty) // Empty status flag
	);

	// Connect FIFO output signals to module output ports
	assign tx_data = fifo_out_dout;
	assign tx_empty = fifo_out_empty;

	// Internal signals for FIFO control and data path
	wire [11:0] captured_data; // Data read from rx_clk_to_tck_blk FIFO
	wire fifo_in_full;   // Full signal for rx_clk_to_tck_blk
	wire fifo_in_empty;  // Empty signal for rx_clk_to_tck_blk

	// FIFO: System RX Clock domain to JTAG TCK domain (Receiving data into JTAG)
	// Data from the system (rx_data) is written on rx_clk
	// and read during Capture-DR state on jt_tck to be loaded into 'dr'.
	fifo_generator_v8_2 rx_clk_to_tck_blk (
		.wr_clk(rx_clk),      // Write clock (System clock)
		.rd_clk(jt_tck),      // Read clock (JTAG clock)
		.din(rx_data),        // Data input from system - ASSUMES 12-bit FIFO width
		.wr_en(wr_en & !fifo_in_full), // Write enable: controlled by system logic when not full
		.rd_en(jt_capture & jt_sel & ~fifo_in_empty & ~jt_reset), // Read enable: during Capture-DR if selected, not empty, and not reset
		.dout(captured_data), // Data output (captured value) - ASSUMES 12-bit FIFO width
		.full(fifo_in_full),  // Full status flag
		.empty(fifo_in_empty) // Empty status flag
	);

	// Connect FIFO full signal to module output port
	assign tx_full = fifo_in_full;

	// Assign JTAG TDO output: LSB of the internal shift register 'dr'
	assign jt_tdo = dr[0];

	// JTAG Data Register (DR) shift logic
	// Operates on the positive edge of the JTAG clock (jt_tck)
	// Asynchronous reset via jt_reset
	always @ (posedge jt_tck or posedge jt_reset)
	begin
		if (jt_reset == 1'b1) // Asynchronous reset condition
		begin
			dr <= 13'd0;
			captured_data_valid <= 1'b0;
		end
		else // Synchronous logic on jt_tck edge
		begin
			// Capture-DR state: Check if data is available from input FIFO
			if (jt_capture == 1'b1 && jt_sel == 1'b1)
			begin
				// Check fifo_in_empty status from the *previous* cycle, as rd_en depends on it.
				// More robustly, check if the read enable *was* asserted.
				// The FIFO read happens combinationally based on jt_capture.
				// We set the flag here if the FIFO *wasn't* empty during capture.
				captured_data_valid <= ~fifo_in_empty;
				dr <= 13'd0; // Clear DR in Capture state (as per original logic)
			end
			// Shift-DR state: Shift data in/out
			else if (jt_shift == 1'b1 && jt_sel == 1'b1)
			begin
				// If valid data was captured in the previous Capture-DR state, load it now.
				// This happens on the first clock edge of the Shift-DR state.
				if (captured_data_valid == 1'b1)
				begin
					captured_data_valid <= 1'b0; // Clear flag after loading
					// Load captured data (11 bits), a validity marker (1'b1), and TDI
					dr <= {jt_tdi, 1'b1, captured_data[11:1]}; // Note: captured_data[0] is discarded here
				end
				// Otherwise, perform a normal shift operation
				else
				begin
					dr <= {jt_tdi, dr[12:1]}; // Shift right, TDI enters MSB
				end
			end
			// Other states (e.g., Update-DR, Idle): Hold the value of dr
			// No explicit else needed if dr should retain its value outside
			// reset, capture, and shift states when jt_sel is high.
			// However, if jt_sel goes low, dr should ideally retain its value.
			// The current logic only updates dr when jt_sel is high during capture/shift.
            // If jt_sel can change during other states while jt_tck is active,
            // consider if dr needs to hold its value explicitly.
            // Also, reset captured_data_valid if not in Capture state to prevent
            // potential issues if a shift starts without a preceding capture.
            else if (jt_capture == 1'b0) // Reset flag if not in capture state
            begin
                 captured_data_valid <= 1'b0;
            end

		end
	end

endmodule