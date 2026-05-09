`timescale 1ns / 1ps
`timescale 1ns / 1ps
module YL3_Shift_Register(
  input        CLK,
  input [15:0] DATA_IN,
  input        EN_IN,
  output       RDY,
  output       RCLK,
  output       SRCLK,
  output       SER_OUT
);
  reg [16:0] shift = 0;
  reg RCLK         = 0; 
  reg SRCLK        = 0; 
  reg RDY          = 1;
  parameter N = 3; 
  parameter [N-1:0] pulse_duration = 6;  
  parameter [N-1:0] setup_time = 7;    
  wire   SER_OUT;
  assign SER_OUT = shift[16]; 
  reg [N-1:0] clk_cnt      = 0;
  reg [1:0]   SRCLK_state  = 0;
  reg         SRCLK_toggle = 0; 
  always @(posedge CLK)
    begin
      case(SRCLK_state)
        0:
         begin 
            if(SRCLK_toggle == 1)
              begin
                SRCLK_state <= SRCLK_state + 1;
                SRCLK       <= 0; 
                clk_cnt     <= 0;
              end
            end
        1:
          begin 
            if(clk_cnt == setup_time - 1)
              begin
                SRCLK       <= 1;
                clk_cnt     <= 0;
                SRCLK_state <= SRCLK_state + 1;
              end
            else
              begin
                clk_cnt <= clk_cnt + 1;
              end
          end
        2:
          begin 
            if(clk_cnt == pulse_duration - 1)
              begin
              SRCLK       <= 0;
              clk_cnt     <= 0;
              SRCLK_state <= SRCLK_state + 1;
            end
          else
            begin
              clk_cnt <= clk_cnt + 1;
            end    
          end
        3:
          begin 
            if(SRCLK_toggle == 0)
              begin
                SRCLK_state<=0;
              end
          end  
      endcase
    end
  reg [N-1:0] clk_cnt2    = 0;
  reg [1:0]   RCLK_state  = 0;
  reg         RCLK_toggle = 0; 
  always @(posedge CLK)
    begin
      case(RCLK_state)
        0:
          begin 
            if(RCLK_toggle == 1)
              begin
                RCLK_state <= RCLK_state + 1;
                RCLK       <= 0; 
                clk_cnt2   <= 0;
              end
          end
        1:
          begin 
            if(clk_cnt2 == setup_time - 1)
              begin
                RCLK       <= 1;
                clk_cnt2   <= 0;
                RCLK_state <= RCLK_state + 1;
              end
            else
              begin
                clk_cnt2 <= clk_cnt2 + 1;
              end
          end
      2:
        begin 
          if(clk_cnt2 == pulse_duration - 1)
            begin
              RCLK       <= 0;
              clk_cnt2   <= 0;
              RCLK_state <= RCLK_state + 1;
            end 
          else
            begin
              clk_cnt2 <= clk_cnt2 + 1;
             end    
        end
      3:
        begin 
          if(RCLK_toggle==0)
            begin
             RCLK_state <= 0;
            end
        end  
      endcase
    end
  reg [1:0] state     = 0; 
  reg [1:0] substate  = 0;
  reg [3:0] cnt       = 0;
  reg       init_done = 0; 
  always @(posedge CLK)
    begin
      case(state)
        0:
          begin 
            if(EN_IN==1)
              begin 
                shift[15:0]  <= DATA_IN;
                cnt          <= 0;
                state        <= state + 1;
                RDY          <= 0;
                SRCLK_toggle <= 0;
                RCLK_toggle  <= 0;
                substate     <= 0;
              end
            else
              begin
                RDY          <= 1;
                cnt          <= 0;
                SRCLK_toggle <= 0;
                RCLK_toggle  <= 0;
                state        <= 0;
                substate     <= 0;
              end
          end
        1:
          begin 
            case(substate)
              0:
                begin 
                  shift[16:1] <= shift[15:0];
                  shift[0]    <= 0;  
                  substate    <= substate + 1;
                end
              1:
                begin 
                  SRCLK_toggle <= 1;
                  substate     <= substate + 1;
                end
              2:
                begin 
                  if(SRCLK == 1)
                    begin
                      SRCLK_toggle <= 0;
                      substate     <= substate + 1;
                    end
                end
              3:
                begin 
                  if(SRCLK == 0)
                    begin
                      if(cnt == 15)
                        begin
                          state <= state + 1;
                          cnt   <= 0;
                        end
                      else
                        begin
                          cnt <= cnt + 1;
                        end
                      substate <= 0;
                    end
                end
            endcase
          end
        2:
          begin 
            case(substate)        
              0:
                begin 
                  RCLK_toggle <= 1;
                  substate    <= substate + 1;
                end
              1:
                begin 
                  if(RCLK == 1)
                    begin
                      RCLK_toggle <= 0;
                      substate    <= substate + 1;
                    end
                end
              2:
                begin 
                  if(RCLK == 0)
                    begin
                      state     <= 0;
                      substate  <= 0;
                      init_done <= 1;
                      RDY       <= 1;
                    end
                end
            endcase
          end
        default:
          begin
            state     <= 0;
            substate  <= 0;
            init_done <= 0;
            RDY       <= 1;
          end
      endcase
    end
endmodule
