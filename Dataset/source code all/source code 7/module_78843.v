`timescale 1ns / 1ps
module RCB_FRL_channel (CLK, CLKDIV, DATA_IN, RST, fifo_WREN1, fifo_reg1);
	input CLK, CLKDIV, RST;
	input [7:0] DATA_IN;
	output fifo_WREN1;
	output [7:0] fifo_reg1;
	reg [15:0] input_reg1;
	wire [7:0] input_reg1_wire, input_reg1_wire_inv;
	assign input_reg1_wire = DATA_IN;
	RCB_FRL_CMD_shift RCB_FRL_CMD_shift_inst
	(
		.data_in(input_reg1_wire),
		.clk(CLKDIV), 
		.enable(~RST), 
		.data_out(fifo_reg1), 
		.data_valid(fifo_WREN1)
	);
endmodule
module RCB_FRL_fifo_RX (ALMOSTEMPTY, ALMOSTFULL, DO, EMPTY, FULL, DI, RDCLK, RDEN, WRCLK, WREN, RST);
	output 	ALMOSTEMPTY, ALMOSTFULL, EMPTY, FULL;
	output 	[7:0] DO;
	input		[7:0] DI;
	input		RDCLK, RDEN, WRCLK, WREN, RST;
	wire [7:0] temp1;
	FIFO18  FIFO18_inst (
		.ALMOSTEMPTY(ALMOSTEMPTY), 
		.ALMOSTFULL(ALMOSTFULL), 
		.DO({temp1, DO[7:0]}), 
		.DOP(), 
		.EMPTY(EMPTY), 
		.FULL(FULL), 
		.RDCOUNT(), 
		.RDERR(), 
		.WRCOUNT(), 
		.WRERR(), 
		.DI({8'h0,DI[7:0]}), 
		.DIP(), 
		.RDCLK(RDCLK), 
		.RDEN(RDEN), 
		.RST(RST), 
		.WRCLK(WRCLK), 
		.WREN(WREN) 
	);
	defparam FIFO18_inst.DATA_WIDTH = 9;
	defparam FIFO18_inst.ALMOST_EMPTY_OFFSET = 6;
endmodule
module RCB_FRL_CMD_shift
(
	data_in,
	clk, 
	enable, 
	data_out, 
	data_valid
	);
   input     clk;                      
   input     enable;                 
   input [7:0] data_in;           
   output       data_valid;
   output [7:0] data_out;
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
					if(byte_count < 8) 
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
`timescale 1ns / 1ps
module RCB_FRL_RX(CLK, CLKDIV, DATA_IN, DATA_OUT, RST, RDCLK, RDEN, ALMOSTEMPTY, fifo_WREN);
	input CLK, CLKDIV;
	input [31:0] DATA_IN;
	output [31:0] DATA_OUT;
	output ALMOSTEMPTY;
	output fifo_WREN;
	input RST, RDCLK, RDEN;
	wire [31:0] DATA_IN;
	wire [7:0] fifo_reg1;
	wire [7:0] fifo_reg2;
	wire [7:0] fifo_reg3;
	wire [7:0] fifo_reg4;
	RCB_FRL_channel inst_channel1 (
			.CLK(CLK), .CLKDIV(CLKDIV), .DATA_IN(DATA_IN[7:0]), .RST(RST), .fifo_WREN1(fifo_WREN1), 
			.fifo_reg1(fifo_reg1[7:0]));
	RCB_FRL_channel inst_channel2 (
			.CLK(CLK), .CLKDIV(CLKDIV), .DATA_IN(DATA_IN[15:8]), .RST(RST), .fifo_WREN1(fifo_WREN2), 
			.fifo_reg1(fifo_reg2[7:0]));
	RCB_FRL_channel inst_channel3 (
			.CLK(CLK), .CLKDIV(CLKDIV), .DATA_IN(DATA_IN[23:16]), .RST(RST), .fifo_WREN1(fifo_WREN3), 
			.fifo_reg1(fifo_reg3[7:0]));
	RCB_FRL_channel inst_channel4 (
			.CLK(CLK), .CLKDIV(CLKDIV), .DATA_IN(DATA_IN[31:24]), .RST(RST), .fifo_WREN1(fifo_WREN4), 
			.fifo_reg1(fifo_reg4[7:0]));
	assign fifo_WREN = fifo_WREN1 & fifo_WREN2 & fifo_WREN3 & fifo_WREN4;
	wire [31:0] DATA_OUT;
	wire ALMOSTEMPTY1, ALMOSTEMPTY2, ALMOSTEMPTY3, ALMOSTEMPTY4;
	RCB_FRL_fifo_RX inst_fifoRX1(
				.ALMOSTEMPTY(ALMOSTEMPTY1), .ALMOSTFULL(), .DO(DATA_OUT [7:0]), .EMPTY(), .FULL(),
				.DI(fifo_reg1[7:0]), .RDCLK(RDCLK), .RDEN(RDEN), .WRCLK(CLKDIV), .WREN(fifo_WREN1), .RST(RST));
	RCB_FRL_fifo_RX inst_fifoRX2(
				.ALMOSTEMPTY(ALMOSTEMPTY2), .ALMOSTFULL(), .DO(DATA_OUT [15:8]), .EMPTY(), .FULL(),
				.DI(fifo_reg2[7:0]), .RDCLK(RDCLK), .RDEN(RDEN), .WRCLK(CLKDIV), .WREN(fifo_WREN2), .RST(RST));
	RCB_FRL_fifo_RX inst_fifoRX3(
				.ALMOSTEMPTY(ALMOSTEMPTY3), .ALMOSTFULL(), .DO(DATA_OUT [23:16]), .EMPTY(), .FULL(),
				.DI(fifo_reg3[7:0]), .RDCLK(RDCLK), .RDEN(RDEN), .WRCLK(CLKDIV), .WREN(fifo_WREN3), .RST(RST));
	RCB_FRL_fifo_RX inst_fifoRX4(
				.ALMOSTEMPTY(ALMOSTEMPTY4), .ALMOSTFULL(), .DO(DATA_OUT [31:24]), .EMPTY(), .FULL(),
				.DI(fifo_reg4[7:0]), .RDCLK(RDCLK), .RDEN(RDEN), .WRCLK(CLKDIV), .WREN(fifo_WREN4), .RST(RST));
	wire ALMOSTEMPTY;
	assign ALMOSTEMPTY = ALMOSTEMPTY1 | ALMOSTEMPTY2 | ALMOSTEMPTY3 | ALMOSTEMPTY4;
endmodule
module RCB_FRL_channel (CLK, CLKDIV, DATA_IN, RST, fifo_WREN1, fifo_reg1);
	input CLK, CLKDIV, RST;
	input [7:0] DATA_IN;
	output fifo_WREN1;
	output [7:0] fifo_reg1;
	reg [15:0] input_reg1;
	wire [7:0] input_reg1_wire, input_reg1_wire_inv;
	assign input_reg1_wire = DATA_IN;
	RCB_FRL_CMD_shift RCB_FRL_CMD_shift_inst
	(
		.data_in(input_reg1_wire),
		.clk(CLKDIV), 
		.enable(~RST), 
		.data_out(fifo_reg1), 
		.data_valid(fifo_WREN1)
	);
endmodule
module RCB_FRL_fifo_RX (ALMOSTEMPTY, ALMOSTFULL, DO, EMPTY, FULL, DI, RDCLK, RDEN, WRCLK, WREN, RST);
	output 	ALMOSTEMPTY, ALMOSTFULL, EMPTY, FULL;
	output 	[7:0] DO;
	input		[7:0] DI;
	input		RDCLK, RDEN, WRCLK, WREN, RST;
	wire [7:0] temp1;
	FIFO18  FIFO18_inst (
		.ALMOSTEMPTY(ALMOSTEMPTY), 
		.ALMOSTFULL(ALMOSTFULL), 
		.DO({temp1, DO[7:0]}), 
		.DOP(), 
		.EMPTY(EMPTY), 
		.FULL(FULL), 
		.RDCOUNT(), 
		.RDERR(), 
		.WRCOUNT(), 
		.WRERR(), 
		.DI({8'h0,DI[7:0]}), 
		.DIP(), 
		.RDCLK(RDCLK), 
		.RDEN(RDEN), 
		.RST(RST), 
		.WRCLK(WRCLK), 
		.WREN(WREN) 
	);
	defparam FIFO18_inst.DATA_WIDTH = 9;
	defparam FIFO18_inst.ALMOST_EMPTY_OFFSET = 6;
endmodule
module RCB_FRL_CMD_shift
(
	data_in,
	clk, 
	enable, 
	data_out, 
	data_valid
	);
   input     clk;                      
   input     enable;                 
   input [7:0] data_in;           
   output       data_valid;
   output [7:0] data_out;
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
					if(byte_count < 8) 
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
