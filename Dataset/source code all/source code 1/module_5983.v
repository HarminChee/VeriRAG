module gradient(
	clk_proc,
	reset_n,
	in_fv,
	in_dv,
	in_data,	
	magnitude_fv,
	magnitude_dv,
	magnitude_data,
	angle_fv,
	angle_dv,
	angle_data,
	addr_rel_i,
	wr_i,
	datawr_i,
	rd_i,
	datard_o
);
parameter IN_SIZE = 8;
parameter MAGNITUDE_SIZE = 16;
parameter ANGLE_SIZE = 16;
parameter CLK_PROC_FREQ = 50000000;
parameter COEF_WIDTH = 9; 
parameter NORM_FACTOR = 8;
parameter DEFAULT_SCR = 32'd41;
parameter DEFAULT_TH  = 32'd50;
localparam TOKEN_SIZE = 9;
localparam N_KERNEL = 8;
input clk_proc; 
input reset_n;
input	in_fv;
input	in_dv;	
input addr_rel_i;
input [31:0] datawr_i; 
input wr_i;
input rd_i;
input [IN_SIZE-1:0] in_data;
output [31:0] datard_o;
output [MAGNITUDE_SIZE-1:0] magnitude_data; 
output [ANGLE_SIZE-1:0] angle_data; 
output magnitude_fv;
output magnitude_dv;
output angle_fv;
output angle_dv;
reg [31:0] datard_o, readdata_new;
reg [31:0] config_setup, config_setup_new;
reg [31:0] threshold, threshold_new;
reg [(IN_SIZE-1):0] row1[2:0], row2[2:0], row3[2:0];
reg [TOKEN_SIZE-1:0] token_d;
reg [((COEF_WIDTH + IN_SIZE)+1):0] q1, q2, q3, q4, s1, s2, m_max;
reg [$clog2(N_KERNEL)-1:0] q1_dir, q2_dir, q3_dir, q4_dir, s1_dir, s2_dir, d_max;
reg [(COEF_WIDTH + IN_SIZE - NORM_FACTOR):0] data_d;
reg [$clog2(N_KERNEL)-1:0] dir_d;
wire [(IN_SIZE-1):0]	row2_wire, row3_wire;
wire onoff_bit;
wire binarize_bit;
wire dv_s;
wire [((COEF_WIDTH + IN_SIZE)+1):0] matrix_out [N_KERNEL-1:0];
wire [TOKEN_SIZE-1:0] token_s;
wire signed [(COEF_WIDTH-1):0] sin_coef [N_KERNEL-1:0];
wire signed [(COEF_WIDTH-1):0] cos_coef [N_KERNEL-1:0];
integer i, j;
generate
always@(*)
	begin
		if (MAGNITUDE_SIZE != 16)
			$error("gradient.v: MAGNITUDE_SIZE different from 16 not supported yet!!!");
		if (ANGLE_SIZE != 16)	
			$error("gradient.v: ANGLE_SIZE different from 16 not supported yet!!!");
		if (IN_SIZE != 8)	
			$error("gradient.v: IN_SIZE different from 8 not supported yet!!!");	
	end	
endgenerate
assign onoff_bit = config_setup[0];
assign binarize_bit = config_setup[1];
assign dv_s = in_dv & onoff_bit; 
always@(posedge clk_proc or negedge reset_n)
	begin
		if (reset_n == 0)
			token_d <= 0;
		else
			if (dv_s | ~in_fv)
				begin
					token_d[0] <= in_fv;
					for(j=0; j<(TOKEN_SIZE-1); j=j+1)
						token_d[j+1] <= token_d[j];
				end
			else
				token_d <= token_d;
	end
assign token_s = (dv_s | ~in_fv) ? token_d : 1'b0; 	
always@(posedge clk_proc or negedge reset_n)
	begin
		if (reset_n == 0)
			for(i=0; i<3;i=i+1)
				begin
					row1[i] <= {IN_SIZE{1'b0}};
					row2[i] <= {IN_SIZE{1'b0}};
					row3[i] <= {IN_SIZE{1'b0}};
				end
		else
			if (token_s[0])
				begin
					for(i=1; i<3;i=i+1)
						begin
						row1[i] <= row1[i-1];
						row2[i] <= row2[i-1];
						row3[i] <= row3[i-1];
						end
					row1[0] <= in_data;
					row2[0] <= row2_wire;
					row3[0] <= row3_wire;
				end
	end
eshift_reg	eshift_reg_inst0(
		.clk(clk_proc),
		.clken(token_s[0]),
		.shiftin(row1[2]),
		.shiftout(row2_wire),
		.taps(),
		.aclr(),
		.res_config(config_setup[10:3])
		);
eshift_reg	eshift_reg_inst1(
		.clk(clk_proc),
		.clken(token_s[0]),
		.shiftin(row2[2]),
		.shiftout(row3_wire),
		.taps(),
		.aclr(),
		.res_config(config_setup[10:3])
		);
assign sin_coef[0] = 0;
assign sin_coef[1] = 97;
assign sin_coef[2] = 181;
assign sin_coef[3] = 236;
assign sin_coef[4] = 255;
assign sin_coef[5] = 236;
assign sin_coef[6] = 181;
assign sin_coef[7] = 97;
assign cos_coef[0] = 255;
assign cos_coef[1] = 236;
assign cos_coef[2] = 181;
assign cos_coef[3] = 97;
assign cos_coef[4] = 0;
assign cos_coef[5] = -97;
assign cos_coef[6] = -181;
assign cos_coef[7] = -236;
genvar index;
generate
for (index=0; index < N_KERNEL; index = index + 1)
	begin: matrix_prod_gen
	matrix_prod #(
		.DATA_WIDTH(IN_SIZE),
		.COEF_WIDTH(COEF_WIDTH) 
	) matrix_prod_inst(
	.clk_i(clk_proc),
	.reset_n_i(reset_n),
	.dv0_i(token_s[1]),
	.dv1_i(token_s[2]),
	.dv2_i(token_s[3]),
	.sclr_i(1'b0),
	.pix01_i(row1[1]), 
	.pix10_i(row2[0]), 
	.pix12_i(row2[2]), 
	.pix21_i(row3[1]), 
	.sin_i(sin_coef[index]),
	.cos_i(cos_coef[index]),
	.data_o(matrix_out[index])
 );
end
endgenerate
always@(posedge clk_proc)
	if(token_s[4])
		begin
			if (matrix_out[0] > matrix_out[1])
				begin
					q1 <= matrix_out[0];
					q1_dir <= 0;
				end
			else
				begin
					q1 <= matrix_out[1];
					q1_dir <= 1;
				end 
		end
always@(posedge clk_proc)
	if(token_s[4])
		begin
			if (matrix_out[2] > matrix_out[3])
				begin
					q2 <= matrix_out[2];
					q2_dir<= 2;
				end
			else
				begin
					q2 <= matrix_out[3];
					q2_dir <= 3;
				end 
		end
always@(posedge clk_proc)
	if(token_s[4])
		begin
			if (matrix_out[4] > matrix_out[5])
				begin
					q3 <= matrix_out[4];
					q3_dir<= 4;
				end
			else
				begin
					q3 <= matrix_out[5];
					q3_dir <= 5;
				end 
		end
always@(posedge clk_proc)
	if(token_s[4])
		begin
			if (matrix_out[6] > matrix_out[7])
				begin
					q4 <= matrix_out[6];
					q4_dir<= 6;
				end
			else
				begin
					q4 <= matrix_out[7];
					q4_dir <= 7;
				end 
		end
always@(posedge clk_proc)
	if (token_s[5]) 
		begin
			if (q1 > q2)
				begin
					s1 <= q1;
					s1_dir<= q1_dir;
				end
			else
				begin
					s1 <= q2;
					s1_dir <= q2_dir;
				end 
		end
always@(posedge clk_proc)
	if (token_s[5])
		begin
			if (q3 > q4)
				begin
					s2 <= q3;
					s2_dir <= q3_dir;
				end
			else
				begin
					s2 <= q4;
					s2_dir <= q4_dir;
				end 
		end
always@(posedge clk_proc or negedge reset_n)
	if (reset_n == 0)
		begin
			m_max <= 0;
			d_max <= 0;
		end
	else 
		begin
			if (token_s[6])
				begin
					if (s1 > s2)
						begin
							m_max <= s1;
							d_max <= s1_dir;
						end
					else
						begin
							m_max <= s2;
							d_max <= s2_dir;
						end 
				end
			end
always@(posedge clk_proc or negedge reset_n)
	if (reset_n == 0)
		data_d <= 0;
	else 
		begin
			dir_d <= d_max;
			if (token_s[7])
				if (m_max[((COEF_WIDTH + IN_SIZE)+1):0] > threshold[((COEF_WIDTH + IN_SIZE)+1):0])
					if(binarize_bit)
						data_d <= {(COEF_WIDTH + IN_SIZE - NORM_FACTOR){1'b1}};
					else
						data_d <= m_max[(COEF_WIDTH + IN_SIZE):NORM_FACTOR-1];
				else
					if(binarize_bit)
						data_d <= {(COEF_WIDTH + IN_SIZE - NORM_FACTOR){1'b0}};
					else
						data_d <= {(COEF_WIDTH + IN_SIZE - NORM_FACTOR){1'b0}};
		end		
assign magnitude_data = data_d;
assign angle_data  	  = dir_d;
assign magnitude_dv   = token_s[8];
assign angle_dv		  = token_s[8];
assign magnitude_fv = (token_d[8]) ? 1'b1 : 1'b0;
assign angle_fv = (token_d[8]) ? 1'b1 : 1'b0;
always @ (*)
	if (wr_i)
		case(addr_rel_i)
			1'd0: 
				begin
					config_setup_new = datawr_i;	
					threshold_new = threshold;
				end
			1'd1: 
				begin
					config_setup_new = config_setup;
					threshold_new = datawr_i;
				end
			default:
				begin
					config_setup_new = config_setup;
					threshold_new = threshold;
				end
		endcase
	else	
		begin
			config_setup_new = config_setup;
			threshold_new = threshold;
		end
always @ (*)
	if (rd_i)
		case(addr_rel_i)
			1'd0:	readdata_new = config_setup;
			1'd1:	readdata_new = threshold;
			default:
				readdata_new = datard_o;
		endcase
	else 
		readdata_new = datard_o;
always @ (posedge clk_proc or negedge reset_n)
	if (reset_n == 1'b0)
		begin
			config_setup	<= DEFAULT_SCR;
			threshold		<= DEFAULT_TH;
			datard_o		<= 32'b0;
		end
	else 
		begin
			config_setup	<= config_setup_new;
			threshold		<= threshold_new;
			datard_o		<= readdata_new;
		end
endmodule
