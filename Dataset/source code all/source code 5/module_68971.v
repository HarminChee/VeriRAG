module pulse_senor_read(clk,reset_n,chipselect,address,write,writedata,read,byteenable,readdata,pulse_in);
input clk;
input reset_n;
input chipselect;
input [1:0]address; 
input write;  
input [31:0] writedata;  
input read;  
input [3:0] byteenable;  
output [31:0] readdata; 
input [1:0]pulse_in;  
reg [31:0] speed_count; 
reg [31:0] speed_count1;   
reg [31:0] current_count;   
reg [31:0] control_reg;  
reg [31:0] time_period;   
reg  speed_count_sel;   
reg  current_count_sel;   
reg  control_reg_sel;  
reg  time_period_sel;
reg [31:0] readdata;    
reg pio_state1;
reg pio_state2;
reg [31:0] time_period_count;
reg  clear_speed_count;
reg  write_count;
wire stop_bit;
assign stop_bit=control_reg[0];
always@(negedge clk or negedge reset_n)
	begin 
		if(!reset_n)
			begin
				pio_state1<=0;
				pio_state2<=0;
			end
		else
			begin
				pio_state1<=pulse_in[0];
				pio_state2<=pio_state1;
			end
	end
always@(posedge clk or negedge reset_n)
	begin 
		if(!reset_n)
			begin
				current_count<=32'h80000000;
			end
		else
			begin
				if(stop_bit)
					begin
						current_count<=32'h80000000;
					end
				else
					if(write & chipselect & current_count_sel)
						begin
							if(byteenable[0])  current_count[7:0]<=writedata[7:0]; 
							if(byteenable[1])  current_count[15:8]<=writedata[15:8];
							if(byteenable[2])  current_count[23:16]<=writedata[23:16];
							if(byteenable[3])  current_count[31:24]<=writedata[31:24];
						end
					else
						begin
						 if(pio_state1==1&&pio_state2==0)
							begin
								if(pulse_in[1])
								current_count<=current_count+1;
								else
								current_count<=current_count-1;
							end
						 end
			end
	end
always@(negedge clk or negedge reset_n)
	begin 
		if(!reset_n)
			begin
				time_period_count<=32'h0FF307B0;   
				clear_speed_count<=0;
			end
		else
			begin
				   if(time_period_count[31])
						begin
						clear_speed_count<=1;
						time_period_count[30:0]<=time_period[30:0];
						time_period_count[31]<=0;
						end
					else
						begin
						clear_speed_count<=0;
						time_period_count<=time_period_count+1;
						end
			end
	end	
always@(posedge clk or negedge reset_n)
	begin 
		if(!reset_n)
			begin
				speed_count1<=32'h00000000;
				speed_count<=32'h00000000;
			end
		else
			begin
				if(stop_bit)
					begin
						speed_count1<=32'h00000000;
						speed_count<=32'h00000000;
					end
				else
					if(clear_speed_count)
						begin
							speed_count1<=32'h00000000;
							speed_count<=speed_count1;
						end
					else
						begin
						 if(pio_state1==1&&pio_state2==0)
							begin
								if(pulse_in[1])
									speed_count1<=speed_count1+1;
								else
									speed_count1<=speed_count1-1;
							end
						 end
			end
	end
always @ (address)  
begin  
    speed_count_sel<=0;  
    current_count_sel<=0;  
    control_reg_sel<=0;
	 time_period_sel<=0;
    case(address)  
        2'b00:speed_count_sel<=1;  
        2'b01:current_count_sel<=1;  
        2'b10:control_reg_sel<=1;  
		  2'b11:time_period_sel<=1;	
     endcase  
end 
always @ (posedge clk or negedge reset_n)  
begin  
	if(!reset_n)   
		control_reg<=0;  
	else 
		begin  
			if(write & chipselect & control_reg_sel)  
				begin  
				if(byteenable[0])  control_reg[7:0]<=writedata[7:0]; 
				if(byteenable[1])  control_reg[15:8]<=writedata[15:8];
				if(byteenable[2])  control_reg[23:16]<=writedata[23:16];
				if(byteenable[3])  control_reg[31:24]<=writedata[31:24];
				end  
		end  
end
always @ (posedge clk or negedge reset_n)  
begin  
	if(!reset_n)   
		time_period<=32'h0FF307B0;  
	else 
		begin  
			if(write & chipselect & time_period_sel)  
				begin  
				if(byteenable[0])  time_period[7:0]<=writedata[7:0];
				if(byteenable[1])  time_period[15:8]<=writedata[15:8];
				if(byteenable[2])  time_period[23:16]<=writedata[23:16];
				if(byteenable[3])  time_period[31:24]<=writedata[31:24];
				end  
		end  
end
always @ (address or read or speed_count or current_count or control_reg or time_period or chipselect)  
begin  
    if(read & chipselect)  
         case(address)  
             2'b00:
				begin
				readdata<=speed_count;
				end				
             2'b01:
				begin
				readdata<=current_count;
				end				
             2'b10:
				begin
				readdata<=control_reg;
				end				
             2'b11:
				begin
				readdata<=time_period;
				end
         endcase   
end
endmodule 
