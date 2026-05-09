`timescale 1ns / 1ps
`timescale 1ns / 1ps
module RCB_FRL_RXMSG_ACK_Decoder(
   input     	clk,                      
   input     	enable,                 
   input [7:0]	data_in,           
	output reg	CON_P, 
	output reg	CON_N
	);
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
