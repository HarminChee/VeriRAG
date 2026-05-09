	module daala_idct4_stream_v1_0_M00_AXIS #
	(
		parameter integer C_M_AXIS_TDATA_WIDTH	= 32,
		parameter integer C_M_START_COUNT	= 32
	)
	(
		input wire  M_AXIS_ACLK,
		input wire  M_AXIS_ARESETN,
		output wire  M_AXIS_TVALID,
		output wire [C_M_AXIS_TDATA_WIDTH-1 : 0] M_AXIS_TDATA,
		output wire [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] M_AXIS_TSTRB,
		output wire  M_AXIS_TLAST,
		input wire  M_AXIS_TREADY
	);
	localparam NUMBER_OF_OUTPUT_WORDS = 8;                                               
	function integer clogb2 (input integer bit_depth);                                   
	  begin                                                                              
	    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                                      
	      bit_depth = bit_depth >> 1;                                                    
	  end                                                                                
	endfunction                                                                          
	localparam integer WAIT_COUNT_BITS = clogb2(C_M_START_COUNT-1);                      
	localparam bit_num  = clogb2(NUMBER_OF_OUTPUT_WORDS);                                
	parameter [1:0] IDLE = 2'b00,        
	                INIT_COUNTER  = 2'b01, 
	                SEND_STREAM   = 2'b10; 
	reg [1:0] mst_exec_state;                                                            
	reg [bit_num-1:0] read_pointer;                                                      
	reg [WAIT_COUNT_BITS-1 : 0] 	count;
	wire  	axis_tvalid;
	reg  	axis_tvalid_delay;
	wire  	axis_tlast;
	reg  	axis_tlast_delay;
	reg [C_M_AXIS_TDATA_WIDTH-1 : 0] 	stream_data_out;
	wire  	tx_en;
	reg  	tx_done;
	assign M_AXIS_TVALID	= axis_tvalid_delay;
	assign M_AXIS_TDATA	= stream_data_out;
	assign M_AXIS_TLAST	= axis_tlast_delay;
	assign M_AXIS_TSTRB	= {(C_M_AXIS_TDATA_WIDTH/8){1'b1}};
	always @(posedge M_AXIS_ACLK)                                             
	begin                                                                     
	  if (!M_AXIS_ARESETN)                                                    
	    begin                                                                 
	      mst_exec_state <= IDLE;                                             
	      count    <= 0;                                                      
	    end                                                                   
	  else                                                                    
	    case (mst_exec_state)                                                 
	      IDLE:                                                               
	        if ( count == 0 )                                                 
	          begin                                                           
	            mst_exec_state  <= INIT_COUNTER;                              
	          end                                                             
	        else                                                              
	          begin                                                           
	            mst_exec_state  <= IDLE;                                      
	          end                                                             
	      INIT_COUNTER:                                                       
	        if ( count == C_M_START_COUNT - 1 )                               
	          begin                                                           
	            mst_exec_state  <= SEND_STREAM;                               
	          end                                                             
	        else                                                              
	          begin                                                           
	            count <= count + 1;                                           
	            mst_exec_state  <= INIT_COUNTER;                              
	          end                                                             
	      SEND_STREAM:                                                        
	        if (tx_done)                                                      
	          begin                                                           
	            mst_exec_state <= IDLE;                                       
	          end                                                             
	        else                                                              
	          begin                                                           
	            mst_exec_state <= SEND_STREAM;                                
	          end                                                             
	    endcase                                                               
	end                                                                       
	assign axis_tvalid = ((mst_exec_state == SEND_STREAM) && (read_pointer < NUMBER_OF_OUTPUT_WORDS));
	assign axis_tlast = (read_pointer == NUMBER_OF_OUTPUT_WORDS-1);                                
	always @(posedge M_AXIS_ACLK)                                                                  
	begin                                                                                          
	  if (!M_AXIS_ARESETN)                                                                         
	    begin                                                                                      
	      axis_tvalid_delay <= 1'b0;                                                               
	      axis_tlast_delay <= 1'b0;                                                                
	    end                                                                                        
	  else                                                                                         
	    begin                                                                                      
	      axis_tvalid_delay <= axis_tvalid;                                                        
	      axis_tlast_delay <= axis_tlast;                                                          
	    end                                                                                        
	end                                                                                            
	always@(posedge M_AXIS_ACLK)                                               
	begin                                                                            
	  if(!M_AXIS_ARESETN)                                                            
	    begin                                                                        
	      read_pointer <= 0;                                                         
	      tx_done <= 1'b0;                                                           
	    end                                                                          
	  else                                                                           
	    if (read_pointer <= NUMBER_OF_OUTPUT_WORDS-1)                                
	      begin                                                                      
	        if (tx_en)                                                               
	          begin                                                                  
	            read_pointer <= read_pointer + 1;                                    
	            tx_done <= 1'b0;                                                     
	          end                                                                    
	      end                                                                        
	    else if (read_pointer == NUMBER_OF_OUTPUT_WORDS)                             
	      begin                                                                      
	        tx_done <= 1'b1;                                                         
	      end                                                                        
	end                                                                              
	assign tx_en = M_AXIS_TREADY && axis_tvalid;   
	    always @( posedge M_AXIS_ACLK )                  
	    begin                                            
	      if(!M_AXIS_ARESETN)                            
	        begin                                        
	          stream_data_out <= 1;                      
	        end                                          
	      else if (tx_en)
	        begin                                        
	          stream_data_out <= read_pointer + 32'b1;   
	        end                                          
	    end                                              
	endmodule
	module daala_idct4_stream_v1_0_M00_AXIS #
	(
		parameter integer C_M_AXIS_TDATA_WIDTH	= 32,
		parameter integer C_M_START_COUNT	= 32
	)
	(
		input wire  M_AXIS_ACLK,
		input wire  M_AXIS_ARESETN,
		output wire  M_AXIS_TVALID,
		output wire [C_M_AXIS_TDATA_WIDTH-1 : 0] M_AXIS_TDATA,
		output wire [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] M_AXIS_TSTRB,
		output wire  M_AXIS_TLAST,
		input wire  M_AXIS_TREADY
	);
	localparam NUMBER_OF_OUTPUT_WORDS = 8;                                               
	function integer clogb2 (input integer bit_depth);                                   
	  begin                                                                              
	    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                                      
	      bit_depth = bit_depth >> 1;                                                    
	  end                                                                                
	endfunction                                                                          
	localparam integer WAIT_COUNT_BITS = clogb2(C_M_START_COUNT-1);                      
	localparam bit_num  = clogb2(NUMBER_OF_OUTPUT_WORDS);                                
	parameter [1:0] IDLE = 2'b00,        
	                INIT_COUNTER  = 2'b01, 
	                SEND_STREAM   = 2'b10; 
	reg [1:0] mst_exec_state;                                                            
	reg [bit_num-1:0] read_pointer;                                                      
	reg [WAIT_COUNT_BITS-1 : 0] 	count;
	wire  	axis_tvalid;
	reg  	axis_tvalid_delay;
	wire  	axis_tlast;
	reg  	axis_tlast_delay;
	reg [C_M_AXIS_TDATA_WIDTH-1 : 0] 	stream_data_out;
	wire  	tx_en;
	reg  	tx_done;
	assign M_AXIS_TVALID	= axis_tvalid_delay;
	assign M_AXIS_TDATA	= stream_data_out;
	assign M_AXIS_TLAST	= axis_tlast_delay;
	assign M_AXIS_TSTRB	= {(C_M_AXIS_TDATA_WIDTH/8){1'b1}};
	always @(posedge M_AXIS_ACLK)                                             
	begin                                                                     
	  if (!M_AXIS_ARESETN)                                                    
	    begin                                                                 
	      mst_exec_state <= IDLE;                                             
	      count    <= 0;                                                      
	    end                                                                   
	  else                                                                    
	    case (mst_exec_state)                                                 
	      IDLE:                                                               
	        if ( count == 0 )                                                 
	          begin                                                           
	            mst_exec_state  <= INIT_COUNTER;                              
	          end                                                             
	        else                                                              
	          begin                                                           
	            mst_exec_state  <= IDLE;                                      
	          end                                                             
	      INIT_COUNTER:                                                       
	        if ( count == C_M_START_COUNT - 1 )                               
	          begin                                                           
	            mst_exec_state  <= SEND_STREAM;                               
	          end                                                             
	        else                                                              
	          begin                                                           
	            count <= count + 1;                                           
	            mst_exec_state  <= INIT_COUNTER;                              
	          end                                                             
	      SEND_STREAM:                                                        
	        if (tx_done)                                                      
	          begin                                                           
	            mst_exec_state <= IDLE;                                       
	          end                                                             
	        else                                                              
	          begin                                                           
	            mst_exec_state <= SEND_STREAM;                                
	          end                                                             
	    endcase                                                               
	end                                                                       
	assign axis_tvalid = ((mst_exec_state == SEND_STREAM) && (read_pointer < NUMBER_OF_OUTPUT_WORDS));
	assign axis_tlast = (read_pointer == NUMBER_OF_OUTPUT_WORDS-1);                                
	always @(posedge M_AXIS_ACLK)                                                                  
	begin                                                                                          
	  if (!M_AXIS_ARESETN)                                                                         
	    begin                                                                                      
	      axis_tvalid_delay <= 1'b0;                                                               
	      axis_tlast_delay <= 1'b0;                                                                
	    end                                                                                        
	  else                                                                                         
	    begin                                                                                      
	      axis_tvalid_delay <= axis_tvalid;                                                        
	      axis_tlast_delay <= axis_tlast;                                                          
	    end                                                                                        
	end                                                                                            
	always@(posedge M_AXIS_ACLK)                                               
	begin                                                                            
	  if(!M_AXIS_ARESETN)                                                            
	    begin                                                                        
	      read_pointer <= 0;                                                         
	      tx_done <= 1'b0;                                                           
	    end                                                                          
	  else                                                                           
	    if (read_pointer <= NUMBER_OF_OUTPUT_WORDS-1)                                
	      begin                                                                      
	        if (tx_en)                                                               
	          begin                                                                  
	            read_pointer <= read_pointer + 1;                                    
	            tx_done <= 1'b0;                                                     
	          end                                                                    
	      end                                                                        
	    else if (read_pointer == NUMBER_OF_OUTPUT_WORDS)                             
	      begin                                                                      
	        tx_done <= 1'b1;                                                         
	      end                                                                        
	end                                                                              
	assign tx_en = M_AXIS_TREADY && axis_tvalid;   
	    always @( posedge M_AXIS_ACLK )                  
	    begin                                            
	      if(!M_AXIS_ARESETN)                            
	        begin                                        
	          stream_data_out <= 1;                      
	        end                                          
	      else if (tx_en)
	        begin                                        
	          stream_data_out <= read_pointer + 32'b1;   
	        end                                          
	    end                                              
	endmodule
