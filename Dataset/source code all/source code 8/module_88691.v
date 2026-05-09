`timescale 1ns / 1ps
module RCB_FRL_channel_MSG (CLK, CLKDIV, DATA_IN, RST, fifo_WREN1, D, RE_SIG, CON_P, CON_N);
	input CLK, CLKDIV, RST;
	input [7:0] DATA_IN;
	output fifo_WREN1, RE_SIG; 
	output [39:0] D;
	output CON_P, CON_N;
	wire [7:0] input_reg1_wire, input_reg1_wire_inv;
	wire CON_P, CON_N;
	assign input_reg1_wire = DATA_IN;
		RCB_FRL_CMD_shift_MSG CMD_shift_inst
		(
			.data_in(input_reg1_wire),
			.clk(CLKDIV), 
			.enable(~RST), 
			.data_out(), 
			.data_valid(),
			.data_correct(fifo_WREN1),
			.data_wrong(RE_SIG),
			.data_all(D)
			);
		RCB_FRL_CMD_shift_MSG_CON CMD_shift_inst2
		(
			.data_in(input_reg1_wire),
			.clk(CLKDIV), 
			.enable(~RST), 
			.CON_P(CON_P),
			.CON_N(CON_N)
			);
endmodule
module RCB_FRL_CMD_shift_MSG
(
	data_in,
	clk, 
	enable, 
	data_out, 
	data_valid,
	data_correct,		
	data_wrong,
	data_all
	);
   parameter lock_pattern = 8'hff	;   
   parameter pack_size = 100;             
   parameter word_size = 8;          
   input     clk;                      
   input     enable;                 
   input [7:0] data_in;           
   output       data_valid;
   output [7:0] data_out;
	output		data_correct;
	output		data_wrong;
	output [39:0] data_all;
   reg [7:0] 	data_reg1;              
   reg [7:0] 	data_reg2;              
   reg [7:0] 	data_reg3;              
   reg [2:0] 	shift;                  
   reg 		    lock;                   
   reg [7:0] 	byte_count;             
   reg [2:0]    front_count;
   reg [7:0] 	data_out_tmp;           
   reg 	    	data_valid;
   reg [7:0] 	frame_length;      
   reg [7:0] 	data_out;               
	reg			data_correct;
	reg			data_wrong;
	reg [39:0]  data_all;
   wire 	end_pack = pack_size;   
	wire [7:0] CRC_ans;
	RCB_FRL_CRC_gen RCB_FRL_CRC_gen_inst ( .D({{8'h06},data_all}), .NewCRC(CRC_ans));
   always @(negedge clk)   
     begin
		if (!enable)
		begin
    	      data_out_tmp <= 8'h00;    
		end
		else
		begin
    	    case(shift)               
		    	3'h0 : data_out_tmp <= data_reg3;
		    	3'h1 : data_out_tmp <= ({data_reg3[6:0],data_reg2[7]});
		    	3'h2 : data_out_tmp <= ({data_reg3[5:0],data_reg2[7:6]});
		    	3'h3 : data_out_tmp <= ({data_reg3[4:0],data_reg2[7:5]});
		    	3'h4 : data_out_tmp <= ({data_reg3[3:0],data_reg2[7:4]});
		    	3'h5 : data_out_tmp <= ({data_reg3[2:0],data_reg2[7:3]});
		    	3'h6 : data_out_tmp <= ({data_reg3[1:0],data_reg2[7:2]});
		    	3'h7 : data_out_tmp <= ({data_reg3[0],data_reg2[7:1]});
		    	default : data_out_tmp <= data_reg3;
	        endcase
		 end
	 end
   always@(negedge clk)           
     begin
		 if(!enable || !lock)		    	      	 
			begin
    	      byte_count <= 0;                   
    	      front_count <= 0;
			end
    	 if(lock)
    	  begin
    	      byte_count <= byte_count + 1;      
    	      front_count <= front_count+1;
    	  end
     end
   always @(negedge clk)         
    begin
		if(!enable) 
	  		begin
        	data_reg1 <= 8'h00;           
        	data_reg2 <= 8'h00;           
        	data_reg3 <= 8'h00;
	  	end
		else 
	 		begin
        	data_reg1 <= data_in;     
        	data_reg2 <= data_reg1;   
        	data_reg3 <= data_reg2;  
 	  		end
    end
  always @(negedge clk)          
     begin
		if(!enable)    
	  		begin
             lock <= 0;
             shift <= 0;
             data_out <= 8'h00;  
             data_valid <= 0;
				 frame_length <= 0;
	  		end
	 	else   
	  		begin  
       			if(!lock)                
          			begin 
							  data_correct <= 1'b0;
							  data_wrong <= 1'b0;
		   				if(data_reg3 === 8'hf5 ) 
		       				begin
                       		lock <= 1;
                       		shift <= 3'h0;
		       				end
		   				else if({data_reg3[6:0],data_reg2[7]} === 8'hf5 ) 
               				begin
			     			lock <= 1;
			     			shift <= 3'h1;   
               				end
		    			else if({data_reg3[5:0],data_reg2[7:6]} === 8'hf5 ) 
			     			begin
			       			lock <= 1;
			       			shift <= 3'h2;   
			     			end
            			else if({data_reg3[4:0],data_reg2[7:5]} === 8'hf5 ) 
			    			begin
			       			lock <= 1;
			       			shift <= 3'h3;   
			    		    end
						else if({data_reg3[3:0],data_reg2[7:4]} === 8'hf5 ) 
			    			begin
                    		lock <= 1;
                    		shift <= 3'h4;   
			    			end
			 			else if({data_reg3[2:0],data_reg2[7:3]} === 8'hf5 )
                  			begin
				    		lock <= 1;
				    		shift <= 3'h5;   
                  		    end
			 			else if({data_reg3[1:0],data_reg2[7:2]} === 8'hf5) 
				   			begin
				    		lock <= 1;
				    		shift <= 3'h6;   
				   		    end
			 			else if({data_reg3[0],data_reg2[7:1]} === 8'hf5)    
				  			begin
				     		lock <= 1;
				     		shift <= 3'h7;   
			  			    end
	         		end    
	     		else if (lock)   
            	  begin                         	 	
		            if( byte_count == 8'h00)     		
					    begin
		               	data_valid <= 0;	
						data_out <= 8'hff;       
						end	
					else if(byte_count == 8'h01)     	
						begin
						data_valid <= 0;
						data_out <= data_out_tmp; 
						frame_length <= data_out_tmp;
						end
					else if(byte_count < frame_length + 8'h1)
					    begin
						data_valid <= 1;
						data_out <= data_out_tmp;
						if (byte_count == 8'h02)
						begin
							data_all[39:32] <= data_out_tmp;
						end
						else if (byte_count == 8'h03)
						begin
							data_all[31:24] <= data_out_tmp;
						end
						else if (byte_count == 8'h04)
						begin
							data_all[23:16] <= data_out_tmp;
						end
						else if (byte_count == 8'h05)
						begin
							data_all[15:8] <= data_out_tmp;
						end
						else if (byte_count == 8'h06)
						begin
							data_all[7:0] <= data_out_tmp;
						end
					end
					else if (byte_count >= frame_length + 8'h1)
						begin
							data_valid <= 0;
							lock <= 0;
							shift <= 0;
			            frame_length <= 0;
							if ( CRC_ans == data_out_tmp)
							begin
								data_correct <=1'b1;
							end
							else
							begin
								data_wrong <=1'b1;
							end
               			end
            	  end  
	      end     
     end    
endmodule
module RCB_FRL_CMD_shift_MSG_CON
(
	data_in,
	clk, 
	enable, 
	CON_P,
	CON_N
	);
   parameter lock_pattern = 8'hff	;   
   parameter pack_size = 100;             
   parameter word_size = 8;          
   input     clk;                      
   input     enable;                 
   input [7:0] data_in;           
		output CON_P, CON_N;
   reg [7:0] 	data_reg1;              
   reg [7:0] 	data_reg2;              
   reg [7:0] 	data_reg3;              
   reg [2:0] 	shift;                  
   reg 		    lock;                   
   reg [7:0] 	byte_count;             
   reg [2:0]    front_count;
   reg [7:0] 	data_out_tmp;           
   reg 	    	data_valid;
   reg [7:0] 	frame_length;      
   reg [7:0] 	data_out;               
	reg			data_correct;
	reg			data_wrong;
	reg [39:0]  data_all;
   wire 	end_pack = pack_size;   
	reg CON_P, CON_N;
   always @(negedge clk)   
     begin
		if (!enable)
		begin
    	      data_out_tmp <= 8'h00;    
		end
		else
		begin
    	    case(shift)               
		    	3'h0 : data_out_tmp <= data_reg3;
		    	3'h1 : data_out_tmp <= ({data_reg3[6:0],data_reg2[7]});
		    	3'h2 : data_out_tmp <= ({data_reg3[5:0],data_reg2[7:6]});
		    	3'h3 : data_out_tmp <= ({data_reg3[4:0],data_reg2[7:5]});
		    	3'h4 : data_out_tmp <= ({data_reg3[3:0],data_reg2[7:4]});
		    	3'h5 : data_out_tmp <= ({data_reg3[2:0],data_reg2[7:3]});
		    	3'h6 : data_out_tmp <= ({data_reg3[1:0],data_reg2[7:2]});
		    	3'h7 : data_out_tmp <= ({data_reg3[0],data_reg2[7:1]});
		    	default : data_out_tmp <= data_reg3;
	        endcase
		 end
	 end
   always @(negedge clk)         
    begin
		if(!enable) 
	  		begin
        	data_reg1 <= 8'h00;           
        	data_reg2 <= 8'h00;           
        	data_reg3 <= 8'h00;
	  	end
		else 
	 		begin
        	data_reg1 <= data_in;     
        	data_reg2 <= data_reg1;   
        	data_reg3 <= data_reg2;  
 	  		end
    end
  always @(negedge clk)          
     begin
		if(!enable)    
	  		begin
             lock <= 0;
             shift <= 0;
             data_out <= 8'h00;  
             data_valid <= 0;
				 frame_length <= 0;
	  		end
	 	else   
		begin
			if(data_reg3 === 8'h5f ) 
		       				begin
		                      CON_P <= 1'b1;
		       				end
		   				else if({data_reg3[6:0],data_reg2[7]} === 8'h5f ) 
               				begin
			     			 CON_P <= 1'b1;  
               				end
		    			else if({data_reg3[5:0],data_reg2[7:6]} === 8'h5f ) 
			     			begin
			       			 CON_P <= 1'b1;
			     			end
            			else if({data_reg3[4:0],data_reg2[7:5]} === 8'h5f ) 
			    			begin
			       			 CON_P <= 1'b1;
			    		    end
						else if({data_reg3[3:0],data_reg2[7:4]} === 8'h5f ) 
			    			begin
                    		 CON_P <= 1'b1;
			    			end
			 			else if({data_reg3[2:0],data_reg2[7:3]} === 8'h5f )
                  			begin
				    	 CON_P <= 1'b1;
                  		    end
			 			else if({data_reg3[1:0],data_reg2[7:2]} === 8'h5f) 
				   			begin
				    		 CON_P <= 1'b1;
				   		    end
			 			else if({data_reg3[0],data_reg2[7:1]} === 8'h5f)    
				  			begin
				     		 CON_P <= 1'b1;
			  			    end
							 else begin
							 CON_P <= 1'b0;
							end
			   				if(data_reg3 === 8'haf ) 
		       				begin
		                      CON_N <= 1'b1;
		       				end
		   				else if({data_reg3[6:0],data_reg2[7]} === 8'haf ) 
               				begin
			     			 CON_N <= 1'b1;  
               				end
		    			else if({data_reg3[5:0],data_reg2[7:6]} === 8'haf ) 
			     			begin
			       			 CON_N <= 1'b1;
			     			end
            			else if({data_reg3[4:0],data_reg2[7:5]} === 8'haf ) 
			    			begin
			       			 CON_N <= 1'b1;
			    		    end
						else if({data_reg3[3:0],data_reg2[7:4]} === 8'haf ) 
			    			begin
                    		 CON_N <= 1'b1;
			    			end
			 			else if({data_reg3[2:0],data_reg2[7:3]} === 8'haf )
                  			begin
				    	 CON_N <= 1'b1;
                  		    end
			 			else if({data_reg3[1:0],data_reg2[7:2]} === 8'haf )
				   			begin
				    		 CON_N <= 1'b1;
				   		    end
			 			else if({data_reg3[0],data_reg2[7:1]} === 8'haf    )
				  			begin
				     		 CON_N <= 1'b1;
			  			    end
							 else begin
							 CON_N <= 1'b0;
							end
	         		end    
	end
endmodule
`timescale 1ns / 1ps
module RCB_FRL_RX_MSG(CLK, CLKDIV, DATA_IN, DATA_OUT, RST, RE_SIG, EN_SIG, CON_P, CON_N);
	input CLK, CLKDIV;
	input [7:0] DATA_IN;
	output [39:0] DATA_OUT;
	output CON_P, CON_N;
	output RE_SIG, EN_SIG;
	input RST;
	wire [7:0] fifo_reg1;
	wire [39:0] D;
	RCB_FRL_channel_MSG inst_channel1 (
			.CLK(CLK), 
			.CLKDIV(CLKDIV), 
			.DATA_IN(DATA_IN), 
			.RST(RST), 
			.fifo_WREN1(EN_SIG), 
			.D(DATA_OUT), 
			.RE_SIG(RE_SIG), 
			.CON_P(CON_P), 
			.CON_N(CON_N)
		);
endmodule
module RCB_FRL_channel_MSG (CLK, CLKDIV, DATA_IN, RST, fifo_WREN1, D, RE_SIG, CON_P, CON_N);
	input CLK, CLKDIV, RST;
	input [7:0] DATA_IN;
	output fifo_WREN1, RE_SIG; 
	output [39:0] D;
	output CON_P, CON_N;
	wire [7:0] input_reg1_wire, input_reg1_wire_inv;
	wire CON_P, CON_N;
	assign input_reg1_wire = DATA_IN;
		RCB_FRL_CMD_shift_MSG CMD_shift_inst
		(
			.data_in(input_reg1_wire),
			.clk(CLKDIV), 
			.enable(~RST), 
			.data_out(), 
			.data_valid(),
			.data_correct(fifo_WREN1),
			.data_wrong(RE_SIG),
			.data_all(D)
			);
		RCB_FRL_CMD_shift_MSG_CON CMD_shift_inst2
		(
			.data_in(input_reg1_wire),
			.clk(CLKDIV), 
			.enable(~RST), 
			.CON_P(CON_P),
			.CON_N(CON_N)
			);
endmodule
module RCB_FRL_CMD_shift_MSG
(
	data_in,
	clk, 
	enable, 
	data_out, 
	data_valid,
	data_correct,		
	data_wrong,
	data_all
	);
   parameter lock_pattern = 8'hff	;   
   parameter pack_size = 100;             
   parameter word_size = 8;          
   input     clk;                      
   input     enable;                 
   input [7:0] data_in;           
   output       data_valid;
   output [7:0] data_out;
	output		data_correct;
	output		data_wrong;
	output [39:0] data_all;
   reg [7:0] 	data_reg1;              
   reg [7:0] 	data_reg2;              
   reg [7:0] 	data_reg3;              
   reg [2:0] 	shift;                  
   reg 		    lock;                   
   reg [7:0] 	byte_count;             
   reg [2:0]    front_count;
   reg [7:0] 	data_out_tmp;           
   reg 	    	data_valid;
   reg [7:0] 	frame_length;      
   reg [7:0] 	data_out;               
	reg			data_correct;
	reg			data_wrong;
	reg [39:0]  data_all;
   wire 	end_pack = pack_size;   
	wire [7:0] CRC_ans;
	RCB_FRL_CRC_gen RCB_FRL_CRC_gen_inst ( .D({{8'h06},data_all}), .NewCRC(CRC_ans));
   always @(negedge clk)   
     begin
		if (!enable)
		begin
    	      data_out_tmp <= 8'h00;    
		end
		else
		begin
    	    case(shift)               
		    	3'h0 : data_out_tmp <= data_reg3;
		    	3'h1 : data_out_tmp <= ({data_reg3[6:0],data_reg2[7]});
		    	3'h2 : data_out_tmp <= ({data_reg3[5:0],data_reg2[7:6]});
		    	3'h3 : data_out_tmp <= ({data_reg3[4:0],data_reg2[7:5]});
		    	3'h4 : data_out_tmp <= ({data_reg3[3:0],data_reg2[7:4]});
		    	3'h5 : data_out_tmp <= ({data_reg3[2:0],data_reg2[7:3]});
		    	3'h6 : data_out_tmp <= ({data_reg3[1:0],data_reg2[7:2]});
		    	3'h7 : data_out_tmp <= ({data_reg3[0],data_reg2[7:1]});
		    	default : data_out_tmp <= data_reg3;
	        endcase
		 end
	 end
   always@(negedge clk)           
     begin
		 if(!enable || !lock)		    	      	 
			begin
    	      byte_count <= 0;                   
    	      front_count <= 0;
			end
    	 if(lock)
    	  begin
    	      byte_count <= byte_count + 1;      
    	      front_count <= front_count+1;
    	  end
     end
   always @(negedge clk)         
    begin
		if(!enable) 
	  		begin
        	data_reg1 <= 8'h00;           
        	data_reg2 <= 8'h00;           
        	data_reg3 <= 8'h00;
	  	end
		else 
	 		begin
        	data_reg1 <= data_in;     
        	data_reg2 <= data_reg1;   
        	data_reg3 <= data_reg2;  
 	  		end
    end
  always @(negedge clk)          
     begin
		if(!enable)    
	  		begin
             lock <= 0;
             shift <= 0;
             data_out <= 8'h00;  
             data_valid <= 0;
				 frame_length <= 0;
	  		end
	 	else   
	  		begin  
       			if(!lock)                
          			begin 
							  data_correct <= 1'b0;
							  data_wrong <= 1'b0;
		   				if(data_reg3 === 8'hf5 ) 
		       				begin
                       		lock <= 1;
                       		shift <= 3'h0;
		       				end
		   				else if({data_reg3[6:0],data_reg2[7]} === 8'hf5 ) 
               				begin
			     			lock <= 1;
			     			shift <= 3'h1;   
               				end
		    			else if({data_reg3[5:0],data_reg2[7:6]} === 8'hf5 ) 
			     			begin
			       			lock <= 1;
			       			shift <= 3'h2;   
			     			end
            			else if({data_reg3[4:0],data_reg2[7:5]} === 8'hf5 ) 
			    			begin
			       			lock <= 1;
			       			shift <= 3'h3;   
			    		    end
						else if({data_reg3[3:0],data_reg2[7:4]} === 8'hf5 ) 
			    			begin
                    		lock <= 1;
                    		shift <= 3'h4;   
			    			end
			 			else if({data_reg3[2:0],data_reg2[7:3]} === 8'hf5 )
                  			begin
				    		lock <= 1;
				    		shift <= 3'h5;   
                  		    end
			 			else if({data_reg3[1:0],data_reg2[7:2]} === 8'hf5) 
				   			begin
				    		lock <= 1;
				    		shift <= 3'h6;   
				   		    end
			 			else if({data_reg3[0],data_reg2[7:1]} === 8'hf5)    
				  			begin
				     		lock <= 1;
				     		shift <= 3'h7;   
			  			    end
	         		end    
	     		else if (lock)   
            	  begin                         	 	
		            if( byte_count == 8'h00)     		
					    begin
		               	data_valid <= 0;	
						data_out <= 8'hff;       
						end	
					else if(byte_count == 8'h01)     	
						begin
						data_valid <= 0;
						data_out <= data_out_tmp; 
						frame_length <= data_out_tmp;
						end
					else if(byte_count < frame_length + 8'h1)
					    begin
						data_valid <= 1;
						data_out <= data_out_tmp;
						if (byte_count == 8'h02)
						begin
							data_all[39:32] <= data_out_tmp;
						end
						else if (byte_count == 8'h03)
						begin
							data_all[31:24] <= data_out_tmp;
						end
						else if (byte_count == 8'h04)
						begin
							data_all[23:16] <= data_out_tmp;
						end
						else if (byte_count == 8'h05)
						begin
							data_all[15:8] <= data_out_tmp;
						end
						else if (byte_count == 8'h06)
						begin
							data_all[7:0] <= data_out_tmp;
						end
					end
					else if (byte_count >= frame_length + 8'h1)
						begin
							data_valid <= 0;
							lock <= 0;
							shift <= 0;
			            frame_length <= 0;
							if ( CRC_ans == data_out_tmp)
							begin
								data_correct <=1'b1;
							end
							else
							begin
								data_wrong <=1'b1;
							end
               			end
            	  end  
	      end     
     end    
endmodule
module RCB_FRL_CMD_shift_MSG_CON
(
	data_in,
	clk, 
	enable, 
	CON_P,
	CON_N
	);
   parameter lock_pattern = 8'hff	;   
   parameter pack_size = 100;             
   parameter word_size = 8;          
   input     clk;                      
   input     enable;                 
   input [7:0] data_in;           
		output CON_P, CON_N;
   reg [7:0] 	data_reg1;              
   reg [7:0] 	data_reg2;              
   reg [7:0] 	data_reg3;              
   reg [2:0] 	shift;                  
   reg 		    lock;                   
   reg [7:0] 	byte_count;             
   reg [2:0]    front_count;
   reg [7:0] 	data_out_tmp;           
   reg 	    	data_valid;
   reg [7:0] 	frame_length;      
   reg [7:0] 	data_out;               
	reg			data_correct;
	reg			data_wrong;
	reg [39:0]  data_all;
   wire 	end_pack = pack_size;   
	reg CON_P, CON_N;
   always @(negedge clk)   
     begin
		if (!enable)
		begin
    	      data_out_tmp <= 8'h00;    
		end
		else
		begin
    	    case(shift)               
		    	3'h0 : data_out_tmp <= data_reg3;
		    	3'h1 : data_out_tmp <= ({data_reg3[6:0],data_reg2[7]});
		    	3'h2 : data_out_tmp <= ({data_reg3[5:0],data_reg2[7:6]});
		    	3'h3 : data_out_tmp <= ({data_reg3[4:0],data_reg2[7:5]});
		    	3'h4 : data_out_tmp <= ({data_reg3[3:0],data_reg2[7:4]});
		    	3'h5 : data_out_tmp <= ({data_reg3[2:0],data_reg2[7:3]});
		    	3'h6 : data_out_tmp <= ({data_reg3[1:0],data_reg2[7:2]});
		    	3'h7 : data_out_tmp <= ({data_reg3[0],data_reg2[7:1]});
		    	default : data_out_tmp <= data_reg3;
	        endcase
		 end
	 end
   always @(negedge clk)         
    begin
		if(!enable) 
	  		begin
        	data_reg1 <= 8'h00;           
        	data_reg2 <= 8'h00;           
        	data_reg3 <= 8'h00;
	  	end
		else 
	 		begin
        	data_reg1 <= data_in;     
        	data_reg2 <= data_reg1;   
        	data_reg3 <= data_reg2;  
 	  		end
    end
  always @(negedge clk)          
     begin
		if(!enable)    
	  		begin
             lock <= 0;
             shift <= 0;
             data_out <= 8'h00;  
             data_valid <= 0;
				 frame_length <= 0;
	  		end
	 	else   
		begin
			if(data_reg3 === 8'h5f ) 
		       				begin
		                      CON_P <= 1'b1;
		       				end
		   				else if({data_reg3[6:0],data_reg2[7]} === 8'h5f ) 
               				begin
			     			 CON_P <= 1'b1;  
               				end
		    			else if({data_reg3[5:0],data_reg2[7:6]} === 8'h5f ) 
			     			begin
			       			 CON_P <= 1'b1;
			     			end
            			else if({data_reg3[4:0],data_reg2[7:5]} === 8'h5f ) 
			    			begin
			       			 CON_P <= 1'b1;
			    		    end
						else if({data_reg3[3:0],data_reg2[7:4]} === 8'h5f ) 
			    			begin
                    		 CON_P <= 1'b1;
			    			end
			 			else if({data_reg3[2:0],data_reg2[7:3]} === 8'h5f )
                  			begin
				    	 CON_P <= 1'b1;
                  		    end
			 			else if({data_reg3[1:0],data_reg2[7:2]} === 8'h5f) 
				   			begin
				    		 CON_P <= 1'b1;
				   		    end
			 			else if({data_reg3[0],data_reg2[7:1]} === 8'h5f)    
				  			begin
				     		 CON_P <= 1'b1;
			  			    end
							 else begin
							 CON_P <= 1'b0;
							end
			   				if(data_reg3 === 8'haf ) 
		       				begin
		                      CON_N <= 1'b1;
		       				end
		   				else if({data_reg3[6:0],data_reg2[7]} === 8'haf ) 
               				begin
			     			 CON_N <= 1'b1;  
               				end
		    			else if({data_reg3[5:0],data_reg2[7:6]} === 8'haf ) 
			     			begin
			       			 CON_N <= 1'b1;
			     			end
            			else if({data_reg3[4:0],data_reg2[7:5]} === 8'haf ) 
			    			begin
			       			 CON_N <= 1'b1;
			    		    end
						else if({data_reg3[3:0],data_reg2[7:4]} === 8'haf ) 
			    			begin
                    		 CON_N <= 1'b1;
			    			end
			 			else if({data_reg3[2:0],data_reg2[7:3]} === 8'haf )
                  			begin
				    	 CON_N <= 1'b1;
                  		    end
			 			else if({data_reg3[1:0],data_reg2[7:2]} === 8'haf )
				   			begin
				    		 CON_N <= 1'b1;
				   		    end
			 			else if({data_reg3[0],data_reg2[7:1]} === 8'haf    )
				  			begin
				     		 CON_N <= 1'b1;
			  			    end
							 else begin
							 CON_N <= 1'b0;
							end
	         		end    
	end
endmodule
