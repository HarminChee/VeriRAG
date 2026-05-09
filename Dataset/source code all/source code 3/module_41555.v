module DETECTOR(
	input 				SYS_CLK,
	input					RST,
	input [13:0]		TIME,
	input [23:0]		THRESHOLD,
	input [29:0]		Y,
	input [25:0]		sumXsq,
	output reg [59:0] Yn_NUM,
	output reg [49:0] Yn_DEN,
	output reg			DETECTION
);
	wire [59:0]		CORRELATION_NUMERATOR;
	wire [49:0]		CORRELATION_DENOMINATOR;
	MULT_FIRSQ	MULT_FIRSQ_instant (
		.dataa 		( Y 								),
		.result 		( CORRELATION_NUMERATOR 	)
	);
	MULT_sumXsq	MULT_sumXsq_instant (
		.dataa 		( sumXsq 						),
		.datab 		( THRESHOLD 					),
		.result 		( CORRELATION_DENOMINATOR	)
	);
	reg [29:0] Y_input;
	always @(posedge SYS_CLK) begin
		if (RST) begin
			Y_input 		<= 0;
			Yn_NUM		<= 0;
			Yn_DEN		<= 0;
			DETECTION 	<= 0;
		end 
		else if (TIME > 274) begin
			Y_input 		<= Y;
			Yn_NUM 		<= CORRELATION_NUMERATOR;
			Yn_DEN 		<= CORRELATION_DENOMINATOR;
			DETECTION 	<= (Yn_NUM > Yn_DEN) & ~Y_input[29]; 
		end
		else begin
			DETECTION 	<= 0;
		end
	end	
endmodule
