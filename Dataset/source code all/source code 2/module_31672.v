`timescale 1ns/1ns
`timescale 1ns/1ns
module WUM_fsm #(parameter SIGN_DEPTH=5, NOS_KEY=2,NOS_STGS=4,SFT_DEL_WDH=4)
			(	input clk,
				input reset,
				input datInReady,
				output reg  compare_enable, output reg compare_mux,
				output a_clr, output datin_clr, output reg shift_amt_clr,
				output reg a_ld, output reg shift_amt_ld,
				output reg input_ready);
localparam Idle=3'h0, DataInload=3'h1, DatadeMux=3'h2, Shift=3'h3, Shift_Dat_ld=3'h4, Compare=3'h5;
reg [2:0]  current_state;
reg [2:0] next_state;
reg [SFT_DEL_WDH:0] shift_delay;
assign a_clr = 0;
assign datin_clr = 0;
always @ (posedge clk)
begin
	if (reset) begin
		current_state <= Idle;
	end
		else
		current_state <= next_state;
end
always @(posedge clk)
begin
	if(reset) begin
		shift_delay <= 0;
	end
	else if(current_state ==  Compare) begin
			if(shift_delay == NOS_STGS+NOS_KEY+1)
		 		shift_delay <= 0;
		 	else begin
		 		shift_delay <= shift_delay + 1;;
		 	end
		end
		else begin
		 shift_delay <= 0;
		end
end
always @(current_state,shift_delay)
begin
	if (shift_delay >= NOS_STGS+1 && shift_delay < NOS_STGS+NOS_KEY+1) begin
		compare_mux<=1;
	end
	else begin
		compare_mux<=0;
	end
end
always @(current_state,shift_delay)
begin
	if(current_state ==  Compare && shift_delay < NOS_STGS+1) begin
		compare_enable <= 1;
	end
	else  compare_enable <= 0;
end
always @(current_state)
begin
	if(current_state ==  DatadeMux) begin
		 input_ready = 1;
	end
	else  input_ready = 0;
end
always @(current_state)
begin
	if(current_state == Shift || current_state ==  Idle) begin
		 shift_amt_clr=1;
	end
	else begin
		 shift_amt_clr=0;
	end
end
always @(current_state)
begin
	if(current_state == Shift_Dat_ld) begin
		 a_ld=1;
	end
	else begin
		 a_ld=0;
	end
end
always @(current_state,shift_delay)
begin
	if(current_state == Compare && shift_delay == NOS_STGS+NOS_KEY+1) begin
		 shift_amt_ld=1;
	end
	else begin
		 shift_amt_ld=0;
	end
end
always @ (current_state, datInReady,shift_delay) 
begin
	case(current_state)
		Idle:				if(datInReady == 1) begin
								next_state=DataInload;
							end
							else next_state= Idle;
		DataInload:			next_state=DatadeMux;
		DatadeMux:			next_state=Shift;
		Shift:				next_state = Shift_Dat_ld;
		Shift_Dat_ld:		next_state = Compare;
		Compare: 			if(shift_delay == NOS_STGS+NOS_KEY+1)
								next_state = Shift;
							else next_state = Compare;
		default: 			next_state=current_state;
	endcase
end
endmodule
