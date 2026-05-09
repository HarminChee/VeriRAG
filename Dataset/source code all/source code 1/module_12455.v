`timescale 1ns / 1ps
`timescale 1ns / 1ps
module align_monitor( 
		input clk357,
		input clk40,
		input rst,
		input align_en,
		input Q1,
		input Q2,
		output reg [6:0] delay_modifier,
		output reg delay_mod_strb,
		output reg [6:0] count1,		
		output reg [6:0] count2,		
		output reg [6:0] count3,		
		output reg monitor_strb
);
reg sample_trig;
reg sample_trig_a;
reg sample_trig_b;
reg [1:0] sample_state = 2'b00;
reg samp0;
reg samp1;
reg samp2;
reg samp3;
reg samples_rdy; 
reg samples_rdy_slow_a; 
reg samples_rdy_slow_b; 
(* equivalent_register_removal = "no", shreg_extract = "no" *) reg align_en_slow_a, align_en_slow_b;
always @(posedge clk357) begin
		sample_trig_a <= sample_trig;
		sample_trig_b <= sample_trig_a;
		if (sample_trig_b) begin
			case (sample_state)
			2'd0: begin
				samp0 <= Q1;
				samp1 <= samp1;
				samp2 <= samp2;
				samp3 <= samp3;
				sample_state <= 2'd1;
				samples_rdy <= samples_rdy;
				end
			2'd1: begin
				samp0 <= (samp0) ? samp0 : Q1;
				samp1 <= (samp0) ? Q1 : samp1;
				samp2 <= (samp0) ? Q2 : samp2;
				samp3 <= samp3;
				sample_state <= (samp0) ? 2'd2 : sample_state; 
				samples_rdy <= samples_rdy;
				end
			2'd2: begin
				samp0 <= samp0;
				samp1 <= samp1;
				samp2 <= samp2;
				samp3 <= Q1;
				sample_state <= 2'd3;	
				samples_rdy <= 1'b1;
				end
			2'd3: begin 
				samp0 <= samp0;
				samp1 <= samp1;
				samp2 <= samp2;
				samp3 <= samp3;
				sample_state <= sample_state;
				samples_rdy <= samples_rdy;
				end
			endcase
		end else begin
			samp0 <= samp0;
			samp1 <= samp1;
			samp2 <= samp2;
			samp3 <= samp3;
			sample_state <= 2'd0;
			samples_rdy <= 1'b0;
		end	
end 
reg samp1_a;
reg samp2_a;
reg samp3_a;
reg samp1_b;
reg samp2_b;
reg samp3_b;
parameter counter_bits = 7;
parameter n_samp = 7'd31;
parameter threshold_min = 7'd5;
parameter threshold_max = 7'd26;
reg [counter_bits-1:0] main_count;
reg [counter_bits-1:0] samp1_count;
reg [counter_bits-1:0] samp2_count;
reg [counter_bits-1:0] samp3_count;
reg [1:0] state40 = 2'b00;
always @(posedge clk40) begin
	align_en_slow_a <= align_en;
	align_en_slow_b <= align_en_slow_a;
	if (rst) begin
		sample_trig <= 0;
		delay_modifier <= 0;
		samp1_a <= 0;
		samp2_a <= 0;
		samp3_a <= 0;
		samp1_b <= 0;
		samp2_b <= 0;
		samp3_b <= 0;
		main_count <= 0;
		samp1_count <= 0;
		samp2_count <= 0;
		samp3_count <= 0;
		state40 <= 0;
		delay_mod_strb <= 0;
		monitor_strb <= 0;
		samples_rdy_slow_a <= 1'b0;
		samples_rdy_slow_b <= 1'b0;
		count1 <= 7'd0;
		count2 <= 7'd0;
		count3 <= 7'd0;
	end else begin
	 if (align_en_slow_b) begin
	 samples_rdy_slow_a <= samples_rdy;
	 samples_rdy_slow_b <= samples_rdy_slow_a;
		if (main_count < n_samp) begin
			case (state40)
			2'b00: begin
				sample_trig <= 1; 
				delay_modifier <= delay_modifier;
				samp1_a <= samp1_a;
				samp2_a <= samp2_a;
				samp3_a <= samp3_a;
				samp1_b <= samp1_b;
				samp2_b <= samp2_b;
				samp3_b <= samp3_b;
				main_count <= main_count;
				samp1_count <= samp1_count;
				samp2_count <= samp2_count;
				samp3_count <= samp3_count;
				state40 <= 2'b01;
				delay_mod_strb <= 0;
				monitor_strb <= 0;
				count1 <= count1;
				count2 <= count2;
				count3 <= count3;	
				end
			2'b01: begin
				if (samples_rdy_slow_b) begin
					samp1_a <= samp1;
					samp2_a <= samp2;
					samp3_a <= samp3;
					sample_trig <= 0;
					state40 <= 2'b10;
					delay_modifier <= delay_modifier;
					samp1_b <= samp1_b;
					samp2_b <= samp2_b;
					samp3_b <= samp3_b;
					main_count <= main_count;
					samp1_count <= samp1_count;
					samp2_count <= samp2_count;
					samp3_count <= samp3_count;
					delay_mod_strb <= delay_mod_strb;
					monitor_strb <= monitor_strb;
					count1 <= count1;
					count2 <= count2;
					count3 <= count3;	
				end else begin 
					samp1_a <= samp1_a;
					samp2_a <= samp2_a;
					samp3_a <= samp3_a;
					sample_trig <= sample_trig;
					state40 <= state40;
					delay_modifier <= delay_modifier;
					samp1_b <= samp1_b;
					samp2_b <= samp2_b;
					samp3_b <= samp3_b;
					main_count <= main_count;
					samp1_count <= samp1_count;
					samp2_count <= samp2_count;
					samp3_count <= samp3_count;
					delay_mod_strb <= delay_mod_strb;
					monitor_strb <= monitor_strb;
					count1 <= count1;
					count2 <= count2;
					count3 <= count3;	
					end 
				end
			2'b10: begin
				samp1_b <= samp1_a;
				samp2_b <= samp2_a;
				samp3_b <= samp3_a;
				state40 <= 2'b11;
				samp1_a <= samp1_a;
				samp2_a <= samp2_a;
				samp3_a <= samp3_a;
				sample_trig <= sample_trig;
				delay_modifier <= delay_modifier;
				main_count <= main_count;
				samp1_count <= samp1_count;
				samp2_count <= samp2_count;
				samp3_count <= samp3_count;
				delay_mod_strb <= delay_mod_strb;
				monitor_strb <= monitor_strb;
				count1 <= count1;
				count2 <= count2;
				count3 <= count3;	
				end
			2'b11: begin
				samp1_count <= samp1_count + samp1_b;
				samp2_count <= samp2_count + samp2_b;
				samp3_count <= samp3_count + samp3_b;
				main_count <= main_count + 1'b1;
				state40 <= 2'b00;
				sample_trig <= sample_trig;
				delay_modifier <= delay_modifier;
				samp1_a <= samp1_a;
				samp2_a <= samp2_a;
				samp3_a <= samp3_a;
				samp1_b <= samp1_b;
				samp2_b <= samp2_b;
				samp3_b <= samp3_b;
				delay_mod_strb <= delay_mod_strb;
				monitor_strb <= monitor_strb;
				count1 <= count1;
				count2 <= count2;
				count3 <= count3;	
				end
			endcase
		end else begin
				if ( (samp2_count < threshold_min) || (samp2_count > threshold_max) ) begin
					if (samp2_count > 16) begin
						if (delay_modifier != 7'b1000000) begin
							delay_modifier <= delay_modifier + 7'd001;
							delay_mod_strb <= 1;
						end
					end else begin
						if (delay_modifier != 7'b0111111) begin
							delay_modifier <= delay_modifier - 7'd001;
							delay_mod_strb <= 1;				
						end
					end 
				end
			count1 <= samp1_count;
			count2 <= samp2_count;
			count3 <= samp3_count;					
			monitor_strb <= 1;
			samp1_a <= samp1_a;
			samp2_a <= samp2_a;
			samp3_a <= samp3_a;
			sample_trig <= sample_trig;
			state40 <= state40;
			samp1_b <= samp1_b;
			samp2_b <= samp2_b;
			samp3_b <= samp3_b;
			main_count <= 5'd0;
			samp1_count <= 5'd0;
			samp2_count <= 5'd0;
			samp3_count <= 5'd0;
			end 
		end else begin 
			count1 <= count1;
			count2 <= count2;
			count3 <= count3;
			sample_trig <= 1'b0;
			delay_modifier <= delay_modifier;
			samp1_a <= 1'b0;
			samp2_a <= 1'b0;
			samp3_a <= 1'b0;
			samp1_b <= 1'b0;
			samp2_b <= 1'b0;
			samp3_b <= 1'b0;
			main_count <= 5'd0;
			samp1_count <= 5'd0;
			samp2_count <= 5'd0;
			samp3_count <= 5'd0;
			state40 <= 2'b00;
			delay_mod_strb <= 1'b0;
			monitor_strb <= 1'b0;
			samples_rdy_slow_a <= 1'b0;
			samples_rdy_slow_b <= 1'b0;
			end 
	end 
end 
endmodule
