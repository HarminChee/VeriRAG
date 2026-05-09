`timescale 1ns / 1ps
module yl3_interface(
  input        CLK,    
  input        test_i,
  input        nRST,   
  input [63:0] DATA,   
  input        LOAD,   
  input        scan_LOAD,
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
  wire        dft_LOAD;
  assign dft_LOAD = test_i ? scan_LOAD : LOAD;
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
  always @(posedge CLK)
    begin
      if(!nRST)
        begin
          state      <= ST_READY;
          chrarr[0]   = 0;
          chrarr[1]   = 0;
          chrarr[2]   = 0;
          chrarr[3]   = 0;
          chrarr[4]   = 0;
          chrarr[5]   = 0;
          chrarr[6]   = 0;
          chrarr[7]   = 0;
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
          if(state != ST_SHIFT)
            begin
            end
          case(state)
            ST_READY:
              begin
                if(dft_LOAD == 1)
                  begin
                    if({chrarr[0], chrarr[1], chrarr[2], chrarr[3], chrarr[4], chrarr[5], chrarr[6], chrarr[7]} != DATA)
                      begin
                        chrarr[0] = DATA[63:56];
                        chrarr[1] = DATA[55:48];
                        chrarr[2] = DATA[47:40];
                        chrarr[3] = DATA[39:32];
                        chrarr[4] = DATA[31:24];
                        chrarr[5] = DATA[23:16];
                        chrarr[6] = DATA[15:8];
                        chrarr[7] = DATA[7:0];
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
                      0:
                        begin
                          posreg <= 8'b0000_0001;
                        end
                      1:
                        begin
                          posreg <= 8'b0000_0010;
                        end
                      2:
                        begin
                          posreg <= 8'b0000_0100;
                        end
                      3:
                        begin
                          posreg <= 8'b0000_1000;
                        end
                      4:
                        begin
                          posreg <= 8'b0001_0000;
                        end
                      5:
                        begin
                          posreg <= 8'b0010_0000;
                        end
                      6:
                        begin
                          posreg <= 8'b0100_0000;
                        end
                      7:
                        begin
                          posreg <= 8'b1000_0000;
                        end
                      default:
                        begin
                        end
                    endcase
                    case (chrarr[aidx])
                      "0", "O":
                        begin
                          chrreg <= 8'b1100_0000;
                        end
                      "1":
                        begin
                          chrreg <= 8'b1111_1001;
                        end
                      "2":
                        begin
                          chrreg <= 8'b1010_0100;
                        end
                      "3":
                        begin
                          chrreg <= 8'b1011_0000;
                        end
                      "4":
                        begin
                          chrreg <= 8'b1001_1001;
                        end
                      "5", "S", "s":
                        begin
                          chrreg <= 8'b1001_0010;
                        end
                      "6":
                        begin
                          chrreg <= 8'b1000_0010;
                        end
                      "7":
                        begin
                          chrreg <= 8'b1111_1000;
                        end
                      "8":
                        begin
                          chrreg <= 8'b1000_0000;
                        end
                      "9":
                        begin
                          chrreg <= 8'b1001_1000;
                        end
                      "A":
                        begin
                          chrreg <= 8'b1000_1000;
                        end
                      "a":
                        begin
                          chrreg <= 8'b1010_0000;
                        end
                      "B", "b":
                        begin
                          chrreg <= 8'b1000_0011;
                        end
                      "C":
                        begin
                          chrreg <= 8'b1100_0110;
                        end
                      "c":
                        begin
                          chrreg <= 8'b1010_0111;
                        end
                      "D", "d":
                        begin
                          chrreg <= 8'b1010_0001;
                        end
                      "E":
                        begin
                          chrreg <= 8'b1000_0110;
                        end
                      "e":
                        begin
                          chrreg <= 8'b1000_0100;
                        end
                      "F", "f":
                        begin
                          chrreg <= 8'b1000_1110;
                        end
                      "G", "g":
                        begin
                          chrreg <= 8'b1001_0000;
                        end              
                      "H":
                        begin
                          chrreg <= 8'b1000_1001;
                        end
                      "h":
                        begin
                          chrreg <= 8'b1000_1011;
                        end
                      "J":
                        begin
                          chrreg <= 8'b1111_0001;
                        end
                      "j":
                        begin
                          chrreg <= 8'b1111_0011;
                        end
                      "L":
                        begin
                          chrreg <= 8'b1100_0111;
                        end
                      "l":
                        begin
                          chrreg <= 8'b1110_0111;
                        end
                      "N", "n":
                        begin
                          chrreg <= 8'b1010_1011;
                        end
                      "o":
                        begin
                          chrreg <= 8'b1010_1011;
                        end
                      "P", "p":
                        begin
                          chrreg <= 8'b1000_1100;
                        end
                      "Q":
                        begin
                          chrreg <= 8'b0100_0000;
                        end
                      "q":
                        begin
                          chrreg <= 8'b0010_0011;
                        end
                      "R": 
                        begin
                          chrreg <= 8'b1100_1110;
                        end
                      "r":  
                        begin
                          chrreg <= 8'b1010_1111;
                        end
                      "T", "t":
                        begin
                          chrreg <= 8'b1000_0111;
                        end
                      "U":
                        begin
                          chrreg <= 8'b1100_0001;
                        end
                      "u":
                        begin
                          chrreg <= 8'b1110_0011;
                        end
                      "°":
                        begin
                          chrreg <= 8'b1001_1100;
                        end
                      ".":
                        begin
                          chrreg <= 8'b0111_1111;
                        end
                      default:
                        begin
                          chrreg <= 8'b1111_1111;
                        end
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