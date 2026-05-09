`timescale 1ns / 1ps
`timescale 1ns / 1ps
module Ps2Interface#(
    parameter SYSCLK_FREQUENCY_HZ = 100000000
  )(
  ps2_clk,
  ps2_data,
  clk,
  rst,
  tx_data,
  tx_valid,
  rx_data,
  rx_valid,
  busy,
  err
);
  inout ps2_clk, ps2_data;
  input clk, rst;
  input [7:0] tx_data;
  input tx_valid;
  output reg [7:0] rx_data;
  output reg rx_valid;
  output busy;
  output reg err;
  parameter CLOCK_CNT_100US = (100*1000) / (1000000000/SYSCLK_FREQUENCY_HZ);
  parameter CLOCK_CNT_20US = (20*1000) / (1000000000/SYSCLK_FREQUENCY_HZ);
  parameter DEBOUNCE_DELAY = 15;
  parameter BITS_NUM = 11;
  parameter [0:0] parity_table [0:255] = {    
    1'b1,1'b0,1'b0,1'b1,1'b0,1'b1,1'b1,1'b0,
    1'b0,1'b1,1'b1,1'b0,1'b1,1'b0,1'b0,1'b1,
    1'b0,1'b1,1'b1,1'b0,1'b1,1'b0,1'b0,1'b1,
    1'b1,1'b0,1'b0,1'b1,1'b0,1'b1,1'b1,1'b0,
    1'b0,1'b1,1'b1,1'b0,1'b1,1'b0,1'b0,1'b1,
    1'b1,1'b0,1'b0,1'b1,1'b0,1'b1,1'b1,1'b0,
    1'b1,1'b0,1'b0,1'b1,1'b0,1'b1,1'b1,1'b0,
    1'b0,1'b1,1'b1,1'b0,1'b1,1'b0,1'b0,1'b1,
    1'b0,1'b1,1'b1,1'b0,1'b1,1'b0,1'b0,1'b1,
    1'b1,1'b0,1'b0,1'b1,1'b0,1'b1,1'b1,1'b0,
    1'b1,1'b0,1'b0,1'b1,1'b0,1'b1,1'b1,1'b0,
    1'b0,1'b1,1'b1,1'b0,1'b1,1'b0,1'b0,1'b1,
    1'b1,1'b0,1'b0,1'b1,1'b0,1'b1,1'b1,1'b0,
    1'b0,1'b1,1'b1,1'b0,1'b1,1'b0,1'b0,1'b1,
    1'b0,1'b1,1'b1,1'b0,1'b1,1'b0,1'b0,1'b1,
    1'b1,1'b0,1'b0,1'b1,1'b0,1'b1,1'b1,1'b0,
    1'b0,1'b1,1'b1,1'b0,1'b1,1'b0,1'b0,1'b1,
    1'b1,1'b0,1'b0,1'b1,1'b0,1'b1,1'b1,1'b0,
    1'b1,1'b0,1'b0,1'b1,1'b0,1'b1,1'b1,1'b0,
    1'b0,1'b1,1'b1,1'b0,1'b1,1'b0,1'b0,1'b1,
    1'b1,1'b0,1'b0,1'b1,1'b0,1'b1,1'b1,1'b0,
    1'b0,1'b1,1'b1,1'b0,1'b1,1'b0,1'b0,1'b1,
    1'b0,1'b1,1'b1,1'b0,1'b1,1'b0,1'b0,1'b1,
    1'b1,1'b0,1'b0,1'b1,1'b0,1'b1,1'b1,1'b0,
    1'b1,1'b0,1'b0,1'b1,1'b0,1'b1,1'b1,1'b0,
    1'b0,1'b1,1'b1,1'b0,1'b1,1'b0,1'b0,1'b1,
    1'b0,1'b1,1'b1,1'b0,1'b1,1'b0,1'b0,1'b1,
    1'b1,1'b0,1'b0,1'b1,1'b0,1'b1,1'b1,1'b0,
    1'b0,1'b1,1'b1,1'b0,1'b1,1'b0,1'b0,1'b1,
    1'b1,1'b0,1'b0,1'b1,1'b0,1'b1,1'b1,1'b0,
    1'b1,1'b0,1'b0,1'b1,1'b0,1'b1,1'b1,1'b0,
    1'b0,1'b1,1'b1,1'b0,1'b1,1'b0,1'b0,1'b1
  };
  parameter IDLE                        = 4'd0;
  parameter RX_NEG_EDGE                 = 4'd1;
  parameter RX_CLK_LOW                  = 4'd2;
  parameter RX_CLK_HIGH                 = 4'd3;
  parameter TX_FORCE_CLK_LOW            = 4'd4;
  parameter TX_BRING_DATA_LOW           = 4'd5;
  parameter TX_RELEASE_CLK              = 4'd6;
  parameter TX_WAIT_FIRTS_NEG_EDGE      = 4'd7;
  parameter TX_CLK_LOW                  = 4'd8;
  parameter TX_WAIT_POS_EDGE            = 4'd9;
  parameter TX_CLK_HIGH                 = 4'd10;
  parameter TX_WAIT_POS_EDGE_BEFORE_ACK = 4'd11;
  parameter TX_WAIT_ACK                 = 4'd12;
  parameter TX_RECEIVED_ACK             = 4'd13;
  parameter TX_ERROR_NO_ACK             = 4'd14;
  reg [10:0] frame;
  wire rx_parity;
  wire ps2_clk_in, ps2_data_in;
  reg clk_inter, ps2_clk_s, data_inter, ps2_data_s;
  reg [3:0] clk_count, data_count;
  reg ps2_clk_en, ps2_clk_en_next, ps2_data_en, ps2_data_en_next;
  reg ps2_clk_out, ps2_clk_out_next, ps2_data_out, ps2_data_out_next;
  reg err_next;
  reg [3:0] state, state_next;
  reg rx_finish;
  reg [3:0] bits_count;
  reg [13:0] counter, counter_next;
  IOBUF IOBUF_inst_0(
    .O(ps2_clk_in),
    .IO(ps2_clk),
    .I(ps2_clk_out),
    .T(~ps2_clk_en)
  );
  IOBUF IOBUF_inst_1(
    .O(ps2_data_in),
    .IO(ps2_data),
    .I(ps2_data_out),
    .T(~ps2_data_en)
  );
  assign busy = (state==IDLE)?1'b0:1'b1;
  always @ (posedge clk, posedge rst)begin
    if(rst)begin
	  rx_data <= 0;
	  rx_valid <= 1'b0;
	end else if(rx_finish==1'b1)begin                       
	  rx_data <= frame[8:1];                                
	  rx_valid <= 1'b1;
	end else begin
	  rx_data <= rx_data;
	  rx_valid <= 1'b0;
	end
  end
  assign rx_parity = parity_table[frame[8:1]];
  assign tx_parity = parity_table[tx_data];
  always @ (posedge clk, posedge rst)begin
    if(rst)
	  frame <= 0;
	else if(tx_valid==1'b1 && state==IDLE) begin
	  frame[0] <= 1'b0;              
	  frame[8:1] <= tx_data;         
	  frame[9] <= tx_parity;         
	  frame[10] <= 1'b1;             
	end else if(state==RX_NEG_EDGE || state==TX_CLK_LOW)
	  frame <= {ps2_data_s, frame[10:1]};
	else
	  frame <= frame;
  end
  always @ (posedge clk, posedge rst) begin
    if(rst)begin
	  ps2_clk_s <= 1'b1;
	  clk_inter <= 1'b1;
	  clk_count <= 0;
	end else if(ps2_clk_in != clk_inter)begin
	  ps2_clk_s <= ps2_clk_s;
	  clk_inter <= ps2_clk_in;
	  clk_count <= 0;
	end else if(clk_count == DEBOUNCE_DELAY) begin
	  ps2_clk_s <= clk_inter;
	  clk_inter <= clk_inter;
	  clk_count <= clk_count;
	end else begin
	  ps2_clk_s <= ps2_clk_s;
	  clk_inter <= clk_inter;
	  clk_count <= clk_count + 1'b1;
	end
  end
  always @ (posedge clk, posedge rst) begin
    if(rst)begin
	  ps2_data_s <= 1'b1;
	  data_inter <= 1'b1;
	  data_count <= 0;
	end else if(ps2_data_in != data_inter)begin
	  ps2_data_s <= ps2_data_s;
	  data_inter <= ps2_data_in;
	  data_count <= 0;
	end else if(data_count == DEBOUNCE_DELAY) begin
	  ps2_data_s <= data_inter;
	  data_inter <= data_inter;
	  data_count <= data_count;
	end else begin
	  ps2_data_s <= ps2_data_s;
	  data_inter <= data_inter;
	  data_count <= data_count + 1'b1;
	end
  end
  always @ (posedge clk, posedge rst)begin
    if(rst)begin
	  state <= IDLE;
	  ps2_clk_en <= 1'b0;
	  ps2_clk_out <= 1'b0;
	  ps2_data_en <= 1'b0;
	  ps2_data_out <= 1'b0;
	  err <= 1'b0;
	  counter <= 0;
	end else begin
	  state <= state_next;
	  ps2_clk_en <= ps2_clk_en_next;
	  ps2_clk_out <= ps2_clk_out_next;
	  ps2_data_en <= ps2_data_en_next;
	  ps2_data_out <= ps2_data_out_next;
	  err <= err_next;
	  counter <= counter_next;
	end
  end
  always @ * begin
    state_next = IDLE;                                     
	ps2_clk_en_next = 1'b0;                                
	ps2_clk_out_next = 1'b1;                               
	ps2_data_en_next = 1'b0;                               
	ps2_data_out_next = 1'b1;                              
	err_next = 1'b0;                                       
	rx_finish = 1'b0;
	counter_next = 0;
    case(state)
	  IDLE:begin                                           
	      if(tx_valid == 1'b1)begin                        
		    state_next = TX_FORCE_CLK_LOW;                 
	      end else if(ps2_clk_s == 1'b0)begin              
		    state_next = RX_NEG_EDGE;                      
	      end else begin                                   
		    state_next = IDLE;
		  end
	    end
	  RX_NEG_EDGE:begin                                    
	      state_next = RX_CLK_LOW;                         
	    end
	  RX_CLK_LOW:begin                                     
	      if(ps2_clk_s == 1'b1)begin
		    state_next = RX_CLK_HIGH;
		  end else begin
		    state_next = RX_CLK_LOW;
		  end
	    end
	  RX_CLK_HIGH:begin                                    
	      if(bits_count == BITS_NUM)begin                  
		    if(rx_parity != frame[9])begin                 
			  err_next = 1'b1;                             
			  state_next = IDLE;                           
			end else begin
			  rx_finish = 1'b1;
			  state_next = IDLE;
			end
		  end else if(ps2_clk_s == 1'b0)begin
		    state_next = RX_NEG_EDGE;
	      end else begin
		    state_next = RX_CLK_HIGH;
		  end		  
	    end
	  TX_FORCE_CLK_LOW:begin                               
	      ps2_clk_en_next = 1'b1;                          
		  ps2_clk_out_next = 1'b0;                         
		  if(counter == CLOCK_CNT_100US)begin              
		    state_next = TX_BRING_DATA_LOW;                
			counter_next = 0;                              
		  end else begin                                   
		    state_next = TX_FORCE_CLK_LOW;                 
			counter_next = counter + 1'b1;                 
		  end                                              
	    end                              
	  TX_BRING_DATA_LOW:begin                              
	      ps2_clk_en_next = 1'b1;                          
		  ps2_clk_out_next = 1'b0;
		  ps2_data_en_next = 1'b1;
		  ps2_data_out_next = 1'b0;
	      if(counter == CLOCK_CNT_20US)begin
		    state_next = TX_RELEASE_CLK;
			counter_next = 0;
		  end else begin
		    state_next = TX_BRING_DATA_LOW;
			counter_next = counter + 1'b1;
		  end
	    end
      TX_RELEASE_CLK:begin                                 
	      ps2_clk_en_next = 1'b0;                          
		  ps2_data_en_next = 1'b1;
		  ps2_data_out_next = 1'b0;
		  state_next = TX_WAIT_FIRTS_NEG_EDGE;
	    end
	  TX_WAIT_FIRTS_NEG_EDGE:begin                         
	      ps2_data_en_next = 1'b1;                         
		  ps2_data_out_next = 1'b0;                        
		  if(counter == 14'd63)begin                       
		    if(ps2_clk_s == 1'b0)begin                     
			  state_next = TX_CLK_LOW;                     
			  counter_next = 0;                            
			end else begin
			  state_next = TX_WAIT_FIRTS_NEG_EDGE;
			  counter_next = counter;
			end
		  end else begin
		    state_next = TX_WAIT_FIRTS_NEG_EDGE;
			counter_next = counter + 1'b1;
		  end
	    end
	  TX_CLK_LOW:begin                                     
	      ps2_data_en_next = 1'b1;                         
		  ps2_data_out_next = frame[0];                    
		  state_next = TX_WAIT_POS_EDGE;                   
	    end
	  TX_WAIT_POS_EDGE:begin                               
	      ps2_data_en_next = 1'b1;                         
		  ps2_data_out_next = frame[0];                    
		  if(bits_count == BITS_NUM-1)begin                
		    ps2_data_en_next = 1'b0;                       
			state_next = TX_WAIT_POS_EDGE_BEFORE_ACK;      
		  end else if(ps2_clk_s == 1'b1)begin              
		    state_next = TX_CLK_HIGH;
		  end else begin
		    state_next = TX_WAIT_POS_EDGE;
		  end
	    end
      TX_CLK_HIGH:begin                                    
	      ps2_data_en_next = 1'b1;                         
		  ps2_data_out_next = frame[0];
		  if(ps2_clk_s == 1'b0)begin
		    state_next = TX_CLK_LOW;
		  end else begin
		    state_next = TX_CLK_HIGH;
		  end
	    end
	  TX_WAIT_POS_EDGE_BEFORE_ACK:begin                    
	      if(ps2_clk_s == 1'b1)begin                       
		    state_next = TX_WAIT_ACK;
		  end else begin
		    state_next = TX_WAIT_POS_EDGE_BEFORE_ACK;
		  end
	    end
	  TX_WAIT_ACK:begin                                    
	      if(ps2_clk_s == 1'b0)begin                       
		    if(ps2_data_s == 1'b0) begin                   
			  state_next = TX_RECEIVED_ACK;                
			end else begin                                 
			  state_next = TX_ERROR_NO_ACK;
			end
		  end else begin
		    state_next = TX_WAIT_ACK;
		  end
	    end
	  TX_RECEIVED_ACK:begin                                
	      if(ps2_clk_s == 1'b1 && ps2_clk_s == 1'b1)begin  
		    state_next = IDLE;
		  end else begin
		    state_next = TX_RECEIVED_ACK;
		  end
	    end
	  TX_ERROR_NO_ACK:begin
	      if(ps2_clk_s == 1'b1 && ps2_clk_s == 1'b1)begin  
		    err_next = 1'b1;                               
			state_next = IDLE;                             
		  end else begin
		    state_next = TX_ERROR_NO_ACK;
		  end
	    end
	  default:begin                                        
	      err_next = 1'b1;                                 
		  state_next = IDLE;
	    end
    endcase
  end
  always @ (posedge clk, posedge rst)begin
    if(rst)
	  bits_count <= 0;
	else if(state==IDLE)
	  bits_count <= 0;
	else if(state==RX_NEG_EDGE || state==TX_CLK_LOW)
	  bits_count <= bits_count + 1'b1;
	else
	  bits_count <= bits_count;
  end
endmodule
