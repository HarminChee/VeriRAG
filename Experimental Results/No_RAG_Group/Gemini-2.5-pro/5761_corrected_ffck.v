`timescale 1ns / 1ps
module yl3_interface_corrected_ffc (
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
  reg         RDY_d1; // Register to detect RDY falling edge synchronously

  wire        RDY;

  YL3_Shift_Register ShiftReg (
    .CLK(CLK),
    .DATA_IN(dataout),
    .EN_IN(EN),
    .RDY(RDY),
    .RCLK(RCK),
    .SRCLK(SCK),
    .SER_OUT(DIO)
  );

  // Removed always @(negedge RDY) block

  always @(posedge CLK) begin
    if (!nRST) begin
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
      ENA        <= 1'b0; // Reset ENA
      ENB        <= 1'b0; // Reset ENB
      RDY_d1     <= 1'b0; // Reset RDY_d1 (assuming RDY is low at reset)
    end else begin
      // Synchronous detection of RDY falling edge
      RDY_d1 <= RDY;

      // Update ENA based on conditions
      // Priority to clear on RDY falling edge
      if (RDY_d1 && !RDY) begin // Falling edge detected
        ENA <= 1'b0;
      end else if (state == ST_READCHR && {posreg, chrreg} == dataout) begin // Transitioning to ST_SHIFT
        ENA <= 1'b1;
      end
      // Note: If neither condition is met, ENA retains its value (implied ENA <= ENA)

      // Update ENB synchronously
      if (state == ST_SHIFT && RDY) begin
        ENB <= 1'b1;
      end else begin
        ENB <= 1'b0;
      end

      // State machine and data logic
      if (state != ST_SHIFT) begin
        // Placeholder for potential logic outside ST_SHIFT update
      end

      case (state)
        ST_READY: begin
          if (LOAD == 1) begin
            if ({chrarr[0], chrarr[1], chrarr[2], chrarr[3], chrarr[4], chrarr[5], chrarr[6], chrarr[7]} != DATA) begin
              chrarr[0] <= DATA[63:56];
              chrarr[1] <= DATA[55:48];
              chrarr[2] <= DATA[47:40];
              chrarr[3] <= DATA[39:32];
              chrarr[4] <= DATA[31:24];
              chrarr[5] <= DATA[23:16];
              chrarr[6] <= DATA[15:8];
              chrarr[7] <= DATA[7:0];
              loaded    <= 1'b0; // Ensure loaded is low while loading new data
            end else begin
              // Data matches, prepare to process
              loaded <= 1'b1;
              state  <= ST_READCHR;
              aidx   <= 4'b0; // Start processing from the first character
            end
          end else begin
             loaded <= 1'b0; // Reset loaded if LOAD goes low
          end
        end
        ST_READCHR: begin
          delaycnt <= 4'b0; // Reset delay counter (usage unclear in original code)
          if ({posreg, chrreg} != dataout) begin // If data needs update based on current aidx
             // Assign posreg based on aidx
             case (aidx)
               0: posreg <= 8'b0000_0001;
               1: posreg <= 8'b0000_0010;
               2: posreg <= 8'b0000_0100;
               3: posreg <= 8'b0000_1000;
               4: posreg <= 8'b0001_0000;
               5: posreg <= 8'b0010_0000;
               6: posreg <= 8'b0100_0000;
               7: posreg <= 8'b1000_0000;
               default: posreg <= 8'b0; // Default case
             endcase

             // Assign chrreg based on character in chrarr[aidx]
             case (chrarr[aidx])
               "0", "O": chrreg <= 8'b1100_0000;
               "1":      chrreg <= 8'b1111_1001;
               "2":      chrreg <= 8'b1010_0100;
               "3":      chrreg <= 8'b1011_0000;
               "4":      chrreg <= 8'b1001_1001;
               "5", "S", "s": chrreg <= 8'b1001_0010;
               "6":      chrreg <= 8'b1000_0010;
               "7":      chrreg <= 8'b1111_1000;
               "8":      chrreg <= 8'b1000_0000;
               "9":      chrreg <= 8'b1001_1000;
               "A":      chrreg <= 8'b1000_1000;
               "a":      chrreg <= 8'b1010_0000;
               "B", "b": chrreg <= 8'b1000_0011;
               "C":      chrreg <= 8'b1100_0110;
               "c":      chrreg <= 8'b1010_0111;
               "D", "d": chrreg <= 8'b1010_0001;
               "E":      chrreg <= 8'b1000_0110;
               "e":      chrreg <= 8'b1000_0100;
               "F", "f": chrreg <= 8'b1000_1110;
               "G", "g": chrreg <= 8'b1001_0000;
               "H":      chrreg <= 8'b1000_1001;
               "h":      chrreg <= 8'b1000_1011;
               "J":      chrreg <= 8'b1111_0001;
               "j":      chrreg <= 8'b1111_0011;
               "L":      chrreg <= 8'b1100_0111;
               "l":      chrreg <= 8'b1110_0111;
               "N", "n": chrreg <= 8'b1010_1011;
               "o":      chrreg <= 8'b1010_1011; // Note: Same as 'n' in original
               "P", "p": chrreg <= 8'b1000_1100;
               "Q":      chrreg <= 8'b0100_0000; // Note: Different from 'q'
               "q":      chrreg <= 8'b0010_0011; // Note: Different from 'Q'
               "R":      chrreg <= 8'b1100_1110;
               "r":      chrreg <= 8'b1010_1111;
               "T", "t": chrreg <= 8'b1000_0111;
               "U":      chrreg <= 8'b1100_0001;
               "u":      chrreg <= 8'b1110_0011;
               "°":      chrreg <= 8'b1001_1100;
               ".":      chrreg <= 8'b0111_1111;
               default:  chrreg <= 8'b1111_1111; // Blank segment
             endcase
             dataout <= {posreg, chrreg}; // Update dataout combinationally based on new posreg/chrreg
          end else begin // Data matches, ready to shift
            aidx    <= aidx + 1'b1;
            state   <= ST_SHIFT;
            // ENA is set high on this transition (handled above)
          end
        end
        ST_SHIFT: begin
          if (RDY) begin // Shift register is ready for next data/action
            if (aidx < 8) begin // More characters to display
              // Prepare for the next character immediately
              // No need to explicitly clear posreg/chrreg/dataout here if ST_READCHR handles it
              state   <= ST_READCHR;
            end else begin // All characters shifted
              loaded <= 1'b0; // Mark processing complete
              state  <= ST_READY; // Return to ready state
            end
          end
          // While RDY is low, stay in ST_SHIFT, ENA/ENB control the ShiftReg instance
        end
        default: begin
           state <= ST_READY; // Default back to READY state
        end
      endcase
    end
  end

  // Combinational logic for EN based on registered ENA and ENB
  always @(*) begin
    EN = (ENA || ENB);
  end

  // Combinational logic for READY output
  assign READY = (state == ST_READY && loaded == 0) ? 1'b1 : 1'b0;

endmodule