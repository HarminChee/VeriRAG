`timescale 1ns / 1ps
`timescale 1ns / 1ps
module coupled_data_processing(
    input clk,
	 input rst,
	 input slow_clk,
	 input [12:0] p2_sigma_in,
    input [12:0] p2_delta_in,
    input [12:0] p3_sigma_in,
    input [12:0] p3_delta_in,
	 input store_strb,
	 input p2_bunch_strb,
	 input p3_bunch_strb,
	 input feedbck_en,
	 input delay_loop_en,
	 input const_dac_en,
	 input [12:0] const_dac_out,
	 input [6:0]  p2_lut_dinb,
	 input [14:0] p2_lut_addrb,
	 input p2_lut_web,
	 input [6:0]  p3_lut_dinb,
	 input [14:0] p3_lut_addrb,
	 input p3_lut_web,
	 input [12:0] b2_offset,
	 input [12:0] b3_offset,
	 input [6:0] fir_k1,
	 output [6:0] p2_lut_doutb,
	 output [6:0] p3_lut_doutb,
    output reg [12:0] amp_drive,
	 output reg dac_en
    );
reg [12:0] b2_offset_a, b2_offset_b, b3_offset_a, b3_offset_b;
reg [12:0] b2_offset_c, b2_offset_d, b3_offset_c, b3_offset_d;
reg [6:0] fir_k1_a, fir_k1_b;
always @(posedge clk or posedge rst) begin
	if (rst) begin
		 b2_offset_a <= 0;
		 b3_offset_a <= 0;
		 b2_offset_b <= 0;
		 b3_offset_b <= 0;
		 b2_offset_c <= 0;
		 b3_offset_c <= 0;
		 b2_offset_d <= 0;
		 b3_offset_d <= 0;
		 fir_k1_a	 <= 0;
		 fir_k1_b	 <= 0;
	end else begin
		 b2_offset_a <= b2_offset;
		 b3_offset_a <= b3_offset;
		 b2_offset_b <= b2_offset_a;
		 b3_offset_b <= b3_offset_a;
		 b2_offset_c <= b2_offset_b;
		 b3_offset_c <= b3_offset_b;
		 b2_offset_d <= b2_offset_c;
		 b3_offset_d <= b3_offset_c;
		 fir_k1_a	 <= fir_k1;
		 fir_k1_b	 <= fir_k1_a;
	end
end
wire zero_strb;
reg p3_bunch_strb_a, p3_bunch_strb_b, p3_bunch_strb_c, p3_bunch_strb_d, p3_bunch_strb_e, p3_bunch_strb_f, p3_bunch_strb_g, p3_bunch_strb_h;
always @(posedge clk or posedge rst) begin
	if (rst) begin
		p3_bunch_strb_a <= 0;
		p3_bunch_strb_b <= 0;
		p3_bunch_strb_c <= 0;
		p3_bunch_strb_d <= 0;
		p3_bunch_strb_e <= 0;
		p3_bunch_strb_f <= 0;
		p3_bunch_strb_g <= 0;
		p3_bunch_strb_h <= 0;
	end else begin
		p3_bunch_strb_a <= p3_bunch_strb | zero_strb;
		p3_bunch_strb_b <= p3_bunch_strb_a;
		p3_bunch_strb_c <= p3_bunch_strb_b;
		p3_bunch_strb_d <= p3_bunch_strb_c;
		p3_bunch_strb_e <= p3_bunch_strb_d;
		p3_bunch_strb_f <= p3_bunch_strb_e;
		p3_bunch_strb_g <= p3_bunch_strb_f;
		p3_bunch_strb_h <= p3_bunch_strb_g;
	end
end
reg p2_bunch_strb_a, p2_bunch_strb_b, p2_bunch_strb_c, p2_bunch_strb_d, p2_bunch_strb_e, p2_bunch_strb_f, p2_bunch_strb_g, p2_bunch_strb_h;
always @(posedge clk or posedge rst) begin
	if (rst) begin
		p2_bunch_strb_a <= 0;
		p2_bunch_strb_b <= 0;
		p2_bunch_strb_c <= 0;
		p2_bunch_strb_d <= 0;
		p2_bunch_strb_e <= 0;
		p2_bunch_strb_f <= 0;
		p2_bunch_strb_g <= 0;
		p2_bunch_strb_h <= 0;
	end else begin
		p2_bunch_strb_a <= p2_bunch_strb | zero_strb;
		p2_bunch_strb_b <= p2_bunch_strb_a;
		p2_bunch_strb_c <= p2_bunch_strb_b;
		p2_bunch_strb_d <= p2_bunch_strb_c;
		p2_bunch_strb_e <= p2_bunch_strb_d;
		p2_bunch_strb_f <= p2_bunch_strb_e;
		p2_bunch_strb_g <= p2_bunch_strb_f;
		p2_bunch_strb_h <= p2_bunch_strb_g;
	end
end
reg store_strb_a, store_strb_b;
always@(posedge clk or posedge rst) begin
	if (rst) begin
		store_strb_a <= 0;
		store_strb_b <= 0;
	end else begin
		store_strb_a <= store_strb;
		store_strb_b <= store_strb_a;
	end
end
assign zero_strb = ~store_strb_a & store_strb_b;
reg [1:0] bunch_count;
always @(posedge clk or posedge rst) begin
	if (rst) begin
		bunch_count <= 0;
	end else begin
		if (zero_strb) begin
			bunch_count <= 0;
		end else begin
			if (p3_bunch_strb_g & store_strb) begin
				bunch_count <= bunch_count + 1;
			end
		end
	end
end
wire [27:0] p2_lut_temp;
wire [20:0] p2_lut_out;
assign p2_lut_out = p2_lut_temp[20:0];
ram_13x28_15x7 p2_lut (
	.clka(clk),
	.dina(), 
	.addra(p2_sigma_in), 
	.wea(1'b0), 
	.douta(p2_lut_temp), 
	.clkb(slow_clk),
	.dinb(p2_lut_dinb), 
	.addrb(p2_lut_addrb), 
	.web(p2_lut_web), 
	.doutb(p2_lut_doutb)); 
reg  [20:0] p2_lut_reg;
always @(posedge clk) p2_lut_reg <= p2_lut_out;
reg [12:0] p2_delta_a, p2_delta_b;
always @(posedge clk or posedge rst) begin
	if (rst) begin
		p2_delta_a <= 0;
		p2_delta_b <= 0;
	end else begin
		p2_delta_a <= p2_delta_in;
		p2_delta_b <= p2_delta_a;
	end
end
wire [47:0] p2_mac_out;
FB_MULT_ADD p2_mult_add (
    .A_IN(p2_lut_reg), 
    .B_IN(p2_delta_b), 
    .CEMULTCARRYIN_IN(1'b0), 
    .CLK_IN(clk), 
	 .C_IN(48'b0),
    .P_OUT(p2_mac_out)
   );
reg  [47:0] p2_store_reg;	
always @(posedge clk or posedge rst) begin
	if (rst) begin
		p2_store_reg <= 0;
	end else begin
		if (zero_strb) begin
			p2_store_reg <= 48'b0;
		end else begin
			if (p2_bunch_strb_e & store_strb) begin
				p2_store_reg <= p2_mac_out;
			end
		end
	end
end
wire [27:0] p3_lut_temp;
wire [20:0] p3_lut_out;
assign p3_lut_out = p3_lut_temp[20:0];
ram_13x28_15x7 p3_lut (
	.clka(clk),
	.dina(), 
	.addra(p3_sigma_in), 
	.wea(1'b0), 
	.douta(p3_lut_temp), 
	.clkb(slow_clk),
	.dinb(p3_lut_dinb), 
	.addrb(p3_lut_addrb), 
	.web(p3_lut_web), 
	.doutb(p3_lut_doutb)); 
reg  [20:0] p3_lut_reg;
always @(posedge clk) p3_lut_reg <= p3_lut_out;
reg [12:0] p3_delta_a, p3_delta_b;
always @(posedge clk or posedge rst) begin
	if (rst) begin
		p3_delta_a <= 0;
		p3_delta_b <= 0;
	end else begin
		p3_delta_a <= p3_delta_in;
		p3_delta_b <= p3_delta_a;
	end
end
wire [47:0] delay_loop_out;
wire [47:0] fb_mac_out;
FB_MULT_ADD feedback_mult_add (
    .A_IN(p3_lut_reg), 
    .B_IN(p3_delta_b), 
    .CEMULTCARRYIN_IN(1'b0), 
    .CLK_IN(clk), 
	 .C_IN(delay_loop_out),
    .P_OUT(fb_mac_out)
   );
wire [47:0] fir_mult_out;
FB_MULT_ADD fir_mult_add (
    .A_IN(p3_lut_reg), 
    .B_IN(p3_delta_b), 
    .CEMULTCARRYIN_IN(1'b0), 
    .CLK_IN(clk), 
	 .C_IN(p2_store_reg),
    .P_OUT(fir_mult_out)
   );
reg [47:0] delay_loop;
reg [41:0] fir_tap1;
always @(posedge clk or posedge rst) begin
	if (rst) begin
		delay_loop <= 0;
		fir_tap1   <= 0;
	end else begin
		if (zero_strb) begin
			delay_loop <= 48'b0;
			fir_tap1   <= 29'b0;
		end else begin
			if (p3_bunch_strb_e & store_strb) begin
				if (delay_loop_en) begin
					delay_loop <= fb_mac_out;
				end else begin
					delay_loop <= 48'b0;
				end
				fir_tap1 <= fir_mult_out[47:6];
			end
		end
	end
end
wire [48:0] fir_scale_mult_out;
FIR_SCALE fir_scaling_multiplier (
	.clk(clk),
	.a(fir_tap1), 
	.b(fir_k1_b), 
	.p(fir_scale_mult_out)); 
reg [47:0] delay_loop_banana;
always @(posedge clk or posedge rst) begin
	if (rst) begin
		delay_loop_banana   <= 0;
	end else begin
		case (bunch_count)
			2'd0: begin
				if (b2_offset_b[12]) begin
					delay_loop_banana <= {23'd8388607, b2_offset_d, 12'b0};
				end else begin
					delay_loop_banana <= {23'd0, b2_offset_d, 12'b0};
				end
			end
			2'd1:	begin
				if (b3_offset_b[12]) begin
					delay_loop_banana <= {23'd8388607, b3_offset_d, 12'b0};
				end else begin
					delay_loop_banana <= {23'd0, b3_offset_d, 12'b0};
				end
			end
		endcase
	end
end
wire [47:0] fir_scaled_sat;
assign fir_scaled_sat = (fir_scale_mult_out[48] & ~fir_scale_mult_out[47]) ? {1'b1, 47'b0} :
								(~fir_scale_mult_out[48] & fir_scale_mult_out[47]) ? {1'b0, 47'b1} :
								fir_scale_mult_out[47:0];
wire [47:0] fir_plus_banana;
ADD_48_48 add_fir_banana (
    .AB_IN(fir_scaled_sat), 
    .CEA2_IN(1'b1), 
    .CEB2_IN(1'b1), 
    .CEMULTCARRYIN_IN(0), 
    .CLK_IN(clk), 
    .C_IN(delay_loop_banana), 
    .P_OUT(fir_plus_banana)
    );
wire [47:0] delay_loop_corr;
ADD_48_48 add_delay_loop (
    .AB_IN(delay_loop), 
    .CEA2_IN(1'b1), 
    .CEB2_IN(1'b1), 
    .CEMULTCARRYIN_IN(0), 
    .CLK_IN(clk), 
    .C_IN(fir_plus_banana), 
    .P_OUT(delay_loop_corr)
    );
ADD_48_48 add_p2_cont (
    .AB_IN(p2_store_reg), 
    .CEA2_IN(1'b1), 
    .CEB2_IN(1'b1), 
    .CEMULTCARRYIN_IN(0), 
    .CLK_IN(clk), 
    .C_IN(delay_loop_corr), 
    .P_OUT(delay_loop_out)
    );
wire [35:0] fbck_sgnl1;
assign fbck_sgnl1 = fb_mac_out[47:12];
reg [12:0] fbck_sgnl2;
always @(fbck_sgnl1) begin
	fbck_sgnl2 = 0; 
	if (fbck_sgnl1[35]) begin
		if ( (~fbck_sgnl1[34:12]) == 23'b0) begin
			fbck_sgnl2 = fbck_sgnl1[12:0];
		end else begin
			fbck_sgnl2 = 13'b1000000000000;
		end
	end else begin
		if ( (fbck_sgnl1[34:12]) == 23'b0) begin
			fbck_sgnl2 = fbck_sgnl1[12:0];
		end else begin
			fbck_sgnl2 = 13'b0111111111111;
		end	
	end
end
wire [12:0] fbck_sgnl3, fbck_sgnl4;
assign fbck_sgnl3 = const_dac_en ? const_dac_out : fbck_sgnl2;
wire zero_output;
assign zero_output = (~store_strb | ~feedbck_en);
assign fbck_sgnl4 = zero_output ? 13'b0 : fbck_sgnl3;
always @(posedge clk) if (p3_bunch_strb_e) amp_drive <= fbck_sgnl4;
always @(posedge clk) dac_en <= p3_bunch_strb_f | p3_bunch_strb_g;
endmodule
