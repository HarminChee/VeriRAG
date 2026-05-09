`timescale 1ns / 1ps
 `define START_AND_CHANNEL_SYNC 1
 `define CHANNEL_AFTER_MEASURE  2
 `define MAX_CHANNEL_NUMBER  4096
 `timescale 1 ns / 1 ps
 module messbauer_generator #
 (
     parameter GCLK_PERIOD = 20,                                                                    
     parameter START_DURATION = 50,                                                                 
     parameter CHANNEL_NUMBER = 512,                                                                
     parameter CHANNEL_DURATION = (16 * (`MAX_CHANNEL_NUMBER / CHANNEL_NUMBER)) * 1000 / (2 *GCLK_PERIOD), 
     parameter CHANNEL_TYPE = `CHANNEL_AFTER_MEASURE                                                
 )
 (
     input wire aclk,
     input wire areset_n,
     output reg start,
     output reg channel
 );
 localparam CHANNEL_GUARD_DURATION = CHANNEL_DURATION - 4 * (1000 / GCLK_PERIOD); 
 localparam CHANNEL_MEANDR_GUARD_DURATION = CHANNEL_DURATION / 2;
 localparam START_HIGH_PHASE_DURATION = 15464 * (1000 / GCLK_PERIOD);
 localparam reg[2:0] INITIAL_STATE = 0;
 localparam reg[2:0] START_LOW_PHASE_STATE = 1;
 localparam reg[2:0] CHANNEL_GENERATION_STATE = 2;
 localparam reg[2:0] START_HIGH_PHASE_STATE = 3;
 reg[31:0] clk_counter;
 reg[2:0] state;
 reg[31:0] channel_counter;
 always @(posedge aclk)
 begin
     if(~areset_n)
     begin
         start <= 1'b1;
         channel <= 1'b1;
         clk_counter <= 8'b0;
         state <= INITIAL_STATE;
     end
     else
     begin
         case (state)
             INITIAL_STATE:
             begin
                 state <= START_LOW_PHASE_STATE;
                 clk_counter <= 0;
             end
             START_LOW_PHASE_STATE:
             begin
                 start <= 0;
                 channel_counter <= 0;
                 if(CHANNEL_TYPE == `START_AND_CHANNEL_SYNC && clk_counter == 0)
                     channel <= 0;
                 clk_counter <= clk_counter + 1;
                 if(clk_counter == START_DURATION)
                     state <= CHANNEL_GENERATION_STATE;
             end
             CHANNEL_GENERATION_STATE:
             begin
                 start <= 1;
                 clk_counter <= clk_counter + 1;
                 if(clk_counter == CHANNEL_GUARD_DURATION)
                 begin
                     channel <= ~channel;
                 end
                 if(clk_counter == CHANNEL_DURATION)
                 begin
                     channel <= ~channel;
                     channel_counter <= channel_counter + 1;
                     clk_counter <= 0;
                     if((channel_counter == CHANNEL_NUMBER - 1 && CHANNEL_TYPE != `START_AND_CHANNEL_SYNC) ||
                        (channel_counter == CHANNEL_NUMBER && CHANNEL_TYPE == `START_AND_CHANNEL_SYNC))
                     begin
                         state <= START_HIGH_PHASE_STATE;
                     end
                 end
             end
             START_HIGH_PHASE_STATE:
             begin
                 start <= 1;
                 channel <= 1;
                 clk_counter <= clk_counter + 1;
                 if(clk_counter == START_HIGH_PHASE_DURATION)
                     state <= INITIAL_STATE;
             end
             default:
             begin
             end
         endcase
     end
 end
 endmodule
`timescale 1ns / 1ps
 `define START_AND_CHANNEL_SYNC 1
 `define CHANNEL_AFTER_MEASURE  2
 `define MAX_CHANNEL_NUMBER  4096
 `timescale 1 ns / 1 ps
 module messbauer_generator #
 (
     parameter GCLK_PERIOD = 20,                                                                    
     parameter START_DURATION = 50,                                                                 
     parameter CHANNEL_NUMBER = 512,                                                                
     parameter CHANNEL_DURATION = (16 * (`MAX_CHANNEL_NUMBER / CHANNEL_NUMBER)) * 1000 / (2 *GCLK_PERIOD), 
     parameter CHANNEL_TYPE = `CHANNEL_AFTER_MEASURE                                                
 )
 (
     input wire aclk,
     input wire areset_n,
     output reg start,
     output reg channel
 );
 localparam CHANNEL_GUARD_DURATION = CHANNEL_DURATION - 4 * (1000 / GCLK_PERIOD); 
 localparam CHANNEL_MEANDR_GUARD_DURATION = CHANNEL_DURATION / 2;
 localparam START_HIGH_PHASE_DURATION = 15464 * (1000 / GCLK_PERIOD);
 localparam reg[2:0] INITIAL_STATE = 0;
 localparam reg[2:0] START_LOW_PHASE_STATE = 1;
 localparam reg[2:0] CHANNEL_GENERATION_STATE = 2;
 localparam reg[2:0] START_HIGH_PHASE_STATE = 3;
 reg[31:0] clk_counter;
 reg[2:0] state;
 reg[31:0] channel_counter;
 always @(posedge aclk)
 begin
     if(~areset_n)
     begin
         start <= 1'b1;
         channel <= 1'b1;
         clk_counter <= 8'b0;
         state <= INITIAL_STATE;
     end
     else
     begin
         case (state)
             INITIAL_STATE:
             begin
                 state <= START_LOW_PHASE_STATE;
                 clk_counter <= 0;
             end
             START_LOW_PHASE_STATE:
             begin
                 start <= 0;
                 channel_counter <= 0;
                 if(CHANNEL_TYPE == `START_AND_CHANNEL_SYNC && clk_counter == 0)
                     channel <= 0;
                 clk_counter <= clk_counter + 1;
                 if(clk_counter == START_DURATION)
                     state <= CHANNEL_GENERATION_STATE;
             end
             CHANNEL_GENERATION_STATE:
             begin
                 start <= 1;
                 clk_counter <= clk_counter + 1;
                 if(clk_counter == CHANNEL_GUARD_DURATION)
                 begin
                     channel <= ~channel;
                 end
                 if(clk_counter == CHANNEL_DURATION)
                 begin
                     channel <= ~channel;
                     channel_counter <= channel_counter + 1;
                     clk_counter <= 0;
                     if((channel_counter == CHANNEL_NUMBER - 1 && CHANNEL_TYPE != `START_AND_CHANNEL_SYNC) ||
                        (channel_counter == CHANNEL_NUMBER && CHANNEL_TYPE == `START_AND_CHANNEL_SYNC))
                     begin
                         state <= START_HIGH_PHASE_STATE;
                     end
                 end
             end
             START_HIGH_PHASE_STATE:
             begin
                 start <= 1;
                 channel <= 1;
                 clk_counter <= clk_counter + 1;
                 if(clk_counter == START_HIGH_PHASE_DURATION)
                     state <= INITIAL_STATE;
             end
             default:
             begin
             end
         endcase
     end
 end
 endmodule
