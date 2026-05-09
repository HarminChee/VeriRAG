module convolution_core (
input clk,
input reset,
input [31:0] value0,
input [31:0] value1,
input [31:0] value2,
input [31:0] value3,
input [31:0] value4,
input [31:0] value5,
input [31:0] value6,
input [31:0] value7,
input [31:0] value8,
input caculating_start,
output reg caculating_done,
input res_done,
output reg [31:0] ret
);
	parameter kernel0 = 8'd1;
	parameter kernel1 = 8'd2;
	parameter kernel2 = 8'd3;
	parameter kernel3 = 8'd4;
	parameter kernel4 = 8'd5;
	parameter kernel5 = 8'd6;
	parameter kernel6 = 8'd7;
	parameter kernel7 = 8'd8;
	parameter kernel8 = 8'd9;
	reg [31:0] Add0,Add1,Add2,Add3,Add4,Add5,Add6,Add7,Add8;
	reg [1:0] status;
	reg [31:0] reg_31, reg_32, reg_33;
	always @(posedge clk) begin
		if (reset) begin
			status <= 2'b00;
			ret <= 32'hffffffff;
			caculating_done <= 1'b0;
		end else if (status == 2'b00 && caculating_start) begin
			Add0 <= value0 * kernel0;
			Add1 <= value1 * kernel1;
			Add2 <= value2 * kernel2;
			Add3 <= value3 * kernel3;
			Add4 <= value4 * kernel4;
			Add5 <= value5 * kernel5;
			Add6 <= value6 * kernel6;
			Add7 <= value7 * kernel7;
			Add8 <= value8 * kernel8;
			status <= 1'b01;
		end else if (status == 2'b01 && caculating_start) begin
			reg_31 <= Add0+Add1+Add2;
			reg_32 <= Add3+Add4+Add5;
			reg_33 <= Add6+Add7+Add8;
			status <= 2'b10;
		end else if (status == 2'b10 && caculating_start) begin
			ret <= reg_31 + reg_32 + reg_33;
			status <= 2'b11; 
			caculating_done <= 1'b1;
		end else  if (caculating_start == 1'b0)begin
			caculating_done <= 1'b0;
			status <= 2'b00;
		end
	end 
endmodule
