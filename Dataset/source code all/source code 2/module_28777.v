`timescale 1 ns / 1 ps
`timescale 1 ns / 1 ps
module OOB_control (
 clk,	          
 reset,	        
 link_reset,
 rx_locked,	    
 tx_datain,	    
 tx_chariskin,  
 tx_dataout,	  
 tx_charisk,	  
 rx_charisk,                             
 rx_datain,                
 rx_dataout, 
 rx_charisk_out,              
 linkup,	          
 rxreset,	          
 gen2,		          
 txcomstart,	      
 txcomtype,	        
 rxstatus,	        
 rxelecidle,	      
 txelecidle,	      
 rxbyteisaligned,	    
 CurrentState_out,	  
 align_det_out,		    
 sync_det_out,		    
 rx_sof_det_out,	    
 rx_eof_det_out,	    
 send_align_count_out 
);
	input   clk;
	input 	reset;
	input   link_reset;
	input 	rx_locked;
	input	  [2:0]	rxstatus;
	input		rxelecidle;
	input	  [15:0]   tx_datain;
  input   tx_chariskin;
	input	  [1:0]   rx_charisk;   		
	input	  [15:0]  rx_datain; 	
	input		rxbyteisaligned;
	input   gen2;	
	output	txcomstart;
	output	txcomtype;
	output 	txelecidle;
	output	[15:0]  tx_dataout;
	output  tx_charisk;                                
	output	[15:0]  rx_dataout;
	output	[1:0]   rx_charisk_out; 	                        
	output  reg linkup;
	output	rxreset;
	output	[3:0]   CurrentState_out;
	output  align_det_out;
	output  sync_det_out;
	output  rx_sof_det_out;
	output  rx_eof_det_out;
  output  [1:0] send_align_count_out;
	parameter [3:0]
	host_comreset		= 4'h0,
	wait_dev_cominit	= 4'h1,
	host_comwake 		= 4'h2, 
	wait_dev_comwake 	= 4'h3,
	wait_after_comwake 	= 4'h4,
	wait_after_comwake1 	= 4'h5,
	host_d10_2 		= 4'h6,
	host_send_align 	= 4'h7,
	link_ready 		= 4'h8;
	reg	[3:0]	CurrentState, NextState;
	reg	[7:0]	count160;
	reg	[17:0]	count;
	reg	[4:0]	count160_round;
	reg	[3:0]	align_char_cnt_reg;
	reg		align_char_cnt_rst, align_char_cnt_inc;
	reg		count_en;
	reg 		send_d10_2_r, send_align_r; 
	reg		tx_charisk;
	reg		txelecidle_r;
	reg		count160_done, count160_go;
	reg	[1:0]	align_count;
	reg        	linkup_r;
	reg		rxreset; 
	reg	[15:0]  rx_datain_r1;
	reg	[15:0]  tx_datain_r1, tx_datain_r2, tx_datain_r3, tx_datain_r4; 
	reg	[15:0]  tx_dataout;
	reg	[15:0]  rx_dataout;
	reg     [1:0]   rx_charisk_out;
	reg		txcomstart_r, txcomtype_r;
	wire		align_det, sync_det;
	wire		comreset_done, dev_cominit_done, host_comwake_done, dev_comwake_done;
	wire		rx_sof_det, rx_eof_det;
	wire		align_cnt_en;
always@(posedge clk or posedge reset)
begin : Linkup_synchronisation
	if (reset) begin
		linkup <= 0;						
	end	
	else begin 
		linkup <= linkup_r;
	end
end
always @ (CurrentState or count or rxstatus or rxelecidle or rx_locked or align_det or sync_det or gen2)
begin : SM_mux
	count_en = 1'b0;
	NextState = host_comreset;
	linkup_r = 1'b0;
	txcomstart_r =1'b0;
	txcomtype_r = 1'b0;
	txelecidle_r = 1'b1;
	send_d10_2_r = 1'b0;
	send_align_r = 1'b0;
	rxreset = 1'b0;	
	case (CurrentState)
		host_comreset :
			begin
				if (rx_locked)
					begin 
						if ((~gen2 && count == 18'h000A2) || (gen2 && count == 18'h00144))
						begin
							txcomstart_r =1'b0;	
							txcomtype_r = 1'b0;
							NextState = wait_dev_cominit;
						end
						else
						begin
							txcomstart_r =1'b1;	
							txcomtype_r = 1'b0;
							count_en = 1'b1;
							NextState = host_comreset;						
						end
					end
				else
					begin
						txcomstart_r =1'b0;	
						txcomtype_r = 1'b0;
						NextState = host_comreset;
					end													
			end						
		wait_dev_cominit : 
			begin
				if (rxstatus == 3'b100) 
				begin
					NextState = host_comwake;
				end
				else
				begin
					`ifdef SIM
					if(count == 18'h001ff) 
					`else
					if(count == 18'h203AD) 
					`endif
					begin
						count_en = 1'b0;
						NextState = host_comreset;
					end
					else
					begin
						count_en = 1'b1;
						NextState = wait_dev_cominit;
					end
				end
			end
		host_comwake : 
			begin
				if ((~gen2 && count == 18'h0009B) || (gen2 && count == 18'h00136))
				begin
					txcomstart_r =1'b0;	
					txcomtype_r = 1'b0;
					NextState = wait_dev_comwake;
				end
				else
				begin
					txcomstart_r =1'b1;	
					txcomtype_r = 1'b1;
					count_en = 1'b1;
					NextState = host_comwake;						
				end
			end
		wait_dev_comwake : 
			begin
				if (rxstatus == 3'b010) 
				begin
					NextState = wait_after_comwake;
				end
				else
				begin
					if(count == 18'h203AD) 
					begin
						count_en = 1'b0;
						NextState = host_comreset;
					end
					else
					begin
						count_en = 1'b1;
						NextState = wait_dev_comwake;
					end
				end
			end
		wait_after_comwake : 
			begin
				if (count == 6'h3F)
				begin
					NextState = wait_after_comwake1;
				end
				else
				begin
					count_en = 1'b1;
					NextState = wait_after_comwake;
				end
			end		
		wait_after_comwake1 : 
			begin
				if (~rxelecidle)
				begin
					rxreset = 1'b1;
					NextState = host_d10_2;
				end
				else
					NextState = wait_after_comwake1; 	
			end
		host_d10_2 : 
		begin
			send_d10_2_r = 1'b1;
			txelecidle_r = 1'b0;
			if (align_det)
			begin
				send_d10_2_r = 1'b0;
				NextState = host_send_align;
			end
			else
			begin
				if(count == 18'h203AD) 
				begin
					count_en = 1'b0;
					NextState = host_comreset;						
				end
				else
				begin
					count_en = 1'b1;
					NextState = host_d10_2;
				end
			end				
		end					
		host_send_align : 
		begin
			send_align_r = 1'b1;
			txelecidle_r = 1'b0;
			if (sync_det) 
			begin
				send_align_r = 1'b0;
				NextState = link_ready;
			end
			else
				NextState = host_send_align;
		end						
		link_ready : 
		begin
			txelecidle_r = 1'b0;
			if (rxelecidle)
			begin
				NextState = link_ready;
				linkup_r = 1'b0;
			end
			else
			begin
				NextState = link_ready;
				linkup_r = 1'b1;
			end
		end
		default : NextState = host_comreset;	
	endcase
end	
always@(posedge clk or posedge reset)
begin : SEQ
	if (reset)
		CurrentState = host_comreset;
	else
		CurrentState = NextState;
end
always@(posedge clk or posedge reset)
begin : data_mux
	if (reset) begin
		tx_dataout <= 16'b0;
    rx_dataout <= 16'b0;
    rx_charisk_out <= 1'b 0;
    tx_charisk     <= 1'b 0; 
  end
	else begin
		if (linkup) begin
      rx_charisk_out <= rx_charisk;
			rx_dataout <= rx_datain;
      tx_dataout <= tx_datain;
      tx_charisk <= tx_chariskin;
	  end
		else if (send_align_r) begin
      rx_charisk_out <= rx_charisk;
			rx_dataout <= rx_datain;
			case (align_count)
			  2'b00 : 
				begin 
					tx_dataout <= 16'h4ABC; 
					tx_charisk <= 1'b1;
				end
				2'b01 : 
				begin
					tx_dataout <= 16'h7B4A; 
					tx_charisk <= 1'b0;
				end
				2'b10 : 
				begin
					tx_dataout <= 16'h4ABC; 
					tx_charisk <= 1'b1;
				end
				2'b11 : 
				begin
					tx_dataout <= 16'h7B4A; 
					tx_charisk <= 1'b0;
				end
			endcase			
		end
		else if ( send_d10_2_r ) begin
      rx_charisk_out <= rx_charisk;
			rx_dataout <= rx_datain;
			tx_dataout <= 16'h4a4a; 
			tx_charisk <= 1'b0;			
		end			
		else begin
      rx_charisk_out <= rx_charisk;
			rx_dataout <= rx_datain;
			case (align_count)
				2'b00 : 
				begin
					tx_dataout <= 16'h4ABC; 
					tx_charisk <= 1'b1;
				end
				2'b01 : 
				begin
					tx_dataout <= 16'h7B4A; 
					tx_charisk <= 1'b0;
				end
				2'b10 : 
				begin
					tx_dataout <= 16'h4ABC; 
					tx_charisk <= 1'b1;
				end
				2'b11 : 
				begin
					tx_dataout <= 16'h7B4A; 
					tx_charisk <= 1'b0;
				end
			endcase			
		end	
  end
end
always@(posedge clk or posedge reset)
begin : comreset_OOB_count
	if (reset)
	begin
		count160 = 8'b0;
		count160_round = 5'b0;
	end	
	else if (count160_go)
		begin  
		if (count160 == 8'h10 )
			begin
				count160 = 8'b0;
				count160_round = count160_round + 1;
			end
		     else
			        count160 = count160 + 1;
		end
		else
		begin
			count160 = 8'b0;
			count160_round = 5'b0;
		end			
end
always@(posedge clk or posedge reset)
begin : freecount
	if (reset)
	begin
		count = 18'b0;
	end	
	else if (count_en)
	begin  
		count = count + 1;
	end
     	else
     	begin
		count = 18'b0;
	end
end
always@(posedge clk or posedge reset)
begin : rxdata_shift
	if (reset)
	begin
		rx_datain_r1 <= 16'b0;						
	end	
	else 
	begin 
		rx_datain_r1 <= rx_datain;
	end
end
always@(posedge clk or posedge reset)
begin : txdata_shift
	if (reset)
	begin
		tx_datain_r1 <= 8'b0;
		tx_datain_r2 <= 8'b0;
		tx_datain_r3 <= 8'b0;
		tx_datain_r4 <= 8'b0;						
	end	
	else 
	begin  
		tx_datain_r1 <= tx_dataout;
		tx_datain_r2 <= tx_datain_r1;
		tx_datain_r3 <= tx_datain_r2;
		tx_datain_r4 <= tx_datain_r3;
	end
end
always@(posedge clk or posedge reset)
begin : send_align_cnt
	if (reset)
		align_count = 2'b0;
	else if (align_cnt_en)
		align_count = align_count + 1;
     	else
		align_count = 2'b0;
end
assign comreset_done = (CurrentState == host_comreset && count160_round == 5'h15) ? 1'b1 : 1'b0;
assign host_comwake_done = (CurrentState == host_comwake && count160_round == 5'h0b) ? 1'b1 : 1'b0;
assign align_det = (rx_datain == 16'h7B4A && rx_datain_r1 == 16'h4ABC) && rxbyteisaligned; 
assign sync_det = (rx_datain == 16'hB5B5 && rx_datain_r1 == 16'h957C);
assign rx_sof_det = (rx_datain == 16'h3737 && rx_datain_r1 == 16'hB57C);
assign rx_eof_det = (rx_datain == 16'hD5D5 && rx_datain_r1 == 16'hB57C);
assign	txcomstart = txcomstart_r;
assign	txcomtype = txcomtype_r;
assign  txelecidle = txelecidle_r;
assign align_cnt_en = ~send_d10_2_r;
assign CurrentState_out = CurrentState;
assign align_det_out = align_det;
assign sync_det_out = sync_det;
assign rx_sof_det_out = rx_sof_det;
assign rx_eof_det_out = rx_eof_det;
assign send_align_count_out = align_count;
endmodule
