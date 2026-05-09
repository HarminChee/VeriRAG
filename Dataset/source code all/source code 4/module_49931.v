`timescale 1ns / 1ps
`timescale 1ns / 1ps
module delayLinieBRAM_WP
	#(parameter WIDTH = 16,
				   BRAM_SIZE_W = 10
	)
	(
    input clk,
    input rst,
    input ce,
    input [WIDTH-1:0] din ,
    output[WIDTH-1:0] dout,
    input [BRAM_SIZE_W-1:0] h_size
    );
	reg [BRAM_SIZE_W-1:0] position = 0;
	wire [16:0] dina;
	wire [16:0] douta;
	always @(posedge clk)
	begin
		if ( ce == 1'b1)
		begin
			if (rst == 1'b1)
			begin
				position <= 0;
			end
			else
			begin
				position <= position+1;
				if (position == h_size-2)
				begin
					position <= 0;
				end
			end		
		end	
	end
	delayLineBRAM BRAM (
		.clka(clk), 
		.wea(1'b1), 
		.addra(position), 
		.dina(dina), 
		.douta(douta) 
	);
	assign dina[WIDTH-1:0]=din;
	assign dout = douta[WIDTH-1:0];
endmodule
