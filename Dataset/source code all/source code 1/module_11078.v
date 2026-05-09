`timescale 1 ns / 1 ps
`timescale 1 ns / 1 ps
module step_curve_new
(
  input clk,
  input [15:0]stage_PIPELINE_SHIFT_IN_cntr,
  output reg CAL,
  output CS,
  output IS1,
  output IS2,
  output reg LE,
  output reg R12,
  output reg RBI,
  output reg RESET,
  output reg RPHI1,
  output reg RPHI2,
  output reg SBI,
  output reg SEB,
  output reg SPHI1,
  output reg SPHI2,
  output SR,
  output [15:0]Aref,
  output [15:0]RG,
  output [15:0]Vana,
  output [15:0]Vthr,
  input reset_gen
);
reg [31:0]counter;
reg [7:0]stage;
reg [15:0]stage_iter;
reg ISSR;
assign IS1=ISSR;
assign IS2=ISSR;
assign SR=ISSR;
assign CS=0;
assign Vthr=16'H0025;
assign Aref=16'H0033;
assign Vana=16'H0066;
assign RG=16'H0033;
always @(posedge clk) begin
  if(reset_gen == 1) begin
    counter <= 0;
    stage <= 0;
    stage_iter <= 0;
  end
  else begin
    if(stage == 0) begin
      if(counter == 0) begin
        CAL <= 1;
        SBI <= 1;
        SPHI1 <= 1;
        SPHI2 <= 1;
        SEB <= 0;
        ISSR <= 0;
        RESET <= 1;
        R12 <= 0;
        RBI <= 1;
        RPHI1 <= 1;
        RPHI2 <= 1;
        LE <= 1;
      end
      if(counter == 9) begin
        if(stage_iter == 0) begin
          stage <= (stage + 1) % 8;
          stage_iter <= 0;
        end
        else begin
          stage_iter <= stage_iter + 1;
        end
        counter <= 0;
      end
      else begin
        counter <= counter + 1;
      end
    end
    if(stage == 1) begin
      if(counter == 0) begin
        CAL <= 1;
        SBI <= 0;
        SPHI1 <= 1;
        SPHI2 <= 1;
        SEB <= 1;
        ISSR <= 1;
        RESET <= 1;
        R12 <= 1;
        RBI <= 1;
        RPHI1 <= 1;
        RPHI2 <= 1;
        LE <= 1;
      end
      if(counter == 2) begin
        SPHI1 <= 0;
        SPHI2 <= 0;
      end
      if(counter == 8) begin
        SEB <= 0;
      end
      if(counter == 16) begin
        RESET <= 0;
      end
      if(counter == 23) begin
        if(stage_iter == 0) begin
          stage <= (stage + 1) % 8;
          stage_iter <= 0;
        end
        else begin
          stage_iter <= stage_iter + 1;
        end
        counter <= 0;
      end
      else begin
        counter <= counter + 1;
      end
    end
    if(stage == 2) begin
      if(counter == 0) begin
        CAL <= 1;
        SBI <= 0;
        SPHI1 <= 0;
        SPHI2 <= 0;
        SEB <= 0;
        ISSR <= 1;
        RESET <= 0;
        R12 <= 1;
        RBI <= 1;
        RPHI1 <= 1;
        RPHI2 <= 1;
        LE <= 1;
      end
      if(counter == 1) begin
        SBI <= 1;
        SPHI1 <= 1;
      end
      if(counter == 2) begin
        SPHI1 <= 0;
      end
      if(counter == 3) begin
        SBI <= 0;
        SPHI2 <= 1;
      end
      if(counter == 4) begin
        SPHI2 <= 0;
      end
      if(counter == 5) begin
        SPHI1 <= 1;
      end
      if(counter == 6) begin
        SPHI1 <= 0;
      end
      if(counter == 7) begin
        SPHI2 <= 1;
      end
      if(counter == 8) begin
        SPHI2 <= 0;
      end
      if(counter == 9) begin
        SPHI1 <= 1;
      end
      if(counter == 10) begin
        SPHI1 <= 0;
      end
      if(counter == 11) begin
        SPHI2 <= 1;
      end
      if(counter == 12) begin
        SPHI2 <= 0;
      end
      if(counter == 13) begin
        SPHI1 <= 1;
      end
      if(counter == 14) begin
        SPHI1 <= 0;
      end
      if(counter == 15) begin
        SPHI2 <= 1;
      end
      if(counter == 16) begin
        SPHI2 <= 0;
      end
      if(counter == 17) begin
        SPHI1 <= 1;
      end
      if(counter == 18) begin
        SPHI1 <= 0;
      end
      if(counter == 19) begin
        SPHI2 <= 1;
      end
      if(counter == 20) begin
        SPHI2 <= 0;
      end
      if(counter == 21) begin
        SPHI1 <= 1;
      end
      if(counter == 22) begin
        SPHI1 <= 0;
      end
      if(counter == 23) begin
        SPHI2 <= 1;
      end
      if(counter == 24) begin
        SPHI2 <= 0;
      end
      if(counter == 25) begin
        SPHI1 <= 1;
      end
      if(counter == 26) begin
        SPHI1 <= 0;
      end
      if(counter == 27) begin
        SPHI2 <= 1;
      end
      if(counter == 28) begin
        SPHI2 <= 0;
      end
      if(counter == 29) begin
        CAL <= 0;
        SPHI1 <= 1;
      end
      if(counter == 30) begin
        SPHI1 <= 0;
      end
      if(counter == 31) begin
        SPHI2 <= 1;
      end
      if(counter == 32) begin
        SPHI2 <= 0;
      end
      if(counter == 33) begin
        SPHI1 <= 1;
      end
      if(counter == 34) begin
        SPHI1 <= 0;
      end
      if(counter == 35) begin
        SPHI2 <= 1;
      end
      if(counter == 36) begin
        SPHI2 <= 0;
      end
      if(counter == 37) begin
        SPHI1 <= 1;
      end
      if(counter == 38) begin
        SPHI1 <= 0;
      end
      if(counter == 39) begin
        SPHI2 <= 1;
      end
      if(counter == 40) begin
        SPHI2 <= 0;
      end
      if(counter == 41) begin
        SPHI1 <= 1;
      end
      if(counter == 42) begin
        SPHI1 <= 0;
      end
      if(counter == 43) begin
        SPHI2 <= 1;
      end
      if(counter == 44) begin
        SPHI2 <= 0;
      end
      if(counter == 45) begin
        SPHI1 <= 1;
      end
      if(counter == 46) begin
        SPHI1 <= 0;
      end
      if(counter == 47) begin
        SPHI2 <= 1;
      end
      if(counter == 48) begin
        SPHI2 <= 0;
      end
      if(counter == 49) begin
        SPHI1 <= 1;
      end
      if(counter == 50) begin
        SPHI1 <= 0;
      end
      if(counter == 51) begin
        SPHI2 <= 1;
      end
      if(counter == 52) begin
        SPHI2 <= 0;
      end
      if(counter == 53) begin
        SPHI1 <= 1;
      end
      if(counter == 54) begin
        SPHI1 <= 0;
      end
      if(counter == 55) begin
        SPHI2 <= 1;
      end
      if(counter == 56) begin
        SPHI2 <= 0;
      end
      if(counter == 57) begin
        SPHI1 <= 1;
      end
      if(counter == 58) begin
        SPHI1 <= 0;
      end
      if(counter == 59) begin
        SPHI2 <= 1;
      end
      if(counter == 60) begin
        SPHI2 <= 0;
      end
      if(counter == 61) begin
        SPHI1 <= 1;
      end
      if(counter == 62) begin
        SPHI1 <= 0;
      end
      if(counter == 63) begin
        SPHI2 <= 1;
      end
      if(counter == 64) begin
        SPHI2 <= 0;
      end
      if(counter == 64) begin
        if(stage_iter == 0) begin
          stage <= (stage + 1) % 8;
          stage_iter <= 0;
        end
        else begin
          stage_iter <= stage_iter + 1;
        end
        counter <= 0;
      end
      else begin
        counter <= counter + 1;
      end
    end
    if(stage == 3) begin
      if(counter == 0) begin
        CAL <= 0;
        SBI <= 0;
        SPHI1 <= 0;
        SPHI2 <= 0;
        SEB <= 0;
        ISSR <= 1;
        RESET <= 0;
        R12 <= 1;
        RBI <= 1;
        RPHI1 <= 1;
        RPHI2 <= 1;
        LE <= 1;
      end
      if(counter == 1) begin
        RESET <= 1;
      end
      if(counter == 3) begin
        SEB <= 1;
      end
      if(counter == 4) begin
        ISSR <= 0;
      end
      if(counter == 5) begin
        R12 <= 0;
      end
      if(counter == 13) begin
        SPHI1 <= 1;
        SPHI2 <= 1;
      end
      if(counter == 17) begin
        SPHI1 <= 0;
        SPHI2 <= 0;
      end
      if(counter == 24) begin
        SBI <= 1;
        SPHI1 <= 1;
      end
      if(counter == 25) begin
        SPHI1 <= 0;
      end
      if(counter == 26) begin
        SPHI2 <= 1;
      end
      if(counter == 27) begin
        SBI <= 0;
        SPHI2 <= 0;
      end
      if(counter == 27) begin
        if(stage_iter == 0) begin
          stage <= (stage + 1) % 8;
          stage_iter <= 0;
        end
        else begin
          stage_iter <= stage_iter + 1;
        end
        counter <= 0;
      end
      else begin
        counter <= counter + 1;
      end
    end
    if(stage == 4) begin
      if(counter == 0) begin
        CAL <= 0;
        SBI <= 0;
        SPHI1 <= 1;
        SPHI2 <= 0;
        SEB <= 1;
        ISSR <= 0;
        RESET <= 1;
        R12 <= 0;
        RBI <= 1;
        RPHI1 <= 1;
        RPHI2 <= 1;
        LE <= 1;
      end
      if(counter == 1) begin
        SPHI1 <= 0;
      end
      if(counter == 2) begin
        SPHI2 <= 1;
      end
      if(counter == 3) begin
        SPHI2 <= 0;
      end
      if(counter == 3) begin
        if(stage_iter == stage_PIPELINE_SHIFT_IN_cntr-1) begin
          stage <= (stage + 1) % 8;
          stage_iter <= 0;
        end
        else begin
          stage_iter <= stage_iter + 1;
        end
        counter <= 0;
      end
      else begin
        counter <= counter + 1;
      end
    end
    if(stage == 5) begin
      if(counter == 0) begin
        CAL <= 0;
        SBI <= 0;
        SPHI1 <= 0;
        SPHI2 <= 0;
        SEB <= 1;
        ISSR <= 0;
        RESET <= 1;
        R12 <= 0;
        RBI <= 1;
        RPHI1 <= 1;
        RPHI2 <= 1;
        LE <= 1;
      end
      if(counter == 2) begin
        LE <= 0;
      end
      if(counter == 6) begin
        RESET <= 0;
      end
      if(counter == 21) begin
        SEB <= 0;
      end
      if(counter == 29) begin
        SEB <= 1;
      end
      if(counter == 34) begin
        RBI <= 0;
      end
      if(counter == 37) begin
        RPHI1 <= 0;
        RPHI2 <= 0;
      end
      if(counter == 38) begin
        if(stage_iter == 0) begin
          stage <= (stage + 1) % 8;
          stage_iter <= 0;
        end
        else begin
          stage_iter <= stage_iter + 1;
        end
        counter <= 0;
      end
      else begin
        counter <= counter + 1;
      end
    end
    if(stage == 6) begin
      if(counter == 0) begin
        CAL <= 0;
        SBI <= 0;
        SPHI1 <= 0;
        SPHI2 <= 0;
        SEB <= 1;
        ISSR <= 0;
        RESET <= 0;
        R12 <= 0;
        RBI <= 0;
        RPHI1 <= 0;
        RPHI2 <= 0;
        LE <= 0;
      end
      if(counter == 2) begin
        RBI <= 1;
        RPHI1 <= 1;
      end
      if(counter == 4) begin
        RPHI1 <= 0;
      end
      if(counter == 5) begin
        RBI <= 0;
      end
      if(counter == 8) begin
        LE <= 1;
      end
      if(counter == 11) begin
        if(stage_iter == 0) begin
          stage <= (stage + 1) % 8;
          stage_iter <= 0;
        end
        else begin
          stage_iter <= stage_iter + 1;
        end
        counter <= 0;
      end
      else begin
        counter <= counter + 1;
      end
    end
    if(stage == 7) begin
      if(counter == 0) begin
        CAL <= 0;
        SBI <= 0;
        SPHI1 <= 0;
        SPHI2 <= 0;
        SEB <= 1;
        ISSR <= 0;
        RESET <= 0;
        R12 <= 0;
        RBI <= 0;
        RPHI1 <= 0;
        RPHI2 <= 0;
        LE <= 1;
      end
      if(counter == 1) begin
        RPHI2 <= 1;
      end
      if(counter == 21) begin
        RPHI2 <= 0;
      end
      if(counter == 22) begin
        RPHI1 <= 1;
      end
      if(counter == 22) begin
        if(stage_iter == 134) begin
          stage <= (stage + 1) % 8;
          stage_iter <= 0;
        end
        else begin
          stage_iter <= stage_iter + 1;
        end
        counter <= 0;
      end
      else begin
        counter <= counter + 1;
      end
    end
  end
end
endmodule
