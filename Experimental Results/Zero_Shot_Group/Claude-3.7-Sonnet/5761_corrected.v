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
      ENA <= 1'b0;
    end

  always @(posedge CLK)
    begin
      if(!nRST)
        begin
          state      <= ST_READY;
          chrarr[0]  <= 8'b0;
          chrarr[1]  <= 8'b0;
          chrarr[2]  <= 8'b0;
          chrarr[3]  <= 8'b0;
          chrarr[4]  <= 8'b0;
          chrarr[5]  <= 8'b0;
          chrarr[6]  <= 8'b0;
          chrarr[7]  <= 8'b0;
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
                    loaded <= 1'b0;
                    chrarr[0] <= DATA[63:56];
                    chrarr[1] <= DATA[55:48];
                    chrarr[2] <= DATA[47:40];
                    chrarr[3] <= DATA[39:32];
                    chrarr[4] <= DATA[31:24];
                    chrarr[5] <= DATA[23:16];
                    chrarr[6] <= DATA[15:8];
                    chrarr[7] <= DATA[7:0];
                    aidx    <= 4'b0;   
                    state  <= ST_READCHR;
                  end
              end

            ST_READCHR:
              begin
                delaycnt <= 4'b0;
                case (aidx)
                  4'd0: posreg <= 8'b0000_0001;
                  4'd1: posreg <= 8'b0000_0010;
                  4'd2: posreg <= 8'b0000_0100;
                  4'd3: posreg <= 8'b0000_1000;
                  4'd4: posreg <= 8'b0001_0000;
                  4'd5: posreg <= 8'b0010_0000;
                  4'd6: posreg <= 8'b0100_0000;
                  4'd7: posreg <= 8'b1000_0000;
                  default: posreg <= 8'b0;
                endcase

                case (chrarr[aidx])
                  8'h30, 8'h4F: chrreg <= 8'b1100_0000;  // "0", "O"
                  8'h31:       chrreg <= 8'b1111_1001;  // "1"
                  8'h32:       chrreg <= 8'b1010_0100;  // "2"
                  8'h33:       chrreg <= 8'b1011_0000;  // "3"
                  8'h34:       chrreg <= 8'b1001_1001;  // "4"
                  8'h35, 8'h53, 8'h73: chrreg <= 8'b1001_0010;  // "5", "S", "s"
                  8'h36:       chrreg <= 8'b1000_0010;  // "6"
                  8'h37:       chrreg <= 8'b1111_1000;  // "7"
                  8'h38:       chrreg <= 8'b1000_0000;  // "8"
                  8'h39:       chrreg <= 8'b1001_1000;  // "9"
                  8'h41:       chrreg <= 8'b1000_1000;  // "A"
                  8'h61:       chrreg <= 8'b1010_0000;  // "a"
                  8'h42, 8'h62: chrreg <= 8'b1000_0011;  // "B", "b"
                  8'h43:       chrreg <= 8'b1100_0110;  // "C"
                  8'h63:       chrreg <= 8'b1010_0111;  // "c"
                  8'h44, 8'h64: chrreg <= 8'b1010_0001;  // "D", "d"
                  8'h45:       chrreg <= 8'b1000_0110;  // "E"
                  8'h65:       chrreg <= 8'b1000_0100;  // "e"
                  8'h46, 8'h66: chrreg <= 8'b1000_1110;  // "F", "f"
                  8'h47, 8'h67: chrreg <= 8'b1001_0000;  // "G", "g"
                  8'h48:       chrreg <= 8'b1000_1001;  // "H"
                  8'h68:       chrreg <= 8'b1000_1011;  // "h"
                  8'h4A:       chrreg <= 8'b1111_0001;  // "J"
                  8'h6A:       chrreg <= 8'b1111_0011;  // "j"
                  8'h4C:       chrreg <= 8'b1100_0111;  // "L"
                  8'h6C:       chrreg <= 8'b1110_0111;  // "l"
                  8'h4E, 8'h6E: chrreg <= 8'b1010_1011;  // "N", "n"
                  8'h6F:       chrreg <= 8'b1010_1011;  // "o"
                  8'h50, 8'h70: chrreg <= 8'b1000_1100;  // "P", "p"
                  8'h51:       chrreg <= 8'b0100_0000;  // "Q"
                  8'h71:       chrreg <= 8'b0010_0011;  // "q"
                  8'h52:       chrreg <= 8'b1100_1110;  // "R"
                  8'h72:       chrreg <= 8'b1010_1111;  // "r"
                  8'h54, 8'h74: chrreg <= 8'b1000_0111;  // "T", "t"
                  8'h55:       chrreg <= 8'b1100_0001;  // "U"
                  8'h75:       chrreg <= 8'b1110_0011;  // "u"
                  8'hB0:       chrreg <= 8'b1001_1100;  // "°"
                  8'h2E:       chrreg <= 8'b0111_1111;  // "."
                  default:     chrreg <= 8'b1111_1111;
                endcase
                dataout <= {posreg, chrreg};
                state   <= ST_SHIFT;
              end

            ST_SHIFT:
              begin
                if(RDY)
                  begin
                    if(aidx < 8)
                      begin
                        aidx    <= aidx + 1'b1;
                        state   <= ST_READCHR;
                      end
                    else
                      begin
                        loaded <= 1'b1;
                        state  <= ST_READY;
                      end
                  end
              end

            default: state <= ST_READY;
          endcase
        end
    end

  always @(state)
    begin
      if(state == ST_SHIFT)
        begin
          ENA <= 1'b1;
          ENB <= 1'b1;
        end
      else
        begin
          ENA <= 1'b0;
          ENB <= 1'b0;
        end
    end

  always @(*)
    begin
      EN <= (ENA || ENB);
    end

  assign READY  = (state == ST_READY && loaded == 1'b0)  ? 1'b1 : 1'b0;

endmodule