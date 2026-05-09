`timescale 1 ns / 1 ns
`timescale 1 ns / 1 ns
module Update_Count_From_AB
          (
           CLK_IN,
           reset,
           enb,
           A,
           B,
           index,
           count_max,
           count
          );
  input   CLK_IN;
  input   reset;
  input   enb;
  input   A;
  input   B;
  input   index;
  input   signed [15:0] count_max;  
  output  signed [15:0] count;  
  parameter IN_NO_ACTIVE_CHILD = 0, IN_A0_B0 = 1, IN_A0_B1 = 2, IN_A1_B0 = 3, IN_A1_B1 = 4;
  parameter IN_INDEX = 0, IN_INIT = 1;
  reg [1:0] is_libEncoderPeripheralHdl_c7_Update_Count_From_AB;  
  reg [2:0] is_INDEX;  
  reg signed [15:0] count_reg;  
  reg [1:0] is_libEncoderPeripheralHdl_c7_Update_Count_From_AB_next;  
  reg [2:0] is_INDEX_next;  
  reg signed [15:0] count_reg_next;  
  always @(posedge CLK_IN)
    begin : libEncoderPeripheralHdl_c7_Update_Count_From_AB_process
      if (reset == 1'b1) begin
        is_INDEX <= IN_NO_ACTIVE_CHILD;
        count_reg <= 16'sd0;
        is_libEncoderPeripheralHdl_c7_Update_Count_From_AB <= IN_INIT;
      end
      else if (enb) begin
        is_libEncoderPeripheralHdl_c7_Update_Count_From_AB <= is_libEncoderPeripheralHdl_c7_Update_Count_From_AB_next;
        is_INDEX <= is_INDEX_next;
        count_reg <= count_reg_next;
      end
    end
  always @(is_libEncoderPeripheralHdl_c7_Update_Count_From_AB, is_INDEX, A, B, index,
       count_max, count_reg) begin
    count_reg_next = count_reg;
    is_libEncoderPeripheralHdl_c7_Update_Count_From_AB_next = is_libEncoderPeripheralHdl_c7_Update_Count_From_AB;
    is_INDEX_next = is_INDEX;
    case ( is_libEncoderPeripheralHdl_c7_Update_Count_From_AB)
      IN_INDEX :
        begin
          if (index == 1'b1) begin
            count_reg_next = 16'sd0;
            is_libEncoderPeripheralHdl_c7_Update_Count_From_AB_next = IN_INDEX;
            is_INDEX_next = IN_A0_B0;
          end
          else begin
            case ( is_INDEX)
              IN_A0_B0 :
                begin
                  if (A && ( ~ B)) begin
                    count_reg_next = count_reg + 1;
                    if ((count_reg + 16'sd1) > count_max) begin
                      count_reg_next = 16'sd0;
                    end
                    else begin
                    end
                    is_INDEX_next = IN_A1_B0;
                  end
                  else if (( ~ A) && B) begin
                    count_reg_next = count_reg - 1;
                    if ((count_reg - 16'sd1) < 16'sb0000000000000000) begin
                      count_reg_next = count_max;
                    end
                    else begin
                    end
                    is_INDEX_next = IN_A0_B1;
                  end
                end
              IN_A0_B1 :
                begin
                  if (A && B) begin
                    count_reg_next = count_reg - 1;
                    if ((count_reg - 16'sd1) < 16'sb0000000000000000) begin
                      count_reg_next = count_max;
                    end
                    else begin
                    end
                    is_INDEX_next = IN_A1_B1;
                  end
                  else begin
                    if (( ~ A) && ( ~ B)) begin
                      count_reg_next = count_reg + 1;
                      if ((count_reg + 16'sd1) > count_max) begin
                        count_reg_next = 16'sd0;
                      end
                      else begin
                      end
                      is_INDEX_next = IN_A0_B0;
                    end
                  end
                end
              IN_A1_B0 :
                begin
                  if (( ~ A) && ( ~ B)) begin
                    count_reg_next = count_reg - 1;
                    if ((count_reg - 16'sd1) < 16'sb0000000000000000) begin
                      count_reg_next = count_max;
                    end
                    else begin
                    end
                    is_INDEX_next = IN_A0_B0;
                  end
                  else begin
                    if (A && B) begin
                      count_reg_next = count_reg + 1;
                      if ((count_reg + 16'sd1) > count_max) begin
                        count_reg_next = 16'sd0;
                      end
                      else begin
                      end
                      is_INDEX_next = IN_A1_B1;
                    end
                  end
                end
              default :
                begin
                  if (( ~ A) && B) begin
                    count_reg_next = count_reg + 1;
                    if ((count_reg + 16'sd1) > count_max) begin
                      count_reg_next = 16'sd0;
                    end
                    else begin
                    end
                    is_INDEX_next = IN_A0_B1;
                  end
                  else if (A && ( ~ B)) begin
                    count_reg_next = count_reg - 1;
                    if ((count_reg - 16'sd1) < 16'sb0000000000000000) begin
                      count_reg_next = count_max;
                    end
                    else begin
                    end
                    is_INDEX_next = IN_A1_B0;
                  end
                end
            endcase
          end
        end
      default :
        begin
          count_reg_next = 16'sd0;
          is_libEncoderPeripheralHdl_c7_Update_Count_From_AB_next = IN_INDEX;
          is_INDEX_next = IN_A0_B0;
        end
    endcase
  end
  assign count = count_reg_next;
endmodule  
