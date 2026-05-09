`default_nettype none
`default_nettype none
module Counter(
    input wire clk_i,        // Added: Test clock input
    input wire test_i,       // Added: Test mode input
    input wire rst,
    output wire dout,
    output wire dout_fabric
);
	wire clk_6khz_cnt;
	wire clk_6khz;
	GP_RCOSC #(
		.PWRDN_EN(0),
		.AUTO_PWRDN(0),
		.OSC_FREQ("25k"),
		.HARDIP_DIV(4),
		.FABRIC_DIV(1)
	) rcosc (
		.PWRDN(1'b0),
		.CLKOUT_HARDIP(clk_6khz_cnt),
		.CLKOUT_FABRIC(clk_6khz)
	);

    // DFT Clock Muxing
    wire dft_clk_cnt;
    wire dft_clk_fabric;
    assign dft_clk_cnt    = test_i ? clk_i : clk_6khz_cnt;
    assign dft_clk_fabric = test_i ? clk_i : clk_6khz;

	localparam COUNT_MAX = 31;
	reg[7:0] count = COUNT_MAX;
	// Use the muxed clock for the flip-flops
	always @(posedge dft_clk_cnt, posedge rst) begin
		if(rst)
			count			<= 8'd0; // Use sized literal
		else begin
			if(count == 8'd0) // Use sized literal
				count		<= COUNT_MAX;
			else
				count		<= count - 1'd1;
		end
	end

	assign dout = (count == 8'd0); // Use sized literal

	reg[5:0] count_fabric = COUNT_MAX;
	// Use the muxed clock for the flip-flops
	always @(posedge dft_clk_fabric, posedge rst) begin
		if(rst)
			count_fabric		<= 6'd0; // Use sized literal
		else begin
			if(count_fabric == 6'd0) // Use sized literal
				count_fabric	<= COUNT_MAX;
			else
				count_fabric	<= count_fabric - 1'd1;
		end
	end

	assign dout_fabric = (count_fabric == 6'd0); // Use sized literal
endmodule
`default_nettype wire