`timescale 1ns / 1ps
`timescale 1ns / 1ps
module RCB_FRL_BYTE_Alignment(
		input     clk,                      
		input     enable,                 
		input [7:0] data_in,           
		output reg		data_valid,
		output reg [7:0]	data_out
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
   always @(negedge clk)   
     begin
		if (!enable)begin
    	      data_out_tmp <= 8'h00;    
				end
		else
		begin
    	    case(shift)               
		    	3'h0 : data_out_tmp <= data_reg1;
		    	3'h1 : data_out_tmp <= ({data_reg1[6:0],data_in[7]});
		    	3'h2 : data_out_tmp <= ({data_reg1[5:0],data_in[7:6]});
		    	3'h3 : data_out_tmp <= ({data_reg1[4:0],data_in[7:5]});
		    	3'h4 : data_out_tmp <= ({data_reg1[3:0],data_in[7:4]});
		    	3'h5 : data_out_tmp <= ({data_reg1[2:0],data_in[7:3]});
		    	3'h6 : data_out_tmp <= ({data_reg1[1:0],data_in[7:2]});
		    	3'h7 : data_out_tmp <= ({data_reg1[0],data_in[7:1]});
		    	default : data_out_tmp <= data_reg1;
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
		   				if(data_reg3 === 8'hf5 & data_reg2 === 8'h08) 
		       				begin
                       		lock <= 1;
                       		shift <= 3'h0;
		       				end
		   				else if({data_reg3[6:0],data_reg2[7]} === 8'hf5 & {data_reg2[6:0],data_reg1[7]} === 8'h08 ) 
               				begin
			     			lock <= 1;
			     			shift <= 3'h1;   
               				end
		    			else if({data_reg3[5:0],data_reg2[7:6]} === 8'hf5 & {data_reg2[5:0],data_reg1[7:6]} === 8'h08) 
			     			begin
			       			lock <= 1;
			       			shift <= 3'h2;   
			     			end
            			else if({data_reg3[4:0],data_reg2[7:5]} === 8'hf5 & {data_reg2[4:0],data_reg1[7:5]} === 8'h08) 
			    			begin
			       			lock <= 1;
			       			shift <= 3'h3;   
			    		    end
						else if({data_reg3[3:0],data_reg2[7:4]} === 8'hf5 & {data_reg2[3:0],data_reg1[7:4]} === 8'h08) 
			    			begin
                    		lock <= 1;
                    		shift <= 3'h4;   
			    			end
			 			else if({data_reg3[2:0],data_reg2[7:3]} === 8'hf5 & {data_reg2[2:0],data_reg1[7:3]} === 8'h08)
                  			begin
				    		lock <= 1;
				    		shift <= 3'h5;   
                  		    end
			 			else if({data_reg3[1:0],data_reg2[7:2]} === 8'hf5 & {data_reg2[1:0],data_reg1[7:2]} === 8'h08) 
				   			begin
				    		lock <= 1;
				    		shift <= 3'h6;   
				   		    end
			 			else if({data_reg3[0],data_reg2[7:1]} === 8'hf5 & {data_reg2[0],data_reg1[7:1]} === 8'h08)    
				  			begin
				     		lock <= 1;
				     		shift <= 3'h7;   
			  			    end
	         		end    
	     		else if (lock)   
            	  begin                         	 	
					if(byte_count < 29) 
					    begin
						data_valid <= 1;
						data_out <= data_out_tmp; 
						end
					else
						begin
			 			data_valid <= 0;
			 			lock <= 0;
			 			shift <= 0;
			            frame_length <= 0;
               			end
            	  end  
	      end     
     end    
endmodule
