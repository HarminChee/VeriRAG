`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module chris_slave (
		input  wire [3:0]  avs_s0_address,     
		input  wire        avs_s0_read,        
		output wire [31:0] avs_s0_readdata,    
		input  wire        avs_s0_write,       
		input  wire [31:0] avs_s0_writedata,   
		output wire        avs_s0_waitrequest, 
		input  wire        clock_clk,          
		input  wire        reset_reset,        
		output wire        LEDR                
	);
	assign avs_s0_readdata = 32'b00000000000000000000000000000000;
   reg			Reg_Status_Read;
   reg			Reg_Status_Write;
   reg [31:0] 		data_in;
   reg [31:0] 		data_out;
	reg 				led_out;
   assign avs_s0_waitrequest = Reg_Status_Read || Reg_Status_Write;
	assign LEDR = led_out;
	wire [8:0] kernel_parameter;
	wire [2:0] image_paramete;
	assign kernel_parameter[0] = (avs_s0_address[3:0] == 4'b0000) & (avs_s0_write | avs_s0_read);
	assign kernel_parameter[1] = (avs_s0_address[3:0] == 4'b0001) & (avs_s0_write | avs_s0_read);
	assign kernel_parameter[2] = (avs_s0_address[3:0] == 4'b0010) & (avs_s0_write | avs_s0_read);
	assign kernel_parameter[3] = (avs_s0_address[3:0] == 4'b0011) & (avs_s0_write | avs_s0_read);
	assign kernel_parameter[4] = (avs_s0_address[3:0] == 4'b0100) & (avs_s0_write | avs_s0_read);
	assign kernel_parameter[5] = (avs_s0_address[3:0] == 4'b0101) & (avs_s0_write | avs_s0_read);
	assign kernel_parameter[6] = (avs_s0_address[3:0] == 4'b0110) & (avs_s0_write | avs_s0_read);
	assign kernel_parameter[7] = (avs_s0_address[3:0] == 4'b0111) & (avs_s0_write | avs_s0_read);
	assign kernel_parameter[8] = (avs_s0_address[3:0] == 4'b1000) & (avs_s0_write | avs_s0_read);
	assign image_paramete[0] = (avs_s0_address[3:0] == 4'b10001) & (avs_s0_write | avs_s0_read); 
	assign image_paramete[1] = (avs_s0_address[3:0] == 4'b10010) & (avs_s0_write | avs_s0_read); 
	assign image_paramete[2] = (avs_s0_address[3:0] == 4'b10011) & (avs_s0_write | avs_s0_read); 
	always @(posedge clock_clk)
	  if (reset_reset) begin
			data_in <= 32'b0;
			data_out <= 32'b0;
			Reg_Status_Write <= 1'b0;	
	  end else if (!avs_s0_waitrequest && avs_s0_write) begin
			Reg_Status_Write <= 1'b0;	
			led_out <= avs_s0_writedata[0];
			data_in <= avs_s0_writedata;
	  end else begin
			Reg_Status_Write <= 1'b0;	
	  end
   always @(posedge clock_clk)
	if (reset_reset) begin
		Reg_Status_Read <= 1'b0;	
	end else if (!avs_s0_waitrequest && avs_s0_read) begin
		Reg_Status_Read <= 1'b0;	
	end else begin
		Reg_Status_Read <= 1'b0;	
	end
endmodule
