module DE0_Nano(
	CLOCK_50,
	LED,
	KEY,
	SW,
	DRAM_ADDR,
	DRAM_BA,
	DRAM_CAS_N,
	DRAM_CKE,
	DRAM_CLK,
	DRAM_CS_N,
	DRAM_DQ,
	DRAM_DQM,
	DRAM_RAS_N,
	DRAM_WE_N,
	G_SENSOR_CS_N,
	G_SENSOR_INT,
	I2C_SCLK,
	I2C_SDAT,
	ADC_CS_N,
	ADC_SADDR,
	ADC_SCLK,
	ADC_SDAT,
	GPIO_2,
	GPIO_2_IN,
	GPIO_0,
	GPIO_0_IN,
	GPIO_1,
	GPIO_1_IN 
);
input 		          		CLOCK_50;
output		     [7:0]		LED;
input 		     [1:0]		KEY;
input 		     [3:0]		SW;
output		    [12:0]		DRAM_ADDR;
output		     [1:0]		DRAM_BA;
output		          		DRAM_CAS_N;
output		          		DRAM_CKE;
output		          		DRAM_CLK;
output		          		DRAM_CS_N;
inout 		    [15:0]		DRAM_DQ;
output		     [1:0]		DRAM_DQM;
output		          		DRAM_RAS_N;
output		          		DRAM_WE_N;
output		          		G_SENSOR_CS_N;
input 		          		G_SENSOR_INT;
output		          		I2C_SCLK;
inout 		          		I2C_SDAT;
output		          		ADC_CS_N;
output		          		ADC_SADDR;
output		          		ADC_SCLK;
input 		          		ADC_SDAT;
inout 		    [12:0]		GPIO_2;
input 		     [2:0]		GPIO_2_IN;
inout 		    [33:0]		GPIO_0;
input 		     [1:0]		GPIO_0_IN;
inout 		    [33:0]		GPIO_1;
input 		     [1:0]		GPIO_1_IN;
wire  			[3:0] 		seconds;
wire				[3:0]			tens_seconds;
wire								minute_inc;
wire				[3:0]			minutes;
wire				[3:0]			tens_minutes;
wire								hours_inc;
wire				[3:0]			hours;
wire				[3:0]			tens_hours;
wire								days_inc;
wire								AM;
wire								PM;
wire								seconds_tick;
wire				[5:0]			segment_sel;
wire				[6:0]			seven_segment;
assign GPIO_0[9] 	= seven_segment[6];
assign GPIO_0[11]	= seven_segment[5];
assign GPIO_0[13] = seven_segment[4];
assign GPIO_0[15] = seven_segment[3];
assign GPIO_0[17] = seven_segment[2];
assign GPIO_0[19] = seven_segment[1];
assign GPIO_0[21] = seven_segment[0];
assign GPIO_0[8]	= segment_sel[5];
assign GPIO_0[10] = segment_sel[4];
assign GPIO_0[12] = segment_sel[3];
assign GPIO_0[14] = segment_sel[2];
assign GPIO_0[16] = segment_sel[1];
assign GPIO_0[18]	= segment_sel[0];
assign LED[0] = seconds_tick;
reg				[12:0]		count_div;
always @ (posedge CLOCK_50)
	count_div <= count_div + 1;
divide_by_50M u1(CLOCK_50, seconds_tick);
count_seconds u2 (
	,
	seconds_tick, 
	seconds[3:0], 
	tens_seconds[3:0], 
	minute_inc
);
count_minutes u3 (
	!KEY[0], 
	minute_inc, 
	minutes[3:0], 
	tens_minutes[3:0], 
	hours_inc
);
count_hours u5(
	SW[0], 
	!KEY[1], 
	hours_inc, 
	hours[3:0], 
	tens_hours[3:0], 
	LED[7], 
	LED[6], 
	days_inc
);
clock_display u6(
	count_div[12], 
	tens_hours[3:0], 
	hours[3:0], 
	tens_minutes[3:0], 
	minutes[3:0], 
	tens_seconds[3:0], 
	seconds[3:0], 
	segment_sel[5:0], 
	seven_segment[6:0]
);
endmodule
