module edid_master_slave_hack(
input rst_n,
input clk,
inout sda_lcd,
output scl_lcd,
input hpd_lcd,
inout sda_pc,
input scl_pc,
output reg hpd_pc,
output [7:0] sda_byte,
output sda_byte_en,
output reg dvi_only,
input hdmi_dvi
);
reg stop;
wire [7:0] edid_byte_lcd;
reg [6:0] counter;
reg [6:0] segments, segment_count;
reg [7:0] debounce_hpd;
reg hpda_stable,hpda_stable_q;
wire start_reading,edid_byte_lcd_en;
assign start_reading = (hpda_stable^hpda_stable_q) & hpda_stable;
always @(posedge clk) begin
	if (~rst_n) begin	
		counter <= 0;
		stop <= 0;
		dvi_only <= 1;
		segments <= 0;
		segment_count <= 0;
		hpd_pc <= 0;
		hpda_stable <= 0;
		hpda_stable_q <= 0;
	end else begin 
		debounce_hpd <= {debounce_hpd[6:0],hpd_lcd};		
		if (debounce_hpd == 8'd255) begin
			hpda_stable <= 1;
		end
		hpda_stable_q <= hpda_stable;
		if (start_reading) begin
			hpd_pc <= 0;
			stop <= 0;
		end
		if (start_reading | stop) begin 
			segments <= 0;
			segment_count <= 0;
			counter <= 0;
		end
		if (edid_byte_lcd_en) begin
			counter <= counter +1;
			if (segment_count==0) begin 
				if (counter == 127) begin 
					if (segments == 0) begin
						stop <= 1;
						hpd_pc <= 1;
					end else begin
						segment_count <= 1;
					end
				end
				if (counter == 126) begin
					if  (edid_byte_lcd == 0) begin
						dvi_only <= 1;
					end else begin
						segments <= edid_byte_lcd;
					end
				end				
			end else begin 
				if (counter == 127) begin 
					if (segment_count == segments) begin
						stop <= 1;
						hpd_pc <=1;
					end else begin
						segment_count <= segment_count+1;
					end					
				end
				if (counter == 0) begin
					if (edid_byte_lcd == 2) begin 
						dvi_only <= 0;
					end
				end
			end
		end 
	end 
end 
edidmaster edid_master(
.rst_n(rst_n),
.clk(clk),
.sda(sda_lcd),
.scl(scl_lcd),
.stop_reading(stop),
.address_w(8'ha0),
.start(start_reading),
.address_r(8'ha1),
.reg0(8'h0),
.sdadata(edid_byte_lcd),
.out_en(edid_byte_lcd_en)
);
assign sda_byte = edid_byte_lcd;
assign sda_byte_en = edid_byte_lcd_en;
edidslave edid_slave(
.rst_n(rst_n),
.clk(clk),
.sda(sda_pc),
.scl(scl_pc),
.dvi_only(hdmi_dvi)
);
endmodule
