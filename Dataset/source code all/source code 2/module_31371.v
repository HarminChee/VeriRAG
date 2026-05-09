module Encryption
  #(
      parameter ADDR_WIDTH = 4,
      parameter DATA_WIDTH = 8,
      parameter MEM_DEPTH = 64
  )(
  input clk,
  input rst,
  input ena,
  input[DATA_WIDTH-1:0] key,
  input[DATA_WIDTH-1:0] data_in,
  output reg finished,
  output reg mem_wr_ena,
  output reg[ADDR_WIDTH-1:0] memIn_addr,
  output reg[ADDR_WIDTH-1:0] memOut_addr,
  output reg[DATA_WIDTH-1:0] data_out
  );
  parameter shift = DATA_WIDTH/2;
  parameter MEM_WIDTH = ADDR_WIDTH+DATA_WIDTH; 
  reg [MEM_WIDTH-1:0] mem [0:8];
  reg start;
  reg done;
  always@(posedge clk)
  begin:Main_Module
    case(rst)
    1'b0:
    if(ena==1'b1 && start==1'b0)begin
      start <= 1'b1;
      done <= 1'b0;
      memIn_addr <= {ADDR_WIDTH{1'b0}};
      memOut_addr <= {ADDR_WIDTH{1'b0}};
      data_out <= {DATA_WIDTH{1'b0}};
      mem_wr_ena <= 1'b0;
    end else 
    if(ena==1'b1) begin:Encryption
        begin:Stage_FetchData
          if(data_in!=={DATA_WIDTH{1'bx}})begin
            mem[0] <= {memIn_addr-1,data_in};
            memIn_addr <= memIn_addr+1;
          end else begin
            done <= 1'b1;
            mem[0] <= {MEM_WIDTH{1'b0}};
          end
        end
        begin:Stage0_Stage4_Stage7_AddRoundKey
              mem[1] <= |mem[0]==1'b0 ? mem[0] : {mem[0][ADDR_WIDTH+DATA_WIDTH-1:DATA_WIDTH],
                                                  mem[0][DATA_WIDTH-1:0] ^ key};
              mem[5] <= |mem[4]==1'b0 ? mem[4] : {mem[4][ADDR_WIDTH+DATA_WIDTH-1:DATA_WIDTH],
                                                  mem[4][DATA_WIDTH-1:0] ^ key};  
              mem[8] <= |mem[7]==1'b0 ? mem[7] : {mem[7][ADDR_WIDTH+DATA_WIDTH-1:DATA_WIDTH],
                                                  mem[7][DATA_WIDTH-1:0] ^ key};
        end
        begin:Stage1_Stage5_SubBytes
             mem[2] <= |mem[1]==1'b0 ? mem[1] : {mem[1][ADDR_WIDTH+DATA_WIDTH-1:DATA_WIDTH],
                                                 ~mem[1][DATA_WIDTH-1:0]+1'b1};
             mem[6] <= |mem[5]==1'b0 ? mem[5] : {mem[5][ADDR_WIDTH+DATA_WIDTH-1:DATA_WIDTH],
                                                ~mem[5][DATA_WIDTH-1:0]+1'b1};
        end
        begin:Stage2_Stage6_ShiftRows
             mem[3] <= |mem[2]==1'b0 ? mem[2] : {mem[2][ADDR_WIDTH+DATA_WIDTH-1:DATA_WIDTH],
                        mem[2][DATA_WIDTH-1-shift-1:0],mem[2][DATA_WIDTH-1:DATA_WIDTH-1-shift]};
             mem[7] <= |mem[6]==1'b0 ? mem[6] : {mem[6][ADDR_WIDTH+DATA_WIDTH-1:DATA_WIDTH],
                        mem[6][DATA_WIDTH-1-shift-1:0],mem[6][DATA_WIDTH-1:DATA_WIDTH-1-shift]};
        end
        begin:Stage3_MixColumns
             mem[4] <= |mem[3]==1'b0 ? mem[3] : {mem[3][ADDR_WIDTH+DATA_WIDTH-1:DATA_WIDTH],
                         mem[3][DATA_WIDTH-1:0]+mem[3][ADDR_WIDTH+DATA_WIDTH-1:DATA_WIDTH]};
        end
        begin:Stage8_Push_Data
          if(mem[8]!=={MEM_WIDTH{1'b0}})begin
            mem_wr_ena  <= 1'b1;
            memOut_addr <= mem[8][ADDR_WIDTH+DATA_WIDTH-1:DATA_WIDTH];
            data_out    <= mem[8][DATA_WIDTH-1:0]; 
          end
          else if (done==1'b1) begin
            finished <= 1'b1;
            start <=1'b0;
            done <= 1'b0;
            mem_wr_ena <= 1'b0;
            memIn_addr <= {ADDR_WIDTH{1'b0}};
            memOut_addr <= {ADDR_WIDTH{1'b0}};
            data_out <= {DATA_WIDTH{1'b0}};
            $display("Encryption Completed");
          end 
        end
    end    
    1'b1: 
    begin:Reset    
      start <=1'b0;
      done <= 1'b0;
      finished <= 1'b0;  
      mem_wr_ena <= 1'b0;
      memIn_addr <= {ADDR_WIDTH{1'b0}};   
      memOut_addr <= {ADDR_WIDTH{1'b0}};
      data_out <= {DATA_WIDTH{1'b0}};
      mem[0] <= {MEM_WIDTH{1'b0}};
      mem[1] <= {MEM_WIDTH{1'b0}};
      mem[2] <= {MEM_WIDTH{1'b0}};
      mem[3] <= {MEM_WIDTH{1'b0}};
      mem[4] <= {MEM_WIDTH{1'b0}};
      mem[5] <= {MEM_WIDTH{1'b0}};
      mem[6] <= {MEM_WIDTH{1'b0}};
      mem[7] <= {MEM_WIDTH{1'b0}};
      mem[8] <= {MEM_WIDTH{1'b0}};
    end
    endcase
  end
endmodule
