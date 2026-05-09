`timescale 1ns / 1ps
`timescale 1ns / 1ps
module neopixel_tx_fsm(
	input wire clk,					
	input wire rst,					
	input wire mode,					
	input wire tx_enable,			
	input wire empty_flg,			
	input wire [23:0] neo_dIn,		
	input wire rgb_msgTyp,			
	output wire rd_next,				
	output wire neo_tx_out			
   );
	parameter idle = 2'b00;				
	parameter chk_fifo = 2'b01;		
	parameter neo_sendRst = 2'b10;   
	parameter neo_sendRGB = 2'b11; 	
	reg [1:0] neostate;	
	reg [4:0] dataCntr; 	
	reg [9:0] pulseCntr;	
	reg tx_compSig;		
	reg neo_dOut;			
	wire [9:0] onePulse; 	
	wire [9:0] zeroPulse;  	
	wire [9:0] fullPulse;	
	parameter rst_pulse 	= 10'd1020; 
	parameter one800 		= 10'd12;	
	parameter zero800		= 10'd5;		
	parameter pulse800	= 10'd23;   
	parameter one400		= 10'd12;
	parameter zero400		= 10'd26;
	parameter pulse400	= 10'd48;
	always@(posedge clk or negedge rst) begin
		if(!rst) begin 
			neostate <= idle;
		end
		else begin 
			case(neostate)			
				idle: begin 
					if(!empty_flg && tx_enable) begin 
						neostate <= chk_fifo;
					end
				end 
				chk_fifo: begin 
					if(empty_flg || !tx_enable) begin 
						neostate <= idle;
					end
					else begin 
						if(rgb_msgTyp) begin 
							neostate <= neo_sendRGB;
						end
						else begin 
							neostate <= neo_sendRst;
						end
					end 
				end 
				neo_sendRst: begin 
					if(tx_compSig) begin 
						neostate <= chk_fifo;	
					end		
				end 
				neo_sendRGB: begin 
					if(tx_compSig) begin
						neostate <= chk_fifo;						
					end
				end 
			endcase 
		end
	end 
	always@(posedge clk) begin			
		if(neostate == neo_sendRst) begin 
			if(pulseCntr >= rst_pulse) begin	
				tx_compSig <= 1;					
				neo_dOut <= 0; 
			end
			else begin 
				neo_dOut <= 0;
			end
		end 
		else if(neostate == neo_sendRGB) begin 
			if(dataCntr > 0) begin 
				if(pulseCntr == fullPulse) begin 
					dataCntr <= dataCntr - 5'd1;
				end				
				else if((neo_dIn[dataCntr - 1] && pulseCntr > onePulse && pulseCntr < fullPulse) || 
						  (!neo_dIn[dataCntr - 1] && pulseCntr > zeroPulse && pulseCntr < fullPulse)) begin						  
					neo_dOut <= 0;		
				end
				else begin
					neo_dOut <= 1; 	
				end		
			end 
			else begin 
				dataCntr <= 5'd24;				
				tx_compSig <= 1;
			end
		end 
		else begin 
			dataCntr <= 5'd24; 
			tx_compSig <= 0;	 
			if(neostate == chk_fifo && rgb_msgTyp && !empty_flg && tx_enable) begin 
				neo_dOut <= 1; 
			end
			else  begin 
				neo_dOut <= 0;
			end
		end 
	end 
	always@(posedge clk) begin	
		if(neostate == neo_sendRst)begin 
			if(pulseCntr <= rst_pulse - 10'd1) begin
				pulseCntr <= pulseCntr + 10'd1;
			end
		end 
		else if (neostate == neo_sendRGB) begin 
			if(pulseCntr <= fullPulse) begin 
				pulseCntr <= pulseCntr + 10'd1;
			end
			else begin 
				 pulseCntr <= 0;
			end
		end 
		else begin 
			pulseCntr <= 0;
		end	
	end 
	assign onePulse = (mode)? one800 : one400; 
	assign zeroPulse = (mode)? zero800 : zero400;	
	assign fullPulse = (mode)? pulse800 : pulse400;
	assign rd_next = tx_compSig; 
	assign neo_tx_out = neo_dOut; 
endmodule
