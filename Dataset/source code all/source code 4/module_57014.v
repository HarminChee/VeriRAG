`timescale 1ns/1ns
`timescale 1ns/1ns
module soft_clock
#(parameter
	C_SIPIF_DWIDTH = 32
)
(
	input                                   Bus2IP_Reset     ,
	input                                   Bus2IP_Clk       ,
	input                                   Bus2IP_WrCE      ,
	input      [0:C_SIPIF_DWIDTH-1]         Bus2IP_Data      ,
	input      [0:(C_SIPIF_DWIDTH/8)-1]     Bus2IP_BE        ,
	output                                  Clk2IP_Clk       ,
	output                                  Clk2Bus_WrAck    ,
	output                                  Clk2Bus_Error    ,
	output                                  Clk2Bus_ToutSup  
);
	localparam [0:3] CLOCK_ENABLE  = 4'b1010;
	localparam [0:3] CLOCK_DISABLE = 4'b0101;
	wire isc_enable_match  = (Bus2IP_Data[C_SIPIF_DWIDTH-4:C_SIPIF_DWIDTH-1] == CLOCK_ENABLE);
	wire isc_disable_match = (Bus2IP_Data[C_SIPIF_DWIDTH-4:C_SIPIF_DWIDTH-1] == CLOCK_DISABLE);
	wire isc_match    = isc_enable_match | isc_disable_match;
	wire isc_mismatch = ~(isc_enable_match | isc_disable_match);
	wire isc_be_match = (Bus2IP_BE[(C_SIPIF_DWIDTH/8)-1:(C_SIPIF_DWIDTH/8)-1] == 1'b1);
	reg isr_ce;
	always @(posedge Bus2IP_Clk or posedge Bus2IP_Reset) begin
		if (Bus2IP_Reset) begin 
			isr_ce <= 1'b1;
		end else begin 
			if (Bus2IP_WrCE && isc_be_match) begin
				isr_ce <= 
					isc_enable_match?  1'b1: 
					isc_disable_match? 1'b0: isr_ce;
			end
		end
	end
	reg isr_error;
	always @(posedge Bus2IP_Clk or posedge Bus2IP_Reset) begin
		if (Bus2IP_Reset) begin 
			isr_error <= 1'b0;
		end else begin 
			if (Bus2IP_WrCE) begin
				isr_error <= isc_mismatch? 1'b1: 1'b0;
			end
		end
	end
	assign Clk2IP_Clk = Bus2IP_Clk & isr_ce;
	assign Clk2Bus_WrAck   = isc_match & Bus2IP_WrCE & isc_be_match;
	assign Clk2Bus_Error   = isc_mismatch & Bus2IP_WrCE & isc_be_match;
	assign Clk2Bus_ToutSup = Bus2IP_Reset;
endmodule
