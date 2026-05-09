`define SNIFFER			3'b000
`define TAGSIM_LISTEN	3'b001
`define TAGSIM_MOD		3'b010
`define READER_LISTEN	3'b011
`define READER_MOD		3'b100
`define SNIFFER			3'b000
`define TAGSIM_LISTEN	3'b001
`define TAGSIM_MOD		3'b010
`define READER_LISTEN	3'b011
`define READER_MOD		3'b100
module hi_iso14443a(
    pck0, ck_1356meg, ck_1356megb,
    pwr_lo, pwr_hi, pwr_oe1, pwr_oe2, pwr_oe3, pwr_oe4,
    adc_d, adc_clk,
    ssp_frame, ssp_din, ssp_dout, ssp_clk,
    cross_hi, cross_lo,
    dbg,
    mod_type
);
    input pck0, ck_1356meg, ck_1356megb;
    output pwr_lo, pwr_hi, pwr_oe1, pwr_oe2, pwr_oe3, pwr_oe4;
    input [7:0] adc_d;
    output adc_clk;
    input ssp_dout;
    output ssp_frame, ssp_din, ssp_clk;
    input cross_hi, cross_lo;
    output dbg;
    input [2:0] mod_type;
wire adc_clk = ck_1356meg;
reg after_hysteresis;
reg [11:0] has_been_low_for;
always @(negedge adc_clk)
begin
	if(adc_d >= 16) after_hysteresis <= 1'b1;			
    else if(adc_d < 8) after_hysteresis <= 1'b0;  		
	if(adc_d >= 192)
    begin
        has_been_low_for <= 12'd0;
    end
    else
    begin
        if(has_been_low_for == 12'd4095)
        begin
            has_been_low_for <= 12'd0;
            after_hysteresis <= 1'b1;
        end
        else
		begin
            has_been_low_for <= has_been_low_for + 1;
		end	
    end
end
reg deep_modulation;
reg [2:0] deep_counter;
reg [8:0] saw_deep_modulation;
always @(negedge adc_clk)
begin
	if(~(| adc_d[7:0]))									
	begin
		if(deep_counter == 3'd7)						
		begin
			deep_modulation <= 1'b1;
			saw_deep_modulation <= 8'd0;
		end
		else
			deep_counter <= deep_counter + 1;
	end
	else							
	begin
		deep_counter <= 3'd0;
		if(saw_deep_modulation == 8'd255)				
			deep_modulation <= 1'b0;
		else
			saw_deep_modulation <= saw_deep_modulation + 1;
	end
end
reg [7:0] input_prev_4, input_prev_3, input_prev_2, input_prev_1;
always @(negedge adc_clk)
begin
	input_prev_4 <= input_prev_3;
	input_prev_3 <= input_prev_2;
	input_prev_2 <= input_prev_1;
	input_prev_1 <= adc_d;
end	
wire [8:0] input_prev_4_times_2 = input_prev_4 << 1;
wire [8:0] adc_d_times_2 		= adc_d << 1;
wire [9:0] tmp1 = input_prev_4_times_2 + input_prev_3;
wire [9:0] tmp2 = adc_d_times_2 + input_prev_1;
wire signed [10:0] adc_d_filtered = {1'b0, tmp1} - {1'b0, tmp2};
reg pre_after_hysteresis; 
reg [3:0] reader_falling_edge_time;
reg [6:0] negedge_cnt;
always @(negedge adc_clk)
begin
	pre_after_hysteresis <= after_hysteresis;
	if (pre_after_hysteresis && ~after_hysteresis)
	begin
		reader_falling_edge_time[3:0] <= negedge_cnt[3:0];
	end
	if (negedge_cnt[3:0] == 4'd13 && (mod_type == `SNIFFER || mod_type == `TAGSIM_LISTEN) && deep_modulation)
	begin
		if (reader_falling_edge_time == 4'd1) 			
		begin
			negedge_cnt <= negedge_cnt + 2;				
		end	
		else if (reader_falling_edge_time == 4'd0)		
		begin
			negedge_cnt <= negedge_cnt;					
		end
		else
		begin
			negedge_cnt <= negedge_cnt + 1;				
		end
		reader_falling_edge_time[3:0] <= 4'd8;			
	end
	else if (negedge_cnt == 7'd127)						
	begin
		negedge_cnt <= 0;
	end	
	else
	begin
		negedge_cnt <= negedge_cnt + 1;
	end
end	
reg [3:0] mod_detect_reset_time;
always @(negedge adc_clk)
begin
	if (mod_type == `READER_LISTEN) 
	begin
		mod_detect_reset_time <= 4'd4;
	end
	else
	if (mod_type == `SNIFFER)
	begin
		if (~pre_after_hysteresis && after_hysteresis && deep_modulation)
		begin
			mod_detect_reset_time <= negedge_cnt[3:0] - 4'd3;
		end
	end
end
reg signed [10:0] rx_mod_falling_edge_max;
reg signed [10:0] rx_mod_rising_edge_max;
reg curbit;
`define EDGE_DETECT_THRESHOLD	5
always @(negedge adc_clk)
begin
	if(negedge_cnt[3:0] == mod_detect_reset_time)
	begin
		if ((rx_mod_falling_edge_max > `EDGE_DETECT_THRESHOLD) && (rx_mod_rising_edge_max < -`EDGE_DETECT_THRESHOLD))
				curbit <= 1'b1;	
			else
				curbit <= 1'b0;	
		rx_mod_rising_edge_max <= 0;
		rx_mod_falling_edge_max <= 0;
	end
	else											
	begin
		if (adc_d_filtered > 0)
		begin
			if (adc_d_filtered > rx_mod_falling_edge_max)
				rx_mod_falling_edge_max <= adc_d_filtered;
		end
		else
		begin
			if (adc_d_filtered < rx_mod_rising_edge_max)
				rx_mod_rising_edge_max <= adc_d_filtered;
		end
	end
end
reg [3:0] reader_data;
reg [3:0] tag_data;
always @(negedge adc_clk)
begin
    if(negedge_cnt[3:0] == 4'd0)
	begin
        reader_data[3:0] <= {reader_data[2:0], after_hysteresis};
		tag_data[3:0] <= {tag_data[2:0], curbit};
	end
end	
reg [31:0] mod_sig_buf;
reg [4:0] mod_sig_ptr;
reg mod_sig;
always @(negedge adc_clk)
begin
	if(negedge_cnt[3:0] == 4'd0) 	
	begin
		mod_sig_buf[31:2] <= mod_sig_buf[30:1];  			
		if (~ssp_dout && ~mod_sig_buf[1])
			mod_sig_buf[1] <= 1'b0;							
		else
			mod_sig_buf[1] <= mod_sig_buf[0];
		mod_sig_buf[0] <= ssp_dout;							
		mod_sig = mod_sig_buf[mod_sig_ptr];					
	end
end
reg [10:0] fdt_counter;
reg fdt_indicator, fdt_elapsed;
reg [3:0] mod_sig_flip;
reg [3:0] sub_carrier_cnt;
`define FDT_COUNT 11'd1128
`define FDT_INDICATOR_COUNT 11'd535
assign fdt_reset = ~after_hysteresis && mod_type == `TAGSIM_LISTEN;
always @(negedge adc_clk)
begin
	if (fdt_reset)
	begin
		fdt_counter <= 11'd0;
		fdt_elapsed <= 1'b0;
		fdt_indicator <= 1'b0;
	end	
	else
	begin
		if(fdt_counter == `FDT_COUNT)
		begin						
			if(~fdt_elapsed)							
			begin
				mod_sig_flip <= negedge_cnt[3:0];		
				sub_carrier_cnt <= 4'd0;				
				fdt_elapsed <= 1'b1;
			end
			else
			begin
				sub_carrier_cnt <= sub_carrier_cnt + 1;
			end	
		end	
		else
		begin
			fdt_counter <= fdt_counter + 1;
		end
	end
	if(fdt_counter == `FDT_INDICATOR_COUNT) fdt_indicator <= 1'b1;
end
reg mod_sig_coil;
always @(negedge adc_clk)
begin
	if (mod_type == `TAGSIM_MOD)			 
	begin
		if(fdt_counter == `FDT_COUNT)
		begin
			if(fdt_elapsed)
			begin
				if(negedge_cnt[3:0] == mod_sig_flip) mod_sig_coil <= mod_sig;
			end
			else
			begin
				mod_sig_coil <= mod_sig;	
			end
		end
	end
	else 									
	begin
		mod_sig_coil <= ssp_dout;
	end	
end
reg temp_buffer_reset;
always @(negedge adc_clk)
begin
	if(fdt_reset)
	begin
		mod_sig_ptr <= 5'd0;
		temp_buffer_reset = 1'b0;
	end	
	else
	begin
		if(fdt_counter == `FDT_COUNT && ~fdt_elapsed)							
			if(~(| mod_sig_ptr[4:0])) 
				mod_sig_ptr <= 5'd8;  											
			else 
				temp_buffer_reset = 1'b1; 										
		if(negedge_cnt[3:0] == 4'd0) 											
		begin
			if((ssp_dout || (| mod_sig_ptr[4:0])) && ~fdt_elapsed)				
				if (mod_sig_ptr == 5'd31) 
					mod_sig_ptr <= 5'd0;										
				else 
					mod_sig_ptr <= mod_sig_ptr + 1;								
			else if(fdt_elapsed && ~temp_buffer_reset)							
			begin
				if(ssp_dout) 
					temp_buffer_reset = 1'b1;							
				if(mod_sig_ptr == 5'd1) 
					mod_sig_ptr <= 5'd8;										
				else 
					mod_sig_ptr <= mod_sig_ptr - 1;								
			end
		end
	end
end
reg [7:0] to_arm;
always @(negedge adc_clk)
begin
	if (negedge_cnt[5:0] == 6'd63)							
	begin
		if (mod_type == `SNIFFER)
		begin
			if(deep_modulation) 							
			begin
				to_arm <= {reader_data[3:0], 4'b0000};		
			end
			else
			begin
				to_arm <= {reader_data[3:0], tag_data[3:0]};
			end			
		end
		else
		begin
			to_arm[7:0] <= {mod_sig_ptr[4:0], mod_sig_flip[3:1]}; 
		end
	end	
	if(negedge_cnt[2:0] == 3'b000 && mod_type == `SNIFFER)	
	begin
		if(negedge_cnt[5:0] != 6'd0)
		begin
			to_arm[7:1] <= to_arm[6:0];
		end
	end
	if(negedge_cnt[3:0] == 4'b0000 && mod_type != `SNIFFER)
	begin
		if(negedge_cnt[6:0] != 7'd0)
		begin
			to_arm[7:1] <= to_arm[6:0];
		end
	end
end
reg ssp_clk;
reg ssp_frame;
always @(negedge adc_clk)
begin
	if(mod_type == `SNIFFER)
	begin
		if(negedge_cnt[2:0] == 3'd0)
			ssp_clk <= 1'b1;
		if(negedge_cnt[2:0] == 3'd4)
			ssp_clk <= 1'b0;
		if(negedge_cnt[5:0] == 6'd0)	
			ssp_frame <= 1'b1;
		if(negedge_cnt[5:0] == 6'd8)	
			ssp_frame <= 1'b0;
	end
	else
	begin
		if(negedge_cnt[3:0] == 4'd0)
			ssp_clk <= 1'b1;
		if(negedge_cnt[3:0] == 4'd8) 
			ssp_clk <= 1'b0;
		if(negedge_cnt[6:0] == 7'd7)	
			ssp_frame <= 1'b1;
		if(negedge_cnt[6:0] == 7'd23)
			ssp_frame <= 1'b0;
	end	
end
reg bit_to_arm;
reg sendbit;
always @(negedge adc_clk)
begin
	if(negedge_cnt[3:0] == 4'd0)
	begin
		if(mod_type == `TAGSIM_LISTEN) 
			sendbit = after_hysteresis;
		else if(mod_type == `TAGSIM_MOD)
			sendbit = fdt_indicator;
		else if (mod_type == `READER_LISTEN)
			sendbit = curbit;
		else
			sendbit = 1'b0;
	end
	if(mod_type == `SNIFFER)
		bit_to_arm = to_arm[7];
	else if (mod_type == `TAGSIM_MOD && fdt_elapsed && temp_buffer_reset)
		bit_to_arm = to_arm[7];
	else
		bit_to_arm = sendbit;
end
assign ssp_din = bit_to_arm;
wire sub_carrier;
assign sub_carrier = ~sub_carrier_cnt[3];
assign pwr_hi = (ck_1356megb & (((mod_type == `READER_MOD) & ~mod_sig_coil) || (mod_type == `READER_LISTEN)));	
assign pwr_oe1 = 1'b0;
assign pwr_oe3 = 1'b0;
assign pwr_oe4 = mod_sig_coil & sub_carrier & (mod_type == `TAGSIM_MOD);
assign pwr_oe2 = 1'b0;
assign pwr_lo = 1'b0;
assign dbg = negedge_cnt[3];
endmodule
