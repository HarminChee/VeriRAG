`timescale 1ns / 1ps
`timescale 1ns / 1ps
module RCB_FRL_RXMSG_Byte_Alignment(   
		input     	clk,                      
		input     	enable,                 
		input [7:0]	data_in,           
		output reg		data_valid,
		output reg [7:0]	data_out,
		output reg		data_correct,
		output reg		data_wrong,
		output reg [39:0]	data_all
	);
   reg [7:0] 	data_reg1;              
   reg [7:0] 	data_reg2;              
   reg [7:0] 	data_reg3;              
   reg [2:0] 	shift;                  
   reg 		    lock;                   
   reg [7:0] 	byte_count;             
   reg [2:0]    front_count;
   reg [7:0] 	data_out_tmp;           
   reg [7:0] 	frame_length;      
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
