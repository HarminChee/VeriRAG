module altera_up_avalon_video_vga_timing (
	clk,
	reset,
	red_to_vga_display,
	green_to_vga_display,
	blue_to_vga_display,
	color_select,
	read_enable,
	end_of_active_frame,
	end_of_frame,
	vga_blank,					
	vga_c_sync,					
	vga_h_sync,					
	vga_v_sync,					
	vga_data_enable,			
	vga_red,						
	vga_green,	 				
	vga_blue,	   			
	vga_color_data	   		
);
parameter CW								= 9;
parameter H_ACTIVE 						= 640;
parameter H_FRONT_PORCH					=  16;
parameter H_SYNC							=  96;
parameter H_BACK_PORCH 					=  48;
parameter H_TOTAL 						= 800;
parameter V_ACTIVE 						= 480;
parameter V_FRONT_PORCH					=  10;
parameter V_SYNC							=   2;
parameter V_BACK_PORCH 					=  33;
parameter V_TOTAL							= 525;
parameter PW								= 10;			
parameter PIXEL_COUNTER_INCREMENT	= 10'h001;
parameter LW								= 10;			
parameter LINE_COUNTER_INCREMENT		= 10'h001;
input						clk;
input						reset;
input			[CW: 0]	red_to_vga_display;
input			[CW: 0]	green_to_vga_display;
input			[CW: 0]	blue_to_vga_display;
input			[ 3: 0]	color_select;
output					read_enable;
output reg				end_of_active_frame;
output reg				end_of_frame;
output reg				vga_blank;			
output reg				vga_c_sync;			
output reg				vga_h_sync;			
output reg				vga_v_sync;			
output reg				vga_data_enable;	
output reg	[CW: 0]	vga_red;				
output reg	[CW: 0]	vga_green;			
output reg	[CW: 0]	vga_blue;  	 		
output reg	[CW: 0]	vga_color_data;	
reg			[PW:1]	pixel_counter;
reg			[LW:1]	line_counter;
reg						early_hsync_pulse;
reg						early_vsync_pulse;
reg						hsync_pulse;
reg						vsync_pulse;
reg						csync_pulse;
reg						hblanking_pulse;
reg						vblanking_pulse;
reg						blanking_pulse;
always @ (posedge clk)
begin
	if (reset)
	begin
		vga_c_sync			<= 1'b1;
		vga_blank			<= 1'b1;
		vga_h_sync			<= 1'b1;
		vga_v_sync			<= 1'b1;
		vga_red				<= {(CW + 1){1'b0}};
		vga_green			<= {(CW + 1){1'b0}};
		vga_blue				<= {(CW + 1){1'b0}};
		vga_color_data		<= {(CW + 1){1'b0}};
	end
	else
	begin
		vga_blank			<= ~blanking_pulse;
		vga_c_sync			<= ~csync_pulse;
		vga_h_sync			<= ~hsync_pulse;
		vga_v_sync			<= ~vsync_pulse;
		vga_data_enable	<= ~blanking_pulse;
		if (blanking_pulse)
		begin
			vga_red			<= {(CW + 1){1'b0}};
			vga_green		<= {(CW + 1){1'b0}};
			vga_blue			<= {(CW + 1){1'b0}};
			vga_color_data	<= {(CW + 1){1'b0}};
		end
		else
		begin
			vga_red			<= red_to_vga_display;
			vga_green		<= green_to_vga_display;
			vga_blue			<= blue_to_vga_display;
			vga_color_data	<= ({(CW + 1){color_select[0]}} & red_to_vga_display) |
									({(CW + 1){color_select[1]}} & green_to_vga_display) |
									({(CW + 1){color_select[2]}} & blue_to_vga_display);
		end
	end
end
always @ (posedge clk)
begin
	if (reset)
	begin
		pixel_counter	<= H_TOTAL - 3; 
		line_counter	<= V_TOTAL - 1; 
	end
	else
	begin
		if (pixel_counter == (H_TOTAL - 1))
		begin
			pixel_counter <= {PW{1'b0}};
			if (line_counter == (V_TOTAL - 1))
				line_counter <= {LW{1'b0}};
			else
				line_counter <= line_counter + LINE_COUNTER_INCREMENT;
		end
		else 
			pixel_counter <= pixel_counter + PIXEL_COUNTER_INCREMENT;
	end
end
always @ (posedge clk) 
begin
	if (reset)
	begin
		end_of_active_frame <= 1'b0;
		end_of_frame		<= 1'b0;
	end
	else
	begin
		if ((line_counter == (V_ACTIVE - 1)) &&
			(pixel_counter == (H_ACTIVE - 2)))
			end_of_active_frame <= 1'b1;
		else
			end_of_active_frame <= 1'b0;
		if ((line_counter == (V_TOTAL - 1)) && 
			(pixel_counter == (H_TOTAL - 2)))
			end_of_frame <= 1'b1;
		else
			end_of_frame <= 1'b0;
	end
end
always @ (posedge clk) 
begin
	if (reset)
	begin
		early_hsync_pulse <= 1'b0;
		early_vsync_pulse <= 1'b0;
		hsync_pulse <= 1'b0;
		vsync_pulse <= 1'b0;
		csync_pulse	<= 1'b0;
	end
	else
	begin
		if (pixel_counter == (H_ACTIVE + H_FRONT_PORCH - 2))
			early_hsync_pulse <= 1'b1;	
		else if (pixel_counter == (H_TOTAL - H_BACK_PORCH - 2))
			early_hsync_pulse <= 1'b0;	
		if ((line_counter == (V_ACTIVE + V_FRONT_PORCH - 1)) && 
				(pixel_counter == (H_TOTAL - 2)))
			early_vsync_pulse <= 1'b1;
		else if ((line_counter == (V_TOTAL - V_BACK_PORCH - 1)) && 
				(pixel_counter == (H_TOTAL - 2)))
			early_vsync_pulse <= 1'b0;
		hsync_pulse <= early_hsync_pulse;
		vsync_pulse <= early_vsync_pulse;
		csync_pulse <= early_hsync_pulse ^ early_vsync_pulse;
	end
end
always @ (posedge clk) 
begin
	if (reset)
	begin
		hblanking_pulse	<= 1'b1;
		vblanking_pulse	<= 1'b1;
		blanking_pulse	<= 1'b1;
	end
	else
	begin
		if (pixel_counter == (H_ACTIVE - 2))
			hblanking_pulse	<= 1'b1;
		else if (pixel_counter == (H_TOTAL - 2))
			hblanking_pulse	<= 1'b0;
		if ((line_counter == (V_ACTIVE - 1)) &&
				(pixel_counter == (H_TOTAL - 2))) 
			vblanking_pulse	<= 1'b1;
		else if ((line_counter == (V_TOTAL - 1)) &&
				(pixel_counter == (H_TOTAL - 2))) 
			vblanking_pulse	<= 1'b0;
		blanking_pulse		<= hblanking_pulse | vblanking_pulse;
	end
end
assign read_enable = ~blanking_pulse;
endmodule
