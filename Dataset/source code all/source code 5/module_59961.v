`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module chris_pipelined (
		input  wire [7:0]  avs_s0_address,       
		input  wire        avs_s0_read,          
		output wire [31:0] avs_s0_readdata,      
		input  wire        avs_s0_write,         
		input  wire [31:0] avs_s0_writedata,     
		output wire        avs_s0_waitrequest,   
		input  wire        clock_clk,            
		input  wire        reset_reset,          
		output wire        ins_irq0_irq,         
		output wire [31:0] avm_m0_address,       
		output wire        avm_m0_read,          
		input  wire        avm_m0_waitrequest,   
		input  wire [31:0] avm_m0_readdata,      
		input  wire        avm_m0_readdatavalid, 
		output wire        avm_m0_write,         
		output wire [31:0] avm_m0_writedata,     
		output wire [7:0]  avm_m0_burstcount     
	);
	reg			reg_status_read;
   reg			reg_status_write;
	reg [31:0] 	reg_data_out;
	assign avs_s0_readdata = reg_data_out;
	assign avs_s0_waitrequest = reg_status_read || reg_status_write;
	wire [8:0] s_kernel_parameter;
	wire s_input_image_addr; 
	wire s_output_image_addr; 
	wire s_module_control; 
	wire s_module_status; 
	reg [31:0] reg_kernel[8:0];
	reg [31:0] reg_source_addr;
	reg [31:0] reg_destination_addr;
	reg [31:0] reg_control;
	reg [31:0] reg_status;
	assign s_kernel_parameter[0] = (avs_s0_address[3:0] == 4'b0000) & (avs_s0_write | avs_s0_read);
	assign s_kernel_parameter[1] = (avs_s0_address[3:0] == 4'b0001) & (avs_s0_write | avs_s0_read);
	assign s_kernel_parameter[2] = (avs_s0_address[3:0] == 4'b0010) & (avs_s0_write | avs_s0_read);
	assign s_kernel_parameter[3] = (avs_s0_address[3:0] == 4'b0011) & (avs_s0_write | avs_s0_read);
	assign s_kernel_parameter[4] = (avs_s0_address[3:0] == 4'b0100) & (avs_s0_write | avs_s0_read);
	assign s_kernel_parameter[5] = (avs_s0_address[3:0] == 4'b0101) & (avs_s0_write | avs_s0_read);
	assign s_kernel_parameter[6] = (avs_s0_address[3:0] == 4'b0110) & (avs_s0_write | avs_s0_read);
	assign s_kernel_parameter[7] = (avs_s0_address[3:0] == 4'b0111) & (avs_s0_write | avs_s0_read);
	assign s_kernel_parameter[8] = (avs_s0_address[3:0] == 4'b1000) & (avs_s0_write | avs_s0_read);
	assign s_input_image_addr = (avs_s0_address[3:0] == 4'b1001) & (avs_s0_write | avs_s0_read);
	assign s_output_image_addr= (avs_s0_address[3:0] == 4'b1010) & (avs_s0_write | avs_s0_read);
	assign s_module_control =  (avs_s0_address[3:0] == 4'b1011) & (avs_s0_write | avs_s0_read);
	assign s_module_status =  (avs_s0_address[3:0] == 4'b1100) & (avs_s0_write | avs_s0_read);
	always @(posedge clock_clk)
		if (reset_reset) begin
			reg_kernel[0] <= 32'h000;
			reg_kernel[1] <= 32'h000;
			reg_kernel[2] <= 32'h000;
			reg_kernel[3] <= 32'h000;
			reg_kernel[4] <= 32'h000;
			reg_kernel[5] <= 32'h000;
			reg_kernel[6] <= 32'h000;
			reg_kernel[7] <= 32'h000;
			reg_kernel[8] <= 32'h000;
			reg_source_addr <= 32'h0000;
			reg_destination_addr <= 32'h0000;
			reg_control <= 32'h0000;
			reg_status <= 32'h0000;	
			reg_status_write <= 1'b0;
	  end else if (!avs_s0_waitrequest && avs_s0_write) begin
			reg_status_write <= 1'b1;
			if (s_kernel_parameter[0]) begin
				reg_kernel[0] <= avs_s0_writedata;
			end
			if (s_kernel_parameter[1]) begin
				reg_kernel[1] <= avs_s0_writedata;
			end
			if (s_kernel_parameter[2]) begin
				reg_kernel[2] <= avs_s0_writedata;
			end
			if (s_kernel_parameter[3]) begin
				reg_kernel[3] <= avs_s0_writedata;
			end
			if (s_kernel_parameter[4]) begin
				reg_kernel[4] <= avs_s0_writedata;
			end
			if (s_kernel_parameter[5]) begin
				reg_kernel[5] <= avs_s0_writedata;
			end
			if (s_kernel_parameter[6]) begin
				reg_kernel[6] <= avs_s0_writedata;
			end
			if (s_kernel_parameter[7]) begin
				reg_kernel[7] <= avs_s0_writedata;
			end
			if (s_kernel_parameter[8]) begin
				reg_kernel[8] <= avs_s0_writedata;
			end
			if (s_input_image_addr) begin
				reg_source_addr <= avs_s0_writedata;
			end
			if (s_output_image_addr) begin
				reg_destination_addr <= avs_s0_writedata;
			end
			if (s_module_control) begin
				reg_control <= avs_s0_writedata;
			end
			if (s_module_status) begin
				reg_status <= avs_s0_writedata;
			end
	  end 
	 always @(posedge clock_clk) begin	
		if (reset_reset) begin
			reg_data_out <= 32'h0000;
			reg_status_read <= 1'b0;
		end else if (!avs_s0_waitrequest && avs_s0_read) begin
			reg_status_read <= 1'b1;
			if (s_kernel_parameter[0]) begin
				reg_data_out <= reg_kernel[0];
			end
			if (s_kernel_parameter[1]) begin
				reg_data_out <= reg_kernel[1];
			end
			if (s_kernel_parameter[2]) begin
				reg_data_out <= reg_kernel[2];
			end
			if (s_kernel_parameter[3]) begin
				reg_data_out <= reg_kernel[3];
			end
			if (s_kernel_parameter[4]) begin
				reg_data_out <= reg_kernel[4];
			end
			if (s_kernel_parameter[5]) begin
				reg_data_out <= reg_kernel[5];
			end
			if (s_kernel_parameter[6]) begin
				reg_data_out <= reg_kernel[6];
			end
			if (s_kernel_parameter[7]) begin
				reg_data_out <= reg_kernel[7];
			end
			if (s_kernel_parameter[8]) begin
				reg_data_out <= reg_kernel[8];
			end
			if (s_input_image_addr) begin
				reg_data_out <= reg_source_addr;
			end
			if (s_output_image_addr) begin
				reg_data_out <= reg_destination_addr;
			end
			if (s_module_control) begin
				reg_data_out <= reg_control;
			end
			if (s_module_status) begin
				reg_data_out <= reg_status;
			end
		end
	end
	always @(posedge clock_clk) begin
		if (reset_reset) begin
		end
	end
endmodule
