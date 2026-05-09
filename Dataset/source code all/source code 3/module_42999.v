module norm(
	clk_proc,
	reset_n,
	in_fv,
	in_dv,
	in_data,
	out_fv,
	out_dv,
	out_data,
	addr_rel_i,
	wr_i,
	datawr_i,
	rd_i,
	datard_o
);
parameter IN_SIZE = 16;
parameter OUT_SIZE = 16;
parameter CLK_PROC_FREQ = 50000000;
localparam NWORDS = 8;
localparam NPIPELINE = 10;
input clk_proc;
input reset_n; 
input in_fv;
input in_dv;
input [IN_SIZE-1:0] in_data;
output	out_fv;
output	out_dv;
output	[OUT_SIZE-1:0] out_data;
input	addr_rel_i;
input	wr_i;
input	[31:0] datawr_i;
input	rd_i;
output	[31:0] datard_o;
wire dv_s;
wire acc_clear;
wire [23:0] shiftout_ext;
wire [IN_SIZE-1:0] shiftout;
reg [5:0]  counter;
reg [18:0] acc;
reg [18:0] acc_d;
reg fsm, fsm_new;
assign dv_s = (in_fv & in_dv) | (out_fv & ~in_fv);
altshift_taps	 #(
	.lpm_hint("RAM_BLOCK_TYPE=AUTO"),
	.lpm_type("altshift_taps"),
	.number_of_taps(1),
	.tap_distance(NWORDS),
	.width(IN_SIZE)
) altshift_taps_inst_0 (
			.clock (clk_proc),
			.clken (dv_s),
			.shiftin (in_data),
			.shiftout (shiftout),
			.taps ()
			,
			.aclr ()
			);
assign acc_clear = (counter == 5'd7);
always@(posedge clk_proc or negedge reset_n)
	if (reset_n == 1'b0)
		counter <= 0;
	else
		if (acc_clear | ~in_fv)
			counter <= 0;
		else
			if(dv_s)
				counter <= counter + 1'b1;
			else
				counter <= counter;
always@(posedge clk_proc or negedge reset_n)
	begin
		if (reset_n == 1'b0)
			acc <= 0;
		else
			if(acc_clear)
				acc <= 0;
			else
				if (dv_s)
					acc <= acc + in_data;
				else
					acc <= acc;
	end
wire shift_dv;	
reg [7:0] acc_token;
always@(posedge clk_proc or negedge reset_n)
	begin
		if(reset_n == 1'b0)
			acc_token <= {8{1'b0}};
		else
			if(dv_s)
				acc_token[7:0] <= {acc_token[6:0], in_dv};	
			else
				acc_token <= acc_token;
	end
assign shift_dv = acc_token[7]; 		
always@(posedge clk_proc or negedge reset_n)
	begin
		if (reset_n == 1'b0)
			acc_d <= 0;
		else
			if(acc_clear)
				if (acc)
					acc_d <= acc + in_data;
				else
					acc_d <= 1;
			else
				acc_d <= acc_d;
	end	
assign shiftout_ext = {shiftout, 8'd0};	
reg [NPIPELINE-1:0] div_token;
always@(posedge clk_proc or negedge reset_n)
	begin
		if(reset_n == 1'b0)
			div_token <= {NPIPELINE{1'b0}};
		else
			if (dv_s)
				div_token[NPIPELINE-1:0] <= {div_token[NPIPELINE-2:0], shift_dv};	
			else
				div_token <= div_token; 
	end
assign out_dv = div_token[NPIPELINE-1] & dv_s; 	
wire [23:0] out_div;
lpm_divide #(
	.lpm_type("lpm_divide"),
	.lpm_widthn(24),
	.lpm_widthd(19),
	.lpm_nrepresentation("UNSIGNED"),
	.lpm_drepresentation("UNSIGNED"),
	.lpm_pipeline(NPIPELINE),
	.lpm_hint("LPM_REMAINDERPOSITIVE=TRUE")
) lpm_divide_inst ( 
	.quotient(out_div), 
	.remain(), 
	.numer(shiftout_ext), 
	.denom(acc_d), 
	.clock(clk_proc), 
	.clken((shift_dv | div_token[NPIPELINE-1]) & dv_s), 
	.aclr(1'b0)
);
assign out_data = {8'd0, out_div[7:0]- out_div[8]} ;
localparam FVTOKEN = NPIPELINE+8;
reg [FVTOKEN-1:0] fv_token;
always@(posedge clk_proc or negedge reset_n)
	begin
		if(reset_n == 1'b0)
			fv_token <= {FVTOKEN{1'b0}};
		else
			if (dv_s)
				fv_token <= {fv_token[FVTOKEN-2:0], in_fv};	
			else
				fv_token <= fv_token;
	end
assign out_fv = fv_token[FVTOKEN-1]; 
endmodule
