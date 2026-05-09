`timescale 1 ns / 1 ps
`timescale 1 ns / 1 ps
module step_curve_short
(
  input clk,
  input [15:0]stage_A2_cntr,
  output reg CAL,
  output CS,
  output IS1,
  output IS2,
  output reg LE,
  output R12,
  output reg RBI,
  output reg RESET,
  output reg RPHI1,
  output reg RPHI2,
  output SBI,
  output SEB,
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
assign CS=0;
assign SBI=0;
assign SEB=1;
assign R12=0;
assign IS1=1;
assign IS2=0;
assign SR=1;
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
        SPHI1 <= 0;
        SPHI2 <= 0;
        RESET <= 0;
        RBI <= 1;
        RPHI1 <= 1;
        RPHI2 <= 1;
        LE <= 1;
      end
      if(counter == 2) begin
        SPHI1 <= 1;
        SPHI2 <= 1;
      end
      if(counter == 5) begin
        SPHI1 <= 0;
        SPHI2 <= 0;
      end
      if(counter == 9) begin
        if(stage_iter == 0) begin
          stage <= (stage + 1) % 5;
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
        CAL <= 0;
        SPHI1 <= 0;
        SPHI2 <= 0;
        RESET <= 0;
        RBI <= 1;
        RPHI1 <= 1;
        RPHI2 <= 1;
        LE <= 1;
      end
      if(counter == 0) begin
        if(stage_iter == stage_A2_cntr-1) begin
          stage <= (stage + 1) % 5;
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
        CAL <= 0;
        SPHI1 <= 0;
        SPHI2 <= 0;
        RESET <= 0;
        RBI <= 1;
        RPHI1 <= 1;
        RPHI2 <= 1;
        LE <= 0;
      end
      if(counter == 2) begin
        RESET <= 1;
      end
      if(counter == 4) begin
        RBI <= 0;
      end
      if(counter == 8) begin
        RPHI1 <= 0;
        RPHI2 <= 0;
      end
      if(counter == 11) begin
        RBI <= 1;
        RPHI1 <= 1;
      end
      if(counter == 12) begin
        RPHI1 <= 0;
      end
      if(counter == 13) begin
        RBI <= 0;
      end
      if(counter == 13) begin
        if(stage_iter == 0) begin
          stage <= (stage + 1) % 5;
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
        SPHI1 <= 0;
        SPHI2 <= 0;
        RESET <= 1;
        RBI <= 0;
        RPHI1 <= 0;
        RPHI2 <= 1;
        LE <= 1;
      end
      if(counter == 21) begin
        RPHI2 <= 0;
      end
      if(counter == 22) begin
        RPHI1 <= 1;
      end
      if(counter == 23) begin
        RPHI1 <= 0;
      end
      if(counter == 23) begin
        if(stage_iter == 126) begin
          stage <= (stage + 1) % 5;
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
        CAL <= 1;
        SPHI1 <= 0;
        SPHI2 <= 0;
        RESET <= 1;
        RBI <= 0;
        RPHI1 <= 0;
        RPHI2 <= 0;
        LE <= 1;
      end
      if(counter == 0) begin
        if(stage_iter == 299) begin
          stage <= (stage + 1) % 5;
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
