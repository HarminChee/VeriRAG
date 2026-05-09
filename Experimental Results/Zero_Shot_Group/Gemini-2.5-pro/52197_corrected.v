`default_nettype none

module Blinky(
	output reg led_lfosc_ff = 0,
	output reg led_lfosc_count = 0,
	output wire led_lfosc_shreg1,
	output wire led_lfosc_shreg1a,
	output wire led_lfosc_shreg2,
	output wire led_lfosc_shreg2a,
	output reg led_rosc_ff = 0,
	output reg led_rcosc_ff = 0,
	input wire sys_rst,			
	input wire count_rst,		
	input wire osc_pwrdn		
);

	// Assuming GP_SYSRESET, GP_POR, GP_LFOSC, GP_RINGOSC, GP_RCOSC, 
	// GP_COUNT8, GP_COUNT14, GP_SHREG are predefined modules/primitives.

	// System Reset Controller (Assuming it exists)
	GP_SYSRESET #(
		.RESET_MODE("LEVEL")
	) reset_ctrl (
		.RST(sys_rst)
	);

	wire por_done;
	// Power-On Reset (Assuming it exists)
	GP_POR #(
		.POR_TIME(500)
	) por (
		.RST_DONE(por_done)
	);

	wire clk_108hz;
	// Low Frequency Oscillator (Assuming it exists)
	GP_LFOSC #(
		.PWRDN_EN(1),
		.AUTO_PWRDN(0),
		.OUT_DIV(16)
	) lfosc (
		.PWRDN(osc_pwrdn),
		.CLKOUT(clk_108hz)
	);

	wire clk_1687khz_cnt;		
	wire clk_1687khz;			
	// Ring Oscillator (Assuming it exists)
	GP_RINGOSC #(
		.PWRDN_EN(1),
		.AUTO_PWRDN(0),
		.HARDIP_DIV(16),
		.FABRIC_DIV(1)
	) ringosc (
		.PWRDN(osc_pwrdn),
		.CLKOUT_HARDIP(clk_1687khz_cnt),
		.CLKOUT_FABRIC(clk_1687khz)
	);

	wire clk_6khz_cnt;			
	wire clk_6khz;				
	// RC Oscillator (Assuming it exists)
	GP_RCOSC #(
		.PWRDN_EN(1),
		.AUTO_PWRDN(0),
		.OSC_FREQ("25k"),		
		.HARDIP_DIV(4),
		.FABRIC_DIV(1)
	) rcosc (
		.PWRDN(osc_pwrdn),
		.CLKOUT_HARDIP(clk_6khz_cnt),
		.CLKOUT_FABRIC(clk_6khz)
	);

	localparam COUNT_MAX = 31;
	reg[7:0] count = COUNT_MAX; // Fabric counter example

	// Fabric Counter Logic (using clk_108hz)
	// Asynchronous reset via count_rst
	always @(posedge clk_108hz, posedge count_rst) begin
		if(count_rst)
			count <= 8'd0; // Reset to 0
		else begin
			if(count == 0)
				count <= COUNT_MAX;
			else
				count <= count - 1'd1;
		end
	end

	wire led_fabric_raw = (count == 0); // Pulse when fabric counter reaches 0

	wire led_lfosc_raw;
	// LFOSC Counter (using GP_COUNT8 primitive)
	GP_COUNT8 #(
		.RESET_MODE("LEVEL"), // Assuming this handles count_rst appropriately
		.COUNT_TO(COUNT_MAX),
		.CLKIN_DIVIDE(1)
	) lfosc_cnt (
		.CLK(clk_108hz),
		.RST(count_rst),
		.OUT(led_lfosc_raw) // Pulse output from the counter primitive
	);

	wire led_rosc_raw;
	// Ring Oscillator Counter (using GP_COUNT14 primitive)
	GP_COUNT14 #(
		.RESET_MODE("LEVEL"), // Assuming this handles count_rst appropriately
		.COUNT_TO(16383), // Example count value
		.CLKIN_DIVIDE(1)
	) ringosc_cnt (
		.CLK(clk_1687khz_cnt), // Using HARDIP output
		.RST(count_rst),
		.OUT(led_rosc_raw) // Pulse output from the counter primitive
	);

	wire led_rcosc_raw;
	// RC Oscillator Counter (using GP_COUNT14 primitive)
	GP_COUNT14 #(
		.RESET_MODE("LEVEL"), // Assuming this handles count_rst appropriately
		.COUNT_TO(1023), // Example count value
		.CLKIN_DIVIDE(1)
	) rcosc_cnt (
		.CLK(clk_6khz_cnt), // Using HARDIP output
		.RST(count_rst),
		.OUT(led_rcosc_raw) // Pulse output from the counter primitive
	);

	// Logic for LFOSC based LEDs (Fabric counter and GP_COUNT8)
	// Toggles LEDs based on counter outputs, gated by POR completion
	always @(posedge clk_108hz) begin
		if(por_done) begin // Only operate after POR is done
			if(led_fabric_raw)
				led_lfosc_ff <= ~led_lfosc_ff; // Toggle on fabric counter pulse
			if(led_lfosc_raw)
				led_lfosc_count <= ~led_lfosc_count; // Toggle on GP_COUNT8 pulse
		end
		// Note: No explicit reset here, relies on initial value and por_done gate
	end

	reg[3:0] pdiv = 4'd0; // Prescaler for Ring Oscillator LED
	// Logic for Ring Oscillator LED (using GP_COUNT14 output and fabric clock)
	// Includes a prescaler (divide by 16)
	always @(posedge clk_1687khz) begin // Using FABRIC output clock
		// Note: No explicit reset here, relies on initial value
		if(led_rosc_raw) begin // Check pulse from ringosc_cnt
			pdiv <= pdiv + 1'd1;
			if(pdiv == 4'b1111) // Toggle only when prescaler rolls over (every 16 pulses)
				led_rosc_ff <= ~led_rosc_ff;
		end else begin
			// Optionally reset pdiv if led_rosc_raw is low? 
			// Current logic keeps pdiv counting even if led_rosc_raw goes low between edges.
			// If reset is desired when led_rosc_raw is low: pdiv <= 4'd0; 
		end
	end

	// Logic for RC Oscillator LED (using GP_COUNT14 output and fabric clock)
	always @(posedge clk_6khz) begin // Using FABRIC output clock
		// Note: No explicit reset here, relies on initial value
		if(led_rcosc_raw) // Toggle on every pulse from rcosc_cnt
			led_rcosc_ff <= ~led_rcosc_ff;
	end

	// Shift Register using GP_SHREG primitive
	GP_SHREG #(
		.OUTA_TAP(8),  // Output A taps the 8th stage
		.OUTA_INVERT(0),
		.OUTB_TAP(16)  // Output B taps the 16th stage
	) shreg (
		.nRST(por_done), // Use por_done for reset (active low, so connect por_done directly if it's active high indication)
		                 // Or connect to ~sys_rst if asynchronous reset is desired
		                 // Original code had 1'b1 (no reset)
		.CLK(clk_108hz),
		.IN(led_lfosc_ff), // Input from the LFOSC FF
		.OUTA(led_lfosc_shreg1), // Output from 8th stage
		.OUTB(led_lfosc_shreg2)  // Output from 16th stage
	);

	// Inferred Shift Register (alternative implementation)
	reg[15:0] led_lfosc_infreg = 16'd0;
	assign led_lfosc_shreg1a = led_lfosc_infreg[7];  // Output from 8th stage (index 7)
	assign led_lfosc_shreg2a = led_lfosc_infreg[15]; // Output from 16th stage (index 15)

	always @(posedge clk_108hz) begin
		// Note: No explicit reset here, relies on initial value
		// Consider adding reset tied to por_done or sys_rst if needed
		// if (!por_done) led_lfosc_infreg <= 16'd0; else ...
		led_lfosc_infreg <= {led_lfosc_infreg[14:0], led_lfosc_ff}; // Shift in the LFOSC FF value
	end

endmodule