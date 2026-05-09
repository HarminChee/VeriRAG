module jpeg_encoder(
	clk,
	rst, // Changed from wire rst = 1'b1 to input rst
	ena,
	dstrb,
	din,
	qnt_val,
	qnt_cnt,
	size,
	rlen,
	amp,
	douten,
	SE,
	SI,
	SO
);
	parameter coef_width = 11;
	parameter di_width = 8;

	input               clk;
	input               rst; // Made rst an input
	input               ena;
	input               dstrb;
	input [di_width-1:0] din;
	input [7:0]         qnt_val;
	output [ 5:0]       qnt_cnt;
	output [ 3:0]       size;
	output [ 3:0]       rlen;
	output [11:0]       amp;
	output              douten;

	// DFT Ports
	input               SE;
	input               SI;
	output              SO;

	// Internal signals
	wire                fdct_doe, qnr_doe;
	wire [11:0]         fdct_dout;
	reg  [11:0]         dfdct_dout;
	wire [10:0]         qnr_dout;
	reg                 dqnr_doe;
	wire [11:0]         dc_diff_dout;
	wire                dc_diff_doe;
	wire                unused_bstart; // Added wire for unconnected output

	// Scan Output - Connect directly to Scan Input as a placeholder
	// A real implementation would involve a scan chain through internal flops.
	// This simple assignment makes the SO port driven, avoiding lint errors.
	// Actual scan functionality depends on tool insertion or manual chain implementation.
	assign SO = SI; // Basic placeholder connection for SO

	fdct #(
		.C_WIDTH(coef_width), // Assuming parameter names C_WIDTH
		.D_WIDTH(di_width),   // Assuming parameter names D_WIDTH
		.O_WIDTH(12)          // Assuming parameter name O_WIDTH for output width
	)
	fdct_zigzag(
		.clk(clk),
		.ena(ena),
		.rst(rst),
		.dstrb(dstrb),
		.din(din),
		.dout(fdct_dout),
		.douten(fdct_doe)
	);

	always @(posedge clk or posedge rst) begin // Added asynchronous reset
		if (rst) begin
			dfdct_dout <= 12'b0;
		end else if (ena) begin
			dfdct_dout <= fdct_dout; // Removed #1 delay
		end
	end

	jpeg_qnr qnr(
		.clk(clk),
		.ena(ena),
		.rst(rst),
		.dstrb(fdct_doe),
		.din(dfdct_dout),
		.qnt_val(qnt_val),
		.qnt_cnt(qnt_cnt),
		.dout(qnr_dout),
		.douten(qnr_doe)
	);

	always @(posedge clk or posedge rst) begin // Added asynchronous reset
		if (rst) begin
			dqnr_doe <= 1'b0;
		end else if (ena) begin
			dqnr_doe <= qnr_doe; // Removed #1 delay
		end
	end

	// Sign extend qnr_dout (11 bits) to 12 bits for rle input
	assign dc_diff_dout = {{1{qnr_dout[10]}}, qnr_dout}; // Corrected sign extension syntax
	assign dc_diff_doe = dqnr_doe;

	jpeg_rle rle(
		.clk(clk),
		.ena(ena),
		.rst(rst),
		.dstrb(dc_diff_doe),
		.din(dc_diff_dout),
		.size(size),
		.rlen(rlen),
		.amp(amp),
		.douten(douten),
		.bstart(unused_bstart) // Connected bstart to declared wire
	);

endmodule

// Note: The sub-module definitions (fdct, jpeg_qnr, jpeg_rle) are assumed to exist elsewhere.
// Parameter names within the fdct instantiation (.C_WIDTH, .D_WIDTH, .O_WIDTH) are assumed;
// adjust them if the actual fdct module uses different names.
// The DFT connection (assign SO = SI) is a minimal placeholder.
// Real scan chain implementation requires modification of internal registers or tool intervention.