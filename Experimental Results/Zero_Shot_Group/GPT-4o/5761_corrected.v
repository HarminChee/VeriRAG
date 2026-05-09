`timescale 1ns / 1ps
module yl3_interface(
  input        CLK,    
  input        nRST,   
  input [63:0] DATA,   
  input        LOAD,   
  output       READY,  
  output       DIO,    
  output       SCK,    
  output       RCK     
);
  localparam  ST_READY     = 2'b00;      
  localparam  ST_READCHR   = 2'b01;      
  localparam  ST_SHIFT     = 2'b10;      
  reg  [7:0]  chrarr [0:7];              
  reg  [3:0]  aidx;                      
  reg  [7:0]  posreg;                    
  reg  [7:0]  chrreg;                    
  reg  [15:0] dataout;                   
  reg  [3:0]  delaycnt;                  
  reg  [4:0]  bitcnt;                    
  reg  [2:0]  lchcnt;                    
  reg  [1:0]  state;                     
  reg         loaded;                    
  reg         EN;
  reg         ENA;
  reg         ENB;
  wire        RDY;
  YL3_Shift_Register ShiftReg(
    .CLK(CLK),
    .DATA_IN(dataout),
    .EN_IN(EN),
    .RDY(RDY),
    .RCLK(RCK),
    .SRCLK(SCK),
    .SER_OUT(DIO)
  );
  always @(negedge RDY)
    begin
      ENA <= 0;
    end
  always @(posedge CLK or negedge nRST)
    begin
      if(!nRST)
        begin
          state      <= ST_READY;
          chrarr[0]   <= 0;
          chrarr[1]   <= 0;
          chrarr[2]   <= 0;
          chrarr[3]   <= 0;
          chrarr[4]   <= 0;
          chrarr[5]   <= 0;
          chrarr[6]   <= 0;
          chrarr[7]   <= 0;
          aidx       <= 4'b0;
          posreg     <= 8'b0;
          chrreg     <= 8'b0;
          dataout    <= 16'b1111_1111_1111_1111;
          delaycnt   <= 4'b0;
          lchcnt     <= 3'b0;
          bitcnt     <= 5'b0;
          loaded     <= 1'b0;
        end
      else
        begin
          case(state)
            ST_READY:
              begin
                if(LOAD == 1)
                  begin
                    if({chrarr[0], chrarr[1], chrarr[2], chrarr[3], chrarr[4], chrarr[5], chrarr[6], chrarr[7]} != DATA)
                      begin
                        chrarr[0] <= DATA[63:56];
                        chrarr[1] <= DATA[55:48];
                        chrarr[2] <= DATA[47:40];
                        chrarr[3] <= DATA[39:32];
                        chrarr[4] <= DATA[31:24];
                        chrarr[5] <= DATA[23:16];
                        chrarr[6] <= DATA[15:8];
                        chrarr[7] <= DATA[7:0];
                      end
                    else
                      begin
                        loaded <= 1'b1;
                        state  <= ST_READCHR;
                      end
                  end
              end
            ST_READCHR:
              begin
                delaycnt <= 4'b0;
                if({posreg, chrreg} != dataout)
                  begin
                    case (aidx)
                      0: posreg <= 8'b0000_0001;
                      1: posreg <= 8'b0000_0010;
                      2: posreg <= 8'b0000_0100;
                      3: posreg <= 8'b0000_1000;
                      4: posreg <= 8'b0001_0000;
                      5: posreg <= 8'b0010_0000;
                      6: posreg <= 8'b0100_0000;
                      7: posreg <= 8'b1000_0000;
                      default: posreg <= 8'b0;
                    endcase
                    case (chrarr[aidx])
                      "0", "O": chrreg <= 8'b1100_0000;
                      "1": chrreg <= 8'b1111_1001;
                      "2": chrreg <= 8'b1010_0100;
                      "3": chrreg <= 8'b1011_0000;
                      "4": chrreg <= 8'b1001_1001;
                      "5", "S", "s": chrreg <= 8'b1001_0010;
                      "6": chrreg <= 8'b1000_0010;
                      "7": chrreg <= 8'b1111_1000;
                      "8": chrreg <= 8'b1000_0000;
                      "9": chrreg <= 8'b1001_1000;
                      "A": chrreg <= 8'b1000_1000;
                      "a": chrreg <= 8'b1010_0000;
                      "B", "b": chrreg <= 8'b1000_0011;
                      "C": chrreg <= 8'b1100_0110;
                      "c": chrreg <= 8'b1010_0111;
                      "D", "d": chrreg <= 8'b1010_0001;
                      "E": chrreg <= 8'b1000_0110;
                      "e": chrreg <= 8'b1000_0100;
                      "F", "f": chrreg <= 8'b1000_1110;
                      "G", "g": chrreg <= 8'b1001_0000;
                      "H": chrreg <= 8'b1000_1001;
                      "h": chrreg <= 8'b1000_1011;
                      "J": chrreg <= 8'b1111_0001;
                      "j": chrreg <= 8'b1111_0011;
                      "L": chrreg <= 8'b1100_0111;
                      "l": chrreg <= 8'b1110_0111;
                      "N", "n": chrreg <= 8'b1010_1011;
                      "o": chrreg <= 8'b1010_1011;
                      "P", "p": chrreg <= 8'b1000_1100;
                      "Q": chrreg <= 8'b0100_0000;
                      "q": chrreg <= 8'b0010_0011;
                      "R": chrreg <= 8'b1100_1110;
                      "r": chrreg <= 8'b1010_1111;
                      "T", "t": chrreg <= 8'b1000_0111;
                      "U": chrreg <= 8'b1100_0001;
                      "u": chrreg <= 8'b1110_0011;
                      "°": chrreg <= 8'b1001_1100;
                      ".": chrreg <= 8'b0111_1111;
                      default: chrreg <= 8'b1111_1111;
                    endcase
                    dataout <= {posreg, chrreg};
                  end
                else
                  begin
                    aidx    <= aidx + 1'b1;
                    state   <= ST_SHIFT;
                  end          
              end
            ST_SHIFT:
              begin
                if(RDY)
                  begin
                    if(aidx < 8)
                      begin
                        posreg  <= 8'b0;
                        chrreg  <= 8'b0;
                        dataout <= 16'b1;
                        state   <= ST_READCHR;
                      end
                    else
                      begin
                        loaded <= 1'b0;
                        state  <= ST_READY;
                      end
                  end
              end
          endcase
        end
    end
  always @(state)
    begin 
      if(state == ST_SHIFT)
        begin
          if(RDY)
            begin
              ENB <= 1;
            end
          else
            begin
              ENB <= 0;
             end  
        end
    end
  always @(*)
    begin
      EN <= (ENA || ENB);
    end
  assign READY  = (state == ST_READY && loaded == 0)  ? 1'b1 : 1'b0;
endmodule